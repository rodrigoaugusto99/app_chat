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
            backgroundColor: Colors.grey[900],
            body: ListView.separated(
              itemCount: viewModel.chats!.length,
              itemBuilder: (BuildContext context, int index) {
                final chat = viewModel.chats![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: decContainer(
                    allPadding: 10,
                    // color: Colors.blue,
                    onTap: () => viewModel.navToChat(chat),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: chat.users
                              .map(
                                (user) => decContainer(
                                  radius: 100,
                                  child: Image.network(
                                    user.photoUrl,
                                    height: 50,
                                    width: 50,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        widthSeparator(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              styledText(
                                height: 0.8,
                                color: Colors.white,
                                //text: chat.users.map((user) => user.name).join(', '),
                                text: chat.chatName,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              styledText(
                                height: 2,
                                text: chat.lastMessage ?? 'NULL',
                                overflow: TextOverflow.ellipsis,
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            styledText(
                              text: chat.hourAndMinutes ?? 'NULL',
                              height: 0.5,
                              color: Colors.grey[600],
                            ),
                            heightSeparator(10),
                            if (chat.countOFUnreadedMessages! > 0)
                              decContainer(
                                allPadding: 5,
                                radius: 10,
                                color: const Color(0xff128c7e),
                                child: styledText(
                                  text: chat.countOFUnreadedMessages.toString(),
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 10);
              },
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
