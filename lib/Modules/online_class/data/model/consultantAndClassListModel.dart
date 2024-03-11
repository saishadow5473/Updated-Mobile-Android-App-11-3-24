import 'dart:convert';
import 'dart:developer';

class ClassAndConsultantListModel {
  ClassAndConsultantListModel({
    this.consultantAndClassTotalCount,
    this.consultantAndClassList,
  });

  final int consultantAndClassTotalCount;
  List<ConsultantAndClassList> consultantAndClassList;

  factory ClassAndConsultantListModel.fromJson(Map<String, dynamic> json) {
    return ClassAndConsultantListModel(
      consultantAndClassTotalCount: json["consultant_and_class_total_count"],
      consultantAndClassList: json["consultant_and_class_list"] == null
          ? []
          : List<ConsultantAndClassList>.from(json["consultant_and_class_list"]
              .map((var x) => ConsultantAndClassList.fromJson(x))) as List<dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
        "consultant_and_class_total_count": consultantAndClassTotalCount,
        "consultant_and_class_list":
            consultantAndClassList.map((ConsultantAndClassList x) => x.toJson()).toList(),
      };
}

class ConsultantAndClassList {
  ConsultantAndClassList({
    this.type,
    this.consultantDetail,
    this.classDetail,
  });

  final String type;
  final ConsultantDetail consultantDetail;
  final ClassDetail classDetail;

