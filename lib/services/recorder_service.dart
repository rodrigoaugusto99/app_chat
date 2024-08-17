import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class RecorderService {
  FlutterSoundRecorder? recorder;
  ValueNotifier<FlutterSoundRecorder?> recorderNotifier = ValueNotifier(null);

  void init() {
    recorder = FlutterSoundRecorder();
    recorderNotifier.value = recorder;
  }

  bool isRecorderReady = false;

  Future<void> initRecorder() async {
    var status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }

    await recorder!.openRecorder();

    isRecorderReady = true;

    recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future<File?> recordVoice() async {
    bool isGranted = await Permission.microphone.isGranted;
    // if (isGranted == false) {
    //   try {
    //     initRecorder();
    //   } on Exception catch (e) {
    //    // _log.e(e);
    //     return;
    //   }
    // }
    if (isGranted == false) return null;
    if (!isRecorderReady) return null;

    //se ja esta gravando
    if (recorder!.isRecording) {
      final path = await recorder!.stopRecorder();
      //isRecording.value = false;
      final audioFile = File(path!);
      return audioFile;
    } else {
      await recorder!.startRecorder(toFile: 'audio');
      //isRecording.value = true;
    }
    return null;
  }
}
