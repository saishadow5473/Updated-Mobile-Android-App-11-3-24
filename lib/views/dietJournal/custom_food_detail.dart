import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/apis/log_apis.dart';
import 'package:ihl/views/dietJournal/create_new_meal.dart';
import 'package:ihl/views/dietJournal/models/food_list_tab_model.dart';
import 'package:ihl/views/dietJournal/models/log_user_food_intake_model.dart';
import 'package:ihl/views/dietJournal/models/view_custom_food_model.dart';
import 'package:ihl/views/dietJournal/stats/caloriesStats.dart';
import 'package:ihl/views/goal_settings/apis/goal_apis.dart';
import 'package:ihl/views/goal_settings/edit_goal_screen.dart';
import 'package:ihl/widgets/customSlideButton.dart';
import 'package:ihl/widgets/goalSetting/resuable_alert_box.dart';
import 'package:intl/intl.dart';
import 'package:loading_skeleton/loading_skeleton.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import 'dietJournal.dart';
import 'models/create_edit_meal_model.dart';

class CustomFoodDetailScreen extends StatefulWidget {
  final MealsListData mealType;
  final String foodCategory;
  final ListCustomRecipe customUserFood;
  final bool viewOnly;
  final Color screenColor;

  const CustomFoodDetailScreen(this.customUserFood,
      {this.viewOnly, this.mealType, this.foodCategory, this.screenColor});
  @override
  _CustomFoodDetailScreenState createState() => _CustomFoodDetailScreenState();
}

class _CustomFoodDetailScreenState extends State<CustomFoodDetailScreen> {
  ListCustomRecipe foodDetail;
  TextEditingController quantityTextController = TextEditingController(text: "1");
  bool dataLoaded = false;
  String _chosenValue;

  bool bookmarked = false;

  ///for checking the goals
  List goalLists = [];
  bool getGoalLoading = false;
  var formatedDate;
  DateTime _selectedDate = DateTime.now();
  String _hour, _minute, _time;
  var dateFormate = DateFormat('dd-MM-yyyy');
  bool futreTimeCheck = false;
  var finalDate;
  var finalTime;
  var textDate;
  String dateTime;
  TimeOfDay selectedTime = TimeOfDay.now();
  String formattedTime;

  @override
  void initState() {
    super.initState();
    checkbookmark();
    getDetails();
    exisitingDate();
  }

  exisitingDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("selected_food_log_date") != null) {
      DateTime sel = DateTime.parse(prefs.getString("selected_food_log_date"));
      sel != null ? _selectedDate = sel : null;
      prefs.remove("selected_food_log_date");
    }
    setState(() {});
  }

  void defaultDate() {
    setState(() {
      print(selectedTime);
      _hour = selectedTime.hour.toString();
      _minute = selectedTime.minute.toString();
      _time = _hour + ':' + _minute;
      finalTime = _time.toString();
      formatedDate = DateFormat("dd-MM-yyyy").format(_selectedDate);
      MaterialLocalizations localizations = MaterialLocalizations.of(context);
      formattedTime = localizations.formatTimeOfDay(selectedTime);
      DateTime tempDate = DateFormat("dd-MM-yyyy hh:mm").parse(formatedDate + " " + finalTime);
      print(tempDate);
      finalDate = tempDate;
      print(finalDate);
    });
  }

  Future<void> _selectDate(BuildContext context, StateSetter mystate) async {
    final DateTime d = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2015),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                      primary: widget.foodCategory == null && widget.mealType == null
                          ? AppColors.primaryAccentColor
                          : widget.foodCategory == null
                              ? HexColor(widget.mealType.startColor)
                              : widget.screenColor)),
              child: child);
        });
    print(d);
    if (d != null)
      mystate(() {
        _selectedDate = d;
        formatedDate = DateFormat("dd-MM-yyyy").format(_selectedDate);
        print(_selectedDate);
        if (_selectedDate.year == DateTime.now().year &&
            _selectedDate.month == DateTime.now().month &&
            _selectedDate.day == DateTime.now().day) {
          futreTimeCheck = selectedTime.hour > DateTime.now().hour
              ? true
              : (selectedTime.hour == DateTime.now().hour &&
                  selectedTime.minute > DateTime.now().minute);
        } else {
          futreTimeCheck = false;
        }
      });
  }

  Future<void> _selectTime(BuildContext context, StateSetter myState) async {
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (context, child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: Theme(
                data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                        primary: widget.foodCategory == null && widget.mealType == null
                            ? AppColors.primaryAccentColor
                            : widget.foodCategory == null
                                ? HexColor(widget.mealType.startColor)
                                : widget.screenColor)),
                child: child,
              ));
        });
    if (picked != null)
      myState(() {
        selectedTime = picked;
        MaterialLocalizations localizations = MaterialLocalizations.of(context);
        formattedTime = localizations.formatTimeOfDay(selectedTime);
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ':' + _minute;
        finalTime = _time.toString();
        textDate = dateFormate.parse('$_selectedDate');
        print(finalTime);
        // DateTime tempDate = Intl.withLocale(
        //     'en',
        //     () => DateFormat("dd-mm-yyyy hh:mm")
        //         .parse('$_selectedDate $finalTime'));
        var formatedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);
        String concartd = formatedDate + " " + finalTime;
        DateTime tempDate = DateFormat("dd-MM-yyyy hh:mm").parse(concartd);
        print(tempDate);
        finalDate = tempDate;
        // _timeController.text = _time;
        // _timeController.text = formatDate(
        //     DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
        //     [hh, ':', nn, " ", am]).toString();
        print(DateTime.now());
        print(_selectedDate.year == DateTime.now().year &&
            _selectedDate.hour == DateTime.now().hour &&
            _selectedDate.minute == DateTime.now().minute);
        if (_selectedDate.year == DateTime.now().year &&
            _selectedDate.month == DateTime.now().month &&
            _selectedDate.day == DateTime.now().day) {
          futreTimeCheck = selectedTime.hour > DateTime.now().hour
              ? true
              : (selectedTime.hour == DateTime.now().hour &&
                  selectedTime.minute > DateTime.now().minute);
        } else {
          futreTimeCheck = false;
        }
        // selectedTime.minute > DateTime.now().minute;
        print(finalTime);
        // DateTime tempDate = Intl.withLocale(
        //     'en',
        //     () => DateFormat("dd-mm-yyyy hh:mm")
        //         .parse('$_selectedDate $finalTime'));
        var _formatedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);
        String _concartd = _formatedDate + " " + finalTime;
        DateTime _tempDate = DateFormat("dd-MM-yyyy hh:mm").parse(_concartd);
        print(_tempDate);
        finalDate = _tempDate;
        // _timeController.text = _time;
        // _timeController.text = formatDate(
        //     DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
        //     [hh, ':', nn, " ", am]).toString();
      });
  }

  void getDetails() async {
    if (widget.customUserFood != null) {
      if (this.mounted) {
        setState(() {
          foodDetail = widget.customUserFood;
          dataLoaded = true;
          _chosenValue = widget.foodCategory == null
              ? (widget.mealType != null ? widget.mealType.type : null)
              : widget.foodCategory;
        });
      }
      addRecents();
    } else {}
  }

  void addRecents() async {
    await SpUtil.getInstance();
    List<FoodListTileModel> recentList = SpUtil.getRecentObjectList('recent_food') ?? [];
    bool exists = recentList.any((fav) => fav.foodItemID == foodDetail.foodId);
    if (!exists) {
      recentList.add(FoodListTileModel(
          foodItemID: foodDetail.foodId,
          title: foodDetail.dish,
          subtitle:
              "${foodDetail.quantity ?? 1} ${foodDetail.servingUnitSize != '' ? camelize(foodDetail.servingUnitSize) : 'Nos.'} | ${foodDetail.calories} Cal",
          extras: foodDetail));
    }
    //SpUtil.putReactiveRecentObjectList(recentList);
    SpUtil.putRecentObjectList('recent_food', recentList);
  }

  void deleteRecents() async {
    await SpUtil.getInstance();
    List<FoodListTileModel> recentList = SpUtil.getRecentObjectList('recent_food') ?? [];
    bool exists = recentList.any((fav) => fav.foodItemID == foodDetail.foodId);
    if (exists) {
      recentList.removeWhere((element) => element.foodItemID == foodDetail.foodId);
    }
    SpUtil.putRecentObjectList('recent_food', recentList);
  }

  void checkbookmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList("bookmarked_food");
    if (bookmarks != null) {
      bookmarked = bookmarks.contains(widget.customUserFood.foodId);
    }
  }

  void deleteFood() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Get.snackbar('Deleted!', '${camelize(foodDetail.dish ?? 'Name Unknown')} deleted successfully.',
        icon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(bookmarked ? Icons.favorite : Icons.favorite_border, color: Colors.white)),
        margin: EdgeInsets.all(20).copyWith(bottom: 40),
        backgroundColor: AppColors.primaryAccentColor,
        colorText: Colors.white,
        duration: Duration(seconds: 6),
        snackPosition: SnackPosition.BOTTOM);
    await LogApis.deleteCustomUserFoodApi(foodItemID: widget.customUserFood.foodId)
        .then((data) async {
      if (data != null) {
        deleteRecents();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DietJournal()),
            (Route<dynamic> route) => false);
        // Get.to(CaloriesStats());
        // Get.off(AddFood(
        //   selectedpage: 2,
        //   mealsListData: widget.mealType,
        // ));
      } else {
        Get.snackbar('Error!', 'Food not deleted',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.favorite, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        bookmarked = false;
      }
    });
  }

  Widget noData() {
    return DietJournalUI(
      topColor: widget.foodCategory == null && widget.mealType == null
          ? AppColors.primaryAccentColor
          : widget.foodCategory == null
              ? HexColor(widget.mealType.startColor)
              : widget.screenColor,
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
                width: 400,
                height: 150,
                colors: [Colors.grey, Colors.grey[300], Colors.grey],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget nutriInfo(String titleTxt, String subTxt) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                titleTxt,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  letterSpacing: 0.5,
                  color: AppColors.textitemTitleColor,
                ),
              ),
            ),
            Text(
              subTxt,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget nutriSubInfo(String titleTxt, String subTxt) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                titleTxt,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: 0.5,
                  color: AppColors.textitemTitleColor.withOpacity(0.8),
                ),
              ),
            ),
            Text(
              subTxt,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.5,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget foodCard(String titleTxt, String subTxt) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      height: ScUtil().setHeight(45),
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${foodDetail.quantity ?? 1} ${foodDetail.servingUnitSize != '' ? camelize(foodDetail.servingUnitSize) : 'Nos.'}  |  ${foodDetail.calories}Cal',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 20,
              letterSpacing: 0.5,
              color: AppColors.textitemTitleColor,
            ),
          ),
          // SizedBox(height: 12),
          // Text(
          //   'Prefered For',
          //   textAlign: TextAlign.left,
          //   style: TextStyle(
          //     fontFamily: FitnessAppTheme.fontName,
          //     fontWeight: FontWeight.w500,
          //     fontSize: 16,
          //     letterSpacing: 0.5,
          //     color: AppColors.textitemTitleColor,
          //   ),
          // ),
          // dynamicChips(),
        ],
      ),
    );
  }

