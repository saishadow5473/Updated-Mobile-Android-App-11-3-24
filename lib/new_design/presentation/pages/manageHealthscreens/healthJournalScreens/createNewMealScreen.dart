import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/utils/appColors.dart';
import '../../../../app/utils/textStyle.dart';
import '../../../../data/providers/network/networks.dart';
import '../../../controllers/healthJournalControllers/foodDetailController.dart';
import 'foodLog1.dart';
import 'searchIngredients.dart';
import '../../../../../views/dietJournal/apis/list_apis.dart';
import '../../../../../views/dietJournal/apis/log_apis.dart';
import '../../../../../views/dietJournal/models/create_edit_meal_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../../../../constants/api.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import 'ingredientDetailedScreen.dart';

String foodName;
String servingType;
String mealCalories;
class NewMeal extends StatefulWidget {
  NewMeal(
      {Key key,
      @required this.baseColor,
      @required this.mealType,
      @required this.selectedQuantity,
      this.ingridentDetail,
      this.mealData,
      @required this.mealName,
      @required this.Qunatity,
      @required this.QuantityUnits})
      : super(key: key);
  final baseColor;
  final mealType;
  final mealData;
  final ingridentDetail;
  final selectedQuantity;
  final mealName;
  final Qunatity;
  final QuantityUnits;
  @override
  State<NewMeal> createState() => _NewMealState();
}

class _NewMealState extends State<NewMeal> {
  TextEditingController nameController = TextEditingController();
  TextEditingController CaloriesController = TextEditingController();
  TextEditingController _servingTypeController = TextEditingController();
  double totalCalorie = 0;
  double totalProteins = 0;
  double totalFats = 0;
  double totalCarbs = 0;
  double totalFiber = 0;
  var custoDetails;
  List customDishes = [];

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
  num quantity = 0.25;
  num selectedindex = 0;
  getCustomeDetail() async {
    custoDetails = await ListApis.customFoodDetailsApi();
    custoDetails.forEach((ele) => {customDishes.add(ele.dish)});
    try {
      for (int i = 0; i < IngredientsList.ingredientsList.length; i++) {
        totalCalorie = totalCalorie + double.parse(IngredientsList.ingredientsList[i].calories);
        totalProteins = totalProteins +
            double.parse(IngredientsList.ingredientsList[i].protiens ?? "0");
        totalCarbs =
            totalCarbs + double.parse(IngredientsList.ingredientsList[i].totalCarbohydrate);
        totalFats = totalFats + double.parse(IngredientsList.ingredientsList[i].totalFat);
        totalFiber = totalFiber + double.parse(IngredientsList.ingredientsList[i].fiber);
      }
    } catch (e) {
    }
    // CaloriesController.text = totalCalorie.toStringAsFixed(0) + " Cal";
    setState(() {});
  }

