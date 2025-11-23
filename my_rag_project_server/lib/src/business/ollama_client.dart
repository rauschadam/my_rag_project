import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:my_rag_project_server/src/config/prompts.dart';

class OllamaClient {
  // Ha a 'dart run' a host gépen fut (fejlesztés), akkor localhost.
  // Ha a szerver is Dockerben futna élesben, akkor 'http://ollama:11434/api/generate' lenne.
  static const String _baseUrl = 'http://localhost:11434/api/generate';

  /// Elküldi a nyers adatokat és a kérdést az Ollama-nak, hogy fogalmazza meg szépen.
  /// Send the raw data and users question to the Ollama to phrase it nicely
  static Future<String> generateRefinedResponse(
      Session session, String rawDataContext, String userQuestion) async {
    try {
      // Instructions for the AI
      // Instructions for the AI
      final prompt = Prompts.getOllamaPrompt(userQuestion, rawDataContext);

      // Hívás az Ollama API-hoz
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'llama3.2', // Name of the model
          'prompt': prompt,
          'stream': false, // We get the answer at one time, not simultaneously
          'options': {
            'temperature': 0.7, // Creativity
            'num_ctx': 4096 // Memory size
          }
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final aiText = jsonResponse['response']?.toString().trim();

        if (aiText != null && aiText.isNotEmpty) {
          return aiText;
        } else {
          return "Az AI üres választ küldött.";
        }
      } else {
        session.log("Ollama Error: ${response.statusCode} - ${response.body}",
            level: LogLevel.error);
        return "Hiba történt a válasz generálásakor (AI hiba).";
      }
    } catch (e) {
      session.log("Ollama Connection Failed: $e", level: LogLevel.error);
      return "Nem érem el a helyi AI motort. (Kérlek ellenőrizd, hogy fut-e az Ollama!)";
    }
  }
}
