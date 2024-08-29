import 'package:app_chat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//todo: tirar esses "?"

class MessageModel {
  String? id;
  String senderId;
  UserModel? user;
  String? message;
  String? audioUrl;
  String? videoUrl;
  String? imageUrl;
  Timestamp createdAt;
  bool isDownloading;
  bool hasError;
  String? path;
  bool needToDownload;
  bool isReadByMe;
  MessageModel({
    this.id,
    this.user,
    required this.senderId,
    this.message,
    this.audioUrl,
    this.videoUrl,
    this.imageUrl,
    this.path,
    this.isDownloading = false,
    this.hasError = false,
    this.needToDownload = false,
    this.isReadByMe = false,
    required this.createdAt,
  });

  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    return MessageModel(
      id: doc.id,
      senderId: doc['senderId'],
      message: doc['message'],
      audioUrl: doc['audioUrl'],
      imageUrl: doc['imageUrl'],
      videoUrl: doc['videoUrl'],
      createdAt: doc['createdAt'],
    );
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'],
      message: map['message'],
      createdAt: map['createdAt'],
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
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
