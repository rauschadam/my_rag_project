import 'package:serverpod/serverpod.dart';
import 'package:my_rag_project_server/src/business/search.dart';
import 'package:my_rag_project_server/src/generative_ai/generative_ai.dart';

class RagEndpoint extends Endpoint {
  /// Ezt hívja a kliens, hogy kérdezzen.
  /// Stream-et ad vissza, így a válasz "szavanként" érkezik meg (mint a ChatGPT-nél).
  Stream<String> ask(Session session, String question) async* {
    final genAi = GenerativeAi();

    // 1. Megkeressük a releváns tudást
    final documents = await searchDocuments(session, question);

    // 2. Generálunk egy választ a dokumentumok alapján
    final answerStream = genAi.generateConversationalAnswer(
      question: question,
      systemPrompt:
          'You are a helpful AI assistant. Use the provided documents to answer the user question accurately.',
      documents: documents,
      conversation: [], // Később ide köthetjük be a chat előzményeket
    );

    // 3. Visszaküldjük a választ darabokban
    await for (var chunk in answerStream) {
      yield chunk;
    }
  }
}
