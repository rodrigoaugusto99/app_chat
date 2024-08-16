import 'dart:io';

import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/ui/common/ui_helpers.dart';
import 'package:app_chat/ui/utils/helpers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

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
  final _log = getLogger('MyChatBubble');
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

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

  Future setAudio() async {
    //audioPlayer.setSourceBytes();
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

//no metodo downloadAudio, na primeira vez o audio eh baixado em cache, em um arquivo temporario.
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> listAllFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${widget.chatId}/';
    final files = Directory(filePath).listSync();

    if (files.isEmpty) {
      _log.e("Nenhum arquivo encontrado no diretório.");
    } else {
      for (var file in files) {
        _log.f('Arquivo encontrado: ${file.path}');
      }
    }
  }

  Future<void> playAudio() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/${widget.chatId}/${widget.message.id}.aac';

    final file = File(filePath);
    _log.i(file);
    if (await file.exists()) {
      // O arquivo existe, reproduza-o
      await audioPlayer.play(UrlSource(filePath));
    } else {
      // Lidar com o caso onde o arquivo não foi encontrado (talvez rebaixar)
      _log.e("Arquivo de áudio não encontrado.");
      await listAllFiles();
    }
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
