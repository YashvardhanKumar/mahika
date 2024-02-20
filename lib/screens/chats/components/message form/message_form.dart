import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../components/custom_icon_icons.dart';
import '../../../../components/record_player.dart';
import '../../../../constants.dart';
import '../../../../packages/thumbnailer.dart';


class MessageForm extends StatefulWidget {
  const MessageForm({
    super.key,
    required this.group,
    required this.sender,
    this.replyTo,
    this.onCancel,
  });

  final DocumentSnapshot sender;
  final DocumentReference group;
  final DocumentSnapshot? replyTo;
  final VoidCallback? onCancel;

  @override
  State<MessageForm> createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm>
    with SingleTickerProviderStateMixin {
  String? message;
  final ctrl = TextEditingController();
  final recorder = FlutterSoundRecorder();
  Timer? timer;
  bool isRecorderReady = false;
  FocusNode focus = FocusNode();
  late AnimationController expandController;
  late Animation<double> animation;
  List<PlatformFile> filesChoosen = [];
  List<String> fileType = [];

  bool expand = true;

  void fileIdentifier() {
    List<String> imageExt = ['jpg', 'jpeg', 'png', 'heic', 'webp'],
        audioExt = ['wav', 'aac', 'mp3','m4a'],
        videoExt = ['mp4', 'mkv', 'webm', 'wmv', 'm4v', 'h264', 'hevc'];
    fileType = [];
    for (var file in filesChoosen) {
      if (imageExt.contains(file.extension!)) {
        fileType.add('image');
      } else if (audioExt.contains(file.extension!)) {
        fileType.add('audio');
      } else if (videoExt.contains(file.extension!)) {
        fileType.add('video');
      } else {
        fileType.add('none');
      }
    }
    setState(() {});
  }

  void prepareAnimations() {
    expandController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.easeIn,
    );
  }

  void _runExpandCheck() {
    if (widget.replyTo != null) {
      expand = true;
      setState(() {});
      expandController.forward();
    } else {
      expandController.reverse().then((value) {
        expand = false;
        setState(() {});
      });
    }
  }

  Future record() async {
    await recorder.startRecorder(toFile: 'audio');
  }

