import 'dart:async';
import 'package:app_chat/app/app.dialogs.dart';
import 'package:app_chat/app/app.locator.dart';
import 'package:flutter/material.dart';
import 'package:app_chat/app/app.dialogs.dart';
import 'package:app_chat/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class LoadingDialog extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  LoadingDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key) {
    request.data.future
        .then((value) => completer(DialogResponse(confirmed: true)));
  }

  @override
  LoadingDialogState createState() => LoadingDialogState();
}

class LoadingDialogState extends State<LoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: const AlertDialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class Loading {
  final DialogService _dialogService = locator<DialogService>();

  Completer? _onLoading;
  dynamic response;

  void showLoading() {
    _onLoading = Completer();
    response = _dialogService.showCustomDialog(
        barrierDismissible: true,
        variant: DialogType.loading,
        barrierColor: Colors.black26,
        data: _onLoading);
  }

  dismiss() async {
    if (_onLoading != null && !_onLoading!.isCompleted) {
      _onLoading!.complete();
      await response;
    }
  }
}
