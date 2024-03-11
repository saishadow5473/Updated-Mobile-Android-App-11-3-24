import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/new_design/presentation/controllers/healthJournalControllers/loadFoodList.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalScrollessBasicPageUI.dart';
import 'package:ihl/views/dietJournal/MealTypeScreen.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/bookmark_list_tab.dart';
import 'package:ihl/views/dietJournal/create_new_meal.dart';
import 'package:ihl/views/dietJournal/custom_food_list_tab.dart';
import 'package:ihl/views/dietJournal/food_detail.dart';
import 'package:ihl/views/dietJournal/models/view_custom_food_model.dart';
import 'package:ihl/views/dietJournal/recents_list_tab.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'controllers/selected_food_controller.dart';
import 'custom_food_detail.dart';

class AddFood extends StatefulWidget {
  final MealsListData mealsListData;
  final int selectedpage;
  final cardioNavigate;

  const AddFood({
    Key key,
    this.mealsListData,
    this.selectedpage,
    this.cardioNavigate,
  }) : super(key: key);

  @override
  _AddFoodState createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final TextEditingController _typeAheadController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode typeAheadFocus =  FocusNode();
  bool showText = true;
  bool searchLoad = true;
  final ScrollController _scrollController = ScrollController();
  final FoodItems foodItemsService = FoodItems();
  int start = 20;
  int end = 20;
  String _query = '';
  final ValueNotifier<List<Map<String, dynamic>>> updatedSearchList = ValueNotifier([]);
  bool novalues = false;
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = true;
  bool reponseListEmpty = false;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() async {
      // print(_scrollController.position.atEdge);
      if (_scrollController.position.atEdge) {
        if (!novalues) {
          start = end + 1;
          end = end + 20;
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

  Future<ListCustomRecipe> getCustomFoodDetail(String foodID) async {
    List<ListCustomRecipe> details = await ListApis.customFoodDetailsApi();
    for (int i = 0; i < details.length; i++) {
      if (details[i].foodId == foodID) {
        return details[i];
      }
    }
  }

  Widget selectedfoodItems() {
    return GetX<SelectedFoodController>(
      init: SelectedFoodController(),
      builder: (SelectedFoodController controller) {
        return controller.foodList.isNotEmpty
            ? Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.foodList.length,
                  itemBuilder: (BuildContext context, int index) => ListTile(
                    title: Text(
                      controller.foodList[index].title ?? 'Name Unknown',
                      style:
                          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                    subtitle: Text(
                      controller.foodList[index].subtitle,
                      style:
                          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                          height: 50,
                          width: 50,
                          decoration:
                              const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                          child: Image.network('https://picsum.photos/id/1080/50/')),
                    ),
                    onTap: () {
                      Get.delete<FoodDataLoaderController>();
                      Get.to(FoodDetailScreen(
                        controller.foodList[index].foodItemID,
                        mealtype: widget.mealsListData,
                      ));
                    },
                  ),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        widget.cardioNavigate
            ? Navigator.pop(context)
            : Get.offAll(
                MealTypeScreen(
                  mealsListData: widget.mealsListData,
                ),
                predicate: (Route route) => Get.currentRoute == Routes.MealTypeScreen,
                arguments: widget.mealsListData,
                popGesture: true);
      },
      child: DietJournalScrollessBasicPageUI(
        topColor: widget.mealsListData != null
            ? HexColor(widget.mealsListData.startColor)
            : AppColors.primaryAccentColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => widget.cardioNavigate
                ? Navigator.pop(context)
                : Get.offAll(
                    MealTypeScreen(
                      mealsListData: widget.mealsListData,
                    ),
                    predicate: (Route route) => Get.currentRoute == Routes.MealTypeScreen,
                    arguments: widget.mealsListData,
                    popGesture: true),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
            ),
          ),
          title: AutoSizeText(
            'Log ${widget.mealsListData != null ? widget.mealsListData.type : 'Meal'}',
            style: const TextStyle(fontSize: 23.0, fontWeight: FontWeight.w500, color: Colors.white),
            // style: TextStyle(
            //   color: Colors.white,
            //   fontSize: 20,
            //   fontWeight: FontWeight.bold,
            // ),
          ),
          actions: [
            Container(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.add,
                  color: widget.mealsListData != null
                      ? HexColor(widget.mealsListData.startColor)
                      : AppColors.primaryAccentColor,
                ),
                label: Text(
                  "New",
                  style: TextStyle(
                    color: widget.mealsListData != null
                        ? HexColor(widget.mealsListData.startColor)
                        : AppColors.primaryAccentColor,
                  ),
                ),
                onPressed: () => Get.to(CreateNewMealScreen(
                  mealType: widget.mealsListData,
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                ),
              ),
            )
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: DefaultTabController(
          length: 3,
          initialIndex: widget.selectedpage ?? 0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  alignment: Alignment.topLeft,
                  child: Form(
                    key: _formKey,
                    child: Theme(
                      data: ThemeData(
                        primaryColor: widget.mealsListData != null
                            ? HexColor(widget.mealsListData.startColor)
                            : AppColors.primaryAccentColor,
                        focusColor: widget.mealsListData != null
                            ? HexColor(widget.mealsListData.startColor)
                            : AppColors.primaryAccentColor,
                      ),
                      // child: TypeAheadFormField(
                      //   // hideOnError: true,
                      //   // // hideOnLoading: fl,
                      //   // hideOnEmpty: true,
                      //
                      //   getImmediateSuggestions: false,
                      //   hideSuggestionsOnKeyboardHide: false,
                      //   textFieldConfiguration: TextFieldConfiguration(
                      //       focusNode: typeAheadFocus,
                      //       cursorColor: HexColor(widget.mealsListData.startColor),
                      //       controller: this._typeAheadController,
                      //       onTap: () {
                      //         showText = false;
                      //         Future.delayed(Duration(seconds: 1), () {
                      //           if (mounted) setState(() {});
                      //         });
                      //       },
                      //       onSubmitted: (val) {
                      //         showText = true;
                      //         Future.delayed(Duration(seconds: 1), () {
                      //           if (mounted) setState(() {});
                      //         });
                      //       },
                      //       decoration: InputDecoration(
                      //         labelStyle: typeAheadFocus.hasPrimaryFocus
                      //             ? TextStyle(
                      //                 color: widget.mealsListData != null
                      //                     ? HexColor(widget.mealsListData.startColor)
                      //                     : AppColors.primaryAccentColor,
                      //               )
                      //             : TextStyle(),
                      //         focusedBorder: OutlineInputBorder(
                      //           borderSide: BorderSide(
                      //             color: widget.mealsListData != null
                      //                 ? HexColor(widget.mealsListData.startColor)
                      //                 : AppColors.primaryAccentColor,
                      //           ),
                      //           borderRadius: const BorderRadius.all(
                      //             const Radius.circular(30.0),
                      //           ),
                      //         ),
                      //         border: new OutlineInputBorder(
                      //           borderSide: BorderSide(
                      //             color: widget.mealsListData != null
                      //                 ? HexColor(widget.mealsListData.startColor)
                      //                 : AppColors.primaryAccentColor,
                      //           ),
                      //           borderRadius: const BorderRadius.all(
                      //             const Radius.circular(30.0),
                      //           ),
                      //         ),
                      //         floatingLabelBehavior: FloatingLabelBehavior.never,
                      //         hintText: 'Search Food or Meal',
                      //         prefixIcon: Padding(
                      //           padding: const EdgeInsetsDirectional.only(start: 8, end: 8.0),
                      //           child: Icon(
                      //             Icons.search,
                      //             color: widget.mealsListData != null
                      //                 ? HexColor(widget.mealsListData.startColor)
                      //                 : AppColors.primaryAccentColor,
                      //           ),
                      //         ),
                      //       )),
                      //   suggestionsCallback: (pattern) async {
                      //     if (pattern == '') {
                      //       showText = true;
                      //       Future.delayed(Duration(seconds: 1), () {
                      //         if (mounted) setState(() {});
                      //       });
                      //       return [];
                      //     } else {
                      //       showText = false;
                      //       Future.delayed(Duration(seconds: 1), () {
                      //         if (mounted) setState(() {});
                      //       });
                      //       searchLoad = true;
                      //       var _list = [];
                      //       await FoodItems.getSuggestions(pattern).then((value) {
                      //         searchLoad = false;
                      //         if (value.length > 0) {
                      //           _list = value;
                      //         }
                      //         if (mounted) setState(() {});
                      //       });
                      //
                      //       return _list;
                      //     }
                      //   },
                      //   minCharsForSuggestions: 1,
                      //   itemBuilder: (context, suggestion) {
                      //     return searchLoad
                      //         ? Shimmer.fromColors(
                      //             child: Container(
                      //                 margin: EdgeInsets.all(8),
                      //                 width: MediaQuery.of(context).size.width,
                      //                 height: MediaQuery.of(context).size.width / 5,
                      //                 decoration: BoxDecoration(
                      //                   color: Colors.white,
                      //                   borderRadius: BorderRadius.circular(10),
                      //                 ),
                      //                 child: Text('Hello')),
                      //             direction: ShimmerDirection.ltr,
                      //             period: Duration(seconds: 2),
                      //             baseColor: Colors.white,
                      //             highlightColor: Colors.grey.withOpacity(0.2))
                      //         : suggestion != null
                      //             ? suggestion.length >= 4
                      //                 ? ListTile(
                      //                     title: Text(
                      //                         suggestion['dish'] != "" || suggestion['dish'] != null
                      //                             ? suggestion['dish']
                      //                             : "Food"),
                      //                     subtitle: Text(
                      //                         '${suggestion['calories'] != "" ? suggestion['calories'] : '-'} kCal'),
                      //                   )
                      //                 : ListTile(
                      //                     title: Map<String, dynamic>.from(suggestion)
                      //                             .entries
                      //                             .contains('dish')
                      //                         ? Text(suggestion['dish'] != "" ||
                      //                                 suggestion['dish'] != null
                      //                             ? suggestion['dish']
                      //                             : "Food")
                      //                         : Text(suggestion['dish_name'] != "" ||
                      //                                 suggestion['dish_name'] != null
                      //                             ? suggestion['dish_name']
                      //                             : "Food"),
                      //                     subtitle: Text(
                      //                         '${suggestion['calories'] != "" ? suggestion['calories'] : '-'} kCal'),
                      //                   )
                      //             : ListTile();
                      //   },
                      //   transitionBuilder: (context, suggestionsBox, controller) {
                      //     return suggestionsBox;
                      //   },
                      //   onSuggestionSelected: (suggestion) async {
                      //     this._typeAheadController.text = suggestion['item_name'];
                      //     // SelectedFoodController.to.foodList.add(
                      //     //   FoodListTileModel(
                      //     //       title: camelize(suggestion['item_name']),
                      //     //       subtitle: '1Nos. | ${suggestion['calories']}kCal',
                      //     //       foodItemID: suggestion['food_item_id']),
                      //     // );
                      //     ///old data type
                      //     try {
                      //       if (suggestion['food_item_id'].toString().substring(0, 3) == "cus") {
                      //         var foodDetail =
                      //             await getCustomFoodDetail(suggestion['food_item_id'].toString());
                      //         Get.to(CustomFoodDetailScreen(
                      //           foodDetail,
                      //           mealType: widget.mealsListData,
                      //         ));
                      //       } else {
                      //         Get.to(FoodDetailScreen(
                      //           suggestion['food_item_id'],
                      //           mealtype: widget.mealsListData,
                      //         ));
                      //       }
                      //     } catch (e) {
                      //       print(e.toString());
                      //       Get.to(FoodDetailScreen(
                      //         suggestion['food_item_id'],
                      //         mealtype: widget.mealsListData,
                      //       ));
                      //     }
                      //
                      //     ///the new changes that made
                      //     // if(suggestion['calories']==""||suggestion['calories'].toString()=='null'||suggestion['calories'].toString()=='0') {
                      //     //
                      //     // }else{
                      //     //   if (suggestion['food_item_id'].toString().substring(
                      //     //       0, 3) == "cus") {
                      //     //     var foodDetail = await getCustomFoodDetail(
                      //     //         suggestion['food_item_id'].toString());
                      //     //     Get.to(CustomFoodDetailScreen(
                      //     //       foodDetail,
                      //     //       mealType: widget.mealsListData,
                      //     //     ));
                      //     //   } else {
                      //     //     Get.to(FoodDetailScreen(
                      //     //       suggestion['food_item_id'],
                      //     //       mealtype: widget.mealsListData,
                      //     //     ));
                      //     //   }
                      //     // }
                      //   },
                      //   validator: (value) {
                      //     if (value.isEmpty) {
                      //       return 'Please type any letter to search';
                      //     }
                      //     return null;
                      //   },
                      //   //hideOnEmpty: true,
                      //   noItemsFoundBuilder: (value) {
                      //     return searchLoad
                      //         ? Shimmer.fromColors(
                      //             child: Container(
                      //                 margin: EdgeInsets.all(8),
                      //                 width: MediaQuery.of(context).size.width,
                      //                 height: MediaQuery.of(context).size.width / 5,
                      //                 decoration: BoxDecoration(
                      //                   color: Colors.white,
                      //                   borderRadius: BorderRadius.circular(10),
                      //                 ),
                      //                 child: Text('Hello')),
                      //             direction: ShimmerDirection.ltr,
                      //             period: Duration(seconds: 2),
                      //             baseColor: Colors.white,
                      //             highlightColor: Colors.grey.withOpacity(0.2))
                      //         : (_typeAheadController.text == '' ||
                      //                 _typeAheadController.text.length == 0 ||
                      //                 _typeAheadController.text == null)
                      //             ? Container()
                      //             : Padding(
                      //                 padding: const EdgeInsets.symmetric(vertical: 8.0),
                      //                 child: Column(
                      //                   children: [
                      //                     Text(
                      //                       'No Results Found!\nWanna create new food ?',
                      //                       textAlign: TextAlign.center,
                      //                       style: TextStyle(
                      //                           color: AppColors.appTextColor, fontSize: 18.0),
                      //                     ),
                      //                     SizedBox(
                      //                       height: 10,
                      //                     ),
                      //                     Row(
                      //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //                       children: [
                      //                         ElevatedButton(
                      //                           onPressed: () {
                      //                             FocusScopeNode currentFocus =
                      //                                 FocusScope.of(context);
                      //                             if (!currentFocus.hasPrimaryFocus) {
                      //                               currentFocus.unfocus();
                      //                             }
                      //                             Navigator.of(context).push(
                      //                               MaterialPageRoute(
                      //                                   builder: (context) => CreateNewMealScreen(
                      //                                         mealType: widget.mealsListData,
                      //                                       )),
                      //                             );
                      //                             // addIngredients(context);
                      //                             // showBottomSheet();
                      //                           },
                      //                           child: Text(
                      //                             "Yes",
                      //                             style: TextStyle(fontSize: 18.0),
                      //                           ),
                      //                           style: ElevatedButton.styleFrom(
                      //                             primary: widget.mealsListData != null
                      //                                 ? HexColor(widget.mealsListData.startColor)
                      //                                 : AppColors.primaryAccentColor,
                      //                           ),
                      //                         ),
                      //                         ElevatedButton(
                      //                           onPressed: () {
                      //                             FocusScopeNode currentFocus =
                      //                                 FocusScope.of(context);
                      //                             if (!currentFocus.hasPrimaryFocus) {
                      //                               currentFocus.unfocus();
                      //                             }
                      //                           },
                      //                           child: Text(
                      //                             "No",
                      //                             style: TextStyle(fontSize: 18.0),
                      //                           ),
                      //                           style: ElevatedButton.styleFrom(
                      //                             primary: widget.mealsListData != null
                      //                                 ? HexColor(widget.mealsListData.startColor)
                      //                                 : AppColors.primaryAccentColor,
                      //                           ),
                      //                         )
                      //                       ],
                      //                     )
                      //                   ],
                      //                 ),
                      //               );
                      //   },
                      // ),
                      child: GestureDetector(
                        onTap: () {
                          FocusScopeNode currentFocus = FocusScope.of(context);

                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                        },
                        child: Form(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Autocomplete<Map<String, dynamic>>(
                                  optionsMaxHeight: 0,
                                  optionsBuilder: (TextEditingValue typeAheadController) {
                                    if (typeAheadController.text.isEmpty) {
                                      return const Iterable<Map<String, dynamic>>.empty();
                                    }

                                    return updatedSearchList.value
                                        .where((Map<String, dynamic> option) {
                                      final String name = option['dish'].toString().toLowerCase();
                                      return name.contains(typeAheadController.text.toLowerCase());
                                    });
                                  },
                                  // onSelected: (Map<String, dynamic> selection) {},
                                  fieldViewBuilder: (BuildContext context,
                                      TextEditingController typeAheadController,
                                      FocusNode focusNode,
                                      VoidCallback onFieldSubmitted) {
                                    return TextField(
                                      controller: typeAheadController,
                                      focusNode: focusNode,
                                      cursorColor: widget.mealsListData != null
                                          ? HexColor(widget.mealsListData.startColor)
                                          : AppColors.primaryAccentColor,
                                      decoration: InputDecoration(
                                        labelStyle: typeAheadFocus.hasPrimaryFocus
                                            ? TextStyle(
                                                color: widget.mealsListData != null
                                                    ? HexColor(widget.mealsListData.startColor)
                                                    : AppColors.primaryAccentColor,
                                              )
                                            : const TextStyle(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: widget.mealsListData != null
                                                ? HexColor(widget.mealsListData.startColor)
                                                : AppColors.primaryAccentColor,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(30.0),
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: widget.mealsListData != null
                                                ? HexColor(widget.mealsListData.startColor)
                                                : AppColors.primaryAccentColor,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(30.0),
                                          ),
                                        ),
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        hintText: 'Search Food or Meal',
                                        prefixIcon: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(start: 8, end: 8.0),
                                          child: Icon(
                                            Icons.search,
                                            color: widget.mealsListData != null
                                                ? HexColor(widget.mealsListData.startColor)
                                                : AppColors.primaryAccentColor,
                                          ),
                                        ),
                                      ),
                                      onChanged: (String value) async {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        List<Map<String, dynamic>> list =
                                            await foodItemsService.getSuggestions(value, 1, 10);
                                        _query = value;
                                        searchResults = list;
                                        typeAheadController.notifyListeners();
                                        updatedSearchList.value.clear();
                                        updatedSearchList.value.addAll(searchResults);
                                        if (list.isNotEmpty) {
                                          setState(() {
                                            isLoading = true;
                                            reponseListEmpty = false;
                                          });
                                        }
                                        if (list.isEmpty) {
                                          setState(() {
                                            isLoading = false;
                                            reponseListEmpty = true;
                                          });
                                        }
                                        if (_query == '') {
                                          setState(() {
                                            isLoading = true;
                                            reponseListEmpty = false;
                                          });
                                        }
                                      },
                                      onSubmitted: (String value) {
                                        // onFieldSubmitted();
                                      },
                                    );
                                  },
                                  // displayStringForOption: (Map<String, dynamic> option) =>
                                  //     option['ingredient'].toString(),
                                  optionsViewBuilder: (BuildContext context, onSelected, Iterable<Map<String, dynamic>> options) {

                                    return ValueListenableBuilder(
                                        valueListenable: updatedSearchList,
                                        builder: (BuildContext context, value, _) {
                                          return Material(
                                            child: isLoading
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 0,
                                                        bottom: 20.sp,
                                                        left: 10.sp,
                                                        right: 10.sp),
                                                    child: ListView.builder(
                                                      padding: const EdgeInsets.all(0.0),
                                                      controller: _scrollController,
                                                      scrollDirection: Axis.vertical,
                                                      shrinkWrap: true,
                                                      itemCount: value.length,
                                                      itemBuilder:
                                                          (BuildContext context, int index) {
                                                        final Map<String, dynamic> option =
                                                            value.elementAt(index);
                                                        return isLoading
                                                            ? ListTile(
                                                                title: Text(option['dish'] ??
                                                                    option["dish_name"]),
                                                                subtitle: Text(
                                                                    option['calories'] + ' Cal'),
                                                                onTap: () async {
                                                                  try {
                                                                    if (option['food_item_id']
                                                                            .toString()
                                                                            .substring(0, 3) ==
                                                                        "cus") {
                                                                      ListCustomRecipe foodDetail =
                                                                          await getCustomFoodDetail(
                                                                              option['food_item_id']
                                                                                  .toString());
                                                                      Get.delete<
                                                                          FoodDataLoaderController>();
                                                                      Get.to(CustomFoodDetailScreen(
                                                                        foodDetail,
                                                                        mealType:
                                                                            widget.mealsListData,
                                                                      ));
                                                                    } else {
                                                                      Get.delete<
                                                                          FoodDataLoaderController>();
                                                                      Get.to(FoodDetailScreen(
                                                                        option['food_item_id'],
                                                                        mealtype:
                                                                            widget.mealsListData,
                                                                      ));
                                                                    }
                                                                  } catch (e) {
                                                                    if (kDebugMode) {
                                                                      print(e.toString());
                                                                    }
                                                                    Get.delete<
                                                                        FoodDataLoaderController>();
                                                                    Get.to(FoodDetailScreen(
                                                                      option['food_item_id'],
                                                                      mealtype:
                                                                          widget.mealsListData,
                                                                    ));
                                                                  }
                                                                },
                                                              )
                                                            : Shimmer.fromColors(
                                                                direction: ShimmerDirection.ltr,
                                                                period: const Duration(seconds: 2),
                                                                baseColor: const Color.fromARGB(
                                                                    255, 240, 240, 240),
                                                                highlightColor:
                                                                    Colors.grey.withOpacity(0.2),
                                                                child: Container(
                                                                    margin: const EdgeInsets.all(8),
                                                                    width: 75.w,
                                                                    height: .5.h,
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(10),
                                                                    ),
                                                                    child: const Text('Hello')));
                                                      },
                                                    ),
                                                  )
                                                : Shimmer.fromColors(
                                                    direction: ShimmerDirection.ltr,
                                                    period: const Duration(seconds: 2),
                                                    baseColor:const Color.fromARGB(255, 240, 240, 240),
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
                                          );
                                        });
                                  },
                                ),
                                if (!isLoading)
                                  Container(
                                    child: reponseListEmpty
                                        ? Column(
                                          children: [
                                            const Text(
                                              'No Result Found!\nWanna create new Food?',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: AppColors.appTextColor,
                                                  fontSize: 18.0),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    FocusScopeNode currentFocus =
                                                        FocusScope.of(context);
                                                    if (!currentFocus.hasPrimaryFocus) {
                                                      currentFocus.unfocus();
                                                    }
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (BuildContext context) =>
                                                              CreateNewMealScreen(
                                                                mealType: widget.mealsListData,
                                                              )),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        widget.mealsListData != null
                                                            ? HexColor(
                                                                widget.mealsListData.startColor)
                                                            : AppColors.primaryAccentColor,
                                                  ),
                                                  child: const Text(
                                                    "Yes",
                                                    style: TextStyle(fontSize: 18.0),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    FocusScopeNode currentFocus =
                                                        FocusScope.of(context);
                                                    if (!currentFocus.hasPrimaryFocus) {
                                                      currentFocus.unfocus();
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        widget.mealsListData != null
                                                            ? HexColor(
                                                                widget.mealsListData.startColor)
                                                            : AppColors.primaryAccentColor,
                                                  ),
                                                  child: const Text(
                                                    "No",
                                                    style: TextStyle(fontSize: 18.0),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        )
                                        : Shimmer.fromColors(
                                            direction: ShimmerDirection.ltr,
                                            period:const Duration(seconds: 2),
                                            baseColor:const Color.fromARGB(255, 240, 240, 240),
                                            highlightColor: Colors.grey.withOpacity(0.2),
                                            child: Container(
                                                margin: const EdgeInsets.all(8),
                                                width: 75.w,
                                                height: 2.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Text('Hello'))),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                //selectedfoodItems(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    height: 50,
                    child: PreferredSize(
                      preferredSize: const Size.fromHeight(kToolbarHeight),
                      child: TabBar(
                        tabs: const [
                          Tab(text: 'Recent'),
                          // Tab(text: 'Bookmarks'),
                          Tab(text: 'Favourite'),
                          Tab(text: 'Custom'),
                        ],
                        //isScrollable: true,
                        indicatorColor: widget.mealsListData != null
                            ? HexColor(widget.mealsListData.startColor)
                            : AppColors.primaryAccentColor,
                        labelColor: Colors.black87,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      RecentsTab(
                        mealType: widget.mealsListData,
                        showText: showText,
                      ),
                      BookmarkTab(mealType: widget.mealsListData),
                      CustomFoodTab(mealType: widget.mealsListData),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class FoodItems {
//   static Future<List> getSuggestions(String query, int startIndex, int endPage) async {
//     final prefs = await SharedPreferences.getInstance();
//     String iHLUserId = prefs.getString('ihlUserId');
//     var food;
//     List<Map<String, dynamic>> matches = [];
//     try {
//       var _res = await Dio().post(
//         "${API.iHLUrl}/foodjournal/list_of_food_items_starts_with",
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'ApiToken': '${API.headerr['ApiToken']}',
//             'Token': '${API.headerr['Token']}',
//           },
//         ),
//         data: {
//           "search_string": query,
//           'ihl_user_id': iHLUserId,
//           "advanceSearch": "true",
//           "start_index": startIndex,
//           "end_index": endPage,
//         },
//       );
//       if (_res.statusCode == 200) {
//         food = _res.data["final_food_list"];
//       }
//       if (food != null) {
//         for (int i = 0; i < food.length; i++) {
//           matches.add(food[i]);
//         }
//       }
//
//       return matches;
//     } catch (e) {
//       if (kDebugMode) {
//         print(e + "add_new_meal");
//       }
//     }
//   }
// }
class FoodItems {
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> getSuggestions(
      String query, int startIndex, int endPage) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String iHLUserId = prefs.getString('ihlUserId');

      final  response = await _dio.post(
        "${API.iHLUrl}/foodjournal/list_of_food_items_starts_with",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
        data: {
          "search_string": query,
          'ihl_user_id': iHLUserId,
          "advanceSearch": "true",
          "start_index": startIndex,
          "end_index": endPage,
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data["final_food_list"]);
      } else {
        // Handle non-200 status codes here
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getSuggestions: $e');
      }
      // Handle error gracefully
      return [];
    }
  }
}

