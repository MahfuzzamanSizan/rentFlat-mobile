import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/inquiry_model.dart';
import '../providers/owner_inquiry_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';

class OwnerInquiriesScreen extends ConsumerWidget {
  const OwnerInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ownerInquiryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tenant Inquiries')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load',
          subtitle: e.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.read(ownerInquiryProvider.notifier).load(),
        ),
        data: (inquiries) => inquiries.isEmpty
            ? const EmptyState(
                icon: Icons.mail_outline_rounded,
                title: 'No inquiries yet',
                subtitle: 'Tenant inquiries will appear here when someone contacts you',
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(ownerInquiryProvider.notifier).load(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: inquiries.length,
                  itemBuilder: (_, i) => _InquiryCard(
                    inquiry: inquiries[i],
                    onAccept: () => ref.read(ownerInquiryProvider.notifier).accept(inquiries[i].id),
                    onReject: () => ref.read(ownerInquiryProvider.notifier).reject(inquiries[i].id),
                    onChat: () => context.push(
                      '/owner/chat/${inquiries[i].id}',
                      extra: {'otherUserName': inquiries[i].tenantName ?? 'Tenant', 'propertyTitle': inquiries[i].propertyTitle ?? ''},
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _InquiryCard extends StatelessWidget {
  final InquiryModel inquiry;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onChat;

  const _InquiryCard({
    required this.inquiry,
    required this.onAccept,
    required this.onReject,
    required this.onChat,
  });

  Color get _statusColor {
    switch (inquiry.status) {
      case InquiryStatus.accepted: return AppColors.success;
      case InquiryStatus.rejected: return AppColors.error;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    (inquiry.tenantName ?? 'T')[0].toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(inquiry.tenantName ?? 'Tenant', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          if (inquiry.tenantVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded, size: 14, color: AppColors.secondary),
                          ],
                        ],
                      ),
                      if (inquiry.tenantOccupation != null)
                        Text(inquiry.tenantOccupation!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                StatusBadge(label: inquiry.status.name.toUpperCase(), color: _statusColor),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inquiry.propertyTitle ?? 'Property',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(inquiry.message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(inquiry.createdAt),
                  style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
                const Spacer(),
                if (inquiry.tenantRating != null)
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
                    Text(' ${inquiry.tenantRating!.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                  ]),
              ],
            ),
            if (inquiry.isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(0, 40),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ] else if (inquiry.isAccepted) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onChat,
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text('Chat with Tenant'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
