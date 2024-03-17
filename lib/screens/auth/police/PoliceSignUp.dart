import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../../components/text_form_field.dart';

import '../../../components/buttons/dropdown_text_field.dart';
import '../../../components/buttons/filled_buttons.dart';
import '../../../constants.dart';
import '../../home/home_page.dart';
import '../components/space_text_input_formatter.dart';
import '../otp_page.dart';

class PoliceSignUp extends StatefulWidget {
  const PoliceSignUp({Key? key}) : super(key: key);

  @override
  State<PoliceSignUp> createState() => _PoliceSignUp();
}

class _PoliceSignUp extends State<PoliceSignUp>
    with SingleTickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final policeIdCtrl = TextEditingController();
  final policePostCtrl = TextEditingController();
  final idProofCtrl = TextEditingController();
  final confPassCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();

  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  late final tabCtrl = TabController(length: 2, vsync: this);
  String? errorText, postError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: tabCtrl,
          tabs: const [
            Tab(
              text: 'Using Email',
            ),
            Tab(
              text: 'Using Phone',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabCtrl,
        children: List.generate(
          tabCtrl.length,
          (index) => SafeArea(
            child: ListView(
              children: [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (index == 0)
                          CustomTextFormField(
                            label: 'Email ID',
                            controller: emailCtrl,
                            hint: 'abc@example.com',
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Field is Required';
                              }
                              return errorText;
                            },
                          ),
                        if (index == 0)
                          const SizedBox(
                            height: 10,
                          ),
                        CustomTextFormField(
                          label: 'Phone No.',
                          controller: phoneCtrl,
                          hint: '00000 00000',
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
                            return errorText;
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          label: 'Police ID',
                          controller: policeIdCtrl,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Field is Required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomDropDownField(
                          label: 'Post',
                          controller: policePostCtrl,
                          listItems: const [
                            'Constable',
                            'Head Constable',
                            'Assistant Sub-Inspector',
                            'Sub-Inspector',
                            'Inspector',
                            'Deputy Superintendant of Police',
                            'Additional Superintendent of Police',
                            'Superintendent of Police',
                            'Senior Superintendent of Police',
                            'Deputy Inspector General of Police',
                            'Inspector-General of Police',
                            'Director-General of Police',
                          ],
                          errorText: postError,
                        ),
                        CustomTextFormField(
                          label: 'Name',
                          controller: nameCtrl,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Field is Required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          label: 'Aadhar Card No.',
                          controller: idProofCtrl,
                          hint: 'XXXX XXXX XXXX XXXX',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.singleLineFormatter,
                            LengthLimitingTextInputFormatter(16,maxLengthEnforcement: MaxLengthEnforcement.enforced),
                            SpaceTextInputFormatter(afterEvery: 4),
                          ],
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Field is Required';
                            }
                            return null;
                          },
                        ),
                        if (index == 0) const SizedBox(height: 10),
                        if (index == 0)
                          CustomTextFormField(
                            label: 'Password',
                            controller: passCtrl,
                            isPassword: true,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Field is Required';
                              }
                              return null;
                            },
                          ),
                        if (index == 0) const SizedBox(height: 10),
                        if (index == 0)
                          CustomTextFormField(
                            label: 'Confirm Password',
                            controller: confPassCtrl,
                            isPassword: true,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Field is Required';
                              } else if (val != passCtrl.text) {
                                return 'Password Doesn\'t Match';
                              }
                              return null;
                            },
                          ),
                        // SizedBox(height: 20),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomFilledButton(
          isClicked: isLoading,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (policePostCtrl.text.isEmpty) {
                postError = 'Add Post';
                setState(() {});
                return;
              }
              postError = null;
              isLoading = true;
              setState(() {});
              if (tabCtrl.index == 0) {
                try {

                  await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: emailCtrl.text,
                    password: passCtrl.text,
                  )
                      .then((value) {
                    firestore
                        .collection('users')
                        .doc(auth.currentUser!.uid)
                        .set({
                      'name': nameCtrl.text,
                      'email': emailCtrl.text,
                      'phoneNo': phoneCtrl.text,
                      'category': 'Police',
                      'IDProof': idProofCtrl.text,
                      'city': 'Gwalior',
                      'state': 'Madhya Pradesh',
                      'policeID': policeIdCtrl.text,
                      'post': policePostCtrl.text,
                      'isVerifiedUser': null,
                    }).then((value) {
                      isLoading = false;
                      setState(() {});
                    });
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => HomePage()),
                      (route) => false,
                    );
                    // TODO: Add Navigator to HomePage
                  });
                } on FirebaseAuthException catch (e) {
                  switch (e.code) {
                    case 'email-already-in-use':
                      {
                        errorText = 'Email already in use';
                        setState(() {});
                        break;
                      }
                    case 'invalid-email':
                      {
                        errorText = 'Invalid Email';
                        setState(() {});
                        break;
                      }
                    default:
                      {
                        errorText = 'Something Went Wrong';
                        setState(() {});
                        break;
                      }
                  }
                  _formKey.currentState!.validate();
                  errorText = null;
                  setState(() {});
                  return;
                }
              } else {
                await auth.verifyPhoneNumber(
                  phoneNumber: '+91${phoneCtrl.text}',
                  verificationCompleted: (PhoneAuthCredential credential) {
                    isLoading = false;
                    otpCtrl.text = credential.smsCode ?? '';
                    if (credential.smsCode != null) {
                      Clipboard.setData(
                          ClipboardData(text: credential.smsCode!));
                    }
                    setState(() {});
                  },
                  verificationFailed: (FirebaseAuthException e) {},
                  codeSent: (String verificationId, int? resendToken) {
                    setState(() {});
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OTPPage(
                          verificationId: verificationId,
                          resendToken: resendToken,
                          data: {
                            'name': nameCtrl.text,
                            'email': emailCtrl.text,
                            'phoneNo': phoneCtrl.text,
                            'category': 'Police',
                            'IDProof': idProofCtrl.text,
                            'city': 'Gwalior',
                            'state': 'Madhya Pradesh',
                            'policeID': policeIdCtrl.text,
                            'post': policePostCtrl.text,
                            'isVerifiedUser': null,
                          },
                          // otpCtrl: otpCtrl,
                        ),
                      ),
                    );
                  },
                  codeAutoRetrievalTimeout: (String verificationId) {},
                );
              }
            }
          },
          label: 'Sign Up',
        ),
      ),
    );
  }
}
