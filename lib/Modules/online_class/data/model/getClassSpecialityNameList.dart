// To parse this JSON data, do
//
//     final specialityListModel = specialityListModelFromJson(jsonString);

import 'dart:convert';

SpecialityListModel specialityListModelFromJson(String str) =>
    SpecialityListModel.fromJson(json.decode(str));

String specialityListModelToJson(SpecialityListModel data) => json.encode(data.toJson());

class SpecialityListModel {
  int totalCount;
  List<SpecialityTypeList> specialityList;

  SpecialityListModel({
    this.totalCount,
    this.specialityList,
  });

  factory SpecialityListModel.fromJson(Map<String, dynamic> json) => SpecialityListModel(
        totalCount: json["total_count"],
        specialityList: List<SpecialityTypeList>.from(
            json["specialityList"].map((x) => SpecialityTypeList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total_count": totalCount,
        "specialityList": List<dynamic>.from(specialityList.map((x) => x.toJson())),
      };
}

class SpecialityTypeList {
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
  String createdByUserName;
  String creatorEmail;
  String creatorMobileNumber;
  int startIndex;
  int endIndex;
  String category;

  SpecialityTypeList({
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
    this.createdByUserName,
    this.creatorEmail,
    this.creatorMobileNumber,
    this.startIndex,
    this.endIndex,
    this.category,
  });

  factory SpecialityTypeList.fromJson(Map<String, dynamic> json) => SpecialityTypeList(
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
        ratings: json["ratings"],
        textReviewsData: List<dynamic>.from(json["text_reviews_data"].map((x) => x)),
        autoApprove: json["auto_approve"],
        createdByUserName: json["created_by_user_name"],
        creatorEmail: json["creator_email"],
        creatorMobileNumber: json["creator_mobile_number"],
        startIndex: json["start_index"],
        endIndex: json["end_index"],
        category: json["category"],
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
        "created_by_user_name": createdByUserName,
        "creator_email": creatorEmail,
        "creator_mobile_number": creatorMobileNumber,
        "start_index": startIndex,
        "end_index": endIndex,
        "category": category,
      };
}

class AffilationExcusiveData {
  List<AffilationArray> affilationArray;

  AffilationExcusiveData({
    this.affilationArray,
  });

  factory AffilationExcusiveData.fromJson(Map<String, dynamic> json) => AffilationExcusiveData(
        affilationArray: List<AffilationArray>.from(
            json["affilation_array"].map((x) => AffilationArray.fromJson(x))),
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
        "affilation_unique_name": affilationUniqueName,
        "affilation_name": affilationName,
        "affilation_mrp": affilationMrp,
        "affilation_price": affilationPrice,
      };
}
