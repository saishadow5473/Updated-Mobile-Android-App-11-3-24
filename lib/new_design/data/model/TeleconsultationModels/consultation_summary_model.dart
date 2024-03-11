import 'dart:convert';
import 'dart:developer';

import 'package:intl/intl.dart';

class ConsultationSummaryModel {
  Message message;
  KioskCheckinHistory kioskCheckinHistory;
  UserDetails userDetails;
  ConsultantDetails consultantDetails;
  MedLabPartnerDetails medLabPartnerDetails;

  ConsultationSummaryModel({
    this.message,
    this.kioskCheckinHistory,
    this.userDetails,
    this.consultantDetails,
    this.medLabPartnerDetails,
  });

  factory ConsultationSummaryModel.fromJson(Map<String, dynamic> json) => ConsultationSummaryModel(
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
        kioskCheckinHistory: json["kiosk_checkin_history"] == null
            ? null
            : KioskCheckinHistory.fromJson(json["kiosk_checkin_history"]),
        userDetails:
            json["user_details"] == null ? null : UserDetails.fromJson(json["user_details"]),
        consultantDetails: json["consultant_details"] == null
            ? null
            : ConsultantDetails.fromJson(json["consultant_details"]),
        medLabPartnerDetails: json["med_lab_partner_details"] == null
            ? null
            : MedLabPartnerDetails.fromJson(json["med_lab_partner_details"]),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "message": message.toJson(),
        "kiosk_checkin_history": kioskCheckinHistory.toJson(),
        "user_details": userDetails.toJson(),
        "consultant_details": consultantDetails.toJson(),
        "med_lab_partner_details": medLabPartnerDetails.toJson(),
      };
}

class ConsultantDetails {
  String consultantEmail;
  String consultantName;
  String consultantMobile;
  String vendorName;
  String education;
  String description;
  String rmpId;
  String accountId;
  String provider;

  ConsultantDetails({
    this.consultantEmail,
    this.consultantName,
    this.consultantMobile,
    this.vendorName,
    this.education,
    this.description,
    this.rmpId,
    this.accountId,
    this.provider,
  });

  factory ConsultantDetails.fromJson(Map<String, dynamic> json) => ConsultantDetails(
        consultantEmail: json["consultant_email"],
        consultantName: json["consultant_name"],
        consultantMobile: json["consultant_mobile"],
        vendorName: json["vendor_name"],
        education: json["education"],
        description: json["description"],
        rmpId: json["rmp_id"],
        accountId: json["account_id"],
        provider: json["provider"],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "consultant_email": consultantEmail,
        "consultant_name": consultantName,
        "consultant_mobile": consultantMobile,
        "vendor_name": vendorName,
        "education": education,
        "description": description,
        "rmp_id": rmpId,
        "account_id": accountId,
        "provider": provider,
      };
}

class KioskCheckinHistory {
  String weightKg;
  String boneMineralContentStatus;
  String protienStatus;
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
  String bmi;
  DateTime dateTimeFormatted;
  String bmiClass;
  String bpClass;
  DateTime dateTime;
  String boneMineralContent;
  String protien;
  String extraCellularWater;
  String intraCellularWater;
  String mineral;
  String skeletalMuscleMass;
  String bodyFatMass;
  String bodyCellMass;
  String waistHipRatio;
  String percentBodyFat;
  String waistHeightRatio;
  String visceralFat;
  String basalMetabolicRate;
  String basalMetabolicRateStatus;
  String skeletalMuscleMassStatus;
  String extraCellularWaterStatus;
  String intraCellularWaterStatus;

  KioskCheckinHistory({
    this.weightKg,
    this.boneMineralContentStatus,
    this.protienStatus,
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
    this.bmi,
    this.dateTimeFormatted,
    this.bmiClass,
    this.bpClass,
    this.dateTime,
    this.boneMineralContent,
    this.extraCellularWater,
    this.protien,
    this.intraCellularWater,
    this.skeletalMuscleMass,
    this.bodyFatMass,
    this.bodyCellMass,
    this.waistHipRatio,
    this.percentBodyFat,
    this.waistHeightRatio,
    this.visceralFat,
    this.basalMetabolicRate,
    this.mineral,
    this.basalMetabolicRateStatus,
    this.skeletalMuscleMassStatus,
    this.extraCellularWaterStatus,
    this.intraCellularWaterStatus,
  });

