import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mahikav/model/community/community_model.dart';

import '../../../../constants.dart';



class MessageController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final RxList<MessageModel> messsageChatData = <MessageModel>[].obs;
  RxList<DocumentSnapshot<MessageModel>> snapshots =
      <DocumentSnapshot<MessageModel>>[].obs;

  List<MessageModel> get messages => messsageChatData.toList();
  RxInt _notifications = 0.obs;

  int get notifications => _notifications.value;

  List<DocumentSnapshot<MessageModel>> get snapshot => snapshots.toList();
  final CollectionReference<Map<String, dynamic>> ref;

  MessageController(this.ref);

  @override
  void onReady() {
    messsageChatData.bindStream(getMessage());
  }

  Stream<List<MessageModel>> getMessage() {
    return ref
        .orderBy('timeSent', descending: true)
        .withConverter(
          fromFirestore: (data, _) => MessageModel.fromJson(data),
          toFirestore: (data, _) => data.toJson(),
        )
        .snapshots()
        .map((event) {
      List<MessageModel> message = [];
      snapshots.value = event.docs;
      for (var c in event.docs) {
        message.add(c.data());
      }
      return message;
    });
  }

  Future updateNotification() async {
    _notifications.value = 0;
    snapshots.first.reference
        .collection('seen')
        .withConverter(
            fromFirestore: (json, _) => SeenModel.fromJson(json),
            toFirestore: (data, _) => data.toJson())
        .get()
        .then((value) {
      for (var z in value.docs.map((e) => e.data())) {
        if (z.ref.id == auth.currentUser!.uid) continue;

        _notifications++;
      }
    });
  }
}
