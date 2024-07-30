import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? id;
  String senderId;
  String message;
  Timestamp createdAt;
  MessageModel({
    this.id,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    return MessageModel(
      id: doc.id,
      senderId: doc['senderId'],
      message: doc['message'],
      createdAt: doc['createdAt'],
    );
  }
}
