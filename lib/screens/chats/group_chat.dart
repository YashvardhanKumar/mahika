import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:direct_caller_sim_choice/direct_caller_sim_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/custom_icon_icons.dart';
import '../../constants.dart';
import '../auth/components/swipe_gesture.dart';
import 'components/message form/message_form.dart';
import 'components/send_message_blob.dart';
import 'group_settings.dart';

class GroupChat extends StatefulWidget {
  const GroupChat(
      {Key? key, required this.chats, required this.user, required this.group})
      : super(key: key);
  final QuerySnapshot chats;
  final DocumentSnapshot group;
  final DocumentSnapshot user;

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  final audioPlayer = AudioPlayer();
  Offset drag = Offset.zero;
  DocumentSnapshot? replyData;

  @override
  void dispose() {
    audioPlayer.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.group['isGeneral']
            ? "General"
            : widget.group['collegeName'])),
        actions: [
          if (widget.user['category'] == 'Member')
            IconButton(
              icon: const Icon(
                Icons.call_rounded,
                size: 32,
              ),
              onPressed: () async {
                await HapticFeedback.vibrate();
                if (Platform.isAndroid) {
                  PermissionStatus? perm;
                  if (!(await Permission.phone.isGranted)) {
                    perm = await Permission.phone.request();

                    if (perm.isDenied) {
                      return;
                    }
                    // } else {
                    final DirectCaller directCaller = DirectCaller();
                    directCaller.makePhoneCall('1090');
                  }
                } else {
                  canLaunchUrl(Uri(
                    scheme: 'tel',
                    path: '+911090',
                  ));
                }
              },
            ),
          if(!widget.group['isGeneral'])
            IconButton(
              icon: const Icon(
                CustomIcon.settings,
                size: 32,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupSettings(
                      groupRef: widget.group.reference,
                      address: widget.group['collegeName'],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: widget.group.reference
              .collection('messages')
              .orderBy('timeSent', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!.docs;
              List<Widget> list = [];
              if (data.isNotEmpty) {
                final today = DateTime.now().day;
                DateTime day = data[0]['timeSent'].toDate().toLocal();
                int prevDay = 0;

                for (int i = 0; i < data.length; i++) {
                  list.add(
                    StreamBuilder<DocumentSnapshot>(
                        stream: data[i]['sentBy'].snapshots(),
                        builder: (context, person) {
                          if (person.hasData) {
                            bool isCur =
                                data[i]['sentBy'].id == auth.currentUser!.uid;

                            return SwipeGesture(
                              background: Container(),
                              threshold: 20,
                              onSwipeRight: () {
                                replyData = data[i];
                                setState(() {});
                              },
                              child: SendMessageBlob(
                                contentType: data[i]['message'].isEmpty? data[i]['contentType']:null,
                                replyRef: data[i]['replyTo'],
                                onCancel: () {
                                  replyData = null;
                                  setState(() {});
                                },
                                size: size,
                                fileMessage: data[i]['message'].isEmpty
                                    ? data[i]['fileMessage']
                                    : null,
                                message: data[i]['message'],
                                time: day,
                                isFirst: (i < data.length - 1 &&
                                        (data[i + 1]['sentBy'].id !=
                                                data[i]['sentBy'].id ||
                                            day.day >
                                                data[i + 1]['timeSent']
                                                    .toDate()
                                                    .toLocal()
                                                    .day)) ||
                                    i == data.length - 1,
                                isLast: (i > 0 &&
                                        (data[i]['sentBy'].id !=
                                                data[i - 1]['sentBy'].id ||
                                            data[i - 1]['timeSent']
                                                    .toDate()
                                                    .toLocal()
                                                    .day >
                                                day.day)) ||
                                    i == 0,
                                isRecieved: !isCur,
                                name: isCur ? 'You' : person.data?['name'],
                                audioPlayer: AudioPlayer(),
                                sender: person.data!,
                                messageData: data[i],
                              ),
                            );
                          }
                          return Container();
                        }),
                  );
                  int dayByNow = prevDay =
                      -day.difference(DateTime.now().toLocal()).inDays;
                  if (i < data.length - 1) {
                    prevDay = -(data[i + 1]['timeSent'] as Timestamp)
                        .toDate()
                        .toLocal()
                        .difference(day)
                        .inDays;
                    int day_ = day
                        .difference((data[i + 1]['timeSent'] as Timestamp)
                            .toDate()
                            .toLocal())
                        .inDays;
                    if (day_ != 0) {
                      String text = (dayByNow == 0)
                          ? 'Today'
                          : (dayByNow == 1)
                              ? 'Yesterday'
                              : DateFormat("dd/MM/yyyy").format(day);
                      list.add(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Material(
                                shape: const StadiumBorder(),
                                color: Colors.grey.shade200,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5.0),
                                  child: Text(
                                    text,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    day = (data[i + 1]['timeSent'] as Timestamp)
                        .toDate()
                        .toLocal();
                  }
                }
                prevDay = -day.difference(DateTime.now().toLocal()).inHours;
                String text = (prevDay >= 0 && prevDay < 24)
                    ? 'Today'
                    : (prevDay >= 24 && prevDay < 48)
                        ? 'Yesterday'
                        : DateFormat("dd/MM/yyyy").format(data[data.length - 1]
                                ['timeSent']
                            .toDate()
                            .toLocal());
                list.add(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Material(
                          shape: const StadiumBorder(),
                          color: Colors.grey.shade200,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5.0),
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox(
                height: size.height,
                child: Column(
                  children: [
                    Flexible(
                      child: ListView.builder(
                        itemCount: list.length,
                        reverse: true,
                        padding: const EdgeInsets.all(10),
                        itemBuilder: (BuildContext context, int index) {
                          return list[index];
                        },
                      ),
                    ),
                    MessageForm(
                      replyTo: replyData,
                      onCancel: () {
                        replyData = null;
                        setState(() {});
                      },
                      group: widget.group.reference,
                      sender: widget.user,
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(
                color: kColorDark,
              ),
            );
          }),
    );
  }
}