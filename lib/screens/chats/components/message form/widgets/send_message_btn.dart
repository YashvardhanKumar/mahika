import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/custom_icon_icons.dart';
import '../../../../../constants.dart';
import '../controllers/message_form_controller.dart';

class SendMessageBtn extends StatelessWidget {
  SendMessageBtn({super.key});

  final f = Get.find<MessageFormController>();

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: kColorDark,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: f.onSendMessage,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, anim) => RotationTransition(
              turns: (f.ctrl.text.isEmpty)
                  ? Tween<double>(begin: 1.25, end: 1).animate(anim)
                  : Tween<double>(begin: 0.75, end: 1).animate(anim),
              child: FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: anim,
                  child: child,
                ),
              ),
            ),
            child: (f.ctrl.text.isEmpty)
                ? Icon(
                    f.r.isRecording.value ? Icons.stop_rounded : CustomIcon.mic,
                    color: Colors.white,
                    size: 25,
                    key: const ValueKey('mic'),
                  )
                : const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 25,
                    key: ValueKey('send'),
                  ),
          ),
        ),
      ),
    );
  }
}
