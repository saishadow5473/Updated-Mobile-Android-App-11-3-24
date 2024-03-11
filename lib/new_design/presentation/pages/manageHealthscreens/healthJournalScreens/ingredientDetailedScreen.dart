import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/utils/appColors.dart';
import '../../../../data/providers/network/healthjournal/foodlogapi.dart';
import 'caloriesCalculation.dart';
import 'editCustomeFood.dart';
import '../../../../../views/dietJournal/models/create_edit_meal_model.dart';
import '../../../../../views/dietJournal/models/view_custom_food_model.dart';
import '../../../../../views/dietJournal/stats/info_quantity_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../dashboard/common_screen_for_navigation.dart';
import 'createNewMealScreen.dart';

class IngredientDetailedScreen extends StatefulWidget {
  IngredientDetailedScreen(
      {Key key,
      this.recipeDetails,
      @required this.mealData,
      @required this.nutrionInfoList,
      @required this.mealType,
      @required this.ingredientID,
      this.IngredientName,
      this.fixedQuantity,
      @required this.editMeal,
      @required this.selectedQuantity,
      @required this.baseColor,
      @required this.item_id,
      this.screen})
      : super(key: key);
  final List<dynamic> nutrionInfoList;
  final ListCustomRecipe recipeDetails;
  final mealData;
  final selectedQuantity;
  final String item_id;
  final bool editMeal;
  String IngredientName;
  final ingredientID;
  String fixedQuantity;
  final baseColor;
  final mealType;
  String screen;
  @override
  State<IngredientDetailedScreen> createState() => _IngredientDetailedScreenState();
}

class _IngredientDetailedScreenState extends State<IngredientDetailedScreen> {
  // var quantityList = [1, 2];
  List<String> items = List.generate(100, (int index) => 'Item $index');
  List<String> servingList = ['cup', 'ml', 'tablespoon'];
  var selectedValue;
  FixedExtentScrollController _scrollWheelController;
  FixedExtentScrollController _servingScrollWheelController;
  @override
  void initState() {
    updateScroll();
    asyncFunction();
    super.initState();
  }

  // List<String> servingTypesList = [];
  num carbs;
  num fats;
  num fiber;
  num protein;
  int initialPosition = 0;
  asyncFunction() async {
    await ingredeintServingTypegetter();
  }

  List<IngredientSizeModel> ingredientSizes = [];
  ingredeintServingTypegetter() async {
    QuantityList.servingTypesList.value = [];
    if (widget.item_id != null) {
      ingredientSizes = await FoodLogNetWorkApis().ingredientSizes(ingredientId: widget.item_id);

      ingredientSizes
          .map(
              (IngredientSizeModel e) => QuantityList.servingTypesList.value.add(e.servingUnitSize))
          .toList();
    } else {
      QuantityList.servingTypesList.value = [widget.nutrionInfoList[0]["serving_unit_size"]];
    }
    QuantityList.servingTypesList.notifyListeners();
  }

  void updateScroll() {
    Map<dynamic, dynamic> nutrionsList = widget.nutrionInfoList[0];
    carbs = num.parse(nutrionsList['carbs']);
    fats = num.parse(nutrionsList['fats']);
    fiber = num.parse(nutrionsList['fiber']);
    protein = num.parse(nutrionsList['protien'] ?? '0');

    initialPosition =
        QuantityList.quantityList.value.indexOf(double.parse(nutrionsList['quantity']));
    _scrollWheelController = FixedExtentScrollController(initialItem: initialPosition);

    double totalCalories = CaloriesCalc().calculateCalories(
        num.parse(widget.fixedQuantity),
        num.parse(nutrionsList['calories']) *
            (num.parse(widget.fixedQuantity) / num.parse(nutrionsList['quantity'])),
        num.parse(nutrionsList['quantity']));
    IngredientCaloriesCalc.calories.value = totalCalories;
    Map nutrionData = CaloriesCalc().calculateNutrients(
      carbs * (num.parse(widget.fixedQuantity) / num.parse(nutrionsList['quantity'])),
      fiber * (num.parse(widget.fixedQuantity) / num.parse(nutrionsList['quantity'])),
      fats * (num.parse(widget.fixedQuantity) / num.parse(nutrionsList['quantity'])),
      protein * (num.parse(widget.fixedQuantity) / num.parse(nutrionsList['quantity'])),
      num.parse(widget.fixedQuantity),
      num.parse(nutrionsList['quantity']),
    );
    IngredientNutriCalculations.nutrients.value = nutrionData;
  }

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic> nutrionsList = widget.nutrionInfoList[0];

