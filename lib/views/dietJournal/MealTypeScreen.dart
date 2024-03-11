import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/new_design/presentation/controllers/healthJournalControllers/foodDetailController.dart';
import 'package:ihl/new_design/presentation/controllers/healthJournalControllers/getTodayLogController.dart';
import 'package:ihl/new_design/presentation/pages/manageHealthscreens/healthJournalScreens/editCusFoodLog.dart';
import 'package:ihl/new_design/presentation/pages/manageHealthscreens/healthJournalScreens/editfoodlog.dart';
import 'package:ihl/new_design/presentation/pages/manageHealthscreens/healthJournalScreens/foodLog1.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/title_widget.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../new_design/presentation/controllers/dashboardControllers/dashBoardContollers.dart';
import 'dietJournalNew.dart';
import 'models/food_list_tab_model.dart';

class MealTypeScreen extends StatefulWidget {
  final MealsListData mealsListData;
  final mealData;
  final String Screen;

  MealTypeScreen({Key key, this.mealData, this.mealsListData, @required this.Screen})
      : super(key: key);

  @override
  _MealTypeScreenState createState() => _MealTypeScreenState();
}

class _MealTypeScreenState extends State<MealTypeScreen> {
  var _controller = ScrollController();
  bool _isVisible = true;
  ScrollController _scrollController = ScrollController();
  List<FoodListTileModel> filteredFoodList;
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels > 0) {
          if (_isVisible) {
            if (this.mounted) {
              setState(() {
                _isVisible = false;
              });
            }
          }
        }
      } else {
        if (!_isVisible) {
          if (this.mounted) {
            setState(() {
              _isVisible = true;
            });
          }
        }
      }
    });
    try {
      Get.put(FoodDetailController());
    } catch (e) {
      debugPrint(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    List<FoodListTileModel> originalList = widget.mealsListData.foodList;

    // Remove duplicates
    filteredFoodList = removeDuplicates(originalList, (FoodListTileModel map) => map.foodItemID);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () async {
        TabBarController _ = Get.find<TabBarController>();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (widget.Screen == "home") {
          prefs.setBool("naviFromCardio", false);
          Get.back();
          Get.back();
          _.updateSelectedIconValue(value: "Home");
        } else if (widget.Screen == "cardio") {
          Get.back();
        } else {
          Get.to(DietJournalNew());
        }
      },
      child: Scaffold(
          body: SafeArea(
            child: Container(
              color: AppColors.bgColorTab,
              child: CustomPaint(
                painter: BackgroundPainter(
                    // primary: HexColor('#23b6e9').withOpacity(0.8),
                    primary: HexColor(widget.mealsListData.startColor).withOpacity(0.8),
                    secondary: HexColor(widget.mealsListData.startColor)),
                // startColor: '#23b6e6',
                // endColor: '#02d39a',
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 30,
                          child: SizedBox(
                            width: ScUtil().setWidth(80),
                            height: ScUtil().setHeight(80),
                            child: Hero(
                                tag: widget.mealsListData.meals,
                                child: Image.asset(widget.mealsListData.imagePath)),
                          ),
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  IconButton(
                                      icon: const Icon(Icons.arrow_back_ios),
                                      color: Colors.white,
                                      onPressed: () async {
                                        TabBarController _ = Get.find<TabBarController>();
                                        Get.put(TodayLogController());
                                        SharedPreferences prefs =
                                            await SharedPreferences.getInstance();
                                        if (widget.Screen == "home") {
                                          prefs.setBool("naviFromCardio", false);
                                          Get.back();
                                          Get.back();
                                          _.updateSelectedIconValue(value: "Home");
                                        } else if (widget.Screen == "cardio") {
                                          Get.back();
                                        } else {
                                          Get.to(DietJournalNew());
                                        }
                                      }),
                                  SizedBox(
                                    width: ScUtil().setWidth(40),
                                  ),
                                ],
                              ),
                              Container(
                                height: ScUtil().setHeight(30),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(left: 40),
                        child: Text(
                          widget.mealsListData.type,
                          textAlign: TextAlign.left,
                          // style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500,color: Colors.white),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32.0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: FoodTitleView(
                                      titleTxt: 'Summary of Today',
                                      subTxt: '',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Card(
                                      elevation: 2,
                                      shadowColor: FitnessAppTheme.nearlyWhite,
                                      borderOnForeground: true,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(4),
                                          ),
                                          side: BorderSide(
                                            width: 1,
                                            color: FitnessAppTheme.nearlyWhite,
                                          )),
                                      color: FitnessAppTheme.white,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Calories added",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: ScUtil().setSp(16),
                                                  ),
                                                ),
                                                Text(
                                                  "${widget.mealsListData.kcal} Cal",
                                                  style: TextStyle(
                                                    color:
                                                        HexColor(widget.mealsListData.startColor),
                                                    fontSize: ScUtil().setSp(18),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Foods Logged",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: ScUtil().setSp(16),
                                                  ),
                                                ),
                                                widget.mealsListData.foodList.length == 1 ||
                                                        widget.mealsListData.foodList.isEmpty
                                                    ? Text(
                                                        "${widget.mealsListData.foodList.isNotEmpty ? widget.mealsListData.foodList.length : '0'} item",
                                                        style: TextStyle(
                                                          color: HexColor(
                                                              widget.mealsListData.startColor),
                                                          fontSize: ScUtil().setSp(18),
                                                        ),
                                                      )
                                                    : Text(
                                                        "${widget.mealsListData.foodList.isNotEmpty ? widget.mealsListData.foodList.length : '0'} items",
                                                        style: TextStyle(
                                                          color: HexColor(
                                                              widget.mealsListData.startColor),
                                                          fontSize: ScUtil().setSp(18),
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                                    child: FoodTitleView(
                                      titleTxt: 'Foods you have logged',
                                      subTxt: '',
                                    ),
                                  ),
                                  widget.mealsListData.kcal != 0
                                      ? SizedBox(
                                          height: ScUtil().setHeight(
                                              widget.mealsListData.foodList.length * 68 ?? 550),
                                          child: Scrollbar(
                                            controller: _scrollController,
                                            child: ListView.builder(
                                                controller: _scrollController,
                                                // physics:
                                                //     NeverScrollableScrollPhysics(),
                                                padding: const EdgeInsets.all(0),
                                                itemCount: filteredFoodList.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  String dateTimeString =
                                                      filteredFoodList[index].foodTime;

                                                  DateTime dateTime =
                                                      DateFormat('dd-MM-yyyy HH:mm:ss')
                                                          .parse(dateTimeString);

                                                  String formattedTime =
                                                      DateFormat('hh:mm a').format(dateTime);
                                                  return ListTile(
                                                    title: Text(
                                                      filteredFoodList[index].title,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                          letterSpacing: 0.5),
                                                    ),
                                                    subtitle: Text(
                                                      filteredFoodList[index].subtitle,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          letterSpacing: 0.5),
                                                    ),
                                                    /*leading: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                      child: Image.network(
                                                          'https://static.vecteezy.com/system/resources/previews/000/463/565/non_2x/healthy-food-clipart-vector.jpg',
                                                          fit: BoxFit.contain)),
                                                ),*/
                                                    trailing: Text(
                                                      'Today $formattedTime',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          letterSpacing: 0.5),
                                                    ),
                                                    onTap: () {
                                                      if (filteredFoodList[index]
                                                              .foodItemID
                                                              .length <
                                                          20) {
                                                        Get.to(EditFoodLog(
                                                          foodId:
                                                              filteredFoodList[index].foodItemID,
                                                          mealType: widget.mealsListData.type,
                                                          mealData: widget.mealData,
                                                          logedData: filteredFoodList[index],
                                                          bgcolor: widget.mealsListData.type
                                                                      .toLowerCase() !=
                                                                  'lunch'
                                                              ? HexColor(
                                                                  widget.mealsListData.endColor)
                                                              : AppColors.primaryAccentColor,
                                                          foodLogId: filteredFoodList[index]
                                                              .foodLogId
                                                              .replaceRange(0, 1, ""),
                                                        ));
                                                      } else {
                                                        Get.to(CustomEditFoodLog(
                                                          foodId:
                                                              filteredFoodList[index].foodItemID,
                                                          mealType: widget.mealsListData.type,
                                                          mealData: widget.mealData,
                                                          logedData:
                                                              widget.mealsListData.foodList[index],
                                                          bgcolor: widget.mealsListData.type
                                                                      .toLowerCase() !=
                                                                  'lunch'
                                                              ? HexColor(
                                                                  widget.mealsListData.endColor)
                                                              : AppColors.primaryAccentColor,
                                                          foodLogId: filteredFoodList[index]
                                                              .foodLogId
                                                              .replaceRange(0, 1, ""),
                                                        ));
                                                      }
                                                    },
                                                  );
                                                }),
                                          ),
                                        )
                                      : Container(
                                          height: ScUtil().setHeight(240),
                                          width: double.infinity,
                                          margin: const EdgeInsets.all(10.0),
                                          child: Card(
                                              elevation: 5,
                                              shadowColor: FitnessAppTheme.nearlyWhite,
                                              borderOnForeground: true,
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(4),
                                                  ),
                                                  side: BorderSide(
                                                    width: 1,
                                                    color: FitnessAppTheme.nearlyWhite,
                                                  )),
                                              color: FitnessAppTheme.white,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Image.network(
                                                      'https://i.postimg.cc/Bb0jC1Js/diet-1.png'),
                                                  SizedBox(height: ScUtil().setHeight(10)),
                                                  const Text(
                                                    'No Food Logged for today!',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontFamily: FitnessAppTheme.fontName,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 18,
                                                      letterSpacing: 0.5,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ),
                                  Container(
                                    height: 2.h,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Visibility(
            visible: _isVisible,
            child: FloatingActionButton.extended(
                onPressed: () {
                  // Get.to(AddFood(
                  //   mealsListData: widget.mealsListData,
                  //   cardioNavigate: widget.cardioNavigate,
                  // ));

                  Get.to(
                    LogFoodLanding(
                        Screen: widget.Screen,
                        mealType: widget.mealsListData.type,
                        mealData: widget.mealData,
                        frequentFood: [],
                        bgColor: widget.mealsListData.type.toLowerCase() != 'lunch'
                            ? HexColor(widget.mealsListData.endColor)
                            : AppColors.primaryAccentColor),
                  );
                },
                backgroundColor: widget.mealsListData.type.toLowerCase() != 'dinner'
                    ? HexColor(widget.mealsListData.endColor)
                    : HexColor('#6F72CA'),
                // backgroundColor: HexColor('#6F72CA'),
                label: Text(widget.mealsListData.kcal != 0 ? 'Add another food' : 'Start Logging !',
                    style:
                        const TextStyle(fontWeight: FontWeight.w600, color: FitnessAppTheme.white)),
                icon: const Icon(Icons.set_meal, color: FitnessAppTheme.white)),
          )),
    );
  }

  List<FoodListTileModel> removeDuplicates(
      List<FoodListTileModel> list, dynamic Function(FoodListTileModel) getKey) {
    Set<dynamic> seen = {};
    List<FoodListTileModel> temp;

    temp = list.where((FoodListTileModel map) => seen.add(getKey(map))).toList();
    temp.sort((a, b) => a.title.compareTo(b.title));
    return temp;
  }
}
