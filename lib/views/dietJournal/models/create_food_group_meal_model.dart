// To parse this JSON data, do
//
//     final createFoodGroupMealModel = createFoodGroupMealModelFromJson(jsonString);

import 'dart:convert';

CreateFoodGroupMealModel createFoodGroupMealModelFromJson(String str) =>
    CreateFoodGroupMealModel.fromJson(json.decode(str));

String createFoodGroupMealModelToJson(CreateFoodGroupMealModel data) => json.encode(data.toJson());

class CreateFoodGroupMealModel {
  String status;

  CreateFoodGroupMealModel({
    this.status,
  });

  factory CreateFoodGroupMealModel.fromJson(Map<String, dynamic> json) => CreateFoodGroupMealModel(
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
      };
}
