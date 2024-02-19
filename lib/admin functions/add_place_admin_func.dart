import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mahikav/constants.dart';

import '../components/buttons/filled_buttons.dart';
import '../components/text_form_field.dart';

class AddPlace_Admin extends StatefulWidget {
  const AddPlace_Admin({Key? key}) : super(key: key);

  @override
  State<AddPlace_Admin> createState() => _AddPlace_AdminState();
}

class _AddPlace_AdminState extends State<AddPlace_Admin> {
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Community'),
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
              label: 'City',
              controller: cityCtrl,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextFormField(
              label: 'State',
              controller: stateCtrl,
            ),
            const SizedBox(
              height: 20,
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
                  await firestore.collection('communities').add({
                    'city': cityCtrl.text,
                    'state': stateCtrl.text,
                  }).then(
                    (value) async {
                      await value.collection('groups').add({
                      'isGeneral': true,
                      'updatedAt': Timestamp.now(),
                    }).then((value) {
                        isClicked = false;
                        setState(() {});
                      });
                    },
                  );
                  Navigator.pop(context);
                },
          label: 'Create',
        ),
      ),
    );
  }
}