  factory KioskCheckinHistory.fromJson(Map<String, dynamic> json) {
    log(jsonEncode(json));
    return KioskCheckinHistory(
      weightKg: json["weightKG"].toString(),
      boneMineralContent: json["bone_mineral_content"].toString(),
      protien: json["protien"].toString(),
      extraCellularWater: json["extra_cellular_water"].toString(),
      intraCellularWater: json["intra_cellular_water"].toString(),
      mineral: json["mineral"].toString(),
      skeletalMuscleMass: json["skeletal_muscle_mass"].toString(),
      bodyFatMass: json["body_fat_mass"].toString(),
      bodyCellMass: json["body_cell_mass"].toString(),
      waistHipRatio: json["waist_hip_ratio"].toString(),
      percentBodyFat: json["percent_body_fat"].toString(),
      waistHeightRatio: json["waist_height_ratio"].toString(),
      visceralFat: json["visceral_fat"].toString(),
      basalMetabolicRate: json["basal_metabolic_rate"].toString(),
      boneMineralContentStatus: json["bone_mineral_content_status"].toString(),
      protienStatus: json["protien_status"].toString(),
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
      bmi: json["bmi"].toString() == "null" || json["bmi"] == ""
          ? "null"
          : double.parse(json["bmi"].toString()).toStringAsFixed(2),
      dateTimeFormatted:
          json["dateTimeFormatted"] == null ? null : DateTime.parse(json["dateTimeFormatted"]),
      bmiClass: json["bmiClass"].toString(),
      bpClass: json["bpClass"].toString(),
      dateTime: json["dateTime"] == null ? null : DateTime.parse(json["dateTime"]),
      basalMetabolicRateStatus: json["basal_metabolic_rate_status"].toString(),
      skeletalMuscleMassStatus: json["skeletal_muscle_mass_status"].toString(),
      extraCellularWaterStatus: json["extra_cellular_water_status"].toString(),
      intraCellularWaterStatus: json["intra_cellular_water_status"].toString(),
    );
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        "Weight": weightKg,
        "Height": heightMeters,
        "Systolic": systolic,
        "Diastolic": diastolic,
        "BMI": bmi,
        "BMI Class": bmiClass,
        "Blood Pressure Class": bpClass,
        "Bone Mineral Content": boneMineralContent,
        "Bone Mineral Content Status": boneMineralContentStatus,
        "Protien": protien,
        "Protien Status": protienStatus,
        "Mineral": mineral,
        "Mineral Status": mineralStatus,
        "Body Fat Mass": bodyFatMass,
        "Body Fat Mass Status": bodyFatMassStatus,
        "Body Cell Mass": bodyCellMass,
        "Body Cell Mass Status": bodyCellMassStatus,
        "Waist Hip Ratio": waistHipRatio,
        "Waist Hip Ratio Status": waistHipRatioStatus,
        "Percent Body Fat": percentBodyFat,
        "Percent Body Fat Status": percentBodyFatStatus,
        "Waist Height Ratio": waistHeightRatio,
        "Waist Height Ratio Status": waistHeightRatioStatus,
        "Visceral Fat": visceralFat,
        "Visceral Fat Status": visceralFatStatus,
        "Extra Cellular Water": extraCellularWater,
        "Extra Cellular Water Status": extraCellularWaterStatus,
        "Intra Cellular Water": intraCellularWater,
        "Intra Cellular Water Status": intraCellularWaterStatus,
        "Skeletal Muscle Mass": skeletalMuscleMass,
        "Skeletal Muscle Mass Status": skeletalMuscleMassStatus,
        "Basal Metabolic Rate": basalMetabolicRate,
        "Basal Metabolic Rate Status": basalMetabolicRateStatus,
        "Date Time":
            dateTime == null ? "null" : DateFormat('dd MMM yyyy  hh:MM aa').format(dateTime),
      };
}

