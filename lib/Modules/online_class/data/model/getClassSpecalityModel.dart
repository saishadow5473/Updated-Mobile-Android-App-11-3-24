// To parse this JSON data, do
//
//     final getClassSpeciality = getClassSpecialityFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

GetClassSpeciality getClassSpecialityFromJson(String str) => GetClassSpeciality.fromJson(json.decode(str));



class GetClassSpeciality {
  int totalCount;
  List<SpecialityList> specialityList;

  GetClassSpeciality({
    @required this.totalCount,
    @required this.specialityList,
  });

  factory GetClassSpeciality.fromJson(Map<String, dynamic> json) => GetClassSpeciality(
    totalCount: json["total_count"],
    specialityList: List<SpecialityList>.from(json["specialityList"].map((x) => SpecialityList.fromJson(x))),
  );


}

class SpecialityList {
  String specialityName;
  String specialityType;

  SpecialityList({
    @required this.specialityName,
    @required this.specialityType,
  });

  factory SpecialityList.fromJson(Map<String, dynamic> json) => SpecialityList(
    specialityName: json["speciality_name"],
    specialityType: json["speciality_type"],
  );

  Map<String, dynamic> toJson() => {
    "speciality_name": specialityName,
    "speciality_type": specialityType,
  };
}
