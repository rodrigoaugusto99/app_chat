import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioPlayer? audioPlayer;

  void init() {
    audioPlayer = AudioPlayer();
  }

  Future setAudio() async {
    audioPlayer!.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playAudio(String filePath) async {
    await audioPlayer!.play(UrlSource(filePath));
  }
}
//todo: no  throw exception colocar mensagens fofas
//todo:no _log.e, colocar o erro pro dev
