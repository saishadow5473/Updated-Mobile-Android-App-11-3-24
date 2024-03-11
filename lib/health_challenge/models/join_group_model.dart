// To parse this JSON data, do
//
//     final joinGroup = joinGroupFromJson(jsonString);

import 'package:meta/meta.dart';

import 'join_individual.dart';

class JoinGroup {
  JoinGroup({
    @required this.groupId,
    @required this.challengeId,
    @required this.userDetails,
  });

  String groupId;
  String challengeId;
  UserDetails userDetails;

  factory JoinGroup.fromJson(Map<String, dynamic> json) => JoinGroup(
        groupId: json["group_id"],
        challengeId: json["challenge_id"],
        userDetails: UserDetails.fromJson(json["user_details"]),
      );

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "challenge_id": challengeId,
        "user_details": userDetails.toJson(),
      };
}
