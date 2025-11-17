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

  /// The main chat method which now:
  /// 1. Loads the conversation history.
  /// 2. Saves messages to the database.
  /// 3. Generates an answer using context.
  Stream<String> ask(
      Session session, int chatSessionId, String question) async* {
    final genAi = GenerativeAi();

    // 1. Verify that the session exists
    final chatSession = await ChatSession.db.findById(session, chatSessionId);
    if (chatSession == null) {
      throw Exception('Chat session not found (ID: $chatSessionId)');
    }

    // 2. Load previous messages (Memory)
    final history = await ChatMessage.db.find(
      session,
      where: (t) => t.chatSessionId.equals(chatSessionId),
      orderBy: (t) => t.createdAt,
    );

    // 3. Search for relevant knowledge/documents in the vector DB
    final documents = await searchDocuments(session, question);

    // 4. Save the USER'S question to the database
    await ChatMessage.db.insertRow(
      session,
      ChatMessage(
        chatSessionId: chatSessionId,
        message: question,
        type: ChatMessageType.user,
        createdAt: DateTime.now(),
      ),
    );

    // 5. Generate the answer (passing the 'history' for context!)
    final answerStream = genAi.generateConversationalAnswer(
      question: question,
      systemPrompt:
          'You are a helpful AI assistant. Answer based on the context and documents provided.',
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
