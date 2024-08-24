import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'college_model.g.dart';

@JsonSerializable()
class CollegeModel {
  final DocumentReference<Map<String,dynamic>>? doc;
  final String city;
  final String state;
  final String collegeAddress;

  CollegeModel({
    this.doc,
    required this.collegeAddress,
    required this.city,
    required this.state,
  });
  factory CollegeModel.fromJson(DocumentSnapshot<Map<String,dynamic>> json) => _$CollegeModelFromJson(json);
  Map<String,dynamic> toJson() => _$CollegeModelToJson(this);
}
