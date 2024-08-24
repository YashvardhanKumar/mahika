import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mahikav/admin%20functions/see_user_list_to_verify.dart';
import 'package:mahikav/screens/auth/pending_verification.dart';

import '../../admin functions/add_place_admin_func.dart';
import '../../components/emergency_buttons.dart';
import '../../constants.dart';
import '../chats/groups/community_topic.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
      firestore.collection('users').doc(auth.currentUser!.uid).snapshots(),
      builder: (context, userData) {
        if (userData.hasData) {
          print(userData.data!.data());
          if (userData.data!['category'] == 'Admin' || !(userData.data!['isVerifiedUser'] ?? false)) {
            return Scaffold(
              floatingActionButton:
              userData.hasData && userData.data!['category'] == 'Member'
                  ? EmergencyButtons()
                  : null,
              appBar: AppBar(
                title: const Text('Communities'),
                actions: [
                  if (userData.data!['category'] == 'Admin')
                    StreamBuilder<QuerySnapshot>(
                        stream: firestore
                            .collection('users')
                            .where("isVerifiedUser", isNull: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          return FilledButton.tonalIcon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserListToVerify(),
                                ),
                              );
                            },
                            icon: Icon(CupertinoIcons.person),
                            label: Text(
                                'New Users (${snapshot.data?.size ?? ''})'),
                          );
                        }),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.search_rounded))
                ],
              ),
              body: Builder(builder: (context) {
                bool isNotAdmin = userData.data!['category'] != 'Admin' &&
                    userData.data!['category'] != null;
                if (isNotAdmin &&
                    !(userData.data!['isVerifiedUser'] ?? false)) {
                  return pendingVerification(
                    userData.data!['isVerifiedUser'],
                  );
                }
                return ListView(
                  children: [
                    if (userData.data!['category'] == 'Admin')
                      ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddPlace_Admin(),
                            ),
                          );
                        },
                      ),
                    if (userData.data!['category'] == 'Admin')
                      const Divider(
                        indent: 20,
                        endIndent: 20,
                        height: 0,
                      ),
                    StreamBuilder<QuerySnapshot>(
                        stream: firestore.collection('communities').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final data = snapshot.data!.docs;
                            return Column(
                              children: List.generate(
                                snapshot.data!.size,
                                    (index) => Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Material(
                                    clipBehavior: Clip.hardEdge,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                CommunitiesTopicList(
                                                  community:
                                                  data[index],
                                                ),
                                          ),
                                        );
                                      },
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundColor: Colors.white,
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.all(5.0),
                                                  child: Image.asset(
                                                    'images/logo.png',
                                                    errorBuilder:
                                                        (context, obj, stack) =>
                                                        Icon(
                                                          Icons
                                                              .location_city_rounded,
                                                          size: 32,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data[index]['city'],
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    data[index]['state'],
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                      FontWeight.w600,
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
                              ),
                            );
                          }
                          return Center(
                            child: CircularProgressIndicator(color: kColorDark),
                          );
                        }),
                  ],
                );
              }),
            );
          }
          return StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('communities')
                  .where('city', isEqualTo: userData.data!['city'])
                  .where('state', isEqualTo: userData.data!['state'])
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CommunitiesTopicList(
                    community: snapshot.data!.docs.first,
                  );
                }
                return Center(
                  child: CircularProgressIndicator(color: kColorDark),
                );
              });
        }
        return const Center(
          child: CircularProgressIndicator(color: kColorDark),
        );
      },
    );
  }
}