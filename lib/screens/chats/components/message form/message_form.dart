import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mahikav/components/getxcontroller/recording_controller.dart';
import 'package:mahikav/model/users/user_model.dart';
import 'package:mahikav/screens/chats/components/message%20form/controllers/message_form_controller.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../components/custom_icon_icons.dart';
import '../../../../constants.dart';
import '../../../../model/community/community_model.dart';
import 'widgets/expandable_message_box_widget.dart';
import 'widgets/send_message_btn.dart';

class MessageForm extends StatelessWidget {
  MessageForm({
    super.key,
    required this.message,
    required this.sender,
    this.replyTo,
    this.onCancel,
  });

  final UserModel sender;
  final CollectionReference<Map<String, dynamic>> message;
  final MessageModel? replyTo;
  final VoidCallback? onCancel;
  final p = Get.put(RecordingController());

  // String? message;
  // final ctrl = TextEditingController();
  // final recorder = FlutterSoundRecorder();
  // Timer? timer;
  // bool isRecorderReady = false;
  // FocusNode focus = FocusNode();
  // late AnimationController expandController;
  // late Animation<double> animation;
  // List<PlatformFile> filesChoosen = [];
  // List<String> fileType = [];
  //
  // bool expand = true;

  // void fileIdentifier() {
  //   List<String> imageExt = ['jpg', 'jpeg', 'png', 'heic', 'webp'],
  //       audioExt = ['wav', 'aac', 'mp3', 'm4a'],
  //       videoExt = ['mp4', 'mkv', 'webm', 'wmv', 'm4v', 'h264', 'hevc'];
  //   fileType = [];
  //   for (var file in filesChoosen) {
  //     if (imageExt.contains(file.extension!)) {
  //       fileType.add('image');
  //     } else if (audioExt.contains(file.extension!)) {
  //       fileType.add('audio');
  //     } else if (videoExt.contains(file.extension!)) {
  //       fileType.add('video');
  //     } else {
  //       fileType.add('none');
  //     }
  //   }
  //   setState(() {});
  // }
  //
  // void prepareAnimations() {
  //   expandController = AnimationController(
  //       vsync: this, duration: const Duration(milliseconds: 200));
  //   animation = CurvedAnimation(
  //     parent: expandController,
  //     curve: Curves.easeIn,
  //   );
  // }
  //
  // void _runExpandCheck() {
  //   if (widget.replyTo != null) {
  //     expand = true;
  //     setState(() {});
  //     expandController.forward();
  //   } else {
  //     expandController.reverse().then((value) {
  //       expand = false;
  //       setState(() {});
  //     });
  //   }
  // }
  //
  // Future record() async {
  //   await recorder.startRecorder(toFile: 'audio');
  // }
  //
  // Future<String?> stop() async {
  //   timer?.cancel();
  //   return await recorder.stopRecorder();
  // }
  //
  // Future initRecorder() async {
  //   final status = await Permission.microphone.request();
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //   }
  //
  //   if (status != PermissionStatus.granted) {
  //     throw 'Microphone permission not granted';
  //   }
  //   await recorder.openRecorder();
  //   isRecorderReady = true;
  //   recorder.setSubscriptionDuration(const Duration(milliseconds: 1));
  // }
  //
  // Future<Position> _determinePosition() async {
  //   LocationPermission permission;
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //   return await Geolocator.getCurrentPosition();
  // }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   initRecorder();
  //   focus.requestFocus();
  //   prepareAnimations();
  //   _runExpandCheck();
  //   Thumbnailer.addCustomMimeTypesToIconDataMappings(<String, IconData>{
  //     'custom/mimeType': FontAwesomeIcons.key,
  //   });
  // }
  //
  // @override
  // void didUpdateWidget(MessageForm oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   _runExpandCheck();
  // }
  //
  // @override
  // void dispose() {
  //   expandController.dispose();
  //   timer?.cancel();
  //   focus.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return GetX<MessageFormController>(
        init: MessageFormController(replyTo, message, sender, onCancel),
        didUpdateWidget: (disposable, state) {
          state.controller?.runExpandCheck();
        },
        builder: (f) {
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              // border: Border(top: BorderSide()),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: ExpandableMessageBoxWidget(),
                ),
                const SizedBox(width: 10),
                SendMessageBtn(),
              ],
            ),
          );
        });
  }
}




