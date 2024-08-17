import 'package:app_chat/models/chat_model.dart';
import 'package:app_chat/ui/utils/helpers.dart';
import 'package:app_chat/ui/views/chat/components/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
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
            //resizeToAvoidBottomInset: true,
            //extendBody: true,
            backgroundColor: Colors.grey[900],
            appBar: AppBar(
              // toolbarHeight: 77,
              leadingWidth: 40,
              foregroundColor: Colors.white,
              backgroundColor: Colors.grey[900],
              // Dividindo nomes dos usuários por vírgula e exibindo imagens lado a lado
              title: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Row(
                      children: chat.users
                          .map(
                            (user) => decContainer(
                              radius: 100,
                              color: Colors.orange,
                              child: Image.network(
                                user.photoUrl,
                                height: 40,
                                width: 40,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    widthSeparator(10),
                    styledText(
                      //text: chat.users.map((user) => user.name).join(', '),
                      text: chat.chatName,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 22,
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
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    //REVERSE
                    reverse: true,
                    padding: const EdgeInsets.only(bottom: 3),
                    //physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    controller: viewModel.scrollController,
                    itemCount: viewModel.messagesGroupedByDays!.length,
                    itemBuilder: (BuildContext context, int index) {
                      //final message = viewModel.messages![index];

                      //REVERSE
                      final messagesByDay = viewModel
                          .messagesGroupedByDays!.reversed
                          .toList()[index];
                      return Column(
                        children: [
                          styledText(
                            text: messagesByDay.day,
                            color: Colors.white,
                            fontSize: 24,
                          ),
                          ...messagesByDay.messages.map<Widget>((message) {
                            return decContainer(
                              leftPadding: 10,
                              rightPadding: 10,
                              topPadding: 3,
                              child: Row(
                                mainAxisAlignment:
                                    message.senderId == viewModel.myUser!.id
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  message.senderId == viewModel.myUser!.id
                                      ? ChatBubble(
                                          isMe: true,
                                          chatId: chat.id,
                                          message: message,
                                        )
                                      : ChatBubble(
                                          chatId: chat.id,
                                          message: message,
                                        )
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                  // Expanded(
                  //   child: ListView.builder(
                  //     padding: const EdgeInsets.only(bottom: 3),
                  //     //physics: const NeverScrollableScrollPhysics(),
                  //     shrinkWrap: true,
                  //     controller: viewModel.scrollController,
                  //     itemCount: viewModel.messages!.length,
                  //     itemBuilder: (BuildContext context, int index) {
                  //       final message = viewModel.messages![index];
                  //       return decContainer(
                  //         leftPadding: 10,
                  //         rightPadding: 10,
                  //         topPadding: 3,
                  //         child: Row(
                  //           mainAxisAlignment:
                  //               message.senderId == viewModel.myUser!.id
                  //                   ? MainAxisAlignment.end
                  //                   : MainAxisAlignment.start,
                  //           children: [
                  //             message.senderId == viewModel.myUser!.id
                  //                 ? MyChatBubble(
                  //                     message: message,
                  //                   )
                  //                 : ChatBubble(
                  //                     message: message,
                  //                   )
                  //           ],
                  //         ),
                  //       );
                  //     },
                  //   ),
                ),
                decContainer(
                  // height: MediaQuery.of(context).viewInsets.bottom + 60,
                  radius: 30,
                  topPadding: 10,
                  bottomPadding: 10,
                  leftPadding: 24,
                  color: Colors.grey[800],
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextField(
                          onChanged: (_) => viewModel.onChanged(_),
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          controller: viewModel.controller,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            if (viewModel.recorder!.isRecording)
                              StreamBuilder<RecordingDisposition>(
                                stream: viewModel.recorder!.onProgress,
                                builder: (context, snapshot) {
                                  final duration = snapshot.hasData
                                      ? snapshot.data!.duration
                                      : Duration.zero;
                                  // Converte a duração para minutos e segundos
                                  String twoDigits(int n) =>
                                      n.toString().padLeft(2, '0');
                                  final minutes = twoDigits(
                                      duration.inMinutes.remainder(60));
                                  final seconds = twoDigits(
                                      duration.inSeconds.remainder(60));

                                  return styledText(
                                    text: '$minutes:$seconds',
                                  );
                                },
                              ),
                            GestureDetector(
                              onTap: viewModel.canRecord
                                  ? viewModel.recordVoice
                                  : viewModel.sendMessage,
                              child: Icon(
                                viewModel.canRecord ? Icons.mic : Icons.send,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                heightSeparator(10)
              ],
            ),
            // bottomNavigationBar: decContainer(
            //   // height: MediaQuery.of(context).viewInsets.bottom + 60,
            //   radius: 30,
            //   topPadding: 10,
            //   bottomPadding: MediaQuery.of(context).viewInsets.bottom + 10,
            //   leftPadding: 24,
            //   color: Colors.grey[800],
            //   child: Row(
            //     children: [
            //       Expanded(
            //         flex: 5,
            //         child: TextField(
            //           cursorColor: Colors.white,
            //           style: const TextStyle(color: Colors.white),
            //           decoration: const InputDecoration(
            //             border: InputBorder.none,
            //           ),
            //           controller: viewModel.controller,
            //         ),
            //       ),
            //       Expanded(
            //         child: GestureDetector(
            //           onTap: viewModel.sendMessage,
            //           child: const Icon(
            //             Icons.send,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          );
  }

  @override
  ChatViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChatViewModel(
        chat: chat,
        context: context,
      );

  @override
  void onViewModelReady(ChatViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.init();
  }
}
