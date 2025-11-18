import 'package:serverpod/serverpod.dart';
import 'package:my_rag_project_server/src/generated/protocol.dart';
import 'package:my_rag_project_server/src/generative_ai/generative_ai.dart';

/// Searches for the most relevant documents in the database matching the user's question.
Future<List<RAGDocument>> searchDocuments(
  Session session,
  String question,
) async {
  final genAi = GenerativeAi();

  // 1. Convert the question into a vector embedding.
  // This allows us to compare the semantic meaning of the question with the documents.
  final embedding = await genAi.generateEmbedding(question);

  // 2. Retrieve the top 5 closest vectors from the database.
  // We use 'distanceCosine' to measure the similarity between the question embedding
  // and the stored document embeddings. The lower the distance, the more similar they are.
  final documents = await RAGDocument.db.find(
    session,
    orderBy: (rag) => rag.embedding.distanceCosine(embedding),
    limit: 5,
  );

  return documents;
}

/// Searches for relevant ListPanels in the DataBase
/// This what is used, if the question refers to database structures (listing things)
Future<List<ListPanelTableDescription>> findRelevantListPanels(
  Session session,
  String question,
) async {
  final genAi = GenerativeAi();

  // 1. Convert the question into a vector embedding.
  // This allows us to compare the semantic meaning of the question with the ListPanel descriptions.
  final embedding = await genAi.generateEmbedding(question);

  // 2. Retrieve the top 3 closest vectors from the database.
  // We use 'distanceCosine' to measure the similarity between the question embedding
  // and the stored document embeddings. The lower the distance, the more similar they are.
  final panels = await ListPanelTableDescription.db.find(
    session,
    orderBy: (t) => t.embedding.distanceCosine(embedding),
    limit: 3,
  );

  return panels;
}
