import 'package:my_rag_project_server/src/business/schema_importer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:my_rag_project_server/src/business/search.dart';
import 'package:my_rag_project_server/src/generative_ai/generative_ai.dart';
import 'package:my_rag_project_server/src/generated/protocol.dart';
import 'dart:math';

class RagEndpoint extends Endpoint {
  /// Creates a new chat session in the database.
  /// This is called by the mobile app on startup to initialize a conversation.
  Future<ChatSession> createSession(Session session) async {
    final chatSession = ChatSession(
      keyToken: _generateRandomString(16),
      createdAt: DateTime.now(),
    );
    return await ChatSession.db.insertRow(session, chatSession);
  }

  Future<void> triggerSchemaImport(Session session) async {
    await SchemaImporter.importSchemaData(session);
  }

  /// The main chat method.
  /// It handles the logic for switching between Schema Search (SQL structure)
  /// and Content Search (Documents), maintains history, and saves messages.
  Stream<String> ask(Session session, int chatSessionId, String question,
      bool searchListPanels) async* {
    final genAi = GenerativeAi();

    // 1. Verify that the session exists
    final chatSession = await ChatSession.db.findById(session, chatSessionId);
    if (chatSession == null) {
      throw Exception('Chat session not found (ID: $chatSessionId)');
    }

    // 2. Load previous messages (Memory)
    // We retrieve the conversation history to allow the AI to understand context.
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

    if (searchListPanels) {
      // --- MODE A: SCHEMA RAG (Database Structure) ---
      // Search for relevant List Panels (tables) instead of documents.
      final panels = await findRelevantListPanels(session, question);

      // Format the found panels into a string context for the AI
      // (Labels here are in Hungarian so the AI understands the data structure)
      String contextData = "Elérhető Listapanelek (Adattáblák):\n";
      for (var p in panels) {
        contextData +=
            "- ID: ${p.distributionId}\n  Név: ${p.nameHun}\n  Leírás: ${p.descriptionHun}\n  Ügyvitel: ${p.businessDescriptionHun}\n\n";
      }

      // Create a specialized prompt for an ERP Expert (IN HUNGARIAN)
      systemPrompt = '''
Te egy intelligens ERP adatbázis szakértő vagy. A feladatod kiválasztani a megfelelő adattáblát (Listapanelt) a felhasználó kérdéséhez, és elmagyarázni, hogyan kell szűrni az adatokat.

$contextData

Feladat:
1. Válaszd ki a legrelevánsabb Listapanelt az ID-ja alapján.
2. A válaszodat így kezdd: "A [ID] számú, [Név] nevű listapanel alapján..."
3. Ha a kérdés konkrét adatra vonatkozik (pl. "cseh szállítók"), akkor írd le, hogy milyen feltételeket keresnénk (pl. "Országkód = CZ").
''';
    } else {
      // --- MODE B: CONTENT RAG (Documentation) ---
      // Search for relevant knowledge documents.
      documents = await searchDocuments(session, question);

      // Create a general helpful assistant prompt (IN HUNGARIAN)
      systemPrompt =
          'Te egy segítőkész AI asszisztens vagy. Válaszolj a kérdésre KIZÁRÓLAG a megadott dokumentumok alapján. Ha a válasz nincs benne a dokumentumokban, mondd azt: "A megadott kontextus alapján nem tudok válaszolni".';
    }

    // 5. Generate the answer
    // We pass the constructed systemPrompt and the documents list.
    final answerStream = genAi.generateConversationalAnswer(
      question: question,
      systemPrompt: systemPrompt, // Hungarian prompt
      documents: documents,
      conversation: history,
    );

    // 6. Stream the answer back to the client and concatenate it for saving
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
