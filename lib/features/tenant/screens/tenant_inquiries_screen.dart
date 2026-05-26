import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/inquiry_model.dart';
import '../providers/inquiry_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';

class TenantInquiriesScreen extends ConsumerWidget {
  const TenantInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tenantInquiryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Inquiries')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load',
          subtitle: e.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.read(tenantInquiryProvider.notifier).load(),
        ),
        data: (inquiries) => inquiries.isEmpty
            ? const EmptyState(
                icon: Icons.mail_outline_rounded,
                title: 'No inquiries yet',
                subtitle: 'Send an inquiry to a property owner to get started',
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(tenantInquiryProvider.notifier).load(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: inquiries.length,
                  itemBuilder: (_, i) => _InquiryCard(inquiry: inquiries[i]),
                ),
              ),
      ),
    );
  }
}

class _InquiryCard extends StatelessWidget {
  final InquiryModel inquiry;
  const _InquiryCard({required this.inquiry});

  Color get _statusColor {
    switch (inquiry.status) {
      case InquiryStatus.accepted: return AppColors.success;
      case InquiryStatus.rejected: return AppColors.error;
      case InquiryStatus.withdrawn: return AppColors.textSecondary;
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
                Expanded(
                  child: Text(
                    inquiry.propertyTitle ?? 'Property',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                StatusBadge(
                  label: inquiry.status.name.toUpperCase(),
                  color: _statusColor,
                ),
              ],
            ),
            if (inquiry.propertyRent != null) ...[
              const SizedBox(height: 4),
              Text('৳${inquiry.propertyRent!.toStringAsFixed(0)}/mo',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 8),
            Text(
              inquiry.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(inquiry.createdAt),
                  style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
                const Spacer(),
                if (inquiry.isAccepted)
                  TextButton(
                    onPressed: () => context.push(
                      '/tenant/chat/${inquiry.id}',
                      extra: {'otherUserName': 'Owner', 'propertyTitle': inquiry.propertyTitle ?? ''},
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 14),
                        SizedBox(width: 4),
                        Text('Chat with Owner'),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
