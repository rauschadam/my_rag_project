import 'package:my_rag_project_client/my_rag_project_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

late SessionManager sessionManager;
late Client client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kliens beállítása
  client = Client(
    'http://$localhost:8080/',
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  )..connectivityMonitor = FlutterConnectivityMonitor();

  sessionManager = SessionManager(
    caller: client.modules.auth,
  );
  await sessionManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAG Tanító',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const KnowledgeInputPage(),
    );
  }
}

class KnowledgeInputPage extends StatefulWidget {
  const KnowledgeInputPage({super.key});

  @override
  State<KnowledgeInputPage> createState() => _KnowledgeInputPageState();
}

class _KnowledgeInputPageState extends State<KnowledgeInputPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  String? _statusMessage;

  // Ez a függvény küldi el az adatot a szervernek
  Future<void> _uploadKnowledge() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      setState(() {
        _statusMessage = 'Kérlek tölts ki minden mezőt!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Feldolgozás és tanulás folyamatban...';
    });

    try {
      // HÍVJUK A VÉGPONTOT
      // Ez a függvény a szerveren fut le:
      // 1. Összefoglal, 2. Vektort generál, 3. Ment az adatbázisba.
      await client.knowledge
          .addArticle(_titleController.text, _contentController.text);

      setState(() {
        _statusMessage = 'Siker! Az AI megtanulta az anyagot.';
        _titleController.clear();
        _contentController.clear();
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Hiba történt: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tudásbázis Feltöltés')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Cím (pl. Serverpod Dokumentáció)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Tartalom (Ide másold a szöveget)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10, // Nagyobb hely a szövegnek
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                onPressed: _uploadKnowledge,
                icon: const Icon(Icons.upload_file),
                label: const Text('Tanítsd meg az AI-nak!'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            const SizedBox(height: 16),
            if (_statusMessage != null)
              Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusMessage!.startsWith('Hiba') ||
                          _statusMessage!.startsWith('Kérlek')
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
