import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioPlayer audioPlayer = AudioPlayer();

  void init() {}

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playAudio(String filePath) async {
    await audioPlayer.play(UrlSource(filePath));
  }
}
