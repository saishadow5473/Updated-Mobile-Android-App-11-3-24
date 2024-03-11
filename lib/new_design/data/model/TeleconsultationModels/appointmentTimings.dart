// To parse this JSON data, do
//
//     final appointmentsTimings = appointmentsTimingsFromJson(jsonString);

// import 'dart:convert';
//
// List<AppointmentsTimings> appointmentsTimingsFromJson(String str) =>
//     List<AppointmentsTimings>.from(json.decode(str).map((x) => AppointmentsTimings.fromJson(x)));
//
// String appointmentsTimingsToJson(List<AppointmentsTimings> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AppointmentsTimings {
  String tileName;
  Categ categ;

  AppointmentsTimings({
    this.tileName,
    this.categ,
  });

  factory AppointmentsTimings.fromJson(Map<String, dynamic> json) {
    String tname = json.keys.first;
    return AppointmentsTimings(
      tileName: tname,
      categ: Categ.fromJson(json[tname]),
    );
  }

// Map<String, dynamic> toJson() => {
//       "tileName": tileName,
//       "categ": List<dynamic>.from(categ.map((x) => x.toJson())),
//     };
}

class Categ {
  List<String> morning;
  List<String> afternoon;
  List<String> evening;
  List<String> night;

  Categ({
    this.morning,
    this.afternoon,
    this.evening,
    this.night,
  });

  factory Categ.fromJson(List json) => Categ(
        morning: removeDuplicate(List<String>.from(json[0]["morning"].map((x) => x))),
        afternoon: removeDuplicate(List<String>.from(json[0]["afternoon"].map((x) => x))),
        evening: removeDuplicate(List<String>.from(json[0]["evening"].map((x) => x))),
        night: removeDuplicate(List<String>.from(json[0]["night"].map((x) => x))),
      );

  // afternoon:
  // json["afternoon"] != null ? List<String>.from(json["afternoon"].map((x) => x)) : [],
  // evening: json["evening"] != null ? List<String>.from(json["evening"].map((x) => x)) : [],
  // night: json["night"] != null ? List<String>.from(json["night"].map((x) => x)) : [],
  Map<String, dynamic> toJson() => {
        "morning": List<String>.from(morning.map((x) => x)),
        "afternoon": List<String>.from(afternoon.map((x) => x)),
        "evening": List<String>.from(evening.map((x) => x)),
        "night": List<String>.from(night.map((x) => x)),
      };
}
List<String> removeDuplicate(List<String> timingList){
  return timingList.toSet().toList();
}