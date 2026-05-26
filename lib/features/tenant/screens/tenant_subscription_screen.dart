import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/subscription_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/widgets/custom_button.dart';

class TenantSubscriptionScreen extends ConsumerStatefulWidget {
  const TenantSubscriptionScreen({super.key});

  @override
  ConsumerState<TenantSubscriptionScreen> createState() => _TenantSubscriptionScreenState();
}

class _TenantSubscriptionScreenState extends ConsumerState<TenantSubscriptionScreen> {
  List<SubscriptionPlanModel> _plans = [];
  SubscriptionModel? _current;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final [plansResp, currentResp] = await Future.wait([
        ApiService.instance.get(ApiConstants.subscriptionPlans, params: {'role': 'TENANT'}),
        ApiService.instance.get(ApiConstants.mySubscription),
      ]);
      setState(() {
        _plans = (plansResp.data as List).map((e) => SubscriptionPlanModel.fromJson(e)).toList();
        _current = currentResp.data != null ? SubscriptionModel.fromJson(currentResp.data) : null;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchase(String planId) async {
    try {
      await ApiService.instance.post(ApiConstants.subscriptionPurchase, data: {
        'planId': planId,
        'gateway': 'BKASH',
      });
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription activated!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Plans')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_current != null) ...[
                    _CurrentPlanBanner(subscription: _current!),
                    const SizedBox(height: 24),
                  ],
                  const Text('Available Plans', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Contact more owners with a paid plan', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ..._plans.map((plan) => _PlanCard(
                        plan: plan,
                        isCurrent: _current?.plan.id == plan.id,
                        onPurchase: () => _purchase(plan.id),
                      )),
                ],
              ),
            ),
    );
  }
}

class _CurrentPlanBanner extends StatelessWidget {
  final SubscriptionModel subscription;
  const _CurrentPlanBanner({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subscription.plan.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${subscription.daysLeft} days remaining', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlanModel plan;
  final bool isCurrent;
  final VoidCallback onPurchase;

  const _PlanCard({required this.plan, required this.isCurrent, required this.onPurchase});

  @override
  Widget build(BuildContext context) {
    final isPremium = plan.price > 100;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppColors.primary : (isPremium ? AppColors.accent : AppColors.divider),
          width: isCurrent || isPremium ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(plan.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (isCurrent)
                  const StatusBadge(label: 'ACTIVE', color: AppColors.success)
                else if (isPremium)
                  const StatusBadge(label: 'POPULAR', color: AppColors.accent),
              ],
            ),
            const SizedBox(height: 4),
            Text(plan.formattedPrice, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 16),
            ...plan.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(f, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                )),
            if (!plan.isFree && !isCurrent) ...[
              const SizedBox(height: 16),
              PrimaryButton(label: 'Get ${plan.name}', onPressed: onPurchase),
            ],
          ],
        ),
      ),
    );
  }
}
