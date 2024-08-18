import 'package:app_chat/app/app.dialogs.dart';
import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/app/app.router.dart';
import 'package:app_chat/models/chat_model.dart';
import 'package:app_chat/models/user_model.dart';
import 'package:app_chat/services/auth_service.dart';
import 'package:app_chat/services/chat_service.dart';
import 'package:app_chat/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();
  final _chatService = locator<ChatService>();
  final _authService = locator<AuthService>();
  final _log = getLogger('HomeViewModel');

//aqui precisa ter nulabilidade? sabendo que se logou, logo user nao eh null
//mas e se ficar null de repente? ai teria que colocar um listener, se for null, deslogue na hora,
//evitando erro de null
  UserModel? user;
  List<ChatModel>? chats;

  void showUsers() {
    _dialogService.showCustomDialog(
      variant: DialogType.showUsers,
    );
  }

  Future<void> init() async {
    setBusy(true);
    user = _userService.user;

    //!precisa disso? no app inteiro, n seria bom um listener q verifica se usuario esta online ou nao?
    if (user == null) return;
    _log.i(user!.id);
    chats = _chatService.chats;
    if (chats == null) return;

    //iterando por todos os chats que o usuario tem
    // for (var chat in chats!) {
    //   chat.chatName = _chatService.setChatName(chat);
    // }
    notifyListeners();

    setBusy(false);
  }

  void navToChat(ChatModel chat) {
    _navigationService.navigateToChatView(chat: chat);
  }

  Future<void> logout() async {
    await _authService.signOut();
    //_navigationService.replaceWithLoginView();
  }
}
