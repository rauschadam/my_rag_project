import 'dart:convert';
import 'dart:math';

import 'package:my_rag_project_server/src/business/ollama_client.dart';
import 'package:serverpod/serverpod.dart';
import 'package:my_rag_project_server/src/business/schema_importer.dart';
import 'package:my_rag_project_server/src/business/search.dart';
import 'package:my_rag_project_server/src/generative_ai/generative_ai.dart';
import 'package:my_rag_project_server/src/generated/protocol.dart';
import 'package:my_rag_project_server/src/config/prompts.dart';

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
      // --- MODE A: SECURE DATA QUERY (ON-DEVICE AI PREPARATION) ---

      // We search for relevant metadata (descriptions of tables), not the data itself.
      final panels = await findRelevantListPanels(session, question);

      // Construct a description of available tables for the AI.
      // In a real app, you would map 'distributionId' to actual SQL table names here.
      // For this demo, we map ID 125 to 'mock_supplier_data'.
      String panelDesc = panels.map((p) {
        String tableName = 'unknown_table';
        if (p.distributionId == 125) tableName = 'list_panel_suplier_data';
        if (p.distributionId == 15) tableName = 'mock_country_data';
        return "ID: ${p.distributionId}, SQL Tábla: $tableName, Név: ${p.nameHun}\n   Leírás: ${p.descriptionHun}";
      }).join("\n\n");

      /// Current date for the AI
      final currentDate = DateTime.now().toIso8601String().substring(0, 10);

      // HUNGARIAN PROMPT: Ask the AI to plan the SQL query in JSON format.
      final queryPlanPrompt = Prompts.getQueryPlanPrompt(question, panelDesc, currentDate);

      // Call Cloud AI to get the PLAN (No sensitive data sent here, only schema info)
      final queryPlanJson = await genAi.generateSimpleAnswer(queryPlanPrompt);
      session.log("AI Query Plan: $queryPlanJson");

      try {
        final cleanJson = queryPlanJson
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final plan = jsonDecode(cleanJson);

        // 1. Execute the database query
        final results = await _executeDynamicQuery(session, plan);

        // Error: The results is empty
        if (results.isEmpty) {
          String noDataResponse =
              "Sajnos nem találtam adatot a megadott feltételekkel az adatbázisban.";
          yield noDataResponse;

          await ChatMessage.db.insertRow(
            session,
            ChatMessage(
              chatSessionId: chatSessionId,
              message: noDataResponse,
              type: ChatMessageType.model,
              createdAt: DateTime.now(),
            ),
          );
          return;
        }

        // The raw results are returned to the client in JSON format.
        // We use a prefix ("DATA_JSON:") so the client knows this is data, not text.

        // 2. map of display names based on the AI
        final List<dynamic> displayFields = plan['displayFields'] ?? [];
        final Map<String, String> aiLabelMap = {};

        for (var field in displayFields) {
          if (field is Map &&
              field['column'] != null &&
              field['label'] != null) {
            aiLabelMap[field['column']] = field['label'];
          }
        }

        StringBuffer rawContextBuffer = StringBuffer();
        for (var row in results) {
          rawContextBuffer.writeln("--- Adatsor ---");
          row.forEach((key, value) {
            // Format date
            var valStr = value.toString();
            if (value is DateTime) valStr = valStr.substring(0, 10);

            // Use Hungarian label if available
            var label = aiLabelMap[key] ?? key;

            rawContextBuffer.writeln("$label: $valStr");
          });
        }

        // 3. Call Ollama (Server-Side)
        final aiResponse = await OllamaClient.generateRefinedResponse(
            session, rawContextBuffer.toString(), question);

        // 4. Return the AI response text to Client
        yield aiResponse;

        // 5. Log to history
        await ChatMessage.db.insertRow(
          session,
          ChatMessage(
            chatSessionId: chatSessionId,
            message: aiResponse,
            type: ChatMessageType.model,
            createdAt: DateTime.now(),
          ),
        );

        return;
      } catch (e) {
        session.log("Query/AI Error: $e", level: LogLevel.error);
        String errorMessage = "Hiba történt a lekérdezés feldolgozása közben.";
        yield errorMessage;

        await ChatMessage.db.insertRow(
          session,
          ChatMessage(
            chatSessionId: chatSessionId,
            message: errorMessage,
            type: ChatMessageType.model,
            createdAt: DateTime.now(),
          ),
        );
        return;
      }
    } else {
      // --- MODE B: CONTENT RAG (Documentation Search) ---
      // This mode uses the Cloud AI to generate the answer based on documents.
      // Suitable for public or non-sensitive documentation.

      List<RAGDocument> documents = await searchDocuments(session, question);

      // HUNGARIAN PROMPT: General assistant prompt
      String systemPrompt = Prompts.systemPromptDocuments;

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
    final displayFields = plan['displayFields'] as List?;
    final filters = plan['filters'] as List? ?? [];
    final orderBy = plan['orderBy'] as Map<String, dynamic>?;
    final limit = plan['limit'] ?? 10;

    // --- SELECT ---
    String selectClause = "*";

    if (displayFields != null && displayFields.isNotEmpty) {
      List<String> cols = [];
      for (var f in displayFields) {
        if (f is Map && f['column'] != null) {
          String col = f['column'];
          if (RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(col)) {
            cols.add("\"$col\"");
          }
        }
      }
      if (cols.isNotEmpty) selectClause = cols.join(", ");
    }

    String query = "SELECT $selectClause FROM \"$tableName\" WHERE 1=1";

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

      // --- AND ---
      query += " AND \"$column\" $operator $valSql";
    }

    // --- ORDER BY ---
    if (orderBy != null && orderBy['column'] != null) {
      final orderCol = orderBy['column'];
      final direction = (orderBy['direction'] == 'DESC') ? 'DESC' : 'ASC';

      if (RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(orderCol)) {
        // Trükk: Mivel az 'amount' nálunk most String ("1500 EUR"),
        // SQL szinten nem tudunk rá jól rendezni castolás nélkül.
        // Éles rendszerben ez NUMERIC lenne. Most egyszerűen szövegként rendezünk.
        query += " ORDER BY \"$orderCol\" $direction";
      }
    }
    // --- LIMIT ---
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
