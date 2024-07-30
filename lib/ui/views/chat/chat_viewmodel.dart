import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/models/chat_model.dart';
import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/models/user_model.dart';
import 'package:app_chat/services/chat_service.dart';
import 'package:app_chat/services/user_service.dart';
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

  UserModel? otherUser;
  List<MessageModel>? messages;

  //todo: map userId1: UserModel1

  Future<void> init() async {
    setBusy(true);
    //load other user
    // String otheUserId =
    //     chat.userIds.firstWhere((element) => element != _userService.user.id);
    // otherUser = await _userService.getOtherUserById(otheUserId);

    //todo: load messages
    messages = await _chatService.getMessages(chat.id);
    //todo: iterar por cada msg e inserir UserModel correspondente
    if (messages == null) return; //todo: grab error
    for (var message in messages!) {
      message.user =
          chat.users.firstWhere((element) => element.id == message.senderId);
    }
    notifyListeners();
    setBusy(false);
  }
}
