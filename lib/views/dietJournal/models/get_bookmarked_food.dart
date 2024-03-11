import 'dart:convert';

List<GetBookMarkedFood> getBookMarkedFoodFromJson(String str) =>
    List<GetBookMarkedFood>.from(json.decode(str).map((x) => GetBookMarkedFood.fromJson(x)));

String getBookMarkedFoodToJson(List<GetBookMarkedFood> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetBookMarkedFood {
  GetBookMarkedFood({
    this.userId,
    this.foodItemId,
  });

  String userId;
  String foodItemId;

  factory GetBookMarkedFood.fromJson(Map<String, dynamic> json) => GetBookMarkedFood(
        userId: json["user_id"],
        foodItemId: json["food_item_id"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "food_item_id": foodItemId,
      };
}
