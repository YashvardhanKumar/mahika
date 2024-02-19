import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahikav/apis/auth_api.dart';

import '../../components/buttons/filled_buttons.dart';
import '../../components/emergency_buttons.dart';
import '../../components/text_form_field.dart';
import '../../constants.dart';
import '../home/home_page.dart';
import 'login_with_phone.dart';
import 'police/PoliceSignUp.dart';
import 'student/StudentSignUp.dart';

class LoginSignUp extends StatefulWidget {
  const LoginSignUp({Key? key, required this.isPolice}) : super(key: key);
  final bool isPolice;

  @override
  State<LoginSignUp> createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? errorText;
  final _formKey = GlobalKey<FormState>();
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: EmergencyButtons(),
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextFormField(
                      label: 'Email ID',
                      controller: emailCtrl,
                      hint: 'abc@example.com',
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Field is Required';
                        }
                        if (errorText != 'Wrong Password') {
                          return errorText;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      label: 'Password',
                      controller: passCtrl,
                      isPassword: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Field is Required';
                        }
                        if (errorText == 'Wrong Password') {
                          return errorText;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomFilledButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          isClicked = true;
                          setState(() {});
                          AuthAPI.loginWithEmail(emailCtrl.text, passCtrl.text)
                              .then((value) {
                            errorText = value;
                            if (_formKey.currentState!.validate()) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                                (_) => false,
                              );
                            }
                            isClicked = false;
                            setState(() {});
                          });
                        }
                      },
                      label: 'Login',
                    ),
                    const SizedBox(height: 20),
                    CupertinoButton(
                      child: const Text(
                        'Login with phone number',
                        style: TextStyle(
                          color: kColorDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {
                        Get.to(const LoginWithPhone());
                      },
                    ),
                    const SizedBox(height: 20),
                    CupertinoButton(
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: kColorDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {},
                    ),
                    const Text(
                      'or',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomOutlineButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => (widget.isPolice)
                                ? const PoliceSignUp()
                                : const StudentSignUp(),
                          ),
                        );
                      },
                      label: 'Create an Account',
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
