import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mahikav/model/community/community_model.dart';
import 'package:mahikav/screens/chats/components/controllers/group_chat_controller.dart';

import '../../../constants.dart';
import '../../home/communities/controllers/user_data_controller.dart';
import '../group_chat.dart';
import '../groups/controllers/group_controller.dart';

class GroupTile extends StatelessWidget {
  GroupTile({
    super.key,
    required this.idx,
  });

  final int idx;
  final c = Get.find<GroupController>();
  final u = Get.find<UserDataController>();

  @override
  Widget build(BuildContext context) {
    return GetX<MessageController>(
        init: MessageController(c.groups[idx].doc!.collection('messages')),
        builder: (m) {
          // c.groupChatData[widget.idx].value.messages;
          // if (message.hasData) {
          final curUser = u.users.where((element) => element.doc!.id == auth.currentUser!.uid).first;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: ListTile(
              tileColor: (m.notifications == 0) ? Colors.white : kColorLight,
              // clipBehavior: Clip.hardEdge,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              onTap: () async {
                m.updateNotification();
                await Get.to(
                  GroupChat(
                    user: curUser,
                    group: c.groups[idx],
                  ),
                );

                for (var z in m.messages) {
                  if (z.sentBy?.id == auth.currentUser!.uid) continue;
                  final value = await z.seen!.doc(auth.currentUser!.uid).get();
                  final data = SeenModel(
                      ref: firestore
                          .collection('users')
                          .doc(auth.currentUser!.uid),
                      seenAt: Timestamp.now());
                  value.reference.set(data.toJson());
                }
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
              subtitle: Builder(builder: (context) {
                if (m.messages.isNotEmpty) {
                  final curUsrId = auth.currentUser!.uid;
                  var data = m.messages.first;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ((data.sentBy?.id == curUsrId) ? 'You: ' : '') +
                            (data.message.isEmpty
                                ? 'Audio/video'
                                : data.message),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        // '',
                        ((data.timeSent.toDate().day == DateTime.now().day)
                                ? DateFormat.jm()
                                : DateFormat("dd/MM/yyyy"))
                            .format(data.timeSent.toDate()),
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
                c.groups[idx].isGeneral
                    ? 'General'
                    : c.groups[idx].collegeName ?? '',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              trailing: (m.notifications == 0)
                  ? null
                  : Material(
                      shape: const CircleBorder(),
                      color: kColorDark,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${m.notifications}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ),
          );
          //   }
          //   return Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          //     child: ListTile(
          //       tileColor: Colors.grey,
          //       // clipBehavior: Clip.hardEdge,
          //       contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //     ),
          //   );
        });
  }
}
