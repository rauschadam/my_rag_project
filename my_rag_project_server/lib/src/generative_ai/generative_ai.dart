import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:serverpod/serverpod.dart';
import 'package:my_rag_project_server/src/generated/protocol.dart';

/// The Gemini model name used for text generation.
const String _geminiModelName = 'gemini-1.5-flash';

/// The Gemini model name used for generating embeddings.
const String _geminiEmbeddingModelName = 'text-embedding-004';

/// Handles interactions with the Generative AI (Gemini) via Dartantic.
class GenerativeAi {
  final String _geminiAPIKey;

  GenerativeAi()
      : _geminiAPIKey = Serverpod.instance.getPassword('geminiAPIKey')!;

  /// Streams a conversational answer based on the question, system prompt,
  /// retrieved RAG documents, and conversation history.
  Stream<String> generateConversationalAnswer({
    required String question,
    required String systemPrompt,
    List<RAGDocument> documents = const [],
    List<ChatMessage> conversation = const [],
  }) async* {
    final messages = <Message>[];

    // Add conversation history to context
    for (final chatMessage in conversation) {
      messages.add(
        Message(
          role: chatMessage.type == ChatMessageType.user
              ? MessageRole.user
              : MessageRole.model,
          // Using 'parts' with TextPart is the correct syntax for this version
          parts: [TextPart(chatMessage.message)],
        ),
      );
    }

    // Create the agent and append the formatted RAG documents to the system prompt
    final agentWithSystem = _createAgent(
      systemPrompt:
          '$systemPrompt\n\n${documents.map((e) => _formatDocument(e)).join('\n')}',
    );

    try {
      final response = agentWithSystem.runStream(question, messages: messages);
      await for (final chunk in response) {
        yield chunk.output;
      }
    } catch (e) {
      print('Generation error: $e');
      throw Exception('Failed to generate answer: $e');
    }
  }

  /// Generates a vector embedding for a given text document.
  Future<Vector> generateEmbedding(String document) async {
    final agent = _createAgent();
    try {
      final embedding = await agent.createEmbedding(
        document,
        dimensions: 1536,
      );
      return Vector(embedding.toList());
    } catch (e) {
      print('Embedding error: $e');
      throw Exception('Failed to generate embedding: $e');
    }
  }

  /// Generates a simple, non-streaming answer for a single question.
  /// Useful for summarization tasks.
  Future<String> generateSimpleAnswer(String question) async {
    final agent = _createAgent();
    try {
      final response = await agent.run(question);
      return response.output;
    } catch (e) {
      throw Exception('AI error: $e');
    }
  }

  /// Formats a RAG document into an XML-like structure to help the LLM distinguish it.
  String _formatDocument(RAGDocument document) {
    return '<doc href="${document.sourceUrl}" title="${document.title}">\n${document.content}\n</doc>';
  }

  /// Creates and configures the Dartantic Agent with the Gemini provider.
  Agent _createAgent({
    String? systemPrompt,
  }) {
    return Agent.provider(
      GeminiProvider(
        apiKey: _geminiAPIKey,
        modelName: _geminiModelName,
        embeddingModelName: _geminiEmbeddingModelName,
      ),
      systemPrompt: systemPrompt,
    );
  }
}
