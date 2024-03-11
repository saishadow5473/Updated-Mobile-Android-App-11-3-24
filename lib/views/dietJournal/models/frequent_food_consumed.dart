// To parse this JSON data, do
//
//     final frequentFoodConsumed = frequentFoodConsumedFromJson(jsonString);

import 'dart:convert';

FrequentFoodConsumed frequentFoodConsumedFromJson(String str) => FrequentFoodConsumed.fromJson(json.decode(str));

String frequentFoodConsumedToJson(FrequentFoodConsumed data) => json.encode(data.toJson());

class FrequentFoodConsumed {
  String status;

  FrequentFoodConsumed({
     this.status,
  });

  factory FrequentFoodConsumed.fromJson(Map<String, dynamic> json) => FrequentFoodConsumed(
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
  };
}
