import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mahikav/constants.dart';
import 'package:mahikav/model/colleges/college_model.dart';
import 'package:mahikav/model/community/community_model.dart';

import '../components/buttons/filled_buttons.dart';
import '../components/text_form_field.dart';

import 'package:flutter/material.dart';
import 'package:mahikav/constants.dart';

import '../components/buttons/filled_buttons.dart';
import '../components/text_form_field.dart';

class AddCollege_Admin extends StatefulWidget {
  const AddCollege_Admin({Key? key, required this.community}) : super(key: key);
  final DocumentSnapshot community;

  @override
  State<AddCollege_Admin> createState() => _AddCollege_AdminState();
}

class _AddCollege_AdminState extends State<AddCollege_Admin> {
  final collegeName = TextEditingController();
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add College'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            CustomTextFormField(
              label: 'College Name',
              controller: collegeName,
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomFilledButton(
          onPressed: isClicked
              ? null
              : () async {
            isClicked = true;
            setState(() {});
            await widget.community.reference.collection('groups').add({
              'collegeName': collegeName.text,
              'isGeneral': false,
              'updatedAt': Timestamp.now(),
            });
            firestore.collection('colleges').add({
              'collegeAddress': collegeName.text,
              'state': widget.community['state'],
              'city': widget.community['city'],
            }).then((value) {
              isClicked = false;
              setState(() {});
            });
            Navigator.pop(context);
          },
          label: 'Create',
        ),
      ),
    );
  }
}