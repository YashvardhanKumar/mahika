import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mahikav/components/record_player.dart';

import '../constants.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firestore.collection('emergency').get().then((value) {
      for (var v in value.docs) {
        v.reference.update({"isSeen": true});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!['category'] == 'Member') {
                return const Center(
                  child: Text('Nothing to show!'),
                );
              }
              return StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('emergency').snapshots(),
                  builder: (context, emergency) {
                    List<Widget> list = [];
                    if (emergency.hasData) {
                      for (var i in emergency.data!.docs) {
                        if (i['address']['locality'].toString().toLowerCase().contains(snapshot.data!['city'].trim().toLowerCase())) {
                          list.add(
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5),
                              child: ListTile(
                                tileColor: Colors.white,
                                // clipBehavior: Clip.hardEdge,
                                contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                                onTap: () async {
                                  Get.to(const RecordPlayer(),
                                      arguments: {'url': i['audio']});
                                  // Navigator.push(context, MaterialPageRoute(builder: (_) => RecordPlayer(url: i['audio'],)));
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                leading: const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.emergency_rounded,
                                    color: kColorLight,
                                    size: 30,
                                  ),
                                ),
                                subtitle: Text(
                                  'Tap to listen recording proof!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                title: Text(
                                  '${snapshot.data!['name']} is in Danger!',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          );
                        }
                      }
                      return ListView.builder(itemBuilder: (_, i) => list[i],itemCount: list.length,);
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
