// To parse this JSON data, do
//
//     final upcomingDetails = upcomingDetailsFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../health_challenge/models/challengemodel.dart';

UpcomingDetails upcomingDetailsFromJson(String str) => UpcomingDetails.fromJson(json.decode(str));

String upcomingDetailsToJson(UpcomingDetails data) => json.encode(data.toJson());

class UpcomingDetails {
  UpcomingDetails({
    this.appointmentList,
    this.subcriptionList,
    this.enrolChallengeList,
  });

  List<AppointmentList> appointmentList;
  List<SubcriptionList> subcriptionList;
  List<EnrolledChallenge> enrolChallengeList = [];

  factory UpcomingDetails.fromJson(Map<String, dynamic> json) => UpcomingDetails(
        appointmentList: List<AppointmentList>.from(
            json["Appointment_list"].map((x) => AppointmentList.fromJson(x))),
        subcriptionList: List<SubcriptionList>.from(
            json["Subcription_list"].map((x) => SubcriptionList.fromJson(x))),
        enrolChallengeList: List<EnrolledChallenge>.from(
            json["enrol_challenge_list"].map((x) => EnrolledChallenge.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Appointment_list": List<dynamic>.from(appointmentList.map((x) => x.toJson())),
        "Subcription_list": List<dynamic>.from(subcriptionList.map((x) => x.toJson())),
        "enrol_challenge_list": List<dynamic>.from(enrolChallengeList.map((x) => x.toJson())),
      };
}

class AppointmentList {
  AppointmentList(
      {@required this.appointmentId,
      @required this.bookedDateTime,
      @required this.consultantName,
      @required this.vendorConsultantId,
      @required this.ihlConsultantId,
      @required this.vendorId,
      @required this.consultantType,
      @required this.consultationFees,
      @required this.modeOfPayment,
      @required this.alergy,
      @required this.kioskCheckinHistory,
      @required this.appointmentStartTime,
      @required this.appointmentEndTime,
      @required this.appointmentDuration,
      @required this.appointmentStatus,
      @required this.startIndex,
      @required this.endIndex,
      @required this.specality,
      @required this.rating,
      @required this.callstatus,
      @required this.experience});

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
  DateTime appointmentStartTime;
  DateTime appointmentEndTime;
  String appointmentDuration;
  String appointmentStatus;
  String specality;
  String rating;
  String experience;
  int startIndex;
  int endIndex;
  String callstatus;

  factory AppointmentList.fromJson(Map<String, dynamic> json) => AppointmentList(
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
      kioskCheckinHistory: json["kiosk_checkin_history"],
      appointmentStartTime: conveterDateTime(datetime: json["appointment_start_time"]),
      appointmentEndTime: conveterDateTime(datetime: json["appointment_end_time"]),
      appointmentDuration: json["appointment_duration"],
      appointmentStatus: json["appointment_status"],
      startIndex: json["start_index"],
      endIndex: json["end_index"],
      specality: json["specality"],
      experience: json["experience"],
      callstatus: json["call_status"],
      rating: json["rating"]);

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
        "specality": specality,
        "experience": experience,
        "rating": rating,
        "call_status": callstatus
      };
}

DateTime conveterDateTime({@required String datetime}) {
  DateTime s = DateFormat("yyyy-MM-dd hh:mm aa").parse(datetime);
  return s;
}

class EnrolledChallenge {
  EnrolledChallenge(
      {@required this.userStatus,
      @required this.name,
      @required this.city,
      @required this.department,
      @required this.designation,
      @required this.gender,
      @required this.enrollmentId,
      @required this.challengeId,
      @required this.challengeMode,
      @required this.challengeType,
      @required this.target,
      @required this.userAchieved,
      @required this.userProgress,
      @required this.groupId,
      @required this.groupAchieved,
      @required this.groupProgress,
      @required this.userduration,
      @required this.challenge_end_time,
      @required this.challenge_start_time,
      @required this.last_updated,
      @required this.user_bib_no,
      @required this.selectedFitnessApp,
      @required this.docUrl,
      @required this.speed,
      @required this.docFilename,
      @required this.docStatus,
      @required this.challengeUnit,
      @required this.challenge_name,
      @required this.challenge_completed_certficate_url,
      @required this.challengeImageUrl,
      @required this.challengeBannerImageUrl,
      @required this.userStartTime,
      @required this.userEndTime,
      @required this.challengeThumbnailUrl});

  String userStatus,
      challenge_name,
      name,
      city,
      department,
      designation,
      gender,
      enrollmentId,
      challengeId,
      challengeMode,
      challengeType,
      challengeUnit,
      userProgress,
      groupId,
      last_updated,
      groupProgress,
      challengeImageUrl,
      challengeThumbnailUrl,
      challengeBannerImageUrl;
  String selectedFitnessApp, challenge_completed_certficate_url;
  String docUrl;
  String docFilename;
  String docStatus = '';
  String user_bib_no = '';
  String speed = '0.00';
  DateTime challenge_start_time, challenge_end_time, userStartTime, userEndTime;
  int target, userduration;
  double userAchieved, groupAchieved;

