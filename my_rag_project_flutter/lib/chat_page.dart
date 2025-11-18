import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:my_rag_project_flutter/chat_message_display.dart';
import 'package:my_rag_project_flutter/main.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // List to store chat messages for display
  final List<ChatMessageDisplay> _messages = [];

  // Controller for the input field
  final TextEditingController _inputTextController = TextEditingController();

  // Controller for scrolling the chat view
  final ScrollController _scrollController = ScrollController();

  // Decides between Document and ListPanel search
  bool _searchDataBase = false;

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
    final text = _inputTextController.text.trim();
    // Do nothing if text is empty or session isn't ready
    if (text.isEmpty || _currentSessionId == null) return;

    setState(() {
      // Add user message to the list
      _messages.add(ChatMessageDisplay(text: text, isUser: true));
      _isLoading = true;
      _inputTextController.clear();

      // Add a placeholder message for the AI response
      _messages.add(ChatMessageDisplay(text: "", isUser: false));
    });

    // Scroll to the bottom to show the new message
    _scrollToBottom();

    try {
      // Call the RAG endpoint on the server (returns a Stream)
      final stream = client.rag.ask(_currentSessionId!, text, _searchDataBase);

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SWS AI Chat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            // Kiírjuk, épp melyik módban vagyunk
            Text(
              _searchDataBase ? 'Mód: Adatbázis (SQL)' : 'Mód: Dokumentumok',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: "Adatok importálása (Egyszeri)",
            onPressed: () async {
              try {
                // Ez hívja meg a szerveren a SchemaImporter-t
                await client.rag.triggerSchemaImport();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Sikeres importálás! Mehet a kérdés.')),
                );
              } catch (e) {
                print("Import hiba: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hiba: $e')),
                );
              }
            },
          ),
          Switch(
            value: _searchDataBase,
            onChanged: (value) {
              setState(() {
                _searchDataBase = value;
              });
              // Opcionális: új sessiont indíthatunk váltáskor,
              // hogy ne keveredjen a kontextus, de nem kötelező.
            },
            activeThumbColor: Colors.green,
          ),
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

          // User Input Box
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left: Text Field
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        controller: _inputTextController,
                        minLines: 1,
                        maxLines: 5, // multiple lines in input
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Írj egy üzenetet...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Colors.grey.shade100,
                          filled: true,
                        ),
                      ),
                    ),
                  ),

                  // Right: Send Button
                  Container(
                    margin: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: (_isLoading || _currentSessionId == null)
                          ? null
                          : _sendMessage,
                      icon: const Icon(Icons.send_rounded, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
