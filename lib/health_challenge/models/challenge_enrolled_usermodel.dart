import 'package:meta/meta.dart';
import 'dart:convert';

EnrolledUser enrolledUserFromJson(String str) =>
    EnrolledUser.fromJson(json.decode(str));

String enrolledUserToJson(EnrolledUser data) => json.encode(data.toJson());

class EnrolledUser {
  EnrolledUser({
    @required this.userStatus,
    @required this.name,
    @required this.city,
    @required this.department,
    @required this.designation,
    @required this.gender,
    @required this.enrollmentId,
    @required this.target,
    @required this.achieved,
  });

  String userStatus,
      name,
      city,
      department,
      designation,
      gender,
      enrollmentId,
      target,
      achieved;

  factory EnrolledUser.fromJson(Map<String, dynamic> json) => EnrolledUser(
        userStatus: json["user_status"],
        name: json["name"],
        city: json["city"],
        department: json["department"],
        designation: json["designation"],
        gender: json["gender"],
        enrollmentId: json["enrollment_id"],
        target: json["target"],
        achieved: json["achieved"],
      );

  Map<String, dynamic> toJson() => {
        "user_status": userStatus,
        "name": name,
        "city": city,
        "department": department,
        "designation": designation,
        "gender": gender,
        "enrollment_id": enrollmentId,
        "target": target,
        "achieved": achieved,
      };
}
