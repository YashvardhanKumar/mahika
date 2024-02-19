import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../model/community/community_model.dart';

class GroupController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final RxList<GroupModel> groupChatData = <GroupModel>[].obs;
  MessageModel? curMessage;
  RxList<DocumentSnapshot<GroupModel>> snapshots =
      <DocumentSnapshot<GroupModel>>[].obs;

  List<GroupModel> get groups => groupChatData.toList();

  List<DocumentSnapshot<GroupModel>> get snapshot => snapshots.toList();
  final CollectionReference<Map<String, dynamic>> ref;

  GroupController(this.ref);

  @override
  void onReady() {
    groupChatData.bindStream(getGroups());
  }

  Stream<List<GroupModel>> getGroups() {
    return ref
        .orderBy('updatedAt', descending: true)
        .withConverter(
      fromFirestore: (data, _) => GroupModel.fromJson(data),
      toFirestore: (data, _) => data.toJson(),
    )
        .snapshots()
        .map((event) {
      List<GroupModel> groups = [];
      snapshots.value = event.docs;
      for (var c in event.docs) {
        groups.add(c.data());
      }
      return groups;
    });
  }
}
