import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const kColorDark = Color(0xff27374D);
const kColorLight = Color(0xffDDE6ED);

final auth = FirebaseAuth.instance;
final firestore = FirebaseFirestore.instance;