import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/models/chat_model.dart';
import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/models/user_model.dart';
import 'package:app_chat/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';

class ChatService {
  final _log = getLogger('ChatService');
  final _userService = locator<UserService>();

  Future<UserModel> getOtherUserById(String id) async {
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
      _log.i('Erro ao obter os chats do usuário: $e');
      throw Exception('Erro desconhecido');
    }
  }

  Future<List<ChatModel>> getUserChats() async {
    // Referência para o Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      List<ChatModel> chats = [];

      // Para cada ID de chat, pega o documento correspondente na coleção 'chats'
      for (String chatId in _userService.user.chatIds) {
        DocumentReference chatRef = firestore.collection('chats').doc(chatId);
        DocumentSnapshot chatDoc = await chatRef.get();
        if (!chatDoc.exists) {
          throw Exception('Cannot find chat');
        }
        final chatModel = ChatModel.fromDocument(chatDoc);
        //atribuir list<usermodel>
        final data = chatDoc.data() as Map<String, dynamic>;
        for (String userId in data['userIds']) {
          // if (userId == _userService.user.id) continue;
          final userMode = await getOtherUserById(userId);
          chatModel.users.add(userMode);
        }
        chats.add(chatModel);
      }
      //todo: ja recuperar as msgs tbm e colocar um atributo de lista de msg nesse model de chat?
      //se for mtas mensagem, ai pega um pouco, pra pelo menos carregar as ultimas mensagens rapidinho depois de clicar no chat

      return chats;
    } catch (e) {
      _log.i('Erro ao obter os chats do usuário: $e');
      throw Exception('Erro desconhecido');
    }
  }

  Future<List<MessageModel>> getChatMessages(String chatId) async {
    // Referência para o Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentReference chatDoc = firestore.collection('chats').doc(chatId);

      // if (!chatDoc.) {
      //   throw Exception('Chat does not exist');
      // }

      QuerySnapshot messagesSnapshot = await chatDoc
          .collection('messages')
          //.orderBy('createdAt', descending: true)
          .get();

      //Map<String, dynamic> data = chatDoc.data() as Map<String, dynamic>;

      List<MessageModel> messages = [];

      // Para cada ID de chat, pega o documento correspondente na coleção 'chats'
      for (var messageDoc in messagesSnapshot.docs) {
        if (!messageDoc.exists) {
          //throw Exception('Cannot find message');
          _log.e('Cannot find message');
          continue;
        }
        final messageModel = MessageModel.fromDocument(messageDoc);

        messages.add(messageModel);
      }

      return messages;
    } catch (e) {
      _log.i('Erro ao obter os chats do usuário: $e');
      throw Exception('Erro desconhecido');
    }
  }

  Future<ChatModel> createOrGetChat(String receiverId) async {
    // Referência para o Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      //todo: ver se ja tem um chat entre os dois ids
      /*iterar por todas as mensagens filtrando pelo userIds,
      vendo se cada chat contem o meu id e o receiver id.
      
      ou posso verificar apenas os chats que estao no meu chatIds.
      */

//todo: o resultado disso deve estar no singleton atualizado por stream subscription
      final myChats = await getUserChats();

//verificar se ja ha um chat com aquele outro user
      for (var chat in myChats) {
        if (chat.userIds.contains(receiverId)) {
          return chat;
        }
      }

      //todo: se nao tiver, criar
      // Referência para a coleção 'chats'
      CollectionReference chats = firestore.collection('chats');

      // Dados do novo documento na coleção 'chats'
      Map<String, dynamic> chatData = {
        'createdAt': FieldValue.serverTimestamp(),
        'userIds': [receiverId, _userService.user.id],
      };

      DocumentReference chatRef = await chats.add(chatData);

      //! primeiro eh criado sem a subcollection messages, eh criado na primeira msg

      // if (!chatDoc.) {
      //   throw Exception('Chat does not exist');
      // }

      final chatSnapshot = await chatRef.get();
      final chatModel = ChatModel.fromDocument(chatSnapshot);

      return chatModel;
    } catch (e) {
      _log.i('Erro ao obter os chats do usuário: $e');
      throw Exception('Erro desconhecido');
    }
  }

  Future<void> sendMessage() async {}
  Future<List<MessageModel>> getMessages(String chatId) async {
    // Referência para o Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Referência para a subcollection 'chats'
      CollectionReference messagesRef =
          firestore.collection('chats').doc(chatId).collection('messages');
      QuerySnapshot messagesSnapshot =
          await messagesRef.orderBy('createdAt', descending: true).get();

      if (messagesSnapshot.docs.isEmpty) {
        return [];
      }

      List<MessageModel> messages = [];

      for (var message in messagesSnapshot.docs) {
        final messageModel = MessageModel.fromDocument(message);
        messages.add(messageModel);
      }

      return messages;
    } catch (e) {
      _log.i('Erro ao enviar a mensagem: $e');
      throw Exception('Erro desconhecido');
    }
  }
}
