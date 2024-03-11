// To parse this JSON data, do
//
//     final createEditIngredient = createEditIngredientFromJson(jsonString);

import 'dart:convert';

CreateEditIngredient createEditIngredientFromJson(String str) => CreateEditIngredient.fromJson(json.decode(str));

String createEditIngredientToJson(CreateEditIngredient data) => json.encode(data.toJson());

class CreateEditIngredient {
    CreateEditIngredient({
        this.ihlUserId,
        this.additionalRegion,
        this.calcium,
        this.calories,
        this.colesterol,
        this.fiber,
        this.id1,
        this.iorn,
        this.item,
        this.monounsaturatedFats,
        this.polyunsaturatedFats,
        this.potassium,
        this.preference,
        this.protiens,
        this.quanity,
        this.saturatedFat,
        this.sodium,
        this.sugar,
        this.timingsFor,
        this.totalCarbohydrate,
        this.totalFat,
        this.transfattyAcid,
        this.partitionKey,
        this.rowKey,
        this.timestamp,
        this.eTag,
    });

    String ihlUserId;
    String additionalRegion;
    String calcium;
    String calories;
    String colesterol;
    String fiber;
    String id1;
    String iorn;
    String item;
    String monounsaturatedFats;
    String polyunsaturatedFats;
    String potassium;
    String preference;
    String protiens;
    String quanity;
    String saturatedFat;
    String sodium;
    String sugar;
    String timingsFor;
    String totalCarbohydrate;
    String totalFat;
    String transfattyAcid;
    String partitionKey;
    String rowKey;
    String timestamp;
    String eTag;

    factory CreateEditIngredient.fromJson(Map<String, dynamic> json) => CreateEditIngredient(
        ihlUserId: json["ihl_user_id"],
        additionalRegion: json["additional_region"].toString(),
        calcium: json["calcium"],
        calories: json["calories"],
        colesterol: json["colesterol"],
        fiber: json["fiber"],
        id1: json["id1"],
        iorn: json["iorn"],
        item: json["item"],
        monounsaturatedFats: json["monounsaturated_fats"],
        polyunsaturatedFats: json["polyunsaturated_fats"],
        potassium: json["potassium"],
        preference: json["preference"],
        protiens: json["protiens"],
        quanity: json["quanity"],
        saturatedFat: json["saturated_fat"],
        sodium: json["sodium"],
        sugar: json["sugar"],
        timingsFor: json["timings_for"],
        totalCarbohydrate: json["total_carbohydrate"],
        totalFat: json["total_fat"],
        transfattyAcid: json["transfatty_acid"],
        partitionKey: json["PartitionKey"],
        rowKey: json["RowKey"],
        timestamp: json["Timestamp"],
        eTag: json["ETag"],
    );

    Map<String, dynamic> toJson() => {
        "ihl_user_id": ihlUserId,
        "additional_region": additionalRegion,
        "calcium": calcium,
        "calories": calories,
        "colesterol": colesterol,
        "fiber": fiber,
        "id1": id1,
        "iorn": iorn,
        "item": item,
        "monounsaturated_fats": monounsaturatedFats,
        "polyunsaturated_fats": polyunsaturatedFats,
        "potassium": potassium,
        "preference": preference,
        "protiens": protiens,
        "quanity": quanity,
        "saturated_fat": saturatedFat,
        "sodium": sodium,
        "sugar": sugar,
        "timings_for": timingsFor,
        "total_carbohydrate": totalCarbohydrate,
        "total_fat": totalFat,
        "transfatty_acid": transfattyAcid,
        "PartitionKey": partitionKey,
        "RowKey": rowKey,
        "Timestamp": timestamp,
        "ETag": eTag,
    };
}
