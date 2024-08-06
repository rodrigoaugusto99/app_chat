import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;

  String name;
  String email;
  List<String> chatIds;
  String photoUrl;
  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.chatIds,
    required this.photoUrl,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      id: doc.id,
      name: doc['name'],
      photoUrl: doc['photoURL'],
      chatIds: List<String>.from(doc['chatIds'] as List<dynamic>),
      email: doc['email'],
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'],
      photoUrl: map['photoURL'],
      chatIds: map['chatIds'],
      email: map['email'],
    );
  }
}
