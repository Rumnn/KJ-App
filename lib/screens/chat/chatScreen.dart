import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../services/chatService.dart';
import '../../appTheme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isLoading = false;
  late AnimationController _typingController;

  static const List<String> _quickPrompts = [
    '見る vs 拝見する vs ご覧になる',
    'いただく vs もらう の違いは?',
    '行く の敬語は何ですか?',
    'Kanji 心 を解説して',
    'Nビジネスメールの書き方',
  ];

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _typingController.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      role: 'assistant',
      content:
          '🎌 **Xin chào! Tôi là Sensei AI của bạn!**\n\nTôi có thể giúp bạn:\n- 📖 Giải thích **Kanji** và từ vựng\n- 🎭 Phân biệt các từ **đồng nghĩa**\n- 🏢 Hướng dẫn **Keigo** (kính ngữ)\n- ✍️ So sánh **văn nói vs văn viết**\n\nHãy hỏi tôi bất cứ điều gì về tiếng Nhật! 🌸',
      timestamp: DateTime.now(),
    ));
  }

  String _errorText(dynamic value) {
    if (value is String) return value;
    if (value is Map) {
      final nested = value['message'] ??
          value['reply'] ??
          value['error'] ??
          value['content'] ??
          value['text'];
      if (nested != null && nested != value) return _errorText(nested);
    }

    return value?.toString() ?? 'Đã có lỗi xảy ra.';
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    _inputCtrl.clear();
    final userMsg = ChatMessage(
      role: 'user',
      content: text.trim(),
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // History = all except welcome + current user message
      final history = _messages
          .where((m) => m != userMsg)
          .skip(1) // skip welcome
          .toList();
      final reply = await ChatService.sendMessage(
        message: text.trim(),
        history: history,
      );
      setState(() {
        _messages.add(ChatMessage(
          role: 'assistant',
          content: reply,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      // Extract server error message if available
      String errorMsg;
      try {
        // ignore: avoid_dynamic_calls
        final dioData = (e as dynamic).response?.data;
        if (dioData is Map) {
          final serverMessage = dioData['message'] ?? dioData['reply'];
          errorMsg = _errorText(serverMessage ?? dioData);
        } else if (dioData is String) {
          errorMsg = dioData;
        } else {
          errorMsg = e.toString();
        }
      } catch (_) {
        errorMsg = e.toString();
      }

      setState(() {
        _messages.add(ChatMessage(
          role: 'assistant',
          content: '$errorMsg',
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _messages.length == 1
                ? _buildWelcomeView()
                : _buildMessageList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: AppTheme.primary),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4352A5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('先', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sensei AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onBackground)),
              Text('Japanese Language Assistant', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textMuted),
          tooltip: 'Cuộc trò chuyện mới',
          onPressed: () {
            setState(() {
              _messages.clear();
              _addWelcomeMessage();
            });
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildBubble(_messages.first),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Gợi ý câu hỏi:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickPrompts.map((p) => _buildQuickPrompt(p)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompt(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == _messages.length) return _buildTypingIndicator();
        return _buildBubble(_messages[i]);
      },
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: msg.content));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã sao chép!'), duration: Duration(seconds: 1)),
          );
        },
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isUser
                ? const LinearGradient(
                    colors: [Color(0xFF4352A5), Color(0xFF5C6BC0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isUser ? null : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isUser ? 20 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 20),
            ),
            boxShadow: [
              BoxShadow(
                color: (isUser ? AppTheme.primary : Colors.black).withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isUser
              ? Text(msg.content, style: const TextStyle(color: Colors.white, fontSize: 15))
              : MarkdownBody(
                  data: msg.content,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 14, color: AppTheme.onBackground, height: 1.5),
                    h1: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    h2: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onBackground),
                    h3: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.onBackground),
                    strong: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onBackground),
                    em: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
                    code: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      backgroundColor: AppTheme.surfaceContainer,
                      color: AppTheme.primary,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tableHead: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tableBody: const TextStyle(fontSize: 13),
                    tableBorder: TableBorder.all(color: AppTheme.outlineVariant, width: 0.5),
                    tableHeadAlign: TextAlign.center,
                    blockquote: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    blockquoteDecoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.05),
                      border: Border(
                        left: BorderSide(color: AppTheme.primary, width: 3),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _typingController,
              builder: (_, __) {
                final progress = (_typingController.value + i * 0.3) % 1.0;
                final opacity = (0.4 + 0.6 * (progress < 0.5 ? progress * 2 : (1 - progress) * 2)).clamp(0.0, 1.0);
                return Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _inputCtrl,
                maxLines: 5,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 15, color: AppTheme.onBackground),
                decoration: const InputDecoration(
                  hintText: 'Hỏi về Kanji, từ vựng, Keigo...',
                  hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (v) => _sendMessage(v),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: () => _sendMessage(_inputCtrl.text),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4352A5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
