import 'package:equatable/equatable.dart';

class ChatThreadModel extends Equatable {
  final String threadId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final String propertyId;
  final String propertyTitle;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const ChatThreadModel({
    required this.threadId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    required this.propertyId,
    required this.propertyTitle,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) => ChatThreadModel(
        threadId: json['threadId'],
        otherUserId: json['otherUserId'],
        otherUserName: json['otherUserName'],
        otherUserPhotoUrl: json['otherUserPhotoUrl'],
        propertyId: json['propertyId'],
        propertyTitle: json['propertyTitle'],
        lastMessage: json['lastMessage'],
        lastMessageAt: DateTime.parse(json['lastMessageAt']),
        unreadCount: json['unreadCount'] ?? 0,
      );

  @override
  List<Object?> get props => [threadId];
}

enum MessageType { text, image, system }

class ChatMessageModel extends Equatable {
  final String id;
  final String threadId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final bool isRead;

  const ChatMessageModel({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
        id: json['id'],
        threadId: json['threadId'],
        senderId: json['senderId'],
        content: json['content'],
        type: MessageType.values.firstWhere(
          (e) => e.name.toUpperCase() == json['type'],
          orElse: () => MessageType.text,
        ),
        createdAt: DateTime.parse(json['createdAt']),
        isRead: json['isRead'] ?? false,
      );

  @override
  List<Object?> get props => [id];
}
