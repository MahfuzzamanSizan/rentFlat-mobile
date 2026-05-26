import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tenant/screens/tenant_chat_screen.dart';

// Owner chat reuses the same chat UI
class OwnerChatScreen extends ConsumerWidget {
  final String threadId;
  final Map<String, String>? extra;

  const OwnerChatScreen({super.key, required this.threadId, this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TenantChatScreen(threadId: threadId, extra: extra);
  }
}
