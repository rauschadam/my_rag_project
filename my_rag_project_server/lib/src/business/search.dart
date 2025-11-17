import 'package:serverpod/serverpod.dart';
import 'package:my_rag_project_server/src/generated/protocol.dart';
import 'package:my_rag_project_server/src/generative_ai/generative_ai.dart';

/// Megkeresi a kérdéshez leginkább hasonlító dokumentumokat az adatbázisban.
Future<List<RAGDocument>> searchDocuments(
  Session session,
  String question,
) async {
  final genAi = GenerativeAi();

  // 1. A kérdésből is vektort (embedding) készítünk
  final embedding = await genAi.generateEmbedding(question);

  // 2. Megkeressük az 5 legközelebbi vektort az adatbázisban
  // A 'distanceCosine' a vektorok közötti hasonlóságot méri.
  final documents = await RAGDocument.db.find(
    session,
    orderBy: (rag) => rag.embedding.distanceCosine(embedding),
    limit: 5,
  );

  return documents;
}
