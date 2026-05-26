import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class TenantShell extends StatelessWidget {
  final Widget child;
  const TenantShell({super.key, required this.child});

  static const _tabs = [
    _Tab('Explore',   Icons.explore_outlined,       Icons.explore_rounded,        '/tenant',             AppColors.tealGradient),
    _Tab('Saved',     Icons.bookmark_border_rounded, Icons.bookmark_rounded,        '/tenant/shortlist',   AppColors.violetGradient),
    _Tab('Inquiries', Icons.mail_outline_rounded,    Icons.mail_rounded,            '/tenant/inquiries',   AppColors.roseGradient),
    _Tab('Profile',   Icons.person_outline_rounded,  Icons.person_rounded,          '/tenant/profile',     AppColors.primaryGradient),
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
      bottomNavigationBar: _FloatingNavBar(
        tabs: _tabs,
        currentIndex: currentIndex,
        onTap: (i) => context.go(_tabs[i].path),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final List<_Tab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _FloatingNavBar(
      {required this.tabs,
      required this.currentIndex,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.6), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final tab = tabs[i];
              final selected = i == currentIndex;
              return Expanded(
                child: _NavItem(
                  tab: tab,
                  selected: selected,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.tab, required this.selected, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    if (widget.selected) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) {
      _ctrl.forward();
    } else if (!widget.selected && old.selected) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon pill
            Transform.scale(
              scale: _scale.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.selected ? 18 : 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: widget.selected ? widget.tab.gradient : null,
                  color: widget.selected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: widget.selected
                      ? [
                          BoxShadow(
                            color: widget.tab.gradient.colors.first
                                .withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  widget.selected ? widget.tab.activeIcon : widget.tab.icon,
                  size: 22,
                  color: widget.selected
                      ? Colors.white
                      : AppColors.textHint,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: widget.selected ? FontWeight.w800 : FontWeight.w500,
                color: widget.selected
                    ? widget.tab.gradient.colors.first
                    : AppColors.textHint,
                letterSpacing: widget.selected ? 0.2 : 0,
              ),
              child: Text(widget.tab.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;
  final LinearGradient gradient;
  const _Tab(this.label, this.icon, this.activeIcon, this.path, this.gradient);
}
