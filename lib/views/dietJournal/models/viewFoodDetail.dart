// To parse this JSON data, do
//
//     final ViewFoodDetail = viewFoodDetailFromJson(jsonString);

import 'dart:convert';

ViewFoodDetail viewFoodDetailFromJson(String str) =>
    ViewFoodDetail.fromJson(json.decode(str));

String viewFoodDetailToJson(ViewFoodDetail data) => json.encode(data.toJson());

class ViewFoodDetail {
  ViewFoodDetail({
    this.additionalRegion = '-',
    this.amount,
    this.calcium = '-',
    this.calories = '-',
    this.colesterol = '-',
    this.fiber = '-',
    this.id1,
    this.id2,
    this.iorn = '-',
    this.item = 'Unknown Meal',
    this.monounsaturatedFats = '-',
    this.polyunsaturatedFats = '-',
    this.potassium = '-',
    this.preference = '-',
    this.protiens = '-',
    this.quanity = '-',
    this.quantityUnit,
    this.saturatedFat = '-',
    this.sodium = '-',
    this.sugar = '-',
    this.timingsFor = '-',
    this.restrictedFor,
    this.totalCarbohydrate = '-',
    this.totalFat = '-',
    this.transfattyAcid = '-',
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
  String amount;
  String calcium;
  String calories;
  String colesterol;
  String fiber;
  String id1;
  String id2;
  String iorn;
  String item;
  String monounsaturatedFats;
  String polyunsaturatedFats;
  String potassium;
  String preference;
  String protiens;
  String quanity;
  String quantityUnit;
  String saturatedFat;
  String sodium;
  String sugar;
  String timingsFor;
  String restrictedFor;
  String totalCarbohydrate;
  String totalFat;
  String transfattyAcid;
  String vitaminA;
  String vitaminC;
  String partitionKey;
  String rowKey;
  String timestamp;
  String eTag;
  Map<String, dynamic> foodDetails;
  ///for new data var -
  Map<String, dynamic> servingSize;
  ///
  // String servingSize;
  String foodName;

  factory ViewFoodDetail.fromJson(Map<String, dynamic> json) => ViewFoodDetail(
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
        // item: json["item"],
        monounsaturatedFats: json["monounsaturated_fats"] == ''
            ? '0'
            : json["monounsaturated_fats"],
        polyunsaturatedFats: json["polyunsaturated_fats"] == ''
            ? '0'
            : json["polyunsaturated_fats"],
        potassium: json["potassium"] == '' ? '0' : json["potassium"],
        preference: json["preference"],
        protiens: json["protiens"] == '' ? '0' : json["protiens"],
    ///quantity  new  start
        // quanity: jsonDecode(json["serving_size"]
        //                 .toString()
        //                 .replaceAll('&quot;', '"'))['serving_qty']
        //             .toString() ==
        //         ''
        //     ? '1 Serving'
        //     : jsonDecode(json["serving_size"]
        //             .toString()
        //             .replaceAll('&quot;', '"'))['serving_qty']
        //         .toString(),
    ///quantity  new end
    ///quantity  old start
    quanity: jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['value'].toString() == ''
    // quanity: json["quantity"].toString() == ''
            ? '1 '
            : jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['value'].toString(),
            // : json["quantity"].toString(),
    ///quantity  old end
    ///quantity Unit new start
    //     quantityUnit: jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['serving_unit'] == 'number'
    //         ? 'Nos.'
    //         : jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['serving_unit'],
    ///quantity Unit new end
    ///quantity Unit old start
    quantityUnit: jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['unit'] == 'number'
    // quantityUnit: json["quantity_unit"].toString() == 'number'
        ? 'Nos.'
        : jsonDecode(json["serving_size"].toString().replaceAll('&quot;', '"'))['unit'],
        // : json["quantity_unit"].toString(),
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
        ///new serving start
        servingSize: jsonDecode(
            json["serving_size"].toString().replaceAll('&quot;', '"')),
       ///new serving end
    /// old serving start
    // servingSize: json["serving_size"].toString(),
    /// old serving end
    foodName: json["food_name"],
    // foodName: json["item"],
      );

  Map<String, dynamic> toJson() => {
        "additional_region": additionalRegion,
        "amount": amount,
        "calcium": calcium,
        "calories": calories,
        "colesterol": colesterol,
        "fiber": fiber,
        "id1": id1,
        "id2": id2,
        "iorn": iorn,
        "item": item,
        "monounsaturated_fats": monounsaturatedFats,
        "polyunsaturated_fats": polyunsaturatedFats,
        "potassium": potassium,
        "preference": preference,
        "protiens": protiens,
        "quanity": quanity,
        "quantity_unit": quantityUnit,
        "saturated_fat": saturatedFat,
        "sodium": sodium,
        "sugar": sugar,
        "timings_for": timingsFor,
        "restricted_for": restrictedFor,
        "total_carbohydrate": totalCarbohydrate,
        "total_fat": totalFat,
        "transfatty_acid": transfattyAcid,
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
  quantityConverting(String value) {
    var parsedString = value.replaceAll('&quot', '"');
    var jPar = jsonDecode(parsedString);
    String valuefinal = jPar['value'];
    return valuefinal;
  }
}
