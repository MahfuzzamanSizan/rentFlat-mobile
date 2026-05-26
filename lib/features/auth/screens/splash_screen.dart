import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _contentCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _dotsCtrl;

  late final Animation<double> _blobFloat1;
  late final Animation<double> _blobFloat2;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _glowScale;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: true);
    _blobFloat1 = Tween<double>(begin: -16, end: 16).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _blobFloat2 = Tween<double>(begin: 12, end: -12).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 950));
    _logoScale = Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0, 0.4)));

    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _contentFade =
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero).animate(
            CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _glowOpacity = Tween<double>(begin: 0.15, end: 0.5).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _glowScale = Tween<double>(begin: 0.88, end: 1.12).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _dotsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();

    _entryCtrl.forward().then((_) => _contentCtrl.forward());
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      ref.read(authProvider.notifier).initialize(),
      Future.delayed(const Duration(milliseconds: 3000)),
    ]);
    if (!mounted) return;
    final s = ref.read(authProvider);
    if (s.status == AuthStatus.authenticated) {
      context.go(s.user!.isOwner ? '/owner' : '/tenant');
    } else {
      context.go('/auth/phone');
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _entryCtrl.dispose();
    _contentCtrl.dispose();
    _pulseCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background gradient
          Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.splashGradient)),

          // ── Dot grid (subtle texture)
          CustomPaint(
            size: size,
            painter: _DotGridPainter(),
          ),

          // ── Large teal blob — top right
          AnimatedBuilder(
            animation: _blobFloat1,
            builder: (_, __) => Positioned(
              top: -90 + _blobFloat1.value,
              right: -70,
              child: _GlowBlob(
                  size: size.width * 0.68,
                  color: AppColors.secondary,
                  opacity: 0.22),
            ),
          ),

          // ── Large violet blob — bottom left
          AnimatedBuilder(
            animation: _blobFloat2,
            builder: (_, __) => Positioned(
              bottom: -100 + _blobFloat2.value,
              left: -60,
              child: _GlowBlob(
                  size: size.width * 0.72,
                  color: AppColors.violet,
                  opacity: 0.18),
            ),
          ),

          // ── Small rose blob — mid left
          AnimatedBuilder(
            animation: _blobFloat2,
            builder: (_, __) => Positioned(
              top: size.height * 0.32 + _blobFloat2.value * 0.6,
              left: 10,
              child: _GlowBlob(size: 90, color: AppColors.rose, opacity: 0.14),
            ),
          ),

          // ── Small amber blob — upper right
          AnimatedBuilder(
            animation: _blobFloat1,
            builder: (_, __) => Positioned(
              top: size.height * 0.18 + _blobFloat1.value * 0.4,
              right: 24,
              child:
                  _GlowBlob(size: 60, color: AppColors.accent, opacity: 0.22),
            ),
          ),

          // ── Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // ── Glow ring + Logo
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, child) => Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow ring
                      Transform.scale(
                        scale: _glowScale.value,
                        child: Opacity(
                          opacity: _glowOpacity.value,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [
                                AppColors.secondary.withOpacity(0.8),
                                AppColors.violet.withOpacity(0.3),
                                Colors.transparent,
                              ], stops: const [
                                0.0,
                                0.5,
                                1.0
                              ]),
                            ),
                          ),
                        ),
                      ),
                      child!,
                    ],
                  ),
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(34),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.45),
                              blurRadius: 48,
                              spreadRadius: 6,
                              offset: const Offset(0, 16),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ShaderMask(
                              shaderCallback: (b) =>
                                  AppColors.primaryGradient.createShader(b),
                              child: const Icon(Icons.home_rounded,
                                  size: 58, color: Colors.white),
                            ),
                            Positioned(
                              bottom: 17,
                              right: 17,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  gradient: AppColors.tealGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Brand name + tagline
                FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [Colors.white, Color(0xFFBAE6FD)],
                          ).createShader(b),
                          child: const Text(
                            'RentEase',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.18)),
                            color: Colors.white.withOpacity(0.08),
                          ),
                          child: Text(
                            'Your smart home rental companion',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // ── Feature pills
                FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: const [
                          _FeaturePill(
                            icon: Icons.verified_rounded,
                            label: 'KYC Verified',
                            color: AppColors.secondary,
                          ),
                          _FeaturePill(
                            icon: Icons.lock_rounded,
                            label: 'Secure Leases',
                            color: AppColors.violet,
                          ),
                          _FeaturePill(
                            icon: Icons.chat_bubble_rounded,
                            label: 'In-app Chat',
                            color: AppColors.rose,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // ── Animated loading dots
                FadeTransition(
                  opacity: _contentFade,
                  child: _AnimatedDots(controller: _dotsCtrl),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting widgets ─────────────────────────────────────────────────────

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _GlowBlob(
      {required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          color.withOpacity(opacity),
          color.withOpacity(0),
        ]),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FeaturePill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.5)),
        color: color.withOpacity(0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1)),
        ],
      ),
    );
  }
}

class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (controller.value - i * 0.25).clamp(0.0, 1.0);
            final brightness = (sin(phase * pi * 2) * 0.5 + 0.5).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 8 + brightness * 2,
              height: 8 + brightness * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(
                  Colors.white.withOpacity(0.2),
                  AppColors.secondary,
                  brightness,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.045)
      ..style = PaintingStyle.fill;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
