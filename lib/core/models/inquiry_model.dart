import 'package:equatable/equatable.dart';

enum InquiryStatus { pending, accepted, rejected, withdrawn }

class InquiryModel extends Equatable {
  final String id;
  final String tenantId;
  final String propertyId;
  final String ownerId;
  final String message;
  final InquiryStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  // Joined fields
  final String? propertyTitle;
  final String? propertyPhotoUrl;
  final double? propertyRent;
  final String? tenantName;
  final String? tenantPhotoUrl;
  final bool tenantVerified;
  final String? tenantOccupation;
  final double? tenantRating;

  const InquiryModel({
    required this.id,
    required this.tenantId,
    required this.propertyId,
    required this.ownerId,
    required this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.propertyTitle,
    this.propertyPhotoUrl,
    this.propertyRent,
    this.tenantName,
    this.tenantPhotoUrl,
    this.tenantVerified = false,
    this.tenantOccupation,
    this.tenantRating,
  });

  factory InquiryModel.fromJson(Map<String, dynamic> json) => InquiryModel(
        id: json['id'],
        tenantId: json['tenantId'],
        propertyId: json['propertyId'],
        ownerId: json['ownerId'],
        message: json['message'],
        status: InquiryStatus.values.firstWhere(
          (e) => e.name.toUpperCase() == json['status'],
          orElse: () => InquiryStatus.pending,
        ),
        createdAt: DateTime.parse(json['createdAt']),
        respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt']) : null,
        propertyTitle: json['propertyTitle'],
        propertyPhotoUrl: json['propertyPhotoUrl'],
        propertyRent: json['propertyRent']?.toDouble(),
        tenantName: json['tenantName'],
        tenantPhotoUrl: json['tenantPhotoUrl'],
        tenantVerified: json['tenantVerified'] ?? false,
        tenantOccupation: json['tenantOccupation'],
        tenantRating: json['tenantRating']?.toDouble(),
      );

  bool get isPending => status == InquiryStatus.pending;
  bool get isAccepted => status == InquiryStatus.accepted;

  @override
  List<Object?> get props => [id, status];
}
