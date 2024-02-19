import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'getxcontroller/player_controller.dart';

class RecordPlayerLocal extends StatelessWidget {
  const RecordPlayerLocal({
    super.key,
    this.url,
    this.onPressed,
    this.isEmergency = true,
  }) : assert(!isEmergency && onPressed != null);
  final String? url;
  final VoidCallback? onPressed;
  final bool isEmergency;

  //
//   @override
//   State<RecordPlayerLocal> createState() => _RecordPlayerLocalState();
// }
//
// class _RecordPlayerLocalState extends State<RecordPlayerLocal> {

  // int tick = 10;
  // Timer? timer;
  // bool canPop = false;
  // late bool disableCancel = true;
  // final audioPlayer = AudioPlayer();
  // bool isPlaying = false;
  // Duration duration = Duration.zero;
  // Duration position = Duration.zero;
  // String fileName = 'audio';
  // String fileExtension = '.aac';
  // String directoryPath = '/storage/emulated/0/SoundRecorder';

  // void _createFile() async {
  //   var status = await Permission.storage.status;
  //   await Permission.audio.request();
  //   Directory directory = Directory("");
  //   if (!status.isGranted) {
  //     // If not we will ask for permission first
  //     await Permission.storage.request();
  //     directory = Directory(directoryPath);
  //   }
  //   if (status.isDenied) {
  //     directory = (await getExternalStorageDirectory())!;
  //
  //     print('Permission Denied');
  //   }
  //   print(directory.path);
  //   var completeFileName = DateTime.now().toUtc().toIso8601String();
  //   final exPath = directory.path;
  //   await Directory(exPath).create(recursive: true);
  //
  //   File file = File(widget.url! ?? "");
  //   //write to file
  //   Uint8List bytes = await file.readAsBytes();
  //   File writeFile = File("$exPath/$completeFileName$fileExtension");
  //   await writeFile.writeAsBytes(bytes);
  //   print(writeFile.path);
  //   // }
  // }

  // String formatTime(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, '0');
  //   final hours = twoDigits(duration.inHours);
  //   final mins = twoDigits(duration.inMinutes.remainder(60));
  //   final secs = twoDigits(duration.inSeconds.remainder(60));
  //   return [
  //     if (duration.inHours > 0) hours,
  //     mins,
  //     secs,
  //   ].join(':');
  // }
  // @override
  // void dispose() {
  //   c.disposePlayer();
  //   // TODO: implement dispose
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return GetX(
        init: PlayerController(url ?? ''),
        builder: (c) => PopScope(
              canPop: c.canPop.isTrue,
              onPopInvoked: (val) {
                c.canPop.value = true;
              },
              child: Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.yellow.shade800,
                              borderRadius: BorderRadius.circular(30)),
                          child: const Icon(
                            Icons.multitrack_audio_rounded,
                            size: 256,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Slider(
                              min: 0,
                              max: c.duration.value.inMicroseconds.toDouble(),
                              value: c.position.value.inMicroseconds.toDouble(),
                              onChanged: (value) async {
                                final position =
                                    Duration(microseconds: value.toInt());
                                await c.audioPlayer.seek(position);
                                await c.audioPlayer.resume();
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(c.formatTime(c.position.value)),
                                  Text(c.formatTime(c.duration.value)),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 35,
                              child: IconButton(
                                icon: Icon(c.isPlaying.value
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded),
                                iconSize: 50,
                                onPressed: () async {
                                  if (c.isPlaying.value) {
                                    await c.audioPlayer.pause();
                                  } else {
                                    await c.audioPlayer.resume();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton(
                                  onPressed:
                                      c.disableCancel.value ? null : Get.back,
                                  child: Text(
                                    c.disableCancel.isTrue
                                        ? '${c.tick} s'
                                        : 'Cancel',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    if (isEmergency) {
                                      c.onPost();
                                    } else {
                                      onPressed!();
                                    }
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        isEmergency ? Colors.red : null,
                                  ),
                                  child: Text(
                                    'Send ${isEmergency ? 'Emergency' : ''}',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }
}

class RecordPlayer extends StatelessWidget {
  const RecordPlayer({Key? key, this.url}) : super(key: key);

  final String? url;
  @override
  Widget build(BuildContext context) {
    return GetX<PlayerController>(
      init: PlayerController(url ?? ''),
      builder: (c) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.yellow.shade800,
                        borderRadius: BorderRadius.circular(30)),
                    child: const Icon(
                      Icons.multitrack_audio_rounded,
                      size: 256,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Slider(
                        min: 0,
                        max: c.duration.value.inMicroseconds.toDouble(),
                        value: c.position.value.inMicroseconds.toDouble(),
                        onChanged: (value) async {
                          final position = Duration(microseconds: value.toInt());
                          await c.audioPlayer.seek(position);
                          await c.audioPlayer.resume();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c.formatTime(c.position.value)),
                            Text(c.formatTime(c.duration.value)),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 35,
                        child: IconButton(
                          icon: Icon(c.isPlaying.isTrue
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded),
                          iconSize: 50,
                          onPressed: () async {
                            if (c.isPlaying.isTrue) {
                              await c.audioPlayer.pause();
                            } else {
                              await c.audioPlayer.resume();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
