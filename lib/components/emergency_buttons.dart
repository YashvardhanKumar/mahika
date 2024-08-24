import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:call_log/call_log.dart';
import 'package:workmanager/workmanager.dart';

import 'custom_icon_icons.dart';
import 'record_player.dart';

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("Native called background task: $task"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

class EmergencyButtons extends StatefulWidget {
  const EmergencyButtons({Key? key}) : super(key: key);

  @override
  State<EmergencyButtons> createState() => _EmergencyButtonsState();
}

class _EmergencyButtonsState extends State<EmergencyButtons> {
  final recorder = FlutterSoundRecorder();
  Timer? timer;
  bool isRecorderReady = false;
  bool isStart = false;
  bool v_down = false;
  bool v_up = false;
  static const platform =
      MethodChannel('volume_double_click');

// Get battery level.

  Future<void> checkVolumeUpandDown() async {
    Workmanager().initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );
    Workmanager().registerOneOffTask("record-audio", "Recording",   constraints: Constraints(
      // connected or metered mark the task as requiring internet
      networkType: NetworkType.connected,
      // require external power
      requiresCharging: false,
    ),);
    platform.setMethodCallHandler((call) {
      if (call.method == "volumeBtnPressed" && call.arguments == true) {
        print(call);
        onRecordClick(context);
      }
      return Future.value(null);
    });

    // setState(() {
    //   _batteryLevel = batteryLevel;
    // });
  }

  Future record() async {
    isStart = true;
    setState(() {});
    await recorder.startRecorder(toFile: 'audio');
  }

  Future<String?> stop() async {
    timer?.cancel();
    isStart = false;
    setState(() {});
    return await recorder.stopRecorder();
  }

  Future initRecorder() async {
    // PermissionStatus status1 = await Permission.storage.request();
    // PermissionStatus status1 = await Permission.accessMediaLocation.request();
    // PermissionStatus status1 = await Permission.audio.request();
    final status = await Permission.microphone.request();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(const Duration(milliseconds: 1));
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future onPost(String url_) async {
    File file = File(url_);
    String fileName = DateTime.now().toIso8601String();
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('audio/$fileName.aac');
    UploadTask uploadTask = firebaseStorageRef.putFile(
        file, SettableMetadata(contentType: 'audio/aac'));
    String url = await uploadTask.whenComplete(() {}).then((value) {
      return value.ref.getDownloadURL();
    });
    Position curPos = await _determinePosition();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(curPos.latitude, curPos.longitude);
    placemarks[0];
    String? name;
    if (FirebaseAuth.instance.currentUser != null) {
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      name = user['name'];
    }
    final address = placemarks.first.toJson();
    await FirebaseFirestore.instance.collection('emergency').add({
      if (name != null) 'name': name,
      'audio': url,
      'address': address,
      'isCreated': DateTime.now().toUtc(),
      'isSeen': false,
    });
    Navigator.pop(context);
  }

  onRecordClick(BuildContext context) async {
    await HapticFeedback.vibrate();
    if (recorder.isRecording) {
      await stop().then(
            (value) => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecordPlayerLocal(
              url: value!,
              onPressed: () async {
                await onPost(value);
              },
            ),
          ),
        ),
      );
    } else {
      await record();
      timer = Timer(const Duration(minutes: 1, seconds: 30), () async {
        await stop().then(
              (value) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecordPlayerLocal(
                url: value!,
                onPressed: () async {
                  await onPost(value);
                },
              ),
            ),
          ),
        );
      });
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initRecorder();

    checkVolumeUpandDown();
  }

  @override
  void dispose() {
    timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          backgroundColor: Colors.red.shade900,
          child: Icon(
            isStart ? Icons.stop_rounded : CustomIcon.mic,
            color: Colors.white,
          ),
          onPressed: () async {
            await HapticFeedback.vibrate();
            if (recorder.isRecording) {
              await stop().then(
                (value) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordPlayerLocal(
                      url: value!,
                      onPressed: () async {
                        await onPost(value);
                      },
                    ),
                  ),
                ),
              );

            } else {
              await record();
              timer = Timer(const Duration(minutes: 1, seconds: 30), () async {
                await stop().then(
                  (value) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecordPlayerLocal(
                        url: value!,
                        onPressed: () async {
                          await onPost(value);
                        },
                      ),
                    ),
                  ),
                );
              });
              setState(() {});
            }
          },
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          backgroundColor: Colors.green,
          child: const Icon(
            Icons.call,
            color: Colors.white,
          ),
          onPressed: () async {
            await HapticFeedback.vibrate();

            PermissionStatus? perm;
            if (!(await Permission.phone.isGranted)) {
              perm = await Permission.phone.request();

              if (perm.isDenied) {
                return;
              }
              // } else {
            }
            const number = '1091'; //set the number here
            bool? res = await FlutterPhoneDirectCaller.callNumber(number);
            var now = DateTime.now();
            int from = now.millisecondsSinceEpoch;
            int to = now.subtract(Duration(hours: 12)).millisecondsSinceEpoch;
            Iterable<CallLogEntry> entries = await CallLog.query(
              dateFrom: from,
              dateTo: to,
              number: '1091',
            );
            print(entries.toList());
          },
        ),
      ],
    );
  }
}
