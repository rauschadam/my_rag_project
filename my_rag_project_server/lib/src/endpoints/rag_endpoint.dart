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
  /// and Content Search (Documents).
  ///
  /// CRITICAL SECURITY NOTE:
  /// When in Schema Search mode (`searchListPanels` is true), actual data is NEVER
  /// sent back to the cloud AI. The AI is only used to PLAN the query.
  /// The execution and response formatting happen locally (Offline) to prevent data leakage.
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

    // 4. Handle Logic based on mode
    if (searchListPanels) {
      // --- MODE A: SECURE ERP DATA QUERY (REAL RAG) ---

      // Step A: Router & Planner (AI)
      // We search for relevant metadata (descriptions of tables), not the data itself.
      final panels = await findRelevantListPanels(session, question);

      // Construct a description of available tables for the AI.
      // In a real app, you would map 'distributionId' to actual SQL table names here.
      // For this demo, we map ID 125 to 'mock_supplier_data'.
      String panelDesc = panels.map((p) {
        String tableName = (p.distributionId == 125)
            ? 'list_panel_suplier_data'
            : 'unknown_table';
        return "ID: ${p.distributionId}, SQL Tábla: $tableName, Név: ${p.nameHun}\n   Leírás: ${p.descriptionHun}";
      }).join("\n\n");

      // HUNGARIAN PROMPT: Ask the AI to plan the SQL query in JSON format.
      final queryPlanPrompt = '''
A felhasználó kérdése: "$question"

Elérhető táblák definíciója:
$panelDesc

A 'list_panel_suplier_data' (Szállítók) tábla fontosabb mezői (PONTOSAN ezeket használd):
- vendorName (Szállító neve, szöveg)
- countryCode (Országkód, pl. HU, CZ, DE, szöveg)
- category (Kategória, pl. Szolgáltatás, Termék, szöveg)
- amount (Összeg, szöveg)

FELADAT: Elemzed a kérdést és készíts egy SQL-szerű lekérdezési tervet JSON formátumban.
A "filters" tömbben sorold fel a feltételeket.
Az operátor lehet: "=", "!=", ">", "<", "ILIKE" (szöveges keresésnél).

Kimeneti formátum (Csak a nyers JSON):
{
  "tableName": "list_panel_suplier_data",
  "filters": [
    {"column": "countryCode", "operator": "=", "value": "CZ"},
    {"column": "vendorName", "operator": "ILIKE", "value": "%Szolgáltatás%"}
  ],
  "limit": 10
}
''';

      // Call Cloud AI to get the PLAN (No sensitive data sent here, only schema info)
      final queryPlanJson = await genAi.generateSimpleAnswer(queryPlanPrompt);
      session.log("AI Query Plan: $queryPlanJson");

      // Step B: Generic Execution (Local Dart Code)
      String finalResponse = "";

      try {
        final cleanJson = queryPlanJson
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final plan = jsonDecode(cleanJson);

        // Execute the dynamic query locally
        final results = await _executeDynamicQuery(session, plan);

        // Step C: Synthesis (Offline Formatting)
        // We format the data locally into a Markdown string.
        // This ensures the actual rows (vendor names, money) are NEVER sent to the AI API.

        if (results.isEmpty) {
          finalResponse =
              "Nem találtam adatot a megadott feltételekkel az adatbázisban.";
        } else {
          finalResponse =
              "**Lekérdezés eredménye (${results.length} találat):**\n\n";

          // Generic formatter: iterates over all columns in the result
          for (var row in results) {
            finalResponse += "- ";
            var infoParts = <String>[];

            // Try to find a "main" column for the title (heuristic)
            String? title;
            if (row.containsKey('vendor_name')) {
              title = row['vendor_name'];
            } else if (row.containsKey('name')) {
              title = row['name'];
            }

            if (title != null) {
              finalResponse += "**$title** ";
            }

            // Add other details
            row.forEach((key, value) {
              if (key != 'id' && key != 'vendor_name' && key != 'name') {
                // Format dates nicely if needed
                String valStr = value.toString();
                if (value is DateTime) valStr = valStr.substring(0, 10);
                infoParts.add("_$key: ${valStr}_");
              }
            });

            if (infoParts.isNotEmpty) {
              finalResponse += "(${infoParts.join(', ')})";
            }
            finalResponse += "\n";
          }

          finalResponse +=
              "\n*(Az adatokat biztonságosan, offline generáltam)*";
        }
      } catch (e) {
        session.log("Query execution error: $e", level: LogLevel.error);
        finalResponse =
            "Hiba történt a lekérdezés feldolgozása közben. (Részletek a szerver logban)";
      }

      // Stream the local response back to the client
      yield finalResponse;

      // Save the model response to history
      await ChatMessage.db.insertRow(
        session,
        ChatMessage(
          chatSessionId: chatSessionId,
          message: finalResponse,
          type: ChatMessageType.model,
          createdAt: DateTime.now(),
        ),
      );

      // Return immediately to avoid calling the general AI logic below
      return;
    } else {
      // --- MODE B: CONTENT RAG (Documentation Search) ---
      // This mode uses the Cloud AI to generate the answer based on documents.
      // Suitable for public or non-sensitive documentation.

      List<RAGDocument> documents = await searchDocuments(session, question);

      // HUNGARIAN PROMPT: General assistant prompt
      String systemPrompt =
          'Te egy segítőkész AI asszisztens vagy. Válaszolj a kérdésre KIZÁRÓLAG a megadott dokumentumok alapján. Ha a válasz nincs benne a dokumentumokban, mondd azt: "A megadott kontextus alapján nem tudok válaszolni".';

      final answerStream = genAi.generateConversationalAnswer(
        question: question,
        systemPrompt: systemPrompt,
        documents: documents,
        conversation: history,
      );

      var fullAnswer = '';
      await for (var chunk in answerStream) {
        fullAnswer += chunk;
        yield chunk;
      }

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
  }

  /// Executes a dynamic SQL query based on the JSON plan.
  /// Uses raw SQL with parameter substitution for safety.
  Future<List<Map<String, dynamic>>> _executeDynamicQuery(
      Session session, Map<String, dynamic> plan) async {
    // --- 1. Setup query data ---
    final tableName = plan['tableName'];
    final filters = plan['filters'] as List? ?? [];
    final limit = plan['limit'] ?? 10;

    // --- 2. Build the SQL query safely ---
    String query = "SELECT * FROM \"$tableName\" WHERE 1=1";

    for (int i = 0; i < filters.length; i++) {
      final f = filters[i];
      final column = f['column'];
      final operator = f['operator'];
      final value = f['value'];

      // Basic SQL Injection prevention for column names
      // (Only allow alphanumeric and underscores)
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(column)) continue;

      // Validate operator
      const allowedOperators = {'=', '!=', '>', '<', '>=', '<=', 'ILIKE'};
      if (!allowedOperators.contains(operator.toUpperCase())) continue;

      String valSql;
      if (value is num) {
        valSql = "$value";
      } else if (value is bool) {
        valSql = "$value";
      } else {
        // On strings we use a single qute for safety
        final safeValue = value.toString().replaceAll("'", "''");
        valSql = "'$safeValue'";
      }

      query += " AND \"$column\" $operator $valSql";
    }

    // Enforce a hard limit to prevent fetching huge datasets
    int safeLimit = (limit is int && limit > 0 && limit <= 50) ? limit : 10;
    query += " LIMIT $safeLimit";

    session.log("Executing Raw SQL: $query");

    // Execute raw query via Serverpod
    final result = await session.db.unsafeQuery(query);

    // Convert to List<Map>
    return result.map((row) => row.toColumnMap()).toList();
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
