import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/utils/appColors.dart';
import '../../../../app/utils/textStyle.dart';
import '../../../controllers/healthJournalControllers/calendarController.dart';
import '../../../controllers/healthJournalControllers/getTodayLogController.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import 'caloriesCalculation.dart';
import 'editCustomeFood.dart';
import 'foodLog1.dart';
import '../../../../../utils/SpUtil.dart';
import '../../../../../views/dietJournal/apis/list_apis.dart';
import '../../../../../views/dietJournal/apis/log_apis.dart';
import '../../../../../views/dietJournal/models/view_custom_food_model.dart';
import '../../../../../views/dietJournal/stats/info_quantity_screen.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:strings/strings.dart';

import '../../../../../views/dietJournal/models/food_list_tab_model.dart';
import '../../../../../views/dietJournal/models/log_user_food_intake_model.dart';
import '../../../../app/services/managehealth/healthJournal.dart';
import '../../../controllers/healthJournalControllers/foodDetailController.dart';
import '../../../controllers/healthJournalControllers/loadFoodList.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class CustomeFoodDetailScreen extends StatefulWidget {
  final foodId;
  final String logDate;
  final mealType;
  final MealsListData mealData;
  final baseColor;
  final String foodName;
  CustomeFoodDetailScreen(
      {Key key,
      @required this.baseColor,
      @required this.foodId,
      @required this.mealType,
      @required this.logDate,
      @required this.mealData,
      @required this.foodName})
      : super(key: key);

  @override
  State<CustomeFoodDetailScreen> createState() => _CustomeFoodDetailScreenState();
}

class _CustomeFoodDetailScreenState extends State<CustomeFoodDetailScreen> {
  List<ListCustomRecipe> foodDetail;
  FixedExtentScrollController _scrollWheelController;
  int initialPosition = 0;
  num valueText = 0;
  var _chosenType;
  var _bgColor;
  LogButtonLoader buttonLoader = LogButtonLoader();
  @override
  void initState() {
    // Get.put(FoodDataLoaderController());
    // final FoodDataLoaderController _foodDataContoller = Get.find();
    getIhlUserId();

    Get.put(CustomeFoodDataLoaderController(widget.foodId));
    // initialPosition = QuantityList.quantityList.value.indexOf();
    _scrollWheelController = FixedExtentScrollController(initialItem: initialPosition);
    _calController.updateMealType(widget.mealType);
    _chosenType = _calController.maelType.value;
    _bgColor = _calController.bgColor.value;

    super.initState();
  }

