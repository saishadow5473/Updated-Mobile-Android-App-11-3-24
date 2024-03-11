import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/healthJournalControllers/loadFoodList.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import 'customeFoodDetailScreen.dart';
import 'foodDetailScreen.dart';
import '../../../../../views/dietJournal/apis/list_apis.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../views/dietJournal/add_new_meal.dart';
import '../../../../../views/dietJournal/models/view_custom_food_model.dart';
import 'createNewMealScreen.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({
    Key key,
    @required this.selectedDate,
    @required this.mealType,
    @required this.baseColor,
    @required this.mealData,
  }) : super(key: key);

  final baseColor;
  final mealType;
  final selectedDate;
  final mealData;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Future<ListCustomRecipe> getCustomFoodDetail(String foodID) async {
    List<ListCustomRecipe> details = await ListApis.customFoodDetailsApi();
    for (int i = 0; i < details.length; i++) {
      if (details[i].foodId == foodID) {
        return details[i];
      }
    }
  }

  bool submitShow = false;
  final TextEditingController _typeAheadController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode typeAheadFocus = FocusNode();
  bool showText = true;
  bool searchLoad = true;
  final ScrollController _scrollController = ScrollController();

  int start = 20;
  int end = 20;
  String _query = '';
  final ValueNotifier<List<Map<String, dynamic>>> updatedSearchList = ValueNotifier([]);
  bool novalues = false;
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = true;
  bool reponseListEmpty = false;
  final FoodItems foodItemsService = FoodItems();

  // Debounced search method
  void _onSearchTextChanged(String value) {
    if (value.isNotEmpty) {
      if (!submitShow || !searchLoad) {
        setState(() {
          submitShow = true;
          searchLoad = true;
        });
      }

      _debounce(() async {
        List<Map<String, dynamic>> list = await foodItemsService.getSuggestions(value, 1, 10);
        _query = value;
        searchResults = list;

        // searchResults.sort((a, b) =>
        //     (a['dish'] ?? a["dish_name"]).length.compareTo((b['dish'] ?? ["dish_name"]).length));
        updatedSearchList.value.clear();
        updatedSearchList.value.addAll(searchResults);
        setState(() {
          searchLoad = false;
        });
      });
    } else {
      setState(() {
        submitShow = false;
      });
    }
  }

// Debounce function
  void _debounce(VoidCallback callback) {
    const Duration debounceDuration = Duration(seconds: 2);
    if (_debounceTimer != null) {
      _debounceTimer.cancel();
    }
    _debounceTimer = Timer(debounceDuration, callback);
  }