class MedLabPartnerDetails {
  dynamic partnerMedName;
  dynamic partnerMedLogoUrl;
  dynamic partnerLabName;
  dynamic partnerLabLogoUrl;

  MedLabPartnerDetails({
    this.partnerMedName,
    this.partnerMedLogoUrl,
    this.partnerLabName,
    this.partnerLabLogoUrl,
  });

  factory MedLabPartnerDetails.fromJson(Map<String, dynamic> json) => MedLabPartnerDetails(
        partnerMedName: json["partner_med_name"],
        partnerMedLogoUrl: json["partner_med_logo_url"],
        partnerLabName: json["partner_lab_name"],
        partnerLabLogoUrl: json["partner_lab_logo_url"],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "partner_med_name": partnerMedName,
        "partner_med_logo_url": partnerMedLogoUrl,
        "partner_lab_name": partnerLabName,
        "partner_lab_logo_url": partnerLabLogoUrl,
      };
}

class Message {
  String bookedDateTime;
  String appointmentId;
  String vendorAppointmentId;
  String userIhlId;
  String consultantName;
  String vendorConsultantId;
  String ihlConsultantId;
  String vendorId;
  String consultantType;
  String specality;
  String consultationFees;
  String modeOfPayment;
  dynamic followupAvailablityTillDate;
  dynamic followUpCost;
  String alergy;
  String appointmentStartTime;
  DateTime appointmentDateFormat;
  String appointmentEndTime;
  String appointmentDuration;
  String appointmentStatus;
  dynamic callStatus;
  dynamic callStartTime;
  dynamic callEndTime;
  dynamic consultationInternalNotes;
  dynamic consultationAdviceNotes;
  dynamic diagnosis;
  List<RadiologyModel> radiology;
  String appointmentModel;
  String vendorName;
  String reasonForVisit;
  List notes;
  KioskCheckinHistory kioskCheckinHistory;
  dynamic medication;
  dynamic adviceToPatient;
  List patientDiagnosis;
  dynamic advice;
  dynamic symptoms;
  dynamic patientSymptoms;
  dynamic prescription;
  List<LabTestModel> labTests;
  dynamic encounterId;
  String doctorCancelledReason;
  String documentId;
  String directCall;
  String affiliationUniqueName;
  String kioskId;
  dynamic alergyGenix;
  String partitionKey;
  String rowKey;
  DateTime timestamp;
  String eTag;

