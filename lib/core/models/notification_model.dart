import 'package:equatable/equatable.dart';

enum NotificationType { listing, inquiry, lease, payment, system }

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final String? referenceId;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.referenceId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'],
        userId: json['userId'],
        title: json['title'],
        body: json['body'],
        type: NotificationType.values.firstWhere(
          (e) => e.name.toUpperCase() == json['type'],
          orElse: () => NotificationType.system,
        ),
        isRead: json['isRead'] ?? false,
        referenceId: json['referenceId'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  @override
  List<Object?> get props => [id, isRead];
}
