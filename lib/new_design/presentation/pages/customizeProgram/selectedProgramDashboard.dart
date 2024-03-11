// To parse this JSON data, do
//
//     final getUserSelectedDashboard = getUserSelectedDashboardFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

GetUserSelectedDashboard getUserSelectedDashboardFromJson(String str) => GetUserSelectedDashboard.fromJson(json.decode(str));

String getUserSelectedDashboardToJson(GetUserSelectedDashboard data) => json.encode(data.toJson());

class GetUserSelectedDashboard {
  String status;
  List<Datum> data;

  GetUserSelectedDashboard({
    @required this.status,
    @required this.data,
  });

  factory GetUserSelectedDashboard.fromJson(Map<String, dynamic> json) => GetUserSelectedDashboard(
    status: json["status"],
    data: List<Datum>.from(json["Data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "Data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String userId;
  String platform;
  String purpose;
  Map<String,dynamic> content;

  Datum({
    @required this.userId,
    @required this.platform,
    @required this.purpose,
    @required this.content,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    content: jsonDecode((json["content"].replaceAll('&#39;','"')).replaceAll('&quot;','"')),
    userId: json["user_id"],
    platform: json["platform"],
    purpose: json["purpose"],

  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "platform": platform,
    "purpose": purpose,
    "content": content,
  };
}
