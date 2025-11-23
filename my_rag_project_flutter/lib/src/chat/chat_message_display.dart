/// Helper class to store message data for the UI
class ChatMessageDisplay {
  final String text;
  final bool isUser;
  final bool isError;

  ChatMessageDisplay(
      {required this.text, required this.isUser, this.isError = false});
}
