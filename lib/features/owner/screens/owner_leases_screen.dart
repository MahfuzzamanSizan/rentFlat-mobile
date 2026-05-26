import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/lease_model.dart';
import '../providers/owner_lease_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';

class OwnerLeasesScreen extends ConsumerWidget {
  const OwnerLeasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ownerLeaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lease Management'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/owner/leases/create'),
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text('New Lease', style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load',
          subtitle: e.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.read(ownerLeaseProvider.notifier).load(),
        ),
        data: (leases) => leases.isEmpty
            ? EmptyState(
                icon: Icons.article_outlined,
                title: 'No leases yet',
                subtitle: 'Create digital leases for your tenants',
                actionLabel: 'Create Lease',
                onAction: () => context.push('/owner/leases/create'),
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(ownerLeaseProvider.notifier).load(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: leases.length,
                  itemBuilder: (_, i) => _OwnerLeaseCard(
                    lease: leases[i],
                    onRecordPayment: () => _showPaymentDialog(context, ref, leases[i].id),
                    onTerminate: () => _showTerminateDialog(context, ref, leases[i].id),
                  ),
                ),
              ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, WidgetRef ref, String leaseId) {
    final amountCtrl = TextEditingController();
    PaymentMethod selectedMethod = PaymentMethod.bkash;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Record Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (৳)', prefixText: '৳ '),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PaymentMethod>(
                value: selectedMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: PaymentMethod.values.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m.name.toUpperCase()),
                )).toList(),
                onChanged: (v) => setState(() => selectedMethod = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(ownerLeaseProvider.notifier).recordPayment(leaseId, {
                  'amount': double.tryParse(amountCtrl.text) ?? 0,
                  'paymentMethod': selectedMethod.name.toUpperCase(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment recorded!'), backgroundColor: AppColors.success),
                );
              },
              child: const Text('Record'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTerminateDialog(BuildContext context, WidgetRef ref, String leaseId) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terminate Lease'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Reason for termination'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(ownerLeaseProvider.notifier).terminateLease(leaseId, reasonCtrl.text.trim());
            },
            child: const Text('Terminate'),
          ),
        ],
      ),
    );
  }
}

class _OwnerLeaseCard extends StatelessWidget {
  final LeaseModel lease;
  final VoidCallback onRecordPayment;
  final VoidCallback onTerminate;

  const _OwnerLeaseCard({required this.lease, required this.onRecordPayment, required this.onTerminate});

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lease.propertyTitle ?? 'Property', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Tenant: ${lease.tenantName ?? "—"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                StatusBadge(label: lease.status.name.toUpperCase(), color: _statusColor),
              ],
            ),
            const Divider(height: 20),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('${fmt.format(lease.startDate)} — ${fmt.format(lease.endDate)}', style: const TextStyle(fontSize: 13)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.payments_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('৳${lease.rentAmount.toStringAsFixed(0)}/mo  •  Due: ${lease.rentDueDay}th', style: const TextStyle(fontSize: 13)),
            ]),
            if (lease.isActive) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTerminate,
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Terminate', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(0, 38),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onRecordPayment,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Record Payment', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
