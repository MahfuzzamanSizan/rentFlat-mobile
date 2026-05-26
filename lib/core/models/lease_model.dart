import 'package:equatable/equatable.dart';

enum LeaseStatus { draft, active, terminated, expired }
enum PaymentMethod { bkash, nagad, card, cash }
enum PaymentStatus { pending, paid, overdue, waived }

class LeaseModel extends Equatable {
  final String id;
  final String propertyId;
  final String tenantId;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;
  final double rentAmount;
  final double securityDeposit;
  final int rentDueDay;
  final LeaseStatus status;
  final DateTime? ownerSignedAt;
  final DateTime? tenantSignedAt;
  final String? terms;
  final DateTime createdAt;

  // Joined
  final String? propertyTitle;
  final String? propertyAddress;
  final String? tenantName;
  final String? ownerName;

  const LeaseModel({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.rentAmount,
    required this.securityDeposit,
    required this.rentDueDay,
    required this.status,
    this.ownerSignedAt,
    this.tenantSignedAt,
    this.terms,
    required this.createdAt,
    this.propertyTitle,
    this.propertyAddress,
    this.tenantName,
    this.ownerName,
  });

  factory LeaseModel.fromJson(Map<String, dynamic> json) => LeaseModel(
        id: json['id'],
        propertyId: json['propertyId'],
        tenantId: json['tenantId'],
        ownerId: json['ownerId'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        rentAmount: (json['rentAmount'] as num).toDouble(),
        securityDeposit: (json['securityDeposit'] as num).toDouble(),
        rentDueDay: json['rentDueDay'],
        status: LeaseStatus.values.firstWhere(
          (e) => e.name.toUpperCase() == json['status'],
          orElse: () => LeaseStatus.draft,
        ),
        ownerSignedAt: json['ownerSignedAt'] != null ? DateTime.parse(json['ownerSignedAt']) : null,
        tenantSignedAt: json['tenantSignedAt'] != null ? DateTime.parse(json['tenantSignedAt']) : null,
        terms: json['terms'],
        createdAt: DateTime.parse(json['createdAt']),
        propertyTitle: json['propertyTitle'],
        propertyAddress: json['propertyAddress'],
        tenantName: json['tenantName'],
        ownerName: json['ownerName'],
      );

  bool get isActive => status == LeaseStatus.active;
  bool get needsTenantSignature => ownerSignedAt != null && tenantSignedAt == null;

  @override
  List<Object?> get props => [id, status];
}

class RentPaymentModel extends Equatable {
  final String id;
  final String leaseId;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidAt;
  final PaymentMethod? paymentMethod;
  final String? transactionReference;
  final PaymentStatus status;
  final String? receiptUrl;

  const RentPaymentModel({
    required this.id,
    required this.leaseId,
    required this.amount,
    required this.dueDate,
    this.paidAt,
    this.paymentMethod,
    this.transactionReference,
    required this.status,
    this.receiptUrl,
  });

  factory RentPaymentModel.fromJson(Map<String, dynamic> json) => RentPaymentModel(
        id: json['id'],
        leaseId: json['leaseId'],
        amount: (json['amount'] as num).toDouble(),
        dueDate: DateTime.parse(json['dueDate']),
        paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
        paymentMethod: json['paymentMethod'] != null
            ? PaymentMethod.values.firstWhere(
                (e) => e.name.toUpperCase() == json['paymentMethod'],
                orElse: () => PaymentMethod.cash,
              )
            : null,
        transactionReference: json['transactionReference'],
        status: PaymentStatus.values.firstWhere(
          (e) => e.name.toUpperCase() == json['status'],
          orElse: () => PaymentStatus.pending,
        ),
        receiptUrl: json['receiptUrl'],
      );

  bool get isPaid => status == PaymentStatus.paid;
  bool get isOverdue => status == PaymentStatus.overdue;
  String get formattedAmount => '৳${amount.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [id, status];
}
