import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/chat_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

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
  final List<ChatMessageModel> _messages = [];
  final Set<String> _seenIds = {};

  bool _isLoading = true;
  bool _sending = false;
  bool _wsConnected = false;

  StompClient? _stompClient;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _stompClient?.deactivate();
    _pollTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── REST: load full history ───────────────────────────────────────────────

  Future<void> _loadMessages() async {
    try {
      final response = await ApiService.instance
          .get(ApiConstants.chatMessages(widget.threadId));
      final raw = response.data;
      final List<dynamic> data = raw is List ? raw : (raw['content'] ?? []);
      _mergeMessages(data.map((e) => ChatMessageModel.fromJson(e)).toList());
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── WebSocket (STOMP) ─────────────────────────────────────────────────────

  Future<void> _connectWebSocket() async {
    final token = await StorageService.getAccessToken();
    final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};

    _stompClient = StompClient(
      config: StompConfig(
        url: ApiConstants.wsUrl,
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
        reconnectDelay: const Duration(seconds: 8),
        onConnect: _onWsConnected,
        onDisconnect: (_) => _onWsDisconnected(),
        onStompError: (_) => _onWsDisconnected(),
        onWebSocketError: (_) => _onWsDisconnected(),
      ),
    );
    _stompClient!.activate();
  }

  void _onWsConnected(StompFrame frame) {
    _pollTimer?.cancel();
    if (mounted) setState(() => _wsConnected = true);

    // Subscribe to the shared chat topic for this thread
    _stompClient!.subscribe(
      destination: ApiConstants.chatTopic(widget.threadId),
      callback: _onWsFrame,
    );
    // Also subscribe to user-specific queue (backend may route messages here)
    _stompClient!.subscribe(
      destination: ApiConstants.userQueue,
      callback: _onWsFrame,
    );
  }

  void _onWsFrame(StompFrame frame) {
    if (frame.body == null || !mounted) return;
    try {
      final msg = ChatMessageModel.fromJson(jsonDecode(frame.body!));
      // Ignore messages that belong to a different thread
      if (msg.threadId.isNotEmpty && msg.threadId != widget.threadId) return;
      _mergeMessages([msg]);
      if (mounted) {
        setState(() {});
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _onWsDisconnected() {
    if (mounted) setState(() => _wsConnected = false);
    // Fall back to polling every 5 s when WebSocket is unavailable
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _pollMessages(),
    );
  }

  // ── Polling fallback ──────────────────────────────────────────────────────

  Future<void> _pollMessages() async {
    if (!mounted) return;
    try {
      final response = await ApiService.instance
          .get(ApiConstants.chatMessages(widget.threadId));
      final raw = response.data;
      final List<dynamic> data = raw is List ? raw : (raw['content'] ?? []);
      final newOnes = _mergeMessages(
          data.map((e) => ChatMessageModel.fromJson(e)).toList());
      if (newOnes > 0 && mounted) {
        setState(() {});
        _scrollToBottom();
      }
    } catch (_) {}
  }

  // ── Send message ──────────────────────────────────────────────────────────

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    if (mounted) setState(() => _sending = true);
    try {
      // Always persist via REST; WS will deliver to the other party
      final response = await ApiService.instance.post(
        ApiConstants.chatMessages(widget.threadId),
        data: {'content': text},
      );
      final msg = ChatMessageModel.fromJson(response.data);
      _mergeMessages([msg]);
      if (mounted) {
        setState(() {});
        _scrollToBottom();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Inserts messages not already in the list, returns count of new items.
  int _mergeMessages(List<ChatMessageModel> incoming) {
    int added = 0;
    for (final m in incoming) {
      if (_seenIds.add(m.id)) {
        _messages.add(m);
        added++;
      }
    }
    if (added > 0) {
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return added;
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(authProvider).user?.id.toString() ?? '';
    final otherName = widget.extra?['otherUserName'] ?? 'Owner';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(otherName),
            if (widget.extra?['propertyTitle'] != null)
              Text(
                widget.extra!['propertyTitle']!,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          // Live / offline indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Tooltip(
              message: _wsConnected ? 'Live' : 'Polling',
              child: Icon(
                Icons.circle,
                size: 10,
                color: _wsConnected ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Start the conversation!',
                          style: TextStyle(color: AppColors.textHint),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg = _messages[i];
                          final isMe = msg.senderId == myId;
                          final showDate = i == 0 ||
                              !_sameDay(
                                  _messages[i - 1].createdAt, msg.createdAt);
                          return Column(
                            children: [
                              if (showDate) _DateDivider(msg.createdAt),
                              _ChatBubble(message: msg, isMe: isMe),
                            ],
                          );
                        },
                      ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, -3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _sending
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
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

// ── Supporting widgets ────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider(this.date);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = DateFormat('dd MMM yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.divider, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.divider, height: 1)),
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
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.createdAt),
                  style: TextStyle(
                    color: isMe ? Colors.white60 : AppColors.textHint,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 12,
                    color: message.isRead
                        ? Colors.lightBlueAccent
                        : Colors.white60,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
