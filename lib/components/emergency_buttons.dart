import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';

import 'custom_icon_icons.dart';
import 'getxcontroller/recording_controller.dart';
import 'record_player.dart';

class EmergencyButtons extends StatelessWidget {
  EmergencyButtons({Key? key}) : super(key: key);

  final recCtrl = Get.put(RecordingController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'record',
            backgroundColor: Colors.red.shade900,
            child: Icon(
              recCtrl.isRecording.isTrue ? Icons.stop_rounded : CustomIcon.mic,
              color: Colors.white,
            ),
            onPressed: () async {
              await HapticFeedback.vibrate();
              if (recCtrl.isRecording.value) {
                recCtrl.stop((val) {
                  Get.to(RecordPlayerLocal(url: val));
                });
              } else {
                recCtrl.record((val) {
                  Get.to(RecordPlayerLocal(url: val));
                });
              }
            },
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            heroTag: 'call',
            backgroundColor: Colors.green,
            child: const Icon(
              Icons.call,
              color: Colors.white,
            ),
            onPressed: () async {
              await HapticFeedback.vibrate();
              await FlutterPhoneDirectCaller.callNumber('+911090');
            },
          ),
        ],
      ),
    );
  }
}