  factory ConsultantAndClassList.fromJson(Map<String, dynamic> json) {
    return ConsultantAndClassList(
      type: json["type"],
      consultantDetail: json["consultant_detail"] == null
          ? null
          : ConsultantDetail.fromJson(json["consultant_detail"]),
      classDetail: json["class_detail"] == null ? null : ClassDetail.fromJson(json["class_detail"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "type": type,
        "consultant_detail": consultantDetail.toJson(),
        "class_detail": classDetail.toJson(),
      };
}

class ClassDetail {
  ClassDetail({
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
    this.externalUrl,
  });

  final String courseImgUrl;
  final String speciality;
  final String courseId;
  final String title;
  final List<String> courseTime;
  final List<String> courseOn;
  final String courseType;
  final String courseDescription;
  final String provider;
  final String consultantId;
  final String consultantName;
  final String consultantGender;
  final int courseFees;
  final int courseFeesMrp;
  final AffilationExcusiveData affilationExcusiveData;
  final String feesFor;
  final int subscriberCount;
  final bool exclusiveOnly;
  final int subscriptionImageUrl;
  final String availableSlotCount;
  final List<dynamic> availableSlot;
  final String courseDuration;
  final String courseStatus;
  final String ratings;
  final List<dynamic> textReviewsData;
  final bool autoApprove;
  final String createdByUserName;
  final String creatorEmail;
  final String creatorMobileNumber;
  final int startIndex;
  final int endIndex;
  final String category;
  final String externalUrl;

  factory ClassDetail.fromJson(Map<String, dynamic> json) {
    return ClassDetail(
      courseImgUrl: json["course_img_url"],
      speciality: json["speciality"],
      courseId: json["course_id"],
      title: json["title"],
      courseTime:
          json["course_time"] == null ? [] : List<String>.from(json["course_time"].map((x) => x)),
      courseOn: json["course_on"] == null ? [] : List<String>.from(json["course_on"].map((x) => x)),
      courseType: json["course_type"],
      courseDescription: json["course_description"],
      provider: json["provider"],
      consultantId: json["consultant_id"],
      consultantName: json["consultant_name"],
      consultantGender: json["consultant_gender"],
      courseFees: json["course_fees"],
      courseFeesMrp: json["course_fees_mrp"],
      affilationExcusiveData: json["affilation_excusive_data"] == null
          ? null
          : AffilationExcusiveData.fromJson(json["affilation_excusive_data"]),
      feesFor: json["fees_for"]=="1 Days"?"1 Day":json["fees_for"],
      subscriberCount: json["subscriber_count"],
      exclusiveOnly: json["exclusive_only"],
      subscriptionImageUrl: json["subscription_image_url"],
      availableSlotCount: json["available_slot_count"],
      availableSlot: json["available_slot"] == null
          ? []
          : List<dynamic>.from(json["available_slot"].map((x) => x)),
      courseDuration: json["course_duration"],
      courseStatus: json["course_status"],
      ratings: json["ratings"],
      textReviewsData: json["text_reviews_data"] == null
          ? []
          : List<dynamic>.from(json["text_reviews_data"].map((x) => x)),
      autoApprove: json["auto_approve"],
      createdByUserName: json["created_by_user_name"],
      creatorEmail: json["creator_email"],
      creatorMobileNumber: json["creator_mobile_number"],
      startIndex: json["start_index"],
      endIndex: json["end_index"],
      category: json["category"],
      externalUrl: json["external_url"],
    );
  }

  Map<String, dynamic> toJson() => {
        "course_img_url": courseImgUrl,
        "speciality": speciality,
        "course_id": courseId,
        "title": title,
        "course_time": courseTime.map((String x) => x).toList(),
        "course_on": courseOn.map((String x) => x).toList(),
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
        "available_slot": availableSlot.map((x) => x).toList(),
        "course_duration": courseDuration,
        "course_status": courseStatus,
        "ratings": ratings,
        "text_reviews_data": textReviewsData.map((x) => x).toList(),
        "auto_approve": autoApprove,
        "created_by_user_name": createdByUserName,
        "creator_email": creatorEmail,
        "creator_mobile_number": creatorMobileNumber,
        "start_index": startIndex,
        "end_index": endIndex,
        "category": category,
        "external_url": externalUrl,
      };
}

class AffilationExcusiveData {
  AffilationExcusiveData({
    this.affilationArray,
  });

  final List<AffilationArray> affilationArray;

  factory AffilationExcusiveData.fromJson(Map<String, dynamic> json) {
    return AffilationExcusiveData(
      affilationArray: json["affilation_array"] == null
          ? []
          : List<AffilationArray>.from(
              json["affilation_array"].map((x) => AffilationArray.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "affilation_array": affilationArray.map((AffilationArray x) => x.toJson()).toList(),
      };
}

class ConsultantDetail {
  AffilationExcusiveData affilationExcusiveData;
  bool exclusiveOnly;
  String rmpId;
  String vendorId;
  String ihlConsultantId;
  String vendorConsultantId;
  String name;
  String email;
  String contactNumber;
  int age;
  List<String> languagesSpoken;
  List<String> consultantSpeciality;
  String description;
  String gender;
  String suffix;
  String qualification;
  String experience;
  String ratings;
  String consultationFees;
  bool liveCallAllowed;
  String currentLiveStatus;
  List<dynamic> textReviewsData;
  String accountId;
  String accountName;
  String accountStatus;
  String consultantAddress;
  String userName;
  String category;

  ConsultantDetail({
    this.affilationExcusiveData,
    this.exclusiveOnly,
    this.rmpId,
    this.vendorId,
    this.ihlConsultantId,
    this.vendorConsultantId,
    this.name,
    this.email,
    this.contactNumber,
    this.age,
    this.languagesSpoken,
    this.consultantSpeciality,
    this.description,
    this.gender,
    this.suffix,
    this.qualification,
    this.experience,
    this.ratings,
    this.consultationFees,
    this.liveCallAllowed,
    this.currentLiveStatus,
    this.textReviewsData,
    this.accountId,
    this.accountName,
    this.accountStatus,
    this.consultantAddress,
    this.userName,
    this.category,
  });

  factory ConsultantDetail.fromJson(Map<String, dynamic> json) => ConsultantDetail(
        affilationExcusiveData: AffilationExcusiveData.fromJson(json["affilation_excusive_data"]),
        exclusiveOnly: json["exclusive_only"],
        rmpId: json["RMP_ID"],
        vendorId: json["vendor_id"],
        ihlConsultantId: json["ihl_consultant_id"],
        vendorConsultantId: json["vendor_consultant_id"],
        name: json["name"],
        email: json["email"],
        contactNumber: json["contact_number"],
        age: json["age"],
        languagesSpoken: List<String>.from(json["languages_Spoken"].map((x) => x)),
        consultantSpeciality: List<String>.from(json["consultant_speciality"].map((x) => x)),
        description: json["description"],
        gender: json["gender"],
        suffix: json["suffix"],
        qualification: json["qualification"],
        experience: json["experience"],
        ratings: json["ratings"],
        consultationFees: json["consultation_fees"],
        liveCallAllowed: json["live_call_allowed"],
        currentLiveStatus: json["current_live_status"],
        textReviewsData: List<dynamic>.from(json["text_reviews_data"].map((x) => x)),
        accountId: json["account_id"],
        accountName: json["account_name"],
        accountStatus: json["account_status"],
        consultantAddress: json["consultant_address"],
        userName: json["user_name"],
        category: json["category"],
      );

  Map<String, dynamic> toJson() => {
        "affilation_excusive_data": affilationExcusiveData.toJson(),
        "exclusive_only": exclusiveOnly,
        "RMP_ID": rmpId,
        "vendor_id": vendorId,
        "ihl_consultant_id": ihlConsultantId,
        "vendor_consultant_id": vendorConsultantId,
        "name": name,
        "email": email,
        "contact_number": contactNumber,
        "age": age,
        "languages_Spoken": List<dynamic>.from(languagesSpoken.map((x) => x)),
        "consultant_speciality": List<dynamic>.from(consultantSpeciality.map((x) => x)),
        "description": description,
        "gender": gender,
        "suffix": suffix,
        "qualification": qualification,
        "experience": experience,
        "ratings": ratings,
        "consultation_fees": consultationFees,
        "live_call_allowed": liveCallAllowed,
        "current_live_status": currentLiveStatus,
        "text_reviews_data": List<dynamic>.from(textReviewsData.map((x) => x)),
        "account_id": accountId,
        "account_name": accountName,
        "account_status": accountStatus,
        "consultant_address": consultantAddress,
        "user_name": userName,
        "category": category,
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
