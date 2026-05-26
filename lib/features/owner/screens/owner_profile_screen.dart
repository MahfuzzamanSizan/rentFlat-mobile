import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class OwnerProfileScreen extends ConsumerWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user!;
    final listingsState = ref.watch(ownerListingProvider);
    final listings = listingsState.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: user.profilePhotoUrl != null
                          ? CachedNetworkImageProvider(user.profilePhotoUrl!)
                          : null,
                      child: user.profilePhotoUrl == null
                          ? const Icon(Icons.person_rounded, size: 48, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        if (user.isKycVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, size: 18, color: AppColors.accent),
                        ],
                      ],
                    ),
                    const Text('Flat Owner', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats row
                  Row(
                    children: [
                      Expanded(child: _StatItem(value: '${listings.length}', label: 'Total Listings')),
                      Container(width: 1, height: 40, color: AppColors.divider),
                      Expanded(child: _StatItem(value: '${listings.where((l) => l.status.name == 'approved').length}', label: 'Active')),
                      Container(width: 1, height: 40, color: AppColors.divider),
                      Expanded(child: _StatItem(value: '4.8', label: 'Avg Rating')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // KYC warning
                  if (!user.isKycVerified)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('KYC Pending', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('Upload NID to get verified badge', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          TextButton(onPressed: () => context.push('/auth/kyc'), child: const Text('Upload')),
                        ],
                      ),
                    ),

                  _Section(title: 'Manage', items: [
                    _MenuItem(icon: Icons.home_outlined, label: 'My Listings', onTap: () => context.go('/owner/listings')),
                    _MenuItem(icon: Icons.article_outlined, label: 'Lease Management', onTap: () => context.push('/owner/leases')),
                    _MenuItem(icon: Icons.workspace_premium_outlined, label: 'Subscription', onTap: () => context.push('/owner/subscription')),
                    _MenuItem(icon: Icons.bar_chart_rounded, label: 'Analytics', onTap: () {}),
                  ]),
                  const SizedBox(height: 12),
                  _Section(title: 'Account', items: [
                    _MenuItem(icon: Icons.edit_outlined, label: 'Edit Profile', onTap: () {}),
                    _MenuItem(icon: Icons.lock_outline_rounded, label: 'Security', onTap: () {}),
                    _MenuItem(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}),
                  ]),
                  const SizedBox(height: 24),
                  SecondaryButton(
                    label: 'Log Out',
                    onPressed: () => _confirmLogout(context, ref),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Log Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 12)),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: List.generate(items.length, (i) => Column(
              children: [
                items[i],
                if (i < items.length - 1) const Divider(height: 1, indent: 52),
              ],
            )),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
