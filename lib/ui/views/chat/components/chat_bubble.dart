import 'dart:io';
import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/services/audio_service.dart';
import 'package:app_chat/services/local_storage_service.dart';
import 'package:app_chat/ui/common/ui_helpers.dart';
import 'package:app_chat/ui/utils/helpers.dart';
import 'package:app_chat/ui/utils/utiis.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatefulWidget {
  final String chatId;
  final MessageModel message;
  final bool isMe;
  const ChatBubble({
    Key? key,
    required this.message,
    required this.chatId,
    this.isMe = false,
  }) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  //final _log = getLogger('MyChatBubble');
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.message.audioUrl != '') {
      initAudio();
    } else if (widget.message.imageUrl != '') {
      initImage();
    }
  }

  String? imagePath;

  Future<void> initImage() async {
    imagePath = await locator<LocalStorageService>().getFilePath(
      chatId: widget.chatId,
      messageId: widget.message.id!,
    );
    setState(() {});
    //todo: se for null, eu poderia ja ter baixado la no chatviewmodel ne

//     if (imagePath == null) {
// //se nao tem o arquivo, mostrar pela internet mesmo
//       imageFile = Image.network(imageUrl);
//     } else {
//       //se pegou o arquivo, mostre
//       imageFile = File(imagePath);
//     }
  }

  void initAudio() {
    if (mounted) {
      audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      });

      audioPlayer.onDurationChanged.listen((newDuration) {
        setState(() {
          duration = newDuration;
        });
      });

      audioPlayer.onPositionChanged.listen((newPosition) {
        setState(() {
          position = newPosition;
        });
      });
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

//no metodo downloadAudio, na primeira vez o audio eh baixado em cache, em um arquivo temporario.
  //todo: utisl

  Future<void> playAudio() async {
    final audioPath = await locator<LocalStorageService>().getFilePath(
      chatId: widget.chatId,
      messageId: widget.message.id!,
    );
    await locator<AudioService>().playAudio(audioPath!);
  }

  Future<String?> getImagePath() async {
    final imagePath = await locator<LocalStorageService>().getFilePath(
      chatId: widget.chatId,
      messageId: widget.message.id!,
    );
    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    final timestampFormatted =
        DateFormat('HH:mm', 'pt_BR').format(widget.message.createdAt.toDate());

    Widget myText() {
      return decContainer(
        allPadding: 10,
        radius: 12,
        color: widget.isMe ? const Color(0xff128c7e) : Colors.grey[800],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            styledText(
                text: widget.message.message!,
                color: Colors.white,
                fontSize: 18),
            widthSeparator(10),
            Align(
              alignment: Alignment.bottomCenter,
              child: styledText(
                text: timestampFormatted,
                color: Colors.white70,
              ),
            )
          ],
        ),
      );
    }

    Widget myAudio() {
      return decContainer(
        clipBehavior: Clip.none,
        width: screenWidth(context) / 1.3,
        leftPadding: 10,
        bottomPadding: 10,
        radius: 12,
        color: widget.isMe ? const Color(0xff128c7e) : Colors.grey[800],
        child: Row(
          children: [
            if (!widget.message.isDownloading)
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                  color: widget.isMe ? Colors.grey[800] : Colors.grey[200],
                ),
                onPressed: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                    isPlaying = false;
                  } else {
                    // await audioPlayer.resume();
                    await playAudio();
                    //await audioPlayer.play(UrlSource(widget.message.audioUrl!));
                  }
                },
              ),
            if (widget.message.isDownloading)
              const Icon(
                Icons.download,
                size: 32,
                color: Colors.blue,
              ),
            Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  // top: 0,
                  // left: 0,
                  // right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Slider(
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());

                        await audioPlayer.seek(position);

                        await audioPlayer.resume();
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: styledText(
                    text: isPlaying
                        ? formatDuration(duration - position)
                        : formatDuration(duration),
                    color: Colors.white,
                  ),
                ),
                //widthSeparator(100),
                Positioned(
                  bottom: 0,
                  right: -20,
                  child: styledText(
                    text: timestampFormatted,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Widget myImage() {
    //   //todo: exibir a imagem de acordo com as suas proprias dimensoes
    //   return decContainer(
    //     width: screenWidth(context) / 2,
    //     color: Colors.blue,
    //     child: ClipRRect(
    //       borderRadius: BorderRadius.circular(8.0),
    //       child: widget.message.isDownloading
    //           ? decContainer(
    //               //todo: FutureBuilder.
    //               color: Colors.grey,
    //               child: const CircularProgressIndicator(),
    //             )
    //           : imagePath != null
    //               ? Image.file(
    //                   File(imagePath!),
    //                   fit: BoxFit.cover,
    //                   // width: 150,
    //                   // height: 150,
    //                 )
    //               : Image.network(
    //                   widget.message.imageUrl!,
    //                   fit: BoxFit.cover,
    //                   // width: 150,
    //                   // height: 150,
    //                 ),
    //     ),
    //   );
    // }

    Widget myImage() {
      //todo: exibir a imagem de acordo com as suas proprias dimensoes
      return decContainer(
        width: screenWidth(context) / 2,
        color: Colors.blue,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: widget.message.isDownloading
              ? decContainer(
                  //todo: FutureBuilder.
                  color: Colors.grey,
                  child: const CircularProgressIndicator(),
                )
              : FutureBuilder<String?>(
                  future: getImagePath(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      // Fallback para Image.network se o arquivo local não for encontrado ou houve erro
                      return Image.network(widget.message.imageUrl!);
                    } else {
                      // Exibe a imagem localmente
                      return Image.file(File(snapshot.data!));
                    }
                  },
                ),
        ),
      );
    }

    if (widget.message.message != '') {
      return myText();
    } else if (widget.message.audioUrl != '') {
      return myAudio();
    } else if (widget.message.videoUrl != '') {
      //return myVideo();
      return Container();
    } else if (widget.message.imageUrl != '') {
      return myImage();
    }
    return Container();
  }
}
