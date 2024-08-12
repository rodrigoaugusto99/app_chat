import 'package:app_chat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? id;
  String senderId;
  UserModel? user;
  String? message;
  String? audioUrl;
  Timestamp createdAt;
  MessageModel({
    this.id,
    this.user,
    required this.senderId,
    this.message,
    this.audioUrl,
    required this.createdAt,
  });

  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    return MessageModel(
      id: doc.id,
      senderId: doc['senderId'],
      message: doc['message'],
      audioUrl: doc['audioUrl'],
      createdAt: doc['createdAt'],
    );
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'],
      message: map['message'],
      createdAt: map['createdAt'],
      audioUrl: map['audioUrl'],
    );
  }

  // factory ChatModel.fromMap(Map<String, dynamic> map) {
  //   return ChatModel(
  //     createdAt: map['createdAt'],
  //     users: [],
  //     chatName: '',
  //     userIds: map['userIds'],
  //   );
  // }
}
