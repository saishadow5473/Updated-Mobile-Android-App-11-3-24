import 'dart:convert';


FoodListTileModel listFoodDetailFromJson(String str) => FoodListTileModel.fromJson(json.decode(str));

String listFoodDetailToJson(FoodListTileModel data) => json.encode(data.toJson());

List<FoodListTileModel> listFoodDetailListFromJson(String str) => List<FoodListTileModel>.from(json.decode(str).map((x) => x == null ? null : FoodListTileModel.fromJson(x)));

String listFoodDetailListToJson(List<FoodListTileModel> data) => json.encode(List<dynamic>.from(data.map((x) => x == null ? null : x.toJson())));

class FoodListTileModel {
  String foodItemID;
  String title;
  String subtitle;
  String foodTime;
  int epochTime;
  String quantity;
  String quantityUnit;
  String foodLogId;
  dynamic extras;

  FoodListTileModel({this.foodLogId,this.foodItemID, this.title, this.subtitle, this.foodTime='',this.epochTime, this.quantity='', this.quantityUnit='Nos.', this.extras});

  FoodListTileModel.empty() :
    foodItemID = '',
    title = '',
    subtitle = '';
    
  factory FoodListTileModel.fromJson(Map<String, dynamic> json) => FoodListTileModel(
        foodItemID: json['foodItemID'],
        title: json['title'],
        foodLogId:json['log_id'],
        subtitle: json["subtitle"],
        foodTime: json["food_time"],
        epochTime: json["epoch_time"],
        quantity: json["quantity"],
        quantityUnit: json["quantity_unit"],
        extras: json['extras']
    );

    Map<String, dynamic> toJson() => {
        "foodItemID": foodItemID,
        "title": title,
        "subtitle": subtitle,
        "food_time":foodTime,
        "epoch_time":epochTime,
        "quantity": quantity,
        "quantity_unit":quantityUnit,
        "extras":extras
    };

}