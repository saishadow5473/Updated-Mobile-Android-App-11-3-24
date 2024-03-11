// // To parse this JSON data, do
// //
// //     final characterSummary = characterSummaryFromJson(jsonString);
//
// import 'package:meta/meta.dart';
// import 'dart:convert';
//
// List<CharacterSummary> characterSummaryFromJson(String str) => List<CharacterSummary>.from(json.decode(str).map((x) => CharacterSummary.fromJson(x)));
//
// String characterSummaryToJson(List<CharacterSummary> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//
// class CharacterSummary {
//   CharacterSummary({
//     this.bookApointment,
//     this.messageUserdata,
//     this.transactionId,
//   });
//
//   BookApointment bookApointment;
//   MessageUserdata messageUserdata;
//   String transactionId;
//
//   factory CharacterSummary.fromJson(Map<String, dynamic> json) => CharacterSummary(
//     bookApointment: BookApointment.fromJson(json["Book_Apointment"]),
//     messageUserdata: MessageUserdata.fromJson(json["message_userdata"]),
//     transactionId: json["transactionId"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "Book_Apointment": bookApointment.toJson(),
//     "message_userdata": messageUserdata.toJson(),
//     "transactionId": transactionId,
//   };
// }
//
// class BookApointment {
//   BookApointment({
//     this.directCall,
//     this.callStatus,
//     this.appointmentId,
//     this.bookedDateTime,
//     this.userIhlId,
//     this.consultantName,
//     this.vendorConsultantId,
//     this.ihlConsultantId,
//     this.vendorId,
//     this.consultantType,
//     this.specality,
//     this.consultationFees,
//     this.modeOfPayment,
//     this.appointmentStartTime,
//     this.appointmentEndTime,
//     this.appointmentDuration,
//     this.appointmentStatus,
//     this.appointmentModel,
//     this.vendorName,
//     this.notes,
//     this.kioskCheckinHistory,
//     this.documentId,
//     this.affiliationUniqueName,
//     this.kioskId,
//   });
//
//   bool directCall;
//   String callStatus;
//   String appointmentId;
//   dynamic bookedDateTime;
//   String userIhlId;
//   String consultantName;
//   String vendorConsultantId;
//   String ihlConsultantId;
//   String vendorId;
//   String consultantType;
//   String specality;
//   String consultationFees;
//   String modeOfPayment;
//   String appointmentStartTime;
//   String appointmentEndTime;
//   String appointmentDuration;
//   String appointmentStatus;
//   String appointmentModel;
//   String vendorName;
//   String notes;
//   Map kioskCheckinHistory;
//   List<String> documentId;
//   String affiliationUniqueName;
//   String kioskId;
//
//   factory BookApointment.fromJson(Map<String, dynamic> json) => BookApointment(
//     directCall: json["direct_call"],
//     callStatus: json["call_status"] == null ? 'null' : json["call_status"],
//     appointmentId: json["appointment_id"].toString(),
//     bookedDateTime: json["booked_date_time"].toString(),
//     userIhlId: json["user_ihl_id"].toString(),//userIhlIdValues.map[json["user_ihl_id"]],
//     consultantName: json["consultant_name"].toString(),//consultantNameValues.map[json["consultant_name"]],
//     vendorConsultantId: json["vendor_consultant_id"].toString(),//consultantIdValues.map[json["vendor_consultant_id"]],
//     ihlConsultantId: json["ihl_consultant_id"].toString(),//consultantIdValues.map[json["ihl_consultant_id"]],
//     vendorId: json["vendor_id"].toString(),//vendorIdValues.map[json["vendor_id"]],
//     consultantType: json["consultant_type"].toString(),
//     specality: json["specality"].toString(),//specalityValues.map[json["specality"]],
//     consultationFees: json["consultation_fees"].toString(),
//     modeOfPayment: json["mode_of_payment"].toString(),//modeOfPaymentValues.map[json["mode_of_payment"]],
//     appointmentStartTime: json["appointment_start_time"].toString(),
//     appointmentEndTime: json["appointment_end_time"].toString(),
//     appointmentDuration: json["appointment_duration"].toString(),//appointmentDurationValues.map[json["appointment_duration"]],
//     appointmentStatus: json["appointment_status"].toString(),//appointmentStatusValues.map[json["appointment_status"]],
//     appointmentModel: json["appointment_model"].toString(),
//     vendorName: json["vendor_name"].toString(),//vendorIdValues.map[json["vendor_name"]],
//     notes: json["notes"].toString(),
//     kioskCheckinHistory:
//     json["kiosk_checkin_history"].toString().length<4 ||
//         json["kiosk_checkin_history"]=='' ||
//         json["kiosk_checkin_history"].toString()=='null'?{}:json["kiosk_checkin_history"],
//     // json["kiosk_checkin_history"].toString().length<4 ||json["kiosk_checkin_history"]=='' ||json["kiosk_checkin_history"].toString()=='null'?"{}":json["kiosk_checkin_history"].toString(),
//     // json["kiosk_checkin_history"].toString().length<4 ||json["kiosk_checkin_history"]=='' ||json["kiosk_checkin_history"].toString()=='null'?{}:
//     // json["kiosk_checkin_history"],),)
//     documentId: json["document_id"].toString()!='null'?List<String>.from(json["document_id"].map((x) => x)):[],
//     affiliationUniqueName: json["affiliation_unique_name"].toString(),
//     kioskId: json["kiosk_id"].toString(),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "direct_call": directCall,
//     "call_status": callStatus == null ? null : callStatus,
//     "appointment_id": appointmentId,
//     "booked_date_time": bookedDateTime,
//     "user_ihl_id": userIhlId,//userIhlIdValues.reverse[userIhlId],
//     "consultant_name": consultantName,//consultantNameValues.reverse[consultantName],
//     "vendor_consultant_id": vendorConsultantId,//consultantIdValues.reverse[vendorConsultantId],
//     "ihl_consultant_id": ihlConsultantId,//consultantIdValues.reverse[ihlConsultantId],
//     "vendor_id": vendorId,//vendorIdValues.reverse[vendorId],
//     "consultant_type": consultantType,
//     "specality": specality,//specalityValues.reverse[specality],
//     "consultation_fees": consultationFees,
//     "mode_of_payment": modeOfPayment,//modeOfPaymentValues.reverse[modeOfPayment],
//     "appointment_start_time": appointmentStartTime,
//     "appointment_end_time": appointmentEndTime,
//     "appointment_duration": appointmentDuration,//appointmentDurationValues.reverse[appointmentDuration],
//     "appointment_status": appointmentStatus,//appointmentStatusValues.reverse[appointmentStatus],
//     "appointment_model": appointmentModel,
//     "vendor_name": vendorName,//vendorIdValues.reverse[vendorName],
//     "notes": notes,
//     "kiosk_checkin_history":kioskCheckinHistory,//kioskCheckinHistoryValues.reverse[kioskCheckinHistory],
//     "document_id": List<dynamic>.from(documentId.map((x) => x)),
//     "affiliation_unique_name": affiliationUniqueName,
//     "kiosk_id": kioskId,
//   };
// }
//
//
//
// class MessageUserdata {
//   MessageUserdata({
//     this.ihlId,
//     this.patientId,
//     this.vendorId,
//     this.firstName,
//     this.lastName,
//     this.gender,
//     this.email,
//     this.mobileNumber,
//     this.dob,
//     this.heightMeters,
//     this.accountId,
//     this.accountName,
//     this.partitionKey,
//     this.rowKey,
//     this.timestamp,
//     this.eTag,
//   });
//
//   String ihlId;
//   String patientId;
//   String vendorId;
//   String firstName;
//   String lastName;
//   String gender;
//   String email;
//   String mobileNumber;
//   String dob;
//   String heightMeters;
//   String accountId;
//   String accountName;
//   String partitionKey;
//   String rowKey;
//   String timestamp;
//   String eTag;
//
//   factory MessageUserdata.fromJson(Map<String, dynamic> json) => MessageUserdata(
//     ihlId: json["ihl_id"].toString(),//userIhlIdValues.map[json["ihl_id"]],
//     patientId: json["patient_id"].toString(),//userIhlIdValues.map[json["patient_id"]],
//     vendorId: json["vendor_id"].toString(),//vendorIdValues.map[json["vendor_id"]],
//     firstName: json["firstName"].toString(),//firstNameValues.map[json["firstName"]],
//     lastName: json["lastName"].toString(),//lastNameValues.map[json["lastName"]],
//     gender: json["gender"].toString(),//genderValues.map[json["gender"]],
//     email: json["email"].toString(),//emailValues.map[json["email"]],
//     mobileNumber: json["mobileNumber"].toString(),
//     dob: json["dob"].toString(),//dobValues.map[json["dob"]],
//     heightMeters: json["heightMeters"].toString(),
//     accountId: json["account_id"].toString(),
//     accountName: json["account_name"].toString(),
//     partitionKey: json["PartitionKey"].toString(),//vendorIdValues.map[json["PartitionKey"]],
//     rowKey: json["RowKey"].toString(),//userIhlIdValues.map[json["RowKey"]],
//     timestamp: json["Timestamp"].toString(),//DateTime.parse(json["Timestamp"]),
//     eTag: json["ETag"].toString(),//eTagValues.map[json["ETag"]],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "ihl_id":ihlId,// userIhlIdValues.reverse[ihlId],
//     "patient_id": patientId,//userIhlIdValues.reverse[patientId],
//     "vendor_id": vendorId,//vendorIdValues.reverse[vendorId],
//     "firstName": firstName,//firstNameValues.reverse[firstName],
//     "lastName": lastName,//lastNameValues.reverse[lastName],
//     "gender": gender,//genderValues.reverse[gender],
//     "email": email,//emailValues.reverse[email],
//     "mobileNumber": mobileNumber,
//     "dob": dob,//dobValues.reverse[dob],
//     "heightMeters": heightMeters,
//     "account_id": accountId,
//     "account_name": accountName,
//     "PartitionKey": partitionKey,//vendorIdValues.reverse[partitionKey],
//     "RowKey": rowKey,//userIhlIdValues.reverse[rowKey],
//     "Timestamp": timestamp.toString(),
//     "ETag": eTag,//eTagValues.reverse[eTag],
//   };
// }
//
//
//
// ///     final kisokCheckinHistory = kisokCheckinHistoryFromJson(jsonString);
//
// KisokCheckinHistory kisokCheckinHistoryFromJson(String str) => KisokCheckinHistory.fromJson(json.decode(str));
//
// String kisokCheckinHistoryToJson(KisokCheckinHistory data) => json.encode(data.toJson());
//
// class KisokCheckinHistory {
//   KisokCheckinHistory({
//     this.dateTime,
//     this.weightKg,
//     this.percentBodyFat,
//     this.heightMeters,
//     this.systolic,
//     this.diastolic,
//     this.pulseBpm,
//     this.spo2,
//     this.temperature,
//     this.bmi,
//     this.bmiClass,
//     this.bpClass,
//     this.spo2Class,
//     this.temperatureClass,
//   });
//
//   String dateTime;
//   String weightKg;
//   String percentBodyFat;
//   String heightMeters;
//   String systolic;
//   String diastolic;
//   String pulseBpm;
//   String spo2;
//   String temperature;
//   String bmi;
//   String bmiClass;
//   String bpClass;
//   String spo2Class;
//   String temperatureClass;
//
//   factory KisokCheckinHistory.fromJson(Map<String, dynamic> json) => KisokCheckinHistory(
//     dateTime: json["dateTime"],
//     weightKg: json["weightKG"],
//     percentBodyFat: json["percent_body_fat"],
//     heightMeters: json["heightMeters"],
//     systolic: json["systolic"],
//     diastolic: json["diastolic"],
//     pulseBpm: json["pulseBpm"],
//     spo2: json["spo2"],
//     temperature: json["temperature"],
//     bmi: json["bmi"],
//     bmiClass: json["bmiClass"],
//     bpClass: json["bpClass"],
//     spo2Class: json["spo2Class"],
//     temperatureClass: json["temperatureClass"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "dateTime": dateTime.toString(),
//     "weightKG": weightKg,
//     "percent_body_fat": percentBodyFat,
//     "heightMeters": heightMeters,
//     "systolic": systolic,
//     "diastolic": diastolic,
//     "pulseBpm": pulseBpm,
//     "spo2": spo2,
//     "temperature": temperature,
//     "bmi": bmi,
//     "bmiClass": bmiClass,
//     "bpClass": bpClass,
//     "spo2Class": spo2Class,
//     "temperatureClass": temperatureClass,
//   };
// }
// To parse this JSON data, do
//
//     final characterSummary = characterSummaryFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<CharacterSummary> characterSummaryFromJson(String str) => List<CharacterSummary>.from(json.decode(str).map((x) => x.length>1?CharacterSummary.fromJson(x):null));

