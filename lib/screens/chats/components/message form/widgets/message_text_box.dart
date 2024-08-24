import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../components/custom_icon_icons.dart';
import '../../../../../constants.dart';
import '../controllers/message_form_controller.dart';

class MessageTextBox extends StatelessWidget {
  MessageTextBox({super.key});

  final f = Get.find<MessageFormController>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RecordingDisposition>(
        stream: f.r.recorder.onProgress,
        builder: (context, s) {
          if (s.hasData && f.r.isRecording.value) {
            return Slider(
              thumbColor: kColorDark,
              label: s.requireData.duration.toString(),
              value: s.requireData.duration.inMicroseconds.toDouble(),
              divisions: const Duration(minutes: 1, seconds: 30).inMicroseconds,
              max: const Duration(minutes: 1, seconds: 30)
                  .inMicroseconds
                  .toDouble(),
              onChanged: (val) {},
            );
          }
          return TextFormField(
            controller: f.ctrl,
            focusNode: f.focus,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              fillColor: Colors.grey.shade200,
              filled: true,
              hintText: 'Send message',
              hintStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              suffixIcon: (f.ctrl.text == '')
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.audio_file_outlined,
                      size: 28,
                    ),
                    onPressed: f.onPickAudioFile,
                  ),
                  IconButton(
                    icon: const Icon(
                      CustomIcon.image_add,
                      size: 28,
                    ),
                    onPressed: f.onPickMediaFile,
                  ),
                ],
              )
                  : null,
              isCollapsed: true,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(50),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(50),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          );
        });
  }
}
