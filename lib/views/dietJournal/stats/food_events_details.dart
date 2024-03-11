import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/apis/log_apis.dart';
import 'package:ihl/views/dietJournal/custom_food_detail.dart';
import 'package:ihl/views/dietJournal/food_detail.dart';
import 'package:ihl/views/dietJournal/models/log_user_food_intake_model.dart';
import 'package:ihl/views/dietJournal/models/view_custom_food_model.dart';
import 'package:ihl/views/dietJournal/stats/caloriesStats.dart';
import 'package:ihl/views/dietJournal/title_widget.dart';
import 'package:ihl/widgets/customSlideButton.dart';
import 'package:intl/intl.dart';
import 'package:loading_skeleton/loading_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../../new_design/presentation/controllers/healthJournalControllers/loadFoodList.dart';
import '../models/food_deatils_updated.dart';
import '../models/food_unit_detils.dart';

class FoodEventsDetails extends StatefulWidget {
  final Color screenColor;
  final String foodName;
  final double itemCount;
  String foodCatogry;
  final String foodId;
  String foodLogTime;
  List<MealsListData> mealsData;
  int foodEpchoid;

  FoodEventsDetails(
      {this.foodName,
      this.screenColor,
      this.itemCount,
      this.foodCatogry,
      this.foodId,
      this.foodLogTime,
      this.foodEpchoid,
      this.mealsData});

  @override
  State<FoodEventsDetails> createState() => _FoodEventsDetailsState();
}

class _FoodEventsDetailsState extends State<FoodEventsDetails> {
  UpdatedFoodDetails foodDetail;
  ListCustomRecipe customeFoodDetail;
  dynamic foodLogList = [];
  String foodName = " ";
  var foodQuanType = " ";
  double logQuan = 1.0;
  num quantity = 1;
  String _chosenValue;
  List<GetFoodUnit> foodUnit;
  double bseQaun = 0.25;
  String selectedTime;
  bool deleted = false;
  bool submitted = false;
  bool dataLoaded = false;
  bool customeDataLoaded = false;
  bool noDataFound = false;
  String sendTime;
  TimeOfDay picker;
  @override
  void initState() {
    super.initState();
    selectedTime = widget.foodLogTime;
    getFoodDetails();
  }

  void getFoodDetails() async {
    if (widget.foodId.length > 20) {
      var details = await ListApis.customFoodDetailsApi();
      if (details.isEmpty) {
        if (this.mounted) {
          setState(() {
            customeDataLoaded = false;
            noDataFound = true;
          });
        }
      }
      for (int i = 0; i < details.length; i++) {
        if (widget.foodId == details[i].foodId) {
          if (this.mounted) {
            setState(() {
              customeFoodDetail = details[i];
              customeDataLoaded = true;
              quantity = widget.itemCount;
            });
          }
        }
      }
      if (customeDataLoaded == false) {
        if (this.mounted) {
          setState(() {
            noDataFound = true;
          });
        }
      }
    } else {
      await ListApis.updatedGetFoodDetails(foodID: widget.foodId).then((data) async {
        if (data != null) {
          foodUnit = await ListApis.getFoodUnit(data.item);
          if (this.mounted) {
            setState(() {
              foodDetail = data;
              dataLoaded = true;
              quantity = widget.itemCount;
              print(foodDetail.calories);
            });
          }
        } else {}
      });
    }
    widget.mealsData.forEach((element) {
      (element.foodList.forEach((element2) {
        foodLogList.add(element2);
      }));
    });

    foodLogList.forEach((ele) {
      if (widget.foodLogTime == ele.foodTime) {
        foodName = ele.title;
        foodQuanType = ele.quantityUnit;
        logQuan = double.parse(ele.quantity);
        print(logQuan);
      }
    });
  }