    // var quantityList = List.generate(100, (index) => index * int.parse(widget.fixedQuantity));
    List<num> quantityList = [
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
    // quantityList.remove(0);

    num valueText = 0;

    dynamic quantity = num.parse(nutrionsList['quantity']);
    double totalCalories = CaloriesCalc().calculateCalories(num.parse(widget.fixedQuantity),
        num.parse(nutrionsList['calories']), num.parse(nutrionsList['quantity']));
    return CommonScreenForNavigation(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            Get.back();
          }, //replaces the screen to Main dashboard
          color: Colors.white,
        ),
        title: const Text("Add Ingredient"),
        centerTitle: true,
        backgroundColor: widget.baseColor,
      ),
      content: Container(
        height: 100.h,
        color: Colors.white60,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                  height: 28.h,
                  child: Image.asset(
                    'newAssets/images/ingredients.png',
                    fit: BoxFit.cover,
                  )),
              SizedBox(
                height: 1.h,
              ),
              Padding(
                padding: EdgeInsets.all(10.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 12.sp),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 40.w,
                            child: Text(
                              '${widget.IngredientName} :',
                              maxLines: 2,
                              style: TextStyle(fontSize: 17.sp),
                            ),
                          ),
                          ValueListenableBuilder(
                              valueListenable: IngredientCaloriesCalc.calories,
                              builder: (_, val, __) {
                                return Text(
                                  '${' ' + val.toStringAsFixed(2)} Cal',
                                  maxLines: 2,
                                  style: TextStyle(color: widget.baseColor, fontSize: 16.sp),
                                );
                              })
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(InfoQuantityScreen(
                        appBarColor: widget.baseColor,
                      )),
                      child: Row(
                        children: <Widget>[
                          Container(
                              height: 18.sp,
                              width: 18.sp,
                              alignment: Alignment.center,
                              decoration:
                                  const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                              child: Text(
                                '?',
                                style: TextStyle(color: Colors.white, fontSize: 15.sp),
                              )),
                          SizedBox(
                            width: 10.sp,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.sp),
                              child: Text(
                                'Quantity',
                                style: TextStyle(color: widget.baseColor),
                              ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12.sp, right: 12.sp, top: 12.sp),
                child: Card(
                  elevation: 3,
                  child: SizedBox(
                    height: 23.h,
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 25.sp, right: 25.sp, top: 20.sp, bottom: 10.sp),
                      child:
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                        Column(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Add quantity',
                                      style: TextStyle(color: widget.baseColor),
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    ValueListenableBuilder(
                                        valueListenable: QuantityList.quantityList,
                                        builder: (_, val, __) {
                                          return GestureDetector(
                                              onTap: () {
                                                final GlobalKey<FormState> _quantityForm =
                                                    new GlobalKey<FormState>();
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext ctx) {
                                                      return AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(10.0),
                                                          ),
                                                          title: const Text('Enter the quantity'),
                                                          content: Form(
                                                            key: _quantityForm,
                                                            child: TextFormField(
                                                              enableInteractiveSelection: false,
                                                              inputFormatters: [
                                                                // FilteringTextInputFormatter
                                                                //     .digitsOnly
                                                              ],
                                                              autovalidateMode: AutovalidateMode
                                                                  .onUserInteraction,
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
                                                              keyboardType: TextInputType.number,
                                                              onChanged: (String value) {
                                                                setState(() {
                                                                  valueText = num.parse(value);
                                                                });
                                                              },
                                                              decoration: const InputDecoration(
                                                                  hintText: "quantity"),
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            MaterialButton(
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(10.0),
                                                                ),
                                                                color: widget.baseColor,
                                                                textColor: Colors.white,
                                                                child: const Text('OK'),
                                                                onPressed: () {
                                                                  if (_quantityForm.currentState
                                                                      .validate()) {
                                                                    quantity = valueText;
                                                                    if (!val.contains(valueText)) {
                                                                      QuantityList
                                                                          .quantityList.value
                                                                          .add(valueText);
                                                                    }
                                                                    QuantityList.quantityList.value
                                                                        .sort();
                                                                    QuantityList
                                                                            .quantityList.value =
                                                                        QuantityList
                                                                            .quantityList.value;
                                                                    QuantityList.quantityList
                                                                        .notifyListeners();
                                                                    initialPosition = QuantityList
                                                                        .quantityList.value
                                                                        .indexOf(quantity);
                                                                    _scrollWheelController
                                                                        .animateToItem(
                                                                            initialPosition,
                                                                            duration:
                                                                                const Duration(
                                                                                    seconds: 1),
                                                                            curve:
                                                                                Curves.easeInOut);
                                                                    Navigator.pop(ctx);
                                                                  }
                                                                  //QuantityList.quantityList.dispose();
                                                                })
                                                          ]);
                                                    });
                                              },
                                              child: Icon(
                                                Icons.edit,
                                                size: 18.sp,
                                              ));
                                        }),
                                  ],
                                ),
                                SizedBox(
                                  height: 19.sp,
                                ),
                                ValueListenableBuilder(
                                    valueListenable: QuantityList.quantityList,
                                    builder: (_, val, __) {
                                      return InkWell(
                                        onTap: () {
                                          final GlobalKey<FormState> _quantityForm =
                                              new GlobalKey<FormState>();
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext ctx) {
                                                return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10.0),
                                                    ),
                                                    title: const Text('Enter the quantity'),
                                                    content: Form(
                                                      key: _quantityForm,
                                                      child: TextFormField(
                                                        enableInteractiveSelection: false,
                                                        inputFormatters: [
                                                          // FilteringTextInputFormatter.digitsOnly
                                                        ],
                                                        autovalidateMode:
                                                            AutovalidateMode.onUserInteraction,
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
                                                        keyboardType:
                                                            const TextInputType.numberWithOptions(
                                                                decimal: true),
                                                        onChanged: (String value) {
                                                          setState(() {
                                                            valueText = num.parse(value);
                                                          });
                                                        },
                                                        decoration: const InputDecoration(
                                                            hintText: "quantity"),
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      MaterialButton(
                                                          color: AppColors.ingredientColor,
                                                          textColor: Colors.white,
                                                          child: const Text('OK'),
                                                          onPressed: () {
                                                            if (_quantityForm.currentState
                                                                .validate()) {
                                                              quantity = valueText;
                                                              if (!val.contains(valueText)) {
                                                                QuantityList.quantityList.value
                                                                    .add(valueText);
                                                              }
                                                              QuantityList.quantityList.value
                                                                  .sort();
                                                              QuantityList.quantityList.value =
                                                                  QuantityList.quantityList.value;
                                                              QuantityList.quantityList
                                                                  .notifyListeners();
                                                              initialPosition = QuantityList
                                                                  .quantityList.value
                                                                  .indexOf(quantity);
                                                              _scrollWheelController.animateToItem(
                                                                  initialPosition,
                                                                  duration:
                                                                      const Duration(seconds: 1),
                                                                  curve: Curves.easeInOut);
                                                              Navigator.pop(ctx);
                                                            }
                                                            //QuantityList.quantityList.dispose();
                                                          })
                                                    ]);
                                              });
                                        },
                                        child: Container(
                                          width: 30.w,
                                          height: 12.h,
                                          padding: EdgeInsets.only(bottom: 15.sp, left: 10.sp),
                                          child: CupertinoPicker.builder(
                                            scrollController: _scrollWheelController,
                                            itemExtent: 40,
                                            selectionOverlay: pickerContainer(),
                                            childCount: val.length,
                                            onSelectedItemChanged: (int _index) {
                                              if (val.length <= 0) return;
                                              int index = _index + 1;
                                              quantity = val[index - 1];
                                              totalCalories = CaloriesCalc().calculateCalories(
                                                  num.parse(widget.fixedQuantity),
                                                  num.parse(nutrionsList['calories']) *
                                                      (num.parse(widget.fixedQuantity) /
                                                          num.parse(nutrionsList['quantity'])),
                                                  quantity);
                                              IngredientCaloriesCalc.calories.value = totalCalories;
                                              Map nutrionData = CaloriesCalc().calculateNutrients(
                                                carbs *
                                                    (num.parse(widget.fixedQuantity) /
                                                        num.parse(nutrionsList['quantity'])),
                                                fiber *
                                                    (num.parse(widget.fixedQuantity) /
                                                        num.parse(nutrionsList['quantity'])),
                                                fats *
                                                    (num.parse(widget.fixedQuantity) /
                                                        num.parse(nutrionsList['quantity'])),
                                                protein *
                                                    (num.parse(widget.fixedQuantity) /
                                                        num.parse(nutrionsList['quantity'])),
                                                num.parse(widget.fixedQuantity),
                                                quantity,
                                              );
                                              IngredientCaloriesCalc.calories.value = totalCalories;
                                              IngredientNutriCalculations.nutrients.value =
                                                  nutrionData;
                                            },
                                            itemBuilder: (BuildContext context, int index) {
                                              return Center(
                                                  child: Text(
                                                val[index].toString(),
                                                style: TextStyle(
                                                    fontFamily: "Poppins", fontSize: 17.sp),
                                              ));
                                            },
                                          ),
                                        ),
                                      );
                                    }),
                              ],
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              'Serving Type',
                              style: TextStyle(color: widget.baseColor),
                            ),
                            SizedBox(
                              height: 18.sp,
                            ),
                            ValueListenableBuilder(
                                valueListenable: QuantityList.servingTypesList,
                                builder: (BuildContext ctx, List val, Widget child) {
                                  if (val.isEmpty) {
                                    return Shimmer.fromColors(
                                      direction: ShimmerDirection.ltr,
                                      period: const Duration(seconds: 2),
                                      baseColor: Colors.white,
                                      highlightColor: Colors.grey.withOpacity(0.2),
                                      child: Container(
                                        height: 12.h,
                                        width: 30.w,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    );
                                  }
                                  if (QuantityList.servingTypesList.value.length == 1) {
                                    return Container(
                                      width: 30.w,
                                      height: 12.h,
                                      padding: EdgeInsets.only(bottom: 15.sp, left: 10.sp),
                                      child: Center(
                                          child: Text(
                                        QuantityList.servingTypesList.value.first,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                        ),
                                        maxLines: 2,
                                      )),
                                    );
                                  } else {
                                    return Container(
                                      width: 30.w,
                                      height: 12.h,
                                      padding: EdgeInsets.only(bottom: 15.sp, left: 10.sp),
                                      child: CupertinoPicker.builder(
                                        scrollController: _servingScrollWheelController,
                                        itemExtent: 40,
                                        selectionOverlay: pickerContainer(),
                                        childCount: val.length,
                                        onSelectedItemChanged: (int i) {
                                          IngredientSizeModel ingredientSizeModel = ingredientSizes
                                              .where((IngredientSizeModel element) =>
                                                  element.servingUnitSize == val[i])
                                              .first;
                                          nutrionsList['calories'] = ingredientSizeModel.calories;
                                          nutrionsList['quantity'] = ingredientSizeModel.quantity;
                                          nutrionsList['serving_unit_size'] =
                                              ingredientSizeModel.servingUnitSize;
                                          // nutrionsList['calories'] = ingredientSizeModel.calories;
                                          IngredientNutriCalculations.nutrients.value = {
                                            'fats': double.parse(ingredientSizeModel.fats),
                                            'fiber': double.parse(ingredientSizeModel.fiber),
                                            'carbs': double.parse(ingredientSizeModel.carbs),
                                            'protein': double.parse(ingredientSizeModel.protein)
                                          };
                                          quantity = double.parse(ingredientSizeModel.quantity);
                                          if (!val.contains(valueText)) {
                                            QuantityList.quantityList.value.add(valueText);
                                          }
                                          QuantityList.quantityList.value.sort();
                                          QuantityList.quantityList.value =
                                              QuantityList.quantityList.value;
                                          QuantityList.quantityList.notifyListeners();
                                          initialPosition =
                                              QuantityList.quantityList.value.indexOf(quantity);
                                          _scrollWheelController.animateToItem(initialPosition,
                                              duration: const Duration(seconds: 1),
                                              curve: Curves.easeInOut);
                                          // Navigator.pop(ctx);
                                          updateScroll();
                                        },
                                        itemBuilder: (BuildContext context, int index) {
                                          return Center(
                                              child: Text(
                                            val[index].toString(),
                                            style: TextStyle(
                                                fontSize: val[index].length < 8 ? 16.sp : 14.sp,
                                                fontFamily: "Poppins",
                                                letterSpacing: 0.3),
                                          ));
                                        },
                                      ),
                                    );
                                  }
                                }),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
              Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(12.sp),
                    child: Card(
                      elevation: 3,
                      child: Container(
                        padding: EdgeInsets.only(left: 20.sp, top: 20.sp, right: 14.w),
                        // height: 16.h,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            //  padding: EdgeInsets.all(8.sp),
                            Text(
                              'Nutrients',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  letterSpacing: 0.5),
                            ),
                            SizedBox(
                              height: 1.5.h,
                            ),
                            ValueListenableBuilder(
                                valueListenable: IngredientNutriCalculations.nutrients,
                                builder: (_, val, __) {
                                  nutrionsList['carbs'] = val['carbs'].toStringAsFixed(2);
                                  nutrionsList['fiber'] = val['fiber'].toStringAsFixed(2);
                                  nutrionsList['fats'] = val['fats'].toStringAsFixed(2);
                                  nutrionsList['protien'] = val['protein'].toStringAsFixed(2);

                                  num _protin = val['protein'];
                                  num _carbs = val['carbs'];
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 48.sp,
                                            height: 5.h,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                const Text('Protein '),
                                                Text(
                                                  _protin.toStringAsFixed(2) == "0.00"
                                                      ? "--"
                                                      : "${_protin.toStringAsFixed(2)}g",
                                                  style: TextStyle(color: widget.baseColor),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.sp,
                                          ),
                                          SizedBox(
                                            width: 48.sp,
                                            height: 5.h,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                const Text('Carbs '),
                                                Text(
                                                  _carbs.toStringAsFixed(2) == "0.00"
                                                      ? "--"
                                                      : '${_carbs.toStringAsFixed(2)}g',
                                                  style: TextStyle(color: widget.baseColor),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 44.sp,
                                            height: 5.h,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                const Text('Fiber '),
                                                Text(
                                                  val['fiber'].toStringAsFixed(2) == "0.00"
                                                      ? "--"
                                                      : val['fiber'].toStringAsFixed(2) + 'g',
                                                  style: TextStyle(color: widget.baseColor),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.sp,
                                          ),
                                          SizedBox(
                                            width: 44.sp,
                                            height: 5.h,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                const Text('Fats '),
                                                Text(
                                                  val['fats'].toStringAsFixed(2) == "0.00"
                                                      ? "--"
                                                      : val['fats'].toStringAsFixed(2) + 'g',
                                                  style: TextStyle(
                                                    color: widget.baseColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                                }),
                            SizedBox(
                              height: 1.5.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 2.h,
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 0, top: 1.h),
                  child: GestureDetector(
                    onTap: () {
                      IngredientsList.ingredientsList.removeWhere(
                          (IngredientModel element) => element.item == widget.IngredientName);
                      quantityList.clear();
                      IngredientsList.ingredientsList.add(IngredientModel(
                          amount: quantity.toString(),
                          item: widget.IngredientName,
                          protiens: nutrionsList['protien'],
                          amount_unit: nutrionsList['serving_unit_size'],
                          calories: totalCalories.toStringAsFixed(0),
                          totalCarbohydrate: nutrionsList['carbs'],
                          totalFat: nutrionsList['fats'],
                          fiber: nutrionsList['fiber'],
                          itemId: nutrionsList['item'],
                          fixedAmount: widget.fixedQuantity));
                      RemoveIngredient.removedIngredients
                          .removeWhere((element) => element == widget.IngredientName);
                      if (widget.editMeal) {
                        Get.to(EditCustomFood(
                          mealType: widget.mealType,
                          baseColor: widget.baseColor,
                          recipeDetails: widget.recipeDetails,
                          mealData: widget.mealData,
                        ));
                      } else {
                        Get.to(NewMeal(
                          selectedQuantity: widget.selectedQuantity,
                          mealData: widget.mealData,
                          baseColor: widget.baseColor,
                          mealType: widget.mealType,
                        ));
                      }
                    },
                    child: Container(
                      height: 4.5.h,
                      width: 28.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15), color: widget.baseColor),
                      child: const Center(
                        child: Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
            ],
          ),
        ),
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
}

class IngredientsList {
  static List<IngredientModel> ingredientsList = [];
}

class IngredientDetails {
  String ingredientName;
  String servingType;
  String Quantity;
  String calories;
  String carbs;
  String fats;
  String fiber;
  String foodid;
  String fixedQuantity;
  IngredientDetails(
      {this.ingredientName,
      this.servingType,
      this.Quantity,
      this.calories,
      this.carbs,
      this.fats,
      this.fiber,
      this.foodid,
      this.fixedQuantity});
}

class IngredientCaloriesCalc {
  static ValueNotifier<double> calories = ValueNotifier<double>(0.0);
}

class IngredientNutriCalculations {
  static ValueNotifier<Map> nutrients =
      ValueNotifier<Map>({'fats': 0.0, 'fiber': 0.0, 'carbs': 0.0, 'protein': 0.0});
}

class QuantityList {
  static ValueNotifier<List<String>> servingTypesList = ValueNotifier<List<String>>([]);
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

class IngredientSizeModel {
  String foodId;
  String calories;
  String carbs;
  String ingredient;
  String fats;
  String fiber;
  String item;
  String servingUnitSize;
  String protein;
  String quantity;

  IngredientSizeModel(
      {this.foodId,
      this.calories,
      this.carbs,
      this.ingredient,
      this.fats,
      this.fiber,
      this.item,
      this.servingUnitSize,
      this.protein,
      this.quantity});

  factory IngredientSizeModel.fromJson(Map<String, dynamic> json) => IngredientSizeModel(
        foodId: json["food_id"],
        calories: json["calories"],
        carbs: json["carbs"],
        ingredient: json["ingredient"],
        fats: json["fats"],
        fiber: json["fiber"],
        item: json["item"],
        servingUnitSize: json["serving_unit_size"],
        protein: json["protein"],
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "food_id": foodId,
        "calories": calories,
        "carbs": carbs,
        "ingredient": ingredient,
        "fats": fats,
        "fiber": fiber,
        "item": item,
        "serving_unit_size": servingUnitSize,
        "protein": protein,
        "quantity": quantity,
      };
}
