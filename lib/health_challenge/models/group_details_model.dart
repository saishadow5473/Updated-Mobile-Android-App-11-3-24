class GroupDetailModel {
  GroupDetailModel({
    this.groupId,
    this.groupName,
    this.groupDetail,
    this.minUser,
    this.maxUser,
    this.currentUserCount,
    this.challengeId,
    this.groupStatus,
    this.groupProgressionStatus,
    this.groupTarget,
    this.groupAchieved,
  });

  String groupId;
  String groupName;
  String groupDetail;
  int minUser;
  int maxUser;
  int currentUserCount;
  String challengeId;
  String groupStatus;
  String groupProgressionStatus;
  String groupTarget;
  String groupAchieved;

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) => GroupDetailModel(
        groupId: json["group_id"],
        groupName: json["group_name"],
        groupDetail: json["group_detail"],
        minUser: json["min_user"],
        maxUser: json["max_user"],
        currentUserCount: json["current_user_count"],
        challengeId: json["challenge_id"],
        groupStatus: json["group_status"],
        groupProgressionStatus: json["group_progression_status"],
        groupTarget: json["group_target"],
        groupAchieved: json["group_achieved"],
      );

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "group_name": groupName,
        "group_detail": groupDetail,
        "min_user": minUser,
        "max_user": maxUser,
        "current_user_count": currentUserCount,
        "challenge_id": challengeId,
        "group_status": groupStatus,
        "group_progression_status": groupProgressionStatus,
        "group_target": groupTarget,
        "group_achieved": groupAchieved,
      };
}
