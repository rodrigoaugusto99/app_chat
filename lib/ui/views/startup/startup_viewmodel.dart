import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.router.dart';
import 'package:app_chat/services/audio_service.dart';
import 'package:app_chat/services/auth_service.dart';
import 'package:app_chat/services/local_storage_service.dart';
import 'package:app_chat/services/recorder_service.dart';
import 'package:app_chat/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stacked/stacked.dart';

import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  // Place anything here that needs to happen before we get into the application
  Future runStartupLogic() async {
    await Future.delayed(const Duration(milliseconds: 200));

    notifyListeners();
    locator<AudioService>().init();
    await locator<RecorderService>().init();
    await locator<AuthService>().init();
    await locator<LocalStorageService>().init();

    //await Future.delayed(const Duration(milliseconds: 1200));
    if (FirebaseAuth.instance.currentUser != null) {
      await locator<UserService>()
          .setUser(FirebaseAuth.instance.currentUser!.uid);
      _navigationService.replaceWithHomeView();
    } else {
      _navigationService.replaceWithLoginView();
    }
  }
}
