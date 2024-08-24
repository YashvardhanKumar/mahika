import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:mahikav/constants.dart';

import '../../../../model/users/user_model.dart';

class UserDataController extends GetxController {
  RxList<UserModel> _users = <UserModel>[].obs;

  List<UserModel> get users => _users;
  Rx<UserModel>? _curUser;

  // UserModel? get curUser => _curUser?.value;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    // getUsers();
    _users.bindStream(getUsers());
  }

  Stream<List<UserModel>> getUsers() {
    return firestore
        .collection('users')
        .withConverter(
          fromFirestore: (data, _) => UserModel.fromJson(data),
          toFirestore: (data, _) => data.toJson(),
        )
        .snapshots()
        .map((event) {
      List<UserModel> user = [];
      for (var c in event.docs) {
        user.add(c.data());
      }
      return user;
    });
  }
}
