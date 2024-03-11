// To parse this JSON data, do
//
//     final listCustomRecipe = listCustomRecipeFromJson(jsonString);

import 'dart:convert';

import 'package:ihl/views/dietJournal/models/create_edit_meal_model.dart';

List<ListCustomRecipe> listCustomRecipeFromJson(String str) => json.decode(str) == null
    ? []
    : List<ListCustomRecipe>.from(json.decode(str).map((x) => ListCustomRecipe.fromJson(x)));

String listCustomRecipeToJson(List<ListCustomRecipe> data) =>
    json.encode(data == null ? [] : List<dynamic>.from(data.map((x) => x.toJson())));

class ListCustomRecipe {
  ListCustomRecipe(
      {this.ihlId,
      this.foodId,
      this.dish,
      this.quantity,
      this.servingUnitSize,
      this.calories,
      this.protein,
      this.carbs,
      this.fiber,
      this.fats,
      this.highVisceralFat,
      this.hypertension,
      this.heartDisease,
      this.diabetes,
      this.highCholesterol,
      this.highBmi,
      this.partitionKey,
      this.rowKey,
      this.timestamp,
      this.eTag,
      this.ingredientDetail});

  String ihlId;
  String foodId;
  String dish;
  String quantity;
  String servingUnitSize;
  String calories;
  String protein;
  String carbs;
  String fiber;
  String fats;
  String highVisceralFat;
  String hypertension;
  String heartDisease;
  String diabetes;
  String highCholesterol;
  String highBmi;
  String partitionKey;
  String rowKey;
  String timestamp;
  String eTag;
  List<IngredientModel> ingredientDetail;

  factory ListCustomRecipe.fromJson(Map<String, dynamic> json) => ListCustomRecipe(
      ihlId: json["ihl_id"],
      foodId: json["food_id"],
      dish: json["dish"],
      quantity: json["quantity"],
      servingUnitSize: json["serving_unit_size"],
      calories: json["calories"],
      protein: json["protein"],
      carbs: json["carbs"],
      fiber: json["fiber"],
      fats: json["fats"],
      highVisceralFat: json["high_visceral_fat"],
      hypertension: json["hypertension"],
      heartDisease: json["heart_disease"],
      diabetes: json["diabetes"],
      highCholesterol: json["high_cholesterol"],
      highBmi: json["high_bmi"],
      partitionKey: json["PartitionKey"],
      rowKey: json["RowKey"],
      timestamp: json["Timestamp"],
      eTag: json["ETag"],
      ingredientDetail:json["ingredient_detail"]=="[]"?[]: json["ingredient_detail"]
          .map<IngredientModel>((e) => IngredientModel.fromJson(e))
          .toList());

  Map<String, dynamic> toJson() => {
        "ihl_id": ihlId,
        "food_id": foodId,
        "dish": dish,
        "quantity": quantity,
        "serving_unit_size": servingUnitSize,
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fiber": fiber,
        "fats": fats,
        "high_visceral_fat": highVisceralFat,
        "hypertension": hypertension,
        "heart_disease": heartDisease,
        "diabetes": diabetes,
        "high_cholesterol": highCholesterol,
        "high_bmi": highBmi,
        "PartitionKey": partitionKey,
        "RowKey": rowKey,
        "Timestamp": timestamp,
        "ETag": eTag,
        "ingredient_detail": ingredientDetail
      };
}
