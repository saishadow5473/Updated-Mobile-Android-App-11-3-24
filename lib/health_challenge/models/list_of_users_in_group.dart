import 'package:meta/meta.dart';
import 'dart:convert';

GroupUser groupUserFromJson(String str) => GroupUser.fromJson(json.decode(str));

String groupUserToJson(GroupUser data) => json.encode(data.toJson());

class GroupUser {
  GroupUser({
    @required this.groupId,
    @required this.userStatus,
    @required this.name,
    @required this.city,
    @required this.department,
    @required this.designation,
    @required this.role,
    @required this.gender,
    @required this.enrollmentId,
    @required this.taget,
    @required this.userId,
    @required this.bibNo,
  });

  String groupId,
      userStatus,
      name,
      city,
      department,
      designation,
      role,
      gender,
      enrollmentId,
      taget,
  bibNo,
      userId;

  factory GroupUser.fromJson(Map<String, dynamic> json) => GroupUser(
      groupId: json["group_id"],
      userStatus: json["user_status"],
      name: json["name"],
      city: json["city"],
      department: json["department"],
      bibNo: json['user_bib_no'],
      designation: json["designation"],
      role: json["role"],
      gender: json["gender"],
      enrollmentId: json["enrollment_id"],
      taget: json["taget"],
      userId: json["user_id"]);

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "user_status": userStatus,
        "name": name,
        "city": city,
        "department": department,
        "designation": designation,
        "role": role,
        "gender": gender,
        "enrollment_id": enrollmentId,
        "taget": taget,
        "user_id": userId
      };
}
