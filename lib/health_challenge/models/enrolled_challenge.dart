import 'package:meta/meta.dart';

import 'challengemodel.dart';

class EnrolledChallenge {
  EnrolledChallenge(
      {@required this.userStatus,
      @required this.name,
      @required this.city,
      @required this.department,
      @required this.designation,
      @required this.gender,
      @required this.enrollmentId,
      @required this.challengeId,
      @required this.challengeMode,
      @required this.challengeType,
      @required this.target,
      @required this.userAchieved,
      @required this.userProgress,
      @required this.groupId,
      @required this.groupAchieved,
      @required this.groupProgress,
      @required this.userduration,
      @required this.challenge_end_time,
      @required this.challenge_start_time,
      @required this.last_updated,
      @required this.user_bib_no,
      @required this.selectedFitnessApp,
      @required this.docUrl,
      @required this.speed,
      @required this.docFilename ,
      @required this.docStatus,
      @required this.challenge_completed_certficate_url,
        @required this.userEndTime,
        @required this.userStartTime,
        @required this.challenge_category,
        @required this.reminder_detail,
      this.groupname});

  String userStatus,
      name,
      city,
      department,
      designation,
      gender,
      enrollmentId,
      challengeId,
      challengeMode,
      challengeType,
      userProgress,
      groupId,
      last_updated,
      groupProgress,
      groupname,challenge_category,reminder_detail;
  String selectedFitnessApp, challenge_completed_certficate_url;
  String docUrl;
  String docFilename;
  String docStatus = '';
  String user_bib_no = '';
  String speed = '0.00';
  DateTime challenge_start_time, challenge_end_time,userStartTime,userEndTime;
  int target, userduration;
  double userAchieved, groupAchieved;

  factory EnrolledChallenge.fromJson(Map<String, dynamic> json) => EnrolledChallenge(
        userStatus: json["user_status"],
        last_updated: json['last_updated'].replaceAll('/Date(', '').replaceAll('+0000)/', ''),
        name: json["name"],
        userduration: int.parse(json['user_duration'] ?? '0'),
        city: json["city"],
        userStartTime: dateTimeConverter(json['user_start_time']),
        userEndTime: dateTimeConverter(json['user_end_time']),
        department: json["department"],
        designation: json["designation"],
        gender: json["gender"],
        speed: json['speed'] ?? '0.00',
        enrollmentId: json["enrollment_id"],
        user_bib_no: json['user_bib_no'] ?? "",
        challengeId: json["challenge_id"],
        challengeMode: json["challenge_mode"],
        challengeType: json["challenge_type"],

        target: int.tryParse(json["target"]??"0")??0,
        challenge_end_time: dateTimeConverter(json['challenge_end_time']),
        challenge_start_time: dateTimeConverter(json['challenge_start_time']),
        userAchieved: json["user_achieved"] == null ? 0 : double.parse(json["user_achieved"]),
        userProgress: json["user_progress"],
        groupId: json["group_id"] == null ? null : json["group_id"],
        groupAchieved: json["group_achieved"] == null ? 0 : double.parse(json["group_achieved"]),
        groupProgress: json["group_progress"] == null ? null : json["group_progress"],
        selectedFitnessApp: json["selected_fitness_app"],
        docUrl: json["doc_url"],
        docFilename: json["doc_filename"],
        docStatus: json["doc_status"] ?? '',
        challenge_completed_certficate_url: json["challenge_completed_certficate_url"],
        challenge_category:json['challenge_category'],
        reminder_detail:json['reminder_detail']
      );

  Map<String, dynamic> toJson() => {
        "user_status": userStatus,
        "name": name,
        "city": city,
        "department": department,
        "designation": designation,
        "gender": gender,
        "enrollment_id": enrollmentId,
        "user_bib_no": user_bib_no,
        "challenge_id": challengeId,
        "challenge_mode": challengeMode,
        "challenge_type": challengeType,
        "target": target,
        "user_achieved": userAchieved,
        "user_progress": userProgress,
        'user_duration': userduration,
        "group_id": groupId == null ? null : groupId,
        "group_achieved": groupAchieved == null ? null : groupAchieved,
        "group_progress": groupProgress == null ? null : groupProgress,
        "selected_fitness_app": selectedFitnessApp,
        "doc_url": docUrl,
        "doc_filename": docFilename,
        "doc_status": docStatus ?? '',
        "challenge_completed_certficate_url": challenge_completed_certficate_url,
        "challenge_category": challenge_category,
        "reminder_detail":reminder_detail
      };
}
