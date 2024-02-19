import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'community_model.g.dart';

class DocumentSerializerNullable
    implements JsonConverter<DocumentReference?, DocumentReference?> {
  const DocumentSerializerNullable();

  @override
  DocumentReference? fromJson(DocumentReference? docRef) => docRef;

  @override
  DocumentReference? toJson(DocumentReference? docRef) => docRef;
}

class DocumentSerializer
    implements JsonConverter<DocumentReference, DocumentReference> {
  const DocumentSerializer();

  @override
  DocumentReference fromJson(DocumentReference docRef) => docRef;

  @override
  DocumentReference toJson(DocumentReference docRef) => docRef;
}

class CollectionSerializer
    implements JsonConverter<CollectionReference, CollectionReference> {
  const CollectionSerializer();

  @override
  CollectionReference fromJson(CollectionReference json) => json;

  @override
  CollectionReference toJson(CollectionReference object) => object;
}

class TimestampSerializer implements JsonConverter<Timestamp, Timestamp> {
  const TimestampSerializer();

  @override
  Timestamp fromJson(Timestamp json) => json;

  @override
  Timestamp toJson(Timestamp object) => object;
}

@JsonSerializable()
class CommunityModel {
  final String city;
  final String state;
  @CollectionSerializer()
  CollectionReference<Map<String, dynamic>>? groups;
  final DocumentReference<Map<String,dynamic>>? doc;

  CommunityModel({
    this.doc,
    this.groups,
    required this.city,
    required this.state,
  });

  factory CommunityModel.fromJson(
          DocumentSnapshot<Map<String, dynamic>> json) =>
      _$CommunityModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityModelToJson(this);
}

@JsonSerializable()
class GroupModel {
  final String? collegeName;
  final bool isGeneral;
  @TimestampSerializer()
  final Timestamp updatedAt;
  @CollectionSerializer()
  CollectionReference<Map<String, dynamic>>? messages;
  final DocumentReference<Map<String,dynamic>>? doc;

  GroupModel({
    this.doc,
    this.messages,
    required this.isGeneral,
    required this.collegeName,
    required this.updatedAt,
  });

  factory GroupModel.fromJson(DocumentSnapshot<Map<String, dynamic>> json) =>
      _$GroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);
}

@JsonSerializable()
class MessageModel {
  final String contentType;
  final String? fileMessage;
  final String message;
  @DocumentSerializerNullable()
  final DocumentReference? replyTo;
  @DocumentSerializerNullable()
  final DocumentReference? sentBy;
  @TimestampSerializer()
  final Timestamp timeSent;
  @CollectionSerializer()
  final DocumentReference<Map<String, dynamic>>? doc;
  CollectionReference<Map<String, dynamic>>? seen;

  MessageModel({
    this.doc,
    this.seen,
    required this.contentType,
    this.fileMessage,
    this.sentBy,
    required this.timeSent,
    required this.message,
    this.replyTo,
  });

  factory MessageModel.fromJson(DocumentSnapshot<Map<String, dynamic>> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}

@JsonSerializable()
class SeenModel {
  @DocumentSerializer()
  final DocumentReference ref;
  @TimestampSerializer()
  final Timestamp seenAt;
  final DocumentReference<Map<String,dynamic>>? doc;

  SeenModel({
    this.doc,
    required this.ref,
    required this.seenAt,
  });

  factory SeenModel.fromJson(DocumentSnapshot<Map<String, dynamic>> json) =>
      _$SeenModelFromJson(json);

  Map<String, dynamic> toJson() => _$SeenModelToJson(this);
}
