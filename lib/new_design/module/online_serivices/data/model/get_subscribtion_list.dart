// To parse this JSON data, do
//
//     final getSubscriptionList = getSubscriptionListFromJson(jsonString);

import 'dart:convert';

GetSubscriptionList getSubscriptionListFromJson(String str) =>
    GetSubscriptionList.fromJson(json.decode(str));

String getSubscriptionListToJson(GetSubscriptionList data) => json.encode(data.toJson());

class GetSubscriptionList {
  int totalCount;
  List<Subscription> subscriptions;

  GetSubscriptionList({
    this.totalCount,
    this.subscriptions,
  });

  factory GetSubscriptionList.fromJson(Map<String, dynamic> json) {
    return GetSubscriptionList(
      totalCount: json["total_count"],
      subscriptions:
      List<Subscription>.from(json["subscriptions"].map((x) => Subscription.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "total_count": totalCount,
        "subscriptions": List<dynamic>.from(subscriptions.map((x) => x.toJson())),
      };
}

class Subscription {
  ClassDetail classDetail;
  String courseId;
  String title;
  String courseTime;
  List<String> courseOn;
  String courseType;
  String provider;
  String consultantId;
  String consultantName;
  ConsultantGender consultantGender;
  int courseFees;
  String feesFor;
  int subscriberCount;
  String courseDuration;
  String subscriptionId;
  ApprovalStatus approvalStatus;
  String externalUrl;

  Subscription({
    this.classDetail,
    this.courseId,
    this.title,
    this.courseTime,
    this.courseOn,
    this.courseType,
    this.provider,
    this.consultantId,
    this.consultantName,
    this.consultantGender,
    this.courseFees,
    this.feesFor,
    this.subscriberCount,
    this.courseDuration,
    this.subscriptionId,
    this.approvalStatus,
    this.externalUrl,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        classDetail: classDetailValues.map[json["class_detail"]],
        courseId: json["course_id"],
        title: json["title"]??" ",
        courseTime: json["course_time"].toString(),
        courseOn: json["course_on"]!=null?List<String>.from(json["course_on"].map((x) => x)):[""],
        courseType: json["course_type"],
        provider: json["provider"],
        consultantId: json["consultant_id"]??" ",
        consultantName: json["consultant_name"]??" ",
        consultantGender: consultantGenderValues.map[json["consultant_gender"]??" "],
        courseFees: json["course_fees"]??0,
        feesFor: json["fees_for"]=="1 Days"?"1 Day":json["fees_for"],
        subscriberCount: json["subscriber_count"]??0,
        courseDuration: json["course_duration"]??" ",
        subscriptionId: json["subscription_id"],
        approvalStatus: approvalStatusValues.map[json["approval_status"]],
        externalUrl: json["external_url"],
      );

  Map<String, dynamic> toJson() => {
        "class_detail": classDetailValues.reverse[classDetail],
        "course_id": courseId,
        "title": title,
        "course_time": courseTime,
        "course_on": List<dynamic>.from(courseOn.map((x) => x)),
        "course_type": courseType,
        "provider": provider,
        "consultant_id": consultantId,
        "consultant_name": consultantName,
        "consultant_gender": consultantGenderValues.reverse[consultantGender],
        "course_fees": courseFees,
        "fees_for": feesFor,
        "subscriber_count": subscriberCount,
        "course_duration": courseDuration,
        "subscription_id": subscriptionId,
        "approval_status": approvalStatusValues.reverse[approvalStatus],
        "external_url": externalUrl,
      };
}

enum ApprovalStatus { ACCEPTED }

final approvalStatusValues = EnumValues({"Accepted": ApprovalStatus.ACCEPTED});

enum ClassDetail { AVAILABLE, NOT_AVAILABLE }

final classDetailValues =
    EnumValues({"available": ClassDetail.AVAILABLE, "not available": ClassDetail.NOT_AVAILABLE});

enum ConsultantGender { F, FEMALE, M, MALE, NULL }

final consultantGenderValues = EnumValues({
  "F": ConsultantGender.F,
  "Female": ConsultantGender.FEMALE,
  "M": ConsultantGender.M,
  "Male": ConsultantGender.MALE,
  "null": ConsultantGender.NULL
});

enum Provider { DEVTESTING, DEV_TESTING, INDIAHEALTHLINK, INDIAHEALTHLINKTRAINING, Janhavidr }

final providerValues = EnumValues({
  "Devtesting": Provider.DEVTESTING,
  "Dev Testing": Provider.DEV_TESTING,
  "INDIAHEALTHLINK": Provider.INDIAHEALTHLINK,
  "INDIAHEALTHLINKTRAINING": Provider.INDIAHEALTHLINKTRAINING,
  "Janhavidr": Provider.Janhavidr
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
