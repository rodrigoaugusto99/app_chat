import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUtils {
  // final _log = getLogger('FirestoreUtils');

  static Future<UserModel> getUserModelById(String id) async {
    // Referência para o Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot documentSnapshot =
          await firestore.collection('users').doc(id).get();

      if (!documentSnapshot.exists) {
        throw Exception('Chat does not exist');
      }

      final userModel = UserModel.fromDocument(documentSnapshot);

      return userModel;
    } catch (e) {
      getLogger('FirestoreUtils').i('Erro ao obter os chats do usuário: $e');
      throw Exception('Erro desconhecido');
    }
  }
}