/*
  Widget dynamicChips() {
    String timings = "01-01-2023";
    List _dynamicChips = timings.split(',');
    return Wrap(
      spacing: 4,
      alignment: WrapAlignment.spaceEvenly,
      runAlignment: WrapAlignment.spaceEvenly,
      children: List<Widget>.generate(_dynamicChips.length, (int index) {
        return Chip(
          label: Text(
            preferedTimings(_dynamicChips[index]),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: widget.foodCategory == null && widget.mealType == null
              ? AppColors.primaryAccentColor
              : widget.foodCategory == null
                  ? HexColor(widget.mealType.startColor)
                  : widget.screenColor,
          elevation: 6.0,
          shadowColor: Colors.grey[60],
        );
      }),
    );
  }
*/
  num calculateCalories(String defaultCalories, String quantity) {
    if (quantity != null) {
      if (double.parse(foodDetail.quantity) > 1.0) {
        return ((double.parse(defaultCalories) / double.parse(foodDetail.quantity)) *
            double.parse(quantity));
      }
      return (double.parse(defaultCalories) * double.parse(quantity));
    } else {
      return double.parse(defaultCalories);
    }
  }

  num calculateCarbs(String fiber, String sugar) {
    return (double.tryParse(fiber) + double.parse(sugar));
  }

  num calculateFats(String satFat, String polyUnsatFat, String monoUnsatFat) {
    return (double.parse(satFat) + double.tryParse(polyUnsatFat) + double.parse(monoUnsatFat));
  }

  num calculateOthers(String cholestrol, String sodium, String calcium, String potassium) {
    return ((double.parse(cholestrol) / 1000) +
        (double.parse(sodium) / 1000) +
        (double.parse(calcium) / 1000) +
        (double.parse(potassium) / 1000));
  }

  bool isAgree = false;

  @override
  Widget build(BuildContext context) {
    return dataLoaded
        ? GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);

              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: DietJournalUI(
                topColor: widget.foodCategory == null && widget.mealType == null
                    ? AppColors.primaryAccentColor
                    : widget.foodCategory == null
                        ? HexColor(widget.mealType.startColor)
                        : widget.screenColor,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: AutoSizeText(
                    camelize(foodDetail.dish ?? 'Name Unknown') ?? '',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.white),
                    // style:
                    //     TextStyle(color: Colors.white,fontSize: 24.0, fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () => Get.to(CreateNewMealScreen(
                          mealType: widget.mealType,
                          customUserFood: widget.customUserFood,
                          editCustomMeal: true,
                        )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: () async {
                          final value = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  title: Center(child: Text('Alert')),
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          'Are you sure you want \n to delete the meal?',
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                  actions: <Widget>[
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          TextButton(
                                            child: Text(
                                              'No',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text(
                                              'Yes',
                                              style: TextStyle(color: Colors.red, fontSize: 18),
                                            ),
                                            onPressed: () {
                                              deleteFood();
                                            },
                                          ),
                                        ])
                                  ],
                                );
                              });
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
                            child: Image.asset(
                              'newAssets/images/ingredients.png',
                              fit: BoxFit.cover,
                            ),
                          )),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: foodCard(foodDetail.dish, foodDetail.quantity),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          color: FitnessAppTheme.white,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Serving Type & Quantity",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w600,
                                    fontSize: ScUtil().setSp(20),
                                    letterSpacing: 0.5,
                                    color: AppColors.textitemTitleColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Container(
                                  padding: EdgeInsets.all(18.0),
                                  width: 85.w,
                                  // height: ScUtil.screenHeight / 2,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[300],
                                        offset: Offset(0.1, 0.1),
                                        blurRadius: 18,
                                      )
                                    ],
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        servingTypeAndQuantity(
                                            ingredientDetail: foodDetail.ingredientDetail)
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: FitnessAppTheme.white,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Nutritional Information",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w600,
                                    fontSize: ScUtil().setSp(20),
                                    letterSpacing: 0.5,
                                    color: AppColors.textitemTitleColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
                                child: Container(
                                  padding: EdgeInsets.all(18.0),
                                  // height: ScUtil.screenHeight / 2,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[300],
                                        offset: Offset(0.1, 0.1),
                                        blurRadius: 18,
                                      )
                                    ],
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: Column(children: [
                                    Visibility(
                                      visible: foodDetail.calories != '0.0' &&
                                          foodDetail.calories != '0' &&
                                          foodDetail.calories != null,
                                      child: nutrionList("Calories", foodDetail.calories),
                                    ),
                                    Visibility(
                                        visible: foodDetail.carbs != '0.0' &&
                                            foodDetail.carbs != '0' &&
                                            foodDetail.carbs != null,
                                        child: nutrionList("Carbohydrates", foodDetail.carbs)),
                                    Visibility(
                                        visible: foodDetail.fats != '0.0' &&
                                            foodDetail.fats != '0' &&
                                            foodDetail.fats != null,
                                        child: nutrionList("Fats", foodDetail.fats)),
                                    Visibility(
                                        visible: foodDetail.fiber != '0.0' &&
                                            foodDetail.fiber != '0' &&
                                            foodDetail.fiber != null,
                                        child: nutrionList("Fiber", foodDetail.fiber)),
                                    Visibility(
                                        visible: foodDetail.protein != '0.0' &&
                                            foodDetail.protein != '0' &&
                                            foodDetail.protein != null,
                                        child: nutrionList("Protein", foodDetail.protein)),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      /*
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: CardColors.bgColor,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Container(
                                  padding: EdgeInsets.all(18.0),
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[300],
                                        offset: Offset(0.1, 0.1),
                                        blurRadius: 18,
                                      )
                                    ],
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Nutritional Information",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 14),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Text(
                                                foodDetail.calories,
                                                style: TextStyle(
                                                  color: widget.foodCategory == null &&
                                                          widget.mealType == null
                                                      ? AppColors.primaryAccentColor
                                                      : widget.foodCategory == null
                                                          ? HexColor(widget.mealType.startColor)
                                                          : widget.screenColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      foodDetail.calories.length > 2 ? 15 : 24,
                                                ),
                                              ),
                                              Text(
                                                "kCal",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Text(
                                                foodDetail.fats + 'g',
                                                style: TextStyle(
                                                  color: Color(0xFF23233C),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: foodDetail.fats.length > 2 ? 15 : 24,
                                                ),
                                              ),
                                              Text(
                                                "gross fat",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              // Text(
                                              //   foodDetail.totalCarbohydrate + 'g',
                                              //   style: TextStyle(
                                              //     color: Color(0xFF23233C),
                                              //     fontWeight: FontWeight.bold,
                                              //     fontSize: foodDetail.totalCarbohydrate.length > 2
                                              //         ? 15
                                              //         : 24,
                                              //   ),
                                              // ),
                                              Text(
                                                "carbohydrate",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Text(
                                                foodDetail.protein + 'g',
                                                style: TextStyle(
                                                  color: Color(0xFF23233C),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: foodDetail.protein.length > 2 ? 15 : 24,
                                                ),
                                              ),
                                              Text(
                                                "protien",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              nutriInfo(
                                  'Carbs',
                                  calculateCarbs(foodDetail.fiber ?? '0', foodDetail.carbs ?? '0')
                                          .toStringAsFixed(2) +
                                      'g'),
                              SizedBox(height: 8),
                              nutriSubInfo('Fiber', foodDetail.fiber + 'g'),
                              SizedBox(height: 8),
                              // nutriSubInfo('Sugars', foodDetail.sugar + 'g'),
                              // SizedBox(height: 12),
                              // nutriInfo(
                              //     'Fat',
                              //     calculateFats(
                              //                 foodDetail. ?? '0',
                              //                 foodDetail.monounsaturatedFats ?? '0',
                              //                 foodDetail.polyunsaturatedFats ?? '0')
                              //             .toStringAsFixed(2) +
                              //         'g'),
                              // SizedBox(height: 8),
                              nutriSubInfo('Saturated Fat', foodDetail.fats + 'g'),
                              // SizedBox(height: 8),
                              // nutriSubInfo(
                              //     'Mono Unsaturated Fat', foodDetail.monounsaturatedFats + 'g'),
                              // SizedBox(height: 8),
                              // nutriSubInfo(
                              //     'Poly Unsaturated Fat', foodDetail.polyunsaturatedFats + 'g'),
                              // SizedBox(height: 8),
                              // nutriSubInfo('Transfatty Acid', foodDetail.transfattyAcid + 'mg'),
                              // SizedBox(height: 12),
                              // nutriInfo(
                              //     'Others',
                              //     calculateOthers(
                              //                 foodDetail.colesterol ?? '0',
                              //                 foodDetail.sodium ?? '0',
                              //                 foodDetail.calcium ?? '0',
                              //                 foodDetail.potassium ?? '0')
                              //             .toStringAsFixed(2) +
                              //         'g'),
                              // SizedBox(height: 8),
                              // nutriSubInfo('Cholesterol', (foodDetail.colesterol ?? '0') + 'mg'),
                              // SizedBox(height: 8),
                              // nutriSubInfo('Sodium', (foodDetail.sodium ?? '0') + 'mg'),
                              // SizedBox(height: 8),
                              // nutriSubInfo('Potassium', (foodDetail.potassium ?? '0') + 'mg'),
                              // SizedBox(height: 8),
                              // nutriSubInfo('Calcium', (foodDetail.calcium ?? '0') + '%'),
                              // SizedBox(height: 8),
                              // nutriSubInfo('Iron', (foodDetail.iron ?? '0') + '%'),
                              // SizedBox(height: 8),
                              // nutriSubInfo('Vitamin A', (foodDetail.vitaminA ?? '0') + '%'),
                              // SizedBox(height: 8),
                              // nutriSubInfo('Vitamin C', (foodDetail.vitaminC ?? '0') + '%'),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      */
                      SizedBox(height: 40),
                    ],
                  ),
                ),
                fab: Visibility(
                  visible: widget.viewOnly == null,
                  child: FloatingActionButton.extended(
                      onPressed: () async {
                        ///call a function from here that will return true or false
                        //according to that either user log the meal or we show an pop up
                        //that will say user to edit the goal
                        // logMeal(context);//this line should be commented and the if else condition below should be uncommented after complete this

                        try {
                          await isGoalNeedToChange().then((v) async {
                            if (v) {
                              alertBox('Change Your Goal', Colors.black, false);
                            } else {
                              logMeal(context);
                            }
                          });
                        } catch (e) {
                          print(e.toString());
                          logMeal(context);
                        }
                      },
                      backgroundColor: widget.foodCategory == null && widget.mealType == null
                          ? AppColors.primaryAccentColor
                          : widget.foodCategory == null
                              ? HexColor(widget.mealType.startColor)
                              : widget.screenColor,
                      label: Text(
                        'Add to Log',
                        style: TextStyle(color: FitnessAppTheme.white),
                      ),
                      icon: Icon(Icons.set_meal, color: FitnessAppTheme.white)),
                )),
          )
        : noData();
  }

  Widget nutrionList(String titleTxt, String subTxt) {
    return ListTile(
        title: Text(
          titleTxt,
          style: TextStyle(fontSize: ScUtil().setSp(20)),
        ),
        trailing: Text(
          subTxt.toString().replaceAll("_", " ").capitalize,
          style: TextStyle(color: Colors.green, fontSize: ScUtil().setSp(18)),
        ));
  }

  Widget servingTypeAndQuantity({List<IngredientModel> ingredientDetail}) {
    TextStyle txtstyle = TextStyle(
        color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 12.px);
    return Column(
      children: [
        Row(
          children: [
            Container(
                width: 25.w,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Name",
                  style: txtstyle,
                )),
            Container(
                width: 25.w,
                alignment: Alignment.center,
                child: Text(
                  "Serving Type",
                  style: txtstyle,
                )),
            Container(
                width: 25.w,
                alignment: Alignment.center,
                child: Text(
                  "Quantity",
                  style: txtstyle,
                )),
          ],
        ),
        Divider(
          thickness: 1,
        ),
        ...ingredientDetail
            .map((e) => Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Container(
                                width: 25.w, alignment: Alignment.centerLeft, child: Text(e.item))),
                        Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Container(
                                width: 25.w,
                                alignment: Alignment.center,
                                child: Text(e.amount_unit))),
                        Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Container(
                                width: 25.w, alignment: Alignment.center, child: Text(e.amount))),
                      ],
                    ),
                    Divider(),
                  ],
                ))
            .toList()
      ],
    );
  }

  String preferedTimings(String timings) {
    switch (timings) {
      case 'SS':
        {
          return 'Snacks';
        }
        break;

      case 'B':
        {
          return 'Breakfast';
        }
        break;
      case 'L':
        {
          return 'Lunch';
        }
        break;
      case 'D':
        {
          return 'Dinner';
        }
        break;
      case 'ES':
        {
          return 'Eve. Snack';
        }
        break;
      case 'MS':
        {
          return 'Morn. Snack';
        }
        break;
      case 'BT':
        {
          return 'Bedtime';
        }
        break;
      case 'EM':
        {
          return 'Early Morn.';
        }
        break;
      case 'LH':
        {
          return 'Lunch';
        }
        break;
      case 'DR':
        {
          return 'Dinner';
        }
        break;
      case 'AF':
        {
          return 'Lunch';
        }
        break;

      default:
        {
          return 'AnyTime';
        }
        break;
    }
  }

  logMeal(BuildContext context) {
    num quantity = quantityAsign(foodDetail.servingUnitSize);
    bool submitted = false;
    var defaultFormatedDate = DateFormat('dd.MM.yyyy').format(_selectedDate);
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    String defaultFormattedTime = localizations.formatTimeOfDay(selectedTime);
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter mystate) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 75.w,
                        child: AutoSizeText(
                          'Log ${camelize(foodDetail.dish ?? 'Name Unknown')}',
                          style: TextStyle(
                            color: AppColors.appTextColor, //AppColors.primaryColor
                            fontSize: 24,
                            //fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      // IconButton(
                      //     onPressed: () {
                      //       log("info selected");
                      //       Get.to(InfoQuantityScreen(
                      //         appBarColor: widget.foodCategory == null && widget.mealType == null
                      //             ? AppColors.primaryAccentColor
                      //             : widget.foodCategory == null
                      //                 ? HexColor(widget.mealType.startColor)
                      //                 : widget.screenColor,
                      //       ));
                      //     },
                      //     icon: Icon(Icons.info_outline))
                    ],
                  ),
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 2,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0).copyWith(left: 24, right: 24),
                  child: Container(
                    child: DropdownButton<String>(
                      focusColor: Colors.white,
                      value: _chosenValue,
                      isExpanded: true,
                      underline: Container(
                        height: 2.0,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: widget.foodCategory == null && widget.mealType == null
                                  ? AppColors.primaryAccentColor
                                  : widget.foodCategory == null
                                      ? HexColor(widget.mealType.startColor)
                                      : widget.screenColor,
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
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      hint: Text(
                        "Select Meal Type",
                        style: TextStyle(
                            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onChanged: (String value) {
                        mystate(() {
                          _chosenValue = value;
                        });
                      },
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 120.0),
                            child: Text(
                              calculateCalories(foodDetail.calories, quantity.toString())
                                  .toStringAsFixed(0),
                              style: TextStyle(
                                color: widget.foodCategory == null && widget.mealType == null
                                    ? AppColors.primaryAccentColor
                                    : widget.foodCategory == null
                                        ? HexColor(widget.mealType.startColor)
                                        : widget.screenColor,
                                //fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
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
                      Padding(
                        padding: const EdgeInsets.only(top: 20, right: 10, bottom: 20, left: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 8.0, top: 8.0, bottom: 8.0, left: 15),
                              child: ClipOval(
                                child: Material(
                                  color: widget.foodCategory == null && widget.mealType == null
                                      ? AppColors.primaryAccentColor
                                      : widget.foodCategory == null
                                          ? HexColor(widget.mealType.startColor)
                                          : widget.screenColor,
                                  // button color
                                  child: InkWell(
                                    splashColor: Colors.red, // inkwell color
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: () async {
                                      _selectDate(context, mystate);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: formatedDate != null
                                    ? Text(
                                        "$formatedDate",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: ScUtil().setSp(12),
                                        ),
                                      )
                                    : Text(
                                        "$defaultFormatedDate",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: ScUtil().setSp(12),
                                        ),
                                      )),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0, left: 60.0),
                              child: ClipOval(
                                child: Material(
                                  color: widget.foodCategory == null && widget.mealType == null
                                      ? AppColors.primaryAccentColor
                                      : widget.foodCategory == null
                                          ? HexColor(widget.mealType.startColor)
                                          : widget.screenColor,
                                  // button color
                                  child: InkWell(
                                    splashColor: Colors.red, // inkwell color
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Icon(
                                        Icons.timelapse,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: () async {
                                      _selectTime(context, mystate);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: formattedTime != null
                                    ? Text(
                                        "$formattedTime",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: ScUtil().setSp(12),
                                        ),
                                      )
                                    : Text(
                                        "$defaultFormattedTime",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: ScUtil().setSp(12),
                                        ),
                                      )),
                            Visibility(
                                visible: futreTimeCheck,
                                child: Text(
                                  "Future Time is not valid",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SizedBox(
                      width: 180,
                      child: CustomSlideButton(
                        customFoodServingType: foodDetail.servingUnitSize,
                        backGroundColor: Colors.black12.withOpacity(0.2),
                        initialValue: double.parse(foodDetail.quantity),
                        speedTransitionLimitCount: 3,
                        firstIncrementDuration: Duration(milliseconds: 300),
                        secondIncrementDuration: Duration(milliseconds: 100),
                        direction: Axis.horizontal,
                        dragButtonColor: widget.foodCategory == null && widget.mealType == null
                            ? AppColors.primaryAccentColor
                            : widget.foodCategory == null
                                ? HexColor(widget.mealType.startColor)
                                : widget.screenColor,
                        withSpring: true,
                        maxValue: 20,
                        minValue: double.parse(foodDetail.quantity),
                        withBackground: true,
                        withPlusMinus: true,
                        iconsColor: widget.foodCategory == null && widget.mealType == null
                            ? AppColors.primaryAccentColor
                            : widget.foodCategory == null
                                ? HexColor(widget.mealType.startColor)
                                : widget.screenColor,
                        //withFastCount: true,
                        stepperValue: quantity,
                        onChanged: (double val) {
                          mystate(() {
                            quantity = val;
                          });
                        },
                        editMeal: false,
                      ),
                    ),
                    Text(
                      camelize(foodDetail.servingUnitSize ?? 'Nos.'),
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                IgnorePointer(
                  ignoring: submitted,
                  child: Visibility(
                    visible: _chosenValue != null ? true : false,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              primary: widget.foodCategory == null && widget.mealType == null
                                  ? AppColors.primaryAccentColor
                                  : widget.foodCategory == null
                                      ? HexColor(widget.mealType.startColor)
                                      : widget.screenColor,
                            ),
                            child: submitted
                                ? Container(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Add to $_chosenValue',
                                    style: TextStyle(color: Colors.white),
                                  ),
                            onPressed: futreTimeCheck
                                ? () {}
                                : _chosenValue != null
                                    ? () async {
                                        mystate(() {
                                          submitted = true;
                                          if (finalDate == null) {
                                            defaultDate();
                                          }
                                        });
                                        var fooddetail = FoodDetail(
                                            foodId: widget.customUserFood.foodId,
                                            foodName: foodDetail.dish ?? 'Name Unknown',
                                            foodQuantity: quantity.toString(),
                                            quantityUnit: foodDetail.servingUnitSize);
                                        var logFood = await prepareForLog(fooddetail, quantity);
                                        LogApis.logUserFoodIntakeApi(data: logFood).then((value) {
                                          if (value != null) {
                                            if (this.mounted) {
                                              setState(() {
                                                submitted = false;
                                              });
                                            }
                                            ListApis.getUserTodaysFoodLogApi(_chosenValue)
                                                .then((value) {
                                              Get.close(2);
                                              Get.to(CaloriesStats());
                                              // Get.to(MealTypeScreen(
                                              //   mealsListData: value,
                                              //   cardioNavigate: false,
                                              // ));
                                            });
                                            Get.snackbar('Logged!',
                                                '${camelize(foodDetail.dish)} logged successfully.',
                                                icon: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Icon(Icons.check_circle,
                                                        color: Colors.white)),
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
                                            Get.snackbar('Food not Logged',
                                                'Encountered some error while logging. Please try again',
                                                icon: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Icon(Icons.cancel_rounded,
                                                        color: Colors.white)),
                                                margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                                duration: Duration(seconds: 5),
                                                snackPosition: SnackPosition.BOTTOM);
                                          }
                                        });
                                      }
                                    : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            );
          });
        });
  }

  Future<LogUserFood> prepareForLog(FoodDetail fooddetail, num quantity) async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    var now = finalDate;
    int epochTime = now.millisecondsSinceEpoch;
    return LogUserFood(
        userIhlId: iHLUserId,
        foodLogTime: now,
        epochLogTime: epochTime,
        foodTimeCategory: _chosenValue,
        caloriesGained:
            calculateCalories(foodDetail.calories, quantity.toString()).toStringAsFixed(0),
        food: [
          Food(foodDetails: [fooddetail])
        ]);
  }

  alertBox(alertText, txtColor, allow) {
    _buildChild(BuildContext context, StateSetter mystate) => ReusableAlertBox(
          alertText: alertText,
          allow: allow,
          context: context,
          isAgree: isAgree,
          mystate: mystate,
          txtColor: txtColor,
          continueOnTap: () {},
          changeOnTap: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewGoalSettingScreen(
                    goalChangeNavigation: true,
                  ),
                ),
                (Route<dynamic> route) => false);
          },
        );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter mystate) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: _buildChild(context, mystate),
                );
              },
            ),
          );
        });
  }

  isGoalNeedToChange() async {
    var needChange;

    ///check here is any goal of the user is become impossible
    //1,=> first check weather user has any goal if yes than go to 2nd step other wise return false;
    await getActiveGoals().then((value) async {
      if (value.length > 0) {
        //2,=> secondly check if users any goal become impossible if yes than return true otherwise all okay than return false;
        //2.1 for checking users goal write a function that can return that can return true or false respectively
        await isGoalImpossible(value).then((changeGoal) async {
          if (changeGoal) {
            needChange = true;
            return true;
          } else {
            needChange = false;
            return false;
          }
        });
      } else {
        needChange = false;
        return false;
      }
    });
    return needChange;
  }

  getActiveGoals() async {
    var goalList1 = [];
    await GoalApis.listGoal().then((value) async {
      if (value != null) {
        List<dynamic> activeGoalLists = [];
        for (int i = 0; i < value.length; i++) {
          if (value[i]['goal_status'] == 'active') {
            activeGoalLists.add(value[i]);
          }
        }
        if (this.mounted) {
          setState(() {
            goalLists = activeGoalLists;
            getGoalLoading = true;
            goalList1 = goalLists;
          });
        }
        return goalList1;
      } else {
        return [];
      }
    });
    return goalList1;
  }

  isGoalImpossible(value) async {
    var impos;
    // if any of the goal is become impossible than true and if no than false;
    for (int i = 0; i < value.length; i++) {
      var goal = value[i];
      await getTargetCalorie(goal).then((targetCalorie) {
        if (int.tryParse(targetCalorie) > 3000) {
          impos = true;
          return true;
        } else if (int.tryParse(targetCalorie) < 100) {
          impos = true;
          return true;
        } else {
          impos = false;
          return false;
        }
      });
    }

    return impos;
  }

  getTargetCalorie(goal) async {
    ///by diet function
    ///by activity function
    ///by both function
    ///by gain function
    ///maintain weight function

    var tagetCalorie;
    // var currentWeight;
    var targetWeight = goal['target_weight'];
    // var goalDuration;
    // var goalCaloriesIntake;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var height = prefs.get('userLatestHeight').toString();
    var currentWeight = await prefs.get('userLatestWeight').toString();

    ///conditon for knowing the type of goal
    await getGoalCalorieIntake(goal['target_weight']).then((goalCaloriesIntake) async {
      DateTime today = DateTime.now();
      // DateTime achieveBy = today.add(Duration(days: noOfDays));
      // var noD = goal['goal_date'].diffrence(today).inDays;
      var previousAchivedDate = DateFormat('MMMM d, yyyy', 'en_US').parse(goal['goal_date']);
      var noOfDays = previousAchivedDate.difference(today).inDays;
      // double loseWeight =  double.tryParse(currentWeight) - double.tryParse(targetWeight);
      // //here noOfDays we get by creting the diffrence from goal_date & todays date
      // ///int noOfDays = ((loseWeight ~/ goalDuration) * 3.5).toInt();
      // ///goalDuration we get from above formula by manipulating it
      // var goalDuration = ((loseWeight / noOfDays) * 3.5);
      // tagetCalorie = (double.parse(goalCaloriesIntake) - (500 * goalDuration))
      //     .toStringAsFixed(0);
      ///lose weight by diet
      if (goal['goal_type'] == 'lose_weight' && goal['goal_sub_type'] == 'reduce_only_by_diet') {
        //lose by diet
        tagetCalorie = await targetCalorieForLoseByDiet(
            currentWeight: currentWeight,
            noOfDays: noOfDays,
            goalCaloriesIntake: goalCaloriesIntake,
            targetWeight: targetWeight);
      }

      ///lose weight by activity
      else if (goal['goal_type'] == 'lose_weight' &&
          goal['goal_sub_type'] == 'reduce_by_exercise') {
        var bmrRateForAlert = maxDuration(goal['activitiy_level']);
        tagetCalorie = ((int.tryParse(goalCaloriesIntake)) * (bmrRateForAlert)).toStringAsFixed(0);
      }

      ///lose weight by both
      // else if(double.parse(goal['target_weight'])<double.parse(goal['weight'])){
      else if (goal['goal_type'] == 'lose_weight' && goal['goal_sub_type'] == 'both') {
        // var bmrRateForAlert = maxDuration(goal['activitiy_level']);
        double loseWeight = double.tryParse(currentWeight) - double.tryParse(targetWeight);
        var goalDuration = (loseWeight / noOfDays) * 7;
        tagetCalorie = ((double.parse(goalCaloriesIntake) * maxDuration(goal['activitiy_level'])) -
                (500 * goalDuration))
            .toStringAsFixed(0);
      }

      ///gain weight
      // else if(double.parse(goal['target_weight'])>double.parse(goal['weight'])){
      else if (goal['goal_type'] == 'gain_weight') {
        tagetCalorie = goalCaloriesIntake.toStringAsFixed(0);
      }

      ///maintain weight
      // else if(double.parse(goal['target_weight'])==double.parse(goal['weight'])){
      else if (goal['goal_type'] == 'maintain_weight') {
        tagetCalorie = goalCaloriesIntake.toStringAsFixed(0);
      }

      return tagetCalorie;
    });
    // }

    ///write the logic for calculating the targetCalorie from the updated weight;
    //take the updated weight;
    //than calculate LoseWeight from the formula
    //than you will calculate the goal pace(you have old goal pace but you are not gonna use that{you will calcukate the
    // goal pace by the updated number of days})
    return tagetCalorie;
  }

  getGoalCalorieIntake(weight) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = prefs.get('data');
    Map res = jsonDecode(userData);
    var height;
    var goalCaloriesIntake;
    String datePattern = "MM/dd/yyyy";
    var dob = res['User']['dateOfBirth'].toString();
    DateTime today = DateTime.now();
    DateTime birthDate = DateFormat(datePattern).parse(dob);
    int age = today.year - birthDate.year;
    if (res['User']['heightMeters'] is num) {
      height = (res['User']['heightMeters'] * 100).toInt().toString();
    }
    var m = res['User']['gender'];
    num maleBmr =
        (10 * double.parse(weight.toString()) + 6.25 * double.parse(height) - (5 * age) + 5);
    num femaleBmr = (10 * double.parse(weight) + 6.25 * double.parse(height) - (5 * age) - 161);
    if (m == 'm' || m == 'M' || m == 'male' || m == 'Male') {
      if (this.mounted) {
        setState(() {
          goalCaloriesIntake = maleBmr.toStringAsFixed(0);
          // return goalCaloriesIntake;
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          goalCaloriesIntake = femaleBmr.toStringAsFixed(0);
          // return goalCaloriesIntake;
        });
      }
    }
    return goalCaloriesIntake;
  }

  targetCalorieForLoseByDiet({currentWeight, targetWeight, noOfDays, goalCaloriesIntake}) {
    double loseWeight = double.tryParse(currentWeight) - double.tryParse(targetWeight);
    //here noOfDays we get by creting the diffrence from goal_date & todays date
    ///int noOfDays = ((loseWeight ~/ goalDuration) * 3.5).toInt();
    ///goalDuration we get from above formula by manipulating it
    var goalDuration = ((loseWeight / noOfDays) * 3.5);
    var tagetCalorie = (double.parse(goalCaloriesIntake) - (500 * goalDuration)).toStringAsFixed(0);
    return tagetCalorie;
  }

  double maxDuration(String goalPlan) {
    if (goalPlan == 'Sedentary (little/no exercises)') {
      return 1.0;
    } else if (goalPlan == 'Lightly Active (exercise 1-3days/wk)') {
      return 1.4;
    } else if (goalPlan == 'Moderately Active (exercise 6-7days/wk)') {
      return 1.6;
    } else if (goalPlan == 'Very Active (hard exercise every day)') {
      return 1.8;
    } else if (goalPlan == 'High Intense Training (Atheletic training)') {
      return 2.0;
    } else {
      return 1.0;
    }
  }
}
//
// alertBox(alertText,txtColor,allow) {
//   _buildChild(BuildContext context) => Container(
//     height: 350,
//     decoration: BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.rectangle,
//         borderRadius: BorderRadius.all(Radius.circular(12))),
//     child: Column(
//       children: <Widget>[
//         Container(
//           child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 children: [
//                   SizedBox(
//                     width: 100,
//                     height: 100,
//                     child: Image.network(
//                         'https://i.postimg.cc/gj4Dfy7g/Objective-PNG-Free-Download.png'),
//                   ),
//                   // Icon(
//                   //   FontAwesomeIcons.palette,
//                   //   size: 80,
//                   //   color: Colors.white,
//                   // ),
//                   // SizedBox(
//                   //   height: 20,
//                   // ),
//                 ],
//               )),
//           width: double.infinity,
//           decoration: BoxDecoration(
//               color: Colors.green,//AppColors.primaryColor,
//               shape: BoxShape.rectangle,
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12))),
//         ),
//         SizedBox(
//           height: 24,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(right: 16, left: 16),
//           child: Text(
//             alertText,
//             style: TextStyle(color: txtColor, fontSize: 20),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         SizedBox(
//           height: 60,
//         ),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: allow?MainAxisAlignment.spaceEvenly:MainAxisAlignment.center,
//           children: [
//             // SizedBox(
//             //   width: MediaQuery.of(context).size.width / 10,
//             // ),
//             Visibility(
//               visible: allow,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   elevation: 0.5,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   primary: AppColors.primaryColor,
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                       top: 13.0, bottom: 13.0, right: 15, left: 15),
//                   child: Text(
//                     'Continue',
//                     style: TextStyle(
//                         fontSize: 15, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 onPressed: () async {
//                   if(allow){
//                     Get.to(ViewGoalSettingScreen());
//                   }
//                 },
//               ),
//             ),
//
//             // SizedBox(
//             //   width: MediaQuery.of(context).size.width / 8,
//             // ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 elevation: 0.5,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//                 primary: AppColors.primaryColor,
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.only(
//                     top: 13.0, bottom: 13.0, right: 15, left: 15),
//                 child: Text(
//                   'Change',
//                   style: TextStyle(
//                       fontSize: 15, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.pop(context);
//                 // Get.to(ViewGoalSettingScreen());
//               },
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
//   showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async => false,
//           child: Dialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16)),
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             child: _buildChild(context),
//           ),
//         );
//       });
// }
