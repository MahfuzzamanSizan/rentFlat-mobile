import 'package:equatable/equatable.dart';

enum PropertyType { apartment, sublet, mess, bachelor, family }
enum PropertyStatus { pending, approved, rented, rejected, expired }

class AreaModel {
  final String id;
  final String city;
  final String district;
  final String areaName;
  final String? subArea;
  final double? latitude;
  final double? longitude;

  const AreaModel({
    required this.id,
    required this.city,
    required this.district,
    required this.areaName,
    this.subArea,
    this.latitude,
    this.longitude,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) => AreaModel(
        id: json['id'],
        city: json['city'],
        district: json['district'],
        areaName: json['areaName'],
        subArea: json['subArea'],
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
      );

  String get fullName => subArea != null ? '$areaName, $subArea' : areaName;
}

class PropertyModel extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final AreaModel area;
  final double rentAmount;
  final bool isNegotiable;
  final PropertyType propertyType;
  final int bedrooms;
  final int bathrooms;
  final int? floorNumber;
  final double? sizeSqft;
  final DateTime? availableFrom;
  final PropertyStatus status;
  final bool isBoosted;
  final List<String> photoUrls;
  final String? videoUrl;
  final List<String> amenities;
  final String? houseRules;
  final int viewsCount;
  final int inquiriesCount;
  final DateTime createdAt;

  // Owner info (joined)
  final String? ownerName;
  final String? ownerPhotoUrl;
  final double? ownerRating;
  final bool ownerVerified;

  const PropertyModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.area,
    required this.rentAmount,
    required this.isNegotiable,
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    this.floorNumber,
    this.sizeSqft,
    this.availableFrom,
    required this.status,
    required this.isBoosted,
    required this.photoUrls,
    this.videoUrl,
    required this.amenities,
    this.houseRules,
    required this.viewsCount,
    required this.inquiriesCount,
    required this.createdAt,
    this.ownerName,
    this.ownerPhotoUrl,
    this.ownerRating,
    this.ownerVerified = false,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final areaJson = json['area'];
    return PropertyModel(
      id: json['id'],
      ownerId: json['ownerId'],
      title: json['title'],
      description: json['description'] ?? '',
      area: areaJson != null
          ? AreaModel.fromJson(areaJson as Map<String, dynamic>)
          : AreaModel(id: json['areaId'] ?? '', city: '', district: '', areaName: 'Unknown'),
      rentAmount: (json['rentAmount'] as num).toDouble(),
      isNegotiable: json['negotiable'] ?? json['isNegotiable'] ?? false,
      propertyType: PropertyType.values.firstWhere(
        (e) => e.name.toUpperCase() == json['propertyType'],
        orElse: () => PropertyType.apartment,
      ),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      floorNumber: json['floorNumber'],
      sizeSqft: json['sizeSqft']?.toDouble(),
      availableFrom: json['availableFrom'] != null ? DateTime.parse(json['availableFrom']) : null,
      status: PropertyStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == json['status'],
        orElse: () => PropertyStatus.pending,
      ),
      isBoosted: json['boosted'] ?? json['isBoosted'] ?? false,
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      videoUrl: json['videoUrl'],
      amenities: List<String>.from(json['amenities'] ?? []),
      houseRules: json['houseRules'],
      viewsCount: json['viewsCount'] ?? 0,
      inquiriesCount: json['inquiriesCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      ownerName: json['ownerName'],
      ownerPhotoUrl: json['ownerPhotoUrl'],
      ownerRating: json['ownerRating']?.toDouble(),
      ownerVerified: json['ownerVerified'] ?? false,
    );
  }

  String get formattedRent => '৳${rentAmount.toStringAsFixed(0)}/mo';
  String get propertyTypeLabel => propertyType.name[0].toUpperCase() + propertyType.name.substring(1);
  String get thumbnail => photoUrls.isNotEmpty ? photoUrls.first : '';

  @override
  List<Object?> get props => [id, title, rentAmount, status];
}

class PropertyFilter {
  final String? areaId;
  final double? minRent;
  final double? maxRent;
  final PropertyType? propertyType;
  final int? bedrooms;
  final int? bathrooms;
  final List<String> amenities;
  final String? sortBy;
  final String? keyword;

  const PropertyFilter({
    this.areaId,
    this.minRent,
    this.maxRent,
    this.propertyType,
    this.bedrooms,
    this.bathrooms,
    this.amenities = const [],
    this.sortBy,
    this.keyword,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    if (areaId != null) params['areaId'] = areaId;
    if (minRent != null) params['minRent'] = minRent;
    if (maxRent != null) params['maxRent'] = maxRent;
    if (propertyType != null) params['propertyType'] = propertyType!.name.toUpperCase();
    if (bedrooms != null) params['bedrooms'] = bedrooms;
    if (bathrooms != null) params['bathrooms'] = bathrooms;
    if (amenities.isNotEmpty) params['amenities'] = amenities.join(',');
    if (sortBy != null) params['sortBy'] = sortBy;
    if (keyword != null && keyword!.isNotEmpty) params['keyword'] = keyword;
    return params;
  }
}
