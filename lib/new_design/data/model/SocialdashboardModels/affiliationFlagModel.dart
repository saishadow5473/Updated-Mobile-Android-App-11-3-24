// To parse this JSON data, do

import 'package:flutter/material.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';

class AffiliationFlagModel {
  String affiliationName;
  List data = [];

  AffiliationFlagModel({
    @required this.affiliationName,
    this.data,
  });

  factory AffiliationFlagModel.fromJson(Map<String, dynamic> json) => AffiliationFlagModel(
        affiliationName: json["Affiliation name"],
        data: json["data"] == null ? [] : json["data"],
      );

  Map<String, dynamic> toJson() => {
        "Affiliation name": affiliationName,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}
