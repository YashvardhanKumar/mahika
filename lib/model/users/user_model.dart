import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String IDProof;
  final UserCategory category;
  final String city;
  final String? collegeAddress;
  final String? email;
  final bool? isVerifiedUser;
  final String name;
  final String phoneNo;
  final String? policeID;
  final String? post;
  final String state;
  final String? studentID;
  final DocumentReference<Map<String,dynamic>>? doc;

  UserModel({
    this.doc,
    this.collegeAddress,
    this.studentID,
    required this.category,
    required this.city,
    this.email,
    required this.isVerifiedUser,
    required this.name,
    required this.phoneNo,
    this.policeID,
    this.post,
    required this.state,
    required this.IDProof,
  });
  factory UserModel.fromJson(DocumentSnapshot<Map<String,dynamic>> json) => _$UserModelFromJson(json);
  Map<String,dynamic> toJson() => _$UserModelToJson(this);
}

enum UserCategory { Police, Member, Admin }
