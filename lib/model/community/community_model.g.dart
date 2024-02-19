// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityModel _$CommunityModelFromJson(DocumentSnapshot<Map<String, dynamic>> json) =>
    CommunityModel(
      groups: json.reference.collection('groups'),
      city: json.data()!['city'] as String,
      state: json.data()!['state'] as String,
      doc: json.reference,
    );

Map<String, dynamic> _$CommunityModelToJson(CommunityModel instance) =>
    <String, dynamic>{
      'city': instance.city,
      'state': instance.state,
      // 'groups': instance.groups,
    };

GroupModel _$GroupModelFromJson(DocumentSnapshot<Map<String, dynamic>> json) => GroupModel(
      messages: json.reference.collection('messages'),
      isGeneral: json.data()!['isGeneral'] as bool,
      collegeName: json.data()!['collegeName'] as String?,
      updatedAt:
          const TimestampSerializer().fromJson(json.data()!['updatedAt'] as Timestamp),
  doc: json.reference,

    );

Map<String, dynamic> _$GroupModelToJson(GroupModel instance) =>
    <String, dynamic>{
      'collegeName': instance.collegeName,
      'isGeneral': instance.isGeneral,
      'updatedAt': const TimestampSerializer().toJson(instance.updatedAt),
      // 'messages': instance.messages,
    };

MessageModel _$MessageModelFromJson(DocumentSnapshot<Map<String, dynamic>> json) => MessageModel(
      seen: json.reference.collection('seen'),
      contentType: (json.data()!['contentType'] ?? '') as String,
      fileMessage: json.data()!['fileMessage'] as String?,
      sentBy: const DocumentSerializerNullable()
          .fromJson(json.data()!['sentBy'] as DocumentReference<Object?>?),
      timeSent:
          const TimestampSerializer().fromJson(json.data()!['timeSent'] as Timestamp),
      message: json.data()!['message'] as String,
      replyTo: const DocumentSerializerNullable()
          .fromJson(json.data()!['replyTo'] as DocumentReference<Object?>?),
  doc: json.reference,

    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'contentType': instance.contentType,
      'fileMessage': instance.fileMessage,
      'message': instance.message,
      'replyTo': const DocumentSerializerNullable().toJson(instance.replyTo),
      'sentBy': const DocumentSerializerNullable().toJson(instance.sentBy),
      'timeSent': const TimestampSerializer().toJson(instance.timeSent),
      // 'seen': instance.seen,
    };

SeenModel _$SeenModelFromJson(DocumentSnapshot<Map<String, dynamic>> json) => SeenModel(
      ref: const DocumentSerializer()
          .fromJson(json.data()!['ref'] as DocumentReference<Object?>),
      seenAt: const TimestampSerializer().fromJson(json.data()!['seenAt'] as Timestamp),
  doc: json.reference,

    );

Map<String, dynamic> _$SeenModelToJson(SeenModel instance) => <String, dynamic>{
      'ref': const DocumentSerializer().toJson(instance.ref),
      'seenAt': const TimestampSerializer().toJson(instance.seenAt),
    };
