import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/dietJournal/add_new_meal.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/apis/log_apis.dart';
import 'package:ihl/views/dietJournal/models/create_edit_meal_model.dart';
import 'package:ihl/views/dietJournal/models/food_list_tab_model.dart';
import 'package:ihl/views/dietJournal/models/view_custom_food_model.dart';
import 'package:ihl/views/dietJournal/search_ingrident.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';
// import 'activity/bookmark_activity_list_tab.dart';

class CreateNewMealScreen extends StatefulWidget {
  final ListCustomRecipe customUserFood;
  final MealsListData mealType;
  bool editCustomMeal;

  CreateNewMealScreen({this.customUserFood, this.mealType, this.editCustomMeal});
  @override
  _CreateNewMealScreenState createState() => _CreateNewMealScreenState();
}

class _CreateNewMealScreenState extends State<CreateNewMealScreen> {
  bool submitted = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool edit = false;
  var custoDetails;
  List customDishes = [];
  List<String> ingridientList = [];
  List<Map<String, dynamic>> ingredientValueList = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController ingridientController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController quantityTypeController = TextEditingController();
  TextEditingController calorieController = TextEditingController();
  TextEditingController protienController = TextEditingController();
  TextEditingController carbController = TextEditingController();
  TextEditingController fiberController = TextEditingController();
  // TextEditingController satFatController = TextEditingController();
  TextEditingController totalFatController = TextEditingController();
  List<Map> sendResult = [];
  @override
  void initState() {
    super.initState();
    if (widget.editCustomMeal == null) {
      widget.editCustomMeal = false;
      initializedValuesWithZero();
    }
    getDetails();
  }

  initializedValuesWithZero() {
    if (this.mounted) {
      setState(() {
        // nameController.text = widget.customUserFood.item;
        // quantityController.text = widget.customUserFood.quantity;
        // quantityTypeController.text =
        //     widget.customUserFood.quantityUnit ?? 'Nos.';
        // ingridientController.text = widget.customUserFood.ingredients;
        // calorieController.text = widget.customUserFood.calories;
        protienController.text = '0';
        carbController.text = '0';
        fiberController.text = '0';
        // sugarController.text = '0';
        totalFatController.text = '0';
      });
    }
  }

  void getDetails() async {
    if (widget.customUserFood != null) {
      if (this.mounted) {
        if (widget.customUserFood.ingredientDetail != null) {
          ingridientList.addAll(widget.customUserFood.ingredientDetail.map((e) => e.item).toList());
          ingridientController.text = ingridientList.join(",");
          for (var e in widget.customUserFood.ingredientDetail) addNutriValues(e.toJson());
        }
        setState(() {
          edit = true;
          nameController.text = widget.customUserFood.dish;
          quantityController.text = widget.customUserFood.quantity;
          quantityTypeController.text = widget.customUserFood.servingUnitSize ?? 'Nos.';
          // ingridientController.text = widget.customUserFood.ingredients;
          calorieController.text = widget.customUserFood.calories;
          protienController.text = widget.customUserFood.protein;
          carbController.text = widget.customUserFood.carbs;
          fiberController.text = widget.customUserFood.fiber;
          // sugarController.text = widget.customUserFood.sugar;
          totalFatController.text = widget.customUserFood.fats;
          // monoFatController.text = widget.customUserFood.monounsaturatedFats;
          // polyFatController.text = widget.customUserFood.polyunsaturatedFats;
          // transFatController.text = widget.customUserFood.transfattyAcid;
          // cholestrolController.text = widget.customUserFood.colesterol;
          // sodiumController.text = widget.customUserFood.sodium;
          // potassiumController.text = widget.customUserFood.potassium;
          // calciumController.text = widget.customUserFood.calcium;
          // ironController.text = widget.customUserFood.iron;
          // vitaminAController.text = widget.customUserFood.vitaminA;
          // vitaminCController.text = widget.customUserFood.vitaminC;
          // notesController.text = widget.customUserFood.notes;
        });
      }
    }
    custoDetails = await ListApis.customFoodDetailsApi();
    custoDetails.forEach((ele) => {customDishes.add(ele.dish)});
  }

