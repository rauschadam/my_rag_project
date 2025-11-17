import 'package:serverpod/serverpod.dart';
import 'package:my_rag_project_server/src/business/data_fetcher.dart';

class KnowledgeEndpoint extends Endpoint {
  /// Adds a new article / text to the knowledge base.
  /// This can be called from the Flutter app.
  Future<void> addArticle(Session session, String title, String content) async {
    // We generate a unique fake URL for now based on time
    final url =
        'https://knowledge-base/${DateTime.now().millisecondsSinceEpoch}';

    await DataFetcher.addTextDocument(
      session: session,
      title: title,
      content: content,
      sourceUrl: url,
    );
  }
}
