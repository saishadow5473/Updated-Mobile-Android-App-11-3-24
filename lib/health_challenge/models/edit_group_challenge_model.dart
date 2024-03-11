class EditGroupChallenge {
  EditGroupChallenge({
    this.groupId,
    this.groupDetail,
  });

  String groupId;
  String groupDetail;

  factory EditGroupChallenge.fromJson(Map<String, dynamic> json) => EditGroupChallenge(
        groupId: json["group_id"],
        groupDetail: json["group_detail"],
      );

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "group_detail": groupDetail,
      };
}
