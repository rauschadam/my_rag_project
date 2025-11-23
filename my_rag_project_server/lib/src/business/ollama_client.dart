import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

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
      final prompt = '''
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
Te egy segítőkész, udvarias és precíz magyar üzleti asszisztens vagy.
A feladatod: Az alább megadott ADATBÁZIS EREDMÉNYEK alapján válaszolj a felhasználó kérdésére.
Fogalmazz természetes, kerek mondatokban magyarul. A válaszod legyen lényegre törő.
Ne használj technikai kifejezéseket (pl. "JSON", "array"), hanem úgy beszélj, mint egy elemző.
Használj Markdown formázást (félkövér, felsorolás) az áttekinthetőségért.

<|eot_id|><|start_header_id|>user<|end_header_id|>
FELHASZNÁLÓ KÉRDÉSE: "$userQuestion"

ADATBÁZIS EREDMÉNYEK (Ezek a tények, amiből dolgoznod kell):
$rawDataContext

<|eot_id|><|start_header_id|>assistant<|end_header_id|>
''';

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
