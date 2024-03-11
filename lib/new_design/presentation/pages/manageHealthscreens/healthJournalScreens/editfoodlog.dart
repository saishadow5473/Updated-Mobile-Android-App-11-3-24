import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants/api.dart';
import '../../../../app/utils/textStyle.dart';
import '../../../../data/providers/network/networks.dart';
import '../../../controllers/healthJournalControllers/calendarController.dart';
import '../../../controllers/healthJournalControllers/foodDetailController.dart';
import '../../../controllers/healthJournalControllers/getTodayLogController.dart';
import 'caloriesCalculation.dart';
import 'foodLog1.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../views/dietJournal/apis/list_apis.dart';
import '../../../../../views/dietJournal/apis/log_apis.dart';
import '../../../../../views/dietJournal/models/food_deatils_updated.dart';
import '../../../../../views/dietJournal/models/food_list_tab_model.dart';
import '../../../../../views/dietJournal/models/food_unit_detils.dart';
import '../../../../../views/dietJournal/models/log_user_food_intake_model.dart';
import '../../../../../views/dietJournal/stats/info_quantity_screen.dart';
import '../../../controllers/healthJournalControllers/loadFoodList.dart';
import '../../dashboard/common_screen_for_navigation.dart';

class EditFoodLog extends StatefulWidget {
  String foodId;
  var logedData;
  var mealType;
  var mealData;
  var bgcolor;
  String foodLogId;

  EditFoodLog({Key key,
    @required this.foodId,
    @required this.mealType,
    @required this.mealData,
    @required this.logedData,
    @required this.foodLogId,
    this.bgcolor})
      : super(key: key);

  @override
  State<EditFoodLog> createState() => _EditFoodLogState();
}

class _EditFoodLogState extends State<EditFoodLog> {
  int initialPositionServing = 0;
  List quantity_type = [];
  int _selectedIndexQuantityType = 0;
  int _selectedIndexQuantity = 0;

  // List<String> quantity_type = ["glass","cup","oz","gm","kg","table spoon"];
  var selectedTime;

  // = TimeOfDay.now();
  FixedExtentScrollController _scrollWheelController;
  FixedExtentScrollController ServingScrollWheelController;
  var _chosenType;
  List<GetFoodUnit> foodUnit;
  UpdatedFoodDetails foodDetail;

  // bool typeCheck = false;
  double baseQunatity = 1;
  Map nutrionData;
  String logCalories = '1';
  double unitQunatity = 1.0;
  double perQunatity;
  var logedDate;
  bool typeChange = false;
  bool kcal = false;
  num valueText = 0;
  LogButtonLoader buttonLoader = LogButtonLoader();

  @override
  void initState() {
    // TODO: implement initState
    if (widget.logedData.runtimeType == FoodListTileModel) {
      typeChange = true;
    }

    selectedTime = typeChange ? widget.logedData.foodTime : widget.logedData.foodLogTime;
    logedDate = DateFormat.jm().format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(selectedTime));

