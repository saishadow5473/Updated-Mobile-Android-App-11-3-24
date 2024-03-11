// To parse this JSON data, do
//
//     final getFoodGroupMealModel = getFoodGroupMealModelFromJson(jsonString);

import 'dart:convert';

GetFoodGroupMealModel getFoodGroupMealModelFromJson(String str) =>
    GetFoodGroupMealModel.fromJson(json.decode(str));

String getFoodGroupMealModelToJson(GetFoodGroupMealModel data) => json.encode(data.toJson());

class GetFoodGroupMealModel {
  List<Status> status;

  GetFoodGroupMealModel({
    this.status,
  });

  factory GetFoodGroupMealModel.fromJson(Map<String, dynamic> json) => GetFoodGroupMealModel(
        status: List<Status>.from(json["status"].map((x) => Status.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": List<dynamic>.from(status.map((x) => x.toJson())),
      };
}

class Status {
  String foodLogGroupId;
  String groupName;
  String userId;
  var listOfFoodLogs;
  String totalCalorieCount;

  Status({
    this.foodLogGroupId,
    this.groupName,
    this.userId,
    this.listOfFoodLogs,
    this.totalCalorieCount,
  });

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        foodLogGroupId: json["food_log_group_id"],
        groupName: json["group_name"],
        userId: json["user_id"],
        listOfFoodLogs: jsonDecode(json["list_of_food_logs"].replaceAll("&#39;", "\"")),
        totalCalorieCount: json["total_calorie_count"],
      );

  Map<String, dynamic> toJson() => {
        "food_log_group_id": foodLogGroupId,
        "group_name": groupName,
        "user_id": userId,
        "list_of_food_logs": listOfFoodLogs,
        "total_calorie_count": totalCalorieCount,
      };
}
