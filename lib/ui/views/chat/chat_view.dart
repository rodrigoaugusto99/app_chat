import 'package:app_chat/models/chat_model.dart';
import 'package:app_chat/ui/utils/helpers.dart';
import 'package:app_chat/ui/views/chat/chat_bubble.dart';
import 'package:app_chat/ui/views/chat/my_chat_bubble.dart';
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
            //extendBody: true,
            backgroundColor: Colors.black,
            appBar: AppBar(
              // Dividindo nomes dos usuários por vírgula e exibindo imagens lado a lado
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      chat.users.map((user) => user.name).join(', '),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (chat.users.length > 1)
                    Row(
                      children: chat.users.map((user) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              user.photoUrl,
                              height: 50,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            //todo: carregar primeiro os mais recentes. colocar reverse.
            body: ListView.builder(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              controller: viewModel.scrollController,
              itemCount: viewModel.messages!.length,
              itemBuilder: (BuildContext context, int index) {
                final message = viewModel.messages![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: decContainer(
                    allPadding: 10,
                    child: Row(
                      mainAxisAlignment:
                          message.senderId == viewModel.myUser!.id
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                      children: [
                        message.senderId == viewModel.myUser!.id
                            ? ChatBubble(
                                message: message,
                              )
                            : MyChatBubble(
                                message: message,
                              )
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
              color: Colors.grey,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.white,
                      child: TextField(
                        controller: viewModel.controller,
                      ),
                    ),
                  ),
                  // widthSeparator(10),
                  Expanded(
                    child: GestureDetector(
                      onTap: viewModel.sendMessage,
                      child: const Icon(
                        Icons.send,
                      ),
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
