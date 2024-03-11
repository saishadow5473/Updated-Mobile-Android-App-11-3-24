import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:ihl/new_design/app/utils/textStyle.dart';
import 'package:ihl/new_design/presentation/controllers/healthJournalControllers/foodDetailController.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:ihl/new_design/presentation/pages/manageHealthscreens/healthJournalScreens/caloriesCalculation.dart';
import 'package:ihl/new_design/presentation/pages/manageHealthscreens/healthJournalScreens/ingredientDetailedScreen.dart';
import 'package:ihl/views/dietJournal/apis/log_apis.dart';
import 'package:ihl/views/dietJournal/models/create_edit_meal_model.dart';
import 'package:ihl/views/dietJournal/models/view_custom_food_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../../../../utils/SpUtil.dart';
import '../../../../../views/dietJournal/models/food_list_tab_model.dart';
import 'foodLog1.dart';
import 'searchIngredients.dart';

class EditCustomFood extends StatefulWidget {
  EditCustomFood(
      {Key key,
      @required this.mealData,
      @required this.mealType,
      @required this.baseColor,
      @required this.recipeDetails});
  ListCustomRecipe recipeDetails;
  final baseColor;
  final mealType;
  final mealData;
  @override
  State<EditCustomFood> createState() => _EditCustomFoodState();
}

class _EditCustomFoodState extends State<EditCustomFood> {
  TextEditingController nameController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();
  TextEditingController _servingTypeController = TextEditingController();

  var ingredient;
  num valueText = 0;
  double totalCalorie = 0;
  double totalProteins = 0;
  double totalFats = 0;
  double totalCarbs = 0;
  double totalFiber = 0;
  num quantity = 0.25;
  var quantityList = [
    0.25,
    0.5,
    0.75,
    1,
    1.5,
    2,
    2.5,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    60,
    70,
    80,
    90,
    100,
    150,
    200,
    250,
    300,
    350,
    400,
    450,
    500,
    600,
    700,
    800,
    900,
    1000,
    1500,
    2000
  ];
  int initialPosition = 0;
  int _selectedIndexQuantity = 0;
  FixedExtentScrollController _scrollWheelController;
  void initState() {
    nameController.text = widget.recipeDetails.dish;
    caloriesController.text = widget.recipeDetails.calories;
    _servingTypeController.text = widget.recipeDetails.servingUnitSize;
    ingredientStore();
    updateScroll();
    super.initState();
  }

  void updateScroll() {
    initialPosition =
        QuantityList.quantityList.value.indexOf(double.parse(widget.recipeDetails.quantity));

    _scrollWheelController = FixedExtentScrollController(initialItem: initialPosition);
    print(initialPosition);
  }

  ingredientStore() {
    // quantityList.clear();
    IngredientsList.ingredientsList.forEach((ele) {
      widget.recipeDetails.ingredientDetail.removeWhere((element) {
        return ele.item == element.item;
      });
    });

    widget.recipeDetails.ingredientDetail.forEach((element) {
      // IngredientsList.ingredientsList.removeWhere((ele) {
      //   return ele.item == element.item;
      // });

      IngredientsList.ingredientsList.add(IngredientModel(
          amount: element.amount,
          item: element.item,
          amount_unit: element.amount_unit,
          calories: element.calories,
          totalCarbohydrate: element.totalCarbohydrate,
          protiens: element.protiens,
          totalFat: element.totalFat,
          fiber: element.fiber,
          itemId: element.itemId,
          fixedAmount: element.fixedAmount));
    });
    print(RemoveIngredient.removedIngredients.length);
    for (int i = 0; i < RemoveIngredient.removedIngredients.length; i++) {
      IngredientsList.ingredientsList
          .removeWhere((element) => element.item == RemoveIngredient.removedIngredients[i]);
    }
    totalCalorie = 0;
    totalProteins = 0;
    totalFats = 0;
    totalCarbs = 0;
    totalFiber = 0;
    IngredientsList.ingredientsList.forEach((element) {
      totalCalorie = totalCalorie + double.parse(element.calories);
      totalCarbs = totalCarbs + double.parse(element.totalCarbohydrate);
      totalFiber = totalFiber + double.parse(element.fiber);
      totalFats = totalFats + double.parse(element.totalFat);
      totalProteins = totalProteins + double.parse(element.protiens ?? "0");
    });
    // caloriesController.text = totalCalorie.toStringAsFixed(0);
    // print(IngredientsList.ingredientsList);
  }

