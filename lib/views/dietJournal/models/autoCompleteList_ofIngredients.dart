
//     final autoCompleteListOfIngredient = autoCompleteListOfIngredientFromJson(jsonString);

import 'dart:convert';

List<AutoCompleteListOfIngredient> autoCompleteListOfIngredientFromJson(String str) => List<AutoCompleteListOfIngredient>.from(json.decode(str).map((x) => AutoCompleteListOfIngredient.fromJson(x)));

String autoCompleteListOfIngredientToJson(List<AutoCompleteListOfIngredient> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AutoCompleteListOfIngredient {
    AutoCompleteListOfIngredient({
        this.itemName,
        this.calories,
        this.foodItemId,
    });

    String itemName;
    String calories;
    String foodItemId;

    factory AutoCompleteListOfIngredient.fromJson(Map<String, dynamic> json) => AutoCompleteListOfIngredient(
        itemName: json["item_name"],
        calories: json["calories"],
        foodItemId: json["food_item_id"],
    );

    Map<String, dynamic> toJson() => {
        "item_name": itemName,
        "calories": calories,
        "food_item_id": foodItemId,
    };
}