  void deleteFood() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Get.snackbar('Deleted!',
    //     '${camelize(foodDetail.item ?? 'Name Unknown')} deleted successfully.',
    //     icon: Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: Icon(bookmarked ? Icons.favorite : Icons.favorite_border,
    //             color: Colors.white)),
    //     margin: EdgeInsets.all(20).copyWith(bottom: 40),
    //     backgroundColor: AppColors.primaryAccentColor,
    //     colorText: Colors.white,
    //     duration: Duration(seconds: 6),
    //     snackPosition: SnackPosition.BOTTOM);
    await LogApis.deleteCustomUserFoodApi(foodItemID: widget.customUserFood.dish)
        .then((data) async {
      if (data != null) {
        deleteRecents();
        Get.off(AddFood(
          selectedpage: 2,
          mealsListData: widget.mealType,
          cardioNavigate: false,
        ));
      } else {
        // Get.snackbar('Error!', 'Food not deleted',
        //     icon: Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: Icon(Icons.favorite, color: Colors.white)),
        //     margin: EdgeInsets.all(20).copyWith(bottom: 40),
        //     backgroundColor: Colors.red,
        //     colorText: Colors.white,
        //     snackPosition: SnackPosition.BOTTOM);

        // bookmarked = false;
      }
    });
  }

  // void
  deleteRecents() async {
    await SpUtil.getInstance();
    List<FoodListTileModel> recentList = SpUtil.getRecentObjectList('recent_food') ?? [];
    bool exists = recentList.any((fav) => fav.foodItemID == widget.customUserFood.dish);
    // foodDetail.userRecipeId2);
    if (exists) {
      recentList.removeWhere((element) => element.foodItemID == widget.customUserFood.dish);
      // foodDetail.userRecipeId2);
    }
    SpUtil.putRecentObjectList('recent_food', recentList);
  }

