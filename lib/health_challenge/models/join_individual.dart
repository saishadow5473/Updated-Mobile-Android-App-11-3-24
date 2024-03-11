// To parse this JSON data, do
//
//     final JoinIndividual = JoinIndividualFromJson(jsonString);

import 'package:meta/meta.dart';

class JoinIndividual {
  JoinIndividual({
    @required this.challengeId,
    @required this.userDetails,
    @required this.isReminderEnabled,
    @required this.reminderDetail,
  });

  String challengeId;
  UserDetails userDetails;
  bool isReminderEnabled;
  Map reminderDetail;

  factory JoinIndividual.fromJson(Map<String, dynamic> json) => JoinIndividual(
        challengeId: json["challenge_id"],
        userDetails: UserDetails.fromJson(json["user_details"]),
      );

  Map<String, dynamic> toJson() => {
        "challenge_id": challengeId,
        "user_details": userDetails.toJson(),
        "is_reminder_enabled": isReminderEnabled,
        "reminder_detail": reminderDetail.toString()
      };
}

class UserDetails {
  UserDetails(
      {@required this.userId,
      @required this.name,
      @required this.city,
      @required this.gender,
      @required this.department,
      @required this.designation,
      @required this.isGloble,
      @required this.email,
      @required this.userStartLocation,
      @required this.selected_fitness_app});

  String userId,
      name,
      city,
      gender,
      department,
      email,
      designation,
      selected_fitness_app,
      userStartLocation;
  bool isGloble;

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
      userId: json["user_id"],
      name: json["name"],
      city: json["city"],
      userStartLocation: json['user_start_location'],
      gender: json["gender"],
      department: json["department"],
      designation: json["designation"],
      isGloble: json["is_globle"],
      email: json['email'],
      selected_fitness_app: json['selected_fitness_app']);

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "city": city,
        "gender": gender,
        "department": department,
        "designation": designation,
        "is_globle": isGloble,
        'email': email,
        'user_start_location': userStartLocation,
        'selected_fitness_app': selected_fitness_app //google fit  other_apps
      };
}
