// To parse this JSON data, do
//
//     final enrolledChallenge = enrolledChallengeFromJson(jsonString);

import 'dart:convert';

import 'package:ihl/health_challenge/models/challengemodel.dart';

ChallengeDetail enrolledChallengeFromJson(String str) => ChallengeDetail.fromJson(json.decode(str));

String enrolledChallengeToJson(ChallengeDetail data) => json.encode(data.toJson());

class ChallengeDetail {
  ChallengeDetail(
      {this.challengeId,
      this.challengeType,
      this.challengeName,
      this.challengeDescription,
      this.affiliations,
      this.targetDepartment,
      this.targetCity,
      this.challengeImgUrl,
      this.challengeImgUrlThumbnail,
      this.challengeMode,
      this.minUsersGroup,
      this.maxUsersGroup,
      this.challengeCompletionCertificateMessage,
      this.challengeCreatedTime,
      this.challengeStartTime,
      this.challengeEndTime,
      this.createdBy,
      this.challengeStatus,
      this.targetToAchieve,
      this.bannerImgUrl,
      this.challengeUnit,
      this.challengeRunType,
      this.partitionKey,
      this.rowKey,
      this.timestamp,
      this.eTag,
      this.challenge_start_location_list,
      this.challenge_completed_certficate_url,
      this.challengeBadge,
      this.is_challenge_banner_visible,
      this.mileStoneTotalTarget,
      this.challengeDurationDays,
      this.challengeLogLimit,
      this.challengeHourDetails,
      this.challengeRemaider,
      this.selfieOptionEnabled,
      this.certificateImageUrl,
      this.challengeSessionDetail});

  String challengeId,
      challengeType,
      challengeName,
      challengeDescription,
      targetDepartment,
      targetCity,
      challengeImgUrl,
      challengeImgUrlThumbnail,
      challengeMode,
      challengeCompletionCertificateMessage,
      challengeCreatedTime,
      createdBy,
      challengeStatus,
      targetToAchieve,
      bannerImgUrl,
      challengeRunType,
      partitionKey,
      rowKey,
      timestamp,
      eTag,
      challengeUnit,
      challenge_completed_certficate_url,
      challengeBadge,
      challengeDurationDays,
      challengeLogLimit,
      challengeHourDetails,
      mileStoneTotalTarget,
      certificateImageUrl,
      challengeSessionDetail;
  List affiliations, challenge_start_location_list;
  int minUsersGroup, maxUsersGroup;
  DateTime challengeStartTime, challengeEndTime;
  bool is_challenge_banner_visible = false;
  bool selfieOptionEnabled = false;
  bool challengeRemaider = false;

