import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:json_annotation/json_annotation.dart';

import '../community/community_model.dart';

part 'emergency_model.g.dart';

class PlacemarkSerializer
    implements JsonConverter<Placemark, Map<String, dynamic>> {
  const PlacemarkSerializer();

  @override
  Placemark fromJson(Map<String, dynamic> json) => Placemark.fromMap(json);

  @override
  Map<String, dynamic> toJson(Placemark object) => object.toJson();
}

@JsonSerializable()
class EmergencyModel {
  final String audio;
  final String? name;
  @TimestampSerializer()
  final Timestamp isCreated;
  final bool isSeen;
  @PlacemarkSerializer()
  final Placemark address;
  final DocumentReference<Map<String, dynamic>>? doc;

  EmergencyModel({
    this.name,
    this.doc,
    required this.address,
    required this.audio,
    required this.isCreated,
    required this.isSeen,
  });

  factory EmergencyModel.fromJson(
          DocumentSnapshot<Map<String, dynamic>> json) =>
      _$EmergencyModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyModelToJson(this);
}
