// To parse this JSON data, do
//
//     final approvedAppointments = approvedAppointmentsFromJson(jsonString);

import 'dart:convert';

import '../../../presentation/controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';

ApprovedAppointments approvedAppointmentsFromJson(String str) =>
    ApprovedAppointments.fromJson(json.decode(str));

String approvedAppointmentsToJson(ApprovedAppointments data) => json.encode(data.toJson());

class ApprovedAppointments {
  int totalCount;
  List<Appointment> appointments;

  ApprovedAppointments({
    this.totalCount,
    this.appointments,
  });

  factory ApprovedAppointments.fromJson(Map<String, dynamic> json) => ApprovedAppointments(
        totalCount: json["total_count"],
        appointments:
            List<Appointment>.from(json["Appointments"].map((x) => Appointment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total_count": totalCount,
        "Appointments": List<dynamic>.from(appointments.map((x) => x.toJson())),
      };
}

class Appointment {
  String appointmentId;
  String bookedDateTime;
  String consultantName;
  String vendorConsultantId;
  String ihlConsultantId;
  String vendorId;
  String consultantType;
  String consultationFees;
  String modeOfPayment;
  String alergy;
  String kioskCheckinHistory;
  String appointmentStartTime;
  String appointmentEndTime;
  String appointmentDuration;
  String appointmentStatus;
  int startIndex;
  int endIndex;
  String callStatus;
  bool isExpired = false;

  Appointment({
    this.appointmentId,
    this.bookedDateTime,
    this.consultantName,
    this.vendorConsultantId,
    this.ihlConsultantId,
    this.vendorId,
    this.consultantType,
    this.consultationFees,
    this.modeOfPayment,
    this.alergy,
    this.kioskCheckinHistory,
    this.appointmentStartTime,
    this.appointmentEndTime,
    this.appointmentDuration,
    this.appointmentStatus,
    this.startIndex,
    this.endIndex,
    this.callStatus,
    this.isExpired,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        appointmentId: json["appointment_id"],
        bookedDateTime: json["booked_date_time"],
        consultantName: json["consultant_name"],
        vendorConsultantId: json["vendor_consultant_id"],
        ihlConsultantId: json["ihl_consultant_id"],
        vendorId: json["vendor_id"],
        consultantType: json["consultant_type"],
        consultationFees: json["consultation_fees"],
        modeOfPayment: json["mode_of_payment"],
        alergy: json["alergy"],
        isExpired: TeleConsultationFunctionsAndVariables.checkAppointmentExpiry(
            appointmentStartTime: json["appointment_start_time"],
            callStatus: json["call_status"],
            appointmentStatus: json["appointment_status"],
            callFees: json["consultation_fees"]),
        kioskCheckinHistory: json["kiosk_checkin_history"],
        appointmentStartTime: json["appointment_start_time"],
        appointmentEndTime: json["appointment_end_time"],
        appointmentDuration: json["appointment_duration"],
        appointmentStatus: json["appointment_status"],
        startIndex: json["start_index"],
        endIndex: json["end_index"],
        callStatus: json["call_status"],
      );

  Map<String, dynamic> toJson() => {
        "appointment_id": appointmentId,
        "booked_date_time": bookedDateTime,
        "consultant_name": consultantName,
        "vendor_consultant_id": vendorConsultantId,
        "ihl_consultant_id": ihlConsultantId,
        "vendor_id": vendorId,
        "consultant_type": consultantType,
        "consultation_fees": consultationFees,
        "mode_of_payment": modeOfPayment,
        "alergy": alergy,
        "kiosk_checkin_history": kioskCheckinHistory,
        "appointment_start_time": appointmentStartTime,
        "appointment_end_time": appointmentEndTime,
        "appointment_duration": appointmentDuration,
        "appointment_status": appointmentStatus,
        "start_index": startIndex,
        "end_index": endIndex,
        "call_status": callStatus,
      };
}
