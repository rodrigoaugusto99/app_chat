import 'dart:async';
import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/exceptions/app_error.dart';
import 'package:app_chat/models/chat_model.dart';
import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/services/local_storage_service.dart';
import 'package:app_chat/services/user_service.dart';
import 'package:app_chat/ui/utils/firestore_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final _log = getLogger('ChatService');
  final _userService = locator<UserService>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<ChatModel>? _chats;
  List<ChatModel>? get chats => _chats;

  Future<void> init() async {
    _chats = await getUserChats();
  }

  StreamSubscription? _actualChatSubscription;
  //! eh necessario isso? eu sei que o getter faz com que a gente pegue sempre
  //! o valor 100% atualizado. Mas precisa disso nesse caso?

  //! alem do mais, aproveitar e entender melhor esse lance do getter ser atualizado.
  StreamSubscription? get actualChatSubscription => _actualChatSubscription;

  //todo: usar value notifier pra usar addlistenrl a no viewmodel?

  // ValueNotifier<List<MessageModel>> actualChatMessages = ValueNotifier([]);

//? criando um listener pro chat ATUAL.
  Future<void> setChatListener(
      ChatModel chat, void Function(MessageModel) onNewMessage) async {
    //ouvindo a query de documentos desse chats
    final query = FirebaseFirestore.instance
        .collection('chats')
        .doc(chat.id)
        .collection('messages');

//instanciando a subscription
//o skip 1  pula a primeira leva de snapshot, que eh TODAS as mensagens
    _actualChatSubscription =
        query.snapshots().skip(1).listen((querySnapshot) async {
      _log.i("New message snapshot received");

      if (querySnapshot.docs.isEmpty) return;

//averiguar se aqui so vem um por um mesmo
      for (var change in querySnapshot.docChanges) {
        //todo: DocumentChangeType.removed
        if (change.type == DocumentChangeType.added) {
          final messageModel = MessageModel.fromDocument(change.doc);
//atribuindo o user na mensagem
          if (messageModel.senderId == _userService.user.id) {
            messageModel.user = _userService.user;
          } else {
            messageModel.user = chat.users
                .firstWhere((element) => element.id == messageModel.senderId);
          }
          //actualChatMessages.value.add(messageModel);
          onNewMessage(messageModel);

          // Future.delayed(const Duration(milliseconds: 100), () {
          //   _scrollToEnd();
          // });
        }
      }
    });
  }

  void disposeListener() {
    _actualChatSubscription!.cancel();
  }

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
        //todo: if message does not existe, send some default error message to show on the place of old lost message.
        final messageModel = MessageModel.fromDocument(message);

        messages.add(messageModel);
      }

      return messages;
    } catch (e) {
      _log.i('Erro ao enviar a mensagem: $e');
      throw Exception('Erro desconhecido');
    }
  }

  //set chats names
  String setChatName(ChatModel chat) {
    String chatName = '';
    //iterando por todos os usuarios de cada chhat
    for (var user in chat.users) {
      int count = 0;
      //quando chegar no meu usuario, ignorar
      if (user.id == _userService.user.id) continue;
      //se tem so um usuario, entao eh um chat cmg e outra pessoa (2 pessoas)
      if (chat.users.length == 1) {
        chatName += user.name;
        //se tem mais de uma pessoa, entao sao 3 (contando cmg). Entao o nome do chat sao todos eles (menos eu)
      } else if (chat.userIds.length > 1) {
        chatName += count == 0 ? user.name : ', ${user.name}';
        count++;
      } else {
        _log.e('nao deveria ter entrado aqui');
      }
    }
    chat.chatName = chatName;
    return chatName;
  }

