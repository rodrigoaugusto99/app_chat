import 'package:app_chat/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:app_chat/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:app_chat/ui/dialogs/loading/loading_dialog.dart';
import 'package:app_chat/ui/views/home/home_view.dart';
import 'package:app_chat/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:app_chat/ui/views/login/login_view.dart';
import 'package:app_chat/services/auth_service.dart';
import 'package:app_chat/services/user_service.dart';
import 'package:app_chat/ui/views/chat/chat_view.dart';
import 'package:app_chat/services/chat_service.dart';
import 'package:app_chat/ui/dialogs/show_users/show_users_dialog.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: ChatView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: AuthService),
    LazySingleton(classType: UserService),
    LazySingleton(classType: ChatService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    StackedDialog(classType: LoadingDialog),
    StackedDialog(classType: ShowUsersDialog),
// @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
