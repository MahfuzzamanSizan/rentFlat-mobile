import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/property_provider.dart';
import '../../../shared/widgets/property_card.dart';
import '../../../shared/widgets/empty_state.dart';

class ShortlistScreen extends ConsumerWidget {
  const ShortlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortlistedIds = ref.watch(shortlistProvider);
    final allProperties = ref.watch(propertySearchProvider).properties;
    final shortlisted = allProperties.where((p) => shortlistedIds.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Properties')),
      body: shortlisted.isEmpty
          ? const EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No saved properties',
              subtitle: 'Properties you save will appear here',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: shortlisted.length,
              itemBuilder: (_, i) => PropertyCard(
                property: shortlisted[i],
                onTap: () => context.push('/tenant/property/${shortlisted[i].id}'),
              ),
            ),
    );
  }
}
