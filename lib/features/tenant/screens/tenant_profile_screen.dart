import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class TenantProfileScreen extends ConsumerWidget {
  const TenantProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
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
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: user.profilePhotoUrl != null
                          ? CachedNetworkImageProvider(user.profilePhotoUrl!)
                          : null,
                      child: user.profilePhotoUrl == null
                          ? const Icon(Icons.person_rounded, size: 44, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_outlined, size: 13, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(user.phone, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        if (user.isKycVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.verified_rounded, size: 16, color: AppColors.accent),
                        ],
                      ],
                    ),
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
                  // KYC status card
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('KYC Not Verified', style: TextStyle(fontWeight: FontWeight.bold)),
                                const Text('Complete verification to get a trusted badge', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/auth/kyc'),
                            child: const Text('Verify'),
                          ),
                        ],
                      ),
                    ),

                  _Section(
                    title: 'Account',
                    items: [
                      _MenuItem(icon: Icons.edit_outlined, label: 'Edit Profile', onTap: () {}),
                      _MenuItem(icon: Icons.workspace_premium_outlined, label: 'Subscription', onTap: () => context.push('/tenant/subscription')),
                      _MenuItem(icon: Icons.article_outlined, label: 'My Leases', onTap: () => context.push('/tenant/lease/all')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Support',
                    items: [
                      _MenuItem(icon: Icons.help_outline_rounded, label: 'Help & FAQ', onTap: () {}),
                      _MenuItem(icon: Icons.feedback_outlined, label: 'Report a Problem', onTap: () {}),
                      _MenuItem(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
                    ],
                  ),
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
            children: List.generate(
              items.length,
              (i) => Column(
                children: [
                  items[i],
                  if (i < items.length - 1) const Divider(height: 1, indent: 52),
                ],
              ),
            ),
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
