import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

List<Challenge> challengeFromJson(String str) =>
    List<Challenge>.from(json.decode(str).map((x) => Challenge.fromJson(x)));

String challengeToJson(List<Challenge> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Challenge {
  Challenge(
      {@required this.challengeName,
      @required this.challengeImgUrlThumbnail,
      @required this.challengeMode,
      @required this.challengeId,
      @required this.challengeType,
      @required this.challengeStatus,
      @required this.affiliations,
      @required this.targetToAchieve,
      @required this.challengeStartTime,
      @required this.challengeEndTime,
      @required this.challengeUnit,
      @required this.challengeRunType});

  String challengeName,
      challengeImgUrlThumbnail,
      challengeMode,
      challengeId,
      challengeType,
      challengeStatus,
      challengeUnit,
      challengeRunType,
      targetToAchieve;
  DateTime challengeStartTime, challengeEndTime;
  List affiliations;
  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        challengeName: json["challenge_name"],
        challengeImgUrlThumbnail: json["challenge_img_url_thumbnail"],
        challengeMode: json["challenge_mode"],
        challengeId: json["challenge_id"],
        challengeUnit: json["challenge_unit"],
        challengeType: json["challenge_Type"],
        challengeStatus: json["challenge_status"],
        challengeRunType: json["challenge_run_type"] == null ? null : json["challenge_run_type"],
        affiliations: json["affiliations"].toString().replaceAll('&quot;', '').contains(',')
            ? json["affiliations"]
                .toString()
                .replaceAll('&quot;', '')
                .replaceAll('[', '')
                .replaceAll(']', '')
                .split(',')
            : [
                json["affiliations"]
                    .toString()
                    .replaceAll('&quot;', '')
                    .replaceAll('[', '')
                    .replaceAll(']', '')
              ],
        targetToAchieve: json["target_to_achieve"],
        challengeStartTime: dateTimeConverter(json["challenge_start_time"]),
        challengeEndTime: dateTimeConverter(json["challenge_end_time"]),
      );

  Map<String, dynamic> toJson() => {
        "challenge_name": challengeName,
        "challenge_img_url_thumbnail": challengeImgUrlThumbnail,
        "challenge_mode": challengeMode,
        "challenge_id": challengeId,
        "challenge_Type": challengeType,
        "challenge_status": challengeStatus,
        "affiliations": affiliations,
        "target_to_achieve": targetToAchieve,
        "challenge_start_time": challengeStartTime,
        "challenge_end_time": challengeEndTime,
        "challenge_unit": challengeUnit,
        "challenge_run_type": challengeRunType == null ? null : challengeRunType,
      };
}

DateTime dateTimeConverter(String value) {
  DateFormat format = DateFormat('MM/dd/yyyy hh:mm:ss a');
  DateFormat format1 = DateFormat('MM-dd-yyyy hh:mm:ss');
  var date;
  try {
    date = format.parse(value);
  } catch (e) {
    date = format1.parse(value);
  }
  return date;
}
