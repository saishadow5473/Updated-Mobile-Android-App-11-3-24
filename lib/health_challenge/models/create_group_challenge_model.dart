// To parse this JSON data, do
//
//     final createGroupChallenge = createGroupChallengeFromJson(jsonString);

import 'package:flutter/material.dart';

class CreateGroupChallenge {
  CreateGroupChallenge({
    this.groupName,
    this.groupDetail,
    this.challengeId,
    this.creatorDetails,
  });

  String groupName, groupDetail, challengeId;
  CreatorDetails creatorDetails;

  factory CreateGroupChallenge.fromJson(Map<String, dynamic> json) => CreateGroupChallenge(
        groupName: json["group_name"],
        groupDetail: json["group_detail"],
        challengeId: json["challenge_id"],
        creatorDetails: CreatorDetails.fromJson(json["creator_details"]),
      );

  Map<String, dynamic> toJson() => {
        "group_name": groupName,
        "group_detail": groupDetail,
        "challenge_id": challengeId,
        "creator_details": creatorDetails.toJson(),
      };
}

class CreatorDetails {
  CreatorDetails(
      {@required this.userId,
      @required this.name,
      @required this.city,
      @required this.gender,
      @required this.department,
      @required this.designation,
      @required this.isGloble,
      @required this.email,
      @required this.user_start_location});

  String userId, name, city, gender, department, designation, email, user_start_location;
  bool isGloble;

  factory CreatorDetails.fromJson(Map<String, dynamic> json) => CreatorDetails(
      userId: json["user_id"],
      name: json["name"],
      city: json["city"],
      gender: json["gender"],
      department: json["department"],
      designation: json["designation"],
      email: json['email'],
      isGloble: json["is_globle"],
      user_start_location: json['user_start_location']);

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "city": city,
        "gender": gender,
        "department": department,
        "designation": designation,
        "is_globle": isGloble,
        'email': email,
        'selected_fitness_app': "google fit",
        'user_start_location': user_start_location
      };
}
