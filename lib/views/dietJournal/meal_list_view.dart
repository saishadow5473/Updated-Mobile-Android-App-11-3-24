import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:loading_skeleton/loading_skeleton.dart';
import 'package:ihl/views/dietJournal/MealTypeScreen.dart';
import 'package:ihl/views/dietJournal/add_new_meal.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';

class MealsListView extends StatefulWidget {
  final String Screen;

  MealsListView({Key key, this.Screen}) : super(key: key);
  @override
  _MealsListViewState createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView> {
  List<MealsListData> mealsListData = [];
  bool loaded = false;

  void getData() async {
    var listApis = ListApis();
    try {
      await listApis.getUserTodaysFoodLogHistoryApi().then((value) {
        if (mounted) {
          setState(() {
            loaded = true;
            mealsListData = value['food'];
          });
        }
      });
    } catch (e) {
      mealsListData = [
        MealsListData(
          imagePath: 'assets/images/diet/breakfast.png',
          type: 'Breakfast',
          kcal: 0,
          meals: <String>['Log your', 'Meals'],
          foodList: [],
          startColor: '#ed3f18',
          endColor: '#f57f64',
        ),
        MealsListData(
          imagePath: 'assets/images/diet/lunch.png',
          type: 'Lunch',
          kcal: 0,
          meals: <String>['Log your', 'Meals'],
          foodList: [],
          startColor: '#23b6e6',
          // endColor: '#02d39a',
          endColor: '#40E0D0',
        ),
        MealsListData(
          imagePath: 'assets/images/diet/snack.png',
          type: 'Snacks',
          kcal: 0,
          meals: <String>['Log your', 'Meals'],
          foodList: [],
          startColor: '#FE95B6',
          endColor: '#FF5287',
        ),
        MealsListData(
          imagePath: 'assets/images/diet/dinner.png',
          type: 'Dinner',
          kcal: 0,
          meals: <String>['Log your', 'Meals'],
          foodList: [],
          startColor: '#6F72CA',
          endColor: '#1E1466',
        ),
      ];
      loaded = true;
      if (mounted) setState(() {});
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      child: loaded
          ? ListView.builder(
              itemCount: mealsListData.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return MealsView(
                  mealsListData: mealsListData[index],
                  Screen: widget.Screen,
                );
              },
            )
          : ListView.builder(
              itemCount: 4,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) => Padding(
                padding: const EdgeInsets.only(top: 32, left: 8, right: 8, bottom: 12),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(64.0),
                  ),
                  child: LoadingSkeleton(
                    width: 140,
                    colors: [Colors.grey, Colors.grey[300], Colors.grey],
                    height: 100,
                  ),
                ),
              ),
            ),
    );
  }
}

class MealsView extends StatelessWidget {
   MealsView({
    Key key,
    this.mealsListData,this.Screen
  }) : super(key: key);

  final MealsListData mealsListData;
  String Screen;

  // final  foodLogList ;

  String mealNameList(List mealList) {
    if (mealList.length > 3) {
      return '${mealList[0]}\n${mealList[1]}\n+ ${mealList.length - 2} more';
    }
    if (mealList.length == 2) {
      return '${mealList[0].length > 10 ? mealList[0].toString().substring(0, 10) : mealList[0].toString()}\n${mealList[1]}\n';
    }
    return mealList.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print(mealsListData);
        Get.to(MealTypeScreen(
          mealsListData: mealsListData,
          Screen: Screen,
        ));
      },
      child: SizedBox(
        width: mealsListData.kcal.toString().length <= 3
            ? ScUtil().setWidth(140)
            : ScUtil().setWidth(155),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 32, left: 8, right: 8, bottom: 16),
              child: Container(
                height: ScUtil().setHeight(170),
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: HexColor(mealsListData.endColor).withOpacity(0.6),
                        offset: const Offset(1.1, 4.0),
                        blurRadius: 8.0),
                  ],
                  gradient: LinearGradient(
                    colors: <HexColor>[
                      HexColor(mealsListData.startColor),
                      HexColor(mealsListData.endColor),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(54.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 54, left: 16, right: 16, bottom: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AutoSizeText(
                        mealsListData.type,
                        // foodLogList[0].food[0].foodDetails.foodName
                        // foodLogList!=null?(foodLogList.foodTimeCategory.toString()).capitalize():'',
                        textAlign: TextAlign.center,
                        // maxFontSize: ScUtil().setSp(16),
                        minFontSize: ScUtil().setSp(12),
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: ScUtil().setSp(16),
                          letterSpacing: 0.2,
                          color: FitnessAppTheme.white,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: SingleChildScrollView(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    mealNameList(mealsListData.meals),
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: ScUtil().setSp(10),
                                      color: FitnessAppTheme.white,
                                    ),
                                  ),
                                )
                                // ;
                                // })
                              ],
                            ),
                          ),
                        ),
                      ),
                      mealsListData?.kcal != 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  '${mealsListData.kcal}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: ScUtil().setSp(19.5),
                                    letterSpacing: 0.2,
                                    color: FitnessAppTheme.white,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: ScUtil().setWidth(4),
                                    bottom: ScUtil().setHeight(3),
                                  ),
                                  child: Text(
                                    'Cal',
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: ScUtil().setSp(10),
                                      letterSpacing: 0.2,
                                      color: FitnessAppTheme.white,
                                    ),
                                  ),
                                ),
                                mealsListData.kcal.toString().length <= 3
                                    ? const Spacer()
                                    : const SizedBox(
                                        height: 0,
                                        width: 0,
                                      ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: ScUtil().setSp(24),
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: FitnessAppTheme.nearlyWhite,
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: FitnessAppTheme.nearlyBlack.withOpacity(0.4),
                                        offset: const Offset(8.0, 8.0),
                                        blurRadius: 8.0),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    color: HexColor(mealsListData.endColor),
                                    size: ScUtil().setSp(24),
                                  ),
                                  onPressed: () {
                                    Get.to(MealTypeScreen(
                                      mealsListData: mealsListData,
                                      Screen: Screen,
                                    ));
                                    // Get.to(AddFood(
                                    //     mealsListData: mealsListData,
                                    //     cardioNavigate: false));
                                  },
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: ScUtil().setWidth(84),
                height: ScUtil().setHeight(84),
                decoration: BoxDecoration(
                  color: FitnessAppTheme.nearlyWhite.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 8,
              child: SizedBox(
                width: ScUtil().setWidth(80),
                height: ScUtil().setHeight(80),
                child: Hero(tag: mealsListData.meals, child: Image.asset(mealsListData.imagePath)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
