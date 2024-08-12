import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/ui/common/ui_helpers.dart';
import 'package:app_chat/ui/utils/helpers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyChatBubble extends StatefulWidget {
  final MessageModel message;
  const MyChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<MyChatBubble> createState() => _MyChatBubbleState();
}

class _MyChatBubbleState extends State<MyChatBubble> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

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

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.stop);

//todo: logica para baixar a url lcoalmente
//todo: avertiguart se da p fzr aqui ou eh melhhor comecar o download logo la
//todo: quando chegar o snapshot no listener
    //final file = File(...);
    // audioPlayer.setSourceDeviceFile(file.path);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final timestampFormatted =
        DateFormat('HH:mm', 'pt_BR').format(widget.message.createdAt.toDate());

    Widget myText() {
      return decContainer(
        allPadding: 10,
        radius: 12,
        color: const Color(0xff128c7e),
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
        color: const Color(0xff128c7e),
        child: Row(
          children: [
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
              onPressed: () async {
                if (isPlaying) {
                  await audioPlayer.pause();
                  isPlaying = false;
                } else {
                  // await audioPlayer.resume();
                  await audioPlayer.play(UrlSource(widget.message.audioUrl!));
                }
              },
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

    // Widget myAudio() {
    //   return Container(
    //     color: Colors.green,
    //     child: Column(
    //       children: [
    //         styledText(
    //           text: timestampFormatted,
    //           color: Colors.white70,
    //         ),
    //         const Icon(
    //           Icons.audiotrack,
    //           size: 24,
    //           color: Colors.blue,
    //         ),
    //         IconButton(
    //           icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
    //           onPressed: () async {},
    //         ),
    //         Slider(
    //           min: 0,
    //           max: duration.inSeconds.toDouble(),
    //           value: position.inSeconds.toDouble(),
    //           onChanged: (value) async {},
    //         ),
    //         Expanded(
    //           child: Row(
    //             //  crossAxisAlignment: CrossAxisAlignment.end,
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               styledText(
    //                 text: formatDuration(duration),
    //                 color: Colors.white,
    //               ),
    //               styledText(
    //                 text: formatDuration(duration - position),
    //                 color: Colors.white,
    //               ),
    //             ],
    //           ),
    //         )
    //       ],
    //     ),
    //   );
    // }

    return widget.message.message != '' ? myText() : myAudio();
  }

  // Future<void> playAudio(String filePath) async {
  //   // Lógica para reproduzir o áudio (use o audioplayers)

  //   await audioPlayer.play(DeviceFileSource(filePath));
  // }

  // Future<String> downloadAudio(String url, String savePath) async {
  //   // Lógica para baixar o áudio (use o pacote http)
  //   return savePath;
  // }
}
