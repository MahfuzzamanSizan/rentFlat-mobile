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

class _PhoneScreenState extends ConsumerState<PhoneScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  String get _formattedPhone {
    final digits = _phoneController.text.trim();
    if (digits.startsWith('0')) return '+880${digits.substring(1)}';
    if (digits.startsWith('+880')) return digits;
    return '+880$digits';
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).sendOtp(_formattedPhone);
      if (mounted) context.push('/auth/otp', extra: _formattedPhone);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Top decoration
                Container(
                  height: 240,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.home_rounded, size: 44, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'RentEase',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'House Rent Management',
                          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                // Form
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Welcome back!',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Enter your phone number to continue.',
                          style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 28),
                        // Phone field
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                decoration: const BoxDecoration(
                                  border: Border(right: BorderSide(color: AppColors.divider)),
                                ),
                                child: Row(
                                  children: [
                                    const Text('🇧🇩', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 6),
                                    const Text('+880', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  maxLength: 11,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  decoration: const InputDecoration(
                                    hintText: '01XXXXXXXXX',
                                    filled: false,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                    counterText: '',
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Phone number is required';
                                    if (v.length < 10) return 'Enter a valid phone number';
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
                            'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                            style: TextStyle(color: AppColors.textHint, fontSize: 12, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 32),
                        // Features highlight
                        _FeatureRow(icon: Icons.verified_outlined, text: 'KYC-verified owners & tenants'),
                        const SizedBox(height: 10),
                        _FeatureRow(icon: Icons.lock_outline_rounded, text: 'Secure digital lease agreements'),
                        const SizedBox(height: 10),
                        _FeatureRow(icon: Icons.chat_bubble_outline_rounded, text: 'In-app messaging with owners'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
