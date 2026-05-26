import 'package:equatable/equatable.dart';

enum UserRole { tenant, owner, admin }
enum KycStatus { pending, verified, rejected }

class UserModel extends Equatable {
  final String id;
  final String phone;
  final String? email;
  final String fullName;
  final UserRole role;
  final KycStatus kycStatus;
  final String? nidDocumentUrl;
  final String? profilePhotoUrl;
  final bool isActive;
  final String? subscriptionId;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.phone,
    this.email,
    required this.fullName,
    required this.role,
    required this.kycStatus,
    this.nidDocumentUrl,
    this.profilePhotoUrl,
    required this.isActive,
    this.subscriptionId,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      email: json['email'],
      fullName: json['fullName'],
      role: UserRole.values.firstWhere(
        (e) => e.name.toUpperCase() == json['role'],
        orElse: () => UserRole.tenant,
      ),
      kycStatus: KycStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == json['kycStatus'],
        orElse: () => KycStatus.pending,
      ),
      nidDocumentUrl: json['nidDocumentUrl'],
      profilePhotoUrl: json['profilePhotoUrl'],
      isActive: json['active'] ?? json['isActive'] ?? true,
      subscriptionId: json['subscriptionId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'email': email,
        'fullName': fullName,
        'role': role.name.toUpperCase(),
        'kycStatus': kycStatus.name.toUpperCase(),
        'profilePhotoUrl': profilePhotoUrl,
        'isActive': isActive,
      };

  bool get isOwner => role == UserRole.owner;
  bool get isTenant => role == UserRole.tenant;
  bool get isKycVerified => kycStatus == KycStatus.verified;

  @override
  List<Object?> get props => [id, phone, fullName, role, kycStatus];
}
