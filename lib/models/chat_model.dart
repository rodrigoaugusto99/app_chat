import 'package:app_chat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String id;
  List<String> userIds;
  List<UserModel> users;
  String chatName;
  // String otherUserId;
  // String message;
  Timestamp createdAt;
  ChatModel({
    required this.id,
    required this.userIds,
    required this.users,
    required this.chatName,
    // required this.otherUserId,
    // required this.message,
    required this.createdAt,
  });

//todo: logica de atribuir os users e chat name aqui? nao ne, SOLID !!
  factory ChatModel.fromDocument(DocumentSnapshot doc) {
    return ChatModel(
      id: doc.id,
      // senderId: doc['senderId'],
      // message: doc['message'],
      createdAt: doc['createdAt'],
      users: [],
      chatName: '',
      userIds: List<String>.from(doc['userIds'] as List<dynamic>),
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
