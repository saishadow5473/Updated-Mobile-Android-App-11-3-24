// To parse this JSON data, do
//
//     final getActivityLog = getActivityLogFromJson(jsonString);

import 'dart:convert';

List<GetActivityLog> getActivityLogFromJson(String str) => List<GetActivityLog>.from(json.decode(str).map((x) => GetActivityLog.fromJson(x)));

String getActivityLogToJson(List<GetActivityLog> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetActivityLog {
    GetActivityLog({
        this.activityLogTime,
        this.epochLogTime,
        this.totalCaloriesBurned,
        this.activityLogId,
        this.activityDetails,
    });

    String activityLogTime;
    int epochLogTime;
    String totalCaloriesBurned;
    String activityLogId;
    List<GetActivityLogActivityDetail> activityDetails;

    factory GetActivityLog.fromJson(Map<String, dynamic> json) => GetActivityLog(
        activityLogTime: json["activity_log_time"],
        epochLogTime: json["epoch_log_time"],
        activityLogId:json["activity_log_id"],
        totalCaloriesBurned: json["total_calories_bued"],
        activityDetails: List<GetActivityLogActivityDetail>.from(json["activity_details"].map((x) => GetActivityLogActivityDetail.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "activity_log_time": activityLogTime,
        "epoch_log_time": epochLogTime,
        "total_calories_bued": totalCaloriesBurned,
        "activity_details": List<dynamic>.from(activityDetails.map((x) => x.toJson())),
    };
}

class GetActivityLogActivityDetail {
    GetActivityLogActivityDetail({
        this.activityDetails,
    });

    List<ActivityDetailActivityDetail> activityDetails;

    factory GetActivityLogActivityDetail.fromJson(Map<String, dynamic> json) => GetActivityLogActivityDetail(
        activityDetails: List<ActivityDetailActivityDetail>.from(json["activity_details"].map((x) => ActivityDetailActivityDetail.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "activity_details": List<dynamic>.from(activityDetails.map((x) => x.toJson())),
    };
}

class ActivityDetailActivityDetail {
    ActivityDetailActivityDetail({
        this.activityId,
        this.activityName,
        this.activityDuration,
    });

    String activityId;
    String activityName;
    String activityDuration;

    factory ActivityDetailActivityDetail.fromJson(Map<String, dynamic> json) => ActivityDetailActivityDetail(
        activityId: json["activity_id"],
        activityName: json["activity_name"],
        activityDuration: json["activity_duration"],
    );

    Map<String, dynamic> toJson() => {
        "activity_id": activityId,
        "activity_name": activityName,
        "activity_duration": activityDuration,
    };
}


