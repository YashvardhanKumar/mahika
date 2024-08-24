import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../constants.dart';
import '../controllers/message_form_controller.dart';

class ReplyToMessageWidget extends StatelessWidget {
  ReplyToMessageWidget({super.key});

  final f = Get.find<MessageFormController>();

  @override
  Widget build(BuildContext context) {
    final isCurSender = f.sender.doc?.id == auth.currentUser!.uid;
    final senderName = isCurSender ? 'You' : f.sender.name;
    final message = f.replyTo!.message.isEmpty
        ? f.replyTo!.contentType
        : f.replyTo!.message;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          AnimatedContainer(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: const Border(
                left: BorderSide(
                  color: kColorDark,
                  width: 8,
                ),
              ),
              color: Colors.grey.shade50,
            ),
            padding: const EdgeInsets.all(10.0),
            duration: const Duration(milliseconds: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senderName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                if (f.replyTo != null)
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          Material(
            shape: const CircleBorder(),
            color: Colors.grey.shade100,
            child: InkWell(
              onTap: f.onCancel,
              child: const Icon(
                Icons.close_rounded,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
    );
  }
}
