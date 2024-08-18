import 'dart:io';
import 'package:app_chat/app/app.logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class RecorderService {
  FlutterSoundRecorder? recorder;
  final _log = getLogger('RecorderService');

  final ValueNotifier<bool> isRecordingNotifier = ValueNotifier(false);

  Stream<RecordingDisposition>? get recordingProgressStream =>
      recorder?.onProgress;

  void dispose() {
    isRecordingNotifier.dispose();
  }

  Future<void> init() async {
    recorder = FlutterSoundRecorder();

    var status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }

    await recorder!.openRecorder();

    isRecorderReady = true;

    recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  bool isRecorderReady = false;

  Future<File?> recordVoice() async {
    bool isGranted = await Permission.microphone.isGranted;
    if (isGranted == false) return null;
    if (!isRecorderReady) return null;

    //se ja esta gravando
    if (recorder!.isRecording) {
      final path = await recorder!.stopRecorder();
      isRecordingNotifier.value =
          false; // Atualiza o ValueNotifier de isRecording
      final audioFile = File(path!);
      return audioFile;
    } else {
      await recorder!.startRecorder(toFile: 'audio');
      isRecordingNotifier.value =
          true; // Atualiza o ValueNotifier de isRecording
      _log.i('recording');
    }
    return null;
  }
}
