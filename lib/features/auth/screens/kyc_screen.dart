import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/widgets/custom_button.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  File? _frontImage;
  File? _backImage;
  bool _isLoading = false;
  final _picker = ImagePicker();

  Future<void> _pickImage(bool isFront) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(picked.path);
        } else {
          _backImage = File(picked.path);
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both NID images')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final formData = FormData.fromMap({
        'frontImage': await MultipartFile.fromFile(_frontImage!.path, filename: 'nid_front.jpg'),
        'backImage': await MultipartFile.fromFile(_backImage!.path, filename: 'nid_back.jpg'),
      });
      await ApiService.instance.postFormData(ApiConstants.kyc, formData);
      await ref.read(authProvider.notifier).refreshProfile();
      if (mounted) {
        final user = ref.read(authProvider).user!;
        context.go(user.isOwner ? '/owner' : '/tenant');
      }
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

  void _skip() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      context.go(user.isOwner ? '/owner' : '/tenant');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('KYC Verification', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Upload your NID to get a verified badge. Verified users get more trust from owners and tenants.',
                        style: TextStyle(color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('NID Front Side', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              _ImageUploadBox(
                image: _frontImage,
                label: 'Tap to upload front',
                icon: Icons.credit_card_outlined,
                onTap: () => _pickImage(true),
              ),
              const SizedBox(height: 20),
              const Text('NID Back Side', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              _ImageUploadBox(
                image: _backImage,
                label: 'Tap to upload back',
                icon: Icons.credit_card_outlined,
                onTap: () => _pickImage(false),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Submit for Verification',
                onPressed: _submit,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
              SecondaryButton(label: 'Do it later', onPressed: _skip),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageUploadBox extends StatelessWidget {
  final File? image;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ImageUploadBox({
    required this.image,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image != null ? AppColors.success : AppColors.divider,
            width: 2,
            style: image != null ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(image!, fit: BoxFit.cover, width: double.infinity),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: AppColors.textHint),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('JPG or PNG', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                ],
              ),
      ),
    );
  }
}
