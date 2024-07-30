import 'package:app_chat/ui/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:app_chat/ui/common/app_colors.dart';
import 'package:app_chat/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'show_users_dialog_model.dart';

const double _graphicSize = 60;

class ShowUsersDialog extends StackedView<ShowUsersDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const ShowUsersDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ShowUsersDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: viewModel.users == null
            ? const CircularProgressIndicator()
            : ListView.builder(
                itemCount: viewModel.users!.length,
                itemBuilder: (BuildContext context, int index) {
                  final user = viewModel.users![index];
                  return decContainer(
                    onTap: () => viewModel.createOrOpenChat(user.id!),
                    height: 30,
                    color: Colors.grey,
                    child: styledText(text: user.name),
                  );
                },
              ),
      ),
    );
  }

  @override
  void onViewModelReady(ShowUsersDialogModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.init();
  }

  @override
  ShowUsersDialogModel viewModelBuilder(BuildContext context) =>
      ShowUsersDialogModel();
}
