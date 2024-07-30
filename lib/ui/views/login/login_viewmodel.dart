import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/app/app.router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../services/auth_service.dart';

class LoginViewModel extends BaseViewModel {
  final _log = getLogger('LoginViewModel');
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();
  // late final loginWithGoogle = _authService.signInWithGoogle;
  // late final loginWithEmailAndPassword =
  //     _authService.signInWithEmailAndPassword(email.text, password.text);
  //late final loginWithApple = _authService.signInWithApple;
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  // var maskFormatter = MaskTextInputFormatter(
  //   mask: '###.###.###-##',
  //   filter: {"#": RegExp(r'[0-9]')},
  //   type: MaskAutoCompletionType.lazy,
  // );

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

  // void login(Future<UserCredential> loginMethod) async {
  //   setBusy(true);
  //   try {
  //     await loginMethod;
  //     // await _authService.signInWithGoogle();

  //     if (_authService.currUser != null) {
  //       await _navigationService.clearStackAndShow(Routes.homeView);
  //     }
  //   } on Exception catch (e) {
  //     _log.e(e);
  //   }
  //   setBusy(false);
  // }
}
