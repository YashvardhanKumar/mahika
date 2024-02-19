import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mahikav/constants.dart';

class GroupSettings extends StatefulWidget {
  const GroupSettings(
      {super.key, required this.groupRef, required this.address});

  final DocumentReference groupRef;
  final String address;

  @override
  State<GroupSettings> createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<GroupSettings> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: widget.groupRef.snapshots(),
      builder: (context, group) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('collegeAddress', isEqualTo: widget.address)
              .snapshots(),
          builder: (context, users) {
            if (users.hasData) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('Group Settings'),
                ),
                body: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: const Center(
                        child: Text('Settings Features are underway!'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        'Group members',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: kColorDark,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Divider(),
                    Column(
                      children: List.generate(
                        users.data!.size,
                        (index) {
                          print(users.data!);
                          return ListTile(
                            leading: CircleAvatar(
                              child: Center(
                                child: Icon(Icons.person_rounded),
                              ),
                            ),
                            title: Text(users.data!.docs[index]['name']),
                            subtitle: Text(users.data!.docs[index]['category']),
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      },
    );
  }
}
