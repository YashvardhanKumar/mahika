import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordPlayerLocal extends StatefulWidget {
  const RecordPlayerLocal({Key? key, this.url, required this.onPressed, this.isEmergency = true}) : super(key: key);
  final String? url;
  final VoidCallback onPressed;
  final bool isEmergency;
  //
  @override
  State<RecordPlayerLocal> createState() => _RecordPlayerLocalState();
}

class _RecordPlayerLocalState extends State<RecordPlayerLocal> {
  int tick = 10;
  Timer? timer;
  bool canPop = false;
  late bool disableCancel = true;
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String fileName = 'audio';
  String fileExtension = '.aac';
  String directoryPath = '/storage/emulated/0/SoundRecorder';

  void _createFile() async {
    // PermissionStatus status = await Permission.storage.request();
    // PermissionStatus status1 = await Permission.accessMediaLocation.request();
    // PermissionStatus status = await Permission.audio.request();
    var status = await Permission.storage.status;
    await Permission.audio.request();
    Directory _directory = Directory("");
    if (!status.isGranted) {
      // If not we will ask for permission first
      await Permission.storage.request();
      _directory = Directory(directoryPath);

      // await Permission.manageExternalStorage.request();
    }
    if (status.isDenied) {
      _directory = (await getExternalStorageDirectory())!;

      print('Permission Denied');
    }
    print(_directory.path);
    // print('status $status   -> $status2');

    // if (status.isGranted) {
    var _completeFileName = DateTime.now().toUtc().toIso8601String();
    final exPath = _directory.path;
    await Directory(exPath).create(recursive: true);

    File file = File(widget.url! ?? "");
    //write to file
    Uint8List bytes = await file.readAsBytes();
    File writeFile = File("$exPath/$_completeFileName$fileExtension");
    await writeFile.writeAsBytes(bytes);
    print(writeFile.path);
    // }
  }

  // void _createDirectory() async {
  //   bool isDirectoryCreated = await Directory(directoryPath).exists();
  //   if (!isDirectoryCreated) {
  //     Directory(directoryPath)
  //         .create()
  //         // The created directory is returned as a Future.
  //         .then((Directory directory) {
  //       print(directory.path);
  //     });
  //   }
  // }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    if (widget.url == null) {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        final file = File(result.files.single.path!);
        await audioPlayer.setSourceAsset(file.path);
      }
    } else {
      final file = File(widget.url!);
      await audioPlayer.setSourceUrl(file.path);
    }
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
    // TODO: implement initState
    super.initState();
    print(widget.url);
    // _createDirectory();
    _createFile();
    setAudio();
    // if(widget.isEmergency) {
    timer = Timer.periodic(const Duration(seconds: 1), (time) {
      if (time.tick == 10) {
        timer?.cancel();
        disableCancel = false;
      }
      tick--;
      setState(() {});
    });
    // }
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (val) {
        canPop = true;
        setState(() {});
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
                      max: duration.inMicroseconds.toDouble(),
                      value: position.inMicroseconds.toDouble(),
                      onChanged: (value) async {
                        final position = Duration(microseconds: value.toInt());
                        await audioPlayer.seek(position);
                        await audioPlayer.resume();
                      },
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
                    CircleAvatar(
                      radius: 35,
                      child: IconButton(
                        icon: Icon(isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                        iconSize: 50,
                        onPressed: () async {
                          if (isPlaying) {
                            await audioPlayer.pause();
                          } else {
                            await audioPlayer.resume();
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          onPressed: disableCancel
                              ? null
                              : () {

                            Navigator.pop(context);
                          },
                          child: Text(
                            disableCancel ? '$tick s' : 'Cancel',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        FilledButton(
                          onPressed: widget.onPressed,
                          // onPressed: () async {
                          //   if (widget.url == null) return;
                          //   File file = File(widget.url!);
                          //   String fileName = DateTime.now().toIso8601String();
                          //   Reference firebaseStorageRef = FirebaseStorage
                          //       .instance
                          //       .ref()
                          //       .child('audio/$fileName.aac');
                          //   UploadTask uploadTask = firebaseStorageRef.putFile(
                          //       file,
                          //       SettableMetadata(contentType: 'audio/aac'));
                          //   String url = await uploadTask
                          //       .whenComplete(() {})
                          //       .then((value) {
                          //     return value.ref.getDownloadURL();
                          //   });
                          //   print(url);
                          //   Position curPos = await _determinePosition();
                          //   List<Placemark> placemarks =
                          //       await placemarkFromCoordinates(
                          //           curPos.latitude, curPos.longitude);
                          //   placemarks[0];
                          //   String? name;
                          //   if (FirebaseAuth.instance.currentUser != null) {
                          //     final user = await FirebaseFirestore.instance
                          //         .collection('users')
                          //         .doc(FirebaseAuth.instance.currentUser!.uid)
                          //         .get();
                          //     name = user['name'];
                          //   }
                          //   final address = placemarks.first.toJson();
                          //   print(address);
                          //   await FirebaseFirestore.instance
                          //       .collection('emergency')
                          //       .add({
                          //     if (name != null) 'name': name,
                          //     'audio': url,
                          //     'address': address,
                          //     'isCreated': DateTime.now().toUtc(),
                          //   });
                          //   Navigator.pop(context);
                          // },
                          child: Text(
                            'Send ${widget.isEmergency ? 'Emergency' : ''}',
                            style: GoogleFonts.poppins(),
                          ),
                          style: FilledButton.styleFrom(
                              backgroundColor:
                              widget.isEmergency ? Colors.red : null),
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
    );
  }
}

class RecordPlayer extends StatefulWidget {
  const RecordPlayer({Key? key, this.url}) : super(key: key);
  final String? url;

  @override
  State<RecordPlayer> createState() => _RecordPlayerState();
}

class _RecordPlayerState extends State<RecordPlayer> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  Future setAudio() async {
    // audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.setSourceUrl(widget.url!);
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
    // TODO: implement initState
    super.initState();
    print(widget.url);
    setAudio();
    audioPlayer.onPlayerStateChanged.listen((state) async{
      print(state);
      if(state == PlayerState.completed) {
        await setAudio();
      }
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    max: duration.inMicroseconds.toDouble(),
                    value: position.inMicroseconds.toDouble(),
                    onChanged: (value) async {
                      final position = Duration(microseconds: value.toInt());
                      await audioPlayer.seek(position);
                      await audioPlayer.resume();
                    },
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
                  CircleAvatar(
                    radius: 35,
                    child: IconButton(
                      icon: Icon(isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                      iconSize: 50,
                      onPressed: () async {
                        if (isPlaying) {
                          await audioPlayer.pause();
                        } else {
                          await audioPlayer.resume();
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}