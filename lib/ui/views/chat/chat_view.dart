import 'package:app_chat/models/chat_model.dart';
import 'package:app_chat/ui/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'chat_viewmodel.dart';

class ChatView extends StackedView<ChatViewModel> {
  final ChatModel chat;
  const ChatView({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ChatViewModel viewModel,
    Widget? child,
  ) {
    return viewModel.isBusy
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              //todo: mover logica p viewModel p exibir todos os users se tiver + de 1.
              title: Text(chat.chatName),
            ),
            //todo: carregar primeiro os mais recentes. colocar reverse.
            body: ListView.builder(
              itemCount: viewModel.messages!.length,
              itemBuilder: (BuildContext context, int index) {
                final message = viewModel.messages![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: decContainer(
                    allPadding: 10,
                    color: Colors.grey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            if (message.user != null &&
                                message.user!.photoUrl != '')
                              Image.network(message.user!.photoUrl),
                          ],
                        ),
                        styledText(text: message.text),
                      ],
                    ),
                  ),
                );
              },
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                left: 24,
                //right: 24,
                top: 10,
              ),
              color: Colors.orange,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.red,
                      child: TextField(
                        controller: viewModel.controller,
                      ),
                    ),
                  ),
                  // widthSeparator(10),
                  const Expanded(
                    child: Icon(
                      Icons.send,
                    ),
                  )
                ],
              ),
            ),
          );
  }

  @override
  ChatViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChatViewModel(
        chat: chat,
      );

  @override
  void onViewModelReady(ChatViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.init();
  }
}