  factory ChallengeDetail.fromJson(Map<String, dynamic> json) => ChallengeDetail(
      challengeId: json["challenge_id"],
      challengeType: json["challenge_Type"],
      challengeName: json["challenge_name"],
      selfieOptionEnabled: json['selfie_option_settings'] ?? false,
      certificateImageUrl: json['certificate_image'],
      mileStoneTotalTarget: json['milestone_total_target'],
      challengeDescription: descriptionTextRemover(json["challenge_description"]),
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
      targetDepartment: unwantedTextRemover(json["target_department"]),
      targetCity: unwantedTextRemover(json["target_city"]),
      challengeImgUrl: json["challenge_img_url"],
      challengeImgUrlThumbnail: json["challenge_img_url_thumbnail"],
      challengeMode: json["challenge_mode"],
      minUsersGroup: json["min_users_group"],
      maxUsersGroup: json["max_users_group"],
      challengeCompletionCertificateMessage: json["challenge_completion_certificate_message"],
      challengeCreatedTime:
          json["challenge_created_time"].replaceAll('/Date(', '').replaceAll(')/', ''),
      challengeStartTime: dateTimeConverter(json["challenge_start_time"]),
      challengeEndTime: dateTimeConverter(json["challenge_end_time"]),
      createdBy: json["created_by"],
      challengeStatus: json["challenge_status"],
      targetToAchieve: json["target_to_achieve"],
      bannerImgUrl: json["Banner_img_url"] ?? json["challenge_Banner_img_url"],
      challengeRunType: json["challenge_run_type"],
      challengeUnit: json["challenge_unit"] ?? "steps",
      challenge_start_location_list:
          json["challenge_start_location_list"].toString().replaceAll('&quot;', '').contains(',')
              ? json["challenge_start_location_list"]
                  .toString()
                  .replaceAll('&quot;', '')
                  .replaceAll('[', '')
                  .replaceAll(']', '')
                  .split(',')
              : [
                  json["challenge_start_location_list"]
                      .toString()
                      .replaceAll('&quot;', '')
                      .replaceAll('[', '')
                      .replaceAll(']', '')
                ],
      partitionKey: json["PartitionKey"],
      rowKey: json["RowKey"],
      timestamp: json["Timestamp"],
      eTag: json["ETag"],
      challenge_completed_certficate_url: json["certificate_image"] ?? "",
      challengeBadge: json["challenge_badge"],
      is_challenge_banner_visible: json["is_challenge_banner_visible"],
      challengeDurationDays: json["other_challenge_duration_in_days"],
      challengeLogLimit: json["other_challenge_no_of_times_log_will_be_done"],
      challengeHourDetails: json["other_challenge_hour_detail"],
      challengeSessionDetail: json["other_challenge_session_detail"],
      challengeRemaider:
          json["other_challenge_reminder"] == "true" || json["other_challenge_reminder"] == "True"
              ? true
              : false ?? false);

  Map<String, dynamic> toJson() => {
        "challenge_id": challengeId,
        "challenge_Type": challengeType,
        "challenge_name": challengeName,
        "challenge_description": challengeDescription,
        "affiliations": affiliations,
        "target_department": targetDepartment,
        "target_city": targetCity,
        "challenge_img_url": challengeImgUrl,
        "challenge_img_url_thumbnail": challengeImgUrlThumbnail,
        "challenge_mode": challengeMode,
        "min_users_group": minUsersGroup,
        "max_users_group": maxUsersGroup,
        "challenge_completion_certificate_message": challengeCompletionCertificateMessage,
        "challenge_created_time": challengeCreatedTime,
        "challenge_start_time": challengeStartTime,
        "challenge_end_time": challengeEndTime,
        "created_by": createdBy,
        "challenge_status": challengeStatus,
        "target_to_achieve": targetToAchieve,
        "Banner_img_url": bannerImgUrl,
        "challenge_run_type": challengeRunType,
        "challenge_unit": challengeUnit,
        "PartitionKey": partitionKey,
        "challenge_start_location_list": challenge_start_location_list,
        "RowKey": rowKey,
        "Timestamp": timestamp,
        "ETag": eTag,
        "challenge_completed_certficate_url": challenge_completed_certficate_url,
        "is_challenge_banner_visible": is_challenge_banner_visible,
      };
}

unwantedTextRemover(String text) {
  if (text.contains(',')) {
    var parseda1 = text.replaceAll('\\&quot', '"');

    var parseda2 = parseda1.replaceAll('&quot;', '');
    String t = parseda2;
    return t;
  } else {
    var parseda1 = text.replaceAll('\\&quot', '"');
    var parseda2 = parseda1.replaceAll('&quot;', '');
    var parseda4 = parseda2.replaceAll('[', '');
    var parseda5 = parseda4.replaceAll(']', '');
    String t = parseda5;
    return t;
  }
}

descriptionTextRemover(String text) {
  var parseda1 = text;

  var parseda2 = parseda1.replaceAll('&quot;', '"');
  var parseda5 =
      parseda2.replaceAll("&#39;", "'").replaceAll("&amp;", "&").replaceAll(RegExp(r'[^\w\s]'), '');
  String t = parseda5;
  return t;
}