  final ClendarController _calController = Get.put(ClendarController());
  TimeOfDay selectedTime = TimeOfDay.now();
  String iHLUserId;
  var tempDateConv;
  getIhlUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    iHLUserId = prefs.getString('ihlUserId');
    tempDateConv = DateFormat('yyyy-MM-dd').parse(widget.logDate);
    _calController.updateTime(TimeOfDay.now(), DateFormat("yyyy-MM-dd").format(tempDateConv));
  }

  Map nutrionData;
  num quantity;
  num fixedQuantity;
  num fixedCalories;
  num protein;
  num carbs;
  num fats;
  num fiber;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.delete<CustomeFoodDataLoaderController>();
        Get.back();
        return null;
      },
      child: CommonScreenForNavigation(
        appBar: AppBar(
          actions: [
            GetBuilder<CustomeFoodDataLoaderController>(
                id: "CusFoodData",
                init: CustomeFoodDataLoaderController(widget.foodId),
                builder: (CustomeFoodDataLoaderController foodDetail) {
                  return InkWell(
                      onTap: () {
                        Get.to(EditCustomFood(
                          mealType: widget.mealType,
                          baseColor: widget.baseColor,
                          recipeDetails: foodDetail.customeFoodDetail,
                          mealData: widget.mealData,
                        ));
                      },
                      child: const Icon(Icons.edit, color: Colors.white));
                }),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  AwesomeDialog(
                    context: context,
                    animType: AnimType.TOPSLIDE,
                    dialogType: DialogType.WARNING,
                    title: "Confirm!",
                    desc: "Are you sure to delete this log",
                    btnOkOnPress: () async {
                      deleteFood();
                    },
                    btnCancelOnPress: () {},
                    btnCancelText: "Cancel",
                    btnOkText: "Delete",
                    btnCancelColor: AppColors.primaryAccentColor,
                    // btnOkColor: widget.screenColor,
                  ).show();
                  // final value = await showDialog<bool>(
                  //     context: context,
                  //     barrierDismissible: false,
                  //     builder: (context) {
                  //       return AlertDialog(
                  //         title: Center(child: Text('Alert')),
                  //         content: Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           crossAxisAlignment: CrossAxisAlignment.center,
                  //           children: <Widget>[
                  //             Expanded(
                  //               child: Text(
                  //                 'Are you sure you want \n to delete the meal?',
                  //                 textAlign: TextAlign.center,
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //         actions: <Widget>[
                  //           Row(
                  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //               children: <Widget>[
                  //                 TextButton(
                  //                   child: Text(
                  //                     'No',
                  //                     style: TextStyle(fontSize: 18),
                  //                   ),
                  //                   onPressed: () {
                  //                     Navigator.of(context).pop();
                  //                   },
                  //                 ),
                  //                 TextButton(
                  //                   child: Text(
                  //                     'Yes',
                  //                     style: TextStyle(color: Colors.red, fontSize: 18),
                  //                   ),
                  //                   onPressed: () {},
                  //                 ),
                  //               ])
                  //         ],
                  //       );
                  //     });
                },
              ),
            )
          ],

          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              Get.delete<CustomeFoodDataLoaderController>();
              Get.to(LogFoodLanding(
                bgColor: widget.baseColor,
                mealData: widget.mealData,
                mealType: widget.mealType,
              ));
            }, //replaces the screen to Main dashboard
            color: Colors.white,
          ),
          centerTitle: true,

          title: Text(
            widget.foodName.capitalize,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          backgroundColor: widget.baseColor,
          // backgroundColor: widget.baseColor,
        ),
        content: GetBuilder<CustomeFoodDataLoaderController>(
            id: "CusFoodData",
            init: CustomeFoodDataLoaderController(widget.foodId),
            builder: (CustomeFoodDataLoaderController foodDetail) {
              // foodDetail.getFoodDetail(widget.foodId);
              bool loadData = foodDetail.customeFoodDetail == null;
              loadData
                  ? {fixedQuantity = 0.25, fixedCalories = 0}
                  : {
                      protein = double.parse(foodDetail.customeFoodDetail.protein),
                      fats = double.parse(foodDetail.customeFoodDetail.fats),
                      fiber = double.parse(foodDetail.customeFoodDetail.fiber),
                      carbs = double.parse(foodDetail.customeFoodDetail.carbs),
                      quantity = double.parse(foodDetail.customeFoodDetail.quantity),
                      fixedQuantity = double.parse(foodDetail.customeFoodDetail.quantity),
                      fixedCalories = double.parse(foodDetail.customeFoodDetail.calories),
                      initialPosition = QuantityList.quantityList.value
                          .indexOf(num.parse(foodDetail.customeFoodDetail.quantity)),
                      _scrollWheelController =
                          FixedExtentScrollController(initialItem: initialPosition),
                    };
              return loadData
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
                                  width: 90.w,
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
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Image.asset(
                                      'newAssets/images/foodimage.png',
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 2.h, bottom: 8.0),
                                child: SizedBox(
                                  width: 86.w,
                                  child: Row(
                                    children: [
                                      foodDetail.customeFoodDetail.dish != null
                                          ? SizedBox(
                                              width: 40.w,
                                              child: Text(
                                                foodDetail.customeFoodDetail.dish.capitalize,
                                                style: AppTextStyles.content4,
                                              ),
                                            )
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
                                          valueListenable: InitialMealCaloriesCalc.calories,
                                          builder: (_, val, __) {
                                            return Text(
                                              val.toStringAsFixed(2) + " Cal",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: widget.baseColor),
                                            );
                                          }),
                                      const Spacer(
                                        flex: 3,
                                      ),
                                      GestureDetector(
                                        onTap: () => Get.to(InfoQuantityScreen(
                                          appBarColor: widget.baseColor,
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
                                                    color: widget.baseColor))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Obx(
                                () => Padding(
                                  padding: EdgeInsets.only(left: 17.5.sp),
                                  child: Row(
                                    children: [
                                      DropdownButton<String>(
                                        focusColor: Colors.white,
                                        value: _calController.maelType.value,
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
                                        onChanged: (String value) {
                                          _calController.updateMealType(value);
                                          _chosenType = _calController.maelType.value;
                                          _bgColor = _calController.bgColor.value;
                                        },
                                      ),
                                      const Spacer(),
                                      InkWell(
                                        splashColor: Colors.red, // inkwell color
                                        child: const SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: Icon(
                                            Icons.timelapse_sharp,
                                            color: Colors.black,
                                          ),
                                        ),
                                        onTap: () async {
                                          final TimeOfDay picked = await showTimePicker(
                                              context: context,
                                              errorInvalidText: "Future Time not allowed",
                                              initialTime: selectedTime,
                                              useRootNavigator: false,
                                              builder: (context, child) {
                                                return MediaQuery(
                                                    data: MediaQuery.of(context)
                                                        .copyWith(alwaysUse24HourFormat: false),
                                                    child: Theme(
                                                      data: Theme.of(context).copyWith(
                                                          colorScheme: ColorScheme.light(
                                                              primary: widget.baseColor)),
                                                      child: child,
                                                    ));
                                              });
                                          if (picked != null) {
                                            _calController.updateTime(picked,
                                                DateFormat("yyyy-MM-dd").format(tempDateConv));
                                            selectedTime = _calController.initSelectedTime.value;
                                          }
                                        },
                                      ),
                                      Obx(() => InkWell(
                                            onTap: () async {
                                              final TimeOfDay picked = await showTimePicker(
                                                  context: context,
                                                  errorInvalidText: "Future Time not allowed",
                                                  initialTime: selectedTime,
                                                  useRootNavigator: false,
                                                  builder: (context, child) {
                                                    return MediaQuery(
                                                        data: MediaQuery.of(context)
                                                            .copyWith(alwaysUse24HourFormat: false),
                                                        child: Theme(
                                                          data: Theme.of(context).copyWith(
                                                              colorScheme: ColorScheme.light(
                                                                  primary: widget.baseColor)),
                                                          child: child,
                                                        ));
                                                  });
                                              if (picked != null) {
                                                _calController.updateTime(picked,
                                                    DateFormat("yyyy-MM-dd").format(tempDateConv));
                                                selectedTime =
                                                    _calController.initSelectedTime.value;
                                              }
                                            },
                                            child: Text(
                                              HealthJournalSearvices().convertTimeOfDayToDateTime(
                                                  format: 'h:mm a',
                                                  time: _calController.initSelectedTime.value),
                                              style: TextStyle(color: widget.baseColor),
                                            ),
                                          )),
                                      const Spacer(
                                        flex: 2,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // Obx(()=>
                              //
                              //     Visibility(
                              //       visible: _calController.futureSelected.value,
                              //       child: Text("Future Time is selected!",style: TextStyle(color: Colors.red,),
                              //       ),
                              //     )),
                              Padding(
                                padding: EdgeInsets.all(12.sp),
                                child: Card(
                                  elevation: 4,
                                  child: SizedBox(
                                    height: 23.h,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.sp, right: 25.sp, top: 25.sp, bottom: 10.sp),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              children: [
                                                Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Text('Add quantity'),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        ValueListenableBuilder(
                                                            valueListenable:
                                                                FoodQuantityList.quantityList,
                                                            builder: (_, val, __) {
                                                              return GestureDetector(
                                                                  onTap: () {
                                                                    final GlobalKey<FormState>
                                                                        quantityForm =
                                                                        GlobalKey<FormState>();
                                                                    showDialog(
                                                                        context: context,
                                                                        builder: (ctx) {
                                                                          return AlertDialog(
                                                                              shape:
                                                                                  RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                    BorderRadius
                                                                                        .circular(
                                                                                            10.0),
                                                                              ),
                                                                              title: const Text(
                                                                                  'Enter the quantity'),
                                                                              content: Form(
                                                                                key: quantityForm,
                                                                                child:
                                                                                    TextFormField(
                                                                                  enableInteractiveSelection:
                                                                                      false,
                                                                                  inputFormatters: [
                                                                                    // FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
                                                                                  ],
                                                                                  autovalidateMode:
                                                                                      AutovalidateMode
                                                                                          .onUserInteraction,
                                                                                  textInputAction:
                                                                                      TextInputAction
                                                                                          .done,
                                                                                  validator:
                                                                                      (String v) {
                                                                                    num _v = num
                                                                                        .tryParse(
                                                                                            v);
                                                                                    if (_v !=
                                                                                        null) {
                                                                                      if (_v.isGreaterThan(
                                                                                          2000)) {
                                                                                        return 'Invalid quantity';
                                                                                      } else {
                                                                                        return null;
                                                                                      }
                                                                                    } else {
                                                                                      return "Enter valid input";
                                                                                    }
                                                                                  },
                                                                                  keyboardType:
                                                                                      const TextInputType
                                                                                              .numberWithOptions(
                                                                                          decimal:
                                                                                              true),
                                                                                  onChanged: (String
                                                                                      value) {
                                                                                    if (mounted) {
                                                                                      setState(() {
                                                                                        valueText =
                                                                                            num.parse(
                                                                                                value);
                                                                                      });
                                                                                    }
                                                                                  },
                                                                                  decoration:
                                                                                      const InputDecoration(
                                                                                          hintText:
                                                                                              "quantity"),
                                                                                ),
                                                                              ),
                                                                              actions: <Widget>[
                                                                                MaterialButton(
                                                                                    shape:
                                                                                        RoundedRectangleBorder(
                                                                                      borderRadius:
                                                                                          BorderRadius
                                                                                              .circular(
                                                                                                  10.0),
                                                                                    ),
                                                                                    color: const Color(
                                                                                        0xffEE6143),
                                                                                    textColor:
                                                                                        Colors
                                                                                            .white,
                                                                                    child:
                                                                                        const Text(
                                                                                            'OK'),
                                                                                    onPressed: () {
                                                                                      if (quantityForm
                                                                                          .currentState
                                                                                          .validate()) {
                                                                                        quantity =
                                                                                            valueText;

                                                                                        if (!val.contains(
                                                                                            valueText)) {
                                                                                          FoodQuantityList
                                                                                              .quantityList
                                                                                              .value
                                                                                              .add(
                                                                                                  valueText);
                                                                                        }

                                                                                        FoodQuantityList
                                                                                            .quantityList
                                                                                            .value
                                                                                            .sort();

                                                                                        FoodQuantityList
                                                                                                .quantityList
                                                                                                .value =
                                                                                            FoodQuantityList
                                                                                                .quantityList
                                                                                                .value;

                                                                                        FoodQuantityList
                                                                                            .quantityList
                                                                                            .notifyListeners();

                                                                                        initialPosition = FoodQuantityList
                                                                                            .quantityList
                                                                                            .value
                                                                                            .indexOf(
                                                                                                quantity);

                                                                                        _scrollWheelController.animateToItem(
                                                                                            initialPosition,
                                                                                            duration: const Duration(
                                                                                                seconds:
                                                                                                    1),
                                                                                            curve: Curves
                                                                                                .easeInOut);

                                                                                        Navigator
                                                                                            .pop(
                                                                                                ctx);
                                                                                      }
                                                                                      //QuantityList.quantityList.dispose();
                                                                                    })
                                                                              ]);
                                                                        });
                                                                  },
                                                                  child: Icon(
                                                                    Icons.edit,
                                                                    size: 17.sp,
                                                                  ));
                                                            })
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    ValueListenableBuilder(
                                                        valueListenable:
                                                            FoodQuantityList.quantityList,
                                                        builder: (_, val, __) {
                                                          print(val.length);
                                                          return SizedBox(
                                                            width: 30.w,
                                                            height: 11.h,
                                                            child: CupertinoPicker.builder(
                                                              scrollController:
                                                                  _scrollWheelController,
                                                              itemExtent: 40,
                                                              selectionOverlay: pickerContainer(),
                                                              childCount: val.length,
                                                              onSelectedItemChanged: (int _index) {
                                                                quantity = val[_index];

                                                                num calcCalories = CaloriesCalc()
                                                                    .calculateCalories(
                                                                        fixedQuantity,
                                                                        num.parse(fixedCalories
                                                                            .toString()),
                                                                        num.parse(
                                                                            quantity.toString()));
                                                                InitialMealCaloriesCalc
                                                                    .calories.value = calcCalories;
                                                                Map nutrionData = CaloriesCalc()
                                                                    .calculateNutrients(
                                                                  carbs,
                                                                  fiber,
                                                                  fats,
                                                                  protein,
                                                                  fixedQuantity,
                                                                  num.parse(quantity.toString()),
                                                                );
                                                                InitialMealNutriCalculations
                                                                    .nutrients.value = nutrionData;
                                                              },
                                                              itemBuilder: (context, index) {
                                                                return Center(
                                                                    child: Text(
                                                                  val[index].toString(),
                                                                  style: TextStyle(fontSize: 17.sp),
                                                                ));
                                                              },
                                                            ),
                                                          );
                                                        }),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Column(
                                                  children: [
                                                    const Text('Serving Type'),
                                                    SizedBox(
                                                      height: 5.h,
                                                    ),
                                                    Text(foodDetail
                                                        .customeFoodDetail.servingUnitSize),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ]),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12.sp),
                                child: Card(
                                  elevation: 4,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 12.sp, top: 15.sp,bottom: 15.sp),
                                    height: 18.h,
                                    child: ValueListenableBuilder(
                                        valueListenable: InitialMealNutriCalculations.nutrients,
                                        builder: (_, val, __) {
                                          return Column(
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
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Text("Proteins"),
                                                        const Spacer(),
                                                        Text(
                                                            val["protein"].toStringAsFixed(2) ==
                                                                    "0.00"
                                                                ? "--"
                                                                : val["protein"]
                                                                        .toStringAsFixed(2) +
                                                                    " g",
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.w500,
                                                                color: widget.baseColor)),
                                                        const Spacer(),
                                                        const Text("Fats"),
                                                        const Spacer(),
                                                        Text(
                                                            val["fats"].toStringAsFixed(2) == "0.00"
                                                                ? "--"
                                                                : val["fats"].toStringAsFixed(2) +
                                                                    " g",
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
                                                      // mainAxisAlignment:
                                                      //     MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Text("Carbs"),
                                                        const Spacer(),
                                                        Text(
                                                            val["carbs"].toStringAsFixed(2) ==
                                                                    "0.00"
                                                                ? "--"
                                                                : val["carbs"].toStringAsFixed(2) +
                                                                    " g",
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.w500,
                                                                color: widget.baseColor)),
                                                        const Spacer(),
                                                        const Text("Fibre"),
                                                        const Spacer(),
                                                        Text(
                                                            val["fiber"].toStringAsFixed(2) ==
                                                                    "0.00"
                                                                ? "--"
                                                                : val["fiber"].toStringAsFixed(2) +
                                                                    " g",
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.w500,
                                                                color: widget.baseColor)),
                                                      ],
                                                    ),
                                                  ),

                                                ],
                                              )
                                            ],
                                          );
                                        }),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Obx(
                                  () => FloatingActionButton.extended(
                                      onPressed: buttonLoader.isButtonLoading.value?(){}:() async {
                                        // logMeal();

                                        if (_calController.futureSelected.value) {
                                          Get.snackbar(
                                              'Future Time is not allowed, Change the time',
                                              "Future Time Alert!",
                                              icon: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(Icons.warning_amber,
                                                      color: Colors.white)),
                                              margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                              backgroundColor: widget.baseColor,
                                              colorText: Colors.white,
                                              duration: const Duration(seconds: 6),
                                              snackPosition: SnackPosition.BOTTOM);
                                        } else {
                                          buttonLoader.isButtonLoading.value=true;
                                          var foodLogTime =
                                              "${DateFormat("yyyy-MM-dd").format(tempDateConv)} ${selectedTime.hour}:${selectedTime.minute}:00";
                                          var logEndTime =
                                              "${DateFormat("yyyy-MM-dd").format(tempDateConv)} 23:59:00";
                                          DateTime tempDate =
                                              DateFormat("yyyy-MM-dd HH:mm:ss").parse(foodLogTime);
                                          int epochTime = tempDate.millisecondsSinceEpoch;

                                          var fooddetail = FoodDetail(
                                              foodId: widget.foodId,
                                              foodName: foodDetail.customeFoodDetail.dish,
                                              foodQuantity: quantity.toString(),
                                              quantityUnit:
                                                  foodDetail.customeFoodDetail.servingUnitSize);
                                          var logFood = await LogUserFood(
                                              userIhlId: iHLUserId,
                                              foodLogTime: tempDate,
                                              epochLogTime: epochTime,
                                              foodTimeCategory: _chosenType,
                                              caloriesGained: InitialMealCaloriesCalc.calories.value
                                                  .toStringAsFixed(0),
                                              food: [
                                                Food(foodDetails: [fooddetail])
                                              ]);
                                          LogApis.logUserFoodIntakeApi(data: logFood).then((value) {
                                            if (value != null) {
                                              ListApis.getUserTodaysFoodLogApi(widget.mealType)
                                                  .then((value) {

                                                DateTime startDate =
                                                    DateFormat("yyyy-MM-dd").parse(foodLogTime);

                                                Get.to(LogFoodLanding(
                                                  mealType: _calController.maelType.value,
                                                  bgColor: _bgColor,
                                                  mealData: widget.mealData,
                                                  date: startDate,
                                                ));
                                                Get.snackbar('Logged!',
                                                    '${camelize(foodDetail.customeFoodDetail.dish)} logged successfully.',
                                                    icon: const Padding(
                                                        padding: EdgeInsets.all(8.0),
                                                        child: Icon(Icons.check_circle,
                                                            color: Colors.white)),
                                                    margin: const EdgeInsets.all(20)
                                                        .copyWith(bottom: 40),
                                                    backgroundColor: _bgColor,
                                                    colorText: Colors.white,
                                                    duration: const Duration(seconds: 5),
                                                    snackPosition: SnackPosition.BOTTOM);
                                              });
                                            } else {
                                              Get.snackbar('Food not Logged',
                                                  'Cannot login multiple foods in same time. Please try again',
                                                  icon: const Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: Icon(Icons.cancel_rounded,
                                                          color: Colors.white)),
                                                  margin:
                                                      const EdgeInsets.all(20).copyWith(bottom: 40),
                                                  backgroundColor: Colors.red,
                                                  colorText: Colors.white,
                                                  duration: const Duration(seconds: 5),
                                                  snackPosition: SnackPosition.BOTTOM);
                                            }
                                          });
                                        }
                                      },
                                      backgroundColor: buttonLoader.isButtonLoading.value?Colors.grey:_calController.futureSelected.value
                                          ? Colors.grey
                                          : widget.baseColor,
                                      label: buttonLoader.isButtonLoading.value?Shimmer.fromColors(
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
                                      ):const Text(
                                        'Add Food',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.set_meal,
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                              SizedBox(
                                height: 15.h,
                              )
                              // Padding(
                              //   padding: EdgeInsets.all(12.sp),
                              //   child: Card(
                              //     elevation: 4,
                              //     child: Container(
                              //       height: 16.h,
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ),
                    );
            }),
      ),
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

  void deleteRecents() async {
    await SpUtil.getInstance();
    List<FoodListTileModel> recentList = SpUtil.getRecentObjectList('recent_food') ?? [];
    bool exists = recentList.any((FoodListTileModel fav) => fav.foodItemID == widget.foodId);
    if (exists) {
      recentList.removeWhere((FoodListTileModel element) => element.foodItemID == widget.foodId);
    }
    SpUtil.putRecentObjectList('recent_food', recentList);
  }

  void deleteFood() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Get.snackbar('Deleted!', '${camelize(widget.foodName ?? 'Name Unknown')} deleted successfully.',
        icon: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.delete_forever,
              color: Colors.white,
            )),
        margin: const EdgeInsets.all(20).copyWith(bottom: 40),
        backgroundColor: AppColors.primaryAccentColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
        snackPosition: SnackPosition.BOTTOM);
    await LogApis.deleteCustomUserFoodApi(foodItemID: widget.foodId).then((data) async {
      // FoodDetailController().customFoodlist.removeWhere((e) => e.foodItemID == widget.foodId);
      if (data != null) {
        deleteRecents();
        Get.find<FoodDetailController>().onInit();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => LogFoodLanding(
                    mealType: widget.mealType,
                    bgColor: widget.baseColor,
                    mealData: widget.mealData)),
            (Route<dynamic> route) => false);
      } else {
        Get.snackbar('Error!', 'Food not deleted',
            icon: const Padding(
                padding: EdgeInsets.all(8.0), child: Icon(Icons.favorite, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }
}

class FoodQuantityList {
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

class InitialMealCaloriesCalc {
  static ValueNotifier<double> calories = ValueNotifier<double>(0.0);
}

class InitialMealNutriCalculations {
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
