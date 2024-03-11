// To parse this JSON data, do
//
//     final getEnrolmentChallengeList = getEnrolmentChallengeListFromJson(jsonString);

import 'dart:convert';

GetEnrolmentChallengeList getEnrolmentChallengeListFromJson(String str) => GetEnrolmentChallengeList.fromJson(json.decode(str));

String getEnrolmentChallengeListToJson(GetEnrolmentChallengeList data) => json.encode(data.toJson());

class GetEnrolmentChallengeList {
  List<NotStarted> notStarted;
  List<Started> started;
  List<Completed> completed;

  GetEnrolmentChallengeList({
     this.notStarted,
     this.started,
     this.completed,
  });

  factory GetEnrolmentChallengeList.fromJson(Map<String, dynamic> json) => GetEnrolmentChallengeList(
    notStarted: List<NotStarted>.from(json["not_started"].map((x) => NotStarted.fromJson(x))),
    started: List<Started>.from(json["started"].map((x) => Started.fromJson(x))),
    completed: List<Completed>.from(json["completed"].map((x) => Completed.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "not_started": List<dynamic>.from(notStarted.map((x) => x.toJson())),
    "started": List<dynamic>.from(started.map((x) => x)),
    "completed": List<dynamic>.from(completed.map((x) => x.toJson())),
  };
}

class Completed {
  String userStatus;
  String name;
  String city;
  String department;
  String designation;
  String gender;
  String enrollmentId;
  String userBibNo;
  String challengeId;
  String challengeName;
  String imgUrl;
  String thumbnailUrl;
  String challengeBannerImgUrl;
  String challengeMode;
  String challengeType;
  String target;
  String userDuration;
  String userAchieved;
  String userProgress;
  String challengeUnit;
  String challengeRunType;
  String lastUpdated;
  String challengeStartTime;
  String challengeEndTime;
  String userStartTime;
  String userEndTime;
  String speed;
  bool isVarient;
  bool bannerVisibleInMainDashboard;
  bool bannerVisibleInSocialDashboard;
  String milestoneTotalTarget;
  String perDayTarget;
  bool selfieOptionSettings;
  String challengeCategory;
  String assosideId;
  String groupId;
  String groupAchieved;
  String groupDuration;
  String groupProgress;
  String selectedFitnessApp;

  Completed({
     this.userStatus,
     this.name,
     this.city,
     this.department,
     this.designation,
     this.gender,
     this.enrollmentId,
     this.userBibNo,
     this.challengeId,
     this.challengeName,
     this.imgUrl,
     this.thumbnailUrl,
     this.challengeBannerImgUrl,
     this.challengeMode,
     this.challengeType,
     this.target,
     this.userDuration,
    this.userAchieved,
     this.userProgress,
     this.challengeUnit,
     this.challengeRunType,
     this.lastUpdated,
     this.challengeStartTime,
     this.challengeEndTime,
     this.userStartTime,
     this.userEndTime,
     this.speed,
    this.isVarient,
    this.bannerVisibleInMainDashboard,
    this.bannerVisibleInSocialDashboard,
    this.milestoneTotalTarget,
    this.perDayTarget,
    this.selfieOptionSettings,
    this.challengeCategory,
    this.assosideId,
    this.groupId,
    this.groupAchieved,
    this.groupDuration,
    this.groupProgress,
    this.selectedFitnessApp,
  });

  factory Completed.fromJson(Map<String, dynamic> json) => Completed(
    userStatus: json["user_status"],
    name: json["name"],
    city: json["city"],
    department: json["department"],
    designation: json["designation"],
    gender: json["gender"],
    enrollmentId: json["enrollment_id"],
    userBibNo: json["user_bib_no"],
    challengeId: json["challenge_id"],
    challengeName: json["challenge_name"],
    imgUrl: json["img_url"],
    thumbnailUrl: json["thumbnail_url"],
    challengeBannerImgUrl: json["challenge_Banner_img_url"],
    challengeMode: json["challenge_mode"],
    challengeType: json["challenge_type"],
    target: json["target"],
    userDuration: json["user_duration"],
    userAchieved: json["user_achieved"],
    userProgress: json["user_progress"],
    challengeUnit: json["challenge_unit"],
    challengeRunType: json["challenge_run_type"],
    lastUpdated: json["last_updated"],
    challengeStartTime: json["challenge_start_time"],
    challengeEndTime: json["challenge_end_time"],
    userStartTime: json["user_start_time"],
    userEndTime: json["user_end_time"],
    speed: json["speed"],
    isVarient: json["is_varient"],
    bannerVisibleInMainDashboard: json["banner_visible_in_main_dashboard"],
    bannerVisibleInSocialDashboard: json["banner_visible_in_social_dashboard"],
    milestoneTotalTarget: json["milestone_total_target"],
    perDayTarget: json["per_day_target"],
    selfieOptionSettings: json["selfie_option_settings"],
    challengeCategory: json["challenge_category"],
    assosideId: json["assoside_id"],
    groupId: json["group_id"],
    groupAchieved: json["group_achieved"],
    groupDuration: json["group_duration"],
    groupProgress: json["group_progress"],
    selectedFitnessApp: json["selected_fitness_app"],
  );

  Map<String, dynamic> toJson() => {
    "user_status": userStatus,
    "name": name,
    "city": city,
    "department": department,
    "designation": designation,
    "gender": gender,
    "enrollment_id": enrollmentId,
    "user_bib_no": userBibNo,
    "challenge_id": challengeId,
    "challenge_name": challengeName,
    "img_url": imgUrl,
    "thumbnail_url": thumbnailUrl,
    "challenge_Banner_img_url": challengeBannerImgUrl,
    "challenge_mode": challengeMode,
    "challenge_type": challengeType,
    "target": target,
    "user_duration": userDuration,
    "user_achieved": userAchieved,
    "user_progress": userProgress,
    "challenge_unit": challengeUnit,
    "challenge_run_type": challengeRunType,
    "last_updated": lastUpdated,
    "challenge_start_time": challengeStartTime,
    "challenge_end_time": challengeEndTime,
    "user_start_time": userStartTime,
    "user_end_time": userEndTime,
    "speed": speed,
    "is_varient": isVarient,
    "banner_visible_in_main_dashboard": bannerVisibleInMainDashboard,
    "banner_visible_in_social_dashboard": bannerVisibleInSocialDashboard,
    "milestone_total_target": milestoneTotalTarget,
    "per_day_target": perDayTarget,
    "selfie_option_settings": selfieOptionSettings,
    "challenge_category": challengeCategory,
    "assoside_id": assosideId,
    "group_id": groupId,
    "group_achieved": groupAchieved,
    "group_duration": groupDuration,
    "group_progress": groupProgress,
    "selected_fitness_app": selectedFitnessApp,
  };
}
class Started {
  String userStatus;
  String name;
  String city;
  String department;
  String designation;
  String gender;
  String enrollmentId;
  String userBibNo;
  String challengeId;
  String challengeName;
  String imgUrl;
  String thumbnailUrl;
  String challengeBannerImgUrl;
  String challengeMode;
  String challengeType;
  String target;
  String userDuration;
  String userAchieved;
  String userProgress;
  String challengeUnit;
  String challengeRunType;
  String lastUpdated;
  String challengeStartTime;
  String challengeEndTime;
  String userStartTime;
  String userEndTime;
  String speed;
  bool isVarient;
  bool bannerVisibleInMainDashboard;
  bool bannerVisibleInSocialDashboard;
  String milestoneTotalTarget;
  String perDayTarget;
  bool selfieOptionSettings;
  String challengeCategory;
  String assosideId;
  String groupId;
  String groupAchieved;
  String groupDuration;
  String groupProgress;
  String selectedFitnessApp;

  Started({
     this.userStatus,
     this.name,
     this.city,
     this.department,
     this.designation,
     this.gender,
     this.enrollmentId,
     this.userBibNo,
     this.challengeId,
     this.challengeName,
     this.imgUrl,
     this.thumbnailUrl,
     this.challengeBannerImgUrl,
     this.challengeMode,
     this.challengeType,
     this.target,
     this.userDuration,
    this.userAchieved,
     this.userProgress,
     this.challengeUnit,
     this.challengeRunType,
     this.lastUpdated,
     this.challengeStartTime,
     this.challengeEndTime,
     this.userStartTime,
     this.userEndTime,
     this.speed,
    this.isVarient,
    this.bannerVisibleInMainDashboard,
    this.bannerVisibleInSocialDashboard,
    this.milestoneTotalTarget,
    this.perDayTarget,
    this.selfieOptionSettings,
    this.challengeCategory,
    this.assosideId,
    this.groupId,
    this.groupAchieved,
    this.groupDuration,
    this.groupProgress,
    this.selectedFitnessApp,
  });

  factory Started.fromJson(Map<String, dynamic> json) => Started(
    userStatus: json["user_status"],
    name: json["name"],
    city: json["city"],
    department: json["department"],
    designation: json["designation"],
    gender: json["gender"],
    enrollmentId: json["enrollment_id"],
    userBibNo: json["user_bib_no"],
    challengeId: json["challenge_id"],
    challengeName: json["challenge_name"],
    imgUrl: json["img_url"],
    thumbnailUrl: json["thumbnail_url"],
    challengeBannerImgUrl: json["challenge_Banner_img_url"],
    challengeMode: json["challenge_mode"],
    challengeType: json["challenge_type"],
    target: json["target"],
    userDuration: json["user_duration"],
    userAchieved: json["user_achieved"],
    userProgress: json["user_progress"],
    challengeUnit: json["challenge_unit"],
    challengeRunType: json["challenge_run_type"],
    lastUpdated: json["last_updated"],
    challengeStartTime: json["challenge_start_time"],
    challengeEndTime: json["challenge_end_time"],
    userStartTime: json["user_start_time"],
    userEndTime: json["user_end_time"],
    speed: json["speed"],
    isVarient: json["is_varient"],
    bannerVisibleInMainDashboard: json["banner_visible_in_main_dashboard"],
    bannerVisibleInSocialDashboard: json["banner_visible_in_social_dashboard"],
    milestoneTotalTarget: json["milestone_total_target"],
    perDayTarget: json["per_day_target"],
    selfieOptionSettings: json["selfie_option_settings"],
    challengeCategory: json["challenge_category"],
    assosideId: json["assoside_id"],
    groupId: json["group_id"],
    groupAchieved: json["group_achieved"],
    groupDuration: json["group_duration"],
    groupProgress: json["group_progress"],
    selectedFitnessApp: json["selected_fitness_app"],
  );

  Map<String, dynamic> toJson() => {
    "user_status": userStatus,
    "name": name,
    "city": city,
    "department": department,
    "designation": designation,
    "gender": gender,
    "enrollment_id": enrollmentId,
    "user_bib_no": userBibNo,
    "challenge_id": challengeId,
    "challenge_name": challengeName,
    "img_url": imgUrl,
    "thumbnail_url": thumbnailUrl,
    "challenge_Banner_img_url": challengeBannerImgUrl,
    "challenge_mode": challengeMode,
    "challenge_type": challengeType,
    "target": target,
    "user_duration": userDuration,
    "user_achieved": userAchieved,
    "user_progress": userProgress,
    "challenge_unit": challengeUnit,
    "challenge_run_type": challengeRunType,
    "last_updated": lastUpdated,
    "challenge_start_time": challengeStartTime,
    "challenge_end_time": challengeEndTime,
    "user_start_time": userStartTime,
    "user_end_time": userEndTime,
    "speed": speed,
    "is_varient": isVarient,
    "banner_visible_in_main_dashboard": bannerVisibleInMainDashboard,
    "banner_visible_in_social_dashboard": bannerVisibleInSocialDashboard,
    "milestone_total_target": milestoneTotalTarget,
    "per_day_target": perDayTarget,
    "selfie_option_settings": selfieOptionSettings,
    "challenge_category": challengeCategory,
    "assoside_id": assosideId,
    "group_id": groupId,
    "group_achieved": groupAchieved,
    "group_duration": groupDuration,
    "group_progress": groupProgress,
    "selected_fitness_app": selectedFitnessApp,
  };
}

class NotStarted {
  String userStatus;
  String name;
  String city;
  String department;
  String designation;
  String gender;
  String enrollmentId;
  String userBibNo;
  String challengeId;
  String challengeName;
  String imgUrl;
  String thumbnailUrl;
  String challengeBannerImgUrl;
  String challengeMode;
  String challengeType;
  String target;
  String challengeUnit;
  String challengeRunType;
  String lastUpdated;
  String challengeStartTime;
  String challengeEndTime;
  String userStartTime;
  String userEndTime;
  bool isVarient;
  String assosideId;
  bool bannerVisibleInMainDashboard;
  bool bannerVisibleInSocialDashboard;
  bool selfieOptionSettings;

  NotStarted({
     this.userStatus,
     this.name,
     this.city,
     this.department,
     this.designation,
     this.gender,
     this.enrollmentId,
     this.userBibNo,
     this.challengeId,
     this.challengeName,
     this.imgUrl,
     this.thumbnailUrl,
     this.challengeBannerImgUrl,
     this.challengeMode,
     this.challengeType,
     this.target,
     this.challengeUnit,
     this.challengeRunType,
     this.lastUpdated,
     this.challengeStartTime,
     this.challengeEndTime,
     this.userStartTime,
     this.userEndTime,
     this.isVarient,
     this.assosideId,
     this.bannerVisibleInMainDashboard,
     this.bannerVisibleInSocialDashboard,
     this.selfieOptionSettings,
  });

  factory NotStarted.fromJson(Map<String, dynamic> json) => NotStarted(
    userStatus: json["user_status"],
    name: json["name"],
    city: json["city"],
    department: json["department"],
    designation: json["designation"],
    gender: json["gender"],
    enrollmentId: json["enrollment_id"],
    userBibNo: json["user_bib_no"],
    challengeId: json["challenge_id"],
    challengeName: json["challenge_name"],
    imgUrl: json["img_url"],
    thumbnailUrl: json["thumbnail_url"],
    challengeBannerImgUrl: json["challenge_Banner_img_url"],
    challengeMode: json["challenge_mode"],
    challengeType: json["challenge_type"],
    target: json["target"],
    challengeUnit: json["challenge_unit"],
    challengeRunType: json["challenge_run_type"],
    lastUpdated: json["last_updated"],
    challengeStartTime: json["challenge_start_time"],
    challengeEndTime: json["challenge_end_time"],
    userStartTime: json["user_start_time"],
    userEndTime: json["user_end_time"],
    isVarient: json["is_varient"],
    assosideId: json["assoside_id"],
    bannerVisibleInMainDashboard: json["banner_visible_in_main_dashboard"],
    bannerVisibleInSocialDashboard: json["banner_visible_in_social_dashboard"],
    selfieOptionSettings: json["selfie_option_settings"],
  );

  Map<String, dynamic> toJson() => {
    "user_status": userStatus,
    "name": name,
    "city": city,
    "department": department,
    "designation": designation,
    "gender": gender,
    "enrollment_id": enrollmentId,
    "user_bib_no": userBibNo,
    "challenge_id": challengeId,
    "challenge_name": challengeName,
    "img_url": imgUrl,
    "thumbnail_url": thumbnailUrl,
    "challenge_Banner_img_url": challengeBannerImgUrl,
    "challenge_mode": challengeMode,
    "challenge_type": challengeType,
    "target": target,
    "challenge_unit": challengeUnit,
    "challenge_run_type": challengeRunType,
    "last_updated": lastUpdated,
    "challenge_start_time": challengeStartTime,
    "challenge_end_time": challengeEndTime,
    "user_start_time": userStartTime,
    "user_end_time": userEndTime,
    "is_varient": isVarient,
    "assoside_id": assosideId,
    "banner_visible_in_main_dashboard": bannerVisibleInMainDashboard,
    "banner_visible_in_social_dashboard": bannerVisibleInSocialDashboard,
    "selfie_option_settings": selfieOptionSettings,
  };
}