  void createCustomFood() async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    List sendResult = [];
    sendResult.add(IngredientsList.ingredientsList);
    print(IngredientsList.ingredientsList.runtimeType);
    print(sendResult);
    // List<IngredientModel> ingredientDetail =
    //     sendResult.map((e) => IngredientModel.fromJson(e)).toList();

    CreateEditRecipe logFood = CreateEditRecipe(
        ihlId: iHLUserId,
        dish: nameController.text,
        quantity: QuantityList.quantityList.value[_selectedIndexQuantity].toString(),
        servingUnitSize: _servingTypeController.text,
        calories: caloriesController.text,
        protein: totalProteins.toString(),
        fats: totalFats.toString(),
        carbs: totalCarbs.toString(),
        fiber: totalFiber.toString(),
        hypertension: "",
        diabetes: "",
        // foodId: widget.customUserFood.foodId == null ? "" : widget.customUserFood.foodId,
        highBmi: "",
        heartDisease: "",
        highCholesterol: "",
        highVisceralFat: "",
        ingredientDetail: jsonEncode(IngredientsList.ingredientsList),
        foodId: widget.recipeDetails.foodId);

    LogApis.createEditCustomFoodApi(data: logFood).then((value) async {
      if (value != null) {
        // deleteFood();
        Get.find<FoodDetailController>().getUserCustmeFoodDetail();
        IngredientsList.ingredientsList.clear();
        totalCalorie = 0;
        nameController.clear();
        caloriesController.clear();
        Get.find<FoodDetailController>().getUserCustmeFoodDetail();
        Get.to(LogFoodLanding(
            mealType: widget.mealType, bgColor: widget.baseColor, mealData: widget.mealData));
        Get.snackbar('Edited!', '${camelize(nameController.text)} Edited successfully.',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.close(1);
        Get.snackbar('Food not created!', 'Encountered some error while logging. Please try again',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  pickerContainer<Widget>() {
    return Container(
      margin: EdgeInsetsDirectional.only(
        start: 0,
        end: 0,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.5, color: Colors.grey),
          bottom: BorderSide(width: 1.5, color: Colors.grey),
        ),
        color: CupertinoDynamicColor.resolve(Colors.transparent, context),
      ),
    );
  }

  void deleteRecents() async {
    await SpUtil.getInstance();
    List<FoodListTileModel> recentList = SpUtil.getRecentObjectList('recent_food') ?? [];
    bool exists = recentList.any((fav) => fav.foodItemID == widget.recipeDetails.foodId);
    if (exists) {
      recentList.removeWhere((element) => element.foodItemID == widget.recipeDetails.foodId);
    }
    SpUtil.putRecentObjectList('recent_food', recentList);
  }

  void deleteFood() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await LogApis.deleteCustomUserFoodApi(foodItemID: widget.recipeDetails.foodId)
        .then((data) async {
      if (data != null) {
        deleteRecents();
      } else {
        Get.snackbar('Error!', 'Fetching Data',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.favorite, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  Widget _buildCupertinoPickerQuantity(BuildContext context, int i, int _length, Key key) {
    return CupertinoPicker.builder(
      magnification: 1.3,
      key: key,
      scrollController: _scrollWheelController,
      itemExtent: 40,
      selectionOverlay: pickerContainer(),
      childCount: QuantityList.quantityList.value.length,
      itemBuilder: (context, index) {
        return Center(
            child: Text(QuantityList.quantityList.value[index].toString(),
                style: TextStyle(fontSize: 14)));
      },
      onSelectedItemChanged: (int _index) {
        MealCaloriesCalc.caloriesbool = true;
        _selectedIndexQuantity = _index;

        // double a =carbs.toInt();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        IngredientsList.ingredientsList.clear();
        nameController.clear();
        caloriesController.clear();
        _servingTypeController.clear();
        totalCalorie = 0;
        totalProteins = 0;
        totalFats = 0;
        totalCarbs = 0;
        totalFiber = 0;
        Get.to(LogFoodLanding(
          mealType: widget.mealType,
          bgColor: widget.baseColor,
          mealData: widget.mealData,
        ));
        return null;
      },
      child: CommonScreenForNavigation(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () async {
                IngredientsList.ingredientsList.clear();
                nameController.clear();
                caloriesController.clear();
                _servingTypeController.clear();
                totalCalorie = 0;
                totalProteins = 0;
                totalFats = 0;
                totalCarbs = 0;
                totalFiber = 0;
                Get.to(LogFoodLanding(
                  mealType: widget.mealType,
                  bgColor: widget.baseColor,
                  mealData: widget.mealData,
                ));
              }, //replaces the screen to Main dashboard
              color: Colors.white,
            ),
            centerTitle: true,
            title: Text("Edit meal"),
            backgroundColor: widget.baseColor,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 2.h),
                Card(
                  margin: EdgeInsets.all(5),
                  child: Padding(
                    padding: EdgeInsets.all(9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: nameController,
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15.0),
                            labelText: "Food Title",
                            hintText: "Like: Biryani / Dosai / Pulav",
                            counterText: "",
                            counterStyle: TextStyle(fontSize: 0),
                            fillColor: Colors.white,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))],
                          textInputAction: TextInputAction.done,
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        const Text('Enter the meal calories'),
                        TextFormField(
                          enableInteractiveSelection: false,
                          controller: caloriesController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: TextStyle(fontSize: 16.sp, color: AppColors.paleFontColor),
                          validator: (value) {
                            if (value != null && value != "") {
                              var _v = num.tryParse(value);
                              if (_v != null) {
                                if ((_v > 2000)) {
                                  return 'Enter calories between 0-2000';
                                }
                              } else {
                                return "Not valid";
                              }
                              return null;
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15.0),
                            labelText: "Calories",
                            counterText: "",
                            counterStyle: TextStyle(fontSize: 0),
                            fillColor: Colors.white,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 12.sp),
                          child: Card(
                            elevation: 0,
                            child: Container(
                              height: 20.h,
                              child: Padding(
                                padding: EdgeInsets.only(top: 10.sp, bottom: 10.sp),
                                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                  Column(
                                    children: [
                                      Row(children: [
                                        Text('Add quantity'),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              final _quantityForm = new GlobalKey<FormState>();
                                              showDialog(
                                                  context: context,
                                                  builder: (ctx) {
                                                    return AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10.0),
                                                        ),
                                                        title: Text('Enter the quantity'),
                                                        content: Form(
                                                          key: _quantityForm,
                                                          child: TextFormField(
                                                            enableInteractiveSelection: false,
                                                            inputFormatters: [
                                                              // FilteringTextInputFormatter
                                                              //     .digitsOnly
                                                            ],
                                                            validator: (String v) {
                                                              num _v = num.tryParse(v);
                                                              if (_v != null) {
                                                                if (_v.isGreaterThan(2000)) {
                                                                  return 'Invalid quantity';
                                                                } else {
                                                                  return null;
                                                                }
                                                              } else {
                                                                return "Enter valid input";
                                                              }
                                                            },
                                                            textInputAction: TextInputAction.done,
                                                            autovalidateMode:
                                                                AutovalidateMode.onUserInteraction,
                                                            keyboardType:
                                                                TextInputType.numberWithOptions(
                                                                    decimal: true),
                                                            onChanged: (value) {
                                                              if (mounted) {
                                                                setState(() {
                                                                  valueText = num.parse(value);
                                                                  print(valueText);
                                                                });
                                                              }
                                                            },
                                                            decoration: InputDecoration(
                                                                hintText: "quantity"),
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          MaterialButton(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(10.0),
                                                              ),
                                                              color: Color(0xffEE6143),
                                                              textColor: Colors.white,
                                                              child: Text('OK'),
                                                              onPressed: () {
                                                                if (_quantityForm.currentState
                                                                    .validate()) {
                                                                  // quantity =
                                                                  //     valueText;
                                                                  if (!QuantityList
                                                                      .quantityList.value
                                                                      .contains(valueText)) {
                                                                    QuantityList.quantityList.value
                                                                        .add(valueText);
                                                                  }
                                                                  QuantityList.quantityList.value
                                                                      .sort();
                                                                  QuantityList.quantityList.value =
                                                                      QuantityList
                                                                          .quantityList.value;
                                                                  QuantityList.quantityList
                                                                      .notifyListeners();
                                                                  initialPosition = QuantityList
                                                                      .quantityList.value
                                                                      .indexOf(valueText);
                                                                  _scrollWheelController
                                                                      .animateToItem(
                                                                          initialPosition,
                                                                          duration:
                                                                              Duration(seconds: 1),
                                                                          curve: Curves.easeInOut);
                                                                  Navigator.pop(ctx);
                                                                }
                                                                //QuantityList.quantityList.dispose();
                                                              })
                                                        ]);
                                                  });
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              size: 17.sp,
                                            ))
                                      ]),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      SizedBox(
                                          width: 25.w,
                                          height: 11.h,
                                          child: _buildCupertinoPickerQuantity(context, 0,
                                              QuantityList.quantityList.value.length, ValueKey(0))),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  Column(
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            'Serving Type',
                                            style: TextStyle(color: widget.baseColor),
                                          ),
                                          SizedBox(
                                            height: 10.sp,
                                          ),
                                          Container(
                                            width: 30.w,
                                            height: 12.h,
                                            padding: EdgeInsets.only(bottom: 15.sp, left: 10.sp),
                                            child: Center(
                                              //     child: Text(
                                              //   "nutrionsList['serving_unit_size']",
                                              //   style: TextStyle(
                                              //     fontSize: 17.sp,
                                              //   ),
                                              //   maxLines: 2,
                                              // )
                                              child: TextFormField(
                                                controller: _servingTypeController,
                                                autovalidateMode:
                                                    AutovalidateMode.onUserInteraction,
                                                textInputAction: TextInputAction.done,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(
                                                      RegExp(r'[a-zA-Z0-9\s]')),
                                                ],
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return "Shouldn't be \nempty!";
                                                  } else {
                                                    if (value.length > 10) {
                                                      return "shouldn't \nexceed 10 \nletters";
                                                    } else if (value.length < 2) {
                                                      return "Minimum 2 letters";
                                                    }
                                                    return null;
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                    hintText: "Enter Serving Type",
                                                    hintStyle: AppTextStyles.hintText),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Get.to(SearchIngredient(
                                    baseColor: widget.baseColor,
                                    mealType: widget.mealType,
                                    editMeal: true,
                                    recipeDetails: widget.recipeDetails,
                                    mealData: widget.mealData,
                                  ));
                                },
                                child: Text('Add ingredients')),
                            GestureDetector(
                              onTap: () {
                                Get.to(SearchIngredient(
                                  baseColor: widget.baseColor,
                                  mealType: widget.mealType,
                                  editMeal: true,
                                  recipeDetails: widget.recipeDetails,
                                  mealData: widget.mealData,
                                ));
                              },
                              child: Container(
                                  height: 8.h,
                                  width: 8.w,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle, color: widget.baseColor),
                                  child: Center(
                                    child: Text(
                                      '+',
                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                  )),
                            )
                          ],
                        ),
                        Container(
                          height: 8.5.h * IngredientsList.ingredientsList.length,
                          width: 100.w,
                          padding: EdgeInsets.only(
                            top: 1.h,
                            left: 3.w,
                          ),
                          child: SingleChildScrollView(
                            child: IngredientsList.ingredientsList != null
                                ? Column(
                                    children: IngredientsList.ingredientsList.map((e) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 3.0),
                                                child: SizedBox(
                                                    width: 40.w, child: Text(e.item.capitalize)),
                                              ),
                                              SizedBox(
                                                  width: 50.w,
                                                  child: Text("${e.amount} ${e.amount_unit}"))
                                            ],
                                          ),
                                          SizedBox(
                                            width: 32.5.w,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  e.calories + " Cal",
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    List<dynamic> nutrionsList1 = [];
                                                    var nutrionslist = {};
                                                    nutrionslist.addAll({'ingredient': e.item});
                                                    nutrionslist.addAll({'quantity': e.amount});
                                                    nutrionslist.addAll(
                                                        {'serving_unit_size': e.amount_unit});
                                                    nutrionslist.addAll({'calories': e.calories});
                                                    nutrionslist
                                                        .addAll({'carbs': e.totalCarbohydrate});
                                                    nutrionslist.addAll({'fats': e.totalFat});
                                                    nutrionslist.addAll({'fiber': e.fiber});
                                                    nutrionslist.addAll({'protien': e.protiens});
                                                    nutrionslist.addAll({'food_id': e.itemId});

                                                    nutrionsList1.add(nutrionslist);
                                                    // var nutriInfoList = await getIngredientDetails(e.foodid);

                                                    Get.to(IngredientDetailedScreen(
                                                      ingredientID: e.itemId,
                                                      IngredientName: e.item,
                                                      nutrionInfoList: nutrionsList1,
                                                      fixedQuantity: e.fixedAmount ?? e.amount,
                                                      screen: 'edit',
                                                      baseColor: widget.baseColor,
                                                      mealType: widget.mealType,
                                                      mealData: widget.mealData,
                                                      editMeal: true,
                                                      recipeDetails: widget.recipeDetails,
                                                    ));
                                                  },
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 19.sp,
                                                  ),
                                                ),
                                                InkWell(
                                                    onTap: () {
                                                      IngredientsList.ingredientsList
                                                          .forEach((element) {
                                                        if (element.item == e.item) {
                                                          totalCalorie = totalCalorie -
                                                              double.parse(e.calories);
                                                          totalCarbs = totalCarbs -
                                                              double.parse(e.totalCarbohydrate);
                                                          totalFiber =
                                                              totalFiber - double.parse(e.fiber);
                                                          totalFats =
                                                              totalFats - double.parse(e.totalFat);
                                                          totalProteins = totalProteins -
                                                              double.parse(e.protiens ?? "0");
                                                          return true;
                                                        }
                                                        return true;
                                                      });
                                                      IngredientsList.ingredientsList.removeWhere(
                                                          (element) => element.item == e.item);
                                                      RemoveIngredient.removedIngredients
                                                          .add(e.item);
                                                      ingredientStore();
                                                      setState(() {});
                                                    },
                                                    child: Icon(
                                                      Icons.highlight_remove_sharp,
                                                      color: Colors.red,
                                                      size: 20.sp,
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList())
                                : SizedBox(
                                    height: 10.h,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IngredientsList.ingredientsList.length != 0
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 12.sp),
                        child: Card(
                          elevation: 4,
                          child: Container(
                            padding: EdgeInsets.only(left: 12.sp, top: 8.sp),
                            height: 18.h,
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Nutrients',
                                    style: AppTextStyles.content5,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      height: 2.5.h,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 1.h, right: 5.w),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Proteins"),
                                          Spacer(),
                                          Text(" ${totalProteins.toStringAsFixed(2)} g",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: widget.baseColor)),
                                          Spacer(),
                                          Text("Fats"),
                                          Spacer(),
                                          Text("${totalFats.toStringAsFixed(2)} g",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: widget.baseColor)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 1.7.h,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 1.h, right: 5.w),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Carbs     "),
                                          Spacer(),
                                          Text("${totalCarbs.toStringAsFixed(2)} g",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: widget.baseColor)),
                                          Spacer(),
                                          Text(" Fibre"),
                                          Spacer(),
                                          Text("${totalFiber.toStringAsFixed(2)} g",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: widget.baseColor)),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(12.sp),
                        child: Card(
                          elevation: 4,
                          child: Container(
                            padding: EdgeInsets.only(left: 12.sp, top: 15.sp),
                            height: 18.h,
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Nutrients',
                                    style: AppTextStyles.content5,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      height: 2.5.h,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 1.h, right: 5.w),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Proteins"),
                                          Spacer(),
                                          Text("${0} g",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: widget.baseColor)),
                                          Spacer(),
                                          Text("Fats"),
                                          Spacer(),
                                          Text("${0} g",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: widget.baseColor)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 1.7.h,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 1.h, right: 5.w),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Carbs     "),
                                          Spacer(),
                                          Text("${0} g",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: widget.baseColor)),
                                          Spacer(),
                                          Text(" Fibre"),
                                          Spacer(),
                                          Text("${0} g",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: widget.baseColor)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                FloatingActionButton.extended(
                  backgroundColor: widget.baseColor,
                  onPressed: () {
                    if (nameController.text != null &&
                        nameController.text != "" &&
                        nameController.text != " " &&
                        _servingTypeController.text != null &&
                        _servingTypeController.text != " " &&
                        _servingTypeController.text != "" &&
                        IngredientsList.ingredientsList != null &&
                        IngredientsList.ingredientsList != "" &&
                        IngredientsList.ingredientsList != " ") {
                      createCustomFood();
                    } else {
                      Get.snackbar('Enter the food details properly', "",
                          icon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.warning_amber, color: Colors.white)),
                          margin: EdgeInsets.all(20).copyWith(bottom: 40),
                          backgroundColor: AppColors.primaryAccentColor,
                          colorText: Colors.white,
                          duration: Duration(seconds: 6),
                          snackPosition: SnackPosition.BOTTOM);
                    }
                  },
                  label: Text("Save Meal"),
                ),
                SizedBox(height: 14.h)
              ],
            ),
          )),
    );
  }
}

class RemoveIngredient {
  static List removedIngredients = [];
}

class MealCaloriesCalc {
  static bool caloriesbool = true;
  static ValueNotifier<double> calories = ValueNotifier<double>(0.0);
}

class MealNutriCalculations {
  static ValueNotifier<Map> nutrients =
      ValueNotifier<Map>({'fats': 0.0, 'fiber': 0.0, 'carbs': 0.0, 'protein': 0.0});
}

class QuantityList {
  static ValueNotifier<List<num>> quantityList = ValueNotifier<List<num>>([
    0.25,
    0.5,
    0.75,
    1,
    1.5,
    2,
    2.5,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    60,
    70,
    80,
    90,
    100,
    150,
    200,
    250,
    300,
    350,
    400,
    450,
    500,
    600,
    700,
    800,
    900,
    1000,
    1500,
    2000
  ]);
}
