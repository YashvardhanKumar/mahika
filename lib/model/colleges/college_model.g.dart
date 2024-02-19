// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'college_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollegeModel _$CollegeModelFromJson(
        DocumentSnapshot<Map<String, dynamic>> json) =>
    CollegeModel(
      collegeAddress: json.data()!['collegeAddress'] as String,
      city: json.data()!['city'] as String,
      state: json.data()!['state'] as String,
      doc: json.reference,
    );

Map<String, dynamic> _$CollegeModelToJson(CollegeModel instance) =>
    <String, dynamic>{
      'city': instance.city,
      'state': instance.state,
      'collegeAddress': instance.collegeAddress,
    };
