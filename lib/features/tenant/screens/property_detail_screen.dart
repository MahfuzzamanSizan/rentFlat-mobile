import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/property_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../providers/property_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  PropertyModel? _property;
  bool _isLoading = true;
  int _currentImageIndex = 0;
  bool _sendingInquiry = false;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadProperty() async {
    final property = await ref.read(propertySearchProvider.notifier).getProperty(widget.propertyId);
    if (mounted) setState(() {
      _property = property;
      _isLoading = false;
    });
  }

  Future<void> _sendInquiry() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write a message to the owner')),
      );
      return;
    }
    setState(() => _sendingInquiry = true);
    try {
      await ApiService.instance.post(ApiConstants.inquiries, data: {
        'propertyId': widget.propertyId,
        'message': _messageController.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inquiry sent! Owner will respond soon.'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingInquiry = false);
    }
  }

  void _showInquirySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send Inquiry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Introduce yourself to the owner', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Hi, I am interested in this property. I am a working professional...',
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Send Interest',
              onPressed: _sendInquiry,
              isLoading: _sendingInquiry,
              icon: Icons.send_rounded,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isShortlisted = _property != null &&
        ref.watch(shortlistProvider).contains(_property!.id);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _property == null
              ? const Center(child: Text('Property not found'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 280,
                      pinned: true,
                      backgroundColor: AppColors.primary,
                      actions: [
                        IconButton(
                          icon: Icon(
                            isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                            color: isShortlisted ? AppColors.accent : Colors.white,
                          ),
                          onPressed: () =>
                              ref.read(shortlistProvider.notifier).toggle(_property!.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: _buildImageGallery(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildDetails(),
                    ),
                  ],
                ),
      bottomNavigationBar: _property != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildImageGallery() {
    final photos = _property!.photoUrls;
    if (photos.isEmpty) {
      return Container(color: AppColors.background, child: const Icon(Icons.home_outlined, size: 80, color: AppColors.textHint));
    }
    return Stack(
      children: [
        PageView.builder(
          itemCount: photos.length,
          onPageChanged: (i) => setState(() => _currentImageIndex = i),
          itemBuilder: (_, i) => CachedNetworkImage(
            imageUrl: photos[i],
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.shimmerBase),
            errorWidget: (_, __, ___) => Container(color: AppColors.background),
          ),
        ),
        if (photos.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                photos.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _currentImageIndex == i ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _currentImageIndex == i ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetails() {
    final p = _property!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(p.area.fullName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ]),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(p.formattedRent, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20)),
                  if (p.isNegotiable) const Text('Negotiable', style: TextStyle(color: AppColors.success, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(icon: Icons.bed_outlined, value: '${p.bedrooms}', label: 'Beds'),
              const SizedBox(width: 12),
              _StatChip(icon: Icons.bathtub_outlined, value: '${p.bathrooms}', label: 'Baths'),
              if (p.sizeSqft != null) ...[
                const SizedBox(width: 12),
                _StatChip(icon: Icons.square_foot_outlined, value: '${p.sizeSqft!.round()}', label: 'sqft'),
              ],
              if (p.floorNumber != null) ...[
                const SizedBox(width: 12),
                _StatChip(icon: Icons.layers_outlined, value: '${p.floorNumber}', label: 'Floor'),
              ],
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Owner card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: p.ownerPhotoUrl != null ? CachedNetworkImageProvider(p.ownerPhotoUrl!) : null,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: p.ownerPhotoUrl == null ? const Icon(Icons.person_rounded, color: AppColors.primary) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(p.ownerName ?? 'Property Owner', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        if (p.ownerVerified) const Icon(Icons.verified_rounded, size: 14, color: AppColors.secondary),
                      ]),
                      if (p.ownerRating != null)
                        Row(children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
                          Text(' ${p.ownerRating!.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Description
          const Text('About this Property', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(p.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),

          if (p.amenities.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: p.amenities.map((a) => Chip(
                label: Text(a, style: const TextStyle(fontSize: 12)),
                avatar: const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
              )).toList(),
            ),
          ],

          if (p.houseRules != null && p.houseRules!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('House Rules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.rule_rounded, size: 18, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(child: Text(p.houseRules!, style: const TextStyle(fontSize: 13, height: 1.5))),
                ],
              ),
            ),
          ],

          if (p.availableFrom != null) ...[
            const SizedBox(height: 20),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Available from ${DateFormat('dd MMM yyyy').format(p.availableFrom!)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ]),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              label: 'Send Interest',
              onPressed: _showInquirySheet,
              icon: Icons.send_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatChip({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