  void deleteMeal() async {
    if (this.mounted) {
      setState(() {
        deleted = true;
      });
    }
    var logFood = await deleteLog();
    print(logFood);
    LogApis.editUserFoodLogApi(data: logFood).then((value) {
      if (value != null) {
        if (this.mounted) {
          setState(() {
            deleted = false;
          });
        }
        DateTime fromDate = DateFormat("dd-MM-yyyy HH:mm:ss").parse(widget.foodLogTime);
        var tillDate = widget.foodLogTime.substring(0, 11) + " 23:59:00";
        Get.to(CaloriesStats());
        Get.snackbar('Log Deleted',
            '${camelize(dataLoaded ? foodDetail.dish : customeFoodDetail.dish)} deleted successfully.',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        if (this.mounted) {
          setState(() {
            submitted = false;
          });
        }
        Get.close(1);
        Get.snackbar('Log not Deleted', 'Encountered some error while deleted. Please try later',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.cancel_rounded, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  Future<EditLogUserFood> deleteLog() async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    print(EditLogUserFood(
        userIhlId: iHLUserId,
        foodLogTime: widget.foodLogTime,
        epochLogTime: widget.foodEpchoid,
        foodTimeCategory: widget.foodCatogry,
        caloriesGained: '0',
        food: []));
    return EditLogUserFood(
        userIhlId: iHLUserId,
        foodLogTime: widget.foodLogTime,
        epochLogTime: widget.foodEpchoid,
        foodTimeCategory: widget.foodCatogry,
        caloriesGained: '0',
        food: []);
  }

  void customeFoodLogMeal() async {
    if (this.mounted) {
      setState(() {
        submitted = true;
      });
    }
    var fooddetail = FoodDetail(
        foodId: widget.foodId,
        foodName: customeFoodDetail.dish,
        foodQuantity: quantity.toString(),
        quantityUnit: customeFoodDetail.servingUnitSize);
    var logFood = await prepareForLog(fooddetail);
    LogApis.editUserFoodLogApi(data: logFood).then((value) {
      if (value != null) {
        if (this.mounted) {
          setState(() {
            submitted = false;
          });
        }
        Get.to(CaloriesStats());
        // ListApis.getUserTodaysFoodLogApi(widget.mealType.type).then((value) {
        //   Get.to(MealTypeScreen(
        //     mealsListData: value,
        //     cardioNavigate: false,
        //   ));
        // });
        Get.snackbar('Changes Logged!',
            '${camelize(dataLoaded ? foodDetail.dish : customeFoodDetail.dish)} logged successfully.',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        if (this.mounted) {
          setState(() {
            submitted = false;
          });
        }
        Get.close(1);
        Get.snackbar('Log not Changed', 'Encountered some error while logging. Please try again',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.cancel_rounded, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  void logMeal() async {
    if (this.mounted) {
      setState(() {
        submitted = true;
      });
    }
    var fooddetail = FoodDetail(
        foodId: widget.foodId,
        foodName: foodDetail.dish,
        foodQuantity: logQuan.toString(),
        quantityUnit: foodQuanType);

    var logFood = await prepareForLog(fooddetail);
    print(logFood);
    LogApis.editUserFoodLogApi(data: logFood).then((value) {
      if (value != null) {
        if (this.mounted) {
          setState(() {
            submitted = false;
          });
        }
        Get.to(CaloriesStats());
        Get.snackbar('Changes Logged!',
            '${camelize(dataLoaded ? foodDetail.dish : customeFoodDetail.dish)} logged successfully.',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        if (this.mounted) {
          setState(() {
            submitted = false;
          });
        }
        Get.close(1);
        Get.snackbar('Log not Changed', 'Encountered some error while logging. Please try again',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.cancel_rounded, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  Widget foodCard(String titleTxt, String subTxt) {
    String time = widget.foodLogTime.substring(11, 19);
    String date = widget.foodLogTime.substring(0, 10);
    TimeOfDay _startTime =
        TimeOfDay(hour: int.parse(time.split(":")[0]), minute: int.parse(time.split(":")[1]));
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    var formattedTime = localizations.formatTimeOfDay(_startTime);
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleView(
            titleTxt: camelize(dataLoaded ? foodDetail.dish : customeFoodDetail.dish),
            subTxt: 'View detail',
            onTap: () {
              dataLoaded
                  ? {
                      Get.delete<FoodDataLoaderController>(),
                      Get.to(FoodDetailScreen(
                        widget.foodId,
                        viewOnly: true,
                        foodCategory: widget.foodCatogry,
                        screenColor: widget.screenColor,
                      ))
                    }
                  : Get.to(CustomFoodDetailScreen(
                      customeFoodDetail,
                      viewOnly: true,
                      foodCategory: widget.foodCatogry,
                      screenColor: widget.screenColor,
                    ));
            },
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(10.0).copyWith(left: 24, right: 24),
            child: Container(
              child: DropdownButton<String>(
                focusColor: Colors.white,
                value: widget.foodCatogry,
                isExpanded: true,
                underline: Container(
                  height: 2.0,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            widget.foodName != null ? widget.screenColor : AppColors.primaryColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                iconEnabledColor: Colors.black,
                items: <String>['Breakfast', 'Lunch', 'Snacks', 'Dinner']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: ScUtil().setSp(16),
                      ),
                    ),
                  );
                }).toList(),
                hint: Text(
                  "Select Meal Type",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: ScUtil().setSp(16),
                      fontWeight: FontWeight.w600),
                ),
                onChanged: (String value) {
                  setState(() {
                    widget.foodCatogry = value;
                    _chosenValue = "true";
                  });
                },
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        selectedTime == widget.foodLogTime
                            ? widget.foodLogTime.substring(0, 11) + formattedTime
                            : widget.foodLogTime.substring(0, 11) + selectedTime,
                        style: TextStyle(
                          color: Colors.grey,
                          //fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 85),
                      // ClipOval(
                      //   child: Material(
                      //     color: widget.screenColor,
                      //     // button color
                      //     child: InkWell(
                      //       splashColor: Colors.red, // inkwell color
                      //       child: SizedBox(
                      //         width: 40,
                      //         height: 40,
                      //         child: Icon(
                      //           Icons.timelapse,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //       onTap: () async {
                      //         _selectTime(context);
                      //       },
                      //     ),
                      //   ),
                      // ),
                      // Text(
                      //   " ${widget.foodLogTime.substring(11, 16)}",
                      //   style: TextStyle(
                      //     color: Colors.grey,
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 16,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(
                    calculateCalories(dataLoaded ? foodDetail.calories : customeFoodDetail.calories,
                            logQuan.toString(), foodQuanType)
                        .toStringAsFixed(0),
                    style: TextStyle(
                      color:
                          widget.foodCatogry != null ? widget.screenColor : AppColors.primaryColor,
                      fontSize: 32,
                    ),
                  ),
                  Text(
                    "Cal",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(
                width: 180,
                child: CustomSlideButton(
                  backGroundColor: Colors.black12.withOpacity(0.2),
                  initialValue: logQuan,
                  speedTransitionLimitCount: 3,
                  firstIncrementDuration: Duration(milliseconds: 300),
                  secondIncrementDuration: Duration(milliseconds: 100),
                  direction: Axis.horizontal,
                  dragButtonColor:
                      widget.foodCatogry != null ? widget.screenColor : AppColors.primaryColor,
                  withSpring: true,
                  maxValue: bseQaun < 9 ? 20 : 200,
                  minValue: bseQaun,
                  withBackground: true,
                  withPlusMinus: true,
                  iconsColor:
                      widget.foodCatogry != null ? widget.screenColor : AppColors.primaryColor,
                  //withFastCount: true,
                  stepperValue: bseQaun,
                  onChanged: (double val) {
                    if (this.mounted) {
                      setState(() {
                        logQuan = val;
                        if (val != widget.itemCount) {
                          _chosenValue = 'true';
                        } else {
                          _chosenValue = null;
                        }
                      });
                    }
                  },
                  editMeal: true,
                ),
              ),
              Flexible(
                child: Text(
                  // camelize(dataLoaded ? foodQuanType : customeFoodDetail.servingUnitSize ?? 'Nos.'),
                  camelize(foodQuanType.replaceAll("(", "") ?? 'Nos.'),
                  softWrap: true,
                  overflow: TextOverflow.fade,
                  // maxLines: 2,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget noData() {
    return DietJournalUI(
      topColor: widget.foodCatogry != null ? widget.screenColor : AppColors.primaryAccentColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: LoadingSkeleton(
            width: 200,
            height: 20,
            colors: [Colors.grey, Colors.grey[300], Colors.grey],
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: LoadingSkeleton(
                  width: 400,
                  height: 250,
                  colors: [Colors.grey, Colors.grey[300], Colors.grey],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: LoadingSkeleton(
                  width: 400,
                  height: 150,
                  colors: [Colors.grey, Colors.grey[300], Colors.grey],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: LoadingSkeleton(
                width: 350,
                height: 100,
                colors: [Colors.grey, Colors.grey[300], Colors.grey],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return dataLoaded || customeDataLoaded
        ? IgnorePointer(
            ignoring: deleted,
            child: DietJournalUI(
              topColor:
                  widget.foodCatogry != null ? widget.screenColor : AppColors.primaryAccentColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () => Get.to(CaloriesStats()),
                ),
                title: AutoSizeText(
                  'Edit Food Log',
                  style: TextStyle(fontSize: 24.0, color: Colors.white),
                  maxLines: 1,
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        AwesomeDialog(
                          context: context,
                          animType: AnimType.TOPSLIDE,
                          dialogType: DialogType.WARNING,
                          title: "Confirm!",
                          desc: "Are you sure to delete this log",
                          btnOkOnPress: () {
                            deleteMeal();
                          },
                          btnCancelOnPress: () {},
                          btnCancelText: "Cancel",
                          btnOkText: "Delete",
                          btnCancelColor: AppColors.primaryAccentColor,
                          btnOkColor: widget.screenColor,
                        ).show();
                      },
                    ),
                  )
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                        height: 200,
                        width: 300,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[300],
                              offset: Offset(0.1, 0.1),
                              blurRadius: 18,
                            )
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            'https://static.vecteezy.com/system/resources/previews/000/463/565/non_2x/healthy-food-clipart-vector.jpg',
                            fit: BoxFit.fill,
                          ),
                        )),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: foodCard(dataLoaded ? foodDetail.item : customeFoodDetail.foodId,
                          dataLoaded ? foodDetail.quantity : customeFoodDetail.quantity),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
              fab: IgnorePointer(
                ignoring: submitted,
                child: Visibility(
                  visible: _chosenValue != null ? true : false,
                  child: FloatingActionButton.extended(
                      onPressed: () {
                        dataLoaded ? logMeal() : customeFoodLogMeal();
                      },
                      backgroundColor: widget.foodCatogry != null
                          ? widget.screenColor
                          : AppColors.primaryAccentColor,
                      label: Text(
                        'Change Log',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      icon: Icon(
                        Icons.set_meal,
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          )
        : noDataFound
            ? IgnorePointer(
                ignoring: deleted,
                child: DietJournalUI(
                  topColor: widget.screenColor != null
                      ? widget.screenColor
                      : AppColors.primaryAccentColor,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: AutoSizeText(
                      'Edit Food Log',
                      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                      maxLines: 1,
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteMeal();
                          },
                        ),
                      )
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30.0,
                        ),
                        Container(
                            height: 200,
                            width: 300,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[300],
                                  offset: Offset(0.1, 0.1),
                                  blurRadius: 18,
                                )
                              ],
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                'https://static.vecteezy.com/system/resources/previews/000/463/565/non_2x/healthy-food-clipart-vector.jpg',
                                fit: BoxFit.fill,
                              ),
                            )),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            "Oops! The Food has been Deleted",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                  fab: IgnorePointer(
                    ignoring: submitted,
                    child: Visibility(
                      visible: _chosenValue != null ? true : false,
                      child: FloatingActionButton.extended(
                          onPressed: () {
                            logMeal();
                          },
                          backgroundColor: widget.screenColor != null
                              ? widget.screenColor
                              : AppColors.primaryAccentColor,
                          label: Text(
                            'Change Log',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          icon: Icon(
                            Icons.set_meal,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              )
            : noData();
  }

  num calculateCalories(String defaultCalories, String quantity, String quantityUnit) {
    String unitCalories = defaultCalories;

    double addQuan;

    if (quantity != null) {
      if (quantityUnit == null) {
        return (double.parse(defaultCalories) * double.parse(quantity));
      } else {
        if (foodUnit != null && foodUnit.length != 0) {
          foodUnit.forEach((element) {
            if (element.servingUnitSize == quantityUnit.replaceAll("(", "")) {
              unitCalories = element.calories;
              bseQaun = double.parse(element.quantity);

              // unitQunatity = double.parse(element.quantity);
              // perQunatity = double.parse(element.quantity);
            }
          });
          addQuan = double.parse(quantity) / bseQaun;
          return (double.parse(unitCalories) * addQuan);
        } else {
          return 20.0;
        }
      }
    } else {
      return double.parse(unitCalories);
    }
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.dial,
        builder: (context, child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(colorScheme: ColorScheme.light(primary: widget.screenColor)),
                child: child,
              ));
        });
    if (timeOfDay != null) {
      setState(() {
        picker = timeOfDay;
        MaterialLocalizations localizations = MaterialLocalizations.of(context);
        var formattedTime = localizations.formatTimeOfDay(picker);
        selectedTime = formattedTime;
        sendTime = widget.foodLogTime.substring(0, 11) + picker.format(context) + ":00";
        _chosenValue = "true";
      });
    }
  }

  Future<EditLogUserFood> prepareForLog(FoodDetail fooddetail) async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    print(widget.foodLogTime);
    return EditLogUserFood(
        userIhlId: iHLUserId,
        foodLogTime: widget.foodLogTime,
        epochLogTime: widget.foodEpchoid,
        foodTimeCategory: widget.foodCatogry,
        caloriesGained: calculateCalories(
                dataLoaded ? foodDetail.calories : customeFoodDetail.calories,
                logQuan.toString(),
                foodQuanType)
            .toStringAsFixed(0),
        food: [
          Food(foodDetails: [fooddetail])
        ]);
  }
}
