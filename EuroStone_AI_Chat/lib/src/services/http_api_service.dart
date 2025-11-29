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

  Future<String> ask({
    required int chatSessionId,
    required String question,
    required bool searchListPanels,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/Rag/ask'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'chatSessionId': chatSessionId,
        'question': question,
        'searchListPanels': searchListPanels,
      }),
    );

    if (response.statusCode == 200) {
      return response
          .body; // The API returns plain text (or JSON string) directly
    } else {
      throw Exception('Failed to get answer: ${response.statusCode}');
    }
  }

  Future<void> triggerSchemaImport() async {
    // This endpoint might not be implemented in C# yet, or is just a placeholder
    // For now, we can just return or throw not implemented
    // throw UnimplementedError("Schema import not implemented in C# backend yet");
    return;
  }
}
