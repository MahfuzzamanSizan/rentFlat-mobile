import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

// Auth screens
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/phone_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/auth/screens/kyc_screen.dart';

// Tenant screens
import '../../features/tenant/screens/tenant_shell.dart';
import '../../features/tenant/screens/home_screen.dart';
import '../../features/tenant/screens/property_detail_screen.dart';
import '../../features/tenant/screens/shortlist_screen.dart';
import '../../features/tenant/screens/tenant_inquiries_screen.dart';
import '../../features/tenant/screens/tenant_chat_screen.dart';
import '../../features/tenant/screens/tenant_lease_screen.dart';
import '../../features/tenant/screens/tenant_subscription_screen.dart';
import '../../features/tenant/screens/notifications_screen.dart';
import '../../features/tenant/screens/tenant_profile_screen.dart';

// Owner screens
import '../../features/owner/screens/owner_shell.dart';
import '../../features/owner/screens/owner_dashboard_screen.dart';
import '../../features/owner/screens/my_listings_screen.dart';
import '../../features/owner/screens/add_property_screen.dart';
import '../../features/owner/screens/owner_inquiries_screen.dart';
import '../../features/owner/screens/owner_chat_screen.dart';
import '../../features/owner/screens/owner_leases_screen.dart';
import '../../features/owner/screens/create_lease_screen.dart';
import '../../features/owner/screens/owner_subscription_screen.dart';
import '../../features/owner/screens/owner_profile_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _tenantKey = GlobalKey<NavigatorState>(debugLabel: 'tenant');
final _ownerKey = GlobalKey<NavigatorState>(debugLabel: 'owner');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final status = authState.status;
      final location = state.uri.toString();

      if (status == AuthStatus.unknown) return null;

      final isAuthRoute = location.startsWith('/auth') || location == '/splash';

      if (status == AuthStatus.unauthenticated && !isAuthRoute) {
        return '/auth/phone';
      }

      if (status == AuthStatus.authenticated) {
        final user = authState.user!;
        if (isAuthRoute && location != '/splash') {
          return user.isOwner ? '/owner' : '/tenant';
        }
        if (user.isOwner && location.startsWith('/tenant')) {
          return '/owner';
        }
        if (user.isTenant && location.startsWith('/owner')) {
          return '/tenant';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),

      // Auth routes
      GoRoute(path: '/auth/phone', builder: (_, __) => const PhoneScreen()),
      GoRoute(
        path: '/auth/otp',
        builder: (_, state) => OtpScreen(phone: state.extra as String),
      ),
      GoRoute(path: '/auth/role', builder: (_, __) => const RoleSelectionScreen()),
      GoRoute(
        path: '/auth/profile',
        builder: (_, state) => ProfileSetupScreen(role: state.extra as String),
      ),
      GoRoute(path: '/auth/kyc', builder: (_, __) => const KycScreen()),

      // Tenant shell with bottom nav
      ShellRoute(
        navigatorKey: _tenantKey,
        builder: (context, state, child) => TenantShell(child: child),
        routes: [
          GoRoute(
            path: '/tenant',
            builder: (_, __) => const TenantHomeScreen(),
          ),
          GoRoute(
            path: '/tenant/shortlist',
            builder: (_, __) => const ShortlistScreen(),
          ),
          GoRoute(
            path: '/tenant/inquiries',
            builder: (_, __) => const TenantInquiriesScreen(),
          ),
          GoRoute(
            path: '/tenant/profile',
            builder: (_, __) => const TenantProfileScreen(),
          ),
        ],
      ),

      // Tenant detail routes (full screen, outside shell)
      GoRoute(
        path: '/tenant/property/:id',
        builder: (_, state) => PropertyDetailScreen(propertyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/tenant/chat/:threadId',
        builder: (_, state) => TenantChatScreen(
          threadId: state.pathParameters['threadId']!,
          extra: state.extra as Map<String, String>?,
        ),
      ),
      GoRoute(
        path: '/tenant/lease/:id',
        builder: (_, state) => TenantLeaseScreen(leaseId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/tenant/subscription',
        builder: (_, __) => const TenantSubscriptionScreen(),
      ),
      GoRoute(
        path: '/tenant/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),

      // Owner shell with bottom nav
      ShellRoute(
        navigatorKey: _ownerKey,
        builder: (context, state, child) => OwnerShell(child: child),
        routes: [
          GoRoute(
            path: '/owner',
            builder: (_, __) => const OwnerDashboardScreen(),
          ),
          GoRoute(
            path: '/owner/listings',
            builder: (_, __) => const MyListingsScreen(),
          ),
          GoRoute(
            path: '/owner/inquiries',
            builder: (_, __) => const OwnerInquiriesScreen(),
          ),
          GoRoute(
            path: '/owner/profile',
            builder: (_, __) => const OwnerProfileScreen(),
          ),
        ],
      ),

      // Owner detail routes (full screen)
      GoRoute(
        path: '/owner/listings/add',
        builder: (_, __) => const AddPropertyScreen(),
      ),
      GoRoute(
        path: '/owner/listings/edit/:id',
        builder: (_, state) => AddPropertyScreen(propertyId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/owner/chat/:threadId',
        builder: (_, state) => OwnerChatScreen(
          threadId: state.pathParameters['threadId']!,
          extra: state.extra as Map<String, String>?,
        ),
      ),
      GoRoute(
        path: '/owner/leases',
        builder: (_, __) => const OwnerLeasesScreen(),
      ),
      GoRoute(
        path: '/owner/leases/create',
        builder: (_, state) => CreateLeaseScreen(extra: state.extra as Map<String, String>?),
      ),
      GoRoute(
        path: '/owner/subscription',
        builder: (_, __) => const OwnerSubscriptionScreen(),
      ),
      GoRoute(
        path: '/owner/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
    ],
  );
});
