import 'dart:async';
import 'package:app_chat/models/user_model.dart';
import 'package:app_chat/exceptions/app_error.dart';
import 'package:app_chat/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/services/auth_service.dart';
import 'package:stacked_services/stacked_services.dart';

class UserService {
  final _log = getLogger('UserService');
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();

  final _firestore = FirebaseFirestore.instance;
  final _firestoreUsers = FirebaseFirestore.instance.collection('users');

  UserModel? _user;
  UserModel get user => _user!;

  StreamSubscription? _userSubscription;

  Future<List<UserModel>> getAllUsers() async {
    // Referência para o Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot querySnapshot = await firestore.collection('users').get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      List<UserModel> users = [];

      // Para cada ID de chat, pega o documento correspondente na coleção 'chats'
      for (var userDoc in querySnapshot.docs) {
        if (!userDoc.exists) {
          //throw Exception('Cannot find message');
          _log.e('Cannot find user');
          continue;
        }
        if (userDoc.id == user.id) continue;
        final userModel = UserModel.fromDocument(userDoc);

        users.add(userModel);
      }

      return users;
    } catch (e) {
      _log.i('Erro ao obter os chats do usuário: $e');
      throw Exception('Erro desconhecido');
    }
  }

  Future<void> setUser(String uid) async {
    final userDocRef = _firestoreUsers.doc(uid);

    try {
      final docSnapshot = await userDocRef.get();
      if (!docSnapshot.exists) {
        throw AppError(message: "User not found");
      }
      _user = UserModel.fromDocument(docSnapshot);
      //_user = UserModel.fromMap(docSnapshot.data()!);
      user.id = uid;
    } catch (error) {
      _log.e(error);
      rethrow;
    }

    _userSubscription = userDocRef.snapshots().skip(1).listen((snapshot) {
      _log.i("New user snapshot received");
      if (snapshot.exists && snapshot.data() != null) {
        _user = UserModel.fromDocument(snapshot);
        //_user = UserModel.fromMap(snapshot.data()!);
      }
      user.id = uid;
    });
    await locator<ChatService>().init();
  }

  void unSetUser() {
    _userSubscription?.cancel();
    _user = null;
  }
}
