import 'dart:async';

import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/models/chat_model.dart';
import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/models/user_model.dart';
import 'package:app_chat/services/chat_service.dart';
import 'package:app_chat/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ChatViewModel extends BaseViewModel {
  final ChatModel chat;
  ChatViewModel({
    required this.chat,
  });
  TextEditingController controller = TextEditingController();
  final _userService = locator<UserService>();
  final _chatService = locator<ChatService>();
  final _log = getLogger('ChatViewModel');

  List<UserModel>? otherUses;

  UserModel? myUser;
  StreamSubscription? _subscription;
  List<MessageModel>? messages;

  Future<void> setLedgerBookListener() async {
    //ouvindo a query de documentos desse chats
    final query = FirebaseFirestore.instance
        .collection('chats')
        .doc(chat.id)
        .collection('messages');

//instanciando a subscription
    _subscription = query.snapshots().skip(1).listen((querySnapshot) async {
      _log.i("New message snapshot received");

      if (querySnapshot.docs.isEmpty) return;

//averiguar se aqui so vem um por um mesmo
      for (var change in querySnapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final messageModel = MessageModel.fromDocument(change.doc);
//atribuindo o user na mensagem
          messageModel.user =
              chat.users.firstWhere((user) => user.id == messageModel.senderId);
          messages!.add(messageModel);
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscription == null) return;
    _subscription!.cancel();
  }

  void sendMessage() async {
    if (controller.text.isEmpty) return;

    try {
      await _chatService.sendMessage(
        message: controller.text,
        chatId: chat.id,
      );

      // messages!.add(messageModel);
      controller.clear();
      controller.text = '';
    } catch (e) {
      _log.e(e);
    }

    notifyListeners();
  }

  Future<void> init() async {
    setBusy(true);
    myUser = _userService.user;

    //todo: load messages //todo: insert on some cache
    messages = await _chatService.getChatMessages(chat.id);

    if (messages == null) return; //todo: grab error
    //todo: iterar por cada msg e inserir UserModel correspondente
    for (var message in messages!) {
      message.user =
          chat.users.firstWhere((element) => element.id == message.senderId);
    }

    notifyListeners();
    setLedgerBookListener();
    setBusy(false);
  }
}
