// To parse this JSON data, do
//
//     final getFrequentFoodConsumed = getFrequentFoodConsumedFromJson(jsonString);

import 'dart:convert';

GetFrequentFoodConsumed getFrequentFoodConsumedFromJson(String str) => GetFrequentFoodConsumed.fromJson(json.decode(str));

String getFrequentFoodConsumedToJson(GetFrequentFoodConsumed data) => json.encode(data.toJson());

class GetFrequentFoodConsumed {
  List<FreqStatus> status;

  GetFrequentFoodConsumed({
     this.status,
  });

  factory GetFrequentFoodConsumed.fromJson(Map<String, dynamic> json) => GetFrequentFoodConsumed(
    status: List<FreqStatus>.from(json["status"].map((x) => FreqStatus.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": List<dynamic>.from(status.map((x) => x.toJson())),
  };
}

class FreqStatus {
  String frequentFoodLogId;
  String userId;
  String category;
  List<dynamic> listOfFoodLogs;

  FreqStatus({
     this.frequentFoodLogId,
     this.userId,
     this.category,
     this.listOfFoodLogs,
  });

  factory FreqStatus.fromJson(Map<String, dynamic> json) => FreqStatus(
    frequentFoodLogId: json["frequent_food_log_id"],
    userId: json["user_id"],
    category: json["category"],
    listOfFoodLogs: List<dynamic>.from(json["list_of_food_logs"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "frequent_food_log_id": frequentFoodLogId,
    "user_id": userId,
    "category": category,
    "list_of_food_logs": List<dynamic>.from(listOfFoodLogs.map((x) => x)),
  };
}

enum Category {
  BREAKFAST,
  CATEGORY_BREAKFAST,
  FOOD
}



class ListOfFoodLogClass {
  String foodId;
  String quantity;
  String name;

  ListOfFoodLogClass({
     this.foodId,
     this.quantity,
     this.name,
  });

  factory ListOfFoodLogClass.fromJson(Map<String, dynamic> json) => ListOfFoodLogClass(
    foodId: json["food_id"],
    quantity: json["quantity"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "food_id": foodId,
    "quantity": quantity,
    "name": name,
  };
}


