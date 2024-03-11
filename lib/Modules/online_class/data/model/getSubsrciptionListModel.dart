// To parse this JSON data, do
//
//     final getSubsrciptionList = getSubsrciptionListFromJson(jsonString);

import 'dart:convert';

GetSubsrciptionList getSubsrciptionListFromJson(String str) => GetSubsrciptionList.fromJson(json.decode(str));

String getSubsrciptionListToJson(GetSubsrciptionList data) => json.encode(data.toJson());

class GetSubsrciptionList {
  int totalCount;
  List<Subscription> subscriptions;

  GetSubsrciptionList({
     this.totalCount,
     this.subscriptions,
  });

  factory GetSubsrciptionList.fromJson(Map<String, dynamic> json) => GetSubsrciptionList(
    totalCount: json["total_count"],
    subscriptions: List<Subscription>.from(json["subscriptions"].map((x) => Subscription.fromJson(x))),
  );

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
  Provider provider;
  String consultantId;
  String consultantName;
  String consultantGender;
  int courseFees;
  String feesFor;
  int subscriberCount;
  String courseDuration;
  String subscriptionId;
  ApprovalStatus approvalStatus;

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
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    classDetail: classDetailValues.map[json["class_detail"]],
    courseId: json["course_id"],
    title: json["title"],
    courseTime: json["course_time"],
    courseOn: List<String>.from(json["course_on"].map((x) => x)),
    courseType: json["course_type"],
    provider: providerValues.map[json["provider"]],
    consultantId: json["consultant_id"],
    consultantName: json["consultant_name"],
    consultantGender: json["consultant_gender"],
    courseFees: json["course_fees"],
    feesFor: json["fees_for"]=="1 Days"?"1 Day":json["fees_for"],
    subscriberCount: json["subscriber_count"],
    courseDuration: json["course_duration"],
    subscriptionId: json["subscription_id"],
    approvalStatus: approvalStatusValues.map[json["approval_status"]],
  );

  Map<String, dynamic> toJson() => {
    "class_detail": classDetailValues.reverse[classDetail],
    "course_id": courseId,
    "title": title,
    "course_time": courseTime,
    "course_on": List<dynamic>.from(courseOn.map((x) => x)),
    "course_type": courseType,
    "provider": providerValues.reverse[provider],
    "consultant_id": consultantId,
    "consultant_name": consultantName,
    "consultant_gender": consultantGender,
    "course_fees": courseFees,
    "fees_for": feesFor,
    "subscriber_count": subscriberCount,
    "course_duration": courseDuration,
    "subscription_id": subscriptionId,
    "approval_status": approvalStatusValues.reverse[approvalStatus],
  };
}

enum ApprovalStatus {
  ACCEPTED
}

final approvalStatusValues = EnumValues({
  "Accepted": ApprovalStatus.ACCEPTED
});

enum ClassDetail {
  AVAILABLE
}

final classDetailValues = EnumValues({
  "available": ClassDetail.AVAILABLE
});

enum Provider {
  IHL,
  INDIAHEALTHLINK,
  JANHAVIDR
}

final providerValues = EnumValues({
  "ihl": Provider.IHL,
  "INDIAHEALTHLINK": Provider.INDIAHEALTHLINK,
  "Janhavidr": Provider.JANHAVIDR
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
