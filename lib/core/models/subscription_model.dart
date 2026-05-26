import 'package:equatable/equatable.dart';

enum SubscriptionStatus { active, expired, cancelled }

class SubscriptionPlanModel extends Equatable {
  final String id;
  final String name;
  final String targetRole;
  final double price;
  final int durationDays;
  final int maxListings;
  final int maxPhotos;
  final int boostCredits;
  final int maxContacts;
  final List<String> features;
  final bool isActive;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.targetRole,
    required this.price,
    required this.durationDays,
    required this.maxListings,
    required this.maxPhotos,
    required this.boostCredits,
    required this.maxContacts,
    required this.features,
    required this.isActive,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) => SubscriptionPlanModel(
        id: json['id'],
        name: json['name'],
        targetRole: json['targetRole'],
        price: (json['price'] as num).toDouble(),
        durationDays: json['durationDays'],
        maxListings: json['maxListings'] ?? 0,
        maxPhotos: json['maxPhotos'] ?? 0,
        boostCredits: json['boostCredits'] ?? 0,
        maxContacts: json['maxContacts'] ?? 0,
        features: List<String>.from(json['features'] ?? []),
        isActive: json['isActive'] ?? true,
      );

  String get formattedPrice => price == 0 ? 'Free' : '৳${price.toStringAsFixed(0)}/mo';
  bool get isFree => price == 0;

  @override
  List<Object?> get props => [id, name, price];
}

class SubscriptionModel extends Equatable {
  final String id;
  final String userId;
  final SubscriptionPlanModel plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.autoRenew,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) => SubscriptionModel(
        id: json['id'],
        userId: json['userId'],
        plan: SubscriptionPlanModel.fromJson(json['plan']),
        status: SubscriptionStatus.values.firstWhere(
          (e) => e.name.toUpperCase() == json['status'],
          orElse: () => SubscriptionStatus.expired,
        ),
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        autoRenew: json['autoRenew'] ?? false,
      );

  bool get isActive => status == SubscriptionStatus.active;
  int get daysLeft => endDate.difference(DateTime.now()).inDays;

  @override
  List<Object?> get props => [id, status];
}
