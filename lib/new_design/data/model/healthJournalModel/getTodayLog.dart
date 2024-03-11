// To parse this JSON data, do
//
//     final getTodayLogModel = getTodayLogModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

GetTodayLogModel getTodayLogModelFromJson(String str) =>
    GetTodayLogModel.fromJson(json.decode(str));

String getTodayLogModelToJson(GetTodayLogModel data) => json.encode(data.toJson());

class GetTodayLogModel {
  GetTodayLogModel({
    this.food,
    this.activity,
  });

  List<Food> food;
  List<Activity> activity;

  factory GetTodayLogModel.fromJson(Map<String, dynamic> json) => GetTodayLogModel(
        food: List<Food>.from(json["food"].map((x) => Food.fromJson(x))),
        activity: List<Activity>.from(json["activity"].map((x) => Activity.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "food": List<dynamic>.from(food.map((x) => x.toJson())),
        "activity": List<dynamic>.from(activity.map((x) => x.toJson())),
      };
}

class Activity {
  Activity({
    @required this.logType,
    @required this.logTime,
    @required this.epochLogTime,
    @required this.totalCaloriesBurned,
    @required this.activityDetails,
  });

  String logType;
  String logTime;
  int epochLogTime;
  String totalCaloriesBurned;
  String activityDetails;

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        logType: json["log_type"],
        logTime: json["log_time"],
        epochLogTime: json["epoch_log_time"],
        totalCaloriesBurned: json["total_calories_burned"],
        activityDetails: json["activity_details"],
      );

  Map<String, dynamic> toJson() => {
        "log_type": logType,
        "log_time": logTime,
        "epoch_log_time": epochLogTime,
        "total_calories_burned": totalCaloriesBurned,
        "activity_details": activityDetails,
      };
}

class Food {
  Food({
    @required this.logType,
    @required this.logTime,
    @required this.epochLogTime,
    @required this.totalCaloriesGained,
    @required this.mealDetails,
    @required this.mealCategory,
  });

  LogType logType;
  String logTime;
  int epochLogTime;
  String totalCaloriesGained;
  String mealDetails;
  MealCategory mealCategory;

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        logType: logTypeValues.map[json["log_type"]],
        logTime: json["log_time"],
        epochLogTime: json["epoch_log_time"],
        totalCaloriesGained: json["total_calories_gained"],
        mealDetails: json["meal_details"],
        mealCategory: mealCategoryValues.map[json["meal_category"]],
      );

  Map<String, dynamic> toJson() => {
        "log_type": logTypeValues.reverse[logType],
        "log_time": logTime,
        "epoch_log_time": epochLogTime,
        "total_calories_gained": totalCaloriesGained,
        "meal_details": mealDetails,
        "meal_category": mealCategoryValues.reverse[mealCategory],
      };
}

enum LogType { FOOD }

final logTypeValues = EnumValues({"food": LogType.FOOD});

enum MealCategory { LUNCH, BREAKFAST, SNACKS, DINNER }

final mealCategoryValues = EnumValues({
  "Breakfast": MealCategory.BREAKFAST,
  "Dinner": MealCategory.DINNER,
  "Lunch": MealCategory.LUNCH,
  "Snacks": MealCategory.SNACKS
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
