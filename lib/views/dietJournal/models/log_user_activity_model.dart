// To parse this JSON data, do
//
//     final logUserActivity = logUserActivityFromJson(jsonString);

import 'dart:convert';

LogUserActivity logUserActivityFromJson(String str) => LogUserActivity.fromJson(json.decode(str));

String logUserActivityToJson(LogUserActivity data) => json.encode(data.toJson());

class LogUserActivity {
    LogUserActivity({
        this.status,
        this.response,
    });

    String status;
    String response;

    factory LogUserActivity.fromJson(Map<String, dynamic> json) => LogUserActivity(
        status: json["status"],
        response: json["response"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "response": response,
    };
}
