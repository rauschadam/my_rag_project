import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';
import 'package:my_rag_project_server/src/business/schema_importer.dart';
import 'package:my_rag_project_server/src/business/search.dart';
import 'package:my_rag_project_server/src/generative_ai/generative_ai.dart';
import 'package:my_rag_project_server/src/generated/protocol.dart';

class RagEndpoint extends Endpoint {
  /// Creates a new chat session in the database.
  /// Called by the mobile app on startup.
  Future<ChatSession> createSession(Session session) async {
    final chatSession = ChatSession(
      keyToken: _generateRandomString(16),
      createdAt: DateTime.now(),
    );
    return await ChatSession.db.insertRow(session, chatSession);
  }

  /// Triggers the import of schema data and mock data into the vector store.
  Future<void> triggerSchemaImport(Session session) async {
    await SchemaImporter.importSchemaData(session);
  }

  /// The main chat method.
  /// Handles the logic for switching between Schema Search (SQL/Mock DB)
  /// and Content Search (Documents), maintains history, and saves messages.
  Stream<String> ask(Session session, int chatSessionId, String question,
      bool searchListPanels) async* {
    final genAi = GenerativeAi();

    // 1. Verify that the session exists
    final chatSession = await ChatSession.db.findById(session, chatSessionId);
    if (chatSession == null) {
      throw Exception('Chat session not found (ID: $chatSessionId)');
    }

    // 2. Load conversation history (Memory)
    final history = await ChatMessage.db.find(
      session,
      where: (t) => t.chatSessionId.equals(chatSessionId),
      orderBy: (t) => t.createdAt,
    );

    // 3. Save the USER'S question to the database
    await ChatMessage.db.insertRow(
      session,
      ChatMessage(
        chatSessionId: chatSessionId,
        message: question,
        type: ChatMessageType.user,
        createdAt: DateTime.now(),
      ),
    );

    // 4. Determine Context and Prompt based on the selected mode
    String systemPrompt;
    List<RAGDocument> documents = [];
    String contextData = "";

    if (searchListPanels) {
      // --- MODE A: REAL RAG / SIMULATION (Database Structure) ---
      // Step A: Router - Identify relevant list panels
      final panels = await findRelevantListPanels(session, question);

      // Create a string description of available panels for the AI planner
      String panelDesc = panels
          .map((p) => "ID: ${p.distributionId}, Név: ${p.nameHun}")
          .join("\n");

      // HUNGARIAN PROMPT: Ask the AI to plan the database query in JSON format.
      final queryPlanPrompt = '''
A felhasználó kérdése: "$question"

Elérhető panelek:
$panelDesc

A 125-ös panel (Szállítók) mezői:
- vendorName (Szállító neve)
- countryCode (Országkód, pl. HU, CZ, DE)
- category (Kategória, pl. Szolgáltatás, Termék, Vegyes)
- amount (Összeg)

Feladat: Elemzed a kérdést és készíts egy JSON struktúrát a lekérdezéshez.
A kimenet CSAK a nyers JSON legyen (markdown nélkül).

Formátum:
{
  "panelId": 125,
  "filters": {
    "countryCode": "CZ",  // Ha országra szűr (kétbetűs kód)
    "category": "Szolgáltatás" // Ha kategóriára szűr
  }
}
''';

      // Call AI to get the query plan
      final queryPlanJson = await genAi.generateSimpleAnswer(queryPlanPrompt);
      session.log("AI Query Plan: $queryPlanJson");

      // Step B: Execution - Run the query against the local database
      String dbResultString = "Nem találtam adatot a megadott feltételekkel.";

      try {
        // Clean the JSON string (remove potential markdown code blocks)
        final cleanJson = queryPlanJson
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final plan = jsonDecode(cleanJson);

        // SIMULATION LOGIC: Query the ListPanekSupplierData table
        if (plan['panelId'] == 125) {
          final filters = plan['filters'];

          // Build dynamic query
          Expression whereClause = Constant.bool(true);

          if (filters['countryCode'] != null) {
            whereClause = whereClause &
                ListPanelSupplierData.t.countryCode
                    .equals(filters['countryCode']);
          }
          if (filters['category'] != null) {
            whereClause = whereClause &
                ListPanelSupplierData.t.category.equals(filters['category']);
          }

          // Execute query
          final results = await ListPanelSupplierData.db
              .find(session, where: (_) => whereClause);

          if (results.isNotEmpty) {
            dbResultString =
                "Lekérdezés eredménye (Találatok száma: ${results.length}):\n";
            for (var row in results) {
              dbResultString +=
                  "- ${row.vendorName} (Ország: ${row.countryCode}, Típus: ${row.category}, Összeg: ${row.amount})\n";
            }
          }
        }
      } catch (e) {
        session.log("Query execution error: $e", level: LogLevel.error);
        dbResultString = "Hiba történt a lekérdezés értelmezésekor.";
      }

      // Step C: Synthesis - Provide the real data to the AI for the final answer
      contextData = dbResultString;

      // HUNGARIAN PROMPT: Instruct the AI to act as an ERP assistant using the data.
      systemPrompt = '''
Te egy intelligens ERP asszisztens vagy.
A felhasználó kérdésére KIZÁRÓLAG az alábbi adatbázis eredmények alapján válaszolj.

Adatbázis eredménye:
$contextData

Instrukciók:
1. Válaszolj magyarul.
2. Légy pontos és tényszerű.
3. Ha van lista, szépen formázva sorold fel.
4. Ha nem találtál adatot, jelezd udvariasan.
''';
    } else {
      // --- MODE B: CONTENT RAG (Documentation) ---
      // Search for relevant knowledge documents based on embeddings.
      documents = await searchDocuments(session, question);

      // HUNGARIAN PROMPT: General assistant for documentation.
      systemPrompt =
          'Te egy segítőkész AI asszisztens vagy. Válaszolj a kérdésre KIZÁRÓLAG a megadott dokumentumok alapján. Ha a válasz nincs benne a dokumentumokban, mondd azt: "A megadott kontextus alapján nem tudok válaszolni".';
    }

    // 5. Generate the answer stream
    // We pass the constructed systemPrompt and context/documents.
    final answerStream = genAi.generateConversationalAnswer(
      question: question,
      systemPrompt: systemPrompt,
      documents: documents, // Used only in Content RAG mode
      conversation: history,
    );

    // 6. Stream the answer back to the client and accumulate it for saving
    var fullAnswer = '';
    await for (var chunk in answerStream) {
      fullAnswer += chunk;
      yield chunk;
    }

    // 7. Save the AI'S full answer to the database
    await ChatMessage.db.insertRow(
      session,
      ChatMessage(
        chatSessionId: chatSessionId,
        message: fullAnswer,
        type: ChatMessageType.model,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Helper function to generate a random string token.
  String _generateRandomString(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
