// To parse this JSON data, do
//
//     final getSpecClassList = getSpecClassListFromJson(jsonString);

import 'dart:convert';

GetSpecClassList getSpecClassListFromJson(String str) =>
    GetSpecClassList.fromJson(json.decode(str));

String getSpecClassListToJson(GetSpecClassList data) => json.encode(data.toJson());

class GetSpecClassList {
  int totalCount;
  List<SpecialityClassList> specialityClassList;

  GetSpecClassList({
    this.totalCount,
    this.specialityClassList,
  });

  factory GetSpecClassList.fromJson(Map<String, dynamic> json) => GetSpecClassList(
        totalCount: json["total_count"],
        specialityClassList: List<SpecialityClassList>.from(
            json["specialityList"].map((x) => SpecialityClassList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total_count": totalCount,
        "specialityList": List<dynamic>.from(specialityClassList.map((x) => x.toJson())),
      };
}

class SpecialityClassList {
  String courseImgUrl;
  String speciality;
  String courseId;
  String title;
  List<String> courseTime;
  List<String> courseOn;
  String courseType;
  String courseDescription;
  String provider;
  String consultantId;
  String consultantName;
  String consultantGender;
  int courseFees;
  int courseFeesMrp;
  AffilationExcusiveData affilationExcusiveData;
  String feesFor;
  int subscriberCount;
  bool exclusiveOnly;
  int subscriptionImageUrl;
  String availableSlotCount;
  List<dynamic> availableSlot;
  String courseDuration;
  String courseStatus;
  String ratings;
  List<dynamic> textReviewsData;
  bool autoApprove;
  int startIndex;
  int endIndex;
  String createdByUserName;
  String creatorEmail;
  String creatorMobileNumber;

  SpecialityClassList({
    this.courseImgUrl,
    this.speciality,
    this.courseId,
    this.title,
    this.courseTime,
    this.courseOn,
    this.courseType,
    this.courseDescription,
    this.provider,
    this.consultantId,
    this.consultantName,
    this.consultantGender,
    this.courseFees,
    this.courseFeesMrp,
    this.affilationExcusiveData,
    this.feesFor,
    this.subscriberCount,
    this.exclusiveOnly,
    this.subscriptionImageUrl,
    this.availableSlotCount,
    this.availableSlot,
    this.courseDuration,
    this.courseStatus,
    this.ratings,
    this.textReviewsData,
    this.autoApprove,
    this.startIndex,
    this.endIndex,
    this.createdByUserName,
    this.creatorEmail,
    this.creatorMobileNumber,
  });

  factory SpecialityClassList.fromJson(Map<String, dynamic> json) => SpecialityClassList(
        courseImgUrl: json["course_img_url"],
        speciality: json["speciality"],
        courseId: json["course_id"],
        title: json["title"],
        courseTime: List<String>.from(json["course_time"].map((x) => x)),
        courseOn: List<String>.from(json["course_on"].map((x) => x)),
        courseType: json["course_type"],
        courseDescription: json["course_description"],
        provider: json["provider"],
        consultantId: json["consultant_id"],
        consultantName: json["consultant_name"],
        consultantGender: json["consultant_gender"],
        courseFees: json["course_fees"],
        courseFeesMrp: json["course_fees_mrp"],
        affilationExcusiveData: AffilationExcusiveData.fromJson(json["affilation_excusive_data"]),
        feesFor: json["fees_for"]=="1 Days"?"1 Day":json["fees_for"],
        subscriberCount: json["subscriber_count"],
        exclusiveOnly: json["exclusive_only"],
        subscriptionImageUrl: json["subscription_image_url"],
        availableSlotCount: json["available_slot_count"],
        availableSlot: List<dynamic>.from(json["available_slot"].map((x) => x)),
        courseDuration: json["course_duration"],
        courseStatus: json["course_status"],
        ratings: json["ratings"].toString(),
        textReviewsData: List<dynamic>.from(json["text_reviews_data"].map((x) => x)),
        autoApprove: json["auto_approve"],
        startIndex: json["start_index"],
        endIndex: json["end_index"],
        createdByUserName: json["created_by_user_name"],
        creatorEmail: json["creator_email"],
        creatorMobileNumber: json["creator_mobile_number"],
      );

  Map<String, dynamic> toJson() => {
        "course_img_url": courseImgUrl,
        "speciality": speciality,
        "course_id": courseId,
        "title": title,
        "course_time": List<dynamic>.from(courseTime.map((x) => x)),
        "course_on": List<dynamic>.from(courseOn.map((x) => x)),
        "course_type": courseType,
        "course_description": courseDescription,
        "provider": provider,
        "consultant_id": consultantId,
        "consultant_name": consultantName,
        "consultant_gender": consultantGender,
        "course_fees": courseFees,
        "course_fees_mrp": courseFeesMrp,
        "affilation_excusive_data": affilationExcusiveData.toJson(),
        "fees_for": feesFor,
        "subscriber_count": subscriberCount,
        "exclusive_only": exclusiveOnly,
        "subscription_image_url": subscriptionImageUrl,
        "available_slot_count": availableSlotCount,
        "available_slot": List<dynamic>.from(availableSlot.map((x) => x)),
        "course_duration": courseDuration,
        "course_status": courseStatus,
        "ratings": ratings,
        "text_reviews_data": List<dynamic>.from(textReviewsData.map((x) => x)),
        "auto_approve": autoApprove,
        "start_index": startIndex,
        "end_index": endIndex,
        "created_by_user_name": createdByUserName,
        "creator_email": creatorEmail,
        "creator_mobile_number": creatorMobileNumber,
      };
}

class AffilationExcusiveData {
  List<AffilationArray> affilationArray;

  AffilationExcusiveData({
    this.affilationArray,
  });

  factory AffilationExcusiveData.fromJson(Map<String, dynamic> json) => AffilationExcusiveData(
        affilationArray: json["affilation_array"] != null
            ? List<AffilationArray>.from(
                json["affilation_array"].map((x) => AffilationArray.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "affilation_array": List<dynamic>.from(affilationArray.map((x) => x.toJson())),
      };
}

class AffilationArray {
  String affilationUniqueName;
  String affilationName;
  String affilationMrp;
  String affilationPrice;

  AffilationArray({
    this.affilationUniqueName,
    this.affilationName,
    this.affilationMrp,
    this.affilationPrice,
  });

  factory AffilationArray.fromJson(Map<String, dynamic> json) => AffilationArray(
        affilationUniqueName: json["affilation_unique_name"],
        affilationName: json["affilation_name"],
        affilationMrp: json["affilation_mrp"],
        affilationPrice: json["affilation_price"],
      );

  Map<String, dynamic> toJson() => {
        "affilation_unique_name": affilationUniqueNameValues.reverse[affilationUniqueName],
        "affilation_name": affilationNameValues.reverse[affilationName],
        "affilation_mrp": affilationMrp,
        "affilation_price": affilationPrice,
      };
}

enum AffilationName { DEV_TESTING, IHL_CARE }

final affilationNameValues =
    EnumValues({"Dev Testing": AffilationName.DEV_TESTING, "IHL Care": AffilationName.IHL_CARE});

enum AffilationUniqueName { DEV_TESTING, IHL_CARE }

final affilationUniqueNameValues = EnumValues(
    {"dev_testing": AffilationUniqueName.DEV_TESTING, "ihl_care": AffilationUniqueName.IHL_CARE});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
