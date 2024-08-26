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

final _log = getLogger('ChatBubble');

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
  AudioPlayer? audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.message.audioUrl != '') {
      initAudio();
    } else if (widget.message.imageUrl != '') {
      //initImage();
    }
  }

  // String getPossiblePath() {
  //   return '${locator<LocalStorageService>().directory!.path}/${widget.chatId}/${widget.message.id}.jpg';
  // }

  //String? imagePath;

  Future<void> initImage() async {
    // if (!widget.message.needToDownload) {
    //   imagePath = getPossiblePath();
    //   setState(() {});
    // }

    //se eu colocar esse delay, da tempo de esperar o downlaod local antes de pegar o arquivo.
    //se la retornou null, entao eu aqui na view la no build eu chamo o image.network
    //todo: e se eu fizer um singleton com os downloads? ai eu teria acesso aqui tbm no loading p baixar local
    // await Future.delayed(const Duration(seconds: 2));
//     final newImagePath = await locator<LocalStorageService>().getImagePath(
//       chatId: widget.chatId,
//       messageId: widget.message.id!,
//     );
//     // _log.v('image path from getImagePath(): $newImagePath');
//     // imagePath = newImagePath;
//     if (newImagePath == null) {
// //!se for null, quer dizer que nao tenho essa img no meu dispositivo, entao vai dar erro
// //ao exibir aqui. Entao, vou colocar uma flag nela p dizer que nao ta baixada.*/
//       widget.message.needToDownload = true;

//       /*isso acontece na primeira vez, que entra no listener essa mensagem.
//       pois a mensagem ja foi enviada para o firestore e pegamos o snapshot com
//       o listener antes mesmo de salvarmos essa foto localmente.

//       //!e se eu colocasse delay de 500 milisegundos pra carregar a imagem?
//       isso pode dar tempo, mas se for uma imagem mt grande, capaz de n ter problema tbm,
//       tipo ql o problema de ver imagem pela internet so naquele momento raro?

//       mas...se for video, demora mais para baixar, entao nao deve valer a pena colocar
//       esse delay. Que tal chamarmos o metodo de getVideoPath de tal segundo em tal segundo,
//       e vamos ficar ouvindo as respostas. enquanto continuar retornando null, estamos exibindo
//       o arquivo com network, mas no primeiro momento que retornar o caminho, entao podemos
//       atribuir o videoPath e chamar o setState pra comecar a usar o arquivo local ao inves do remoto.
//       */
//       _log.f('usando image.network');
//     }
//     setState(() {});
    //todo: se for null, eu poderia ja ter baixado la no chatviewmodel ne ou service??!?!?! ui !
    //nem da, pq de qlqr forma temos que fazer o doc p pegar o id da mensagem pra poder ai sim
//fazer o download com o arquivo com o nome correto, e nao tem await que faca o listener nao
//capturar quando esse novo doc for criado.

//a n ser que eu faca o id ser gerado por uuid p eu ter mais controle sobre isso

//     if (imagePath == null) {
// //se nao tem o arquivo, mostrar pela internet mesmo
//       imageFile = Image.network(imageUrl);
//     } else {
//       //se pegou o arquivo, mostre
//       imageFile = File(imagePath);
//     }
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
              alignment: Alignment.center,
              width: screenWidth(context) / 2,
              height: screenWidth(context) / 2,
              color: Colors.blue,
              child: GestureDetector(
                onTap: () => downloadIt(),
                child: const Icon(
                  Icons.download,
                  color: Colors.white,
                ),
              ),
            )
          : decContainer(
              width: screenWidth(context) / 50,
              // height: screenWidth(context) / 2,
              color: Colors.blue,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: widget.message.isDownloading
                      ? decContainer(
                          color: Colors.grey,
                          child: const CircularProgressIndicator(),
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
