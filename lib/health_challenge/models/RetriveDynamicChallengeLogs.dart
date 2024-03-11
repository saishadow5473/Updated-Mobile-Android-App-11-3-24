// To parse this JSON data, do
//
//     final joinIndividualChallenge = joinIndividualChallengeFromJson(jsonString);

import 'dart:convert';

List<JoinIndividualChallenge> joinIndividualChallengeFromJson(String str) => List<JoinIndividualChallenge>.from(json.decode(str).map((x) => JoinIndividualChallenge.fromJson(x)));

String joinIndividualChallengeToJson(List<JoinIndividualChallenge> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class JoinIndividualChallenge {
  String enrollmentId;
  String achieved;
  String logTime;
  String session;

  JoinIndividualChallenge({
     this.enrollmentId,
     this.achieved,
     this.logTime,
     this.session,
  });

  factory JoinIndividualChallenge.fromJson(Map<String, dynamic> json) => JoinIndividualChallenge(
    enrollmentId: json["enrollment_id"],
    achieved: json["achieved"],
    logTime: json["log_time"],
    session: json["session"],
  );

  Map<String, dynamic> toJson() => {
    "enrollment_id": enrollmentId,
    "achieved": achieved,
    "log_time": logTime,
    "session": session,
  };
}