  Message({
    this.bookedDateTime,
    this.appointmentId,
    this.vendorAppointmentId,
    this.userIhlId,
    this.consultantName,
    this.vendorConsultantId,
    this.ihlConsultantId,
    this.vendorId,
    this.consultantType,
    this.specality,
    this.consultationFees,
    this.modeOfPayment,
    this.followupAvailablityTillDate,
    this.followUpCost,
    this.alergy,
    this.appointmentStartTime,
    this.appointmentDateFormat,
    this.appointmentEndTime,
    this.appointmentDuration,
    this.appointmentStatus,
    this.callStatus,
    this.callStartTime,
    this.callEndTime,
    this.consultationInternalNotes,
    this.consultationAdviceNotes,
    this.diagnosis,
    this.radiology,
    this.appointmentModel,
    this.vendorName,
    this.reasonForVisit,
    this.notes,
    this.kioskCheckinHistory,
    this.medication,
    this.adviceToPatient,
    this.patientDiagnosis,
    this.advice,
    this.symptoms,
    this.patientSymptoms,
    this.prescription,
    this.labTests,
    this.encounterId,
    this.doctorCancelledReason,
    this.documentId,
    this.directCall,
    this.affiliationUniqueName,
    this.kioskId,
    this.alergyGenix,
    this.partitionKey,
    this.rowKey,
    this.timestamp,
    this.eTag,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        bookedDateTime: json["booked_date_time"],
        appointmentId: json["appointment_id"],
        vendorAppointmentId: json["vendor_appointment_id"],
        userIhlId: json["user_ihl_id"],
        consultantName: json["consultant_name"],
        vendorConsultantId: json["vendor_consultant_id"],
        ihlConsultantId: json["ihl_consultant_id"],
        vendorId: json["vendor_id"],
        consultantType: json["consultant_type"],
        specality: json["specality"] == "null" ? "N/A" : json["specality"],
        consultationFees: json["consultation_fees"].toString(),
        modeOfPayment: json["mode_of_payment"],
        followupAvailablityTillDate: json["followup_availablity_till_date"],
        followUpCost: json["follow_up_cost"],
        alergy: json["alergy"] == "" ? null : json["alergy"],
        appointmentStartTime: json["appointment_start_time"],
        appointmentDateFormat: DateTime.parse(json["appointment_date_format"]),
        appointmentEndTime: json["appointment_end_time"],
        appointmentDuration: json["appointment_duration"],
        appointmentStatus: json["appointment_status"],
        callStatus: json["call_status"],
        callStartTime: json["call_start_time"],
        callEndTime: json["call_end_time"],
        consultationInternalNotes: json["consultation_internal_notes"],
        consultationAdviceNotes: json["consultation_advice_notes"] != null
            ? json["consultation_advice_notes"].toString().replaceAll('&#39;', "'")
            : json["consultation_advice_notes"],
        diagnosis: json["diagnosis"] != null
            ? json["diagnosis"].toString().replaceAll('&#39;', "'")
            : json["diagnosis"],
        radiology: json["radiology"].toString() == "[]" || json["radiology"].toString() == "null"
            ? <RadiologyModel>[]
            : List<RadiologyModel>.from(json["radiology"].map((dynamic e) {
                return RadiologyModel.fromJson(e);
              })),
        appointmentModel: json["appointment_model"],
        vendorName: json["vendor_name"],
        reasonForVisit: json["reason_for_visit"],
        notes: json["notes"] is! List
            ? json["notes"] == "[]" || json["notes"] == ""
                ? []
                : [json["notes"]]
            : json["notes"].map((e) => e["Description"]).toList(),
        kioskCheckinHistory: json["kiosk_checkin_history"] == null
            ? null
            : KioskCheckinHistory.fromJson(json["kiosk_checkin_history"]),
        medication: json["medication"],
        adviceToPatient: json["advice_to_patient"],
        patientDiagnosis: json["patient_diagnosis"] ?? <dynamic>[],
        advice: json["advice"],
        symptoms: json["symptoms"],
        patientSymptoms: json["patient_symptoms"],
        prescription: json["prescription"],
        labTests: json["lab_tests"].toString() == "[]" || json["lab_tests"].toString() == "null"
            ? <LabTestModel>[]
            : List<LabTestModel>.from(json["lab_tests"].map((dynamic e) {
                return LabTestModel.fromJson(e);
              })),
        encounterId: json["encounter_id"],
        doctorCancelledReason: json["doctor_cancelled_reason"],
        documentId: json["document_id"],
        directCall: json["direct_call"],
        affiliationUniqueName: json["affiliation_unique_name"],
        kioskId: json["kiosk_id"],
        alergyGenix: json["alergy_genix"],
        partitionKey: json["PartitionKey"],
        rowKey: json["RowKey"],
        timestamp: DateTime.parse(json["Timestamp"]),
        eTag: json["ETag"],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "booked_date_time": bookedDateTime,
        "appointment_id": appointmentId,
        "vendor_appointment_id": vendorAppointmentId,
        "user_ihl_id": userIhlId,
        "consultant_name": consultantName,
        "vendor_consultant_id": vendorConsultantId,
        "ihl_consultant_id": ihlConsultantId,
        "vendor_id": vendorId,
        "consultant_type": consultantType,
        "specality": specality,
        "consultation_fees": consultationFees,
        "mode_of_payment": modeOfPayment,
        "followup_availablity_till_date": followupAvailablityTillDate,
        "follow_up_cost": followUpCost,
        "alergy": alergy,
        "appointment_start_time": appointmentStartTime,
        "appointment_date_format": appointmentDateFormat.toIso8601String(),
        "appointment_end_time": appointmentEndTime,
        "appointment_duration": appointmentDuration,
        "appointment_status": appointmentStatus,
        "call_status": callStatus,
        "call_start_time": callStartTime,
        "call_end_time": callEndTime,
        "consultation_internal_notes": consultationInternalNotes,
        "consultation_advice_notes": consultationAdviceNotes,
        "diagnosis": diagnosis,
        "radiology": radiology,
        "appointment_model": appointmentModel,
        "vendor_name": vendorName,
        "reason_for_visit": reasonForVisit,
        "notes": notes,
        "kiosk_checkin_history": kioskCheckinHistory.toJson(),
        "medication": medication,
        "advice_to_patient": adviceToPatient,
        "patient_diagnosis": patientDiagnosis,
        "advice": advice,
        "symptoms": symptoms,
        "patient_symptoms": patientSymptoms,
        "prescription": prescription,
        "lab_tests": labTests,
        "encounter_id": encounterId,
        "doctor_cancelled_reason": doctorCancelledReason,
        "document_id": documentId,
        "direct_call": directCall,
        "affiliation_unique_name": affiliationUniqueName,
        "kiosk_id": kioskId,
        "alergy_genix": alergyGenix,
        "PartitionKey": partitionKey,
        "RowKey": rowKey,
        "Timestamp": timestamp.toIso8601String(),
        "ETag": eTag,
      };
}

class UserDetails {
  String userFirstName;
  String userLastName;
  String userMobileNumber;
  String userEmail;
  String age;
  String gender;

