import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../record_player.dart';

class RecordingController extends GetxController {
  final recorder = FlutterSoundRecorder();
  Rx<Timer>? timer;
  RxBool isRecorderReady = false.obs;
  RxBool isRecording = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    initRecorder();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    disposeRecorder();
    super.onClose();
  }

  Future record(ValueChanged<String> onPressed) async {
    recorder.startRecorder(toFile: 'audio').then(
      (value) {
        isRecording.value = true;
        timer = Timer(
          const Duration(minutes: 1, seconds: 30),
          () => stop(onPressed),
        ).obs;
      },
    );
  }

  void stop(ValueChanged<String> onPressed) async {
    timer?.value.cancel();
    final val = await recorder.stopRecorder();
    isRecording.value = false;
    onPressed(val!);
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await recorder.openRecorder();
    isRecorderReady = true.obs;
    update();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 1));
  }

  void disposeRecorder() {
    timer?.value.cancel();
  }
}
