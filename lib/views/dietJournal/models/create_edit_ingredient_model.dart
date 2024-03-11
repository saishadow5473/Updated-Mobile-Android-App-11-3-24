// To parse this JSON data, do
//
//     final createEditIngredient = createEditIngredientFromJson(jsonString);

import 'dart:convert';

CreateEditIngredient createEditIngredientFromJson(String str) => CreateEditIngredient.fromJson(json.decode(str));

String createEditIngredientToJson(CreateEditIngredient data) => json.encode(data.toJson());

class CreateEditIngredient {
    String ihlId;
    String calories;
    String carbs;
    String fats;
    String fiber;
    String ingredient;
    String protein;
    String quantity;
    String servingUnitSize;
    String foodId;

    CreateEditIngredient({
         this.ihlId,
         this.calories,
         this.carbs,
         this.fats,
         this.fiber,
         this.ingredient,
         this.protein,
         this.quantity,
         this.servingUnitSize,
         this.foodId,
    });

    factory CreateEditIngredient.fromJson(Map<String, dynamic> json) => CreateEditIngredient(
        ihlId: json["ihl_id"],
        calories: json["calories"],
        carbs: json["carbs"],
        fats: json["fats"],
        fiber: json["fiber"],
        ingredient: json["ingredient"],
        protein: json["protein"],
        quantity: json["quantity"],
        servingUnitSize: json["serving_unit_size"],
        foodId: json["food_id"],
    );

    Map<String, dynamic> toJson() => {
        "ihl_id": ihlId,
        "calories": calories,
        "carbs": carbs,
        "fats": fats,
        "fiber": fiber,
        "ingredient": ingredient,
        "protein": protein,
        "quantity": quantity,
        "serving_unit_size": servingUnitSize,
        "food_id": foodId,
    };
}



// // To parse this JSON data, do
// //
// //     final createEditIngredient = createEditIngredientFromJson(jsonString);
//
// import 'dart:convert';
//
// CreateEditIngredient createEditIngredientFromJson(String str) => CreateEditIngredient.fromJson(json.decode(str));
//
// String createEditIngredientToJson(CreateEditIngredient data) => json.encode(data.toJson());
//
// class CreateEditIngredient {
//     CreateEditIngredient({
//         this.ihlId,
//         this.additionalRegion,
//         this.userIngredientId1,
//         this.userIngredientId2,
//         this.amountUnit,
//         this.calcium,
//         this.colesterol,
//         this.fiber,
//         this.item,
//         this.ingredients,
//         this.monounsaturatedFats,
//         this.polyunsaturatedFats,
//         this.potassium,
//         this.preference,
//         this.iron,
//         this.protiens,
//         this.quanity,
//         this.quantityUnit,
//         this.restrictedFor,
//         this.calories,
//         this.saturatedFat,
//         this.sodium,
//         this.sugar,
//         this.timingsFor,
//         this.totalCarbohydrate,
//         this.totalFat,
//         this.transfattyAcid,
//         this.vitaminA,
//         this.notes,
//         this.vitaminC,
//     });
//
//     String ihlId;
//     String additionalRegion;
//     String userIngredientId1;
//     String userIngredientId2;
//     String amountUnit;
//     String calcium;
//     String colesterol;
//     String fiber;
//     String item;
//     String ingredients;
//     String monounsaturatedFats;
//     String polyunsaturatedFats;
//     String potassium;
//     String preference;
//     String iron;
//     String protiens;
//     String quanity;
//     String quantityUnit;
//     String restrictedFor;
//     String calories;
//     String saturatedFat;
//     String sodium;
//     String sugar;
//     String timingsFor;
//     String totalCarbohydrate;
//     String totalFat;
//     String transfattyAcid;
//     String vitaminA;
//     String notes;
//     String vitaminC;
//
//     factory CreateEditIngredient.fromJson(Map<String, dynamic> json) => CreateEditIngredient(
//         ihlId: json["ihl_id"],
//         additionalRegion: json["additional_region"].toString(),
//         userIngredientId1: json["user_ingredient_id1"],
//         userIngredientId2: json["user_ingredient_id2"],
//         amountUnit: json["amount_unit"],
//         calcium: json["calcium"],
//         colesterol: json["colesterol"],
//         fiber: json["fiber"],
//         item: json["item"],
//         ingredients: json["ingredients"],
//         monounsaturatedFats: json["monounsaturated_fats"],
//         polyunsaturatedFats: json["polyunsaturated_fats"],
//         potassium: json["potassium"],
//         preference: json["preference"],
//         iron: json["iron"],
//         protiens: json["protiens"],
//         quanity: json["quanity"],
//         quantityUnit: json["quantity_unit"],
//         restrictedFor: json["restricted_for"],
//         calories: json["calories"],
//         saturatedFat: json["saturated_fat"],
//         sodium: json["sodium"],
//         sugar: json["sugar"],
//         timingsFor: json["timings_for"],
//         totalCarbohydrate: json["total_carbohydrate"],
//         totalFat: json["total_fat"],
//         transfattyAcid: json["transfatty_acid"],
//         vitaminA: json["vitamin_a"],
//         notes: json["notes"],
//         vitaminC: json["vitamin_c"],
//     );
//
//     Map<String, dynamic> toJson() => {
//         "ihl_id": ihlId,
//         "additional_region": additionalRegion,
//         "user_ingredient_id1": userIngredientId1,
//         "user_ingredient_id2": userIngredientId2,
//         "amount_unit": amountUnit,
//         "calcium": calcium,
//         "colesterol": colesterol,
//         "fiber": fiber,
//         "item": item,
//         "ingredients": ingredients,
//         "monounsaturated_fats": monounsaturatedFats,
//         "polyunsaturated_fats": polyunsaturatedFats,
//         "potassium": potassium,
//         "preference": preference,
//         "iron": iron,
//         "protiens": protiens,
//         "quanity": quanity,
//         "quantity_unit": quantityUnit,
//         "restricted_for": restrictedFor,
//         "calories": calories,
//         "saturated_fat": saturatedFat,
//         "sodium": sodium,
//         "sugar": sugar,
//         "timings_for": timingsFor,
//         "total_carbohydrate": totalCarbohydrate,
//         "total_fat": totalFat,
//         "transfatty_acid": transfattyAcid,
//         "vitamin_a": vitaminA,
//         "notes": notes,
//         "vitamin_c": vitaminC,
//     };
// }
