import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/lease_model.dart';
import '../providers/lease_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';

class TenantLeaseScreen extends ConsumerWidget {
  final String? leaseId;
  const TenantLeaseScreen({super.key, this.leaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tenantLeaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Leases')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load',
          subtitle: e.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.read(tenantLeaseProvider.notifier).load(),
        ),
        data: (leases) => leases.isEmpty
            ? const EmptyState(
                icon: Icons.article_outlined,
                title: 'No leases yet',
                subtitle: 'Your lease agreements will appear here',
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(tenantLeaseProvider.notifier).load(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: leases.length,
                  itemBuilder: (_, i) => _LeaseCard(
                    lease: leases[i],
                    onSign: leases[i].needsTenantSignature
                        ? () => ref.read(tenantLeaseProvider.notifier).signLease(leases[i].id)
                        : null,
                  ),
                ),
              ),
      ),
    );
  }
}

class _LeaseCard extends StatelessWidget {
  final LeaseModel lease;
  final VoidCallback? onSign;

  const _LeaseCard({required this.lease, this.onSign});

  Color get _statusColor {
    switch (lease.status) {
      case LeaseStatus.active: return AppColors.success;
      case LeaseStatus.terminated: return AppColors.error;
      case LeaseStatus.expired: return AppColors.textSecondary;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
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
                    lease.propertyTitle ?? 'Property',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                StatusBadge(label: lease.status.name.toUpperCase(), color: _statusColor),
              ],
            ),
            if (lease.propertyAddress != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(lease.propertyAddress!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
            const Divider(height: 20),
            _InfoRow(label: 'Owner', value: lease.ownerName ?? '—'),
            _InfoRow(label: 'Start Date', value: fmt.format(lease.startDate)),
            _InfoRow(label: 'End Date', value: fmt.format(lease.endDate)),
            _InfoRow(label: 'Monthly Rent', value: '৳${lease.rentAmount.toStringAsFixed(0)}'),
            _InfoRow(label: 'Security Deposit', value: '৳${lease.securityDeposit.toStringAsFixed(0)}'),
            _InfoRow(label: 'Rent Due Day', value: '${lease.rentDueDay}th of every month'),

            if (lease.ownerSignedAt != null) ...[
              const SizedBox(height: 8),
              _SignatureStatus(label: 'Owner Signed', date: lease.ownerSignedAt!),
            ],
            if (lease.tenantSignedAt != null) ...[
              const SizedBox(height: 4),
              _SignatureStatus(label: 'You Signed', date: lease.tenantSignedAt!),
            ],

            if (onSign != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, color: AppColors.warning),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Owner has sent this lease for your signature', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Review & Sign Lease', onPressed: onSign),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }
}

class _SignatureStatus extends StatelessWidget {
  final String label;
  final DateTime date;
  const _SignatureStatus({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
        const SizedBox(width: 6),
        Text('$label on ${DateFormat('dd MMM yyyy').format(date)}',
            style: const TextStyle(color: AppColors.success, fontSize: 12)),
      ],
    );
  }
}
