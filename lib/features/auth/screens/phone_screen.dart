import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final AnimationController _bgFloatCtrl;
  late final AnimationController _cardSlideCtrl;
  late final AnimationController _headerCtrl;

  late final Animation<double> _blob1Float;
  late final Animation<double> _blob2Float;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  String get _formattedPhone {
    final digits = _phoneController.text.trim();
    if (digits.startsWith('0')) return '+880${digits.substring(1)}';
    if (digits.startsWith('+880')) return digits;
    return '+880$digits';
  }

  @override
  void initState() {
    super.initState();

    _bgFloatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 5000))
      ..repeat(reverse: true);
    _blob1Float = Tween<double>(begin: -18, end: 18).animate(
        CurvedAnimation(parent: _bgFloatCtrl, curve: Curves.easeInOut));
    _blob2Float = Tween<double>(begin: 12, end: -12).animate(
        CurvedAnimation(parent: _bgFloatCtrl, curve: Curves.easeInOut));

    _cardSlideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _cardSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
            CurvedAnimation(parent: _cardSlideCtrl, curve: Curves.easeOutCubic));
    _cardFade = CurvedAnimation(parent: _cardSlideCtrl, curve: Curves.easeOut);

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _headerFade =
        CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
            CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

    _headerCtrl.forward().then((_) => _cardSlideCtrl.forward());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _bgFloatCtrl.dispose();
    _cardSlideCtrl.dispose();
    _headerCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final devOtp =
          await ref.read(authProvider.notifier).sendOtp(_formattedPhone);
      if (mounted) {
        context.push('/auth/otp', extra: {'phone': _formattedPhone, 'devOtp': devOtp});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full-screen gradient background
          Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.splashGradient)),

          // ── Dot grid
          CustomPaint(size: size, painter: _DotPainter()),

          // ── Floating blobs
          AnimatedBuilder(
            animation: _blob1Float,
            builder: (_, __) => Positioned(
              top: -60 + _blob1Float.value,
              right: -50,
              child: _Blob(
                  size: size.width * 0.6,
                  color: AppColors.secondary,
                  opacity: 0.2),
            ),
          ),
          AnimatedBuilder(
            animation: _blob2Float,
            builder: (_, __) => Positioned(
              top: size.height * 0.28 + _blob2Float.value,
              left: -40,
              child: _Blob(
                  size: size.width * 0.45,
                  color: AppColors.violet,
                  opacity: 0.14),
            ),
          ),
          AnimatedBuilder(
            animation: _blob1Float,
            builder: (_, __) => Positioned(
              top: size.height * 0.12 + _blob1Float.value * 0.5,
              right: 20,
              child:
                  _Blob(size: 55, color: AppColors.accent, opacity: 0.25),
            ),
          ),

          // ── Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ── Header area (gradient section)
                    FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                          child: Column(
                            children: [
                              // Logo
                              Container(
                                width: 78,
                                height: 78,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.secondary.withOpacity(0.4),
                                      blurRadius: 32,
                                      spreadRadius: 4,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (b) => AppColors
                                          .primaryGradient
                                          .createShader(b),
                                      child: const Icon(Icons.home_rounded,
                                          size: 42, color: Colors.white),
                                    ),
                                    Positioned(
                                      bottom: 14,
                                      right: 14,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                          gradient: AppColors.tealGradient,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check_rounded,
                                            size: 11, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ShaderMask(
                                shaderCallback: (b) => const LinearGradient(
                                  colors: [Colors.white, Color(0xFFBAE6FD)],
                                ).createShader(b),
                                child: const Text(
                                  'RentEase',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Your smart home rental companion',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── White card
                    FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: _cardSlide,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(36)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Pull handle
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      margin:
                                          const EdgeInsets.only(bottom: 24),
                                      decoration: BoxDecoration(
                                        color: AppColors.divider,
                                        borderRadius:
                                            BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),

                                  // Title
                                  const Text(
                                    'Welcome back!',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Enter your phone number to get started.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          AppColors.textSecondary,
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // Phone field
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: AppColors.divider, width: 1.5),
                                      color: AppColors.background,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 16),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                                right: BorderSide(
                                                    color: AppColors.divider,
                                                    width: 1.5)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Text('🇧🇩',
                                                  style:
                                                      TextStyle(fontSize: 20)),
                                              const SizedBox(width: 6),
                                              ShaderMask(
                                                shaderCallback: (b) =>
                                                    AppColors.primaryGradient
                                                        .createShader(b),
                                                child: const Text(
                                                  '+880',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _phoneController,
                                            keyboardType:
                                                TextInputType.phone,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            maxLength: 11,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                            decoration: const InputDecoration(
                                              hintText: '01XXXXXXXXX',
                                              hintStyle: TextStyle(
                                                  color: AppColors.textHint,
                                                  fontWeight: FontWeight.w400),
                                              filled: false,
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 16),
                                              counterText: '',
                                            ),
                                            validator: (v) {
                                              if (v == null || v.isEmpty)
                                                return 'Phone number is required';
                                              if (v.length < 10)
                                                return 'Enter a valid phone number';
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  PrimaryButton(
                                    label: 'Send OTP',
                                    onPressed: _sendOtp,
                                    isLoading: _isLoading,
                                    icon: Icons.arrow_forward_rounded,
                                  ),

                                  const SizedBox(height: 20),

                                  Center(
                                    child: Text(
                                      'By continuing, you agree to our Terms & Privacy Policy',
                                      style: TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 12,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  const SizedBox(height: 28),
                                  const _Divider(),
                                  const SizedBox(height: 20),

                                  // Feature highlights
                                  _FeatureRow(
                                    gradient: AppColors.tealGradient,
                                    icon: Icons.verified_rounded,
                                    title: 'KYC-verified owners',
                                    subtitle: 'Trusted & identity-checked landlords',
                                  ),
                                  const SizedBox(height: 14),
                                  _FeatureRow(
                                    gradient: AppColors.violetGradient,
                                    icon: Icons.article_rounded,
                                    title: 'Digital lease agreements',
                                    subtitle: 'Sign and manage contracts online',
                                  ),
                                  const SizedBox(height: 14),
                                  _FeatureRow(
                                    gradient: AppColors.roseGradient,
                                    icon: Icons.chat_bubble_rounded,
                                    title: 'In-app messaging',
                                    subtitle: 'Chat directly with property owners',
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Blob({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
            colors: [color.withOpacity(opacity), color.withOpacity(0)]),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Container(height: 1, color: AppColors.divider)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('Why RentEase?',
            style: TextStyle(
                color: AppColors.textHint,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ),
      Expanded(child: Container(height: 1, color: AppColors.divider)),
    ]);
  }
}

class _FeatureRow extends StatelessWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureRow(
      {required this.gradient,
      required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += 28) {
      for (double y = 0; y < size.height * 0.55; y += 28) {
        canvas.drawCircle(Offset(x, y), 1.4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