  UserDetails(
      {this.userFirstName,
      this.userLastName,
      this.userMobileNumber,
      this.userEmail,
      this.age,
      this.gender});

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        userFirstName: json["user_first_name"],
        userLastName: json["user_last_name"],
        userMobileNumber: json["user_mobile_number"],
        userEmail: json["user_email"],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "user_first_name": userFirstName,
        "user_last_name": userLastName,
        "user_mobile_number": userMobileNumber,
        "user_email": userEmail,
      };
}

class LabTestModel {
  String testPrescribedOn;
  String testName;
  String labNote;
  String prescribedBy;

  LabTestModel({
    this.testPrescribedOn,
    this.testName,
    this.labNote,
    this.prescribedBy,
  });

  factory LabTestModel.fromJson(Map<String, dynamic> json) => LabTestModel(
        testPrescribedOn: json["test_prescribed_on"] ?? "N/A",
        testName: json["test_name"] ?? "N/A",
        labNote: json["lab_note"] ?? "N/A",
        prescribedBy: json["prescribed_by"] ?? "N/A",
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "test_prescribed_on": testPrescribedOn,
        "test_name": testName,
        "lab_note": labNote,
        "prescribed_by": prescribedBy,
      };
}

class RadiologyModel {
  String testPrescribedOn;
  String testName;
  String radiologyNote;
  String prescribedBy;

  RadiologyModel({
    this.testPrescribedOn,
    this.testName,
    this.radiologyNote,
    this.prescribedBy,
  });

  factory RadiologyModel.fromJson(Map<String, dynamic> json) => RadiologyModel(
        testPrescribedOn: json["test_prescribed_on"] ?? "N/A",
        testName: json["test_name"] ?? "N/A",
        radiologyNote: json["radiology_note"] ?? "N/A",
        prescribedBy: json["prescribed_by"] ?? "N/A",
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "test_prescribed_on": testPrescribedOn,
        "test_name": testName,
        "radiology_note": radiologyNote,
        "prescribed_by": prescribedBy,
      };
}
