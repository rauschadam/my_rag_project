import 'package:serverpod/serverpod.dart';
import 'package:my_rag_project_server/src/generated/protocol.dart';
import 'package:my_rag_project_server/src/generative_ai/generative_ai.dart';

class DataFetcher {
  /// Processes a text document: summarizes it, creates an embedding, and saves it to the DB.
  static Future<void> addTextDocument({
    required Session session,
    required String title,
    required String content,
    required String sourceUrl,
  }) async {
    // Instantiate our AI helper
    final genAi = GenerativeAi();

    session.log('Processing document: $title');

    // 1. Generate a summary optimized for retrieval (Embedding Summary)
    // This helps the search be more accurate than just using raw text.
    var embeddingSummary = await genAi.generateSimpleAnswer(
        'Summarize the following text in a concise way optimized for retrieval and embedding search. Text:\n$content');

    // 2. Generate the vector embedding from the summary
    final embedding = await genAi.generateEmbedding(embeddingSummary);

    // 3. Create the database object
    final ragDocument = RAGDocument(
      title: title,
      sourceUrl: Uri.parse(sourceUrl),
      fetchTime: DateTime.now(),
      content: content,
      embeddingSummary: embeddingSummary,
      shortDescription:
          embeddingSummary, // Using summary for description too for simplicity
      embedding: embedding,
      type: RAGDocumentType.documentation,
    );

    // 4. Save to database
    // First, check if it already exists to avoid duplicates (based on URL)
    final existing = await RAGDocument.db.findFirstRow(
      session,
      where: (t) => t.sourceUrl.equals(Uri.parse(sourceUrl)),
    );

    if (existing != null) {
      ragDocument.id = existing.id;
      await RAGDocument.db.updateRow(session, ragDocument);
      session.log('Document updated: $sourceUrl');
    } else {
      await RAGDocument.db.insertRow(session, ragDocument);
      session.log('New document saved: $sourceUrl');
    }
  }
}
