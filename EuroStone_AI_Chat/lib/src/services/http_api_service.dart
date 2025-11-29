import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpApiService {
  // Use 10.0.2.2 for Android emulator to access localhost
  // Use localhost for Windows/Web
  // For physical device, use your local IP address
  static const String _baseUrl = 'http://localhost:5119';

  Future<int> createSession() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/Rag/createSession'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception('Failed to create session: ${response.statusCode}');
    }
  }

  Stream<Map<String, dynamic>> ask({
    required int chatSessionId,
    required String question,
    required bool searchListPanels,
  }) async* {
    final request = http.Request('POST', Uri.parse('$_baseUrl/Rag/ask'));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'chatSessionId': chatSessionId,
      'question': question,
      'searchListPanels': searchListPanels,
    });

    final client = http.Client();
    try {
      final response = await client.send(request);

      if (response.statusCode == 200) {
        final stream = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in stream) {
          if (line.trim().isNotEmpty) {
            try {
              final data = jsonDecode(line);
              yield data;
            } catch (e) {
              print("Error decoding JSON line: $e");
            }
          }
        }
      } else {
        throw Exception('Failed to get answer: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  Future<void> triggerSchemaImport() async {
    // This endpoint might not be implemented in C# yet, or is just a placeholder
    // For now, we can just return or throw not implemented
    // throw UnimplementedError("Schema import not implemented in C# backend yet");
    return;
  }
}
