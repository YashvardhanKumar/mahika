import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../model/community/community_model.dart';

class CommunityController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final RxList<CommunityModel> _communitiesChatData = <CommunityModel>[].obs;
  RxList<DocumentSnapshot<CommunityModel>> snapshots =
      <DocumentSnapshot<CommunityModel>>[].obs;

  List<CommunityModel> get communities => _communitiesChatData.toList();

  List<DocumentSnapshot<CommunityModel>> get snapshot => snapshots.toList();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    _communitiesChatData.bindStream(getCommunities());
  }

  Stream<List<CommunityModel>> getCommunities() {
    return firestore
        .collection('communities')
        .withConverter(
      fromFirestore: (data, _) => CommunityModel.fromJson(data),
      toFirestore: (data, _) => data.toJson(),
    )
        .snapshots()
        .map((event) {
      List<CommunityModel> communities = [];
      snapshots.value = event.docs;
      for (var c in event.docs) {
        communities.add(c.data());
      }
      return communities;
    });
  }
}
