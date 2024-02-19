// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmergencyModel _$EmergencyModelFromJson(DocumentSnapshot<Map<String, dynamic>> json) =>
    EmergencyModel(
      name: json.data()!['name'] as String?,
      address: const PlacemarkSerializer()
          .fromJson(json.data()!['address'] as Map<String, dynamic>),
      audio: json.data()!['audio'] as String,
      isCreated:
          const TimestampSerializer().fromJson(json.data()!['isCreated'] as Timestamp),
      isSeen: json.data()!['isSeen'] as bool,
      doc: json.reference,
    );

Map<String, dynamic> _$EmergencyModelToJson(EmergencyModel instance) =>
    <String, dynamic>{
      'audio': instance.audio,
      'name': instance.name,
      'isCreated': const TimestampSerializer().toJson(instance.isCreated),
      'isSeen': instance.isSeen,
      'address': const PlacemarkSerializer().toJson(instance.address),
    };