  factory EnrolledChallenge.fromJson(Map<String, dynamic> json) => EnrolledChallenge(
        challengeImageUrl: json['img_url'],
        challengeBannerImageUrl: json['challenge_Banner_img_url'],
        challengeThumbnailUrl: json['thumbnail_url'],
        userStatus: json["user_status"],
        last_updated: json['last_updated'].replaceAll('/Date(', '').replaceAll('+0000)/', ''),
        name: json["name"],
        userduration: int.parse(json['user_duration'] ?? '0'),
        city: json["city"],
        userStartTime: dateTimeConverter(json['user_start_time']),
        userEndTime: dateTimeConverter(json['user_end_time']),
        department: json["department"],
        designation: json["designation"],
        gender: json["gender"],
        speed: json['speed'] ?? '0.00',
        enrollmentId: json["enrollment_id"],
        user_bib_no: json['user_bib_no'] ?? "",
        challengeId: json["challenge_id"],
        challengeMode: json["challenge_mode"],
        challengeType: json["challenge_type"],
        target: int.tryParse(json["target"]??"0"),
        challengeUnit: json['challenge_unit'],
        challenge_name: json['challenge_name'],
        challenge_end_time: dateTimeConverter(json['challenge_end_time']),
        challenge_start_time: dateTimeConverter(json['challenge_start_time']),
        userAchieved: json["user_achieved"] == null ? 0 : double.parse(json["user_achieved"]),
        userProgress: json["user_progress"],
        groupId: json["group_id"] == null ? null : json["group_id"],
        groupAchieved: json["group_achieved"] == null ? 0 : double.parse(json["group_achieved"]),
        groupProgress: json["group_progress"] == null ? null : json["group_progress"],
        selectedFitnessApp: json["selected_fitness_app"],
        docUrl: json["doc_url"],
        docFilename: json["doc_filename"],
        docStatus: json["doc_status"] ?? '',
        challenge_completed_certficate_url: json["challenge_completed_certficate_url"],
      );

  Map<String, dynamic> toJson() => {
        "user_status": userStatus,
        "name": name,
        "city": city,
        "department": department,
        "designation": designation,
        "gender": gender,
        "enrollment_id": enrollmentId,
        "user_bib_no": user_bib_no,
        "challenge_id": challengeId,
        "challenge_mode": challengeMode,
        "challenge_type": challengeType,
        "target": target,
        "user_achieved": userAchieved,
        "user_progress": userProgress,
        'user_duration': userduration,
        "group_id": groupId == null ? null : groupId,
        "group_achieved": groupAchieved == null ? null : groupAchieved,
        "group_progress": groupProgress == null ? null : groupProgress,
        "selected_fitness_app": selectedFitnessApp,
        "doc_url": docUrl,
        "doc_filename": docFilename,
        "doc_status": docStatus ?? '',
        "challenge_completed_certficate_url": challenge_completed_certficate_url
      };
}

class SubcriptionList {
  SubcriptionList(
      {@required this.classDetail,
      @required this.courseId,
      @required this.title,
      @required this.courseTime,
      @required this.courseOn,
      @required this.courseType,
      @required this.provider,
      @required this.consultantId,
      @required this.consultantName,
      @required this.consultantGender,
      @required this.courseFees,
      @required this.feesFor,
      @required this.subscriberCount,
      @required this.courseDuration,
      @required this.subscriptionId,
      @required this.approvalStatus,
      @required this.course_description,
      @required this.current_available,
      @required this.course_frequency,
      this.externalUrl});

  String classDetail;
  String courseId;
  String title;
  String courseTime;
  List<String> courseOn;
  String courseType;
  String provider;
  String consultantId;
  String consultantName;
  String consultantGender;
  int courseFees;
  String feesFor;
  int subscriberCount;
  String courseDuration;
  String subscriptionId;
  String approvalStatus;
  String course_frequency;
  String course_description;
  String current_available;
  String externalUrl;

  factory SubcriptionList.fromJson(Map<String, dynamic> json) => SubcriptionList(
        externalUrl: json["external_url"],
        classDetail: json["class_detail"],
        courseId: json["course_id"],
        title: json["title"],
        courseTime: json["course_time"].toString(),
        courseOn:
            json["course_on"] != null ? List<String>.from(json["course_on"].map((x) => x)) : [],
        courseType: json["course_type"],
        provider: json["provider"],
        consultantId: json["consultant_id"],
        consultantName: json["consultant_name"],
        consultantGender: json["consultant_gender"] ?? "",
        courseFees: json["course_fees"],
        feesFor: json["fees_for"]=="1 Days"?"1 Day":json["fees_for"],
        subscriberCount: json["subscriber_count"],
        courseDuration: json["course_duration"],
        subscriptionId: json["subscription_id"],
        approvalStatus: json["approval_status"],
        course_description: json["course_description"],
        course_frequency: json["course_frequency"],
        current_available: currtentDayorNot(
            freq: json["course_frequency"],
            days: json["course_on"] != null
                ? List<String>.from(json["course_on"].map((x) => x))
                : []),
      );

  Map<String, dynamic> toJson() => {
        "class_detail": classDetail,
        "course_id": courseId,
        "title": title,
        "course_time": courseTime,
        "course_on": List<dynamic>.from(courseOn.map((x) => x)),
        "course_type": courseType,
        "provider": provider,
        "consultant_id": consultantId,
        "consultant_name": consultantName,
        "consultant_gender": consultantGender,
        "course_fees": courseFees,
        "fees_for": feesFor,
        "subscriber_count": subscriberCount,
        "course_duration": courseDuration,
        "subscription_id": subscriptionId,
        "approval_status": approvalStatus,
        "course_frequency": course_frequency,
        "course_description": course_description,
      };
}

String currtentDayorNot({String freq, List days}) {
  String currentDay = DateFormat('EEEE').format(DateTime.now());
  if (freq != null) {
    if (days.contains(currentDay) || freq.toLowerCase() == "daily") {
      return "Today";
    } else {
      return "Timing";
    }
  } else {
    return "Timing";
  }
}
