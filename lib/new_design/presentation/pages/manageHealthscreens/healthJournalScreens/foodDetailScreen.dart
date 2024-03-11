import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../views/dietJournal/models/frequent_food_consumed.dart';
import '../../../../../views/dietJournal/models/get_frequent_food_consumed.dart';
import '../../../../app/utils/textStyle.dart';
import '../../../controllers/healthJournalControllers/calendarController.dart';
import '../../../controllers/healthJournalControllers/loadFoodList.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import 'caloriesCalculation.dart';
import 'foodLog1.dart';
import '../../../../../views/dietJournal/apis/list_apis.dart';
import '../../../../../views/dietJournal/apis/log_apis.dart';
import '../../../../../views/dietJournal/models/food_deatils_updated.dart';
import '../../../../../views/dietJournal/models/food_unit_detils.dart';
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
import '../../../controllers/healthJournalControllers/getTodayLogController.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodId;
  final String logDate;
  final mealType;
  final mealData;
  final baseColor;
  final String title;

  const FoodDetailScreen(
      {Key key,
      @required this.baseColor,
      @required this.foodId,
      @required this.mealType,
      @required this.logDate,
      @required this.title,
      @required this.mealData})
      : super(key: key);

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  UpdatedFoodDetails foodDetail;
  var _chosenType;
  var _bgColor;
  RxBool _fvrt = false.obs;

  final FoodDetailController _foodDetailController = Get.find<FoodDetailController>();
  int initialPosition = 0;
  FixedExtentScrollController _scrollWheelController;
  LogButtonLoader buttonLoader = LogButtonLoader();

  @override
  void initState() {
    // Get.put(FoodDataLoaderController());
    // final FoodDataLoaderController _foodDataContoller = Get.find();

    _scrollWheelController = FixedExtentScrollController(initialItem: initialPosition);
    getIhlUserId();

    Iterable<FoodListTileModel> contain = _foodDetailController.favList
        .where((FoodListTileModel element) => element.foodItemID == widget.foodId);
    if (contain.isNotEmpty) {
      _fvrt.value = true;
    } else {
      _fvrt.value = false;
    }
    checkbookmark();
    _calController.updateMealType(widget.mealType);

    _chosenType = _calController.maelType.value;
    _bgColor = _calController.bgColor.value;

    super.initState();
  }

  void checkbookmark() async {
    // Get.find<FoodDetailController>().getBookMarkedFoodDetail();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList("bookmarked_foods");
  }

  final ClendarController _calController = Get.put(ClendarController());
  TimeOfDay selectedTime = TimeOfDay.now();
  String iHLUserId;

  getIhlUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    iHLUserId = prefs.getString('ihlUserId');
    _calController.updateTime(TimeOfDay.now(), widget.logDate);
  }

  String quantityUnit;
  num quantity;
  num fixedQuantity;
  num fixedCalories;
  num protein;
  num carbs;
  num fats;
  num fiber;
  num valueText = 0;
  int servingTypeIndex = 0;
  int _indexQ = 0;

  Map nutrionData;
  String servingType = '';

  Widget loadAssetImage() {
    return Container(
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
          borderRadius: BorderRadius.all(Radius.circular(12.sp)),
          image: const DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                'newAssets/images/foodimage.png',
              ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: AppBar(
        actions: [
          Obx(() {
            return IconButton(
              icon: Icon(_fvrt.value ? Icons.favorite : Icons.favorite_border, color: Colors.white),
              onPressed: () {
                bookmarkActivity();
              },
            );
          }),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            Get.to(LogFoodLanding(
              bgColor: widget.baseColor,
              mealData: widget.mealData,
              mealType: widget.mealType,
            ));
          }, //replaces the screen to Main dashboard
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text(widget.title),
        backgroundColor: widget.baseColor,
        // backgroundColor: widget.baseColor,
      ),
      content: GetBuilder<FoodDataLoaderController>(
          id: "FoodData",
          init: FoodDataLoaderController(widget.foodId),
          builder: (FoodDataLoaderController foodDetail) {
            List<GetFoodUnit> foodUnit;

            bool loadData = foodDetail.foodDetail == null;
            loadData ? foodUnit = [] : foodUnit = foodDetail.foodUnit;
            loadData
                ? {}
                : {
                    quantity = num.parse(foodDetail.foodDetail.quantity),
                    quantityUnit = foodDetail.foodDetail.servingUnitSize,
                    fixedCalories = num.parse(foodDetail.foodDetail.calories),
                    fixedQuantity = num.parse(foodDetail.foodDetail.quantity),
                    servingType = foodDetail.foodDetail.servingUnitSize.toString(),
                  };
            return loadData
                ? SizedBox(
                    height: 100.h,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
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
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
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
                            loadAssetImage(),
                            Padding(
                              padding: EdgeInsets.only(top: 2.h, bottom: 8.0),
                              child: SizedBox(
                                width: 86.w,
                                child: Row(
                                  children: <Widget>[
                                    foodDetail.foodDetail.dish != null
                                        ? SizedBox(
                                            width: 40.w,
                                            child: Text(
                                              foodDetail.foodDetail.dish,
                                              style: AppTextStyles.content4,
                                            ),
                                          )
                                        : Shimmer.fromColors(
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
                                    const Spacer(),
                                    ValueListenableBuilder(
                                        valueListenable: InitialMealCaloriesCalc.calories,
                                        builder: (_, val, __) {
                                          return Text(
                                            val.toStringAsFixed(0) + " Cal",
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
                                                style:
                                                    TextStyle(color: Colors.white, fontSize: 15.sp),
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
                                  children: <Widget>[
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
                                        // _calController.maelType.value = value;
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
                                        TimeOfDay picked = await showTimePicker(
                                            context: context,
                                            initialTime: selectedTime,
                                            builder: (BuildContext context, Widget child) {
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
                                        picked ??= TimeOfDay.now();
                                        _calController.updateTime(picked, widget.logDate);
                                        selectedTime = _calController.initSelectedTime.value;
                                      },
                                    ),
                                    Obx(() => InkWell(
                                          onTap: () async {
                                            TimeOfDay picked = await showTimePicker(
                                                context: context,
                                                initialTime: selectedTime,
                                                builder: (BuildContext context, Widget child) {
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
                                            picked ??= TimeOfDay.now();
                                            _calController.updateTime(picked, widget.logDate);
                                            selectedTime = _calController.initSelectedTime.value;
                                          },
                                          child: Text(
                                            HealthJournalSearvices().convertTimeOfDayToDateTime(
                                                format: 'h:mm a',
                                                time: _calController.initSelectedTime.value),
                                            style: TextStyle(color: widget.baseColor),
                                          ),
                                        )),
                                    // Obx(()=>
                                    //
                                    //     Visibility(
                                    //       visible: _calController.futureSelected.value,
                                    //       child: Text("Future Time is selected!",style: TextStyle(color: Colors.red,),
                                    //       ),
                                    //     )),
                                    const Spacer(
                                      flex: 2,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12.sp),
                              child: Card(
                                elevation: 4,
                                child: SizedBox(
                                  height: 23.h,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.sp, right: 25.sp, top: 20.sp, bottom: 10.sp),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
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
                                                                      _quantityForm =
                                                                      GlobalKey<FormState>();
                                                                  showDialog(
                                                                      context: context,
                                                                      builder: (BuildContext ctx) {
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
                                                                              key: _quantityForm,
                                                                              child: TextFormField(
                                                                                enableInteractiveSelection:
                                                                                    false,
                                                                                autovalidateMode:
                                                                                    AutovalidateMode
                                                                                        .onUserInteraction,
                                                                                inputFormatters: [
                                                                                  // DoubleInputFormatter()
                                                                                ],
                                                                                validator:
                                                                                    (String v) {
                                                                                  num _v =
                                                                                      num.tryParse(
                                                                                          v);
                                                                                  if (_v != null) {
                                                                                    if (_v
                                                                                        .isGreaterThan(
                                                                                            2000)) {
                                                                                      return 'Invalid quantity';
                                                                                    } else {
                                                                                      return null;
                                                                                    }
                                                                                  } else {
                                                                                    return "Enter valid input";
                                                                                  }
                                                                                },
                                                                                textInputAction:
                                                                                    TextInputAction
                                                                                        .done,
                                                                                keyboardType:
                                                                                    const TextInputType
                                                                                            .numberWithOptions(
                                                                                        decimal:
                                                                                            true),
                                                                                onChanged:
                                                                                    (String value) {
                                                                                  if (mounted) {
                                                                                    setState(() {
                                                                                      valueText =
                                                                                          num.parse(
                                                                                              value);
                                                                                      print(
                                                                                          valueText);
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
                                                                                      Colors.white,
                                                                                  child: const Text(
                                                                                      'OK'),
                                                                                  onPressed: () {
                                                                                    if (_quantityForm
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
                                                                                      Navigator.pop(
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
                                                        return SizedBox(
                                                          width: 30.w,
                                                          height: 12.h,
                                                          child: CupertinoPicker.builder(
                                                            scrollController:
                                                           _scrollWheelController,
                                                            itemExtent: 40,
                                                            selectionOverlay: pickerContainer(),
                                                            childCount: val.length,
                                                            onSelectedItemChanged: (int _indexQ) {
                                                              quantity = val[_indexQ];

                                                              num calcCalories = CaloriesCalc()
                                                                  .calculateCalories(
                                                                      fixedQuantity,
                                                                      num.parse(
                                                                          fixedCalories.toString()),
                                                                      num.parse(
                                                                          quantity.toString()));
                                                              InitialMealCaloriesCalc
                                                                  .calories.value = calcCalories;
                                                              fats = num.parse(
                                                                  foodUnit[servingTypeIndex].fats);
                                                              fiber = num.parse(
                                                                  foodUnit[servingTypeIndex].fiber);
                                                              protein = num.parse(
                                                                  foodUnit[servingTypeIndex]
                                                                      .protein);
                                                              carbs = num.parse(
                                                                  foodUnit[servingTypeIndex].carbs);
                                                              Map nutrionData =
                                                                  CaloriesCalc().calculateNutrients(
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
                                                            itemBuilder:
                                                                (BuildContext context, int index) {
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
                                                    // height: foodUnit.length > 1 ? 1.5.h : 2.5.h,
                                                    height: 1.2.h,
                                                  ),
                                                  SizedBox(
                                                    width: 33.w,
                                                    height: 12.h,
                                                    child: CupertinoPicker.builder(
                                                      itemExtent: 40,
                                                      selectionOverlay: pickerContainer(),
                                                      childCount: foodUnit.length,
                                                      onSelectedItemChanged: (int _index) {
                                                        servingType = foodUnit[_index]
                                                            .servingUnitSize
                                                            .toString();
                                                        quantity =
                                                            num.parse(foodUnit[_index].quantity);
                                                        fixedQuantity =
                                                            num.parse(foodUnit[_index].quantity);
                                                        fixedCalories =
                                                            num.parse(foodUnit[_index].calories);

                                                        fats = num.parse(foodUnit[_index].fats);
                                                        fiber = num.parse(foodUnit[_index].fiber);
                                                        protein =
                                                            num.parse(foodUnit[_index].protein);
                                                        carbs = num.parse(foodUnit[_index].carbs);
                                                        servingTypeIndex = _index;
                                                        initialPosition = FoodQuantityList
                                                            .quantityList.value
                                                            .indexOf(quantity);
                                                        _indexQ = initialPosition;
                                                        _scrollWheelController.animateToItem(
                                                            initialPosition,
                                                            duration: const Duration(seconds: 1),
                                                            curve: Curves.fastOutSlowIn);
                                                      },
                                                      itemBuilder:
                                                          (BuildContext context, int index) {
                                                        return Center(
                                                            child: Text(
                                                          foodUnit[index]
                                                              .servingUnitSize
                                                              .toString(),
                                                          style: TextStyle(fontSize: 16.sp),
                                                        ));
                                                      },
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
                            Padding(
                              padding: EdgeInsets.all(12.sp),
                              child: Card(
                                elevation: 4,
                                child: Container(
                                  padding: EdgeInsets.only(left: 12.sp, top: 15.sp),
                                  height: 18.h,
                                  child: ValueListenableBuilder(
                                      valueListenable: InitialMealNutriCalculations.nutrients,
                                      builder: (_, val, __) {
                                        return Column(
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                'Nutrients',
                                                style: AppTextStyles.content5,
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
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
                                                          val['protein'].toStringAsFixed(2) !=
                                                                  "0.00"
                                                              ? val['protein'].toStringAsFixed(2) +
                                                                  "g"
                                                              : "--",
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                              color: widget.baseColor)),
                                                      const Spacer(),
                                                      const Text("Fats"),
                                                      const Spacer(),
                                                      Text(
                                                          val['fats'].toStringAsFixed(2) != "0.00"
                                                              ? val['fats'].toStringAsFixed(2) + "g"
                                                              : "--",
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
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      const Text("Carbs     "),
                                                      const Spacer(),
                                                      Text(
                                                          val['carbs'].toStringAsFixed(2) != "0.00"
                                                              ? val['carbs'].toStringAsFixed(2) +
                                                                  "g"
                                                              : "--",
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                              color: widget.baseColor)),
                                                      const Spacer(),
                                                      const Text(" Fibre"),
                                                      const Spacer(),
                                                      Text(
                                                          val['fiber'].toStringAsFixed(2) != "0.00"
                                                              ? val['fiber'].toStringAsFixed(2) +
                                                                  "g"
                                                              : "--",
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                              color: widget.baseColor)),
                                                    ],
                                                  ),
                                                )
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
                              child: Obx(() => FloatingActionButton.extended(
                                  onPressed: buttonLoader.isButtonLoading.value
                                      ? () {}
                                      : () async {
                                          // logMeal();
                                    DateTime startDate;
                                          buttonLoader.isButtonLoading.value = true;
                                          if (_calController.futureSelected.value) {
                                            Get.snackbar(
                                                'Future Time is not allowed, Change the time',
                                                "Future Time Alert!",
                                                icon: const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Icon(Icons.warning_amber,
                                                        color: Colors.white)),
                                                margin:
                                                    const EdgeInsets.all(20).copyWith(bottom: 40),
                                                backgroundColor: widget.baseColor,
                                                colorText: Colors.white,
                                                duration: const Duration(seconds: 6),
                                                snackPosition: SnackPosition.BOTTOM);
                                            buttonLoader.isButtonLoading.value = false;
                                          } else {
                                            String foodLogTime =
                                                "${widget.logDate} ${selectedTime.hour}:${selectedTime.minute}:00";
                                            String logEndTime = "${widget.logDate} 23:59:00";
                                            DateTime tempDate = DateFormat("yyyy-MM-dd HH:mm:ss")
                                                .parse(foodLogTime);

                                            int epochTime = tempDate.millisecondsSinceEpoch;
                                            FoodDetail fooddetail = FoodDetail(
                                                foodId: widget.foodId,
                                                foodName: foodDetail.foodDetail.dish,
                                                foodQuantity: quantity.toString(),
                                                quantityUnit: servingType);
                                            LogUserFood logFood = await LogUserFood(
                                                userIhlId: iHLUserId,
                                                foodLogTime: tempDate,
                                                epochLogTime: epochTime,
                                                foodTimeCategory: _chosenType,
                                                caloriesGained: InitialMealCaloriesCalc
                                                    .calories.value
                                                    .toStringAsFixed(0),
                                                food: [
                                                  Food(foodDetails: [fooddetail])
                                                ]);
                                            LogApis.logUserFoodIntakeApi(data: logFood)
                                                .then((LogUserFoodIntakeResponse value) {
                                              if (value != null) {
                                                ListApis.getUserTodaysFoodLogApi(_chosenType)
                                                    .then((value) {
                                                   startDate =
                                                      DateFormat("yyyy-MM-dd").parse(foodLogTime);
                                                });
                                              }
                                              LogApis.frequentFoodGroupMeal(
                                                  meal_category: _chosenType,
                                                  foodFoodIdList: foodDetail.foodID,
                                                  foodQuantityList:
                                                  foodDetail.foodDetail.quantity,
                                                  foodNamelist: foodDetail.foodDetail.dish)
                                                  .then((FrequentFoodConsumed value) {
                                                if (value != null) {
                                                  ListApis.list_user_frequent_food_log()
                                                      .then((GetFrequentFoodConsumed value) {
                                                    if (value != null) {
                                                       startDate =
                                                      DateFormat("yyyy-MM-dd").parse(foodLogTime);

                                                      Get.delete<FoodDataLoaderController>();
                                                      Get.delete<TodayLogController>();
                                                      Get.to(LogFoodLanding(
                                                        mealType: _calController.maelType.value,
                                                        bgColor: _bgColor,
                                                        mealData: widget.mealData,
                                                        date: startDate, frequentFood:value.status??'',
                                                      ));
                                                    }
                                                  });
                                                }
                                              });
                                              // Get.delete<FoodDataLoaderController>();
                                              // Get.delete<TodayLogController>();
                                              // Get.to(LogFoodLanding(
                                              //   mealType: _calController.maelType.value,
                                              //   bgColor: _bgColor,
                                              //   mealData: widget.mealData,
                                              //   date: startDate,
                                              // ));
                                              // Get.snackbar('Logged!',
                                              //     '${camelize(foodDetail.foodDetail.dish)} logged successfully.',
                                              //     icon: const Padding(
                                              //         padding: EdgeInsets.all(8.0),
                                              //         child: Icon(Icons.check_circle,
                                              //             color: Colors.white)),
                                              //     margin: const EdgeInsets.all(20)
                                              //         .copyWith(bottom: 40),
                                              //     backgroundColor: _bgColor,
                                              //     colorText: Colors.white,
                                              //     duration: const Duration(seconds: 5),
                                              //     snackPosition: SnackPosition.BOTTOM);
                                              // else {
                                              //   Get.snackbar('Food not Logged',
                                              //       'Cannot login multiple foods in same time. Please try again',
                                              //       icon: const Padding(
                                              //           padding: EdgeInsets.all(8.0),
                                              //           child: Icon(Icons.cancel_rounded,
                                              //               color: Colors.white)),
                                              //       margin: const EdgeInsets.all(20)
                                              //           .copyWith(bottom: 40),
                                              //       backgroundColor: Colors.red,
                                              //       colorText: Colors.white,
                                              //       duration: const Duration(seconds: 5),
                                              //       snackPosition: SnackPosition.BOTTOM);
                                              // }
                                            });

                                          }
                                        },
                                  backgroundColor: buttonLoader.isButtonLoading.value
                                      ? Colors.grey
                                      : _calController.futureSelected.value
                                          ? Colors.grey
                                          : widget.baseColor,
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
                                          'Add Food',
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
                              height: 12.h,
                            )
                          ],
                        ),
                      ),
                    ),
                  );
          }),
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

  void bookmarkActivity() async {
    if (!_fvrt.value) {
      await LogApis.bookmarkFoodApi(foodItemID: widget.foodId).then((String data) async {
        if (data != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> bookmarks = prefs.getStringList("bookmarked_foods") ?? [];
          print('bookmarks====$bookmarks');
          if (!bookmarks.contains(widget.foodId)) {
            bookmarks.add(widget.foodId);
            prefs.setStringList("bookmarked_foods", bookmarks);
          }
          // if (mounted)
          //   setState(() {
          //     bookmarked = true;
          //   });
          await ListApis.updatedGetFoodDetails(foodID: widget.foodId)
              .then((UpdatedFoodDetails data) {
            _foodDetailController.favList.add(FoodListTileModel(
              foodItemID: data.foodId,
              title: data.dish,

              ///old subtitle
              ///"${details[i].quantity ?? 1} ${camelize(details[i].quantityUnit)} | ${details[i].calories} kCal",
              subtitle:
                  "${data.quantity ?? 1} ${camelize(data.servingUnitSize ?? 'Nos')} | ${data.calories ?? 0} Cal",
            ));
          });
          Iterable<FoodListTileModel> contain = _foodDetailController.favList
              .where((FoodListTileModel element) => element.foodItemID == widget.foodId);
          if (contain.isNotEmpty) {
            _fvrt.value = true;
          } else {
            _fvrt.value = false;
          }
          _foodDetailController.update(['FoodDetailsScreen']);
        }

        Get.snackbar('Bookmarked!', 'added to your bookmarks',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(_fvrt.value ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: widget.baseColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 1),
            snackPosition: SnackPosition.BOTTOM);
      });
    } else {
      Get.snackbar('Bookmark Removed!', 'removed from your bookmarks.',
          icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Icon(_fvrt.value ? Icons.favorite : Icons.favorite_border, color: Colors.white)),
          margin: const EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: widget.baseColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.BOTTOM);
      // if (mounted) {
      //   setState(() {
      //     bookmarked = false;
      //   });
      // }
      _foodDetailController.favList
          .removeWhere((FoodListTileModel element) => element.foodItemID == widget.foodId);
      Iterable<FoodListTileModel> contain = _foodDetailController.favList
          .where((FoodListTileModel element) => element.foodItemID == widget.foodId);
      if (contain.isNotEmpty) {
        _fvrt.value = true;
      } else {
        _fvrt.value = false;
      }
      _foodDetailController.update(['FoodDetailsScreen']);
      await LogApis.deleteBookmarkFoodApi(foodItemID: widget.foodId).then((String data) async {
        if (data != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> bookmarks = prefs.getStringList("bookmarked_foods") ?? [];
          if (bookmarks.contains(widget.foodId)) {
            bookmarks.remove(widget.foodId);
            prefs.setStringList("bookmarked_foods", bookmarks);
          }
          Get.find<FoodDetailController>().deleteBookMarkedDetail(widget.foodId);
          _foodDetailController.update(['FoodDetailsScreen']);

          // if (mounted) {
          //   setState(() {
          //     bookmarked = false;
          //   });
          // }
        } else {
          Get.snackbar('Bookmark not removed!', 'Try Later',
              icon: const Padding(
                  padding: EdgeInsets.all(8.0), child: Icon(Icons.favorite, color: Colors.white)),
              margin: const EdgeInsets.all(20).copyWith(bottom: 40),
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
          // bookmarked = true;
        }
      });
    }
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

class DoubleInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String filteredValue = newValue.text;
    if (filteredValue.isNotEmpty) {
      // Remove any non-digit or non-decimal characters from the input
      filteredValue = filteredValue.replaceAll(RegExp(r'[^0-9.]'), '');

      // Split the value by the decimal point
      List<String> parts = filteredValue.split('.');
      if (parts.length > 2) {
        // More than one decimal point found, return the old value
        return oldValue;
      } else if (parts.length == 2 && parts[1].length > 2) {
        // More than two decimal places found, return the old value
        return oldValue;
      }
    }

    // Return the filtered value
    return TextEditingValue(
      text: filteredValue,
      selection: TextSelection.collapsed(offset: filteredValue.length),
    );
  }
}
