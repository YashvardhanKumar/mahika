import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '../../constants.dart';
import '../home/home_page.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({
    Key? key,
    required this.verificationId,
    this.data,
    required this.resendToken,
  }) : super(key: key);
  final String verificationId;
  final int? resendToken;
  final Map<String, dynamic>? data;

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  // final List<FocusNode> focusNode = [];
  // final List<TextEditingController> controllers = [];
  final otpCtrl = TextEditingController();
  final otpFocus = FocusNode();
  String? errorText;
  Timer? timer;
  Timer? resendTimer;
  bool isSent = false;

  // String? verifyOTP;
  int? tick;

  // IOWebSocketChannel? _channel;

  @override
  void initState() {
    // focusNode[i].dispose();
    // for (int i = 0; i < 6; i++) {
    //   // focusNode.add(FocusNode());
    //   controllers.add(TextEditingController());
    // }
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    resendTimer?.cancel();
    // for (int i = 0; i < 6; i++) {
    //   // focusNode[i].dispose();
    //   // controllers[i].dispose();
    // }
    otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        leadingWidth: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Verify your Account',
              style: GoogleFonts.poppins(
                  fontSize: 28, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            Pinput(
              length: 6,
              androidSmsAutofillMethod:
                  AndroidSmsAutofillMethod.smsUserConsentApi,
              defaultPinTheme: PinTheme(
                textStyle: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SourceSansPro',
                ),
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: (otpCtrl.text.isNotEmpty)
                          ? Colors.black
                          : const Color(0xffD8DADC),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              focusedPinTheme: PinTheme(
                  textStyle: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SourceSansPro',
                  ),
                  decoration: BoxDecoration(
                    border: const Border.fromBorderSide(
                      BorderSide(
                        width: 2,
                        color: Colors.black,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  )),
              errorPinTheme: PinTheme(
                textStyle: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SourceSansPro',
                ),
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.red.shade800),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              controller: otpCtrl,
              focusNode: otpFocus,
              keyboardAppearance: Brightness.light,
              validator: (pin) {
                if (pin == null || pin.isEmpty) {
                  return 'Please enter the code';
                }
                if (pin.length < 4) {
                  return 'Please enter the complete pin';
                }
                return null;
              },
              onChanged: (pin) {
                if (pin.length == 6) {
                  continueFunction();
                } else {
                  setState(() {});
                }
              },
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Row(
            //     children: List.generate(
            //       6,
            //       (index) => Flexible(
            //         child: OTPBox(
            //           errorText: errorText,
            //           controller: controllers[index],
            //           // focusNode: focusNode[index],
            //           onChanged: (value) {
            //             if (value.length > 1 && index < 5) {
            //               String text = value;
            //               for(int i = 0; i < 6 - index; i++) {
            //                 controllers[index + i].text = text.substring(i,i + 1);
            //                 FocusScope.of(context).nextFocus();
            //               }
            //               // controllers[index + 1].text =
            //               //     controllers[index].text.substring(index + 1);
            //               setState(() {});
            //               // controllers[index].text = controllers[index + 1].text.substring(index,index + 1);
            //             }
            //             if (index == 5) {
            //               FocusScope.of(context).unfocus();
            //               continueFunction();
            //               return;
            //             }
            //             print('1 : ${controllers[0].text}');
            //             print('2 : ${controllers[1].text}');
            //             print('3 : ${controllers[2].text}');
            //             print('4 : ${controllers[3].text}');
            //             print('5 : ${controllers[4].text}');
            //             print('6 : ${controllers[5].text}');
            //           },
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  child: Text(
                    'Resend?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: kColorDark,
                    ),
                  ),
                  onPressed: (tick == null || tick != 0) ? null : () async {},
                ),
                const SizedBox(
                  width: 5,
                ),
                if (tick != null && tick != 0)
                  Text(
                    '$tick s',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void continueFunction() async {
    // String otp = '';
    //
    // for (int i = 0; i < 6; i++) {
    //   if (controllers[i].text.isEmpty) {
    //     return;
    //   }
    //   otp += controllers[i].text;
    //   controllers[i].clear();
    // }

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: otpCtrl.text,
    );

    // Sign the user in (or link) with the credential

    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((e) async {
      if (widget.data != null) {
        await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .set(widget.data!);
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(),
        ),
        (_) => false,
      );
    });
  }
}
