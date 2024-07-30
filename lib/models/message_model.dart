import 'package:app_chat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? id;
  String senderId;
  UserModel? user;
  String text;
  Timestamp createdAt;
  MessageModel({
    this.id,
    this.user,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    return MessageModel(
      id: doc.id,
      senderId: doc['senderId'],
      text: doc['message'],
      createdAt: doc['createdAt'],
    );
  }
}
