import 'package:get/get.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../../../views/dietJournal/models/food_list_tab_model.dart';

class FoodDetailController extends GetxController {
  var foodData = [];
  List<FoodListTileModel> favList = [];
  List<FoodListTileModel> customFoodlist = [];
  List<FoodListTileModel> mealsListData = [];
  List<String> bookmarks = [];

  var favFoods;
  RxBool dataLoded = true.obs;
  @override
  void onInit() {
    super.onInit();
    getFoodDetails();
    getUserCustmeFoodDetail();
    getBookMarkedFoodDetail();
  }

  getFoodDetails() async {
    await ListApis().getUserTodaysFoodLogHistoryApi().then((value) {
      mealsListData = value['food'][0].foodList;
    });
    update();
  }

  getBookMarkedFoodDetail() async {
    var details = await ListApis.bookmarkedFoodDetailsApi();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("bookmarked_food");
    List<String> bookmarks = [];
    for (int i = 0; i < details.length; i++) {
      bool exists =
          favList.any((fav) => fav.foodItemID == (details[i] != null ? details[i].foodItemId : ''));
      if (!exists) {
        if (details[i] != null) {
          bookmarks.add(details[i].foodItemId);
          // favList.add(details[i].foodItemId as FoodListTileModel);

          prefs.setStringList("bookmarked_food", bookmarks);
          if (details[i].foodItemId.length > 20) {
            await ListApis.customFoodDetailsApi().then((data) {
              data.forEach((element) {
                if (element.foodId == details[i].foodItemId) {
                  favList.add(FoodListTileModel(
                    foodItemID: element.foodId,
                    title: element.dish,
                    subtitle:
                        "${element.quantity ?? 1} ${camelize(element.servingUnitSize ?? 'Nos')} | ${element.calories ?? 0} Cal",
                  ));
                } else {}
              });
            });
          } else {
            await ListApis.updatedGetFoodDetails(foodID: details[i].foodItemId).then((data) {
              favList.add(FoodListTileModel(
                foodItemID: data.foodId,
                title: data.dish,

                ///old subtitle
                ///"${details[i].quantity ?? 1} ${camelize(details[i].quantityUnit)} | ${details[i].calories} kCal",
                subtitle:
                    "${data.quantity ?? 1} ${camelize(data.servingUnitSize ?? 'Nos')} | ${data.calories ?? 0} Cal",
              ));
            });
          }
        }
      }
    }
    update(['FoodDetailsScreen']);
  }

  deleteBookMarkedDetail(String foodid) async {
    var details = await ListApis.bookmarkedFoodDetailsApi();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("bookmarked_food");
    // List<String> bookmarks = [];
    // for (int i = 0; i < details.length; i++) {
    //   // bool _exist = favList.contains((element))
    //   bool exists = favList.any((fav) =>
    //   fav.foodItemID == (details[i] == null ? 'details[i].foodItemId' : ''));
    //   if (!exists) {
    //     if (details[i] != null) {
    //       bookmarks.remove(details[i].foodItemId);
    //
    //       prefs.setStringList("bookmarked_food", bookmarks);
    //     }
    //   }
    // }

    // favList.any((fav) { fav.foodItemID == foodid  ? favList.remove(foodid): 'rgdd';});
    favList.removeWhere((element) => element.foodItemID == foodid);
    // favList.forEach((element) => bookmarks.remove(element.foodItemID));
    // prefs.setStringList("bookmarked_food", bookmarks);
    // prefs.setStringList("bookmarked_food", favList.cast<String>());
    // prefs.setStringList("bookmarked_food", bookmarks);
    // if (exists) {
    //   if (details[i] != null) {
    //     bookmarks.remove(details[i].foodItemId);
    //     prefs.setStringList("bookmarked_food", bookmarks);
    //
    //   }
    //
    // }
    update(['FoodDetailsScreen']);
  }

  getUserCustmeFoodDetail() async {
    var details = await ListApis.customFoodDetailsApi();
    customFoodlist = [];
    for (int i = 0; i < details.length; i++) {
      bool exists = customFoodlist.any((fav) => fav.foodItemID == details[i].rowKey);
      if (!exists) {
        customFoodlist.add(FoodListTileModel(
            foodItemID: details[i].rowKey,
            title: details[i].dish,
            subtitle:
                "${camelize(details[i].quantity ?? '1 Nos.')} ${camelize(details[i].servingUnitSize ?? 'Nos.')} | ${double.parse(details[i].calories).toInt()} Cal",
            extras: details[i]));
      }
    }
    update(["Custome food widget"]);
  }
}
