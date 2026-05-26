import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/widgets/empty_state.dart';

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final response = await ApiService.instance.get(ApiConstants.notifications);
  final List<dynamic> data = response.data['content'] ?? response.data;
  return data.map((e) => NotificationModel.fromJson(e)).toList();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.inquiry: return Icons.mail_rounded;
      case NotificationType.lease: return Icons.article_rounded;
      case NotificationType.payment: return Icons.payment_rounded;
      case NotificationType.listing: return Icons.home_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.inquiry: return AppColors.secondary;
      case NotificationType.lease: return AppColors.primary;
      case NotificationType.payment: return AppColors.success;
      case NotificationType.listing: return AppColors.accent;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load',
          subtitle: e.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(notificationsProvider),
        ),
        data: (notifications) => notifications.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications',
                subtitle: 'You\'re all caught up!',
              )
            : ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                itemBuilder: (_, i) {
                  final n = notifications[i];
                  return ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _colorForType(n.type).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_iconForType(n.type), color: _colorForType(n.type), size: 22),
                    ),
                    title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd MMM, HH:mm').format(n.createdAt),
                          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                        ),
                      ],
                    ),
                    tileColor: n.isRead ? null : AppColors.primary.withOpacity(0.04),
                    isThreeLine: true,
                  );
                },
              ),
      ),
    );
  }
}
