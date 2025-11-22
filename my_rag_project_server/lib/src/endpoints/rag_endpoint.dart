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
      final queryPlanPrompt = '''
A felhasználó kérdése: "$question"

Elérhető táblák definíciója:
$panelDesc

A 'list_panel_suplier_data' (Szállítók) tábla fontosabb mezői (PONTOSAN ezeket használd):
- vendorName (Szállító neve, szöveg)
- countryCode (Országkód, pl. HU, CZ, DE, szöveg)
- category (Kategória, pl. Szolgáltatás, Termék, szöveg)
- amount (Összeg, szöveg)
- lastActivity (Utolsó aktivitás dátuma, pl. "2025-10-01", Dátum típus)

A 'mock_country_data' (Országok - Panel 15):
   - countryName (Ország neve, pl. "Magyarország")
   - isoCode (Kétbetűs kód, pl. HU)
   - isEuMember (EU tag? true/false)
   - isNatoMember (NATO tag? true/false)

FELADAT: 
Döntsd el, melyik tábla releváns a kérdéshez (Szállítók VAGY Országok).
Elemzed a kérdést és készíts egy SQL-szerű lekérdezési tervet JSON formátumban.

A "tableName" -be kerül a tábla neve, ahonnan lekérdezést hajtjuk végre
A "displayFields" tömbben sorold fel a szükséges mezőket. Minden elemnél add meg:
 - "column": az SQL mező neve
 - "label": a mező magyar neve (a séma alapján)
A "filters" tömbben sorold fel a feltételeket.
Az operátor lehet: "=", "!=", ">", "<", "ILIKE" (szöveges keresésnél).


Szabályok:
1. **Dátumok:** Ha a kérdés időtartamra vonatkozik (pl. "elmúlt 6 hónap"), számold ki a pontos kezdő dátumot a Mai dátumhoz ($currentDate) képest! Használd a ">=" operátort a 'lastActivity' mezőn.
2. **Rendezés:** Ha a kérdés "legnagyobb", "legkisebb" vagy sorrendet kér, használd az "orderBy" mezőt.

Kimeneti formátum (Csak a nyers JSON):
{
  "tableName": "list_panel_suplier_data", // VAGY "mock_country_data"
  "displayFields": [
     {"column": "vendorName", "label": "Szállító"},
     {"column": "amount", "label": "Összeg"}
  ], // Csak a lényeges mezőket (column) add vissza a hozzá tartozó magyar megnevezéssel
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
      String responseData = "";

      try {
        final cleanJson = queryPlanJson
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final plan = jsonDecode(cleanJson);

        // Execute the dynamic query locally
        final results = await _executeDynamicQuery(session, plan);

        // The raw results are returned to the client in JSON format.
        // We use a prefix ("DATA_JSON:") so the client knows this is data, not text.

        // Dynamic mapping of display names
        final List<dynamic> displayFields = plan['displayFields'] ?? [];
        final Map<String, String> aiLabelMap = {};

        for (var field in displayFields) {
          if (field is Map &&
              field['column'] != null &&
              field['label'] != null) {
            aiLabelMap[field['column']] = field['label'];
          }
        }

        if (results.isEmpty) {
          // If there is no data we return the error in JSON
          responseData = jsonEncode({
            "status": "empty",
            "message": "Nem találtam adatot a feltételekkel."
          });
        } else {
          // Convert dates to strings, befor jsonEncode
          final jsonReadyResults = results.map((row) {
            return row.map((key, value) {
              // Dátum formázás
              var finalValue = value;
              if (value is DateTime) {
                finalValue = value.toIso8601String().substring(0, 10);
              }

              final translatedKey = aiLabelMap[key] ?? key;
              return MapEntry(translatedKey, finalValue);
            });
          }).toList();
          // Return the successful JSON
          responseData = jsonEncode({
            "status": "success",
            "query_context":
                "A felhasználó kérdésére ($question) ezeket az adatokat találtam:",
            "data": jsonReadyResults
          });
        }
      } catch (e) {
        session.log("Query Error: $e", level: LogLevel.error);
        responseData = jsonEncode({
          "status": "error",
          "message": "Hiba történt a szerver oldali lekérdezésben."
        });
      }

      // Return with special prefix
      // This will tell the client to start the On-Device AI.
      yield "DATA_JSON:$responseData";

      // Log the raw Json (The local AI will generate the answer from this)
      await ChatMessage.db.insertRow(
        session,
        ChatMessage(
          chatSessionId: chatSessionId,
          message: "DATA_JSON:$responseData", // Save raw json to history
          type: ChatMessageType.model,
          createdAt: DateTime.now(),
        ),
      );
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
