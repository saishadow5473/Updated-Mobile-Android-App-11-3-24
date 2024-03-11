import 'package:intl/intl.dart';

class UpdateChallengeTarget {
  UpdateChallengeTarget({
    this.enrollmentId,
    this.progressStatus,
    this.achieved,
    this.duration,
    this.email,
    this.certificateBase64,
    this.certificatePngBase64,
    this.firstTime,
    this.challengeEndTime,
    this.challengeStartTime,
    this.speed,
    this.logTime,
    this.session,
    this.challenge_type,
  });

  final String enrollmentId,
      progressStatus,
      achieved,
      duration,
      email,
      certificateBase64,
      certificatePngBase64,
      speed,
      challenge_type,
      session;
  bool firstTime = false;
  DateTime challengeEndTime, challengeStartTime, logTime;
  factory UpdateChallengeTarget.fromJson(Map<String, dynamic> json) => UpdateChallengeTarget(
        enrollmentId: json["enrollment_id"],
        progressStatus: json["progress_status"],
        achieved: json["achieved"],
        duration: json["duration"],
        email: json["email"],
        certificateBase64: json["certificate_base64"],
        certificatePngBase64: json["certificate_png_base64"],
        challengeStartTime: json['user_start_time'],
        challengeEndTime: json['user_end_time'],
        logTime: json['log_time'],
        session: json['session'],
        speed: json['speed'],
        challenge_type: json['challenge_type'],
      );

  Map<String, dynamic> toJson() => firstTime
      ? {
          "enrollment_id": enrollmentId,
          "progress_status": "progressing",
          "log_time": DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now()),
          "achieved": "0",
          "duration": "0",
          "user_start_time": DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now()),
          "challenge_type":
              challenge_type //TODO dynamic challenge need challenge type now hard coded the challenge type
        }
      : progressStatus == 'progressing'
          ? {
              "enrollment_id": enrollmentId,
              "progress_status": "progressing",
              "achieved": achieved,
              "log_time": DateFormat('MM/dd/yyyy HH:mm:ss').format(logTime),

              "duration": duration,
              "challenge_type":
                  challenge_type //TODO dynamic challenge need challenge type now hard coded the challenge type
            }
          : {
              "enrollment_id": enrollmentId,
              "progress_status": "completed",
              "achieved": achieved,
              "duration": duration,
              "log_time": DateFormat('MM/dd/yyyy HH:mm:ss').format(logTime),
              "email": email,
              "certificate_base64": certificateBase64,
              "certificate_png_base64": certificatePngBase64,
              "user_end_time": DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now()),
              "challenge_type":
                  challenge_type //TODO dynamic challenge need challenge type now hard coded the challenge type
            };
}
