// To parse this JSON data, do
//
//     final bookMarkedActivity = bookMarkedActivityFromJson(jsonString);

import 'dart:convert';

List<BookMarkedActivity> bookMarkedActivityFromJson(String str) => List<BookMarkedActivity>.from(json.decode(str).map((x) => BookMarkedActivity.fromJson(x)));

String bookMarkedActivityToJson(List<BookMarkedActivity> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

BookMarkedActivity bookMarkedActivitySPFromJson(String str) => BookMarkedActivity.fromJson(json.decode(str));

String bookMarkedActivitySPToJson(BookMarkedActivity data) => json.encode(data.toJson());

class BookMarkedActivity {
    BookMarkedActivity({
        this.activityId,
        this.activityName,
        this.activityMetValue,
        this.activityType,
    });

    String activityId;
    String activityName;
    String activityMetValue;
    String activityType;

    factory BookMarkedActivity.fromJson(Map<String, dynamic> json) => BookMarkedActivity(
        activityId: json["activity_id"],
        activityName: json["activity_name"],
        activityMetValue: json["activity_met_value"],
        activityType: json["activity_type"],
    );

    Map<String, dynamic> toJson() => {
        "activity_id": activityId,
        "activity_name": activityName,
        "activity_met_value": activityMetValue,
        "activity_type": activityType,
    };
}
