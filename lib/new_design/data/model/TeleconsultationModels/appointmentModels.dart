import 'dart:convert';

import 'package:get/get.dart';

import '../../../../views/cardiovascular_views/cardio_dashboard.dart';
import '../../../presentation/controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';

class CompletedAppointment {
  String appointmentId;
  String callStatus;
  String bookedDateTime;
  String consultantName;
  String vendorConsultantId;
  String ihlConsultantId;
  String vendorId;
  String consultationFees;
  String modeOfPayment;
  String allergy;
  bool isExpired = false;
  // KioskCheckinHistory kioskCheckinHistory;
  String appointmentStartTime;
  String appointmentEndTime;
  String appointmentDuration;
  String appointmentStatus;
  int startIndex;
  int endIndex;

  CompletedAppointment({
    this.appointmentId,
    this.callStatus,
    this.bookedDateTime,
    this.consultantName,
    this.vendorConsultantId,
    this.ihlConsultantId,
    this.vendorId,
    this.consultationFees,
    this.modeOfPayment,
    this.allergy,
    // this.kioskCheckinHistory,
    this.appointmentStartTime,
    this.appointmentEndTime,
    this.appointmentDuration,
    this.appointmentStatus,
    this.startIndex,
    this.endIndex,
    this.isExpired,
  });

  factory CompletedAppointment.fromJson(Map<String, dynamic> json) => CompletedAppointment(
        appointmentId: json["appointment_id"],
        callStatus:
            json["call_status"] != null ? json["call_status"].toString().capitalizeFirst : "N/A",
        bookedDateTime: json["booked_date_time"],
        consultantName: json["consultant_name"],
        vendorConsultantId: json["vendor_consultant_id"],
        ihlConsultantId: json["ihl_consultant_id"],
        vendorId: json["vendor_id"],
        consultationFees: json["consultation_fees"],
        modeOfPayment: json["mode_of_payment"],
        allergy: json["allergy"],
        isExpired: TeleConsultationFunctionsAndVariables.checkAppointmentExpiry(appointmentStartTime:
            json["appointment_start_time"],callStatus:
            json["call_status"] != null ? json["call_status"].toString().capitalizeFirst : "N/A",callFees:json["consultation_fees"],appointmentStatus: json["appointment_status"] ),
        // kioskCheckinHistory: KioskCheckinHistory.fromJson(
        //     jsonDecode(json["kiosk_checkin_history"].toString().replaceAll("&quot;", '"'))),
        appointmentStartTime: json["appointment_start_time"],
        appointmentEndTime: json["appointment_end_time"],
        appointmentDuration: json["appointment_duration"],
        appointmentStatus: json["appointment_status"],
        startIndex: json["start_index"],
        endIndex: json["end_index"],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "appointment_id": appointmentId,
        "call_status": callStatus,
        "booked_date_time": bookedDateTime,
        "consultant_name": consultantName,
        "vendor_consultant_id": vendorConsultantId,
        "ihl_consultant_id": ihlConsultantId,
        "vendor_id": vendorId,
        "consultation_fees": consultationFees,
        "mode_of_payment": modeOfPayment,
        "allergy": allergy,
        // "kiosk_checkin_history": kioskCheckinHistory.toJson(),
        "appointment_start_time": appointmentStartTime,
        "appointment_end_time": appointmentEndTime,
        "appointment_duration": appointmentDuration,
        "appointment_status": appointmentStatus,
        "start_index": startIndex,
        "end_index": endIndex,
      };
}

class KioskCheckinHistory {
  String dateTime;
  String weightKg;
  String boneMineralContentStatus;
  String proteinStatus;
  String mineralStatus;
  String bodyFatMassStatus;
  String bodyCellMassStatus;
  String waistHipRatioStatus;
  String percentBodyFatStatus;
  String waistHeightRatioStatus;
  String visceralFatStatus;
  String heightMeters;
  String systolic;
  String diastolic;
  String bmiClass;
  String bpClass;
  String bmi;

  KioskCheckinHistory({
    this.dateTime,
    this.weightKg,
    this.boneMineralContentStatus,
    this.proteinStatus,
    this.mineralStatus,
    this.bodyFatMassStatus,
    this.bodyCellMassStatus,
    this.waistHipRatioStatus,
    this.percentBodyFatStatus,
    this.waistHeightRatioStatus,
    this.visceralFatStatus,
    this.heightMeters,
    this.systolic,
    this.diastolic,
    this.bmiClass,
    this.bpClass,
    this.bmi,
  });

