import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class UserListToVerify extends StatefulWidget {
  const UserListToVerify({super.key});

  @override
  State<UserListToVerify> createState() => _UserListToVerifyState();
}

class _UserListToVerifyState extends State<UserListToVerify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users to Approve"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('users')
              .where("isVerifiedUser", isNull: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.size,
                itemBuilder: (_, i) {
                  final d = snapshot.data!.docs[i];
                  return ListTile(
                    title: Text(d['name'] + '(${d['category']})'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApproveUser(
                            userRef: snapshot.data!.docs[i].reference,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}

class ApproveUser extends StatefulWidget {
  const ApproveUser({super.key, required this.userRef});

  final DocumentReference userRef;

  @override
  State<ApproveUser> createState() => _ApproveUserState();
}

class _ApproveUserState extends State<ApproveUser> {
  showdialog(bool approve) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Are you sure?'),
        content: Text(
            'Are you sure you ${approve ? '' : 'don\'t'} want to approve this user? This can be undone!'),
        actions: [
          CupertinoDialogAction(
            textStyle: const TextStyle(color: CupertinoColors.destructiveRed),
            // color: CupertinoColors.destructiveRed,
            child: const Text('No'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text("Yes"),
            onPressed: () {
              widget.userRef.update({
                "isVerifiedUser": approve,
              });
              Navigator.pop(context);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<DocumentSnapshot>(
            stream: widget.userRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final d = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("IDProof: ${d['IDProof']}"),
                        Text("category: ${d['category']}"),
                        Text("email: ${d['email']}"),
                        Text("name: ${d['name']}"),
                        Text("phoneNo: ${d['phoneNo']}"),
                        Text("city: ${d['city']}"),
                        Text("state: ${d['state']}"),
                      ],
                    ),
                    Builder(builder: (context) {
                      if (d['category'] == 'Member') {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("collegeAddress: ${d['collegeAddress']}"),
                            Text("studentID: ${d['studentID']}"),
                          ],
                        );
                      } else if (d['category'] == 'Police') {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("policeID: ${d['policeID']}"),
                            Text("post: ${d['post']}"),
                          ],
                        );
                      }
                      return Container();
                    }),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FilledButton(
                            onPressed: () {
                              showdialog(true);
                            },
                            child: const Text('Approve')),
                        FilledButton.tonal(
                            onPressed: () {
                              showdialog(false);
                            },
                            child: const Text('Don\'t Approve'))
                      ],
                    ),
                  ],
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}
