import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/custom_food_detail.dart';
import 'package:ihl/views/dietJournal/models/view_custom_food_model.dart';
import 'package:ihl/views/dietJournal/models/food_list_tab_model.dart';
import 'package:loading_skeleton/loading_skeleton.dart';
import 'package:ihl/views/dietJournal/food_detail.dart';
import 'package:ihl/utils/SpUtil.dart';

import '../../new_design/presentation/controllers/healthJournalControllers/loadFoodList.dart';

class RecentsTab extends StatefulWidget {
  final MealsListData mealType;
  final bool showText;
  const RecentsTab({Key key, this.mealType, this.showText}) : super(key: key);

  @override
  _RecentsTabState createState() => _RecentsTabState();
}

class _RecentsTabState extends State<RecentsTab> {
  List<FoodListTileModel> recentList = [];
  bool loaded = false;
  bool empty = false;

  @override
  void initState() {
    super.initState();
    getRecentList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getRecentList() async {
    await SpUtil.getInstance();
    recentList = SpUtil.getRecentObjectList('recent_food') ?? [];
    if (recentList.isNotEmpty) {
      setState(() {
        loaded = true;
      });
    } else {
      setState(() {
        loaded = true;
        empty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: false);
    if (loaded) {
      return !empty
          ? Padding(
              padding: EdgeInsets.only(left: ScUtil().setWidth(35)),
              child: ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: recentList.length,
                itemBuilder: (BuildContext context, int index) => ListTile(
                  title: Text(
                    recentList[index].title ?? 'Name Unknown',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                  subtitle: Text(
                    recentList[index].subtitle,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
//leading: SizedBox(width: ScUtil().setWidth(0.5),),
                  /*leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20))),
                        child:
                            Image.network('https://static.vecteezy.com/system/resources/previews/000/463/565/non_2x/healthy-food-clipart-vector.jpg', fit:BoxFit.contain)),
                  ),*/
                  onTap: () {
                    if (recentList[index].foodItemID.substring(0, 3) == "cus") {
                      Get.to(CustomFoodDetailScreen(
                        ListCustomRecipe.fromJson(recentList[index].extras),
                        mealType: widget.mealType,
                      ));
                    } else {
                      Get.delete<FoodDataLoaderController>();
                      Get.to(FoodDetailScreen(
                        recentList[index].foodItemID,
                        mealtype: widget.mealType,
                      ));
                    }
                  },
                ),
              ),
            )
          : Container(
              child: Center(
                child: Text(
                  'No Recents\nContinue browsing foods to see more here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: widget.showText ? AppColors.appItemTitleTextColor : Colors.white),
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
