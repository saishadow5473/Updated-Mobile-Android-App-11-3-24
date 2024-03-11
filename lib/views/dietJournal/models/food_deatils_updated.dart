import 'dart:convert';

UpdatedFoodDetails updatedFoodDetailsFromJson(String str) =>
    UpdatedFoodDetails.fromJson(json.decode(str));

String updatedFoodDetailsToJson(UpdatedFoodDetails data) => json.encode(data.toJson());

class UpdatedFoodDetails {
  UpdatedFoodDetails({
    this.foodId,
    this.calories,
    this.carbs,
    this.diabetes,
    this.dish,
    this.fats,
    this.fiber,
    this.heartDisease,
    this.highBmi,
    this.item,
    this.hypertension,
    this.highVisceralFat,
    this.highCholesterol,
    this.servingUnitSize,
    this.protein,
    this.quantity,
    this.sno,
  });

  final String foodId;
  final String calories;
  final String carbs;
  final String diabetes;
  final String dish;
  final String fats;
  final String fiber;
  final String heartDisease;
  final String highBmi;
  final String item;
  final String hypertension;
  final String highVisceralFat;
  final String highCholesterol;
  String servingUnitSize;
  final String protein;
  final String quantity;
  final String sno;

  factory UpdatedFoodDetails.fromJson(Map<String, dynamic> json) => UpdatedFoodDetails(
        foodId: json["food_id"],
        calories: json["calories"],
        carbs: json["carbs"],
        diabetes: json["diabetes"],
        dish: json["dish"],
        fats: json["fats"],
        fiber: json["fiber"],
        heartDisease: json["heart_disease"],
        highBmi: json["high_bmi"],
        item: json["item"],
        hypertension: json["hypertension"],
        highVisceralFat: json["high_visceral_fat"],
        highCholesterol: json["high_cholesterol"],
        servingUnitSize: json["serving_unit_size"],
        protein: json["protein"],
        quantity: json["quantity"],
        sno: json["sno"],
      );

  Map<String, dynamic> toJson() => {
        "food_id": foodId,
        "calories": calories,
        "carbs": carbs,
        "diabetes": diabetes,
        "dish": dish,
        "fats": fats,
        "fiber": fiber,
        "heart_disease": heartDisease,
        "high_bmi": highBmi,
        "item": item,
        "hypertension": hypertension,
        "high_visceral_fat": highVisceralFat,
        "high_cholesterol": highCholesterol,
        "serving_unit_size": servingUnitSize,
        "protein": protein,
        "quantity": quantity,
        "sno": sno,
      };
}
