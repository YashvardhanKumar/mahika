import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mahikav/constants.dart';

class MessageAudioPlayer extends StatefulWidget {
  const MessageAudioPlayer({super.key, required this.url, required this.audioPlayer});

  final String url;
  final AudioPlayer audioPlayer;


  @override
  State<MessageAudioPlayer> createState() => _MessageAudioPlayerState();
}

class _MessageAudioPlayerState extends State<MessageAudioPlayer>
    with SingleTickerProviderStateMixin {
  int tick = 10;
  Timer? timer;
  bool disableCancel = true;
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.stop);
    // if (widget.url == null) {
    //   final result = await FilePicker.platform.pickFiles();
    //   if (result != null) {
    //     final file = File(result.files.single.path!);
    //     await audioPlayer.setSourceAsset(file.path);
    //   }
    // } else {
    final file = File(widget.url);
    await audioPlayer.setSourceUrl(widget.url);
    // }
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final mins = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return [
      if (duration.inHours > 0) hours,
      mins,
      secs,
    ].join(':');
  }

  @override
  void initState() {
    super.initState();
    setAudio();
    // timer = Timer.periodic(const Duration(seconds: 1), (time) {
    //   if (time.tick == 10) {
    //     timer?.cancel();
    //     disableCancel = false;
    //   }
    //   tick--;
    //   setState(() {});
    // });
    audioPlayer.onPlayerStateChanged.listen((state) {
      if(mounted) {
        isPlaying = state == PlayerState.playing;
        setState(() {});
      }
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      if(mounted) {
        duration = newDuration;
        setState(() {});
      }
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      if(mounted) {
        position = newPosition;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                iconSize: 20,
                onPressed: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    await audioPlayer.resume();
                  }
                },
              ),
              Expanded(
                child: Slider(
                  min: 0,
                  activeColor: kColorDark,
                  inactiveColor: kColorLight,
                  // secondaryActiveColor: kColorLight,
                  thumbColor: kColorDark,
                  max: duration.inMicroseconds.toDouble(),
                  value: position.inMicroseconds.toDouble(),
                  onChanged: (value) async {
                    final position = Duration(microseconds: value.toInt());
                    await audioPlayer.seek(position);
                    await audioPlayer.resume();
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatTime(position)),
                Text(formatTime(duration)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}