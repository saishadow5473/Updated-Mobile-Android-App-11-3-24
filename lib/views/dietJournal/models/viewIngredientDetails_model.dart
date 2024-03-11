// To parse this JSON data, do
//
//     final listCustomIngredient = listCustomIngredientFromJson(jsonString);

import 'dart:convert';

List<ListCustomIngredient> listCustomIngredientFromJson(String str) => List<ListCustomIngredient>.from(json.decode(str).map((x) => ListCustomIngredient.fromJson(x)));

String listCustomIngredientToJson(List<ListCustomIngredient> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

ListCustomIngredient customRecipeDetailFromJson(String str) => ListCustomIngredient.fromJson(json.decode(str));

String customRecipeDetailToJson(ListCustomIngredient data) => json.encode(data.toJson());

class ListCustomIngredient {
    ListCustomIngredient({
        this.ihlId,
        this.additionalRegion,
        this.userIngredientId1,
        this.userIngredientId2,
        this.amount,
        this.amountUnit,
        this.calcium,
        this.colesterol,
        this.fiber,
        this.monounsaturatedFats,
        this.polyunsaturatedFats,
        this.potassium,
        this.preference,
        this.protiens,
        this.quantityUnit,
        this.restrictedFor,
        this.sodium,
        this.sugar,
        this.timingsFor,
        this.totalCarbohydrate,
        this.totalFat,
        this.transfattyAcid,
        this.saturatedFat,
        this.iron,
        this.item,
        this.calories,
        this.vitaminA,
        this.notes,
        this.vitaminC,
        this.partitionKey,
        this.rowKey,
        this.timestamp,
        this.eTag,
    });

    String ihlId;
    String additionalRegion;
    String userIngredientId1;
    String userIngredientId2;
    String amount;
    String amountUnit;
    String calcium;
    String colesterol;
    String fiber;
    String monounsaturatedFats;
    String polyunsaturatedFats;
    String potassium;
    String preference;
    String protiens;
    String quantityUnit;
    String restrictedFor;
    String sodium;
    String sugar;
    String timingsFor;
    String totalCarbohydrate;
    String totalFat;
    String transfattyAcid;
    String saturatedFat;
    String iron;
    String item;
    String calories;
    String vitaminA;
    String notes;
    String vitaminC;
    String partitionKey;
    String rowKey;
    String timestamp;
    String eTag;

    factory ListCustomIngredient.fromJson(Map<String, dynamic> json) => ListCustomIngredient(
        ihlId: json["ihl_id"],
        additionalRegion: json["additional_region"].toString(),
        userIngredientId1: json["user_ingredient_id1"],
        userIngredientId2: json["user_ingredient_id2"],
        amount: json["amount"],
        amountUnit: json["amount_unit"],
        calcium: json["calcium"],
        colesterol: json["colesterol"],
        fiber: json["fiber"],
        monounsaturatedFats: json["monounsaturated_fats"],
        polyunsaturatedFats: json["polyunsaturated_fats"],
        potassium: json["potassium"],
        preference: json["preference"],
        protiens: json["protiens"],
        quantityUnit: json["quantity_unit"],
        restrictedFor: json["restricted_for"],
        sodium: json["sodium"],
        sugar: json["sugar"],
        timingsFor: json["timings_for"],
        totalCarbohydrate: json["total_carbohydrate"],
        totalFat: json["total_fat"],
        transfattyAcid: json["transfatty_acid"],
        saturatedFat: json["saturated_fat"],
        iron: json["iron"],
        item: json["item"],
        calories: json["calories"],
        vitaminA: json["vitamin_a"],
        notes: json["notes"],
        vitaminC: json["vitamin_c"],
        partitionKey: json["PartitionKey"],
        rowKey: json["RowKey"],
        timestamp: json["Timestamp"],
        eTag: json["ETag"],
    );

    Map<String, dynamic> toJson() => {
        "ihl_id": ihlId,
        "additional_region": additionalRegion,
        "user_ingredient_id1": userIngredientId1,
        "user_ingredient_id2": userIngredientId2,
        "amount": amount,
        "amount_unit": amountUnit,
        "calcium": calcium,
        "colesterol": colesterol,
        "fiber": fiber,
        "monounsaturated_fats": monounsaturatedFats,
        "polyunsaturated_fats": polyunsaturatedFats,
        "potassium": potassium,
        "preference": preference,
        "protiens": protiens,
        "quantity_unit": quantityUnit,
        "restricted_for": restrictedFor,
        "sodium": sodium,
        "sugar": sugar,
        "timings_for": timingsFor,
        "total_carbohydrate": totalCarbohydrate,
        "total_fat": totalFat,
        "transfatty_acid": transfattyAcid,
        "saturated_fat": saturatedFat,
        "iron": iron,
        "item": item,
        "calories": calories,
        "vitamin_a": vitaminA,
        "notes": notes,
        "vitamin_c": vitaminC,
        "PartitionKey": partitionKey,
        "RowKey": rowKey,
        "Timestamp": timestamp,
        "ETag": eTag,
    };
}