//?load user chats
  Future<List<ChatModel>> getUserChats() async {
    // Referência para o Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      List<ChatModel> chats = [];

      // Para cada ID de chat, pega o documento correspondente na coleção 'chats'
      /*pega os ids dentro do array chatIds do doc do usuario,
      itera por todos e faz um ChatModel. */
      if (_userService.user.chatIds.isEmpty) {
        return [];
      }
      for (String chatId in _userService.user.chatIds) {
        DocumentReference chatRef = firestore.collection('chats').doc(chatId);
        //separo o chatRef pq vou usar de novo depois usar com .data()
        DocumentSnapshot chatDoc = await chatRef.get();
        //!
        if (!chatDoc.exists) {
          throw Exception('Cannot find chat');
        }
        final chatModel = ChatModel.fromDocument(chatDoc);

        final data = chatDoc.data() as Map<String, dynamic>;
        for (String userId in data['userIds']) {
          if (userId == _userService.user.id) continue;
          final userModel = await FirestoreUtils.getUserModelById(userId);
          chatModel.users.add(userModel);
        }
        chatModel.chatName = setChatName(chatModel);

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

//?load messages from some chats
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
          .orderBy('createdAt', descending: false)
          .get();

      //Map<String, dynamic> data = chatDoc.data() as Map<String, dynamic>;

      List<MessageModel> messages = [];

      // if (snapshot.docs.isNotEmpty) {
      //   List<QueryDocumentSnapshot> documents = snapshot.docs.toList();

      //   // Ordena a lista de documentos pelo campo 'createdAt'
      //   documents.sort((a, b) {
      //     Timestamp timestampA = a['createdAt'];
      //     Timestamp timestampB = b['createdAt'];
      //     return timestampB
      //         .compareTo(timestampA); // Ordena em ordem decrescente
      //   });

      //   // O primeiro documento da lista ordenada será o mais recente
      //   QueryDocumentSnapshot mostRecentDocument = documents.first;

      //   Map<String, dynamic> data =
      //       mostRecentDocument.data() as Map<String, dynamic>;
      // }

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
      _log.e('Erro ao obter os chats do usuário: $e');
      throw Exception('Erro desconhecido');
    }
  }

//?if chat exists, return its ChatModel. if does not exist, create and return it.
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

      //atribuir chatId ao usuario
      final docRef = firestore.collection('users').doc(receiverId);
      final myDocRef = firestore.collection('users').doc(_userService.user.id);

      await docRef.update({
        'chatIds': FieldValue.arrayUnion([chatRef.id]),
      });

      await myDocRef.update({
        'chatIds': FieldValue.arrayUnion([chatRef.id]),
      });

      //! primeiro eh criado sem a subcollection messages, isso eh criado na primeira msg

      // if (!chatDoc.) {
      //   throw Exception('Chat does not exist');
      // }

//o chatRef eh o documento, entao tem o .id. Logo, id nao precisa ser nullable
      final chatSnapshot = await chatRef.get();
      final chatModel = ChatModel.fromDocument(chatSnapshot);

      return chatModel;
    } catch (e) {
      _log.i('Erro ao obter os chats do usuário: $e');
      throw Exception('Erro desconhecido');
    }
  }

//?send message
  Future<String> sendMessage({
    String? message,
    required String chatId,
    String? audioUrl,
    String? videoUrl,
    String? imageUrl,
    String? futureId,
  }) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      CollectionReference messagesRef =
          firestore.collection('chats').doc(chatId).collection('messages');

//criando map pra tacar dentro da colecao de messages e p dps fazer o fromMap pra MessageModel.
      final messageDoc = {
        'senderId': _userService.user.id!,
        'message': message ?? '',
        'audioUrl': audioUrl ?? '',
        'videoUrl': videoUrl ?? '',
        'imageUrl': imageUrl ?? '',
        //'createdAt': FieldValue.serverTimestamp(),

        'createdAt': Timestamp.fromDate(DateTime.now()),
      };
//todo: se existir futureId, respeita-lo aqui.
      if (futureId == null) {
        final messageRef = await messagesRef.add(messageDoc);
        //retornando o id da mensagem criada.
        return messageRef.id;
        // return MessageModel.fromMap(messageDoc);
      } else {
        await messagesRef.doc(futureId).set(messageDoc);
        return futureId;
      }
    } on Exception catch (e) {
      throw AppError(message: e.toString());
    }
  }
}
