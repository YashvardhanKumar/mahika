import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mahikav/components/custom_icon_icons.dart';
import 'package:mahikav/screens/chats/components/message%20form/widgets/message_video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../constants.dart';
import '../../../packages/thumbnailer.dart';
import 'message_audio_player.dart';

class SendMessageBlob extends StatefulWidget {
  const SendMessageBlob({
    super.key,
    required this.size,
    this.replyRef,
    required this.message,
    required this.time,
    this.isFirst = false,
    this.isLast = false,
    this.isRecieved = false,
    required this.name,
    this.fileMessage,
    required this.audioPlayer,
    required this.sender,
    this.onCancel,
    required this.messageData,
    this.contentType,
  });

  final DocumentReference? replyRef;
  final DocumentSnapshot sender;
  final DocumentSnapshot messageData;
  final String message;
  final DateTime time;
  final bool isFirst;
  final bool isLast;
  final Size size;
  final bool isRecieved;
  final String? name, fileMessage, contentType;
  final AudioPlayer audioPlayer;
  final VoidCallback? onCancel;

  @override
  State<SendMessageBlob> createState() => _SendMessageBlobState();
}

class _SendMessageBlobState extends State<SendMessageBlob> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Thumbnailer.addCustomMimeTypesToIconDataMappings(<String, IconData>{
      'custom/mimeType': FontAwesomeIcons.key,
    });
  }

  @override
  Widget build(BuildContext context) {
    bool last = widget.isLast && !widget.isFirst;
    return Row(
      children: [
        if (!widget.isRecieved) const Expanded(child: SizedBox()),
        Column(
          crossAxisAlignment: widget.isRecieved
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: widget.isFirst ? 5 : 1,
            ),
            if (widget.isFirst) Text(widget.name ?? ''),
            if (widget.isFirst) const SizedBox(height: 5),
            Material(
              color: widget.isRecieved ? const Color(0xffd9d9d9) : kColorDark,
              shape: RoundedRectangleBorder(
                borderRadius: (widget.isRecieved)
                    ? BorderRadius.only(
                        topRight: const Radius.circular(15),
                        topLeft: (widget.isFirst)
                            ? const Radius.circular(15)
                            : const Radius.circular(3),
                        bottomLeft: (last)
                            ? const Radius.circular(15)
                            : const Radius.circular(3),
                        bottomRight: const Radius.circular(15),
                      )
                    : BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: (widget.isFirst)
                            ? const Radius.circular(15)
                            : const Radius.circular(3),
                        bottomRight: (last)
                            ? const Radius.circular(15)
                            : const Radius.circular(3),
                        bottomLeft: const Radius.circular(15),
                      ),
              ),
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: (widget.size.width - 20) * 4 / 5, minWidth: 65),
                padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
                child: Column(
                  crossAxisAlignment: widget.isRecieved
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.replyRef != null)
                      StreamBuilder<DocumentSnapshot>(
                          stream: widget.replyRef!.snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            return Material(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                  bottom: Radius.circular(32)),
                              color: Colors.grey.shade200,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  // border: Border(
                                  //   left: BorderSide(
                                  //     color: kColorDark,
                                  //     width: 8,
                                  //     strokeAlign: BorderSide.strokeAlignInside,
                                  //   ),
                                  // ),
                                  color: Colors.grey.shade50,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        widget.sender.id ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                            ? "You"
                                            : widget.sender['name'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        (snapshot.data!["message"]
                                                .toString()
                                                .isEmpty
                                            ? "Audio"
                                            : snapshot.data!["message"]),
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    if (widget.replyRef != null) const SizedBox(height: 10),
                    Row(
                      mainAxisSize: (widget.replyRef != null)
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      mainAxisAlignment: (widget.replyRef != null)
                          ? MainAxisAlignment.spaceBetween
                          : widget.isRecieved
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                      children: [
                        // if (!isRecieved) const SizedBox(),
                        Flexible(
                          child: Builder(builder: (context) {
                            if (widget.contentType != null &&
                                widget.contentType != 'text') {
                              if (widget.contentType == 'audio') {
                                return MessageAudioPlayer(
                                  url: widget.fileMessage!,
                                  audioPlayer: widget.audioPlayer,
                                );
                              } else if (widget.contentType == 'image') {
                                return Container(
                                  decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                                  constraints: const BoxConstraints(
                                    minHeight: 50,
                                    maxHeight: 500,
                                    minWidth: 50,
                                  ),
                                  child: Image.network(
                                    widget.fileMessage!,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } else {
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(MessageVideoPlayer(
                                        url: widget.fileMessage!));
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: ShapeDecoration(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minHeight: 50,
                                          maxHeight: 500,
                                          minWidth: 50,
                                        ),
                                        child: FutureBuilder(
                                            future:
                                                VideoThumbnail.thumbnailData(
                                              video: widget.fileMessage!,
                                              imageFormat: ImageFormat.JPEG,
                                              maxWidth: 128,
                                              // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                                              quality: 25,
                                            ),
                                            builder: (context, data) {
                                              if (data.hasData) {
                                                return Image.memory(data.data!);
                                              } else {
                                                return Container();
                                              }
                                            }),
                                      ),
                                      Material(
                                        color: Colors.white38,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: const Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: Icon(
                                            CustomIcon.play,
                                            size: 28,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                            }
                            return Text(
                              widget.message,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: widget.isRecieved ? null : Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }),
                        ),
                        // if (isRecieved) Flexible(child: const SizedBox()),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        DateFormat.jm().format(widget.time),
                        textAlign: TextAlign.end,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: widget.isRecieved
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // if (isRecieved) Expanded(child: SizedBox()),
      ],
    );
  }
}