String characterSummaryToJson(List<CharacterSummary> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CharacterSummary {
  CharacterSummary({
    this.bookApointment,
    this.messageUserdata,
    this.transactionId,
  });

  BookApointment bookApointment;
  MessageUserdata messageUserdata;
  String transactionId;

  factory CharacterSummary.fromJson(Map<String, dynamic> json) => CharacterSummary(
    bookApointment: BookApointment.fromJson(json["Book_Apointment"]),
    messageUserdata: MessageUserdata.fromJson(json["message_userdata"]??json['message_userdata_genix']),
    transactionId: json["transactionId"],
  );

  Map<String, dynamic> toJson() => {
    "Book_Apointment": bookApointment.toJson(),
    "message_userdata": messageUserdata.toJson(),
    "transactionId": transactionId,
  };
}

class BookApointment {
  BookApointment({
    this.directCall,
    this.callStatus,
    this.appointmentId,
    this.bookedDateTime,
    this.userIhlId,
    this.consultantName,
    this.vendorConsultantId,
    this.ihlConsultantId,
    this.vendorId,
    this.consultantType,
    this.specality,
    this.consultationFees,
    this.modeOfPayment,
    this.appointmentStartTime,
    this.appointmentEndTime,
    this.appointmentDuration,
    this.appointmentStatus,
    this.appointmentModel,
    this.vendorName,
    this.notes,
    this.kioskCheckinHistory,
    this.documentId,
    this.affiliationUniqueName,
    this.kioskId,
  });

  bool directCall;
  String callStatus;
  String appointmentId;
  dynamic bookedDateTime;
  String userIhlId;
  String consultantName;
  String vendorConsultantId;
  String ihlConsultantId;
  String vendorId;
  String consultantType;
  String specality;
  String consultationFees;
  String modeOfPayment;
  String appointmentStartTime;
  String appointmentEndTime;
  String appointmentDuration;
  String appointmentStatus;
  String appointmentModel;
  String vendorName;
  String notes;
  Map kioskCheckinHistory;
  List<String> documentId;
  String affiliationUniqueName;
  String kioskId;

  factory BookApointment.fromJson(Map<String, dynamic> json) => BookApointment(
    directCall: json["direct_call"],
    callStatus: json["call_status"] == null ? 'null' : json["call_status"],
    appointmentId: json["appointment_id"].toString(),
    bookedDateTime: json["booked_date_time"].toString(),
    userIhlId: json["user_ihl_id"].toString(),//userIhlIdValues.map[json["user_ihl_id"]],
    consultantName: json["consultant_name"].toString(),//consultantNameValues.map[json["consultant_name"]],
    vendorConsultantId: json["vendor_consultant_id"].toString(),//consultantIdValues.map[json["vendor_consultant_id"]],
    ihlConsultantId: json["ihl_consultant_id"].toString(),//consultantIdValues.map[json["ihl_consultant_id"]],
    vendorId: json["vendor_id"].toString(),//vendorIdValues.map[json["vendor_id"]],
    consultantType: json["consultant_type"].toString(),
    specality: json["specality"].toString(),//specalityValues.map[json["specality"]],
    consultationFees: json["consultation_fees"].toString(),
    modeOfPayment: json["mode_of_payment"].toString(),//modeOfPaymentValues.map[json["mode_of_payment"]],
    appointmentStartTime: json["appointment_start_time"].toString(),
    appointmentEndTime: json["appointment_end_time"].toString(),
    appointmentDuration: json["appointment_duration"].toString(),//appointmentDurationValues.map[json["appointment_duration"]],
    appointmentStatus: json["appointment_status"].toString(),//appointmentStatusValues.map[json["appointment_status"]],
    appointmentModel: json["appointment_model"].toString(),
    vendorName: json["vendor_name"].toString(),//vendorIdValues.map[json["vendor_name"]],
    notes: json["notes"].toString(),
    kioskCheckinHistory:
    json["kiosk_checkin_history"].toString().length<4 ||
        json["kiosk_checkin_history"]=='' ||
        json["kiosk_checkin_history"].toString()=='null'?{}:json["kiosk_checkin_history"],
    // json["kiosk_checkin_history"].toString().length<4 ||json["kiosk_checkin_history"]=='' ||json["kiosk_checkin_history"].toString()=='null'?"{}":json["kiosk_checkin_history"].toString(),
    // json["kiosk_checkin_history"].toString().length<4 ||json["kiosk_checkin_history"]=='' ||json["kiosk_checkin_history"].toString()=='null'?{}:
    // json["kiosk_checkin_history"],),)
    documentId: json["document_id"].toString()!='null'?List<String>.from(json["document_id"].map((x) => x)):[],
    affiliationUniqueName: json["affiliation_unique_name"].toString(),
    kioskId: json["kiosk_id"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "direct_call": directCall,
    "call_status": callStatus == null ? null : callStatus,
    "appointment_id": appointmentId,
    "booked_date_time": bookedDateTime,
    "user_ihl_id": userIhlId,//userIhlIdValues.reverse[userIhlId],
    "consultant_name": consultantName,//consultantNameValues.reverse[consultantName],
    "vendor_consultant_id": vendorConsultantId,//consultantIdValues.reverse[vendorConsultantId],
    "ihl_consultant_id": ihlConsultantId,//consultantIdValues.reverse[ihlConsultantId],
    "vendor_id": vendorId,//vendorIdValues.reverse[vendorId],
    "consultant_type": consultantType,
    "specality": specality,//specalityValues.reverse[specality],
    "consultation_fees": consultationFees,
    "mode_of_payment": modeOfPayment,//modeOfPaymentValues.reverse[modeOfPayment],
    "appointment_start_time": appointmentStartTime,
    "appointment_end_time": appointmentEndTime,
    "appointment_duration": appointmentDuration,//appointmentDurationValues.reverse[appointmentDuration],
    "appointment_status": appointmentStatus,//appointmentStatusValues.reverse[appointmentStatus],
    "appointment_model": appointmentModel,
    "vendor_name": vendorName,//vendorIdValues.reverse[vendorName],
    "notes": notes,
    "kiosk_checkin_history":kioskCheckinHistory,//kioskCheckinHistoryValues.reverse[kioskCheckinHistory],
    "document_id": List<dynamic>.from(documentId.map((x) => x)),
    "affiliation_unique_name": affiliationUniqueName,
    "kiosk_id": kioskId,
  };
}



class MessageUserdata {
  MessageUserdata({
    this.ihlId,
    this.patientId,
    this.vendorId,
    this.firstName,
    this.lastName,
    this.gender,
    this.email,
    this.mobileNumber,
    this.dob,
    this.heightMeters,
    this.accountId,
    this.accountName,
    this.partitionKey,
    this.rowKey,
    this.timestamp,
    this.eTag,
  });

  String ihlId;
  String patientId;
  String vendorId;
  String firstName;
  String lastName;
  String gender;
  String email;
  String mobileNumber;
  String dob;
  String heightMeters;
  String accountId;
  String accountName;
  String partitionKey;
  String rowKey;
  String timestamp;
  String eTag;

  factory MessageUserdata.fromJson(Map<String, dynamic> json) => MessageUserdata(
    ihlId: json["ihl_id"].toString(),//userIhlIdValues.map[json["ihl_id"]],
    patientId: json["patient_id"].toString(),//userIhlIdValues.map[json["patient_id"]],
    vendorId: json["vendor_id"].toString(),//vendorIdValues.map[json["vendor_id"]],
    firstName: json["firstName"].toString(),//firstNameValues.map[json["firstName"]],
    lastName: json["lastName"].toString(),//lastNameValues.map[json["lastName"]],
    gender: json["gender"].toString(),//genderValues.map[json["gender"]],
    email: json["email"].toString(),//emailValues.map[json["email"]],
    mobileNumber: json["mobileNumber"].toString(),
    dob: json["dob"].toString(),//dobValues.map[json["dob"]],
    heightMeters: json["heightMeters"].toString(),
    accountId: json["account_id"].toString(),
    accountName: json["account_name"].toString(),
    partitionKey: json["PartitionKey"].toString(),//vendorIdValues.map[json["PartitionKey"]],
    rowKey: json["RowKey"].toString(),//userIhlIdValues.map[json["RowKey"]],
    timestamp: json["Timestamp"].toString(),//DateTime.parse(json["Timestamp"]),
    eTag: json["ETag"].toString(),//eTagValues.map[json["ETag"]],
  );

  Map<String, dynamic> toJson() => {
    "ihl_id":ihlId,// userIhlIdValues.reverse[ihlId],
    "patient_id": patientId,//userIhlIdValues.reverse[patientId],
    "vendor_id": vendorId,//vendorIdValues.reverse[vendorId],
    "firstName": firstName,//firstNameValues.reverse[firstName],
    "lastName": lastName,//lastNameValues.reverse[lastName],
    "gender": gender,//genderValues.reverse[gender],
    "email": email,//emailValues.reverse[email],
    "mobileNumber": mobileNumber,
    "dob": dob,//dobValues.reverse[dob],
    "heightMeters": heightMeters,
    "account_id": accountId,
    "account_name": accountName,
    "PartitionKey": partitionKey,//vendorIdValues.reverse[partitionKey],
    "RowKey": rowKey,//userIhlIdValues.reverse[rowKey],
    "Timestamp": timestamp.toString(),
    "ETag": eTag,//eTagValues.reverse[eTag],
  };
}



///     final kisokCheckinHistory = kisokCheckinHistoryFromJson(jsonString);

KisokCheckinHistory kisokCheckinHistoryFromJson(String str) => KisokCheckinHistory.fromJson(json.decode(str));

String kisokCheckinHistoryToJson(KisokCheckinHistory data) => json.encode(data.toJson());

class KisokCheckinHistory {
  KisokCheckinHistory({
    this.dateTime,
    this.weightKg,
    this.percentBodyFat,
    this.heightMeters,
    this.systolic,
    this.diastolic,
    this.pulseBpm,
    this.spo2,
    this.temperature,
    this.bmi,
    this.bmiClass,
    this.bpClass,
    this.spo2Class,
    this.temperatureClass,
  });

  String dateTime;
  String weightKg;
  String percentBodyFat;
  String heightMeters;
  String systolic;
  String diastolic;
  String pulseBpm;
  String spo2;
  String temperature;
  String bmi;
  String bmiClass;
  String bpClass;
  String spo2Class;
  String temperatureClass;

  factory KisokCheckinHistory.fromJson(Map<String, dynamic> json) => KisokCheckinHistory(
    dateTime: json["dateTime"],
    weightKg: json["weightKG"],
    percentBodyFat: json["percent_body_fat"],
    heightMeters: json["heightMeters"],
    systolic: json["systolic"],
    diastolic: json["diastolic"],
    pulseBpm: json["pulseBpm"],
    spo2: json["spo2"],
    temperature: json["temperature"],
    bmi: json["bmi"],
    bmiClass: json["bmiClass"],
    bpClass: json["bpClass"],
    spo2Class: json["spo2Class"],
    temperatureClass: json["temperatureClass"],
  );

  Map<String, dynamic> toJson() => {
    "dateTime": dateTime.toString(),
    "weightKG": weightKg,
    "percent_body_fat": percentBodyFat,
    "heightMeters": heightMeters,
    "systolic": systolic,
    "diastolic": diastolic,
    "pulseBpm": pulseBpm,
    "spo2": spo2,
    "temperature": temperature,
    "bmi": bmi,
    "bmiClass": bmiClass,
    "bpClass": bpClass,
    "spo2Class": spo2Class,
    "temperatureClass": temperatureClass,
  };
}
