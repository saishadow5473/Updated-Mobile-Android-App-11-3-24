// To parse this JSON data, do
//
//     final getCourseDetail = getCourseDetailFromJson(jsonString);

import 'dart:convert';

GetCourseDetail getCourseDetailFromJson(String str) => GetCourseDetail.fromJson(json.decode(str));

String getCourseDetailToJson(GetCourseDetail data) => json.encode(data.toJson());

class GetCourseDetail {
  String speciality;
  String courseId;
  String title;
  List<String> courseTime;
  List<dynamic> courseOn;
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
  dynamic externalUrl;
  int ratings;
  List<dynamic> textReviewsData;
  bool autoApprove;

  GetCourseDetail({
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
    this.externalUrl,
    this.ratings,
    this.textReviewsData,
    this.autoApprove,
  });

  factory GetCourseDetail.fromJson(Map<String, dynamic> json) => GetCourseDetail(
    speciality: json["speciality"],
    courseId: json["course_id"],
    title: json["title"],
    courseTime: List<String>.from(json["course_time"].map((x) => x)),
    courseOn: List<dynamic>.from(json["course_on"].map((x) => x)),
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
    externalUrl: json["external_url"],
    ratings: json["ratings"],
    textReviewsData: List<dynamic>.from(json["text_reviews_data"].map((x) => x)),
    autoApprove: json["auto_approve"],
  );

  Map<String, dynamic> toJson() => {
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
    "external_url": externalUrl,
    "ratings": ratings,
    "text_reviews_data": List<dynamic>.from(textReviewsData.map((x) => x)),
    "auto_approve": autoApprove,
  };
}

class AffilationExcusiveData {
  List<AffilationArray> affilationArray;

  AffilationExcusiveData({
    this.affilationArray,
  });

  factory AffilationExcusiveData.fromJson(Map<String, dynamic> json) => AffilationExcusiveData(
    affilationArray: List<AffilationArray>.from(json["affilation_array"].map((x) => AffilationArray.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "affilation_array": List<dynamic>.from(affilationArray.map((x) => x.toJson())),
  };
}

class AffilationArray {
  String affilationUniqueName;
  String affilationName;
  String affilationMrp;
  dynamic affilationGst;
  String affilationPrice;

  AffilationArray({
    this.affilationUniqueName,
    this.affilationName,
    this.affilationMrp,
    this.affilationGst,
    this.affilationPrice,
  });

  factory AffilationArray.fromJson(Map<String, dynamic> json) => AffilationArray(
    affilationUniqueName: json["affilation_unique_name"],
    affilationName: json["affilation_name"],
    affilationMrp: json["affilation_mrp"],
    affilationGst: json["affilation_gst"],
    affilationPrice: json["affilation_price"],
  );

  Map<String, dynamic> toJson() => {
    "affilation_unique_name": affilationUniqueName,
    "affilation_name": affilationName,
    "affilation_mrp": affilationMrp,
    "affilation_gst": affilationGst,
    "affilation_price": affilationPrice,
  };
}
