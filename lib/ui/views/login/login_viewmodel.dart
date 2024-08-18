import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../services/auth_service.dart';

class LoginViewModel extends BaseViewModel {
  final _log = getLogger('LoginViewModel');
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  void loginWithEmail() async {
    setBusy(true);
    try {
      await _authService.signInWithEmailAndPassword(email.text, password.text);

      if (_authService.currUser != null) {
        await _navigationService.clearStackAndShow(Routes.homeView);
      }
    } on Exception catch (e) {
      _log.e(e);
    }
    setBusy(false);
  }

  void loginWithGoogle() async {
    setBusy(true);
    try {
      await _authService.signInWithGoogle();

      if (_authService.currUser != null) {
        await _navigationService.clearStackAndShow(Routes.homeView);
      }
    } on Exception catch (e) {
      _log.e(e);
    }
    setBusy(false);
  }
}
