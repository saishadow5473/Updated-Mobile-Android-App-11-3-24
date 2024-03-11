import 'dart:convert';

List<GetFoodUnit> getFoodUnitFromJson(String str) => json.decode(str) == null
    ? []
    : List<GetFoodUnit>.from(json.decode(str).map((x) => GetFoodUnit.fromJson(x)));

String getFoodUnitToJson(List<GetFoodUnit> data) =>
    json.encode(data == null ? [] : List<dynamic>.from(data.map((x) => x.toJson())));

class GetFoodUnit {
  GetFoodUnit({
    this.foodId,
    this.calories,
    this.carbs,
    this.dish,
    this.fats,
    this.fiber,
    this.item,
    this.servingUnitSize,
    this.protein,
    this.quantity,
  });

  String foodId;
  String calories;
  String carbs;
  String dish;
  String fats;
  String fiber;
  String item;
  String servingUnitSize;
  String protein;
  String quantity;

  factory GetFoodUnit.fromJson(Map<String, dynamic> json) => GetFoodUnit(
        foodId: json["food_id"],
        calories: json["calories"],
        carbs: json["carbs"],
        dish: json["dish"],
        fats: json["fats"],
        fiber: json["fiber"],
        item: json["item"],
        servingUnitSize: json["serving_unit_size"],
        protein: json["protein"],
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "food_id": foodId,
        "calories": calories,
        "carbs": carbs,
        "dish": dish,
        "fats": fats,
        "fiber": fiber,
        "item": item,
        "serving_unit_size": servingUnitSize,
        "protein": protein,
        "quantity": quantity,
      };
}
