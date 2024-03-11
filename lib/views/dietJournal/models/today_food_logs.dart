// To parse this JSON data, do
//
//     final todayFoodLog = todayFoodLogFromJson(jsonString);

import 'dart:convert';

List<TodayFoodLog> todayFoodLogFromJson(String str) => List<TodayFoodLog>.from(json.decode(str).map((x) => TodayFoodLog.fromJson(x)));

String todayFoodLogToJson(List<TodayFoodLog> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TodayFoodLog {
    TodayFoodLog({
        this.food,
        this.foodLogTime,
        this.epochLogTime,
        this.foodTimeCategory,
        this.totalCaloriesGained,
        this.foodLogId
    });

    List<Food> food;
    String foodLogTime;
    int epochLogTime;
    String foodTimeCategory;
    String totalCaloriesGained;
    String foodLogId;

    factory TodayFoodLog.fromJson(Map<String, dynamic> json) => TodayFoodLog(
        food: List<Food>.from(json["food"].map((x) => Food.fromJson(x))),
        foodLogTime: json["food_log_time"],
        epochLogTime: json["epoch_log_time"],
        foodTimeCategory: json["food_time_category"],
        totalCaloriesGained: json["total_calories_gained"],
        foodLogId: json["log_id"]
    );

    Map<String, dynamic> toJson() => {
        "food": List<dynamic>.from(food.map((x) => x.toJson())),
        "food_log_time": foodLogTime,
        "epoch_log_time": epochLogTime,
        "food_time_category": foodTimeCategory,
        "total_calories_gained": totalCaloriesGained,
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

    String foodId;
    String foodName;
    String foodQuantity;
    String quantityUnit;

    factory FoodDetail.fromJson(Map<String, dynamic> json) => FoodDetail(
        foodId: json["food_id"].toString(),
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
