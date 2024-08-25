import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordPlayerLocal extends StatefulWidget {
  const RecordPlayerLocal(
      {Key? key, this.url, required this.onPressed, this.isEmergency = true})
      : super(key: key);
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
  String fileExtension = '.mp3';
  // String directoryPath = '/storage/emulated/0/SoundRecorder';
  Future<bool> _requestPermission(Permission p) => p.request().isGranted;
  Future<bool> _hasAcceptedPermissions() async {
    if (Platform.isAndroid) {
      if (await _requestPermission(Permission.storage) &&
          // access media location needed for android 10/Q
          await _requestPermission(Permission.accessMediaLocation) &&
          // manage external storage needed for android 11/R
          await _requestPermission(Permission.manageExternalStorage)) {
        return true;
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Permission Denied")));
        return false;
      }
    }
    if (Platform.isIOS) {
      if (await _requestPermission(Permission.photos)) {
        return true;
      } else {
        return false;
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Permission Denied")));
      // not android or ios
      return false;
    }
  }

  void _createFile() async {
    if (!(await _hasAcceptedPermissions())) return;
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
      return;
    }

    Directory _directory = Directory("dir");
    if (Platform.isAndroid) {
      _directory = Directory("/storage/emulated/0/Download/Mahika");
    } else {
      _directory = await getApplicationDocumentsDirectory();
    }

    final exPath = _directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    // await Permission.manageExternalStorage.request();

    print(exPath);
    var _completeFileName = DateTime.now().toUtc().toIso8601String();

    File file = File(widget.url! ?? "");
    //write to file
    Uint8List bytes = await file.readAsBytes();
    File writeFile = File("$exPath/$_completeFileName$fileExtension");
    await writeFile.writeAsBytes(bytes);
    print(writeFile.path);
    Navigator.pop(context);

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
    // _createFile();
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
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration;
        });
      }
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
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
                                  _createFile();
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
    audioPlayer.onPlayerStateChanged.listen((state) async {
      print(state);
      if (state == PlayerState.completed) {
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
