import 'package:my_rag_project_client/my_rag_project_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

late SessionManager sessionManager;
late Client client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Client with the server URL and authentication key manager
  client = Client(
    'http://$localhost:8080/',
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  )
    // Checks the internet connection at all times
    ..connectivityMonitor = FlutterConnectivityMonitor();

  // Initialize SessionManager to handle user sessions and authentication state
  sessionManager = SessionManager(caller: client.modules.auth);
  await sessionManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAG AI Chat',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // List to store chat messages for display
  final List<ChatMessageDisplay> _messages = [];

  // Controller for the input field
  final TextEditingController _controller = TextEditingController();

  // Controller for scrolling the chat view
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  int? _currentSessionId;

  @override
  void initState() {
    super.initState();
    // Start a new chat session when the page loads
    _startNewSession();
  }

  /// Request a new session ID from the server
  Future<void> _startNewSession() async {
    try {
      final session = await client.rag.createSession();
      setState(() {
        _currentSessionId = session.id;
      });
    }
    // error..
    catch (e) {
      print("Error starting session: $e");
    }
  }

  /// Send the user's message to the server and handle the streaming response
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    // Do nothing if text is empty or session isn't ready
    if (text.isEmpty || _currentSessionId == null) return;

    setState(() {
      // Add user message to the list
      _messages.add(ChatMessageDisplay(text: text, isUser: true));
      _isLoading = true;
      _controller.clear();

      // Add a placeholder message for the AI response
      _messages.add(ChatMessageDisplay(text: "", isUser: false));
    });

    // Scroll to the bottom to show the new message
    _scrollToBottom();

    try {
      // Call the RAG endpoint on the server (returns a Stream)
      final stream = client.rag.ask(_currentSessionId!, text);

      // Process the stream chunks as they arrive
      await for (final chunk in stream) {
        setState(() {
          final lastMsg = _messages.last;
          // Append the new chunk to the last message (the AI's message)
          _messages.last = ChatMessageDisplay(
            text: lastMsg.text + chunk,
            isUser: false,
          );
        });
        // Scroll to bottom on every new chunk to follow the text generation
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.last =
            ChatMessageDisplay(text: "Error: $e", isUser: false, isError: true);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Helper to scroll the list view to the very bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart RAG Chat 🧠'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Clear history and start a new session
              _messages.clear();
              _startNewSession();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Chat history area
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Attach the scroll controller
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isError
                          ? Colors.red[100]
                          : (msg.isUser ? Colors.blue[100] : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Limit width for better UI appearance
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8),

                    // HERE IS THE MAGIC: Using MarkdownBody instead of Text!
                    // This renders bold text, code blocks, lists, etc.
                    child: MarkdownBody(
                      data: msg.text,
                      selectable: true, // Text is selectable
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: 16,
                          color: msg.isError ? Colors.red : Colors.black87,
                        ),
                        code: const TextStyle(
                          backgroundColor: Colors.black12,
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading indicator
          if (_isLoading) const LinearProgressIndicator(),

          // Input area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type something...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: (_isLoading || _currentSessionId == null)
                      ? null
                      : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class to store message data for the UI
class ChatMessageDisplay {
  final String text;
  final bool isUser;
  final bool isError;

  ChatMessageDisplay(
      {required this.text, required this.isUser, this.isError = false});
}
