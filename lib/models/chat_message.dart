class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime? timestamp;
  final bool isTyping;
  final String? id;

  const ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
    this.id,
  });
}