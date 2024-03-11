import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/models/food_list_tab_model.dart';
import 'package:ihl/views/dietJournal/custom_food_detail.dart';
import 'package:loading_skeleton/loading_skeleton.dart';
import 'package:strings/strings.dart';

import '../../new_design/presentation/controllers/healthJournalControllers/loadFoodList.dart';

class CustomFoodTab extends StatefulWidget {
  final MealsListData mealType;
  const CustomFoodTab({Key key, this.mealType}) : super(key: key);

  @override
  _CustomFoodTabState createState() => _CustomFoodTabState();
}

class _CustomFoodTabState extends State<CustomFoodTab> {
  List<FoodListTileModel> customFoodlist = [];
  bool loaded = false;
  bool empty = false;

  @override
  void initState() {
    super.initState();
    getCustomFoodList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getCustomFoodList() async {
    var details = await ListApis.customFoodDetailsApi();

    for (int i = 0; i < details.length; i++) {
      bool exists = customFoodlist.any((fav) => fav.foodItemID == details[i].rowKey);
      if (!exists) {
        print(details[i].toJson());
        customFoodlist.add(FoodListTileModel(
            foodItemID: details[i].rowKey,
            title: details[i].dish,
            subtitle:
                "${camelize(details[i].quantity ?? '1 Nos.')} ${camelize(details[i].servingUnitSize ?? 'Nos.')} | ${details[i].calories} Cal",
            extras: details[i]));
      }
    }
    if (customFoodlist.isNotEmpty) {
      if (this.mounted) {
        setState(() {
          loaded = true;
          print(customFoodlist);
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
                itemCount: customFoodlist.length,
                itemBuilder: (BuildContext context, int index) => ListTile(
                  title: Text(
                    customFoodlist[index].title ?? 'Name Unknown',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                  subtitle: Text(
                    customFoodlist[index].subtitle,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                  /*leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20))),
                        child:
                            Image.network('https://static.vecteezy.com/system/resources/previews/000/463/565/non_2x/healthy-food-clipart-vector.jpg', fit: BoxFit.contain,)),
                  ),*/
                  onTap: () {
                    Get.delete<FoodDataLoaderController>();
                    Get.to(CustomFoodDetailScreen(
                      customFoodlist[index].extras,
                      mealType: widget.mealType,
                    ));
                  },
                ),
              ),
            )
          : Container(
              child: Center(
                child: Text(
                  'No Custom Food.\nContinue adding meals to see more here.',
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
            animationEnd: AnimationEnd.EXTREMELY_ON_TOP,
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
