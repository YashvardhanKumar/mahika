// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../../constants.dart';
// import '../../model/emergency/emergency_model.dart';
//
// class PlayerController extends GetxController {
//   String fileName = 'audio';
//   String fileExtension = '.aac';
//   String directoryPath = '/storage/emulated/0/SoundRecorder';
//   RxInt tick = 10.obs;
//   Rx<Timer>? timer;
//   RxBool canPop = false.obs;
//   RxBool disableCancel = true.obs;
//   final AudioPlayer audioPlayer = AudioPlayer();
//   RxBool isPlaying = false.obs;
//   Rx<Duration> duration = Duration.zero.obs;
//   Rx<Duration> position = Duration.zero.obs;
//   final String url;
//   PlayerController(this.url);
//
//   @override
//   void onReady() {
//     // TODO: implement onReady
//     super.onReady();
//     // url = Get.arguments['url'] ?? '';
//     createFile();
//     setAudio();
//   }
//
//   @override
//   void onClose() {
//     disposePlayer();
//     // TODO: implement onClose
//     super.onClose();
//   }
//
//   void disposePlayer() {
//     audioPlayer.dispose();
//     timer?.value.cancel();
//   }
//
//   void createFile() async {
//     var status = await Permission.storage.status;
//     await Permission.audio.request();
//     Directory directory = Directory("");
//     if (!status.isGranted) {
//       // If not we will ask for permission first
//       await Permission.storage.request();
//       directory = Directory(directoryPath);
//     }
//     if (status.isDenied) {
//       directory = (await getExternalStorageDirectory())!;
//
//       print('Permission Denied');
//     }
//     print(directory.path);
//     var completeFileName = DateTime.now().toUtc().toIso8601String();
//     final exPath = directory.path;
//     await Directory(exPath).create(recursive: true);
//
//     File file = File(url);
//     //write to file
//     Uint8List bytes = await file.readAsBytes();
//     File writeFile = File("$exPath/$completeFileName$fileExtension");
//     await writeFile.writeAsBytes(bytes);
//     print(writeFile.path);
//     // }
//   }
//
//   Future setAudio() async {
//     audioPlayer.setReleaseMode(ReleaseMode.loop);
//     final file = File(url);
//     await audioPlayer.setSourceUrl(file.path);
//       timer = Timer.periodic(const Duration(seconds: 1), (time) {
//       if (time.tick == 10) {
//         timer?.value.cancel();
//         disableCancel.value = false;
//       }
//       tick--;
//       // setState(() {});
//     }).obs;
//     audioPlayer.onPlayerStateChanged.listen((state) {
//       isPlaying.value = state == PlayerState.playing;
//     });
//     audioPlayer.onDurationChanged.listen((newDuration) {
//       duration.value = newDuration;
//     });
//     audioPlayer.onPositionChanged.listen((newPosition) {
//       position.value = newPosition;
//     });
//   }
//
//   String formatTime(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final hours = twoDigits(duration.inHours);
//     final mins = twoDigits(duration.inMinutes.remainder(60));
//     final secs = twoDigits(duration.inSeconds.remainder(60));
//     return [
//       if (duration.inHours > 0) hours,
//       mins,
//       secs,
//     ].join(':');
//   }
//
//   Future<Position> _determinePosition() async {
//     LocationPermission permission;
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }
//     return await Geolocator.getCurrentPosition();
//   }
//
//   void onPost() async {
//     File file = File(this.url);
//     String fileName = DateTime.now().toIso8601String();
//     User? user = auth.currentUser;
//     if (user == null) {
//       await auth.signInAnonymously();
//     }
//     Reference firebaseStorageRef =
//         FirebaseStorage.instance.ref().child('audio/$fileName.aac');
//
//     UploadTask uploadTask = firebaseStorageRef.putFile(
//         file, SettableMetadata(contentType: 'audio/aac'));
//
//     String url = await uploadTask
//         .whenComplete(() {})
//         .then((value) => value.ref.getDownloadURL());
//
//     Position curPos = await _determinePosition();
//
//     List<Placemark> placemarks =
//         await placemarkFromCoordinates(curPos.latitude, curPos.longitude);
//
//     String? name;
//     if (FirebaseAuth.instance.currentUser != null) {
//       final user = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .get();
//       name = user['name'];
//     }
//     // final address = placemarks.first.toJson();
//     final data = EmergencyModel(
//       name: name,
//       address: placemarks.first,
//       audio: url,
//       isCreated: Timestamp.now(),
//       isSeen: false,
//     );
//     await FirebaseFirestore.instance.collection('emergency').add(data.toJson());
//     // Get.back();
//   }
// }
