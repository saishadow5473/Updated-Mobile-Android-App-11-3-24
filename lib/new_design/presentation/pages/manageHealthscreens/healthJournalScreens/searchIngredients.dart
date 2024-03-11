// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/apigeeregistry/v1.dart';
import 'package:ihl/new_design/data/providers/network/networks.dart';
import 'package:ihl/new_design/presentation/pages/manageHealthscreens/healthJournalScreens/caloriesCalculation.dart';
import 'package:ihl/new_design/presentation/pages/manageHealthscreens/healthJournalScreens/newIngredient.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/models/view_custom_food_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/api.dart';
import '../../../../../views/dietJournal/search_ingrident.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import 'ingredientDetailedScreen.dart';

class SearchIngredient extends StatefulWidget {
  const SearchIngredient(
      {Key key,
      @required this.mealData,
      this.recipeDetails,
      @required this.editMeal,
      @required this.mealType,
      @required this.baseColor,@required this.selectedQuantity})
      : super(key: key);
  final dynamic baseColor;
  final dynamic mealType;
  final dynamic selectedQuantity;
  final ListCustomRecipe recipeDetails;
  final dynamic mealData;
  final bool editMeal;

  @override
  State<SearchIngredient> createState() => _SearchIngredientState();
}

class _SearchIngredientState extends State<SearchIngredient> {
  List<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[];
  final ScrollController _scrollController = ScrollController();
  int start = 1;
  int end = 20;
  String _query = '';
  final ValueNotifier<List<Map<String, dynamic>>> updatedSearchList =
      ValueNotifier<List<Map<String, dynamic>>>(<Map<String, dynamic>>[]);
  bool novalues = false;
  bool valueNotFound = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() async {
      // print(_scrollController.position.atEdge);
      if (_scrollController.position.atEdge) {
        if (!novalues) {
          start = end + 1;
          end = end + 20;
          //created empty map to display the shimmer while fecthing the paginations 🥚
          updatedSearchList.value += <Map<String, dynamic>>[<String, dynamic>{}];
          List<Map<String, dynamic>> ss =
              await IngridientItems.getSuggestions(_query, start, end) ?? <dynamic>[];

          searchResults.addAll(ss);
          updatedSearchList.value = searchResults;
          updatedSearchList.notifyListeners();
          searchResults.toSet().toList();
          updatedSearchList.value
              .removeWhere((Map<String, dynamic> element) => element == <String, dynamic>{});

          if (ss.isEmpty) {
            novalues = true;
          }
        } else {
          log("No more values");
        }
      }
    });
  }

  getIngredientDetails(String ingredientId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final dynamic response = await dio.post('${API.iHLUrl}/foodjournal/view_all_ingredient_detail',
        data: json.encode(
          {"food_id": ingredientId},
        ),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ));

    if (response.statusCode == 200) {
      dynamic food = response.data['message'];
      return food;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return true;
      },
      child: CommonScreenForNavigation(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              Get.back();
            }, //replaces the screen to Main dashboard
            color: Colors.white,
          ),
          title: const Text("Search Ingredients"),
          centerTitle: true,
          backgroundColor: widget.baseColor,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 5.h),
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {},
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            onTap: () {},
                            onChanged: (String value) async {
                              valueNotFound = true;
                              updatedSearchList.value = <Map<String, dynamic>>[];
                              debounce(() async {
                                List<Map<String, dynamic>> list =
                                    await IngridientItems.getSuggestions(value, 1, 20);
                                start = 1;
                                end = 20;
                                novalues = false;
                                _query = value;
                                searchResults = list;
                                updatedSearchList.value.addAll(searchResults);
                                valueNotFound = false;
                                updatedSearchList.notifyListeners();
                              });
                            },
                            autofocus: true,
                            showCursor: true,
                            readOnly: false,
                            // controller: _typeAheadController,
                            decoration: const InputDecoration(
                              hintText: 'Search Ingredients',
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                              border: InputBorder.none,
                            ),
                            // onSubmitted: (_) => _performSearch(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.sp,
                  ),
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: updatedSearchList,
                      builder: (_, List<Map<String, dynamic>> val, __) {
                        if (val.isEmpty && controller.text.isNotEmpty && valueNotFound) {
                          return Shimmer.fromColors(
                              direction: ShimmerDirection.ltr,
                              period: const Duration(seconds: 2),
                              baseColor: const Color.fromARGB(255, 240, 240, 240),
                              highlightColor: Colors.grey.withOpacity(0.2),
                              child: Container(
                                  margin: const EdgeInsets.all(8),
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width / 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text('Hello')));
                        }
                        if (val.isEmpty && controller.text.isNotEmpty && valueNotFound == false) {
                          return InkWell(
                            onTap: () {
                              FocusScopeNode currentFocus = FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute<dynamic>(
                                    builder: (BuildContext context) => AddNewIngredient(
                                          baseColor: widget.baseColor,
                                          editMeal: widget.editMeal,
                                        )),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Add New Ingredient  ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black, fontSize: 17.5.sp),
                                ),
                                Icon(
                                  Icons.add,
                                  color: widget.baseColor,
                                  size: 19.sp,
                                )
                              ],
                            ),
                          );
                        }
                        return Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top: 20.sp),
                              child: Column(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                      if (!currentFocus.hasPrimaryFocus) {
                                        currentFocus.unfocus();
                                      }
                                      Navigator.of(context).push(
                                        MaterialPageRoute<dynamic>(
                                            builder: (BuildContext context) => AddNewIngredient(
                                                  baseColor: widget.baseColor,
                                                  editMeal: widget.editMeal,
                                                )),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          'Add New Ingredient  ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.black, fontSize: 17.5.sp),
                                        ),
                                        Icon(
                                          Icons.add,
                                          color: widget.baseColor,
                                          size: 19.sp,
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10.sp, right: 10.sp),
                              height: 59.5.h,
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                    scrollbarTheme: ScrollbarThemeData(
                                  thumbVisibility: MaterialStateProperty.all(true),
                                  radius: const Radius.circular(5),
                                  thumbColor: MaterialStateProperty.all(widget.baseColor),
                                )),
                                child: Scrollbar(
                                  controller: _scrollController,
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      children: val.map((Map<String, dynamic> e) {
                                        if (e.isEmpty) {
                                          return Padding(
                                            padding: EdgeInsets.all(1.h),
                                            child: Shimmer.fromColors(
                                                direction: ShimmerDirection.ltr,
                                                period: const Duration(seconds: 2),
                                                baseColor: const Color.fromARGB(255, 240, 240, 240),
                                                highlightColor: Colors.grey.withOpacity(0.2),
                                                child: Container(
                                                    width: 80.w,
                                                    height: 3.h,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: const Text('Hello'))),
                                          );
                                        }
                                        return GestureDetector(
                                          onTap: () async {
                                            dynamic foodid;
                                            if (!e.keys.contains('food_id')) {
                                              foodid = e['food_item_id'];
                                            } else {
                                              foodid = e['food_id'];
                                            }
                                            dynamic nutrionInfo =
                                                await getIngredientDetails(foodid);
                                            // var foodQuantity =
                                            //     await ListApis.getFoodUnit(e['item']);
                                            num totalCalories = CaloriesCalc().calculateCalories(
                                                num.parse(nutrionInfo[0]['quantity']),
                                                num.parse(nutrionInfo[0]['calories']),
                                                num.parse(nutrionInfo[0]['quantity']));
                                            Map<dynamic, dynamic> nutrionData =
                                                CaloriesCalc().calculateNutrients(
                                              num.parse(nutrionInfo[0]['carbs']),
                                              num.parse(nutrionInfo[0]['fiber']),
                                              num.parse(nutrionInfo[0]['fats']),
                                              num.parse(nutrionInfo[0]['protein'] ?? '0'),
                                              num.parse(nutrionInfo[0]['quantity']),
                                              num.parse(nutrionInfo[0]['quantity']),
                                            );
                                            // ignore: non_constant_identifier_names
                                            String item_id = nutrionInfo[0]["item"];
                                            IngredientCaloriesCalc.calories.value = totalCalories;
                                            IngredientNutriCalculations.nutrients.value =
                                                nutrionData;
                                            // ignore: use_build_context_synchronously
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute<dynamic>(
                                                    builder: (BuildContext context) =>
                                                        IngredientDetailedScreen(
                                                          selectedQuantity: widget.selectedQuantity,
                                                          nutrionInfoList: nutrionInfo,
                                                          IngredientName:
                                                              e['ingredient'] ?? e['dish_name'],
                                                          fixedQuantity: nutrionInfo[0]['quantity'],
                                                          screen: 'search',
                                                          baseColor: widget.baseColor,
                                                          ingredientID: foodid,
                                                          recipeDetails: widget.recipeDetails,
                                                          mealType: widget.mealType,
                                                          mealData: widget.mealData,
                                                          editMeal: widget.editMeal,
                                                          item_id: item_id,
                                                        )));
                                            //  Get.to(IngredientDetailedScreen);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    bottom:
                                                        BorderSide(color: Colors.grey.shade100))),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                SizedBox(width: 5.w),
                                                SizedBox(
                                                    width: 68.w,
                                                    child: Text(e['ingredient'] ?? e['dish_name'])),
                                                const Spacer(),
                                                const Text(
                                                  '+',
                                                  style: TextStyle(
                                                      fontSize: 26, color: Color(0xffEE6143)),
                                                ),
                                                SizedBox(width: 5.w),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Timer _debounceTimer;

  void debounce(VoidCallback callback) {
    const Duration debounceDuration = Duration(seconds: 2);
    if (_debounceTimer != null) {
      _debounceTimer.cancel();
    }
    _debounceTimer = Timer(debounceDuration, callback);
  }
}
