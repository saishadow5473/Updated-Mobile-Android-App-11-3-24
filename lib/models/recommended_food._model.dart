// To parse this JSON data, do
//
//     final recommendedFood = recommendedFoodFromJson(jsonString);

import 'dart:convert';

RecommendedFood recommendedFoodFromJson(String str) =>
    RecommendedFood.fromJson(json.decode(str));

String recommendedFoodToJson(RecommendedFood data) =>
    json.encode(data.toJson());

class RecommendedFood {
  RecommendedFood({
    this.id,
    this.region,
    this.mealType,
    this.hypertension,
    this.cholesterol,
    this.visceralFats,
    this.dishType,
    this.dishName,
  });

  final int id;
  final String region;
  final String mealType;
  final String hypertension;
  final String cholesterol;
  final String visceralFats;
  final String dishType;
  final String dishName;

  factory RecommendedFood.fromJson(Map<String, dynamic> json) =>
      RecommendedFood(
        id: json["id"],
        region: json["region"],
        mealType: json["meal_type"],
        hypertension: json["hypertension"],
        cholesterol: json["cholesterol"],
        visceralFats: json["visceral_fats"],
        dishType: json["dish_type"],
        dishName: json["dish_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "region": region,
        "meal_type": mealType,
        "hypertension": hypertension,
        "cholesterol": cholesterol,
        "visceral_fats": visceralFats,
        "dish_type": dishType,
        "dish_name": dishName,
      };
}
