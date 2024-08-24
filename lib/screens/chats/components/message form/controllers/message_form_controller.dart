import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mahikav/components/getxcontroller/recording_controller.dart';
import 'package:mahikav/model/community/community_model.dart';
import 'package:mahikav/model/users/user_model.dart';

import '../../../../../components/record_player.dart';
import '../../../../../constants.dart';
import '../../../../../packages/thumbnailer.dart';

class MessageFormController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // String? message;
  final _ctrl = TextEditingController().obs;

  get ctrl => _ctrl; // Rx<Timer>? timer;
  // RxBool isRecorderReady = false.obs;
  final Rx<FocusNode> _focus = FocusNode().obs;

  FocusNode get focus => _focus.value;
  late final Rx<AnimationController> _expandController;

  AnimationController get expandController => _expandController.value;
  late final Rx<Animation<double>> _animation;
  Animation<double> get animation => _animation.value;

  final RxList<PlatformFile> _filesChoosen = <PlatformFile>[].obs;

  List<PlatformFile> get filesChoosen => _filesChoosen.toList();

  final RxList<String> _fileType = <String>[].obs;

  List<String> get fileType => _fileType.toList();

  final RxBool _expand = true.obs;

  bool get expand => _expand.value;

  final MessageModel? replyTo;
  final CollectionReference message;
  final UserModel sender;
  final VoidCallback? onCancel;

  MessageFormController(this.replyTo, this.message, this.sender, this.onCancel);

  final r = Get.put(RecordingController());

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    prepareAnimations();
    runExpandCheck();
    Thumbnailer.addCustomMimeTypesToIconDataMappings(<String, IconData>{
      'custom/mimeType': FontAwesomeIcons.key,
    });
  }

  @override
  void onClose() {
    _focus.value.dispose();
    _ctrl.value.dispose();
    // TODO: implement onClose
    super.onClose();
  }

  void fileIdentifier() {
    List<String> imageExt = ['jpg', 'jpeg', 'png', 'heic', 'webp'],
        audioExt = ['wav', 'aac', 'mp3', 'm4a'],
        videoExt = ['mp4', 'mkv', 'webm', 'wmv', 'm4v', 'h264', 'hevc'];
    // fileType = [];
    for (var file in filesChoosen) {
      if (imageExt.contains(file.extension!)) {
        _fileType.add('image');
      } else if (audioExt.contains(file.extension!)) {
        _fileType.add('audio');
      } else if (videoExt.contains(file.extension!)) {
        _fileType.add('video');
      } else {
        _fileType.add('none');
      }
    }
  }

  void prepareAnimations() {
    _expandController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200)).obs;
    _animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.easeIn,
    ).obs;
  }

  void runExpandCheck() {
    if (replyTo != null) {
      _expand.value = true;
      expandController.forward();
    } else {
      expandController.reverse().then((value) {
        _expand.value = false;
      });
    }
  }

  Future onPostFile(String url_, String type, String ext) async {
    File file = File(url_);
    String fileName = DateTime.now().toIso8601String();
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('$type/$fileName.$ext');
    UploadTask uploadTask = firebaseStorageRef.putFile(
        file, SettableMetadata(contentType: '$type/$ext'));
    String url = await uploadTask.whenComplete(() {}).then((value) {
      return value.ref.getDownloadURL();
    });
    final data = MessageModel(
        contentType: type,
        timeSent: Timestamp.now(),
        message: '',
        fileMessage: url,
        sentBy: firestore.collection('users').doc(auth.currentUser!.uid));
    await message.add(data).then(
          (value) async => await message.parent?.update({
            'updatedAt': Timestamp.now(),
          }),
        );
    Get.back();
  }

  void onPostMessage() async {
    await message.add(MessageModel(
            message: ctrl.text.trim(),
            sentBy: sender.doc,
            timeSent: Timestamp.now(),
            // 'isReply': widget.replyTo != null,
            replyTo: replyTo?.doc,
            contentType: 'text')
        .toJson());
    message.parent?.update({
      'updatedAt': Timestamp.now(),
    });
  }

  void onRemoveFile(int index) {
    _filesChoosen.removeAt(index);
    _fileType.removeAt(index);
  }

  void onPickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
      withReadStream: true,
    );
    if (result != null) {
      _filesChoosen.addAll(result.files);
      fileIdentifier();
    }
  }

  void onPickMediaFile() async {
    final result = await FilePicker
        .platform
        .pickFiles(
      type: FileType.media,
      allowMultiple: true,
      withReadStream: true,
    );
    if (result != null) {
      _filesChoosen
          .addAll(result.files);
      fileIdentifier();
    }
  }

  void onSendMessage() async {
    if (ctrl.text.isNotEmpty) {
      await message.add(MessageModel(
              message: ctrl.text.trim(),
              sentBy: sender.doc,
              timeSent: Timestamp.now(),
              replyTo: replyTo?.doc,
              contentType: 'text')
          .toJson());
      message.parent?.update({
        'updatedAt': Timestamp.now(),
      });
    } else {
      await HapticFeedback.lightImpact();
      if (r.recorder.isRecording) {
        r.stop(
          (value) => Get.to(
            RecordPlayerLocal(
              url: value,
              onPressed: () async {
                onPostFile(value, "audio", 'aac');
              },
              isEmergency: false,
            ),
          ),
        );
      } else {
        _filesChoosen.clear();
        _fileType.clear();
        _ctrl.value.clear();
        r.record(
          (value) => Get.to(
            RecordPlayerLocal(
              url: value,
              onPressed: () async {
                onPostFile(value, "audio", 'aac');
              },
              isEmergency: false,
            ),
          ),
        );
      }
    }
    if (onCancel != null) {
      onCancel!();
    }
  }

}
