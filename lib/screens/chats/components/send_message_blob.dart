import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mahikav/model/community/community_model.dart';

import '../../../constants.dart';
import 'message_audio_player.dart';

class SendMessageBlob extends StatelessWidget {
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
    this.onCancel, required this.messageData,
  });

  final DocumentReference? replyRef;
  final DocumentSnapshot sender;
  final MessageModel messageData;
  final String message;
  final DateTime time;
  final bool isFirst;
  final bool isLast;
  final Size size;
  final bool isRecieved;
  final String? name, fileMessage;
  final AudioPlayer audioPlayer;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    bool last = isLast && !isFirst;
    return Row(
      children: [
        if (!isRecieved) const Expanded(child: SizedBox()),
        Column(
          crossAxisAlignment:
              isRecieved ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: isFirst ? 5 : 1,
            ),
            if (isFirst) Text(name ?? ''),
            if (isFirst) const SizedBox(height: 5),
            Material(
              color: isRecieved ? const Color(0xffd9d9d9) : kColorDark,
              shape: RoundedRectangleBorder(
                borderRadius: (isRecieved)
                    ? BorderRadius.only(
                        topRight: const Radius.circular(15),
                        topLeft: (isFirst)
                            ? const Radius.circular(15)
                            : const Radius.circular(3),
                        bottomLeft: (last)
                            ? const Radius.circular(15)
                            : const Radius.circular(3),
                        bottomRight: const Radius.circular(15),
                      )
                    : BorderRadius.only(
                  topLeft: const Radius.circular(15),
                        topRight: (isFirst)
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
                    maxWidth: (size.width - 20) * 4 / 5, minWidth: 65),
                padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
                child: Column(
                  crossAxisAlignment: isRecieved
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (replyRef != null)
                      StreamBuilder<DocumentSnapshot>(
                          stream: replyRef!.snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return SizedBox();
                            return Material(
                              borderRadius: BorderRadius.vertical(
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
                                        sender.id ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                            ? "You"
                                            : sender['name'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        (snapshot.data!["message"].toString().isEmpty
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
                    if (replyRef != null) const SizedBox(height: 10),
                    Row(
                      mainAxisSize: (replyRef != null)
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      mainAxisAlignment: (replyRef != null)
                          ? MainAxisAlignment.spaceBetween
                          : isRecieved
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                      children: [
                        // if (!isRecieved) const SizedBox(),
                        Flexible(
                          child: Builder(builder: (context) {
                            if (fileMessage != null) {
                              return MessageAudioPlayer(
                                url: fileMessage!,
                                audioPlayer: audioPlayer,
                              );
                            }
                            return Text(
                              message,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: isRecieved ? null : Colors.white,
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
                        DateFormat.jm().format(time),
                        textAlign: TextAlign.end,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isRecieved
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


