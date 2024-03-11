// To parse this JSON data, do
//
//     final logUserFoodIntake = logUserFoodIntakeFromJson(jsonString);

import 'dart:convert';

import 'package:intl/intl.dart';

// To parse this JSON data, do
//
//     final logUserFood = logUserFoodFromJson(jsonString);

LogUserFood logUserFoodFromJson(String str) => LogUserFood.fromJson(json.decode(str));

String logUserFoodToJson(LogUserFood data) => json.encode(data.toJson());

EditLogUserFood editlogUserFoodFromJson(String str) => EditLogUserFood.fromJson(json.decode(str));

String editlogUserFoodToJson(EditLogUserFood data) => json.encode(data.toJson());

class LogUserFood {
  LogUserFood({
    this.userIhlId,
    this.foodLogTime,
    this.epochLogTime,
    this.foodTimeCategory,
    this.caloriesGained,
    this.food,
  });

  String userIhlId;
  DateTime foodLogTime;
  int epochLogTime;
  String foodTimeCategory;
  String caloriesGained;
  List<Food> food;

  factory LogUserFood.fromJson(Map<String, dynamic> json) => LogUserFood(
        userIhlId: json["user_ihl_id"],
        foodLogTime: DateTime.parse(json["food_log_time"]),
        epochLogTime: json["epoch_log_time"],
        foodTimeCategory: json["food_time_category"],
        caloriesGained: json["calories_gained"],
        food: List<Food>.from(json["food"].map((x) => Food.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "user_ihl_id": userIhlId,
        "food_log_time": DateFormat('yyyy-MM-dd HH:mm:ss').format(foodLogTime),
        "epoch_log_time": epochLogTime,
        "food_time_category": foodTimeCategory,
        "calories_gained": caloriesGained,
        "food": List<dynamic>.from(food.map((x) => x.toJson())),
      };
}

class EditLogUserFood {
  EditLogUserFood({
    this.userIhlId,
    this.foodLogTime,
    this.foodLogId,
    this.epochLogTime,
    this.foodTimeCategory,
    this.caloriesGained,
    this.food,
  });

  String userIhlId;
  String foodLogTime;
  String foodLogId;
  int epochLogTime;
  String foodTimeCategory;
  String caloriesGained;
  List<Food> food;

  factory EditLogUserFood.fromJson(Map<String, dynamic> json) => EditLogUserFood(
      userIhlId: json["user_ihl_id"],
      foodLogTime: json["food_log_time"],
      epochLogTime: json["epoch_log_time"],
      foodTimeCategory: json["food_time_category"],
      caloriesGained: json["calories_gained"],
      food: List<Food>.from(json["food"].map((x) => Food.fromJson(x))),
      foodLogId: json["food_log_id"]);

  Map<String, dynamic> toJson() => {
        "user_ihl_id": userIhlId,
        "food_log_time": DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(DateFormat('dd-MM-yyyy HH:mm:ss').parse(foodLogTime)),
        "epoch_log_time": epochLogTime,
        "food_time_category": foodTimeCategory,
        "calories_gained": caloriesGained,
        "food": List<dynamic>.from(food.map((x) => x.toJson())),
        "food_log_id": foodLogId
      };
}

class Food {
  Food({
    this.foodDetails,
  });

  List<FoodDetail> foodDetails;

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        foodDetails: List<FoodDetail>.from(json["food_details"].map((x) => FoodDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "food_details": List<dynamic>.from(foodDetails.map((x) => x.toJson())),
      };
}

class FoodDetail {
  FoodDetail({
    this.foodId,
    this.foodName,
    this.foodQuantity,
    this.quantityUnit,
  });

  var foodId;
  String foodName;
  String foodQuantity;
  String quantityUnit;

  factory FoodDetail.fromJson(Map<String, dynamic> json) => FoodDetail(
        foodId: json["food_id"],
        foodName: json["food_name"],
        foodQuantity: json["food_quantity"],
        quantityUnit: json["quantity_unit"],
      );

  Map<String, dynamic> toJson() => {
        "food_id": foodId,
        "food_name": foodName,
        "food_quantity": foodQuantity,
        "quantity_unit": quantityUnit,
      };
}

LogUserFoodIntakeResponse logUserFoodIntakeFromJson(String str) =>
    LogUserFoodIntakeResponse.fromJson(json.decode(str));

class LogUserFoodIntakeResponse {
  LogUserFoodIntakeResponse({
    this.status,
    this.response,
  });

  String status;
  String response;

  factory LogUserFoodIntakeResponse.fromJson(Map<String, dynamic> json) =>
      LogUserFoodIntakeResponse(
        status: json["status"],
        response: json["response"],
      );
}
