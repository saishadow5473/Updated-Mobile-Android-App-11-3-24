// To parse this JSON data, do
//
//     final getAppointmentList = getAppointmentListFromJson(jsonString);

import 'dart:convert';

import '../../../../data/model/TeleconsultationModels/appointmentModels.dart';

GetAppointmentList getAppointmentListFromJson(String str) =>
    GetAppointmentList.fromJson(json.decode(str));

String getAppointmentListToJson(GetAppointmentList data) => json.encode(data.toJson());

class GetAppointmentList {
  int totalCount;
  List<CompletedAppointment> appointments;

  GetAppointmentList({
    this.totalCount,
    this.appointments,
  });

  factory GetAppointmentList.fromJson(Map<String, dynamic> json) => GetAppointmentList(
        totalCount: json["total_count"],
        appointments: List<CompletedAppointment>.from(
            json["Appointments"].map((x) => CompletedAppointment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total_count": totalCount,
        "Appointments": List<dynamic>.from(appointments.map((x) => x.toJson())),
      };
}
