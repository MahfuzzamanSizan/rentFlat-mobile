import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final String? devOtp;
  const OtpScreen({super.key, required this.phone, this.devOtp});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with TickerProviderStateMixin {
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  int _resendTimer = 60;
  Timer? _timer;
  String _otp = '';
  String _selectedRole = 'TENANT';

  late final AnimationController _entryCtrl;
  late final AnimationController _bgCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _blobFloat;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4500))
      ..repeat(reverse: true);
    _blobFloat = Tween<double>(begin: -14, end: 14).animate(
        CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _headerFade =
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0, 0.6));
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.12), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _entryCtrl,
                curve: const Interval(0, 0.6, curve: Curves.easeOut)));
    _cardFade =
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.2, 1.0));
    _cardSlide =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _entryCtrl,
                curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)));

    _entryCtrl.forward();
    _startTimer();

    if (widget.devOtp != null) {
      _otp = widget.devOtp!;
      _otpController.text = widget.devOtp!;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendTimer = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimer == 0) {
        t.cancel();
      } else {
        setState(() => _resendTimer--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _nameController.dispose();
    _entryCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otp.length < 6) {
      _snack('Enter the 6-digit OTP');
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      _snack('Please enter your full name');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await ref.read(authProvider.notifier).verifyOtp(
            widget.phone,
            _otp,
            role: _selectedRole,
            fullName: _nameController.text.trim(),
          );
      if (mounted) {
        final role = result['role'] as String? ?? _selectedRole;
        context.go(role == 'OWNER' ? '/owner' : '/tenant');
      }
    } catch (e) {
      if (mounted) {
        _snack(e.toString(), error: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    try {
      final newDevOtp =
          await ref.read(authProvider.notifier).sendOtp(widget.phone);
      _startTimer();
      if (mounted) {
        if (newDevOtp != null) {
          _otp = newDevOtp;
          _otpController.text = newDevOtp;
        }
        _snack('OTP resent successfully');
      }
    } catch (e) {
      if (mounted) _snack(e.toString(), error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background
          Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.splashGradient)),

          // ── Blobs
          AnimatedBuilder(
            animation: _blobFloat,
            builder: (_, __) => Positioned(
              top: -60 + _blobFloat.value,
              right: -50,
              child: _Blob(
                  size: size.width * 0.55,
                  color: AppColors.violet,
                  opacity: 0.2),
            ),
          ),
          AnimatedBuilder(
            animation: _blobFloat,
            builder: (_, __) => Positioned(
              top: size.height * 0.2 - _blobFloat.value * 0.5,
              left: -30,
              child: _Blob(
                  size: size.width * 0.4,
                  color: AppColors.rose,
                  opacity: 0.12),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ── Header
                    FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                          child: Column(
                            children: [
                              // Back button
                              Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () => context.pop(),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.2)),
                                    ),
                                    child: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: Colors.white,
                                        size: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Shield icon
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF5B21B6),
                                      Color(0xFF8B5CF6)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.violet.withOpacity(0.45),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                    Icons.shield_rounded,
                                    color: Colors.white,
                                    size: 36),
                              ),
                              const SizedBox(height: 16),
                              ShaderMask(
                                shaderCallback: (b) => const LinearGradient(
                                  colors: [Colors.white, Color(0xFFE9D5FF)],
                                ).createShader(b),
                                child: const Text(
                                  'Verify Phone',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.7)),
                                  children: [
                                    const TextSpan(
                                        text: 'We sent a code to\n'),
                                    TextSpan(
                                      text: widget.phone,
                                      style: const TextStyle(
                                        color: Color(0xFFE9D5FF),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
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
                          padding:
                              const EdgeInsets.fromLTRB(24, 28, 24, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Handle
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: AppColors.divider,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),

                              // Dev OTP banner
                              if (widget.devOtp != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 11),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFFBEB),
                                        Color(0xFFFEF3C7)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.accent
                                            .withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          gradient:
                                              AppColors.accentGradient,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                            Icons.info_rounded,
                                            size: 16,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Dev Mode OTP',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                          Text(widget.devOtp!,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                  color:
                                                      AppColors.warning,
                                                  letterSpacing: 4)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // OTP field label
                              const Text('Enter OTP',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 12),

                              // OTP pin field
                              PinCodeTextField(
                                appContext: context,
                                length: 6,
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                animationType: AnimationType.scale,
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(14),
                                  fieldHeight: 56,
                                  fieldWidth: 46,
                                  activeColor: AppColors.violet,
                                  inactiveColor: AppColors.divider,
                                  selectedColor: AppColors.secondary,
                                  activeFillColor: AppColors.violet
                                      .withOpacity(0.06),
                                  inactiveFillColor: AppColors.background,
                                  selectedFillColor: AppColors.secondary
                                      .withOpacity(0.05),
                                  borderWidth: 2,
                                ),
                                enableActiveFill: true,
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                                onChanged: (v) => _otp = v,
                              ),

                              const SizedBox(height: 6),

                              // Resend timer
                              Center(
                                child: _resendTimer > 0
                                    ? Text(
                                        'Resend OTP in ${_resendTimer}s',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: _resend,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient:
                                                AppColors.violetGradient,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Resend OTP',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13),
                                          ),
                                        ),
                                      ),
                              ),

                              const SizedBox(height: 24),

                              // Full name
                              const Text('Full Name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization:
                                    TextCapitalization.words,
                                decoration: InputDecoration(
                                  hintText: 'Enter your full name',
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(10),
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.person_rounded,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Role selection
                              const Text('I am a',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                      child: _RoleCard(
                                    label: 'Tenant',
                                    subtitle: 'Looking for a home',
                                    icon: Icons.person_search_rounded,
                                    gradient: AppColors.tealGradient,
                                    selected: _selectedRole == 'TENANT',
                                    onTap: () => setState(
                                        () => _selectedRole = 'TENANT'),
                                  )),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: _RoleCard(
                                    label: 'Owner',
                                    subtitle: 'Listing property',
                                    icon: Icons.home_work_rounded,
                                    gradient: AppColors.violetGradient,
                                    selected: _selectedRole == 'OWNER',
                                    onTap: () => setState(
                                        () => _selectedRole = 'OWNER'),
                                  )),
                                ],
                              ),

                              const SizedBox(height: 28),

                              PrimaryButton(
                                label: 'Verify & Continue',
                                onPressed: _verify,
                                isLoading: _isLoading,
                                icon: Icons.arrow_forward_rounded,
                              ),
                            ],
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

class _RoleCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final bool selected;
  final VoidCallback onTap;
  const _RoleCard(
      {required this.label,
      required this.subtitle,
      required this.icon,
      required this.gradient,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: selected ? gradient : null,
          color: selected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? gradient.colors.last.withOpacity(0.6)
                : AppColors.divider,
            width: selected ? 0 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 30,
                color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: selected
                        ? Colors.white.withOpacity(0.75)
                        : AppColors.textHint,
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
          ],
        ),
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