  Widget _customButton() {
    return Container(
      height: 60,
      child: IgnorePointer(
        ignoring: submitted,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            if (_formKey.currentState.validate()) {
              createCustomFood(result: sendResult);
            } else {
              if (this.mounted) {
                setState(() {
                  _autoValidate = true;
                });
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: widget.mealType != null
                  ? HexColor(widget.mealType.startColor)
                  : Color(0xFF19a9e5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: submitted
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Submit',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addNutriValues(var result) async {
    if (result != null) {
      if (this.mounted) {
        setState(() {
          ingredientValueList.add(result);
          if (calorieController.text == "") {
            calorieController.text = result['calories'] == ""
                ? "0"
                : double.parse(result['calories'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
          } else {
            var temp = result['calories'] == ""
                ? '0'
                : double.parse(result['calories'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
            var sum = double.parse(calorieController.text) + double.parse(temp);
            calorieController.text = sum.toStringAsFixed(1);
          }
          // if (protienController.text == "") {
          //   protienController.text = result['protiens'] == ""
          //       ? "0"
          //       : double.parse(result['protiens'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
          //           .toStringAsFixed(1);
          // } else {
          //   var temp = result['protiens'] == ""
          //       ? '0'
          //       : double.parse(result['protiens'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
          //           .toStringAsFixed(1);
          //   var sum = double.parse(protienController.text) + double.parse(temp);
          //   protienController.text = sum.toStringAsFixed(1);
          // }

          if (carbController.text == "") {
            carbController.text = result['carbs'] == ""
                ? "0"
                : double.parse(result['carbs'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
          } else {
            var temp = result['carbs'] == ""
                ? '0'
                : double.parse(result['carbs'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
            var sum = double.parse(carbController.text) + double.parse(temp);
            carbController.text = sum.toStringAsFixed(1);
          }
          if (fiberController.text == "") {
            fiberController.text = result['fiber'] == ""
                ? "0"
                : double.parse(result['fiber'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
          } else {
            var temp = result['fiber'] == ""
                ? '0'
                : double.parse(result['fiber'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
            var sum = double.parse(fiberController.text) + double.parse(temp);
            fiberController.text = sum.toStringAsFixed(1);
          }

          if (totalFatController.text == "") {
            totalFatController.text = result['fats'] == ""
                ? "0"
                : double.parse(result['fats'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
          } else {
            var temp = result['fats'] == ""
                ? '0'
                : double.parse(result['fats'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
            var sum = double.parse(totalFatController.text) + double.parse(temp);
            totalFatController.text = sum.toStringAsFixed(1);
          }
          if (result["serving_unit_size"] == null) {
            result["serving_unit_size"] = "gm";
          }
          if (result["quantity"] == null || result["quantity"] == "") {
            result["quantity"] = "50";
          }
        });
      }
    }
    log(result.toString());
    Map r = result;
    sendResult.add(r);
  }

  void subNutriValues(var result) async {
    if (result != null) {
      if (this.mounted) {
        setState(() {
          if (calorieController.text == "") {
            calorieController.text = result['calories'] == ""
                ? "0"
                : double.parse(result['calories'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
          } else {
            var temp = result['calories'] == ""
                ? '0'
                : double.parse(result['calories'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
            var sum = double.parse(calorieController.text) - double.parse(temp);
            calorieController.text = sum.toStringAsFixed(1);
          }
          if (protienController.text == "") {
            protienController.text = result['protiens'] == ""
                ? "0"
                : double.parse(result['protiens'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
          } else {
            var temp = result['protiens'] == ""
                ? '0'
                : double.parse(result['protiens'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
            var sum = double.parse(protienController.text) - double.parse(temp);
            protienController.text = sum.toStringAsFixed(1);
          }

          if (carbController.text == "") {
            carbController.text = result['total_carbohydrate'] == ""
                ? "0"
                : double.parse(result['total_carbohydrate'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
          } else {
            var temp = result['total_carbohydrate'] == ""
                ? '0'
                : double.parse(result['total_carbohydrate'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
            var sum = double.parse(carbController.text) - double.parse(temp);
            carbController.text = sum.toStringAsFixed(1);
          }
          if (fiberController.text == "") {
            fiberController.text = result['fiber'] == ""
                ? "0"
                : double.parse(result['fiber'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
          } else {
            var temp = result['fiber'] == ""
                ? '0'
                : double.parse(result['fiber'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
            var sum = double.parse(fiberController.text) - double.parse(temp);
            fiberController.text = sum.toStringAsFixed(1);
          }

          if (totalFatController.text == "") {
            totalFatController.text = result['total_fat'] == ""
                ? "0"
                : double.parse(result['total_fat'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
          } else {
            var temp = result['total_fat'] == ""
                ? '0'
                : double.parse(result['total_fat'].replaceAll(new RegExp(r'[^0-9+.]'), ''))
                    .toStringAsFixed(1);
            var sum = double.parse(totalFatController.text) - double.parse(temp);
            totalFatController.text = sum.toStringAsFixed(1);
          }

          ingredientValueList.remove(result);
          sendResult.remove(result);
        });
      }
    }
  }

  void createCustomFood({var result}) async {
    if (this.mounted) {
      setState(() {
        submitted = true;
      });
    }
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    List<IngredientModel> ingredientDetail =
        sendResult.map((e) => IngredientModel.fromJson(e)).toList();
    CreateEditRecipe logFood = CreateEditRecipe(
      ihlId: iHLUserId,
      dish: widget.customUserFood != null ? widget.customUserFood.dish : nameController.text,
      quantity: quantityController.text,
      servingUnitSize: quantityTypeController.text,
      calories: calorieController.text,
      protein: protienController.text,
      fats: totalFatController.text,
      carbs: carbController.text,
      fiber: fiberController.text,
      hypertension: "",
      diabetes: "",
      // foodId: widget.customUserFood.foodId == null ? "" : widget.customUserFood.foodId,
      highBmi: "",
      heartDisease: "",
      highCholesterol: "",
      highVisceralFat: "",
      ingredientDetail: jsonEncode(ingredientDetail),
    );
    if (widget.editCustomMeal) {
      logFood.foodId = widget.customUserFood.foodId;
      // logFood.ingredientDetail = jsonEncode(widget.customUserFood.ingredientDetail);
    }
    // if (false)
    LogApis.createEditCustomFoodApi(data: logFood).then((value) async {
      if (value != null) {
        // deleteFood();
        if (widget.editCustomMeal) {
          try {
            if (widget.customUserFood.dish == nameController.text) {
              await SpUtil.getInstance();
              List<FoodListTileModel> recentList = SpUtil.getRecentObjectList('recent_food') ?? [];
              bool exists = recentList.any((fav) => fav.foodItemID == widget.customUserFood.foodId);
              // foodDetail.userRecipeId2);
              if (exists) {
                recentList
                    .removeWhere((element) => element.foodItemID == widget.customUserFood.foodId);
                // foodDetail.userRecipeId2);
              }
              SpUtil.putRecentObjectList('recent_food', recentList);
            } else {
              await LogApis.deleteCustomUserFoodApi(foodItemID: widget.customUserFood.foodId)
                  .then((data) async {
                if (data != null) {
                  await SpUtil.getInstance();
                  List<FoodListTileModel> recentList =
                      SpUtil.getRecentObjectList('recent_food') ?? [];
                  bool exists =
                      recentList.any((fav) => fav.foodItemID == widget.customUserFood.foodId);
                  // foodDetail.userRecipeId2);
                  if (exists) {
                    recentList.removeWhere(
                        (element) => element.foodItemID == widget.customUserFood.foodId);
                    // foodDetail.userRecipeId2);
                  }
                  SpUtil.putRecentObjectList('recent_food', recentList);
                  // await deleteRecents();
                  // Get.off(AddFood(
                  //   selectedpage: 2,
                  //   mealsListData: widget.mealType,
                  // ));
                } else {
                  // Get.snackbar('Error!', 'Food not deleted',
                  //     icon: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: Icon(Icons.favorite, color: Colors.white)),
                  //     margin: EdgeInsets.all(20).copyWith(bottom: 40),
                  //     backgroundColor: Colors.red,
                  //     colorText: Colors.white,
                  //     snackPosition: SnackPosition.BOTTOM);

                  // bookmarked = false;
                }
              });
            }
          } catch (e) {
            print(e.toString());
          }
        }
        if (this.mounted) {
          setState(() {
            submitted = false;
          });
        }
        /*Get.offUntil(
            GetPageRoute(
                page: () => AddFood(
                      selectedpage: 2,
                      mealsListData: widget.mealType,
                    )),
            (route) => false);*/
        Get.to(AddFood(
          selectedpage: 2,
          mealsListData: widget.mealType,
          cardioNavigate: false,
        ));
        Get.snackbar('Created!', '${camelize(nameController.text)} created successfully.',
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

  @override
  Widget build(BuildContext context) {
    return DietJournalUI(
      topColor: widget.mealType != null
          ? HexColor(widget.mealType.startColor)
          : AppColors.primaryAccentColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          edit ? 'Edit Meal' : 'Create New Meal',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.white),
          // style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold,color: Colors.white),
          maxLines: 1,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          // if (_formKey.currentState.validate()) {
          // } else {
          //   if (this.mounted) {
          //     setState(() {
          //       _autoValidate = true;
          //     });
          //   }
          // }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: ScUtil().setHeight(30),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    // color: CardColors.bgColor,
                    color: FitnessAppTheme.white,
                    shadowColor: FitnessAppTheme.grey,
                    borderOnForeground: true,
                    shape: RoundedRectangleBorder(
                        // borderRadius: BorderRadius.all(
                        //   Radius.circular(10),
                        // ),
                        side: BorderSide(
                      width: 1,
                      color: FitnessAppTheme.grey.withOpacity(0.1),
                    )),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: ScUtil().setHeight(20)),
                          Text(
                            'Title of the Food',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              letterSpacing: 0.5,
                              color: AppColors.textitemTitleColor,
                            ),
                          ),
                          SizedBox(height: ScUtil().setHeight(10)),
                          TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: nameController,
                            validator: (value) {
                              if (!edit) {
                                if (!customDishes.contains(value.toLowerCase()) &&
                                    !customDishes.contains(value) &&
                                    !customDishes.contains(value.capitalize) &&
                                    !customDishes.contains(value.capitalizeFirst)) {
                                  if (value.isEmpty) {
                                    return 'Food Title can\'t be empty!';
                                  } else if (value.length < 4 && value.isNotEmpty) {
                                    return "Atleast 4 characters needed.";
                                  } else if ((value.length > 100) && value.isNotEmpty) {
                                    return "Food item name should be less than 100 chars";
                                  }

                                  return null;
                                } else {
                                  return "Food item name already exists";
                                }
                              } else {
                                if (value.isEmpty) {
                                  return 'Food Title can\'t be empty!';
                                } else if (value.length < 4 && value.isNotEmpty) {
                                  return "Atleast 4 characters needed.";
                                } else if ((value.length > 100) && value.isNotEmpty) {
                                  return "Food item name should be less than 100 chars";
                                }

                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                              labelText: "Food Title",
                              hintText: "Like: Biryani / Dosai / Pulav",
                              counterText: "",
                              counterStyle: TextStyle(fontSize: 0),
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  borderSide: new BorderSide(color: Colors.blueGrey)),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                            ],
                            textInputAction: TextInputAction.done,
                          ),
                          SizedBox(height: ScUtil().setHeight(20)),
                          Text(
                            'Quantity of the Food',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              letterSpacing: 0.5,
                              color: AppColors.textitemTitleColor,
                            ),
                          ),
                          SizedBox(height: ScUtil().setHeight(10)),
                          TextFormField(
                            controller: quantityController,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Quantity can\'t be empty!';
                              } else if ((double.parse(value) > 1000) && value.isNotEmpty) {
                                return "Quantity value should be less than 100";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                              labelText: "Quantity",
                              hintText: "Like: 1 or 10 or 12",
                              counterText: "",
                              counterStyle: TextStyle(fontSize: 0),
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  borderSide: new BorderSide(color: Colors.blueGrey)),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                          ),
                          SizedBox(height: ScUtil().setHeight(20)),
                          Text(
                            'Serving Type',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              letterSpacing: 0.5,
                              color: AppColors.textitemTitleColor,
                            ),
                          ),
                          SizedBox(height: ScUtil().setHeight(10)),
                          TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: quantityTypeController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Serving type can\'t be empty!';
                              } else if (value.length < 2 && value.isNotEmpty) {
                                return "Serving 3 characters needed.";
                              } else if ((value.length > 9) && value.isNotEmpty) {
                                return "Serving type should be less than 9 chars";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                              labelText: "Serving Type",
                              hintText: "Like Nos./Cup/Serving/Katori/Teaspoon etc.",
                              counterText: "",
                              counterStyle: TextStyle(fontSize: 0),
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  borderSide: new BorderSide(color: Colors.blueGrey)),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                            ],
                            textInputAction: TextInputAction.done,
                          ),

                          SizedBox(height: ScUtil().setHeight(20)),
                          Text(
                            'Ingredients of the Food',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              letterSpacing: 0.5,
                              color: AppColors.textitemTitleColor,
                            ),
                          ),
                          SizedBox(height: ScUtil().setHeight(10)),
                          TextFormField(
                            controller: ingridientController,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                              labelText: "Ingredients",
                              hintText: "Like: Rice/Wheat/Chilli Powder",
                              counterText: "",
                              counterStyle: TextStyle(fontSize: 0),
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  borderSide: new BorderSide(color: Colors.blueGrey)),
                            ),
                            readOnly: true,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchIngridientScreen(),
                                  ));
                              if (ingridientList.isNotEmpty) {
                                if (result != null) {
                                  if (!ingridientList.contains((result['ingredient']))) {
                                    ingridientList.add((result['ingredient']));
                                    addNutriValues(result);
                                  }
                                }
                              } else {
                                if (result != null) {
                                  ingridientList.add((result['ingredient']));
                                  addNutriValues(result);
                                }
                              }
                              if (this.mounted) {
                                setState(() {
                                  ingridientController.text = ingridientList.join(',');
                                });
                              }
                            },
                          ),
                          SizedBox(height: ScUtil().setHeight(15)),
                          Visibility(
                            visible: ingridientController.text.isNotEmpty,
                            child: Container(
                              // color: Colors.red,
                              child: Column(
                                children: [
                                  ...ingridientList.map<Widget>((e) {
                                    return ingredientTile(Ingredient: e);
                                    /*
                                    SizedBox(
                                      // width: MediaQuery.of(context).size.width *
                                      //     0.4,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        child: Chip(
                                          // onPressed: () {
                                          //   ingridientList
                                          //       .removeWhere((element) {
                                          //     if (element == e) {
                                          //       for (int i = 0;
                                          //           i <=
                                          //               ingredientValueList
                                          //                   .length;
                                          //           i++) {
                                          //         if (camelize(
                                          //                 ingredientValueList[i]
                                          //                     ['item']) ==
                                          //             element) {
                                          //           subNutriValues(
                                          //               ingredientValueList[i]);
                                          //           break;
                                          //         }
                                          //       }
                                          //       return true;
                                          //     }
                                          //     return false;
                                          //   });
                                          //   ingridientController.text =
                                          //       ingridientList.join(',');
                                          //   setState(() {});
                                          // },
                                          backgroundColor:
                                              AppColors.primaryAccentColor.withOpacity(0.9),
                                          labelPadding: EdgeInsets.zero,
                                          label: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 3),
                                            child: Text(
                                              e.toString(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: ScUtil().setSp(14)),
                                            ),
                                          ),
                                          deleteIcon: Icon(
                                            Icons.remove_circle_outline_rounded,
                                            color: Colors.white,
                                            size: 21,
                                          ),
                                          deleteIconColor: Colors.white,
                                          onDeleted: () {
                                            ingridientList.removeWhere((element) {
                                              if (element == e) {
                                                for (int i = 0;
                                                    i <= ingredientValueList.length;
                                                    i++) {
                                                  if (camelize(ingredientValueList[i]['item']) ==
                                                      element) {
                                                    subNutriValues(ingredientValueList[i]);
                                                    break;
                                                  }
                                                }
                                                return true;
                                              }
                                              return false;
                                            });
                                            ingridientController.text = ingridientList.join(',');
                                            setState(() {});
                                          },
                                          // tooltip: "Click to remove ",
                                        ),
                                      ),
                                    );*/
                                  }).toList()
                                ],
                              ),
                            ),
                          ),
                          // SizedBox(height: ScUtil().setHeight(5)),
                          // ingridientController.text.isNotEmpty
                          //     ? TextButton(
                          //         onPressed: () {
                          //           if (this.mounted) {
                          //             setState(() {
                          //               for (int i = 0;
                          //                   i <= ingredientValueList.length;
                          //                   i++) {
                          //                 if (camelize(ingredientValueList[i]
                          //                         ['item']) ==
                          //                     ingridientList.last) {
                          //                   subNutriValues(
                          //                       ingredientValueList[i]);
                          //                   break;
                          //                 }
                          //               }
                          //
                          //               ingridientList
                          //                   .remove(ingridientList.last);
                          //               ingridientController.text =
                          //                   ingridientList.join(',');
                          //             });
                          //           }
                          //         },
                          //         child: Text('Delete Ingredient'))
                          //     : SizedBox.shrink(),
                          SizedBox(height: ScUtil().setHeight(5)),
                          SizedBox(height: ScUtil().setHeight(10)),
                          Row(
                            children: [
                              Text(
                                'Protein \n(in grams)',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  color: AppColors.textitemTitleColor,
                                ),
                              ),
                              // SizedBox(width: ScUtil().setWidth(20)),
                              Spacer(),
                              SizedBox(
                                width: 40.w,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Value can\'t be empty!';
                                    } else if ((double.parse(value) > 1000) && value.isNotEmpty) {
                                      return "Value should be less than 1000";
                                    }
                                    return null;
                                  },
                                  controller: protienController,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                                    labelText: "Protein",
                                    suffixText: 'gms',
                                    counterText: "",
                                    counterStyle: TextStyle(fontSize: 0),
                                    fillColor: Colors.white,
                                    border: new OutlineInputBorder(
                                        borderRadius: new BorderRadius.circular(15.0),
                                        borderSide: new BorderSide(color: Colors.blueGrey)),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ScUtil().setHeight(20)),
                          Row(
                            children: [
                              Text(
                                'Carbohydrates\n(in grams)',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  color: AppColors.textitemTitleColor,
                                ),
                              ),
                              // SizedBox(width: ScUtil().setWidth(20)),
                              Spacer(),
                              SizedBox(
                                width: 40.w,
                                child: TextFormField(
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Value can\'t be empty!';
                                    } else if ((double.parse(value) > 1000) && value.isNotEmpty) {
                                      return "Value should be less than 1000";
                                    }
                                    return null;
                                  },
                                  controller: carbController,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                                    labelText: "Carbs.",
                                    suffixText: 'gms',
                                    counterText: "",
                                    counterStyle: TextStyle(fontSize: 0),
                                    fillColor: Colors.white,
                                    border: new OutlineInputBorder(
                                        borderRadius: new BorderRadius.circular(15.0),
                                        borderSide: new BorderSide(color: Colors.blueGrey)),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ScUtil().setHeight(20)),
                          Row(
                            children: [
                              Text(
                                'Fibers \n(in grams)',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  color: AppColors.textitemTitleColor,
                                ),
                              ),
                              // SizedBox(width: ScUtil().setWidth(20)),
                              Spacer(),
                              SizedBox(
                                width: 40.w,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Value can\'t be empty!';
                                    } else if ((double.parse(value) > 1000) && value.isNotEmpty) {
                                      return "Value should be less than 1000";
                                    }
                                    return null;
                                  },
                                  controller: fiberController,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                                    labelText: "Fiber",
                                    suffixText: 'gms',
                                    counterText: "",
                                    counterStyle: TextStyle(fontSize: 0),
                                    fillColor: Colors.white,
                                    border: new OutlineInputBorder(
                                        borderRadius: new BorderRadius.circular(15.0),
                                        borderSide: new BorderSide(color: Colors.blueGrey)),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ScUtil().setHeight(20)),
                          Row(
                            children: [
                              Text(
                                'Fats\n(in grams)',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  color: AppColors.textitemTitleColor,
                                ),
                              ),
                              // SizedBox(width: ScUtil().setWidth(20)),
                              Spacer(),
                              SizedBox(
                                width: 40.w,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Value can\'t be empty!';
                                    } else if ((double.parse(value) > 1000) && value.isNotEmpty) {
                                      return "Value should be less than 1000";
                                    }
                                    return null;
                                  },
                                  controller: totalFatController,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                                    labelText: "Fats",
                                    suffixText: 'gms',
                                    counterText: "",
                                    counterStyle: TextStyle(fontSize: 0),
                                    fillColor: Colors.white,
                                    border: new OutlineInputBorder(
                                        borderRadius: new BorderRadius.circular(15.0),
                                        borderSide: new BorderSide(color: Colors.blueGrey)),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ScUtil().setHeight(20)),
                          Text(
                            'Calories',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              letterSpacing: 0.5,
                              color: AppColors.textitemTitleColor,
                            ),
                          ),
                          SizedBox(height: ScUtil().setHeight(10)),
                          TextFormField(
                            autovalidateMode: AutovalidateMode.disabled,
                            controller: calorieController,
                            enabled: false,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Calories Value can\'t be empty!';
                              } else if ((double.parse(value) >= 1000) && value.isNotEmpty) {
                                return "Calories Value should be less than 1000";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                              // labelText: "Calories",
                              hintText: "Like: 168 / 200 / 250",
                              counterText: "",
                              counterStyle: TextStyle(fontSize: 0),
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  borderSide: new BorderSide(color: Colors.blueGrey)),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: ScUtil().setHeight(20)),
                          SizedBox(height: ScUtil().setHeight(20)),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: Center(
                    child: _customButton(),
                  ),
                ),
                SizedBox(height: ScUtil().setHeight(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget ingredientTile({String Ingredient}) {
    Map s = sendResult.where((e) => e["ingredient"] == Ingredient).toList().first;
    IngredientModel e = IngredientModel.fromJson(s);
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // width: 60.w,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.transparent),
                      color: Colors.blue),
                  child: Text(
                    Ingredient.toString(),
                    style: TextStyle(
                      fontSize: 14.px,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () => _showDialogIngredient(e),
                  child: Icon(
                    FontAwesomeIcons.edit,
                    size: 20,
                    color: Colors.blue.shade300,
                  ),
                ),
                // SizedBox(width: 16),
                // InkWell(
                //   onTap: () {
                //     ingridientList.removeWhere((element) {
                //       if (element == e.item) {
                //         for (int i = 0; i <= ingredientValueList.length; i++) {
                //           if (camelize(ingredientValueList[i]['item']) == element) {
                //             subNutriValues(ingredientValueList[i]);
                //             break;
                //           }
                //         }
                //         return true;
                //       }
                //       return false;
                //     });
                //     ingridientController.text = ingridientList.join(',');
                //     setState(() {});
                //   },
                //   child: Icon(
                //     Icons.delete,
                //     color: Colors.red.shade300,
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 10),
            typeContainer(e),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Divider(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget typeContainer(IngredientModel e) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Serving Type",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: 30.w,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(0, 4, 8, 4),
              decoration: BoxDecoration(
                  // border: Border.all(color: Colors.grey),
                  // borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
              child: Text(
                e.amount_unit,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            )
          ],
        ),
        Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Quantity",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: 25.w,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(8, 4, 0, 4),
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.grey),
              //   borderRadius: BorderRadius.all(Radius.circular(6)),
              // ),
              child: Text(
                e.amount,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  _showDialogIngredient(IngredientModel e) {
    TextEditingController _servingTypeText = TextEditingController();
    TextEditingController _quantityText = TextEditingController();
    GlobalKey<FormState> _key = GlobalKey<FormState>();
    _servingTypeText.text = e.amount_unit;
    _quantityText.text = e.amount;
    return showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Container(
              // height: 500,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: Form(
                key: _key,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // SizedBox(width: 30),
                      SizedBox(
                        width: 60.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Spacer(),
                            Text(
                              e.item,
                              style: TextStyle(
                                fontSize: 16.px,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade300,
                              ),
                              softWrap: false,
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                ingridientList.removeWhere((element) {
                                  if (element == e.item) {
                                    for (int i = 0; i <= ingredientValueList.length; i++) {
                                      if ((ingredientValueList[i]['ingredient']) == element) {
                                        subNutriValues(ingredientValueList[i]);
                                        break;
                                      }
                                    }
                                    return true;
                                  }
                                  return false;
                                });
                                ingridientController.text = ingridientList.join(',');
                                setState(() {});
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.red.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        enabled: true,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Serving Type can't be empty";
                          }
                          // else if (value.length < 1) {
                          //   return "Serving type lenght must be more than 1 letter";
                          // }
                          return null;
                        },
                        controller: _servingTypeText,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Serving Type',
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Quantity can't be empty";
                          }
                          return null;
                        },
                        controller: _quantityText,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Quantity',
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        child: Text('Okay'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                        ),
                        onPressed: () {
                          if (_key.currentState.validate()) {
                            for (var ele in sendResult) {
                              if (ele["ingredient"] == e.item) {
                                ele["quantity"] = _quantityText.text;
                                ele["serving_unit_size"] = _servingTypeText.text;
                              }
                            }
                            Navigator.pop(context);
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
