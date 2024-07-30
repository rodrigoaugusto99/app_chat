import 'package:app_chat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String id;
  List<String> userIds;
  List<UserModel> users;
  // String otherUserId;
  // String message;
  Timestamp createdAt;
  ChatModel({
    required this.id,
    required this.userIds,
    required this.users,
    // required this.otherUserId,
    // required this.message,
    required this.createdAt,
  });

  factory ChatModel.fromDocument(DocumentSnapshot doc) {
    return ChatModel(
      id: doc.id,
      // senderId: doc['senderId'],
      // message: doc['message'],
      createdAt: doc['createdAt'],
      users: [],
      userIds: List<String>.from(doc['userIds'] as List<dynamic>),
    );
  }
}