  Future<String?> stop() async {
    timer?.cancel();
    return await recorder.stopRecorder();
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

  Future onPost(String url_, String type, String ext) async {
    File file = File(url_);
    String fileName = DateTime.now().toIso8601String();
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('$type/$fileName.$ext');
    UploadTask uploadTask = firebaseStorageRef.putFile(
        file, SettableMetadata(contentType: '$type/$ext'));
    String url = await uploadTask.whenComplete(() {}).then((value) {
      return value.ref.getDownloadURL();
    });
    // Position curPos = await _determinePosition();
    // List<Placemark> placemarks =
    //     await placemarkFromCoordinates(curPos.latitude, curPos.longitude);
    // placemarks[0];
    // String? name;
    // if (FirebaseAuth.instance.currentUser != null) {
    //   final user = await FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(FirebaseAuth.instance.currentUser!.uid)
    //       .get();
    //   name = user['name'];
    // }
    // final address = placemarks.first.toJson();
    // print(address);
    await widget.group.collection('messages').add({
      'fileMessage': url,
      'message': "",
      'sentBy': widget.sender.reference,
      'timeSent': Timestamp.now(),
      'replyTo': widget.replyTo?.reference,
      'contentType': type,
    }).then(
          (value) async => await widget.group.update({
        'updatedAt': Timestamp.now(),
      }),
    );
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initRecorder();
    focus.requestFocus();
    prepareAnimations();
    _runExpandCheck();
    Thumbnailer.addCustomMimeTypesToIconDataMappings(<String, IconData>{
      'custom/mimeType': FontAwesomeIcons.key,
    });
  }

  @override
  void didUpdateWidget(MessageForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    timer?.cancel();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Material(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(expand ? 20 : 32),
                  bottom: const Radius.circular(32)),
              color: Colors.grey.shade200,
              child: Column(
                children: [
                  if (expand)
                    SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            AnimatedContainer(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: const Border(
                                    left: BorderSide(
                                        color: kColorDark,
                                        width: 8,
                                        strokeAlign:
                                        BorderSide.strokeAlignInside)),
                                color: Colors.grey.shade50,
                              ),
                              duration: const Duration(milliseconds: 200),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.sender.id ==
                                                FirebaseAuth.instance
                                                    .currentUser!.uid
                                                ? "You"
                                                : widget.sender['name'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          if (widget.replyTo != null)
                                            Text(
                                              (widget.replyTo?["message"]
                                                  .toString()
                                                  .isEmpty ??
                                                  false)
                                                  ? widget
                                                  .replyTo!['contentType']
                                                  .toString()
                                                  : (widget.replyTo![
                                              "message"] ??
                                                  ''),
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Material(
                              shape: const CircleBorder(),
                              color: Colors.grey.shade100,
                              child: InkWell(
                                onTap: widget.onCancel,
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  if (filesChoosen.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade50,
                      ),
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: List.generate(filesChoosen.length, (index) {
                            final file = filesChoosen[index];
                            final filePut = File(file.path ?? '');
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    clipBehavior: Clip.hardEdge,
                                    child: Container(
                                      height: 70,
                                      width: 70,
                                      alignment: Alignment.center,
                                      color: kColorLight,
                                      child: Builder(builder: (context) {
                                        if (fileType[index] == 'image') {
                                          return Image.file(filePut,
                                              cacheHeight: 70, cacheWidth: 70);
                                        } else if (fileType[index] == 'video') {
                                          return FutureBuilder(
                                              future:
                                              VideoThumbnail.thumbnailData(
                                                video: filePut.path,
                                                imageFormat: ImageFormat.JPEG,
                                                maxWidth: 128,
                                                // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                                                quality: 25,
                                              ),
                                              builder: (_, data) {
                                                if (data.hasData &&
                                                    data.data != null) {
                                                  return Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Image.memory(
                                                        data.data!,
                                                        width: 70,
                                                        height: 70,
                                                        cacheWidth: 70,
                                                        cacheHeight: 70,
                                                      ),
                                                      Material(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                        color: Colors.white30,
                                                        child: Padding(
                                                          padding:
                                                          EdgeInsets.all(5),
                                                          child: Icon(
                                                              CustomIcon.play),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                                return const Icon(
                                                    CustomIcon.play);
                                              });
                                        } else if (fileType[index] == 'audio') {
                                          return const Icon(
                                              Icons.audiotrack_rounded);
                                        } else {
                                          return Column(
                                            children: [
                                              Icon(FontAwesomeIcons.file),
                                              Text(
                                                filesChoosen[index]
                                                    .extension
                                                    ?.toUpperCase() ??
                                                    '',
                                                style: TextStyle(fontSize: 12),
                                              )
                                            ],
                                          );
                                        }
                                      }),
                                    ),
                                  ),
                                ),
                                Material(
                                  shape: const CircleBorder(),
                                  color: Colors.grey.shade100,
                                  child: InkWell(
                                    onTap: () {
                                      filesChoosen.removeAt(index);
                                      fileType.removeAt(index);
                                      setState(() {});
                                    },
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  // if (widget.replyTo != null) const SizedBox(height: 10),
                  StreamBuilder<RecordingDisposition>(
                      stream: recorder.onProgress,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && recorder.isRecording) {
                          return Slider(
                            thumbColor: kColorDark,
                            label: snapshot.requireData.duration.toString(),
                            value: snapshot.requireData.duration.inMicroseconds
                                .toDouble(),
                            divisions: const Duration(minutes: 1, seconds: 30)
                                .inMicroseconds,
                            max: const Duration(minutes: 1, seconds: 30)
                                .inMicroseconds
                                .toDouble(),
                            onChanged: (val) {},
                          );
                        }
                        return TextFormField(
                          controller: ctrl,
                          focusNode: focus,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (val) {
                            message = val;
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            hintText: 'Send message',
                            hintStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                            suffixIcon: (ctrl.text == '') ?  Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.audio_file_outlined,
                                    size: 28,
                                  ),
                                  onPressed: () async {
                                    final result =
                                    await FilePicker.platform.pickFiles(
                                      type: FileType.audio,
                                      allowMultiple: true,
                                      withReadStream: true,
                                    );
                                    if (result != null) {
                                      filesChoosen.addAll(result.files);
                                      fileIdentifier();
                                      setState(() {});
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    CustomIcon.image_add,
                                    size: 28,
                                  ),
                                  onPressed: () async {
                                    final result =
                                    await FilePicker.platform.pickFiles(
                                      type: FileType.media,
                                      allowMultiple: true,
                                      withReadStream: true,
                                    );
                                    if (result != null) {
                                      filesChoosen.addAll(result.files);
                                      fileIdentifier();
                                      setState(() {});
                                    }
                                  },
                                ),
                              ],
                            ) : null,
                            isCollapsed: true,
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        );
                      }),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            shape: const CircleBorder(),
            color: kColorDark,
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () async {
                if (ctrl.text.isNotEmpty) {
                  await widget.group.collection('messages').doc().set({
                    'message': ctrl.text.trim(),
                    'sentBy': widget.sender.reference,
                    'timeSent': Timestamp.now(),
                    // 'isReply': widget.replyTo != null,
                    'replyTo': widget.replyTo?.reference,
                    'contentType': 'text'
                  });
                  await widget.group.update({
                    'updatedAt': Timestamp.now(),
                  });
                  //     .then(
                  //   (value) async => await value.update({
                  //     'updatedAt': Timestamp.now(),
                  //   }),
                  // );
                } else {
                  await HapticFeedback.lightImpact();
                  if(filesChoosen.isNotEmpty) {
                    for(int i = 0; i <filesChoosen.length; i++) {
                      onPost(filesChoosen[i].path!, fileType[i], filesChoosen[i].extension!);
                    }
                  } else if (recorder.isRecording) {
                    await stop().then(
                          (value) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecordPlayerLocal(
                            url: value!,
                            onPressed: () async {
                              await onPost(value, "audio", 'aac');
                            },
                            isEmergency: false,
                          ),
                        ),
                      ),
                    );
                  } else {
                    await record();
                    ctrl.clear();
                    filesChoosen.clear();
                    fileType.clear();
                    setState(() {});
                    timer = Timer(const Duration(minutes: 1, seconds: 30),
                            () async {
                          await stop().then(
                                (value) => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecordPlayerLocal(
                                  url: value!,
                                  onPressed: () async {
                                    await onPost(value, 'audio', 'aac');
                                  },
                                  isEmergency: true,
                                ),
                              ),
                            ),
                          );
                        });
                    setState(() {});
                  }
                }
                ctrl.clear();
                filesChoosen.clear();
                fileType.clear();
                if (widget.onCancel != null) {
                  widget.onCancel!();
                }
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: (ctrl.text.isEmpty)
                        ? Tween<double>(begin: 1.25, end: 1).animate(anim)
                        : Tween<double>(begin: 0.75, end: 1).animate(anim),
                    child: FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                        scale: anim,
                        child: child,
                      ),
                    ),
                  ),
                  child: (ctrl.text.isEmpty)
                      ? Icon(
                    recorder.isRecording
                        ? Icons.stop_rounded
                        : CustomIcon.mic,
                    color: Colors.white,
                    size: 25,
                    key: const ValueKey('mic'),
                  )
                      : const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 25,
                    key: ValueKey('send'),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}