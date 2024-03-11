import 'package:flutter/material.dart';

class SearchFoodModel{
 final String dish,calories,foodItem_id,item;

  SearchFoodModel({@required this.dish,@required this.calories,@required this.foodItem_id,@required this.item});
  factory SearchFoodModel.fromJson(Map<String, dynamic> map)=>SearchFoodModel(dish: map['dish'], calories: map['calories'], foodItem_id: map['food_item_id'], item: map['item']);
}