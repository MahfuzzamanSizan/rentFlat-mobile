import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class OwnerShell extends StatelessWidget {
  final Widget child;
  const OwnerShell({super.key, required this.child});

  static const _tabs = [
    _TabItem(label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, path: '/owner'),
    _TabItem(label: 'Listings', icon: Icons.home_outlined, activeIcon: Icons.home_rounded, path: '/owner/listings'),
    _TabItem(label: 'Inquiries', icon: Icons.mail_outline_rounded, activeIcon: Icons.mail_rounded, path: '/owner/inquiries'),
    _TabItem(label: 'Profile', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, path: '/owner/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i].path)) {
        currentIndex = i;
        break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isSelected = i == currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => context.go(tab.path),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isSelected ? tab.activeIcon : tab.icon,
                            color: isSelected ? AppColors.primary : AppColors.textHint,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;
  const _TabItem({required this.label, required this.icon, required this.activeIcon, required this.path});
}
