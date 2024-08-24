import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/message_form_controller.dart';
import 'message_text_box.dart';
import 'picked_image_to_post.dart';
import 'reply_to_message_widget.dart';

class ExpandableMessageBoxWidget extends StatelessWidget {
  ExpandableMessageBoxWidget({super.key});

  final f = Get.find<MessageFormController>();

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(f.expand ? 20 : 32),
          bottom: const Radius.circular(32)),
      color: Colors.grey.shade200,
      child: Column(
        children: [
          if (f.expand)
            SizeTransition(
              sizeFactor: f.animation,
              axisAlignment: 1,
              child: ReplyToMessageWidget(),
            ),
          if (f.filesChoosen.isNotEmpty) PickedImageToPost(),
          // if (widget.replyTo != null) const SizedBox(height: 10),
          MessageTextBox(),
        ],
      ),
    );
  }
}