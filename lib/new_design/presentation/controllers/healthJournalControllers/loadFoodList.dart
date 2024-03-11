import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/manageHealthscreens/healthJournalScreens/caloriesCalculation.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/models/food_deatils_updated.dart';
import 'package:ihl/views/dietJournal/models/view_custom_food_model.dart';
import 'package:strings/strings.dart';

import '../../../../views/dietJournal/models/food_list_tab_model.dart';
import '../../../../views/dietJournal/models/food_unit_detils.dart';
import '../../pages/manageHealthscreens/healthJournalScreens/customeFoodDetailScreen.dart';
import '../../pages/manageHealthscreens/healthJournalScreens/foodDetailScreen.dart'
    as foodNutrientsListner;

class FoodDataLoaderController extends GetxController {
  final String foodID;
  UpdatedFoodDetails foodDetail;
  List<ListCustomRecipe> customeFoodDetail;
  FoodDataLoaderController(this.foodID);
  List<GetFoodUnit> foodUnit;
  List<FoodListTileModel> recentList = SpUtil.getRecentObjectList('recent_food') ?? [];
  void onInit() {
    getFoodDetail(foodID);
    super.onInit();
  }

  getFoodUnit(itemId) async {
    foodUnit = await ListApis.getFoodUnit(itemId);
  }

  getFoodDetail(String foodId) async {
    foodDetail = await ListApis.updatedGetFoodDetails(foodID: foodId);
    await getFoodUnit(foodDetail.item);
    await SpUtil.getInstance();
    try {
      bool exists = recentList.any((fav) => fav.foodItemID == foodDetail.foodId);
      if (!exists) {
        recentList.add(FoodListTileModel(
          foodItemID: foodDetail.foodId,
          title: foodDetail.dish,
          subtitle:
              "${foodDetail.quantity ?? 1} ${camelize(foodDetail.servingUnitSize ?? 'Nos.')} | ${foodDetail.calories ?? 0} Cal",
          // subtitle: "${foodDetail.servingSize['serving_qty'] ?? 1} ${camelize(foodDetail.servingSize['serving_unit'])} | ${foodDetail.calories??0} kCal",
        ));
      }

      //SpUtil.putReactiveRecentObjectList(recentList);
      SpUtil.putRecentObjectList('recent_food', recentList);
    } catch (e) {
      print(e);
      SpUtil.putRecentObjectList('recent_food', recentList);
    }
    foodNutrientsListner.InitialMealCaloriesCalc.calories =
        ValueNotifier<double>(double.parse(foodDetail.calories));
    // var quantity = num.parse(foodDetail.quantity);
    // var quantityUnit = foodDetail.servingUnitSize;
    // var fixedCalories = num.parse(foodDetail.calories);
    // var fixedQuantity = num.parse(foodDetail.quantity);
    // var servingType = foodDetail.servingUnitSize.toString();
    var nutrionData = CaloriesCalc().calculateNutrients(
      num.parse(foodDetail.carbs),
      num.parse(foodDetail.fiber),
      num.parse(foodDetail.fats),
      num.parse(foodDetail.protein),
      num.parse(foodDetail.quantity),
      num.parse(foodDetail.quantity),
    );
    foodNutrientsListner.InitialMealNutriCalculations.nutrients.value = nutrionData;
    update(["FoodData"]);
  }
}

class CustomeFoodDataLoaderController extends GetxController {
  final String foodID;
  ListCustomRecipe customeFoodDetail;
  CustomeFoodDataLoaderController(this.foodID);
  void onInit() {
    getCustomFoodDetail(foodID);
    super.onInit();
  }

  getCustomFoodDetail(String foodID) async {
    var cusDetail = await ListApis.customFoodDetailsApi();
    for (int i = 0; i < cusDetail.length; i++) {
      if (cusDetail[i].foodId == foodID) {
        customeFoodDetail = cusDetail[i];
      }
    }

    var protein = double.parse(customeFoodDetail.protein);
    var fats = double.parse(customeFoodDetail.fats);
    var fiber = double.parse(customeFoodDetail.fiber);
    var carbs = double.parse(customeFoodDetail.carbs);
    var quantity = double.parse(customeFoodDetail.quantity);
    var fixedQuantity = double.parse(customeFoodDetail.quantity);
    var fixedCalories = double.parse(customeFoodDetail.calories);
    InitialMealCaloriesCalc.calories = ValueNotifier<double>(fixedCalories);
    var nutrionData = CaloriesCalc().calculateNutrients(
      carbs,
      fiber,
      fats,
      protein,
      quantity,
      quantity,
    );
    InitialMealNutriCalculations.nutrients.value = nutrionData;
    update(["CusFoodData"]);
  }
}