// Remember to define _debounceTimer as a class-level variable
  Timer _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() async {
      // print(_scrollController.position.atEdge);
      if (_scrollController.position.atEdge) {
        if (!novalues) {
          start = end + 1;
          end = end + 10;
        }

        List<Map<String, dynamic>> ss = await foodItemsService.getSuggestions(_query, start, end);

        searchResults.addAll(ss);
        updatedSearchList.value = searchResults;
        updatedSearchList.notifyListeners();

        searchResults.toSet().toList();

        if (ss.isEmpty) {
          novalues = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            Get.back();
          }, //replaces the screen to Main dashboard
          color: Colors.white,
        ),
        title: Padding(padding: EdgeInsets.only(left: 15.w), child: const Text("Search Food")),
        backgroundColor: widget.baseColor,
      ),
      content: SizedBox(
        height: 100.h,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 5.h),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: TextField(
                              onTap: () {},

                              onChanged: _onSearchTextChanged,
                              autofocus: true,
                              showCursor: true,
                              readOnly: false,
                              controller: _typeAheadController,
                              decoration: const InputDecoration(
                                hintText: 'Search Food or Meal',
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
                    Visibility(
                      visible: _typeAheadController.text == "" || searchResults.isNotEmpty,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text("If can't find food in the list?"),
                        TextButton(
                            onPressed: () {
                              Get.to(NewMeal(
                                baseColor: widget.baseColor,
                                mealType: widget.mealType,
                                mealName: "",
                                Qunatity: "0.25",
                                QuantityUnits: "",
                              ));
                              // Get.to(CreateNewMealScreen(
                              //   mealType: widget.mealData,
                              // ));
                            },
                            child: Text(
                              "Add New",
                              style: TextStyle(color: widget.baseColor),
                            ))
                      ]),
                    ),
                    Visibility(
                      visible: submitShow,
                      child: searchLoad
                          ? Column(
                              children: [
                                Shimmer.fromColors(
                                    direction: ShimmerDirection.ltr,
                                    period: const Duration(seconds: 2),
                                    baseColor: const Color.fromARGB(255, 240, 240, 240),
                                    highlightColor: Colors.grey.withOpacity(0.2),
                                    child: Container(
                                        margin: const EdgeInsets.all(8),
                                        width: 75.w,
                                        height: .5.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text('Hello'))),
                                SizedBox(
                                  height: 59.5.h,
                                )
                              ],
                            )
                          : Column(
                              children: [
                                SizedBox(
                                    height: 64.h,
                                    child: _typeAheadController.text != null &&
                                            searchResults.isEmpty
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: 1.h),
                                              const Text("No Result Found"),
                                              Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Text("If can't find food in the list?"),
                                                    TextButton(
                                                        onPressed: () {
                                                          Get.to(NewMeal(
                                                            baseColor: widget.baseColor,
                                                            mealType: widget.mealType,
                                                            mealName: "",
                                                            Qunatity: "0.25",
                                                            QuantityUnits: "",
                                                          ));
                                                          // Get.to(CreateNewMealScreen(
                                                          //   mealType: widget.mealData,
                                                          // ));
                                                        },
                                                        child: Text(
                                                          "Add New",
                                                          style: TextStyle(color: widget.baseColor),
                                                        ))
                                                  ])
                                            ],
                                          )
                                        : ValueListenableBuilder<List<Map<String, dynamic>>>(
                                            valueListenable: updatedSearchList,
                                            builder: (_, List<Map<String, dynamic>> val, __) {
                                              return val.isNotEmpty
                                                  ? SizedBox(
                                                      height: 40.h,
                                                      child: SingleChildScrollView(
                                                        controller: _scrollController,
                                                        child: Column(
                                                          children:
                                                              val.map((Map<String, dynamic> e) {
                                                            return ListTile(
                                                              leading: SizedBox(
                                                                width: 70.w,
                                                                child: Text(e["dish"] != null
                                                                    ? "${e["dish"].replaceAll('&amp;', '&')}"
                                                                        .capitalize
                                                                    : "${e["dish_name"].replaceAll('&amp;', '&')}"
                                                                        .capitalize),
                                                              ),
                                                              trailing: Icon(
                                                                Icons.add,
                                                                color: widget.baseColor,
                                                                size: 20.sp,
                                                              ),
                                                              onTap: () async {
                                                                String selectedDateTemp;
                                                                if (widget
                                                                        .selectedDate.runtimeType ==
                                                                    DateTime) {
                                                                  selectedDateTemp = DateFormat(
                                                                          'yyyy-MM-dd')
                                                                      .format(widget.selectedDate);
                                                                }
                                                                if (e["food_item_id"].length < 20) {
                                                                  Get.delete<
                                                                      FoodDataLoaderController>();

                                                                  Get.to(FoodDetailScreen(
                                                                    foodId: e["food_item_id"],
                                                                    title: e["dish"] != null
                                                                        ? "${e["dish"]}".capitalize
                                                                        : "${e["dish_name"]}"
                                                                            .capitalize,
                                                                    mealType: widget.mealType,
                                                                    mealData: widget.mealData,
                                                                    baseColor: widget.baseColor,
                                                                    logDate: widget.selectedDate
                                                                                .runtimeType ==
                                                                            DateTime
                                                                        ? selectedDateTemp
                                                                        : widget.selectedDate,
                                                                  ));
                                                                } else {
                                                                  Get.delete<
                                                                      CustomeFoodDataLoaderController>();
                                                                  Get.to(CustomeFoodDetailScreen(
                                                                    foodName: e["dish"] != null
                                                                        ? "${e["dish"]}".capitalize
                                                                        : "${e["dish_name"]}"
                                                                            .capitalize,
                                                                    foodId: e["food_item_id"],
                                                                    mealType: widget.mealType,
                                                                    mealData: widget.mealData,
                                                                    baseColor: widget.baseColor,
                                                                    logDate: widget.selectedDate
                                                                                .runtimeType ==
                                                                            DateTime
                                                                        ? selectedDateTemp
                                                                        : widget.selectedDate,
                                                                  ));
                                                                }
                                                              },
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    )
                                                  : Container();
                                            })),
                              ],
                            ),
                    ),
                    Visibility(
                        visible: !submitShow,
                        child: Container(
                          height: 60.h,
                        )),
                  ],
                ),
              ),
              // Container(
              //   height: 10.h,
              // )
            ],
          ),
        ),
      ),
    );
  }
}
