import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../../components/custom_icon_icons.dart';

class MessageVideoPlayer extends StatefulWidget {
  const MessageVideoPlayer({super.key, required this.url});

  final String url;

  @override
  State<MessageVideoPlayer> createState() => _MessageVideoPlayerState();
}

class _MessageVideoPlayerState extends State<MessageVideoPlayer> {
  late VideoPlayerController _controller;
  bool isPlaying = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: _controller.value.isPlaying ? null : AppBar(
        backgroundColor: Colors.white70,
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              isPlaying = _controller.value.isPlaying;
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : FutureBuilder(
                      future: VideoThumbnail.thumbnailData(
                        video: widget.url,
                        imageFormat: ImageFormat.JPEG,
                        maxWidth: 128,
                        // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                        quality: 25,
                      ),
                      builder: (context, data) {
                        if (data.hasData) {
                          return Image.memory(data.data!);
                        } else {
                          return Material(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(22.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      },
                    ),
              if(!_controller.value.isPlaying)
              Material(
                color: Colors.white38,
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(15)),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(
                    CustomIcon.play,
                    size: 28,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
