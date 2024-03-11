// To parse this JSON data, do
//
//     final getClassSpeciality = getClassSpecialityFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

GetOnlineServicesSpeciality getOnlineServicesSpecialityFromJson(String str) =>
    GetOnlineServicesSpeciality.fromJson(json.decode(str));

class GetOnlineServicesSpeciality {
  int totalCount;
  List<OnlineServicesSpecialityList> specialityList;

  GetOnlineServicesSpeciality({
    @required this.totalCount,
    @required this.specialityList,
  });

  factory GetOnlineServicesSpeciality.fromJson(Map<String, dynamic> json) => GetOnlineServicesSpeciality(
        totalCount: json["total_count"],
        specialityList: List<OnlineServicesSpecialityList>.from(
            json["specialityList"].map((x) => OnlineServicesSpecialityList.fromJson(x))),
      );
}

class OnlineServicesSpecialityList {
  String specialityName;
  String specialityType;

  OnlineServicesSpecialityList({
    @required this.specialityName,
    @required this.specialityType,
  });

  factory OnlineServicesSpecialityList.fromJson(Map<String, dynamic> json) => OnlineServicesSpecialityList(
        specialityName: json["speciality_name"],
        specialityType: json["speciality_type"],
      );

  Map<String, dynamic> toJson() => {
        "speciality_name": specialityName,
        "speciality_type": specialityType,
      };
}
