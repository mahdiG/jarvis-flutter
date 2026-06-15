import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../models/chat_message.dart';
import 'conversations_list_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _quickChips = const [
    'Reflect on my day',
    'Help me focus',
    'Plan tomorrow',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      const ChatMessage(
        content:
            'Good morning. The air is quiet today. What is one gentle intention you\'d like to set for the hours ahead?',
        isUser: false,
        timestamp: null,
      ),
    );
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  bool get _isSendEnabled => _textController.text.trim().isNotEmpty;

  void _sendMessage({String? text}) {
    final message = text ?? _textController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(content: message, isUser: true, timestamp: DateTime.now()),
      );
      _textController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate AI reply
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            content: _zenResponse(message),
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  String _zenResponse(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('reflect') || lower.contains('day')) {
      return 'Take a slow breath. What moments from today brought you a sense of peace, even briefly? Those are the threads worth weaving into tomorrow.';
    }
    if (lower.contains('focus') || lower.contains('deep')) {
      return 'That is a noble pursuit. Let us clear the digital desk.\n\nPerhaps we can begin by identifying the single most meaningful piece of deep work you wish to accomplish. What is calling for your attention?';
    }
    if (lower.contains('plan') || lower.contains('tomorrow')) {
      return 'Before mapping the hours ahead, let us name one thing you wish to protect time for tomorrow. Not a task — something that matters.';
    }
    return 'A thoughtful intention. Let it settle before we move. What does this look like in its simplest form?';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              // Chat messages area
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: 8,
                  ),
                  children: [
                    // Date marker
                    const _DateMarker(label: 'Today'),
                    const SizedBox(height: 32),

                    // Messages
                    ..._messages.map((msg) => MessageBubble(message: msg)),

                    // Typing indicator
                    if (_isTyping) ...[
                      const SizedBox(height: 24),
                      const _AiMessageHeader(),
                      const SizedBox(height: 8),
                      const TypingIndicator(),
                    ],
                  ],
                ),
              ),

              // Bottom input area
              _buildBottomInput(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Left: Menu button
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: ZenColors.ink,
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

            // Center: Title
            Expanded(
              child: Center(
                child: Text(
                  'Zen Assistant',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 32 / 24,
                    letterSpacing: -0.01,
                    color: ZenColors.ink,
                  ),
                ),
              ),
            ),

            // Right: History button
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                icon: const Icon(
                  Icons.history_rounded,
                  color: ZenColors.ink,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ConversationsListScreen(),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        color: ZenColors.paperBg,
        border: Border(
          top: BorderSide(
            color: ZenColors.surfaceVariant,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick prompts chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickChips.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final chip = _quickChips[index];
                    return _QuickChip(
                      label: chip,
                      onTap: () => _sendMessage(text: chip),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ZenColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: ZenColors.surfaceContainerHighest.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Add button
                    _InputIconButton(
                      icon: Icons.add_rounded,
                      onPressed: () {},
                    ),

                    // Text field
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.send,
                        maxLines: 4,
                        minLines: 1,
                        onSubmitted: _isSendEnabled ? (_) => _sendMessage() : null,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                          color: ZenColors.ink,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write a thought...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 20 / 14,
                            color: ZenColors.outline.withValues(alpha: 0.7),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),

                    // Send button
                    _InputIconButton(
                      icon: Icons.arrow_upward_rounded,
                      filled: true,
                      onPressed: _isSendEnabled ? () => _sendMessage() : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Date marker ──────────────────────────────────────────────────
class _DateMarker extends StatelessWidget {
  final String label;
  const _DateMarker({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 14 / 11,
          letterSpacing: 0.02,
          color: ZenColors.outline,
        ),
      ),
    );
  }
}

// ─── AI message header (spa icon + "Zen") ─────────────────────────
class _AiMessageHeader extends StatelessWidget {
  const _AiMessageHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.spa_rounded,
            size: 18,
            color: ZenColors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Zen',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 14 / 11,
              letterSpacing: 0.02,
              color: ZenColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick prompt chip ────────────────────────────────────────────
class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ZenColors.secondaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: ZenColors.secondaryContainer.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 14 / 11,
            letterSpacing: 0.02,
            color: ZenColors.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

// ─── Round icon button for input area ─────────────────────────────
class _InputIconButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback? onPressed;

  const _InputIconButton({
    required this.icon,
    this.filled = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = 40.0;
    return SizedBox(
      width: size,
      height: size,
      child: filled
          ? GestureDetector(
              onTap: onPressed,
              child: Container(
                decoration: BoxDecoration(
                  color: ZenColors.ink,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: ZenColors.paperSheet,
                ),
              ),
            )
          : IconButton(
              icon: Icon(icon, color: ZenColors.onSurfaceVariant),
              onPressed: onPressed,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
    );
  }
}