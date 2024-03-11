import 'dart:convert';

Specialities specialitiesFromJson(String str) => Specialities.fromJson(json.decode(str));

String specialitiesToJson(Specialities data) => json.encode(data.toJson());

class Specialities {
  int totalCount;
  List<SpecialityList> specialityList;

  Specialities({
    this.totalCount,
    this.specialityList,
  });

  factory Specialities.fromJson(Map<String, dynamic> json) => Specialities(
        totalCount: json["total_count"],
        specialityList: List<SpecialityList>.from(
            json["specialityList"].map((x) => SpecialityList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total_count": totalCount,
        "specialityList": List<dynamic>.from(specialityList.map((x) => x.toJson())),
      };
}

class SpecialityList {
  String specialityName;
  String specialityType;

  SpecialityList({
    this.specialityName,
    this.specialityType,
  });

  factory SpecialityList.fromJson(Map<String, dynamic> json) => SpecialityList(
      specialityName: json["speciality_name"], specialityType: json["speciality_type"] ?? "");

  Map<String, dynamic> toJson() => {
        "speciality_name": specialityName,
        "speciality_type": specialityType,
      };
}
