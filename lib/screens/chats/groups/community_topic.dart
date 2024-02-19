import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mahikav/components/buttons/filled_buttons.dart';
import 'package:mahikav/components/emergency_buttons.dart';
import 'package:mahikav/model/community/community_model.dart';
import 'package:mahikav/screens/home/first_page.dart';
import 'package:mahikav/screens/notifications.dart';

import '../../../admin functions/add_college_admin_function.dart';
import '../../../constants.dart';
import '../../../model/users/user_model.dart';
import '../../home/communities/controllers/user_data_controller.dart';
import '../components/group_tiles.dart';
import 'controllers/group_controller.dart';

// import '../../../components/custom_text.dart';
// import '../../../constants.dart';

class CommunitiesTopicList extends StatelessWidget {
  CommunitiesTopicList({Key? key, required this.community}) : super(key: key);
  final CommunityModel community;

  final c = Get.put(UserDataController());

  // final g = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    return GetX<GroupController>(
      init: GroupController(community.doc!.collection('groups')),
      initState: (state) {
        state.controller!.groupChatData
            .bindStream(state.controller!.getGroups());
      },
      builder: (g) {
        final curUser = c.users
            .where((element) => element.doc!.id == auth.currentUser!.uid)
            .first;
        return StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('emergency').snapshots(),
          builder: (_, notifications) {
            if (!notifications.hasData || curUser == null) return Container();
            int notification =
                notifications.data?.docs.where((e) => !e["isSeen"]).length ?? 0;
            return Scaffold(
              floatingActionButton: curUser.category == UserCategory.Member
                  ? EmergencyButtons()
                  : null,
              appBar: AppBar(
                title: Text('${curUser.city}, ${curUser.state}'),
                actions: [
                  if (curUser.category == UserCategory.Member)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        IconButton(
                          onPressed: () => Get.to(const Notifications()),
                          icon: const Icon(Icons.notifications),
                        ),
                        if (notification != 0)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Material(
                              color: Colors.red,
                              shape: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "$notification",
                                  style: GoogleFonts.sourceSansPro(
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  IconButton(
                      onPressed: () {
                        Get.defaultDialog(
                          title: "Nearby locations",
                          content: const Text(
                              'This feature is underway. Wait for the update!'),
                          actions: [
                            CustomFilledButton(
                              onPressed: Get.back,
                              label: 'Okay',
                            ),
                          ],
                        );
                      },
                      icon: const Icon(Icons.location_on_rounded)),
                  IconButton(
                    onPressed: () async {
                      await auth.signOut();
                      Get.offAll(const FirstPage());
                    },
                    icon: const Icon(Icons.logout_rounded),
                  )
                ],
              ),
              body: Builder(
                builder: (context) {
                  // if () {
                  var userData = curUser;
                  var groupList = g.groups;
                  List<Widget> list = [];
                  for (var z in groupList) {
                    if (userData.category == UserCategory.Member &&
                        !z.isGeneral &&
                        userData.collegeAddress != z.collegeName) {
                      continue;
                    }
                    list.add(
                      GroupTile(idx: list.length),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (userData.category == UserCategory.Admin)
                        ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          leading: const Icon(
                            Icons.add_location_alt_rounded,
                            size: 40,
                            color: kColorDark,
                          ),
                          title: Text(
                            'Add New College',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            Get.to(
                                AddCollege_Admin(
                                  community: community,
                                ),
                                arguments: {
                                  'community': community,
                                });
                          },
                        ),
                      if (userData.category == UserCategory.Admin)
                        const Divider(
                          indent: 20,
                          endIndent: 20,
                          height: 0,
                        ),
                      Column(
                        children: list,
                      ),
                    ],
                  );
                  // }
                  // return const Center(
                  //   child: CircularProgressIndicator(
                  //     color: kColorDark,
                  //   ),
                  // );
                },
              ),
            );
          },
        );
      },
    );
  }
}