  factory KioskCheckinHistory.fromJson(Map<String, dynamic> json) => KioskCheckinHistory(
        weightKg: json["weightKG"].toString(),
        boneMineralContentStatus: json["bone_mineral_content_status"].toString(),
        proteinStatus: json["protein_status"].toString(),
        mineralStatus: json["mineral_status"].toString(),
        bodyFatMassStatus: json["body_fat_mass_status"].toString(),
        bodyCellMassStatus: json["body_cell_mass_status"].toString(),
        waistHipRatioStatus: json["waist_hip_ratio_status"].toString(),
        percentBodyFatStatus: json["percent_body_fat_status"].toString(),
        waistHeightRatioStatus: json["waist_height_ratio_status"].toString(),
        visceralFatStatus: json["visceral_fat_status"].toString(),
        heightMeters: json["heightMeters"].toString(),
        systolic: json["systolic"].toString(),
        diastolic: json["diastolic"].toString(),
        bmiClass: json["bmiClass"].toString(),
        bpClass: json["bpClass"].toString(),
        bmi: json["bmi"].toString(),
        dateTime: json["dateTime"],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "dateTime": dateTime,
        "weightKG": weightKg,
        "bone_mineral_content_status": boneMineralContentStatus,
        "protein_status": proteinStatus,
        "mineral_status": mineralStatus,
        "body_fat_mass_status": bodyFatMassStatus,
        "body_cell_mass_status": bodyCellMassStatus,
        "waist_hip_ratio_status": waistHipRatioStatus,
        "percent_body_fat_status": percentBodyFatStatus,
        "waist_height_ratio_status": waistHeightRatioStatus,
        "visceral_fat_status": visceralFatStatus,
        "heightMeters": heightMeters,
        "systolic": systolic,
        "diastolic": diastolic,
        "bmiClass": bmiClass,
        "bpClass": bpClass,
        "bmi": bmi,
      };
}

// class CancelledAppointment {
//   String appointmentId;
//   String callStatus;
//   String bookedDateTime;
//   String consultantName;
//   String vendorConsultantId;
//   String ihlConsultantId;
//   String vendorId;
//   String consultationFees;
//   String modeOfPayment;
//   String allergy;
//   KioskCheckinHistory kioskCheckinHistory;
//   String appointmentStartTime;
//   String appointmentEndTime;
//   String appointmentDuration;
//   String appointmentStatus;
//   int startIndex;
//   int endIndex;

//   CancelledAppointment({
//     this.appointmentId,
//     this.callStatus,
//     this.bookedDateTime,
//     this.consultantName,
//     this.vendorConsultantId,
//     this.ihlConsultantId,
//     this.vendorId,
//     this.consultationFees,
//     this.modeOfPayment,
//     this.allergy,
//     this.kioskCheckinHistory,
//     this.appointmentStartTime,
//     this.appointmentEndTime,
//     this.appointmentDuration,
//     this.appointmentStatus,
//     this.startIndex,
//     this.endIndex,
//   });

//   factory CancelledAppointment.fromJson(Map<String, dynamic> json) => CancelledAppointment(
//         appointmentId: json["appointment_id"],
//         callStatus: json["call_status"],
//         bookedDateTime: json["booked_date_time"],
//         consultantName: json["consultant_name"],
//         vendorConsultantId: json["vendor_consultant_id"],
//         ihlConsultantId: json["ihl_consultant_id"],
//         vendorId: json["vendor_id"],
//         consultationFees: json["consultation_fees"],
//         modeOfPayment: json["mode_of_payment"],
//         allergy: json["allergy"],
//         kioskCheckinHistory: KioskCheckinHistory.fromJson(
//             jsonDecode(json["kiosk_checkin_history"].toString().replaceAll("&quot;", '"'))),
//         appointmentStartTime: json["appointment_start_time"],
//         appointmentEndTime: json["appointment_end_time"],
//         appointmentDuration: json["appointment_duration"],
//         appointmentStatus: json["appointment_status"],
//         startIndex: json["start_index"],
//         endIndex: json["end_index"],
//       );

//   Map<String, dynamic> toJson() => {
//         "appointment_id": appointmentId,
//         "call_status": callStatus,
//         "booked_date_time": bookedDateTime,
//         "consultant_name": consultantName,
//         "vendor_consultant_id": vendorConsultantId,
//         "ihl_consultant_id": ihlConsultantId,
//         "vendor_id": vendorId,
//         "consultation_fees": consultationFees,
//         "mode_of_payment": modeOfPayment,
//         "allergy": allergy,
//         "kiosk_checkin_history": kioskCheckinHistory.toJson(),
//         "appointment_start_time": appointmentStartTime,
//         "appointment_end_time": appointmentEndTime,
//         "appointment_duration": appointmentDuration,
//         "appointment_status": appointmentStatus,
//         "start_index": startIndex,
//         "end_index": endIndex,
//       };
// }
