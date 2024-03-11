// To parse this JSON data, do
//
//     final createEditRecipe = createEditRecipeFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

CreateEditRecipe createEditRecipeFromJson(String str) =>
    CreateEditRecipe.fromJson(json.decode(str));

String createEditRecipeToJson(CreateEditRecipe data) => json.encode(data.toJson());

class CreateEditRecipe {
  CreateEditRecipe({
    this.ihlId,
    this.dish,
    this.quantity,
    this.servingUnitSize,
    this.calories,
    this.protein,
    this.fats,
    this.carbs,
    this.fiber,
    this.hypertension,
    this.heartDisease,
    this.diabetes,
    this.highCholesterol,
    this.highVisceralFat,
    this.highBmi,
    this.foodId,
    @required this.ingredientDetail,
  });

  String ihlId;
  String dish;
  String quantity;
  String servingUnitSize;
  String calories;
  String protein;
  String fats;
  String carbs;
  String fiber;
  String hypertension;
  String heartDisease;
  String diabetes;
  String highCholesterol;
  String highVisceralFat;
  String highBmi;
  String foodId = '0';
  String ingredientDetail;

  factory CreateEditRecipe.fromJson(Map<String, dynamic> json) => CreateEditRecipe(
      ihlId: json["ihl_id"],
      dish: json["dish"],
      quantity: json["quantity"],
      servingUnitSize: json["serving_unit_size"],
      calories: json["calories"],
      protein: json["protein"],
      fats: json["fats"],
      carbs: json["carbs"],
      fiber: json["fiber"],
      hypertension: json["hypertension"],
      heartDisease: json["heart_disease"],
      diabetes: json["diabetes"],
      highCholesterol: json["high_cholesterol"],
      highVisceralFat: json["high_visceral_fat"],
      highBmi: json["high_bmi"],
      foodId: json["food_id"],
      ingredientDetail: json["ingredient_detail"]);

  Map<String, dynamic> toJson() => {
        "ihl_id": ihlId,
        "dish": dish,
        "quantity": quantity,
        "serving_unit_size": servingUnitSize,
        "calories": calories,
        "protein": protein,
        "fats": fats,
        "carbs": carbs,
        "fiber": fiber,
        "hypertension": hypertension,
        "heart_disease": heartDisease,
        "diabetes": diabetes,
        "high_cholesterol": highCholesterol,
        "high_visceral_fat": highVisceralFat,
        "high_bmi": highBmi,
        "food_id": foodId,
        "ingredient_detail": ingredientDetail
      };
}

class IngredientModel {
  IngredientModel({
    this.fiber,
    this.protiens,
    this.totalFat,
    this.item,
    this.calories,
    this.totalCarbohydrate,
    this.amount_unit,
    this.amount,
    this.itemId,
    this.fixedAmount,
  });

  String fiber;
  String protiens;
  String totalFat;
  String item;
  String calories;
  String totalCarbohydrate, amount_unit, amount, itemId, fixedAmount;

  factory IngredientModel.fromJson(Map<String, dynamic> json) => IngredientModel(
      fiber: json["fiber"],
      protiens: json["protiens"] ?? "0",
      totalFat: json["fats"],
      item: json["ingredient"],
      calories: json["calories"],
      totalCarbohydrate: json["carbs"],
      amount_unit: json["serving_unit_size"],
      amount: json["quantity"]);

  Map<String, dynamic> toJson() => {
        "fiber": fiber,
        "protiens": protiens,
        "fats": totalFat,
        "ingredient": item,
        "calories": calories,
        "carbs": totalCarbohydrate,
        "quantity": amount,
        "serving_unit_size": amount_unit
      };
}
