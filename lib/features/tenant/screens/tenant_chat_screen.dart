import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/chat_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class TenantChatScreen extends ConsumerStatefulWidget {
  final String threadId;
  final Map<String, String>? extra;

  const TenantChatScreen({super.key, required this.threadId, this.extra});

  @override
  ConsumerState<TenantChatScreen> createState() => _TenantChatScreenState();
}

class _TenantChatScreenState extends ConsumerState<TenantChatScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessageModel> _messages = [];
  bool _isLoading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final response = await ApiService.instance.get(ApiConstants.chatMessages(widget.threadId));
      final List<dynamic> data = response.data['content'] ?? response.data;
      setState(() {
        _messages = data.map((e) => ChatMessageModel.fromJson(e)).toList();
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    setState(() => _sending = true);
    try {
      final response = await ApiService.instance.post(
        ApiConstants.chatMessages(widget.threadId),
        data: {'content': text, 'type': 'TEXT'},
      );
      final msg = ChatMessageModel.fromJson(response.data);
      setState(() => _messages.add(msg));
      _scrollToBottom();
    } catch (_) {} finally {
      setState(() => _sending = false);
    }
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
    final myId = ref.watch(authProvider).user?.id ?? '';
    final otherName = widget.extra?['otherUserName'] ?? 'Owner';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(otherName),
            if (widget.extra?['propertyTitle'] != null)
              Text(widget.extra!['propertyTitle']!, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('Start the conversation!', style: TextStyle(color: AppColors.textHint)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg = _messages[i];
                          final isMe = msg.senderId == myId;
                          return _ChatBubble(message: msg, isMe: isMe);
                        },
                      ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12, right: 12, top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, -3))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _sending
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.createdAt),
              style: TextStyle(
                color: isMe ? Colors.white60 : AppColors.textHint,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
