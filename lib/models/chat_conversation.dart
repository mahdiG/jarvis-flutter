class ChatConversation {
  final String id;
  final String title;
  final String previewText;
  final DateTime lastMessageAt;
  final int messageCount;
  final bool isPinned;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.previewText,
    required this.lastMessageAt,
    this.messageCount = 0,
    this.isPinned = false,
  });

  /// Returns a human-readable time group label.
  String get timeGroup {
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (now.day == lastMessageAt.day &&
        now.month == lastMessageAt.month &&
        now.year == lastMessageAt.year) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.day == lastMessageAt.day &&
        yesterday.month == lastMessageAt.month &&
        yesterday.year == lastMessageAt.year) {
      return 'Yesterday';
    }
    if (diff.inDays < 7) return 'This week';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    return 'Older';
  }

  /// Returns a time-group section key for grouping conversations.
  String get sectionKey {
    if (timeGroup == 'Today' || timeGroup == 'Yesterday') return timeGroup;
    if (timeGroup == 'This week') return 'This week';
    return 'Older';
  }

  ChatConversation copyWith({
    String? id,
    String? title,
    String? previewText,
    DateTime? lastMessageAt,
    int? messageCount,
    bool? isPinned,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      previewText: previewText ?? this.previewText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messageCount: messageCount ?? this.messageCount,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatConversation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ChatConversation(id: $id, title: $title, lastMessageAt: $lastMessageAt)';
}