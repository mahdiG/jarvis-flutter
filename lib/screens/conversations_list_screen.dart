import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/chat_conversation.dart';
import '../widgets/conversation_card.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  // Sample conversations for demonstration
  final List<ChatConversation> _conversations = [
    ChatConversation(
      id: '1',
      title: 'Setting intentions for the week',
      previewText:
          'Take a slow breath. What moments from today brought you a sense of peace, even briefly?',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 15)),
      messageCount: 8,
    ),
    ChatConversation(
      id: '2',
      title: 'Deep work planning session',
      previewText:
          'Before mapping the hours ahead, let us name one thing you wish to protect time for tomorrow.',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
      messageCount: 12,
    ),
    ChatConversation(
      id: '3',
      title: 'Evening reflection',
      previewText:
          'A thoughtful intention. Let it settle before we move. What does this look like in its simplest form?',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      messageCount: 5,
    ),
    ChatConversation(
      id: '4',
      title: 'Morning mindfulness',
      previewText:
          'Good morning. The air is quiet today. What is one gentle intention you\'d like to set?',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
      messageCount: 10,
    ),
    ChatConversation(
      id: '5',
      title: 'Focus and productivity',
      previewText:
          'That is a noble pursuit. Let us clear the digital desk. What is calling for your attention?',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 3)),
      messageCount: 15,
    ),
    ChatConversation(
      id: '6',
      title: 'Gratitude practice',
      previewText:
          'Take a moment to notice three small things that went well today.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 5)),
      messageCount: 6,
    ),
    ChatConversation(
      id: '7',
      title: 'Creative brainstorming',
      previewText:
          'Let the ideas flow without judgment. What comes to mind when you think of possibility?',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 10)),
      messageCount: 20,
    ),
  ];

  List<ChatConversation> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;
    final query = _searchQuery.toLowerCase();
    return _conversations.where((c) {
      return c.title.toLowerCase().contains(query) ||
          c.previewText.toLowerCase().contains(query);
    }).toList();
  }

  /// Groups conversations by their section key.
  Map<String, List<ChatConversation>> _groupConversations(
      List<ChatConversation> conversations) {
    final grouped = <String, List<ChatConversation>>{};
    for (final c in conversations) {
      grouped.putIfAbsent(c.sectionKey, () => []).add(c);
    }
    // Sort groups by priority
    final order = ['Today', 'Yesterday', 'This week', 'Older'];
    final sorted = <String, List<ChatConversation>>{};
    for (final key in order) {
      if (grouped.containsKey(key)) {
        sorted[key] = grouped[key]!;
      }
    }
    return sorted;
  }

  void _deleteConversation(ChatConversation conversation) {
    setState(() {
      _conversations.removeWhere((c) => c.id == conversation.id);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Conversation deleted',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ZenColors.paperSheet,
          ),
        ),
        backgroundColor: ZenColors.ink,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          textColor: ZenColors.secondaryContainer,
          onPressed: () {
            // Re-add the conversation back
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredConversations;
    final grouped = _groupConversations(filtered);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Content
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : _buildConversationsList(grouped),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: ZenColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      title: Text(
        'History',
        style: GoogleFonts.sourceSerif4(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 32 / 24,
          letterSpacing: -0.01,
          color: ZenColors.ink,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: ZenColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ZenColors.surfaceContainerHighest.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(
              Icons.search_rounded,
              size: 20,
              color: ZenColors.outline.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                  color: ZenColors.ink,
                ),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 20 / 14,
                    color: ZenColors.outline.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: ZenColors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationsList(Map<String, List<ChatConversation>> grouped) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      children: [
        for (final entry in grouped.entries) ...[
          // Section header
          _SectionHeader(label: entry.key),
          // Conversations in this section
          for (final conversation in entry.value)
            ConversationCard(
              conversation: conversation,
              onTap: () {
                // Navigate back to chat with this conversation context
                Navigator.of(context).pop(conversation);
              },
              onDelete: () => _deleteConversation(conversation),
            ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off_rounded : Icons.spa_rounded,
              size: 48,
              color: ZenColors.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'No conversations found' : 'No conversations yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 22 / 16,
                color: ZenColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try a different search term'
                  : 'Start a chat with Zen Assistant\nto see your conversations here',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 18 / 13,
                color: ZenColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 14 / 11,
          letterSpacing: 0.08,
          color: ZenColors.outline,
        ),
      ),
    );
  }
}