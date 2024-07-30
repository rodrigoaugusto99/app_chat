import 'package:app_chat/ui/utils/helpers.dart';
import 'package:app_chat/ui/views/home/home_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return viewModel.isBusy || viewModel.chats == null
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            bottomNavigationBar: ElevatedButton(
              onPressed: viewModel.showUsers,
              child: const Text('show users'),
            ),
            appBar: HomeAppBar(
              imageNetwork: viewModel.user!.photoUrl,
              title: viewModel.user!.name,
              onTap: viewModel.logout,
            ),
            backgroundColor: Colors.grey,
            body: Center(
              child: ListView.separated(
                itemCount: viewModel.chats!.length,
                itemBuilder: (BuildContext context, int index) {
                  final chat = viewModel.chats![index];
                  return decContainer(
                    onTap: () => viewModel.navToChat(chat),
                    child: styledText(text: chat.chatName),
                    height: 50,
                    color: Colors.blueGrey,
                    // child: styledText(text: chat.n)
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 10);
                },
              ),
            ),
          );
  }

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel();
  @override
  void onViewModelReady(HomeViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.init();
  }
}
