import 'package:app_chat/ui/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'login_viewmodel.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: viewModel.email,
            ),
            TextField(
              controller: viewModel.password,
            ),
            ElevatedButton(
              //onPressed: () => viewModel.loginWithEmailAndPassword,
              onPressed: () => viewModel.loginWithEmail(),
              child: const Text('Login com email e senha'),
            ),
            heightSeparator(100),
            ElevatedButton(
              // onPressed: () =>
              //     viewModel.loginWithGoogle(viewModel.log
              onPressed: () => viewModel.loginWithGoogle(),
              child: const Text('Login com google'),
            ),
            // ElevatedButton(
            //   onPressed: () => viewModel.login(viewModel.loginWithApple),
            //   child: const Text('Login com apple'),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginViewModel();
}
