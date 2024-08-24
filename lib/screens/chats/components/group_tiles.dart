import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../constants.dart';
import '../group_chat.dart';

class GroupTile extends StatefulWidget {
  const GroupTile({
    super.key,
    required this.userData,
    required this.community,
  });

  final DocumentSnapshot userData;
  final QueryDocumentSnapshot community;

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  Future updateNotification() async {
    notifications = 0;
    await widget.community.reference
        .collection('messages')
        .orderBy('timeSent', descending: true)
        .get()
        .then((message) {
      for (QueryDocumentSnapshot z in message.docs) {
        if (z['sentBy'].id == auth.currentUser!.uid) continue;
        z.reference.collection('seen').doc(auth.currentUser!.uid).get().then(
              (value) {
            if (!value.exists) {
              notifications++;
              setState(() {});
            }
          },
        );
      }
    });
  }

  int notifications = 0;
  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateNotification();
    // timer = Timer.periodic(
    //   const Duration(seconds: 1),
    //   (_) async {
    //     await updateNotification();
    //   },
    // );
  }

  @override
  void dispose() {
    // timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: widget.community.reference
            .collection('messages')
            .orderBy('timeSent', descending: true)
            .snapshots(),
        builder: (context, message) {
          if (message.hasData) {
            return Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: ListTile(
                tileColor: (notifications == 0) ? Colors.white : kColorLight,
                // clipBehavior: Clip.hardEdge,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                onTap: () async {
                  notifications = 0;
                  setState(() {});
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupChat(
                        chats: message.data!,
                        user: widget.userData,
                        group: widget.community,
                      ),
                    ),
                  ).then((value) async {
                    for (QueryDocumentSnapshot z in message.data!.docs) {
                      if (z['sentBy'].id == auth.currentUser!.uid) continue;
                      await z.reference
                          .collection('seen')
                          .doc(auth.currentUser!.uid)
                          .get()
                          .then(
                            (value) async {
                          if (!value.exists) {
                            await value.reference.set({
                              'ref': widget.userData.reference,
                              'seenAt': Timestamp.now(),
                            });
                          }
                        },
                      );
                    }
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: const CircleAvatar(
                  radius: 25,
                  backgroundColor: kColorDark,
                  child: Icon(
                    Icons.school_rounded,
                    color: kColorLight,
                    size: 30,
                  ),
                ),
                subtitle: StreamBuilder<DocumentSnapshot>(
                    stream: (message.data?.docs.isNotEmpty ?? false)
                        ? message.data?.docs.first.reference.snapshots()
                        : null,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.data;
                        final curUsrId = auth.currentUser!.uid;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ((data!['sentBy'].id == curUsrId)
                                  ? 'You: '
                                  : '') +
                                  (snapshot.data!['message'].isEmpty
                                      ? snapshot.data!['contentType']
                                      : snapshot.data!['message']),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              // '',
                              ((data['timeSent'].toDate().day ==
                                  DateTime.now().day)
                                  ? DateFormat.jm()
                                  : DateFormat("dd/MM/yyyy"))
                                  .format(data['timeSent'].toDate()),
                              style: GoogleFonts.poppins(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      }
                      return const Text('No Messages');
                    }),
                title: Text(
                  widget.community['isGeneral']
                      ? 'General'
                      : widget.community['collegeName'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                trailing: (notifications == 0)
                    ? null
                    : Material(
                  shape: const CircleBorder(),
                  color: kColorDark,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '$notifications',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: ListTile(
              tileColor: Colors.grey,
              // clipBehavior: Clip.hardEdge,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        });
  }
}