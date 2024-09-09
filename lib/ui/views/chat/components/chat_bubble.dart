import 'dart:io';
import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/services/audio_service.dart';
import 'package:app_chat/services/local_storage_service.dart';
import 'package:app_chat/ui/common/ui_helpers.dart';
import 'package:app_chat/ui/utils/helpers.dart';
import 'package:app_chat/ui/utils/utiis.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

final _log = getLogger('ChatBubble');

class ChatBubble extends StatefulWidget {
  final String chatId;
  final MessageModel message;
  final bool isMe;
  final Function()? onTap;
  const ChatBubble({
    Key? key,
    required this.message,
    required this.chatId,
    required this.onTap,
    this.isMe = false,
  }) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  //final _log = getLogger('MyChatBubble');
  AudioPlayer? audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.message.audioUrl != '') {
      initAudio();
    } else if (widget.message.videoUrl != '') {
      initVideo();
    }
  }

  late VideoPlayerController _controller;

  void initVideo() {
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.message.videoUrl!));

    _controller.addListener(() {
      setState(() {});
    });
    // _controller.setLooping(true);
    // _controller.initialize().then((_) => setState(() {}));
    // _controller.play();
    _controller.initialize();
  }

  void playVideo() {
    _controller.play();
  }

  void pauseVideo() {
    _controller.pause();
  }

  void initAudio() {
    audioPlayer = AudioPlayer();
    if (mounted) {
      audioPlayer!.onPlayerStateChanged.listen((state) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      });

      audioPlayer!.onDurationChanged.listen((newDuration) {
        setState(() {
          duration = newDuration;
        });
      });

      audioPlayer!.onPositionChanged.listen((newPosition) {
        setState(() {
          position = newPosition;
        });
      });
    }
  }

  Future<void> downloadIt() async {
    widget.message.needToDownload = false;
    widget.message.isDownloading = true;
    setState(() {});
    try {
      final filePathDownloaded =
          await locator<LocalStorageService>().downloadFile(
        chatId: widget.chatId,
        isImage: true,
        message: widget.message,
      );
      widget.message.path = filePathDownloaded;
      widget.message.isDownloading = false;
    } on Exception catch (e) {
      _log.e(e);
      widget.message.hasError = true;
    }
    setState(() {});
  }

  @override
  void dispose() {
    if (audioPlayer != null) {
      audioPlayer!.dispose();
    }

    super.dispose();
  }

//no metodo downloadAudio, na primeira vez o audio eh baixado em cache, em um arquivo temporario.
  //todo: utisl

  Future<void> playAudio() async {
    final audioPath = await locator<LocalStorageService>().getAudioPath(
      chatId: widget.chatId,
      messageId: widget.message.id!,
    );
    await locator<AudioService>().playAudio(audioPath!);
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
                    await audioPlayer!.pause();
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

                        await audioPlayer!.seek(position);

                        await audioPlayer!.resume();
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

    Widget myImage() {
      //todo: exibir a imagem de acordo com as suas proprias dimensoes
      return widget.message.needToDownload
          ? decContainer(
              radius: 8,
              allPadding: 5,
              alignment: Alignment.center,
              width: screenWidth(context) / 2,
              height: screenWidth(context) / 2,
              color: const Color(0xff128c7e),
              child: GestureDetector(
                onTap: () => downloadIt(),
                child: const Icon(
                  Icons.download,
                  color: Colors.white,
                ),
              ),
            )
          : Stack(
              children: [
                decContainer(
                  radius: 8,
                  allPadding: 5,
                  width: screenWidth(context) / 2,
                  // height: screenWidth(context) / 2,
                  color: const Color(0xff128c7e),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: widget.message.isDownloading
                          ? const SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(),
                            )
                          :
                          // widget.message.path != null
                          //     ?
                          Image.file(
                              File(widget.message.path!),
                              fit: BoxFit.cover,
                              // width: 150,
                              // height: 150,
                            )
                      // : Image.network(
                      //     widget.message.imageUrl!,
                      //     fit: BoxFit.cover,
                      //     // width: 150,
                      //     // height: 150,
                      //   ),
                      ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: styledText(
                    text: timestampFormatted,
                    color: Colors.white,
                  ),
                )
              ],
            );
    }

    Widget myVideo() {
      return Stack(
        children: [
          decContainer(
            alignment: Alignment.center,
            width: screenWidth(context) / 2,
            height: screenWidth(context) / 2,
            color: Colors.blue,
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container(),
          ),
          Align(
            alignment: Alignment.center,
            child: decContainer(
              onTap: widget.onTap,
              // onTap: _controller.value.isPlaying
              //     ? () => pauseVideo()
              //     : () => playVideo(),
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 30,
              ),
            ),
          ),
          const Positioned(
            bottom: 5,
            child: Row(
              children: [
                //tempo atual
                //slide
                //tempo total
              ],
            ),
          )
        ],
      );
    }

    if (widget.message.message != '') {
      return myText();
    } else if (widget.message.audioUrl != '') {
      return myAudio();
    } else if (widget.message.videoUrl != '') {
      return myVideo();
    } else if (widget.message.imageUrl != '') {
      return myImage();
    }
    return Container();
  }
}
