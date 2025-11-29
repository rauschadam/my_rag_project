import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:eurostone_ai_chat/src/chat/chat_message_display.dart';

import 'package:eurostone_ai_chat/src/chat/search_mode.dart';
import 'package:eurostone_ai_chat/src/services/speech_manager.dart';
import 'package:eurostone_ai_chat/src/services/http_api_service.dart';

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

  /// Decides between Document and ListPanel (SQL) search logic
  SearchMode _searchMode = SearchMode.sql;

  /// Handles the speech-to-text functionality
  final SpeechManager _speechManager = SpeechManager();

  /// API Service for communicating with the C# backend
  final HttpApiService _apiService = HttpApiService();

  /// The words recognized from the user's speech
  String _wordsSpoken = "";

  /// Loading state for server requests
  bool _isLoading = false;

  /// Current RAG session ID
  int? _currentSessionId;

  @override
  void initState() {
    super.initState();
    // Start a new chat session when the page loads
    _startNewSession();
    _initSpeech();
  }

  /// Initialize the speech-to-text service
  void _initSpeech() async {
    await _speechManager.init(
      onError: (errorMsg) => debugPrint("Initialization error: $errorMsg"),
    );
    if (mounted) setState(() {});
  }

  /// Starts listening to the user's speech
  void _startListening() async {
    // 1. Check if we have permission to use the mic or if service is available
    if (!_speechManager.isEnabled) {
      await _speechManager.init(
        onError: (error) => debugPrint('Microphone error: $error'),
      );
      if (mounted) setState(() {});
    }

    // 2. If permission is still missing, notify the user via SnackBar (in Hungarian)
    if (!_speechManager.isEnabled) {
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

    // 3. If we have permission, start listening
    await _speechManager.startListening(
      onResult: (text) {
        setState(() {
          _wordsSpoken = text;
          _inputTextController.text = _wordsSpoken;
          _inputTextController.selection = TextSelection.fromPosition(
              TextPosition(offset: _inputTextController.text.length));
        });
      },
      onListeningStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  /// Manually stop listening
  void _stopListening() async {
    await _speechManager.stopListening(
      onListeningStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  /// Request a new session ID from the server
  Future<void> _startNewSession() async {
    try {
      final sessionId = await _apiService.createSession();
      setState(() {
        _currentSessionId = sessionId;
      });
    } catch (e) {
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
      _messages.add(ChatMessageDisplay(text: "...", isUser: false));
    });

    // Scroll to the bottom to show the new message
    _scrollToBottom();

    try {
      // Determine search mode logic (Database/SQL vs Documents)
      bool searchDataBase = _searchMode == SearchMode.sql;

      // Subscribe to the stream
      final stream = _apiService.ask(
        chatSessionId: _currentSessionId!,
        question: text,
        searchListPanels: searchDataBase,
      );

      await for (final data in stream) {
        final type = data['type'];
        final content = data['content'];

        if (type == 'status') {
          setState(() {
            _messages.last = ChatMessageDisplay(
              text: "_${content}_",
              isUser: false,
            );
          });
        } else if (type == 'result') {
          setState(() {
            _messages.last = ChatMessageDisplay(
              text: content,
              isUser: false,
            );
          });
        } else if (type == 'error') {
          setState(() {
            _messages.last = ChatMessageDisplay(
              text: "⚠️ Hiba: $content",
              isUser: false,
              isError: true,
            );
          });
        }

        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.last = ChatMessageDisplay(
            text: "Hiba történt: $e", isUser: false, isError: true);
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
              'Eurostone AI Chat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            // Display current active mode in Hungarian
            Text(
              _searchMode == SearchMode.sql
                  ? 'Mód: Adatbázis (SQL)'
                  : 'Mód: Dokumentumok',
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
                // Triggers SchemaImporter on the server
                await _apiService.triggerSchemaImport();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Sikeres importálás! Mehet a kérdés.')),
                );
              } catch (e) {
                debugPrint("Import error: $e");
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hiba: $e')),
                );
              }
            },
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

                    // Using MarkdownBody to render bold text, code blocks, lists, etc.
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
                  // User input field row
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

                  // Bottom Row (Controls)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildModeButton(),
                        // Mic button with glow effect
                        GestureDetector(
                          onLongPress: _startListening,
                          onLongPressUp: _stopListening,
                          child: _speechManager.isListening
                              ? AvatarGlow(
                                  animate: _speechManager.isListening,
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
            _speechManager.isListening ? 'Hallgatom...' : 'Írj üzenetet...',
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
          _speechManager.isListening ? Colors.blue : Colors.grey.shade200,
      foregroundColor:
          _speechManager.isListening ? Colors.white : Colors.black87,
      onPressed: _speechManager.isListening ? _stopListening : _startListening,
      child: Icon(
        _speechManager.isListening ? Icons.mic_off : Icons.mic,
        size: 20,
      ),
    );
  }

  void _showModeSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  "Válassz keresési módot",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // 1. Option: Documents
                _buildModeOption(
                  icon: Icons.description_outlined,
                  title: "Dokumentumok",
                  subtitle: "Keresés a feltöltött fájlokban",
                  isSelected: _searchMode == SearchMode.documents,
                  onTap: () {
                    setState(() {
                      _searchMode = SearchMode.documents;
                    });
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 8),

                // 2. Option: DataBase
                _buildModeOption(
                  icon: Icons.storage_outlined,
                  title: "Adatbázis (SQL)",
                  subtitle: "Lekérdezés az SQL táblákból",
                  isSelected: _searchMode == SearchMode.sql,
                  onTap: () {
                    setState(() {
                      _searchMode = SearchMode.sql;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor.withAlpha(25) : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: FloatingActionButton.small(
        shape: const CircleBorder(side: BorderSide.none),
        elevation: 0,
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.black87,
        onPressed: _showModeSelectionSheet,
        child: Icon(
          _searchMode == SearchMode.sql ? Icons.storage : Icons.description,
          size: 20,
        ),
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
