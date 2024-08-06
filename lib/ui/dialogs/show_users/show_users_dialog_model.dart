import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.router.dart';
import 'package:app_chat/models/user_model.dart';
import 'package:app_chat/services/auth_service.dart';
import 'package:app_chat/services/chat_service.dart';
import 'package:app_chat/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ShowUsersDialogModel extends BaseViewModel {
  final _userService = locator<UserService>();
  final _chatService = locator<ChatService>();
  final _navigationService = locator<NavigationService>();

  List<UserModel>? users;

  Future<void> init() async {
    users = await _userService.getAllUsers();
    notifyListeners();
  }

  Future<void> createOrOpenChat(String receiverId) async {
    //todo: lembrar de nos viewmodels sempre fazer try catch pra pegar os erros
    //todo: que vieram dos services pra poder exibir ao usuario.
    final chatModel = await _chatService.createOrGetChat(receiverId);
    //navega pro chat criado ou recuperado.
    _navigationService.navigateToChatView(chat: chatModel);
  }
}
