// To parse this JSON data, do
//
//     final getTodaySFoodLog = getTodaySFoodLogFromJson(jsonString);

import 'dart:convert';

import 'package:strings/strings.dart';

GetTodaySFoodLog getTodaySFoodLogFromJson(String str) => GetTodaySFoodLog.fromJson(json.decode(str));

String getTodaySFoodLogToJson(GetTodaySFoodLog data) => json.encode(data.toJson());

class GetTodaySFoodLog {
    GetTodaySFoodLog({
        this.food,
        this.activity,
    });

    List<Food> food;
    List<Activity> activity;

    factory GetTodaySFoodLog.fromJson(Map<String, dynamic> json) => GetTodaySFoodLog(
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
        this.logType,
        this.logTime,
        this.totalCaloriesBurned,
        this.activityDetails,
        this.logId,
    });
    String logId;
    String logType;
    String logTime;
    String totalCaloriesBurned;
    List<ActivityDetails> activityDetails;

    factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        logType: json["log_type"],
        logTime: json["log_time"],
        logId:json["log_id"],
        totalCaloriesBurned: json["total_calories_bued"],
        activityDetails: List<ActivityDetails>.from(json["activity_details"].map((x) => ActivityDetails.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "log_type": logType,
        "log_time": logTime,
        "total_calories_bued": totalCaloriesBurned,
        "activity_details": List<dynamic>.from(activityDetails.map((x) => x.toJson())),
    };
}

class ActivityDetails {
    ActivityDetails({
        this.activityDetails,
    });

    List<ActivityDetail> activityDetails;

    factory ActivityDetails.fromJson(Map<String, dynamic> json) => ActivityDetails(
        activityDetails: List<ActivityDetail>.from(json["activity_details"].map((x) => ActivityDetail.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "activity_details": List<dynamic>.from(activityDetails.map((x) => x.toJson())),
    };
}

class ActivityDetail {
    ActivityDetail({
        this.activityId,
        this.activityName,
        this.activityDuration,
    });

    String activityId;
    String activityName;
    String activityDuration;

    factory ActivityDetail.fromJson(Map<String, dynamic> json) => ActivityDetail(
        activityId: json["activity_id"].toString(),
        activityName: json["activity_name"],
        activityDuration: json["activity_duration"],
    );

    Map<String, dynamic> toJson() => {
        "activity_id": activityId,
        "activity_name": activityName,
        "activity_duration": activityDuration,
    };
}

class Food {
    Food({
        this.logType,
        this.logTime,
        this.totalCaloriesGained,
        this.mealDetails,
        this.mealCategory,
        this.epochLogTime,
        this.foodLogId
    });

    String logType;
    String logTime;
    String totalCaloriesGained;
    List<MealDetail> mealDetails;
    String mealCategory;
    int epochLogTime;
    String foodLogId;

    factory Food.fromJson(Map<String, dynamic> json) => Food(
        logType: json["log_type"],
        logTime: json["log_time"],
        foodLogId: json["log_id"],
        totalCaloriesGained: json["total_calories_gained"],
        mealDetails: List<MealDetail>.from(json["meal_details"].map((x) => MealDetail.fromJson(x))),
        mealCategory: json["meal_category"],
        epochLogTime: json["epoch_log_time"]
    );

    Map<String, dynamic> toJson() => {
        "log_type": logType,
        "log_time": logTime,
        "total_calories_gained": totalCaloriesGained,
        "meal_details": List<dynamic>.from(mealDetails.map((x) => x.toJson())),
        "meal_category": mealCategory,
        "epoch_log_time":epochLogTime,
    };
}

class MealDetail {
    MealDetail({
        this.foodDetails,
    });

    List<FoodDetail> foodDetails;

    factory MealDetail.fromJson(Map<String, dynamic> json) => MealDetail(
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
        this.quantityUnit,
        this.foodQuantity,
    });

    var foodId;
    String foodName;
    String foodQuantity;
    String quantityUnit;

    factory FoodDetail.fromJson(Map<String, dynamic> json) => FoodDetail(
        foodId: json["food_id"],
        foodName: json["food_name"],
        foodQuantity: json["food_quantity"]??'1',
        quantityUnit: camelize(json["quantity_unit"]??'Nos.')
    );

    Map<String, dynamic> toJson() => {
        "food_id": foodId,
        "food_name": foodName,//Values.reverse[foodName],
        "food_quantity": foodQuantity,
    };
}