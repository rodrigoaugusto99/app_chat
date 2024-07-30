// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/dialogs/info_alert/info_alert_dialog.dart';
import '../ui/dialogs/loading/loading_dialog.dart';
import '../ui/dialogs/show_users/show_users_dialog.dart';

enum DialogType {
  infoAlert,
  loading,
  showUsers,
}

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final Map<DialogType, DialogBuilder> builders = {
    DialogType.infoAlert: (context, request, completer) =>
        InfoAlertDialog(request: request, completer: completer),
    DialogType.loading: (context, request, completer) =>
        LoadingDialog(request: request, completer: completer),
    DialogType.showUsers: (context, request, completer) =>
        ShowUsersDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