    _chosenType = widget.mealType;
    MealCaloriesCalc.caloriesbool = false;
    updateScroll();
    getDetails();
    super.initState();
  }

  void updateScroll() {
    double quantity = double.parse(typeChange
        ? widget.logedData.quantity
        : widget.logedData.food[0].foodDetails[0].foodQuantity);
    if (!QuantityList.quantityList.value.contains(quantity)) {
      QuantityList.quantityList.value.add(quantity);

      QuantityList.quantityList.value.sort();
    }
    // if (!quantity.contains(_quantity)) {
    //   quantity=QuantityList.quantityList.value;
    // }
    initialPosition = QuantityList.quantityList.value.indexOf(double.parse(typeChange
        ? widget.logedData.quantity
        : widget.logedData.food[0].foodDetails[0].foodQuantity));

    _scrollWheelController = FixedExtentScrollController(initialItem: initialPosition);
  }

  num fixedQuantity;
  num protein;
  num carbs;
  num fat;
  num fiber;
  int initialPosition = 0;

  void getDetails() async {
    await ListApis.updatedGetFoodDetails(foodID: widget.foodId)
        .then((UpdatedFoodDetails data) async {
      foodUnit = await ListApis.getFoodUnit(data.item);
      if (data != null) {
        if (mounted) {
          setState(() {
            foodDetail = data;
            carbs = num.parse(foodDetail.carbs).roundToDouble();
            fat = num.parse(foodDetail.fats).roundToDouble();
            fiber = num.parse(foodDetail.fiber).roundToDouble();
            protein = num.parse(foodDetail.protein).roundToDouble();
            fixedQuantity = num.parse(foodDetail.quantity);

            MealCaloriesCalc.calories.value = typeChange
                ? int.parse(widget.logedData.extras).toDouble()
                : int.parse(widget.logedData.totalCaloriesGained).toDouble();
            nutrionData = CaloriesCalc().calculateNutrients(
              num.parse(carbs.toString()),
              num.parse(fiber.toString()),
              num.parse(fat.toString()),
              num.parse('18.0'),
              fixedQuantity,
              num.parse(typeChange
                  ? widget.logedData.quantity
                  : widget.logedData.food[0].foodDetails[0].foodQuantity.toString()),
            );

            MealNutriCalculations.nutrients.value = nutrionData;
          });
        }
      } else {}
    });
    print(foodUnit.length);
    for (int i = 0; i < foodUnit.length; i++) {
      quantity_type.add(foodUnit[i].servingUnitSize);
    }
    initialPositionServing = quantity_type.indexOf(typeChange
        ? widget.logedData.quantityUnit
        : widget.logedData.food[0].foodDetails[0].quantityUnit);
    ServingScrollWheelController = FixedExtentScrollController(initialItem: initialPositionServing);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            Get.back();
          }, //replaces the screen to Main dashboard
          color: Colors.white,
        ),
        title:
        Padding(padding: EdgeInsets.only(left: 15.w), child: Text("Edit ${widget.mealType}")),
        backgroundColor: widget.mealType != 'lunch' ? widget.bgcolor : AppColors.primaryAccentColor,
        // backgroundColor: widget.baseColor,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 18.sp),
            child: IconButton(
                onPressed: () {
                  AwesomeDialog(
                    context: context,
                    animType: AnimType.TOPSLIDE,
                    dialogType: DialogType.WARNING,
                    title: "Confirm!",
                    desc: "Are you sure to delete this log",
                    btnOkOnPress: () async {
                      bool isDeleted = await deleteMeal(
                          typeChange ? widget.logedData.foodTime : widget.logedData.foodLogTime);
                      if (isDeleted) {
                        DateTime currentDate = DateTime.now();

                        DateTime startTime =
                        DateTime(currentDate.year, currentDate.month, currentDate.day, 0, 0, 0);

                        DateTime endTime = DateTime(
                            currentDate.year, currentDate.month, currentDate.day, 23, 59, 0);

                        DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
                        String startTimeString = formatter.format(startTime);
                        String endTimeString = formatter.format(endTime);
                        Get.snackbar('Log Deleted', 'deleted successfully.',
                            icon: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.check_circle, color: Colors.white)),
                            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                            backgroundColor: AppColors.primaryAccentColor,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 5),
                            snackPosition: SnackPosition.BOTTOM);
                        try {
                          Get.find<ClendarController>()
                              .updateFoodDetail(startTimeString, endTimeString, widget.mealType);
                          Get.delete<FoodDataLoaderController>();
                        } catch (e) {
                          print("CalendarController not initialized");
                        }
                        Get.to(LogFoodLanding(
                          mealType: widget.mealType,
                          mealData: widget.mealData,
                          bgColor: widget.bgcolor,
                        ));
                        try {
                          Get.find<TodayLogController>().onInit();
                        } catch (e) {
                          Get.put(TodayLogController());
                        }
                      } else {
                        Get.close(1);
                        Get.snackbar('Log not Deleted',
                            'Encountered some error while deleted. Please try later',
                            icon: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.cancel_rounded, color: Colors.white)),
                            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 5),
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                    btnCancelOnPress: () {},
                    btnCancelText: "Cancel",
                    btnOkText: "Delete",
                    btnCancelColor: AppColors.primaryAccentColor,
                    // btnOkColor: widget.screenColor,
                  ).show();
                },
                icon: const Icon(Icons.delete)),
          )
        ],
      ),
      content: Scaffold(
        body: GetBuilder<FoodDataLoaderController>(
            id: "FoodData",
            init: FoodDataLoaderController(widget.foodId),
            builder: (FoodDataLoaderController foodDetail) {
              // foodDetail.getFoodDetail(widget.foodId);
              bool loadData = foodDetail.foodDetail == null;
              return loadData //widget.logedData.toString().isEmpty && widget.logedData == null
                  ? SizedBox(
                height: 100.h,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12.sp),
                        child: SizedBox(
                          height: 30.h,
                          child: Shimmer.fromColors(
                              direction: ShimmerDirection.ltr,
                              period: const Duration(seconds: 2),
                              baseColor: Colors.white,
                              highlightColor: Colors.grey,
                              child: Container(
                                  margin: const EdgeInsets.all(8),
                                  width: 90.w,
                                  height: 55.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text('Hello'))),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(21.sp),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Shimmer.fromColors(
                                    direction: ShimmerDirection.ltr,
                                    period: const Duration(seconds: 2),
                                    baseColor: Colors.white,
                                    highlightColor: Colors.grey,
                                    child: Container(
                                        margin: const EdgeInsets.all(8),
                                        width: 5.w,
                                        height: 2.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text('Hello'))),
                                SizedBox(width: 6.w),
                                Shimmer.fromColors(
                                    direction: ShimmerDirection.ltr,
                                    period: const Duration(seconds: 2),
                                    baseColor: Colors.white,
                                    highlightColor: Colors.grey,
                                    child: Container(
                                        margin: const EdgeInsets.all(8),
                                        width: 5.w,
                                        height: 2.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text('Hello'))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12.sp),
                        child: Card(
                          elevation: 4,
                          child: SizedBox(
                              height: 18.h,
                              child: Shimmer.fromColors(
                                  direction: ShimmerDirection.ltr,
                                  period: const Duration(seconds: 2),
                                  baseColor: Colors.white,
                                  highlightColor: Colors.grey,
                                  child: Container(
                                      margin: const EdgeInsets.all(8),
                                      width: 85.w,
                                      height: 20.h,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text('Hello')))),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 100.h,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 5.h),
                        Container(
                            height: 25.h,
                            width: 95.w,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[300],
                                  offset: const Offset(0.1, 0.1),
                                  blurRadius: 18,
                                )
                              ],
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15)),
                              child: Image.asset(
                                'newAssets/images/ingredients.png',
                                fit: BoxFit.cover,
                              ),
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: 2.h, bottom: 8.0),
                          child: SizedBox(
                            width: 95.w,
                            child: Row(
                              children: [
                                widget.logedData !=
                                    null //widget.logedData.food[0].foodDetails[0].foodName
                                    ? Text(
                                    '   ${typeChange ? widget.logedData.title : widget.logedData
                                        .food[0].foodDetails[0]
                                        .foodName}') //!typeCheck?Text('${widget.logedData.title}'):
                                // foodDetail.foodDetail.dish,
                                // style: AppTextStyles.content4,

                                    : Shimmer.fromColors(
                                    direction: ShimmerDirection.ltr,
                                    period: const Duration(seconds: 2),
                                    baseColor: Colors.white,
                                    highlightColor:
                                    AppColors.primaryAccentColor.withOpacity(0.2),
                                    child: Container(
                                        margin: const EdgeInsets.all(8),
                                        width: 5.w,
                                        height: 2.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text('Hello'))),
                                const Spacer(),
                                ValueListenableBuilder(
                                    valueListenable: MealCaloriesCalc.calories,
                                    builder: (_, val, __) {
                                      return Text(
                                        !MealCaloriesCalc.caloriesbool
                                            ? "${typeChange ? widget.logedData.extras : widget
                                            .logedData.totalCaloriesGained} Cal"
                                            : "${val.toStringAsFixed(0)} Cal",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: widget.mealType != 'lunch'
                                                ? widget.bgcolor
                                                : AppColors.primaryAccentColor),
                                      );
                                    }),
                                const Spacer(
                                  flex: 3,
                                ),
                                GestureDetector(
                                  onTap: () =>

                                  ///Quantity checking screen
                                  Get.to(InfoQuantityScreen(
                                    appBarColor: widget.mealType != 'lunch'
                                        ? widget.bgcolor
                                        : AppColors.primaryAccentColor,
                                  )),
                                  child: Row(
                                    children: [
                                      Container(
                                          height: 18.sp,
                                          width: 18.sp,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                              color: Colors.black, shape: BoxShape.circle),
                                          child: Text(
                                            '?',
                                            style: TextStyle(
                                                color: Colors.white, fontSize: 15.sp),
                                          )),
                                      SizedBox(
                                        width: 10.sp,
                                      ),
                                      Text('Quantity',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: widget.mealType != 'lunch'
                                                  ? widget.bgcolor
                                                  : AppColors.primaryAccentColor))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.5.sp, right: 8.sp),
                          child: Row(
                            children: [
                              DropdownButton<String>(
                                focusColor: Colors.white,
                                value: _chosenType,
                                //elevation: 5,
                                style: const TextStyle(color: Colors.white),
                                iconEnabledColor: Colors.black,
                                items: <String>['Breakfast', 'Lunch', 'Snacks', 'Dinner']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                                hint: const Text(
                                  "Quantity",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                // onChanged: (String value) {
                                //   _chosenType = value;
                                // },
                              ),
                              const Spacer(),
                              const InkWell(
                                splashColor: Colors.red, // inkwell color
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.timelapse_sharp,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Text(
                                logedDate,
                                style: TextStyle(color: widget.bgcolor),
                              ),
                              const Spacer(
                                flex: 2,
                              )
                            ],
                          ),
                        ),
                        Card(
                          elevation: 4,
                          child: SizedBox(
                            height: 22.h,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 25.sp, right: 25.sp, top: 20.sp, bottom: 14.sp),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Row(children: [
                                          const Text('Add quantity'),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          GestureDetector(
                                              onTap: () {
                                                final quantityForm = GlobalKey<FormState>();
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext ctx) {
                                                      return AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(10.0),
                                                          ),
                                                          title: const Text(
                                                              'Enter the quantity'),
                                                          content: Form(
                                                            key: quantityForm,
                                                            child: TextFormField(
                                                              enableInteractiveSelection:
                                                              false,
                                                              inputFormatters: [
                                                                // FilteringTextInputFormatter
                                                                //     .digitsOnly
                                                              ],
                                                              autovalidateMode:
                                                              AutovalidateMode
                                                                  .onUserInteraction,
                                                              validator: (String v) {
                                                                num _v = num.tryParse(v);
                                                                if (_v != null) {
                                                                  if (_v
                                                                      .isGreaterThan(2000)) {
                                                                    return 'Invalid quantity';
                                                                  } else {
                                                                    return null;
                                                                  }
                                                                } else {
                                                                  return "Enter valid input";
                                                                }
                                                              },
                                                              textInputAction:
                                                              TextInputAction.done,
                                                              keyboardType:
                                                              const TextInputType
                                                                  .numberWithOptions(
                                                                  decimal: true),
                                                              onChanged: (String value) {
                                                                if (mounted) {
                                                                  setState(() {
                                                                    valueText =
                                                                        num.parse(value);
                                                                  });
                                                                }
                                                              },
                                                              decoration:
                                                              const InputDecoration(
                                                                  hintText: "quantity"),
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            MaterialButton(
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius.circular(
                                                                      10.0),
                                                                ),
                                                                color:
                                                                const Color(0xffEE6143),
                                                                textColor: Colors.white,
                                                                child: const Text('OK'),
                                                                onPressed: () {
                                                                  if (quantityForm
                                                                      .currentState
                                                                      .validate()) {
                                                                    // quantity =
                                                                    //     valueText;
                                                                    if (!QuantityList
                                                                        .quantityList.value
                                                                        .contains(
                                                                        valueText)) {
                                                                      QuantityList
                                                                          .quantityList.value
                                                                          .add(valueText);
                                                                    }
                                                                    QuantityList
                                                                        .quantityList.value
                                                                        .sort();

                                                                    QuantityList.quantityList
                                                                        .value =
                                                                        QuantityList
                                                                            .quantityList
                                                                            .value;
                                                                    QuantityList.quantityList
                                                                        .notifyListeners();
                                                                    initialPosition =
                                                                        QuantityList
                                                                            .quantityList
                                                                            .value
                                                                            .indexOf(
                                                                            valueText);
                                                                    _scrollWheelController
                                                                        .animateToItem(
                                                                        initialPosition,
                                                                        duration:
                                                                        const Duration(
                                                                            seconds:
                                                                            1),
                                                                        curve: Curves
                                                                            .easeInOut);
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
                                            child: _buildCupertinoPickerQuantity(
                                                context,
                                                0,
                                                QuantityList.quantityList.value.length,
                                                const ValueKey(0))),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Column(
                                      children: [
                                        const Text('Serving Type'),
                                        SizedBox(
                                          height: 1.h,
                                        ),
                                        SizedBox(
                                            width: 30.w,
                                            height: 11.h,
                                            child: _buildCupertinoPickerServingUnitType(
                                                context,
                                                1,
                                                quantity_type.length,
                                                const ValueKey(1))),
                                      ],
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                        Card(
                          elevation: 4,
                          child: ValueListenableBuilder(
                              valueListenable: MealNutriCalculations.nutrients,
                              builder: (_, val, __) {
                                return Container(
                                  padding: EdgeInsets.only(left: 15.sp, top: 15.sp),
                                  height: 18.h,
                                  width: 95.w,
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
                                            padding: EdgeInsets.only(
                                                left: 1.w, top: 1.h, right: 5.w),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text("Proteins"),
                                                const Spacer(),
                                                Text(
                                                    val['protein'].toStringAsFixed(2) ==
                                                        "0.00"
                                                        ? "--"
                                                        : val['protein'].toStringAsFixed(2) +
                                                        "g",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: widget.bgcolor)),
                                                const Spacer(),
                                                const Text("Fats"),
                                                const Spacer(),
                                                Text(
                                                    val['fats'].toStringAsFixed(2) == "0.00"
                                                        ? "--"
                                                        : val['fats'].toStringAsFixed(2) +
                                                        "g",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: widget.bgcolor)),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 1.7.h,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 1.w, top: 1.h, right: 5.w),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text("Carbs     "),
                                                const Spacer(),
                                                Text(
                                                    val['carbs'].toStringAsFixed(2) == "0.00"
                                                        ? "--"
                                                        : val['carbs'].toStringAsFixed(2) +
                                                        "g",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: widget.bgcolor)),
                                                const Spacer(),
                                                const Text(" Fiber"),
                                                const Spacer(),
                                                Text(
                                                    val['fiber'].toStringAsFixed(2) == "0.00"
                                                        ? "--"
                                                        : val['fiber'].toStringAsFixed(2) +
                                                        "g",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: widget.bgcolor)),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              }),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Obx(() =>
                              FloatingActionButton.extended(
                                  onPressed: buttonLoader.isButtonLoading.value
                                      ? () {}
                                      : () {
                                    buttonLoader.isButtonLoading.value = true;
                                    logMeal();
                                  },
                                  backgroundColor: buttonLoader.isButtonLoading.value
                                      ? Colors.grey
                                      : widget.bgcolor,
                                  label: buttonLoader.isButtonLoading.value
                                      ? Shimmer.fromColors(
                                    direction: ShimmerDirection.ltr,
                                    period: const Duration(seconds: 2),
                                    baseColor: Colors.white,
                                    highlightColor: Colors.grey,
                                    child: const Text(
                                      'Updating Log',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                      : const Text(
                                    'Change Log',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.set_meal,
                                    color: Colors.white,
                                  ))),
                        ),
                        SizedBox(
                          height: 15.h,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Future<bool> deleteMeal(String loggedTime) async {
    print(loggedTime);
    DateTime inputDate = DateFormat('dd-MM-yyyy HH:mm:ss').parse(loggedTime);
    String outputDateString = DateFormat('yyyy-MM-dd HH:mm:ss').format(inputDate);
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    var res = await dio.post(
      '${API.iHLUrl}/foodjournal/delete_food_log',
      data: json.encode({
        "user_ihl_id": iHLUserId,
        "food_log_time": outputDateString,
        "food_log_id": widget.foodLogId
      }),
    );
    if (res.statusCode == 200) {
      if (res.data['status'] == 'success') {
        return true;
      }
    }
    return false;
  }

  void logMeal() async {
    // if (this.mounted) {
    //   setState(() {
    //     submitted = true;
    //   });
    // }
    ///without changing quantity its not getting updated so..for food quantity params done conditions to both today's summary screen and in logging screen
    ///today's summary screen ->FoodListTileModel and logging screen normal flow
    var fooddetail = FoodDetail(
        foodId:
        '${typeChange ? widget.logedData.foodItemID : widget.logedData.food[0].foodDetails[0]
            .foodId}',
        foodName:
        '${typeChange ? widget.logedData.title : widget.logedData.food[0].foodDetails[0].foodName}',
        foodQuantity:
        widget.logedData.runtimeType == FoodListTileModel && _selectedIndexQuantity == 0
            ? widget.logedData.quantity
            : _selectedIndexQuantity == 0
            ? widget.logedData.food[0].foodDetails[0].foodQuantity
            : QuantityList.quantityList.value[_selectedIndexQuantity].toString(),
        quantityUnit: quantity_type[_selectedIndexQuantityType].toString());
    var logFood = await prepareForLog(fooddetail);

    await LogApis.editUserFoodLogApi(data: logFood).then((value) {
      if (value != null) {
        // if (this.mounted) {
        //   setState(() {
        //     submitted = false;
        //   });
        // }
        ListApis.getUserTodaysFoodLogApi(widget.mealType).then((value) {
          print('VALUE===>$value');
          Get.put(ClendarController());
          Get.put(FoodDetailController());
          Get.to(LogFoodLanding(
            mealType: widget.mealType,
            mealData: widget.mealData,
            bgColor: widget.bgcolor,
          ));
          try {
            Get.find<TodayLogController>().onInit();
          } catch (e) {
            Get.put(TodayLogController());
          }
        });
        Get.snackbar('Changes Logged!',
            '${typeChange ? widget.logedData.title : widget.logedData.food[0].foodDetails[0]
                .foodName} logged successfully.',
            icon: const Padding(
                padding: EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        // if (this.mounted) {
        //   setState(() {
        //     submitted = false;
        //   });
        // }
        Get.close(1);
        Get.snackbar('Log not Changed', 'Encountered some error while logging. Please try again',
            icon: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.cancel_rounded, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  Widget _buildCupertinoPickerQuantity(BuildContext context, int i, int _length, Key key) {
    return ValueListenableBuilder(
        valueListenable: QuantityList.quantityList,
        builder: (_, val, __) {
          return CupertinoPicker.builder(
            backgroundColor: Colors.white,
            magnification: 1.3,
            key: key,
            scrollController: _scrollWheelController,
            itemExtent: 40,
            selectionOverlay: pickerContainer(),
            childCount: val.length,
            itemBuilder: (BuildContext context, int index) {
              return Center(
                  child: Text(val[index].toString(), style: const TextStyle(fontSize: 14)));
            },
            onSelectedItemChanged: (int _index) {
              MealCaloriesCalc.caloriesbool = true;
              _selectedIndexQuantity = _index;
              // double a =carbs.toInt();
              num calcCalories = CaloriesCalc().calculateCalories(
                  fixedQuantity,
                  fixedQuantity *
                      num.parse(typeChange
                          ? widget.logedData.extras
                          : widget.logedData.totalCaloriesGained) /
                      num.parse(typeChange
                          ? widget.logedData.quantity
                          : widget.logedData.food[0].foodDetails[0].foodQuantity.toString()),
                  num.parse(QuantityList.quantityList.value[_selectedIndexQuantity].toString()));
              MealCaloriesCalc.calories.value = calcCalories;
              Map nutrionData = CaloriesCalc().calculateNutrients(
                carbs.roundToDouble(),
                fiber.roundToDouble(),
                fat.roundToDouble(),
                num.parse('18.0'),
                fixedQuantity,
                num.parse(_selectedIndexQuantity.toString()),
              );
              MealNutriCalculations.nutrients.value = nutrionData;
            },
          );
        });
  }

  Widget _buildCupertinoPickerServingUnitType(BuildContext context, int i, int length, Key key) {
    return CupertinoPicker.builder(
      backgroundColor: Colors.white,
      magnification: 1.3,
      key: key,
      scrollController: ServingScrollWheelController,
      itemExtent: 40,
      selectionOverlay: pickerContainer(),
      childCount: length,
      itemBuilder: (BuildContext context, int index) {
        return Center(
            child: Text(
              quantity_type[index],
              style: TextStyle(fontSize: quantity_type[index].length > 10 ? 13.sp : 14.sp),
            ));
      },
      onSelectedItemChanged: (int index) {
        _selectedIndexQuantityType = index;
        initialPosition = QuantityList.quantityList.value
            .indexOf(QuantityList.quantityList.value[_selectedIndexQuantityType]);

        //  _indexQ = initialPosition;
        ServingScrollWheelController.animateToItem(initialPosition,
            duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
      },
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
          top: BorderSide(width: 1.0, color: Colors.black),
          bottom: BorderSide(width: 1.0, color: Colors.black),
        ),
        color: CupertinoDynamicColor.resolve(Colors.transparent, context),
      ),
    );
  }

  Future<EditLogUserFood> prepareForLog(FoodDetail fooddetail) async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    var _temp = MealCaloriesCalc.calories.value.toString();
    print(_temp);
    return EditLogUserFood(
        userIhlId: iHLUserId,
        foodLogId: widget.foodLogId,
        foodLogTime: '${typeChange ? widget.logedData.foodTime : widget.logedData.foodLogTime}',
        epochLogTime: typeChange ? widget.logedData.epochTime : widget.logedData.epochLogTime,
        foodTimeCategory: widget.mealType,
        caloriesGained: MealCaloriesCalc.caloriesbool
            ? MealCaloriesCalc.calories.value.toStringAsFixed(0)
            : "${typeChange ? widget.logedData.extras : widget.logedData.totalCaloriesGained}",
        // "${widget.logedData.totalCaloriesGained}", //calculateCalories('90', '1').toStringAsFixed(0),
        //  typeCheck?"${widget.logedData.extras}":"${widget.logedData.totalCaloriesGained}", '1').toStringAsFixed(0),
        food: [
          Food(foodDetails: [fooddetail])
        ]);
  }

// num calculateCalories(String defaultCalories, String quantity) {
//   if (quantity != null) {
//     if (double.parse('125'
//             '') >
//         1.0) {
//       return ((double.parse(defaultCalories) / double.parse('111')) * double.parse(quantity));
//     }
//     return (double.parse(defaultCalories) * double.parse(quantity));
//   } else {
//     return double.parse(defaultCalories);
//   }
// }
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
