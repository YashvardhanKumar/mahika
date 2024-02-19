import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/buttons/filled_buttons.dart';
import '../../components/emergency_buttons.dart';
import '../../components/text_form_field.dart';
import 'components/space_text_input_formatter.dart';
import 'otp_page.dart';

class LoginWithPhone extends StatefulWidget {
  const LoginWithPhone({Key? key}) : super(key: key);

  @override
  State<LoginWithPhone> createState() => _LoginWithPhoneState();
}

class _LoginWithPhoneState extends State<LoginWithPhone> {
  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool resendOTP = false;
  String? code;
  QuerySnapshot? data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: EmergencyButtons(),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFormField(
                label: 'Phone No.',
                controller: phoneCtrl,
                hint: '00000 00000',
                keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                FilteringTextInputFormatter.singleLineFormatter,
                LengthLimitingTextInputFormatter(10,maxLengthEnforcement: MaxLengthEnforcement.enforced),
                SpaceTextInputFormatter(afterEvery: 5),
              ],
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Field is Required';
                  }
                  print(phoneCtrl.text);
                  if (data!.size == 0) {
                    isLoading = false;
                    setState(() {});
                    return 'Account doesn\'t exists!';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              CustomFilledButton(
                isClicked: isLoading,
                onPressed: () async {
                  isLoading = true;
                  setState(() {});
                  data = await FirebaseFirestore.instance
                      .collection('users')
                      .where('phoneNo', isEqualTo: phoneCtrl.text)
                      .get();
                  setState(() {});
                  if (_formKey.currentState!.validate()) {
                    await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: '+91${phoneCtrl.text}',
                      verificationCompleted:
                          (PhoneAuthCredential credential) {},
                      verificationFailed: (FirebaseAuthException e) {
                        print(e);
                      },
                      codeSent: (String verificationId, int? resendToken) {
                        code = verificationId;
                        isLoading = false;
                        setState(() {});
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OTPPage(
                              verificationId: verificationId,
                              resendToken: resendToken,
                            ),
                          ),
                        );
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {},
                    );
                  }
                },
                label: 'Send OTP',
              )
            ],
          ),
        ),
      ),
    );
  }
}
