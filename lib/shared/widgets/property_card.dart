import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/property_model.dart';
import '../../core/constants/app_colors.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;
  final bool showOwnerActions;
  final VoidCallback? onEdit;
  final VoidCallback? onBoost;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.showOwnerActions = false,
    this.onEdit,
    this.onBoost,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              _buildContentSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        SizedBox(
          height: 190,
          width: double.infinity,
          child: property.thumbnail.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: property.thumbnail,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.shimmerBase,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => _placeholderImage(),
                )
              : _placeholderImage(),
        ),
        // Gradient overlay for text readability
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
        ),
        // Rent badge - bottom right over image
        Positioned(
          bottom: 12,
          left: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      property.formattedRent,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    if (property.isNegotiable) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Nego',
                          style: TextStyle(color: AppColors.success, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Boosted badge
        if (property.isBoosted)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, size: 13, color: Colors.white),
                  SizedBox(width: 3),
                  Text('Featured', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        // Photo count
        if (property.photoUrls.length > 1)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library_outlined, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${property.photoUrls.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        // Status badge (for owners)
        if (showOwnerActions)
          Positioned(
            bottom: 12,
            right: 12,
            child: _statusBadge(),
          ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            property.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 13, color: AppColors.secondary),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  property.area.fullName,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Specs row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _SpecChip(icon: Icons.bed_rounded, label: '${property.bedrooms} Bed'),
              _SpecChip(icon: Icons.bathtub_rounded, label: '${property.bathrooms} Bath'),
              _SpecChip(
                icon: _typeIcon(property.propertyType),
                label: property.propertyTypeLabel,
              ),
              if (property.sizeSqft != null)
                _SpecChip(icon: Icons.square_foot_rounded, label: '${property.sizeSqft!.round()} sqft'),
            ],
          ),
          if (showOwnerActions) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                _MetaChip(icon: Icons.visibility_outlined, value: '${property.viewsCount}'),
                const SizedBox(width: 10),
                _MetaChip(icon: Icons.mail_outline_rounded, value: '${property.inquiriesCount}'),
                const Spacer(),
                if (onBoost != null)
                  _ActionBtn(
                    icon: Icons.bolt_rounded,
                    label: 'Boost',
                    color: AppColors.accent,
                    onTap: onBoost!,
                  ),
                const SizedBox(width: 6),
                if (onEdit != null)
                  _ActionBtn(
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    color: AppColors.primary,
                    onTap: onEdit!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge() {
    Color color;
    String label;
    switch (property.status) {
      case PropertyStatus.approved:
        color = AppColors.success;
        label = 'Active';
        break;
      case PropertyStatus.pending:
        color = AppColors.warning;
        label = 'Pending';
        break;
      case PropertyStatus.rented:
        color = AppColors.rented;
        label = 'Rented';
        break;
      case PropertyStatus.rejected:
        color = AppColors.error;
        label = 'Rejected';
        break;
      default:
        color = AppColors.expired;
        label = 'Expired';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  IconData _typeIcon(PropertyType type) {
    switch (type) {
      case PropertyType.apartment: return Icons.apartment_rounded;
      case PropertyType.sublet: return Icons.house_outlined;
      case PropertyType.mess: return Icons.people_rounded;
      case PropertyType.bachelor: return Icons.person_rounded;
      case PropertyType.family: return Icons.family_restroom_rounded;
    }
  }

  Widget _placeholderImage() {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: const Center(
        child: Icon(Icons.home_rounded, size: 64, color: AppColors.divider),
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String value;
  const _MetaChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textHint),
        const SizedBox(width: 3),
        Text(value, style: const TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
