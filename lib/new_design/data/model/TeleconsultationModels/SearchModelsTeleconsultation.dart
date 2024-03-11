import 'package:flutter/material.dart';

class SearchTeleConulstationData {
  List<String> specialityList;
  String consultantName;
  String ihlConsultantId;
  String gender;
  String experience;
  bool liveCallAllowed;
  String rating;
  String specialityType;
  List<String> languagesSpoken;

  SearchTeleConulstationData({
    @required this.specialityList,
    @required this.consultantName,
    @required this.ihlConsultantId,
    @required this.gender,
    @required this.experience,
    @required this.liveCallAllowed,
    @required this.rating,
    @required this.specialityType,
    @required this.languagesSpoken,
  });

  factory SearchTeleConulstationData.fromJson(Map<String, dynamic> json) =>
      SearchTeleConulstationData(
        specialityList: List<String>.from(json["speciality_list"].map((x) => x)),
        consultantName: json["consultant_name"],
        ihlConsultantId: json["ihl_consultant_id"],
        gender: json["gender"],
        experience: json["experience"],
        liveCallAllowed:
            json["live_call_allowed"].toString().toLowerCase().contains("true") ? true : false,
        rating: json["rating"],
        specialityType: json["speciality_type"],
        languagesSpoken: List<String>.from(json["languages_Spoken"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "speciality_list": List<dynamic>.from(specialityList.map((x) => x)),
        "consultant_name": consultantName,
        "ihl_consultant_id": ihlConsultantId,
        "gender": gender,
        "experience": experience,
        "live_call_allowed": liveCallAllowed,
        "rating": rating,
        "speciality_type": specialityType,
        "languages_Spoken": List<dynamic>.from(languagesSpoken.map((x) => x)),
      };
}
