import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tenant/screens/tenant_subscription_screen.dart';

// Owner subscription screen reuses the same logic
class OwnerSubscriptionScreen extends ConsumerWidget {
  const OwnerSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const TenantSubscriptionScreen();
  }
}
