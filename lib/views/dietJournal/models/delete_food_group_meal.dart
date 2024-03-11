// To parse this JSON data, do
//
//     final deleteFoodGroupMealModel = deleteFoodGroupMealModelFromJson(jsonString);

import 'dart:convert';

DeleteFoodGroupMealModel deleteFoodGroupMealModelFromJson(String str) =>
    DeleteFoodGroupMealModel.fromJson(json.decode(str));

String deleteFoodGroupMealModelToJson(DeleteFoodGroupMealModel data) => json.encode(data.toJson());

class DeleteFoodGroupMealModel {
  String status;

  DeleteFoodGroupMealModel({
    this.status,
  });

  factory DeleteFoodGroupMealModel.fromJson(Map<String, dynamic> json) => DeleteFoodGroupMealModel(
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
      };
}
