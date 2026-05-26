import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/property_model.dart';
import '../providers/listing_provider.dart';
import '../../../shared/widgets/property_card.dart';
import '../../../shared/widgets/empty_state.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ownerListingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/owner/listings/add'),
            tooltip: 'Add Listing',
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
          onAction: () => ref.read(ownerListingProvider.notifier).load(),
        ),
        data: (listings) => listings.isEmpty
            ? EmptyState(
                icon: Icons.home_outlined,
                title: 'No listings yet',
                subtitle: 'Post your first property and start receiving inquiries',
                actionLabel: 'Add Listing',
                onAction: () => context.push('/owner/listings/add'),
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(ownerListingProvider.notifier).load(),
                child: Column(
                  children: [
                    // Status filter tabs
                    _StatusTabs(listings: listings),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: listings.length,
                        itemBuilder: (_, i) => PropertyCard(
                          property: listings[i],
                          showOwnerActions: true,
                          onTap: () => context.push('/owner/listings/edit/${listings[i].id}'),
                          onEdit: () => context.push('/owner/listings/edit/${listings[i].id}'),
                          onBoost: () => _showBoostDialog(context, ref, listings[i].id),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: state.valueOrNull?.isNotEmpty == true
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/owner/listings/add'),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Add Listing', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  void _showBoostDialog(BuildContext context, WidgetRef ref, String propertyId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Boost Listing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose boost duration:'),
            const SizedBox(height: 12),
            ...[
              (days: 3, label: '3 Days', cost: '1 credit'),
              (days: 7, label: '7 Days', cost: '2 credits'),
              (days: 30, label: '30 Days', cost: '5 credits'),
            ].map(
              (opt) => ListTile(
                title: Text(opt.label),
                subtitle: Text(opt.cost, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                trailing: const Icon(Icons.bolt_rounded, color: AppColors.accent),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(ownerListingProvider.notifier).boostListing(propertyId, opt.days);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Listing boosted for ${opt.label}!'), backgroundColor: AppColors.success),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
      ),
    );
  }
}

class _StatusTabs extends StatefulWidget {
  final List<PropertyModel> listings;
  const _StatusTabs({required this.listings});

  @override
  State<_StatusTabs> createState() => _StatusTabsState();
}

class _StatusTabsState extends State<_StatusTabs> {
  int _selected = 0;

  static const _statuses = [
    (label: 'All', status: null),
    (label: 'Active', status: PropertyStatus.approved),
    (label: 'Pending', status: PropertyStatus.pending),
    (label: 'Rented', status: PropertyStatus.rented),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = _statuses[i];
          final count = s.status == null
              ? widget.listings.length
              : widget.listings.where((l) => l.status == s.status).length;
          final isSelected = _selected == i;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
              ),
              child: Text(
                '${s.label} ($count)',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
