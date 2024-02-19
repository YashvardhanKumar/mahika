import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../../components/custom_icon_icons.dart';
import '../../../../../constants.dart';
import '../controllers/message_form_controller.dart';

class PickedImageToPost extends StatelessWidget {
  PickedImageToPost({super.key});

  final f = Get.find<MessageFormController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(10.0),
        itemBuilder: (BuildContext context, int index) {
          final file = f.filesChoosen[index];
          final filePut = File(file.path ?? '');
          return Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.hardEdge,
                child: Container(
                  height: 70,
                  width: 70,
                  margin: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  color: kColorLight,
                  child: Builder(builder: (context) {
                    switch (f.fileType[index]) {
                      case 'image':
                        return Image.file(filePut,
                            cacheHeight: 70, cacheWidth: 70);
                      case 'video':
                        return FutureBuilder(
                          future: VideoThumbnail.thumbnailData(
                            video: filePut.path,
                            imageFormat: ImageFormat.JPEG,
                            maxWidth: 70,
                            // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                            quality: 25,
                          ),
                          builder: (_, data) {
                            if (data.hasData && data.data != null) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.memory(
                                    data.data!,
                                    width: 70,
                                    height: 70,
                                    cacheWidth: 70,
                                    cacheHeight: 70,
                                    fit: BoxFit.cover,
                                  ),
                                  Material(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white30,
                                    child: const Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Icon(CustomIcon.play),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return const Icon(CustomIcon.play);
                          },
                        );
                      case 'audio':
                        return const Icon(Icons.audiotrack_rounded);
                      default:
                        return Column(
                          children: [
                            const Icon(FontAwesomeIcons.file),
                            Text(
                              f.filesChoosen[index].extension?.toUpperCase() ??
                                  '',
                              style: const TextStyle(fontSize: 12),
                            )
                          ],
                        );
                    }
                  }),
                ),
              ),
              Material(
                shape: const CircleBorder(),
                color: Colors.grey.shade100,
                child: InkWell(
                  onTap: () => f.onRemoveFile(index),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          );
        },
        itemCount: f.filesChoosen.length,
      ),
    );
  }
}
