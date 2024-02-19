// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(DocumentSnapshot<Map<String, dynamic>> json) => UserModel(
      collegeAddress: json.data()!['collegeAddress'] as String?,
      studentID: json.data()!['studentID'] as String?,
      category: $enumDecode(_$UserCategoryEnumMap, json.data()!['category']),
      city: json.data()!['city'] as String,
      email: json.data()!['email'] as String?,
      isVerifiedUser: json.data()!['isVerifiedUser'] as bool?,
      name: json.data()!['name'] as String,
      phoneNo: json.data()!['phoneNo'] as String,
      policeID: json.data()!['policeID'] as String?,
      post: json.data()!['post'] as String?,
      state: json.data()!['state'] as String,
      IDProof: json.data()!['IDProof'] as String,
      doc: json.reference,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'IDProof': instance.IDProof,
      'category': _$UserCategoryEnumMap[instance.category]!,
      'city': instance.city,
      'collegeAddress': instance.collegeAddress,
      'email': instance.email,
      'isVerifiedUser': instance.isVerifiedUser,
      'name': instance.name,
      'phoneNo': instance.phoneNo,
      'policeID': instance.policeID,
      'post': instance.post,
      'state': instance.state,
      'studentID': instance.studentID,
    };

const _$UserCategoryEnumMap = {
  UserCategory.Police: 'Police',
  UserCategory.Member: 'Member',
  UserCategory.Admin: 'Admin',
};
