import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mahikav/screens/auth/pending_verification.dart';

import '../../admin functions/add_place_admin_func.dart';
import '../../components/emergency_buttons.dart';
import '../../constants.dart';
import '../../model/users/user_model.dart';
import '../chats/groups/community_topic.dart';
import 'communities/controllers/community_controller.dart';
import 'communities/controllers/user_data_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final c = Get.put<CommunityController>(CommunityController());
  final u = Get.find<UserDataController>();

  @override
  Widget build(BuildContext context) {
    final curUser = u.users
        .where((element) => element.doc!.id == auth.currentUser?.uid)
        .firstOrNull;
    if (curUser != null) {
      // print(userData.data!.data());
      if (curUser.category == UserCategory.Admin ||
          !(curUser.isVerifiedUser ?? false)) {
        return Scaffold(
          floatingActionButton: curUser.category == UserCategory.Member
              ? EmergencyButtons()
              : null,
          appBar: AppBar(
            title: const Text('Communities'),
            // actions: [
            //   IconButton(
            //       onPressed: () {},
            //       icon: const Icon(Icons.search_rounded))
            // ],
          ),
          body: Builder(builder: (context) {
            bool isNotAdmin = curUser.category != UserCategory.Admin;
            if (isNotAdmin && !(curUser.isVerifiedUser ?? false)) {
              return pendingVerification(
                curUser.isVerifiedUser,
              );
            }
            return ListView(
              children: [
                if (curUser.category == UserCategory.Admin)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: const Icon(
                      Icons.groups_rounded,
                      size: 45,
                      color: kColorDark,
                    ),
                    title: Text(
                      'Create New Community',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Get.to(const AddPlace_Admin());
                    },
                  ),
                if (curUser.category == UserCategory.Admin)
                  const Divider(
                    indent: 20,
                    endIndent: 20,
                    height: 0,
                  ),
                Column(
                  children: List.generate(
                    c.communities.length,
                    (index) => Material(
                      clipBehavior: Clip.hardEdge,
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xffeeeeee))),
                      child: InkWell(
                        onTap: () {
                          Get.to(
                            CommunitiesTopicList(
                              community: c.communities[index],
                            ),
                            arguments: {
                              'communities': c.communities[index],
                            },
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Image.asset(
                                    'images/logo.png',
                                    errorBuilder: (context, obj, stack) =>
                                        const Icon(
                                      Icons.location_city_rounded,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.communities[index].city,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    c.communities[index].state,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: kColorDark,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      }
      return Obx(() {
        final data = c.communities
            .where((p) => p.city == curUser.city && p.state == curUser.state);
        return CommunitiesTopicList(
          community: data.first,
        );
      });
    }
    return const Center(
      child: CircularProgressIndicator(color: kColorDark),
    );
    // },
    // );
    // ,
    // );
  }
}
