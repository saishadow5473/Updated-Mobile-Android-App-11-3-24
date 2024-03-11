// To parse this JSON data, do
//
//     final listUserFood = listUserFoodFromJson(jsonString);

import 'dart:convert';

List<ListUserFood> listUserFoodFromJson(String str) => List<ListUserFood>.from(json.decode(str).map((x) => x == null ? null : ListUserFood.fromJson(x)));

String listUserFoodToJson(List<ListUserFood> data) => json.encode(List<dynamic>.from(data.map((x) => x == null ? null : x.toJson())));

ListUserFood listFoodDetailFromJson(String str) => ListUserFood.fromJson(json.decode(str));

String listFoodDetailToJson(ListUserFood data) => json.encode(data.toJson());


class ListUserFood {
    ListUserFood({
        this.additionalRegion,
        this.id1,
        this.id2,
        this.amount,
        this.calcium,
        this.colesterol,
        this.fiber,
        this.monounsaturatedFats,
        this.polyunsaturatedFats,
        this.potassium,
        this.preference,
        this.protiens,
        this.quantity,
        this.quantityUnit,
        this.restrictedFor,
        this.sodium,
        this.sugar,
        this.timingsFor,
        this.totalCarbohydrate,
        this.totalFat,
        this.transfattyAcid,
        this.saturatedFat,
        this.iorn,
        this.item,
        this.calories,
        this.vitaminA,
        this.vitaminC,
        this.partitionKey,
        this.rowKey,
        this.timestamp,
        this.eTag,
        this.foodDetails,
        this.servingSize,
        this.foodName,
    });

    String additionalRegion;
    String id1;
    String id2;
    String amount;
    String calcium;
    String colesterol;
    String fiber;
    String monounsaturatedFats;
    String polyunsaturatedFats;
    String potassium;
    String preference;
    String protiens;
    String quantity;
    String quantityUnit;
    String restrictedFor;
    String sodium;
    String sugar;
    String timingsFor;
    String totalCarbohydrate;
    String totalFat;
    String transfattyAcid;
    String saturatedFat;
    String iorn;
    String item;
    String calories;
    String vitaminA;
    String vitaminC;
    String partitionKey;
    String rowKey;
    String timestamp;
    String eTag;
    Map<String, dynamic> foodDetails;
    String servingSize;
    String foodName;

    factory ListUserFood.fromJson(Map<String, dynamic> json) => ListUserFood(
        additionalRegion: json["additional_region"].toString(),
        amount: json['amount'],
        calcium: json["calcium"] == '' ? '0' : json["calcium"],
        calories: json["calories"] == '' ? '0' : json["calories"],
        colesterol: json["colesterol"] == '' ? '0' : json["colesterol"],
        fiber: json["fiber"] == '' ? '0' : json["fiber"],
        id1: json["id1"],
        id2: json["id2"],
        iorn: json["iorn"] == '' ? '0' : json["iorn"],
        item: json["food_name"],
        monounsaturatedFats: json["monounsaturated_fats"] == ''
            ? '0'
            : json["monounsaturated_fats"],
        polyunsaturatedFats: json["polyunsaturated_fats"] == ''
            ? '0'
            : json["polyunsaturated_fats"],
        potassium: json["potassium"] == '' ? '0' : json["potassium"],
        preference: json["preference"],
        protiens: json["protiens"] == '' ? '0' : json["protiens"],
        quantity:
        ///old start
        jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['value'].toString() == ''
            ? '1 Serving'
            : jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['value'].toString(),
        ///old end
        ///new start
        // jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['serving_qty'].toString() == ''
        //     ? '1 Serving'
        //     : jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['serving_qty'].toString(),
        ///new end


        //     .toString(),
        // quantity: jsonDecode(json["serving_size"]
        //     .toString()
        //     .replaceAll('&quot;', '"'))['value']
        //     .toString() ==
        //     ''
        //     ? '1 Serving'
        //     : jsonDecode(json["serving_size"]
        //     .toString()
        //     .replaceAll('&quot;', '"'))['value']
        //     .toString(),
        //
        ///quantity Unit new  start
        // quantityUnit: jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['serving_unit'].toString() == 'null'
        //     ? 'Nos.'
        //     : jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['serving_unit'],
        ///quantity Unit new end

        ///quantity Unit old  start
        quantityUnit: jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['unit'] == 'number'
            ? 'Nos.'
            : jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['unit'],
        ///quantity Unit old end
        saturatedFat: json["saturated_fat"] == '' ? '0' : json["saturated_fat"],
        sodium: json["sodium"] == '' ? '0' : json["sodium"],
        sugar: json["sugar"] == '' ? '0' : json["sugar"],
        timingsFor: json["timings_for"],
        restrictedFor: json['restricted_for'],
        totalCarbohydrate:
        json["total_carbohydrate"] == '' ? '0' : json["total_carbohydrate"],
        totalFat: json["total_fat"] == '' ? '0' : json["total_fat"],
        transfattyAcid: json["transfatty_acid"],
        vitaminA: json['vitamin_a'],
        vitaminC: json['vitamin_c'],
        partitionKey: json["PartitionKey"],
        rowKey: json["RowKey"],
        timestamp: json["Timestamp"],
        eTag: json["ETag"],
        foodDetails: jsonDecode(
            json["food_details"].toString().replaceAll('&quot;', '"')),
        servingSize: json["serving_size"],
        foodName: json["food_name"],
    );

    Map<String, dynamic> toJson() => {
        "additional_region": additionalRegion,
        "id1": id1,
        "id2": id2,
        "amount": amount,
        "calcium": calcium,
        "colesterol": colesterol,
        "fiber": fiber,
        "monounsaturated_fats": monounsaturatedFats,
        "polyunsaturated_fats": polyunsaturatedFats,
        "potassium": potassium,
        "preference": preference,
        "protiens": protiens,
        "quantity": quantity,
        "quantity_unit": quantityUnit,
        "restricted_for": restrictedFor,
        "sodium": sodium,
        "sugar": sugar,
        "timings_for": timingsFor,
        "total_carbohydrate": totalCarbohydrate,
        "total_fat": totalFat,
        "transfatty_acid": transfattyAcid,
        "saturated_fat": saturatedFat,
        "iorn": iorn,
        "item": item,
        "calories": calories,
        "vitamin_a": vitaminA,
        "vitamin_c": vitaminC,
        "PartitionKey": partitionKey,
        "RowKey": rowKey,
        "Timestamp": timestamp,
        "ETag": eTag,
        "food_details": foodDetails,
        "serving_size": servingSize,
        "foodName": foodName
    };
}
