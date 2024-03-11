import 'dart:convert';

import 'package:meta/meta.dart';

GroupModel groupModelFromJson(String str) =>
    GroupModel.fromJson(json.decode(str));

String groupModelToJson(GroupModel data) => json.encode(data.toJson());

class GroupModel {
  GroupModel({
    @required this.groupId,
    @required this.groupName,
    @required this.groupDetail,
    @required this.groupStatus,
  });

  String groupId, groupName, groupDetail, groupStatus;

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        groupId: json["group_id"],
        groupName: json["group_name"],
        groupDetail: json["group_detail"],
        groupStatus: json["group_status"],
      );

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "group_name": groupName,
        "group_detail": groupDetail,
        "group_status": groupStatus,
      };
}
