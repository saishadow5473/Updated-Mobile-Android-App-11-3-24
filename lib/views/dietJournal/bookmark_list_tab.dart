import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/food_detail.dart';
import 'package:loading_skeleton/loading_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../new_design/presentation/controllers/healthJournalControllers/loadFoodList.dart';
import 'models/food_list_tab_model.dart';

class BookmarkTab extends StatefulWidget {
  final MealsListData mealType;
  const BookmarkTab({Key key, this.mealType}) : super(key: key);

  @override
  _BookmarkTabState createState() => _BookmarkTabState();
}

class _BookmarkTabState extends State<BookmarkTab> {
  List<FoodListTileModel> favList = [];
  bool loaded = false;
  bool empty = false;

  @override
  void initState() {
    super.initState();
    getBookmarkList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getBookmarkList() async {
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
          // favList.add(FoodListTileModel(
          //   foodItemID: foodDetails[i].foodItemId,
          //   title: foodDetails[i].name,
          //
          //   ///old subtitle
          //   ///"${details[i].quantity ?? 1} ${camelize(details[i].quantityUnit)} | ${details[i].calories} kCal",
          //   subtitle:
          //       "${foodDetails[i].quantity ?? 1} ${camelize(foodDetails[i].quantityUnit ?? 'Nos')} | ${foodDetails[i].calories ?? 0} kCal",
          // ));
          print(favList);
        }
      }
    }
    if (favList.isNotEmpty) {
      if (this.mounted) {
        setState(() {
          loaded = true;
          print(favList);
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          loaded = true;
          empty = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loaded) {
      return !empty
          ? Padding(
              padding: EdgeInsets.only(left: ScUtil().setWidth(35)),
              child: ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: favList.length,
                itemBuilder: (BuildContext context, int index) => ListTile(
                  title: Text(
                    favList[index].title ?? 'Name Unknown',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                  subtitle: Text(
                    favList[index].subtitle,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                  /*leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20))),
                        child: Image.network(
                            'https://static.vecteezy.com/system/resources/previews/000/463/565/non_2x/healthy-food-clipart-vector.jpg',
                            fit: BoxFit.fill)),
                  ),*/
                  onTap: () {
                    Get.delete<FoodDataLoaderController>();
                    Get.to(FoodDetailScreen(
                      favList[index].foodItemID,
                      mealtype: widget.mealType,
                    ));
                  },
                ),
              ),
            )
          : Container(
              child: Center(
                child: Text(
                  'No Favorite food bookmarked.\nContinue bookmarking meals to see more here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: 4,
        itemBuilder: (BuildContext context, int index) => ListTile(
          title: LoadingSkeleton(
            width: 100,
            height: 20,
            colors: [Colors.grey, Colors.grey[300], Colors.grey],
            margin: EdgeInsets.only(right: 120),
          ),
          subtitle: LoadingSkeleton(
            width: 200,
            height: 10,
            colors: [Colors.grey, Colors.grey[300], Colors.grey],
            margin: EdgeInsets.only(right: 80),
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: LoadingSkeleton(
              width: 50,
              height: 50,
              colors: [Colors.grey, Colors.grey[300], Colors.grey],
            ),
          ),
          onTap: () {},
        ),
      );
    }
  }
}
