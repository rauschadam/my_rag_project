import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:my_rag_project_flutter/chat_message_display.dart';
import 'package:my_rag_project_flutter/main.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  /// List to store chat messages for display
  final List<ChatMessageDisplay> _messages = [];

  /// Controller for the input field
  final TextEditingController _inputTextController = TextEditingController();

  /// Controller for scrolling the chat view
  final ScrollController _scrollController = ScrollController();

  /// Decides between Document and ListPanel search
  bool _searchDataBase = false;

  /// Works with the users speech message
  final SpeechToText _speechToText = SpeechToText();

  /// Decides if it should listen to the users speech
  bool _speechEnabled = false;

  /// The words created from the users speech
  String _wordsSpoken = "";

  bool _isLoading = false;
  int? _currentSessionId;

  @override
  void initState() {
    super.initState();
    // Start a new chat session when the page loads
    _startNewSession();
    _initSpeech();
  }

  /// Initialize the speech to text, if the permission is granted
  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (e) => debugPrint("Inicializálási hiba: $e"),
      );
    }
    // On error we set the permission to denied
    catch (e) {
      _speechEnabled = false;
    }
    // Updates the UI
    if (mounted) setState(() {});
  }

  /// Starts listening to the users speech
  void _startListening() async {
    // 1. Check if we have permission to use the mic
    if (!_speechEnabled || !_speechToText.isAvailable) {
      try {
        _speechEnabled = await _speechToText.initialize(
          onError: (error) => debugPrint('Mikrofon hiba: $error'),
          onStatus: (status) => debugPrint('Mikrofon státusz: $status'),
        );
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint("Inicializálási hiba: $e");
      }
    }

    // 2. If we still dont have permission then, we tell the user to give permission in the phones settings
    if (!_speechEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'A mikrofonhoz nincs hozzáférés. Kérlek, engedélyezd a beállításokban!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 3. If we have permission, then we listen on the mic
    await _speechToText.listen(
      onResult: _onSpeechResult,
      pauseFor: const Duration(seconds: 3),
      localeId: "hu_HU",
    );
  }

  /// Manually stop listening
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    // Updates the UI
    setState(() {
      _wordsSpoken = result.recognizedWords;
      // Put the words spoken into the input field
      _inputTextController.text = _wordsSpoken;
      // Put the cursor at the end of the words inputted
      _inputTextController.selection = TextSelection.fromPosition(
          TextPosition(offset: _inputTextController.text.length));
    });
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
      debugPrint("Error starting session: $e");
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
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Sikeres importálás! Mehet a kérdés.')),
                );
              } catch (e) {
                debugPrint("Import hiba: $e");
                if (!context.mounted) return;
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

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User input field
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _buildInputField(),
                      ),
                      const SizedBox(width: 8),
                      // Send button
                      _buildSendButton(),
                    ],
                  ),

                  // Bottom Row
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Mic button
                        GestureDetector(
                          onLongPress: _startListening,
                          onLongPressUp: _stopListening,
                          child: _speechToText.isListening
                              ? AvatarGlow(
                                  animate: _speechToText.isListening,
                                  glowColor: Colors.blue,
                                  repeat: true,
                                  duration: const Duration(milliseconds: 1500),
                                  glowRadiusFactor: 0.4,
                                  child: _buildMicButton(),
                                )
                              : _buildMicButton(),
                        ),
                      ],
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

  Widget _buildInputField() {
    return TextField(
      controller: _inputTextController,
      minLines: 1,
      maxLines: 6,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => _sendMessage(),
      decoration: InputDecoration(
        hintText:
            _speechToText.isListening ? 'Hallgatom...' : 'Írj üzenetet...',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
      ),
    );
  }

  Widget _buildMicButton() {
    return FloatingActionButton.small(
      shape: const CircleBorder(side: BorderSide.none),
      elevation: 0,
      backgroundColor:
          _speechToText.isListening ? Colors.blue : Colors.grey.shade200,
      foregroundColor:
          _speechToText.isListening ? Colors.white : Colors.black87,
      onPressed: _speechToText.isListening ? _stopListening : _startListening,
      child: Icon(
        _speechToText.isListening ? Icons.mic_off : Icons.mic,
        size: 20,
      ),
    );
  }

  Widget _buildSendButton() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: (_isLoading || _currentSessionId == null)
          ? Colors.grey.shade300
          : Theme.of(context).colorScheme.primary,
      child: IconButton(
        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
        onPressed:
            (_isLoading || _currentSessionId == null) ? null : _sendMessage,
      ),
    );
  }
}
