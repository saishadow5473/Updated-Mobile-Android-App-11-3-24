import 'dart:convert';

import 'package:flutter/material.dart';

PostUserSelectedDashboard postUserSelectedDashboardFromJson(String str) => PostUserSelectedDashboard.fromJson(json.decode(str));

String postUserSelectedDashboardToJson(PostUserSelectedDashboard data) => json.encode(data.toJson());

class PostUserSelectedDashboard {
  String userId;
  String purpose;
  String platform;
  String content;

  PostUserSelectedDashboard({
    @required this.userId,
    @required this.purpose,
    @required this.platform,
    @required this.content,
  });

  factory PostUserSelectedDashboard.fromJson(Map<String, dynamic> json) => PostUserSelectedDashboard(
    userId: json["user_id"],
    purpose: json["purpose"],
    platform: json["platform"],
    content: json["content"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "purpose": purpose,
    "platform": platform,
    "content": content,
  };
}