  void initState() {
    getCustomeDetail();
    if (foodName != null) {
      nameController.text = foodName;
    }
    if (servingType != null) {
      _servingTypeController.text = servingType;
    }
    if(mealCalories!=null){
      CaloriesController.text=mealCalories;
    }
    super.initState();
  }
  void removeSync(){
    foodName = "";
    servingType = "";
    mealCalories="";

  }
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        IngredientsList.ingredientsList.clear();
        removeSync();
        Get.to(LogFoodLanding(
            mealType: widget.mealType, bgColor: widget.baseColor, mealData: widget.mealData));
      },
      child: CommonScreenForNavigation(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                IngredientsList.ingredientsList.clear();
                removeSync();
                Get.to(LogFoodLanding(
                  mealType: widget.mealType,
                  bgColor: widget.baseColor,
                  mealData: widget.mealData,
                ));
              }, //replaces the screen to Main dashboard
              color: Colors.white,
            ),
            title: const Text("Create New Meal"),
            centerTitle: true,
            backgroundColor: widget.baseColor,
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      // padding: EdgeInsets.only(left: 18.sp, right: 18.sp, top: 30.sp),
                      padding: const EdgeInsets.all(9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Enter the meal name',style:TextStyle(fontSize: 15.sp,fontWeight: FontWeight.bold)),
                          TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: nameController,
                            onChanged: (v) => foodName = v,
                            validator: (value) {
                              if (!customDishes.contains(value.toLowerCase()) &&
                                  !customDishes.contains(value) &&
                                  !customDishes.contains(value.capitalize) &&
                                  !customDishes.contains(value.capitalizeFirst)) {
                                if (value.isEmpty) {
                                  return 'Food Title can\'t be empty!';
                                } else if (value.length < 4 && value.isNotEmpty) {
                                  return "At least 4 characters needed.";
                                } else if ((value.length > 33) && value.isNotEmpty) {
                                  return "Food item name should be less than 33 chars";
                                }

                                return null;
                              } else {
                                return "Food item name already exists";
                              }
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15.0),
                              labelText: "Food Title",
                              hintText: "Like: Biryani / Dosai / Pulav",
                              counterText: "",
                              counterStyle: TextStyle(fontSize: 0),
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))],
                            textInputAction: TextInputAction.done,
                          ),
                          SizedBox(
                            height: 4.h,
                          ),
                          Text('Enter the meal calories',style:TextStyle(fontSize: 15.sp,fontWeight: FontWeight.bold)),

                          TextFormField(
                            enableInteractiveSelection: false,
                            controller: CaloriesController,
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            style: TextStyle(fontSize: 16.sp,color: AppColors.paleFontColor),
                            onChanged: (v) => mealCalories = v,
                            validator: (value) {
                              if(value!=null&&value!="") {
                                var _v = num.tryParse(value);
                                if (_v != null) {
                                  if ((_v > 2000)) {
                                    return 'Enter calories between 0-2000';
                                  }
                                } else {
                                  return "Not valid";
                                }
                                return null;
                              }
                              else{

                                return null;
                              }
                            },
                            decoration:  const InputDecoration(
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
                              // color: AppColors.backgroundScreenColor,
                              elevation: 0,
                              child: Container(
                                height: 20.h,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10.sp, bottom: 10.sp),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                    Column(
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              'Add quantity',
                                              style: TextStyle(color: widget.baseColor),
                                            ),
                                            SizedBox(
                                              height: 12.sp,
                                            ),
                                            Container(
                                              width: 30.w,
                                              height: 12.h,
                                              padding: EdgeInsets.only(bottom: 15.sp, left: 10.sp),
                                              child: CupertinoPicker.builder(
                                                scrollController:
                                                    FixedExtentScrollController(initialItem: widget.selectedQuantity??0),
                                                itemExtent: 40,
                                                selectionOverlay: pickerContainer(),
                                                childCount: quantityList.length,
                                                onSelectedItemChanged: (int _index) {
                                                  if (quantityList.isEmpty) return;
                                                  var index = _index + 1;
                                                  selectedindex=widget.selectedQuantity??index;
                                                  print(index);
                                                  quantity = quantityList[index - 1];
                                                },
                                                itemBuilder: (context, index) {
                                                  return Center(
                                                      child: Text(
                                                    quantityList[index].toString(),
                                                    style: TextStyle(fontSize: 17.sp),
                                                  ));
                                                },
                                              ),
                                            ),
                                          ],
                                        )
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
                                              width: 33.w,
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

                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  textInputAction: TextInputAction.done,
                                                  onChanged: (v) => servingType = v,
                                                  controller: _servingTypeController,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.allow(
                                                        RegExp(r'[a-zA-Z0-9\s]')),
                                                  ],

                                                  validator: (value) {

                                                    if (value.isEmpty) {
                                                      return "Shouldn't be empty!";
                                                    } else {
                                                      if(value.length>10){
                                                        return "shouldn't exceed 10 \nletters";
                                                      }
                                                      else if(value.length<2){
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
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    Get.to(SearchIngredient(
                                      baseColor: widget.baseColor,
                                      editMeal: false,
                                      mealType: widget.mealType,
                                      mealData: widget.mealData,
                                    ));
                                  },
                                  child: const Text('Add ingredients')),
                              GestureDetector(
                                onTap: () {
                                  Get.to(SearchIngredient(
                                    selectedQuantity: selectedindex,

                                    baseColor: widget.baseColor,
                                    editMeal: false,
                                    mealType: widget.mealType,
                                    mealData: widget.mealData,
                                  ));
                                },
                                child: Container(
                                    // height: 10.h,
                                    width: 10.w,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle, color: widget.baseColor),
                                    child: const Center(
                                      child: Text(
                                        '+',
                                        style: TextStyle(fontSize: 20, color: Colors.white),
                                      ),
                                    )),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.h),
                            child: Container(
                              height: IngredientsList.ingredientsList.length < 10 ? null : 30.h,
                              width: 95.w,
                              padding: EdgeInsets.only(top: 3.h, left: 3.w, right: 1.w),
                              child: IngredientsList.ingredientsList != null
                                  ? Column(
                                      children: IngredientsList.ingredientsList.map((IngredientModel e) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                                                  child: SizedBox(
                                                      width: 40.w, child: Text(e.item.capitalize)),
                                                ),
                                                SizedBox(
                                                    width: 40.w,
                                                    child: Text("${e.amount} ${e.amount_unit}"))
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text("${e.calories} Cal"),
                                                IconButton(
                                                    onPressed: () async {
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
                                                      nutrionslist.addAll({'item': e.itemId});
                                                      nutrionslist.addAll({'protien': e.protiens});

                                                      nutrionsList1.add(nutrionslist);
                                                      // var nutriInfoList = await getIngredientDetails(e.foodid);

                                                      Get.to(IngredientDetailedScreen(
                                                        selectedQuantity: selectedindex,
                                                        ingredientID: e.itemId,
                                                        IngredientName: e.item,
                                                        nutrionInfoList: nutrionsList1,
                                                        fixedQuantity: e.fixedAmount,
                                                        screen: 'edit',
                                                        baseColor: widget.baseColor,
                                                        mealType: widget.mealType,
                                                        mealData: widget.mealData,
                                                        item_id: e.itemId,
                                                        editMeal: false,
                                                      ));
                                                    },
                                                    icon: Icon(
                                                      Icons.edit,
                                                      size: 19.sp,
                                                    )),
                                                // IconButton(

                                                //     icon: Icon(
                                                //       Icons.highlight_remove_sharp,
                                                //       color: Colors.red,
                                                //       size: 20.sp,
                                                //     )),
                                                InkWell(
                                                  onTap: () {
                                                    for (var element in IngredientsList.ingredientsList) {
                                                      if (element.item == e.item) {
                                                        totalCalorie =
                                                            totalCalorie - double.parse(e.calories);
                                                        CaloriesController.text =
                                                            "${totalCalorie.toStringAsFixed(0)} Cal";
                                                        continue;
                                                      }
                                                      continue;
                                                    }
                                                    IngredientsList.ingredientsList.removeWhere(
                                                        (IngredientModel element) => element.item == e.item);
                                                    setState(() {});
                                                  },
                                                  child: Icon(
                                                    Icons.highlight_remove_sharp,
                                                    color: Colors.red,
                                                    size: 20.sp,
                                                  ),
                                                )
                                              ],
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

                  IngredientsList.ingredientsList.isNotEmpty
                      ? Padding(
                          padding:  EdgeInsets.all(8.sp),
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
                                            const Text("Proteins"),
                                            const Spacer(),
                                            Text("${totalProteins.toStringAsFixed(2)} g",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: widget.baseColor)),
                                            const Spacer(),
                                            const Text("Fats"),
                                            const Spacer(),
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
                                            const Text("Carbs     "),
                                            const Spacer(),
                                            Text("${totalCarbs.toStringAsFixed(2)} g",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: widget.baseColor)),
                                            const Spacer(),
                                            const Text(" Fibre"),
                                            const Spacer(),
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
                          padding: EdgeInsets.all(8.sp),
                          child: Card(
                            elevation: 4,
                            child: Container(
                              padding: EdgeInsets.only(left: 12.sp, top: 15.sp),
                              // height: 18.h,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'Nutrients',
                                      style: AppTextStyles.content5,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2.5.h,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 1.h, right: 5.w),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Proteins"),
                                        const Spacer(),
                                        Text("${0} g",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: widget.baseColor)),
                                        const Spacer(),
                                        const Text("Fats"),
                                        const Spacer(),
                                        Text("${0} g",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: widget.baseColor)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 1.7.h),
                                  Padding(
                                    padding: EdgeInsets.only(top: 1.h, right: 5.w),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Carbs     "),
                                        const Spacer(),
                                        Text("${0} g",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: widget.baseColor)),
                                        const Spacer(),
                                        const Text(" Fibre"),
                                        const Spacer(),
                                        Text("${0} g",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: widget.baseColor)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 1.7.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                  FloatingActionButton.extended(
                    backgroundColor: widget.baseColor,
                    onPressed: () {
                      if(_formKey.currentState.validate()) {
                        if (nameController.text != null &&
                            nameController.text != "" &&
                            nameController.text != " " &&
                            _servingTypeController.text != null &&
                            _servingTypeController.text != " " &&
                            _servingTypeController.text != "") {
                          createCustomFood();

                        } else {
                          Get.snackbar('Select the Ingredient!', "Missing",
                              icon: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.warning_amber, color: Colors.white)),
                              margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                              backgroundColor: AppColors.primaryAccentColor,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 6),
                              snackPosition: SnackPosition.BOTTOM);
                        }
                      }
                    },
                    label: const Text("Save Meal"),
                  ),
                  SizedBox(
                    height: 14.h,
                  )
                ],
              ),
            ),
          )),
    );
  }

  pickerContainer<Widget>() {
    return Container(
      margin: const EdgeInsetsDirectional.only(
        start: 0,
        end: 0,
      ),
      decoration: BoxDecoration(
        border: const Border(
          top: BorderSide(width: 1.5, color: Colors.grey),
          bottom: BorderSide(width: 1.5, color: Colors.grey),
        ),
        color: CupertinoDynamicColor.resolve(Colors.transparent, context),
      ),
    );
  }

  getIngredientDetails(String ingredientId) async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');

    final response = await dio.post('${API.iHLUrl}/foodjournal/view_all_ingredient_detail',
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
      var food = response.data['message'];
      return food['quantity'];
    }
  }

  void createCustomFood() async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    List sendResult = [];
    sendResult.add(IngredientsList.ingredientsList);
    // List<IngredientModel> ingredientDetail =
    //     sendResult.map((e) => IngredientModel.fromJson(e)).toList();

    CreateEditRecipe logFood = CreateEditRecipe(
      ihlId: iHLUserId,
      dish: nameController.text,
      quantity: quantity.runtimeType == int ? quantity.toString() : quantity.toStringAsFixed(2),
      servingUnitSize: _servingTypeController.text,
      calories: CaloriesController.text!=""?CaloriesController.text:"0",
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
    );
    LogApis.createEditCustomFoodApi(data: logFood).then((value) async {
      if (value != null) {
        Get.find<FoodDetailController>().getUserCustmeFoodDetail();
        removeSync();
        IngredientsList.ingredientsList.clear();
        totalCalorie = 0;
        CaloriesController.clear();
        Get.to(LogFoodLanding(
            mealType: widget.mealType, bgColor: widget.baseColor, mealData: widget.mealData));
        Get.snackbar('Created!', '${camelize(nameController.text)} created successfully.',
            icon: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.close(1);
        Get.snackbar('Food not created!', 'Encountered some error while logging. Please try again',
            icon: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }
}
