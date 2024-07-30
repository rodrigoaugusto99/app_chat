import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/models/chat_model.dart';
import 'package:app_chat/models/user_model.dart';
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

  UserModel? otherUser;

  Future<void> init() async {
    setBusy(true);
    //todo: load other user
    // String otheUserId =
    //     chat.userIds.firstWhere((element) => element != _userService.user.id);
    // otherUser = await _userService.getOtherUserById(otheUserId);

    //todo: load messages
    setBusy(false);
  }
}
