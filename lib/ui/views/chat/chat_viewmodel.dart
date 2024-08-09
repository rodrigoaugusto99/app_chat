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

class ChatViewModel extends BaseViewModel with WidgetsBindingObserver {
  final ChatModel chat;
  BuildContext context;
  ChatViewModel({
    required this.chat,
    required this.context,
  }) {
    WidgetsBinding.instance.addObserver(this);
    // focus.addListener(() {
    //   if (focus.hasFocus) {
    //     _scrollToEnd();
    //     Future.delayed(
    //       const Duration(milliseconds: 1000),
    //       () => _scrollToEnd(),
    //     );
    //   }
    // });
  }
  // FocusNode focus = FocusNode();

  ScrollController scrollController = ScrollController();

  TextEditingController controller = TextEditingController();
  final _userService = locator<UserService>();
  final _chatService = locator<ChatService>();
  final _log = getLogger('ChatViewModel');
//todo: ao subir teclado, aparecer ultimas msgs normalmente
  List<UserModel>? otherUses;

  UserModel? myUser;
  StreamSubscription? _subscription;
  List<MessageModel>? messages;

  Future<void> setChatListener() async {
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
          if (messageModel.senderId == myUser!.id) {
            messageModel.user = myUser;
          } else {
            messageModel.user = chat.users
                .firstWhere((element) => element.id == messageModel.senderId);
          }
          messages!.add(messageModel);

          notifyListeners();
          Future.delayed(const Duration(milliseconds: 100), () {
            _scrollToEnd();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    super.dispose();
    if (_subscription == null) return;
    _subscription!.cancel();
  }

//chamado quando muda o tasmanhho do layout (qnd abre teclado)
  @override
  void didChangeMetrics() {
    final screenHeight = MediaQuery.of(context).size.height;
    //apenas se a posicao atual e menor que a substracao entre o maximo e o tamanhho total
    // if ((scrollController.position.maxScrollExtent -
    //         scrollController.position.pixels) <
    //     screenHeight) {
    //   _log.e('scroll');
    // }

/*
ao abrir o teclado, caso a distancia entre o scroll atual e o maximo de scroll possivel
for menor que a metade da altura da tela, entao faz o scroll.

ou seja, se estiver QUASE NO FIM DO SCROLL, entao rola la pro final qnd abrir teclado.
 */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((scrollController.position.maxScrollExtent -
              scrollController.position.pixels) <
          screenHeight / 2) {
        _scrollToEnd();
        // scrollController.animateTo(
        //   scrollController.position.maxScrollExtent,
        //   duration: const Duration(milliseconds: 100),
        //   curve: Curves.easeInOut,
        // );
      }
    });
    super.didChangeMetrics();
  }

  void sendMessage() async {
    if (controller.text.isEmpty) return;

    try {
      await _chatService.sendMessage(
        message: controller.text,
        chatId: chat.id,
      );

      // controller.clear();
      controller.text = '';
    } catch (e) {
      _log.e(e);
    }
    //_scrollToEnd();
    notifyListeners();
  }

  Future<void> init() async {
    setBusy(true);
    myUser = _userService.user;

    //todo: load messages //todo: insert on some cache
    messages = await _chatService.getChatMessages(chat.id);

    if (messages == null) return; //todo: grab error
    //iterar por cada msg e inserir UserModel correspondente
    for (var message in messages!) {
      if (message.senderId == myUser!.id) {
        //aqui posso colocar uma flag na mensagem pra dizer que eh minha, pro exemplo.
        message.user = myUser;
      } else {
        message.user = chat.users.firstWhere(
          (element) => element.id == message.senderId,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();
    });
    setChatListener();
    setBusy(false);
  }

  Future<void> _scrollToEnd() async {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    _log.i('');
    // await Future.delayed(const Duration(milliseconds: 500));
    // _scrollToEnd();
  }
}
