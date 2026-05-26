import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import '../providers/owner_inquiry_provider.dart';
import '../providers/owner_lease_provider.dart';
import '../../../core/models/property_model.dart';
import '../../../core/models/inquiry_model.dart';
import '../../../core/models/lease_model.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final listingsState = ref.watch(ownerListingProvider);
    final inquiriesState = ref.watch(ownerInquiryProvider);
    final leasesState = ref.watch(ownerLeaseProvider);

    final listings = listingsState.valueOrNull ?? [];
    final inquiries = inquiriesState.valueOrNull ?? [];
    final leases = leasesState.valueOrNull ?? [];

    final activeListings = listings.where((l) => l.status == PropertyStatus.approved).length;
    final pendingInquiries = inquiries.where((i) => i.status == InquiryStatus.pending).length;
    final activeLeases = leases.where((l) => l.isActive).length;
    final totalRevenue = leases
        .where((l) => l.isActive)
        .fold(0.0, (sum, l) => sum + l.rentAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ownerListingProvider);
          ref.invalidate(ownerInquiryProvider);
          ref.invalidate(ownerLeaseProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Hero App Bar ─────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 170,
              pinned: true,
              backgroundColor: AppColors.primary,
              elevation: 0,
              actions: [
                GestureDetector(
                  onTap: () => context.push('/owner/notifications'),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              user.fullName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome back,', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                              Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // KYC warning
                  if (!user.isKycVerified) ...[
                    _KycBanner(onTap: () => context.push('/auth/kyc')),
                    const SizedBox(height: 16),
                  ],

                  // Stats grid
                  const Text('Overview', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.45,
                    children: [
                      _StatCard(
                        icon: Icons.home_rounded,
                        label: 'Active Listings',
                        value: '$activeListings',
                        color: AppColors.primary,
                        gradient: AppColors.primaryGradient,
                        onTap: () => context.go('/owner/listings'),
                      ),
                      _StatCard(
                        icon: Icons.mail_rounded,
                        label: 'New Inquiries',
                        value: '$pendingInquiries',
                        color: AppColors.secondary,
                        gradient: const LinearGradient(colors: [Color(0xFF2B87D1), Color(0xFF4EA8E8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        onTap: () => context.go('/owner/inquiries'),
                      ),
                      _StatCard(
                        icon: Icons.article_rounded,
                        label: 'Active Leases',
                        value: '$activeLeases',
                        color: AppColors.success,
                        gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF43A047)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        onTap: () => context.push('/owner/leases'),
                      ),
                      _StatCard(
                        icon: Icons.payments_rounded,
                        label: 'Monthly Revenue',
                        value: totalRevenue == 0 ? '৳0' : '৳${(totalRevenue / 1000).toStringAsFixed(0)}k',
                        color: AppColors.accent,
                        gradient: AppColors.accentGradient,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Quick actions
                  const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _ActionButton(icon: Icons.add_home_rounded, label: 'Add Listing', color: AppColors.primary, onTap: () => context.push('/owner/listings/add'))),
                      const SizedBox(width: 10),
                      Expanded(child: _ActionButton(icon: Icons.article_rounded, label: 'Leases', color: AppColors.success, onTap: () => context.push('/owner/leases'))),
                      const SizedBox(width: 10),
                      Expanded(child: _ActionButton(icon: Icons.workspace_premium_rounded, label: 'Plans', color: AppColors.accent, onTap: () => context.push('/owner/subscription'))),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Recent inquiries
                  if (inquiries.isNotEmpty) ...[
                    Row(
                      children: [
                        const Text('Recent Inquiries', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.go('/owner/inquiries'),
                          child: const Text('See all', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...inquiries.take(3).map((inq) => _InquiryTile(inquiry: inq,
                        onTap: () => context.go('/owner/inquiries'))),
                  ],

                  // Recent leases
                  if (leases.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text('Active Leases', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.push('/owner/leases'),
                          child: const Text('See all', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...leases.where((l) => l.isActive).take(2).map((lease) => _LeaseTile(lease: lease)),
                  ],

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KycBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _KycBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complete KYC Verification', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text('Upload NID to post listings & get verified badge', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(8)),
              child: const Text('Verify', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 5))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _InquiryTile extends StatelessWidget {
  final InquiryModel inquiry;
  final VoidCallback onTap;
  const _InquiryTile({required this.inquiry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                (inquiry.tenantName ?? 'T')[0].toUpperCase(),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(inquiry.tenantName ?? 'Tenant', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(inquiry.propertyTitle ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (inquiry.isPending)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(8)),
                child: const Text('New', style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }
}

class _LeaseTile extends StatelessWidget {
  final LeaseModel lease;
  const _LeaseTile({required this.lease});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.article_rounded, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lease.propertyTitle ?? 'Property', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Tenant: ${lease.tenantName ?? "—"}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('৳${lease.rentAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13)),
              Text('/mo', style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
            ],
          ),
        ],
      ),
    );
  }
}
