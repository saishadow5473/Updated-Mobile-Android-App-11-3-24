import 'dart:convert';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/apis/log_apis.dart';
import 'package:ihl/views/dietJournal/models/food_deatils_updated.dart';
import 'package:ihl/views/dietJournal/models/food_list_tab_model.dart';
import 'package:ihl/views/dietJournal/models/log_user_food_intake_model.dart';
import 'package:ihl/views/dietJournal/stats/caloriesStats.dart';
import 'package:ihl/views/dietJournal/stats/info_quantity_screen.dart';
import 'package:ihl/views/goal_settings/apis/goal_apis.dart';
import 'package:ihl/views/goal_settings/edit_goal_screen.dart';
import 'package:ihl/widgets/customSlideButton.dart';
import 'package:ihl/widgets/goalSetting/resuable_alert_box.dart';
import 'package:intl/intl.dart';
import 'package:loading_skeleton/loading_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:strings/strings.dart';

import 'models/food_unit_detils.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodItemId;
  final bool viewOnly;
  final MealsListData mealtype;
  final String foodCategory;
  final Color screenColor;

  const FoodDetailScreen(this.foodItemId,
      {this.viewOnly, this.mealtype, this.foodCategory, this.screenColor});
  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  //ViewFoodDetail foodDetail;
  UpdatedFoodDetails updatedFoodDetails;
  List<GetFoodUnit> foodUnit;
  var unitQunatity = 1.0;
  double countAdd = 1;
  double perQunatity;
  var formatedDate;
  String unitDropDown;
  double quantity = 1.0;
  TextEditingController quantityTextController = TextEditingController(text: "1");
  bool dataLoaded = false;
  String _chosenValue;
  // double quantity = 0.25;
  bool bookmarked = false;
  DateTime _selectedDate = DateTime.now();
  String _hour, _minute, _time;
  var dateFormate = DateFormat('dd-MM-yyyy');
  bool futreTimeCheck = false;
  bool serveCheck = true;
  var finalDate;
  var finalTime;
  var textDate;
  String dateTime;
  TimeOfDay selectedTime = TimeOfDay.now();
  String formattedTime;

  ///for checking the goals
  List goalLists = [];
  bool getGoalLoading = false;
  bool isAgree = false;
  // var dateText = DateFormat("dd-MM-yyyy hh:mm")
  //               .parse('$_selectedDate $finalTime');

  @override
  void initState() {
    super.initState();
    checkbookmark();
    getDetails();
    exisitingDate();
    // initializeDateFormatting("en", null);
  }

  exisitingDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime sel = DateTime.parse(prefs.getString("selected_food_log_date"));
    sel != null ? _selectedDate = sel : null;
    prefs.remove("selected_food_log_date");
    setState(() {});
  }

  // Future<void> _selecteDate(BuildContext context, StateSetter mystate) async {
  //   final DateTime d=DateTimePickerFormField(
  //           dateOnly: true,
  //           format: dateFormat,
  //           decoration: InputDecoration(labelText: 'Select Date'),
  //           initialValue: DateTime.now(), //Add this in your Code.
  //           initialDate: DateTime(2017),
  //           onSaved: (value) {
  //             debugPrint(value.toString());
  //           },
  //         ),
  // }
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
                      primary: widget.foodCategory == null
                          ? HexColor(widget.mealtype.startColor)
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
                        primary: widget.foodCategory == null
                            ? HexColor(widget.mealtype.startColor)
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
        // futreTimeCheck = _selectedDate.isAfter(DateTime.now());
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
        var formatedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);
        String concartd = formatedDate + " " + finalTime;
        DateTime tempDate = DateFormat("dd-MM-yyyy hh:mm").parse(concartd);
        print(tempDate);
        finalDate = tempDate;
        // _timeController.text = _time;
        // _timeController.text = formatDate(
        //     DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
        //     [hh, ':', nn, " ", am]).toString();
      });
  }

  void getDetails() async {
    // await ListApis.foodDetailsApi(itemId: widget.foodItemId).then((data) {
    //   if (data != null) {
    //     if (this.mounted) {
    //       setState(() {
    //         updatedFoodDetails = data;
    //         //dataLoaded = true;
    //         _chosenValue = widget.foodCategory == null
    //             ? (widget.mealtype != null ? widget.mealtype.type : null)
    //             : widget.foodCategory;
    //       });
    //     }
    //     addRecents();
    //   } else {}
    // });
    await ListApis.updatedGetFoodDetails(foodID: widget.foodItemId).then((value) {
      if (value != null) {
        if (this.mounted) {
          setState(() {
            updatedFoodDetails = value;
            dataLoaded = true;
            _chosenValue = widget.foodCategory == null
                ? (widget.mealtype != null ? widget.mealtype.type : null)
                : widget.foodCategory;
          });
        }
        addRecents();
      }
    });
    foodUnit = await ListApis.getFoodUnit(updatedFoodDetails.item);
    if (foodUnit.length == 1) {
      unitDropDown = foodUnit[0].servingUnitSize;
    }
    quantity = double.parse(updatedFoodDetails.quantity);
    unitQunatity = double.parse(updatedFoodDetails.quantity);
    perQunatity = double.parse(updatedFoodDetails.quantity);
    //print(foodUnit);
  }

  void addRecents() async {
    await SpUtil.getInstance();
    List<FoodListTileModel> recentList = SpUtil.getRecentObjectList('recent_food') ?? [];
    bool exists = recentList.any((fav) => fav.foodItemID == updatedFoodDetails.foodId);
    if (!exists) {
      recentList.add(FoodListTileModel(
        foodItemID: updatedFoodDetails.foodId,
        title: updatedFoodDetails.dish,
        subtitle:
            "${updatedFoodDetails.quantity ?? 1} ${camelize(updatedFoodDetails.servingUnitSize ?? 'Nos.')} | ${updatedFoodDetails.calories ?? 0} Cal",
        // subtitle: "${foodDetail.servingSize['serving_qty'] ?? 1} ${camelize(foodDetail.servingSize['serving_unit'])} | ${foodDetail.calories??0} kCal",
      ));
    }
    //SpUtil.putReactiveRecentObjectList(recentList);
    SpUtil.putRecentObjectList('recent_food', recentList);
  }

  void checkbookmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList("bookmarked_food");
    if (bookmarks != null) {
      if (this.mounted) {
        setState(() {
          bookmarked = bookmarks.contains(widget.foodItemId);
        });
      }
    }
  }

  void bookmarkFood() async {
    if (!bookmarked) {
      Get.snackbar('Bookmarked!', '${camelize(updatedFoodDetails.dish)} bookmarked successfully.',
          icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Icon(bookmarked ? Icons.favorite : Icons.favorite_border, color: Colors.white)),
          margin: EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: AppColors.primaryAccentColor,
          colorText: Colors.white,
          duration: Duration(seconds: 6),
          snackPosition: SnackPosition.BOTTOM);
      await LogApis.bookmarkFoodApi(foodItemID: widget.foodItemId).then((data) async {
        if (data != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> bookmarks = prefs.getStringList("bookmarked_food") ?? [];
          if (!bookmarks.contains(widget.foodItemId)) {
            bookmarks.add(widget.foodItemId);
            prefs.setStringList("bookmarked_food", bookmarks);
          }
          if (this.mounted) {
            setState(() {
              bookmarked = true;
            });
          }
        } else {
          Get.snackbar('Bookmark error!', 'Try Later',
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
    } else {
      Get.snackbar(
          'Bookmark Removed!', '${camelize(updatedFoodDetails.dish)} removed from your bookmarks.',
          icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Icon(bookmarked ? Icons.favorite : Icons.favorite_border, color: Colors.white)),
          margin: EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: AppColors.primaryAccentColor,
          colorText: Colors.white,
          duration: Duration(seconds: 6),
          snackPosition: SnackPosition.BOTTOM);
      await LogApis.deleteBookmarkFoodApi(foodItemID: widget.foodItemId).then((data) async {
        if (data != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> bookmarks = prefs.getStringList("bookmarked_food") ?? [];
          if (bookmarks.contains(widget.foodItemId)) {
            bookmarks.remove(widget.foodItemId);
            prefs.setStringList("bookmarked_food", bookmarks);
          }
          if (this.mounted) {
            setState(() {
              bookmarked = false;
            });
          }
        } else {
          Get.snackbar('Bookmark not removed!', 'Try Later',
              icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.favorite, color: Colors.white)),
              margin: EdgeInsets.all(20).copyWith(bottom: 40),
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
          bookmarked = true;
        }
      });
    }
  }

  Widget noData() {
    return DietJournalUI(
      topColor: widget.foodCategory == null
          ? (widget.mealtype != null
              ? HexColor(widget.mealtype.startColor)
              : AppColors.primaryAccentColor)
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

  Widget foodInfo(String titleTxt, String subTxt) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    titleTxt,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.5,
                      color: AppColors.textitemTitleColor,
                    ),
                  ),
                ),
                Text(
                  camelize(subTxt ?? '') + '  ',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 0.5,
                    color: Colors.grey,
                  ),
                ),
                DropdownButton<String>(
                  focusColor: Colors.white,
                  value: _chosenValue,
                  //elevation: 5,
                  style: TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.black,
                  items: <String>['Serving', 'Cup', 'Katori', 'Nos.']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  hint: Text(
                    "Quantity",
                    style:
                        TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  onChanged: (String value) {
                    if (this.mounted) {
                      setState(() {
                        _chosenValue = value;
                      });
                    }
                  },
                ),
                Text(
                  ' | ${updatedFoodDetails.calories}cal',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: <Widget>[
                Container(
                  width: 60,
                  height: 43,
                  child: TextField(
                      controller: quantityTextController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: InputDecoration(
                        counterText: "",
                        disabledBorder:
                            UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                        contentPadding: EdgeInsets.only(left: 24),
                      ),
                      style: TextStyle(height: 2.0, color: Colors.black)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    focusColor: Colors.white,
                    value: _chosenValue,
                    isExpanded: true,
                    //elevation: 5,
                    style: TextStyle(color: Colors.white),
                    iconEnabledColor: Colors.black,
                    items: <String>['Serving', 'Cup', 'Katori', 'Nos.']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    hint: Text(
                      "Quantity",
                      style:
                          TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    onChanged: (String value) {
                      if (this.mounted) {
                        setState(() {
                          _chosenValue = value;
                        });
                      }
                    },
                  ),
                ),
              ],
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
      child: Center(
        child: Text(
          '${updatedFoodDetails.quantity ?? 1} ${camelize(updatedFoodDetails.servingUnitSize ?? 'Nos.')}    |   ${updatedFoodDetails.calories ?? 0}Cal',
          // "${foodDetail.servingSize['serving_qty'] ?? 1} ${camelize(foodDetail.servingSize['serving_unit'])} | ${foodDetail.calories??0} kCal",
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
    );
  }

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
          backgroundColor: widget.foodCategory == null
              ? (widget.mealtype != null
                  ? HexColor(widget.mealtype.startColor)
                  : AppColors.primaryAccentColor)
              : widget.screenColor,
          elevation: 6.0,
          shadowColor: Colors.grey[60],
        );
      }),
    );
  }

  num calculateCalories(String defaultCalories, String quantity, String quantityUnit) {
    String unitCalories = defaultCalories;
    print(countAdd);
    if (quantity != null) {
      if (quantityUnit == null) {
        return (double.parse(defaultCalories) * countAdd);
      } else {
        foodUnit.forEach((element) {
          if (element.servingUnitSize == quantityUnit) {
            unitCalories = element.calories;
            // unitQunatity = double.parse(element.quantity);
            // perQunatity = double.parse(element.quantity);
          }
        });
        print(unitCalories);
        print(double.parse(unitCalories) * countAdd);
        return (double.parse(unitCalories) * countAdd);
      }
    } else {
      return double.parse(unitCalories);
    }
  }

  num calculateCarbs(String fiber, String sugar) {
    return (double.parse(fiber) + double.parse(sugar));
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
                topColor: widget.foodCategory == null
                    ? (widget.mealtype != null
                        ? HexColor(widget.mealtype.startColor)
                        : AppColors.primaryAccentColor)
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
                    camelize(updatedFoodDetails.dish) ?? '',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.white),
                    // style:
                    //     TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: Icon(
                          bookmarked ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          bookmarkFood();
                        },
                      ),
                    )
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: ScUtil().setHeight(30.0),
                      ),
                      Container(
                          height: ScUtil().setHeight(200),
                          width: 55.w,
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
                      SizedBox(height: ScUtil().setHeight(20)),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: foodCard(updatedFoodDetails.dish, updatedFoodDetails.quantity),
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
                                  //height: ScUtil.screenHeight / 2,
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
                                  // child: ListView.builder(
                                  //     itemCount: updatedFoodDetails.,
                                  //     itemBuilder: (BuildContext context, int index) {
                                  //       return ListTile(
                                  //           trailing: Text(
                                  //             foodDetail.foodDetails.values
                                  //                 .elementAt(index)
                                  //                 .toString()
                                  //                 .capitalizeFirst,
                                  //             style: TextStyle(
                                  //                 color: Colors.green,
                                  //                 fontSize: ScUtil().setSp(15)),
                                  //           ),
                                  //           title: Text(foodDetail.foodDetails.keys
                                  //               .elementAt(index)
                                  //               .toString()
                                  //               .replaceAll("_", " ")
                                  //               .capitalize));
                                  //     }),
                                  child: Column(children: [
                                    Visibility(
                                      visible: updatedFoodDetails.calories != '0' &&
                                          updatedFoodDetails.calories != '0.0' &&
                                          updatedFoodDetails.calories != null,
                                      child: nutrionList("Calories", updatedFoodDetails.calories),
                                    ),
                                    Visibility(
                                        visible: updatedFoodDetails.carbs != '0' &&
                                            updatedFoodDetails.carbs != '0.0' &&
                                            updatedFoodDetails.carbs != null,
                                        child:
                                            nutrionList("Carbohydrates", updatedFoodDetails.carbs)),
                                    Visibility(
                                        visible: updatedFoodDetails.fats != '0' &&
                                            updatedFoodDetails.fats != '0.0' &&
                                            updatedFoodDetails.fats != null,
                                        child: nutrionList("Fats", updatedFoodDetails.fats)),
                                    Visibility(
                                        visible: updatedFoodDetails.fiber != '0' &&
                                            updatedFoodDetails.fiber != '0.0' &&
                                            updatedFoodDetails.fiber != null,
                                        child: nutrionList("Fiber", updatedFoodDetails.fiber)),
                                    Visibility(
                                        visible: updatedFoodDetails.protein != '0' &&
                                            updatedFoodDetails.protein != '0.0' &&
                                            updatedFoodDetails.protein != null,
                                        child: nutrionList("Protein", updatedFoodDetails.protein)),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /*Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: CardColors.bgColor,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Text(
                                                foodDetail.calories,
                                                style: TextStyle(
                                                  color: widget.mealtype!=null?HexColor(widget.mealtype.startColor):AppColors.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
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
                                                foodDetail.totalFat + 'g',
                                                style: TextStyle(
                                                  color: Color(0xFF23233C),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
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
                                              Text(
                                                foodDetail.totalCarbohydrate +
                                                    'g',
                                                style: TextStyle(
                                                  color: Color(0xFF23233C),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
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
                                                foodDetail.protiens + 'g',
                                                style: TextStyle(
                                                  color: Color(0xFF23233C),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
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
                                  calculateCarbs(foodDetail.fiber,
                                              foodDetail.sugar)
                                          .toStringAsFixed(2) +
                                      'g'),
                              SizedBox(height: 8),
                              nutriSubInfo('Fiber', foodDetail.fiber + 'g'),
                              SizedBox(height: 8),
                              nutriSubInfo('Sugars', foodDetail.sugar + 'g'),
                              SizedBox(height: 12),
                              nutriInfo(
                                  'Fat',
                                  calculateFats(
                                              foodDetail.saturatedFat,
                                              foodDetail.monounsaturatedFats,
                                              foodDetail.polyunsaturatedFats)
                                          .toStringAsFixed(2) +
                                      'g'),
                              SizedBox(height: 8),
                              nutriSubInfo('Saturated Fat',
                                  foodDetail.saturatedFat + 'g'),
                              SizedBox(height: 8),
                              nutriSubInfo('Mono Unsaturated Fat',
                                  foodDetail.monounsaturatedFats + 'g'),
                              SizedBox(height: 8),
                              nutriSubInfo('Poly Unsaturated Fat',
                                  foodDetail.polyunsaturatedFats + 'g'),
                              SizedBox(height: 8),
                              nutriSubInfo('Transfatty Acid',
                                  foodDetail.transfattyAcid + 'mg'),
                              SizedBox(height: 12),
                              nutriInfo(
                                  'Others',
                                  calculateOthers(
                                              foodDetail.colesterol,
                                              foodDetail.sodium,
                                              foodDetail.calcium,
                                              foodDetail.potassium)
                                          .toStringAsFixed(2) +
                                      'g'),
                              SizedBox(height: 8),
                              nutriSubInfo(
                                  'Cholesterol', foodDetail.colesterol + 'mg'),
                              SizedBox(height: 8),
                              nutriSubInfo('Sodium', foodDetail.sodium + 'mg'),
                              SizedBox(height: 8),
                              nutriSubInfo(
                                  'Potassium', foodDetail.potassium + 'mg'),
                              SizedBox(height: 8),
                              nutriSubInfo('Calcium', foodDetail.calcium + '%'),
                              SizedBox(height: 8),
                              nutriSubInfo('Iron', foodDetail.iorn + '%'),
                              SizedBox(height: 8),
                              nutriSubInfo(
                                  'Vitamin A', foodDetail.vitaminA + '%'),
                              SizedBox(height: 8),
                              nutriSubInfo(
                                  'Vitamin C', foodDetail.vitaminC + '%'),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),*/
                      SizedBox(height: ScUtil().setHeight(40)),
                    ],
                  ),
                ),
                fab: Visibility(
                  visible: widget.viewOnly == null,
                  child: FloatingActionButton.extended(
                      onPressed: () async {
                        // logMeal(context);
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
                      backgroundColor: widget.foodCategory == null
                          ? (widget.mealtype != null
                              ? HexColor(widget.mealtype.startColor)
                              : AppColors.primaryAccentColor)
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
    double fixedQuantity = double.parse(updatedFoodDetails.quantity);
    bool submitted = false;
    var defaultFormatedDate = DateFormat('dd.MM.yyyy').format(_selectedDate);
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    String defaultFormattedTime = localizations.formatTimeOfDay(selectedTime);
    // String unitDropDown;

    print(futreTimeCheck);
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 75.w,
                        child: AutoSizeText(
                          'Log ${camelize(updatedFoodDetails.dish)}',
                          style: TextStyle(
                            color: AppColors.appTextColor, //AppColors.primaryColor
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
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
                              color: widget.foodCategory == null
                                  ? (widget.mealtype != null
                                      ? HexColor(widget.mealtype.startColor)
                                      : AppColors.primaryColor)
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
                        mystate(() {
                          _chosenValue = value;
                        });
                      },
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 120.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              calculateCalories(updatedFoodDetails.calories ?? '0',
                                      unitQunatity.toString(), unitDropDown)
                                  .toStringAsFixed(0),
                              style: TextStyle(
                                color: widget.foodCategory == null
                                    ? (widget.mealtype != null
                                        ? HexColor(widget.mealtype.startColor)
                                        : AppColors.primaryColor)
                                    : widget.screenColor,
                                fontSize: ScUtil().setSp(32),
                              ),
                            ),
                            Text(
                              "Cal",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: ScUtil().setSp(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(
                      //   width: ScUtil().setWidth(90),
                      // ),
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
                                  color: widget.foodCategory == null
                                      ? HexColor(widget.mealtype.startColor)
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
                                  color: widget.foodCategory == null
                                      ? HexColor(widget.mealtype.startColor)
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
                          ],
                        ),
                      ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SizedBox(
                      width: 180,
                      child: Container(
                        //color: Colors.black,
                        child: CustomSlideButton(
                          backGroundColor: Colors.black12.withOpacity(0.2),
                          initialValue: unitDropDown != null ? perQunatity : 0.0,
                          speedTransitionLimitCount: 3,
                          firstIncrementDuration: Duration(milliseconds: 300),
                          secondIncrementDuration: Duration(milliseconds: 100),
                          direction: Axis.horizontal,
                          dragButtonColor: widget.foodCategory == null
                              ? (widget.mealtype != null
                                  ? HexColor(widget.mealtype.startColor)
                                  : AppColors.primaryColor)
                              : widget.screenColor,
                          withSpring: true,
                          maxValue: perQunatity < 9 ? 20 : 200,
                          minValue: perQunatity,
                          withBackground: true,
                          withPlusMinus: true,
                          iconsColor: widget.foodCategory == null
                              ? (widget.mealtype != null
                                  ? HexColor(widget.mealtype.startColor)
                                  : AppColors.primaryColor)
                              : widget.screenColor,

                          //withFastCount: true,
                          stepperValue: unitDropDown != null ? unitQunatity : 0.0,
                          onChanged: (double val) {
                            unitDropDown != null
                                ? mystate(() {
                                    unitQunatity = val;
                                    quantity = unitQunatity;
                                  })
                                : mystate(() {
                                    serveCheck = false;
                                  });
                          },
                          onCountChange: (double val) {
                            unitDropDown != null
                                ? mystate(() {
                                    countAdd = val;
                                  })
                                : mystate(() {
                                    serveCheck = false;
                                  });

                            ;
                          },
                          editMeal: false,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: foodUnit.length > 1,
                            child: Row(
                              children: [
                                Text(
                                  "Serving Type",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: widget.foodCategory == null
                                        ? HexColor(widget.mealtype.startColor)
                                        : widget.screenColor,
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                    onTap: () {
                                      log("info selected");
                                      Get.to(InfoQuantityScreen(
                                        appBarColor: widget.foodCategory == null
                                            ? (widget.mealtype != null
                                                ? HexColor(widget.mealtype.startColor)
                                                : AppColors.primaryAccentColor)
                                            : widget.screenColor,
                                      ));
                                    },
                                    child: Icon(
                                      Icons.info_outline,
                                      color: HexColor(widget.mealtype.startColor),
                                    ))
                              ],
                            ),
                          ),
                          foodUnit.length > 1
                              ? DropdownButton<String>(
                                  focusColor: Colors.white,
                                  value: unitDropDown,
                                  isExpanded: true,
                                  underline: Container(
                                    height: 2.0,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: serveCheck ? Colors.grey : Colors.red,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.black),
                                  iconEnabledColor: Colors.black,
                                  items: foodUnit
                                      .map(
                                        (map) => DropdownMenuItem(
                                          child: Text(map.servingUnitSize),
                                          value: map.servingUnitSize,
                                        ),
                                      )
                                      .toList(),
                                  hint:
                                      // serveCheck
                                      //                           ?
                                      Text(
                                    "Select Unit",
                                    style: TextStyle(
                                        color: serveCheck ? Colors.blueGrey : Colors.red,
                                        fontSize: ScUtil().setSp(16),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  // : Text(
                                  //     "Select Unit",
                                  //     style: TextStyle(
                                  //         color: Colors.red,
                                  //         fontSize: ScUtil().setSp(16),
                                  //         fontWeight: FontWeight.w600),
                                  //   ),
                                  onChanged: (String value) {
                                    mystate(() {
                                      unitDropDown = value;
                                      serveCheck = true;
                                      foodUnit.forEach((element) {
                                        if (unitDropDown == element.servingUnitSize) {
                                          unitQunatity = double.parse(element.quantity);
                                          perQunatity = double.parse(element.quantity);
                                          countAdd = 1;
                                        }
                                      });
                                    });
                                  },
                                )
                              : Text(
                                  camelize(updatedFoodDetails.servingUnitSize ?? "Nos."),
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                  // maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: ScUtil().setSp(17),
                                  ),
                                ),
                          Visibility(
                              visible: !serveCheck,
                              child: Text(
                                "Please Select",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ))
                        ],
                      ),
                    )
                    // Flexible(
                    //   child: Text(
                    //     camelize(foodDetail.quantityUnit ?? 'Nos.'),
                    //     softWrap: true,
                    //     overflow: TextOverflow.fade,
                    //     // maxLines: 2,
                    //     style: TextStyle(
                    //       color: Colors.grey,
                    //       fontSize: ScUtil().setSp(24),
                    //     ),
                    //   ),
                    // ),
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
                              primary: widget.foodCategory == null
                                  ? (widget.mealtype != null
                                      ? HexColor(widget.mealtype.startColor)
                                      : AppColors.primaryColor)
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
                                : unitDropDown != null
                                    ? _chosenValue != null && _selectedDate != null
                                        ? () async {
                                            mystate(() {
                                              submitted = true;
                                              if (finalDate == null) {
                                                defaultDate();
                                              }
                                              // if (finalDate == null) {
                                              //   _hour = selectedTime.hour.toString();
                                              //   _minute =
                                              //       selectedTime.minute.toString();
                                              //   _time = _hour + ':' + _minute;
                                              //   finalTime = _time.toString();
                                              //   DateTime tempDate = Intl.withLocale(
                                              //       'en',
                                              //       () => DateFormat("dd-mm-yyyy hh:mm")
                                              //           .parse(
                                              //               '$formatedDate $finalTime'));
                                              //   finalDate = tempDate;
                                              //   print(finalDate);
                                              // }
                                            });
                                            var fooddetail = FoodDetail(
                                                foodId: widget.foodItemId,
                                                foodName: updatedFoodDetails.dish,
                                                foodQuantity: unitQunatity.toString(),
                                                quantityUnit: unitDropDown);
                                            print(fooddetail);
                                            var logFood =
                                                await prepareForLog(fooddetail, unitQunatity);
                                            print(logFood);
                                            LogApis.logUserFoodIntakeApi(data: logFood)
                                                .then((value) {
                                              if (value != null) {
                                                if (this.mounted) {
                                                  setState(() {
                                                    submitted = false;
                                                  });
                                                }
                                                widget.foodCategory == null
                                                    ? ListApis.getUserTodaysFoodLogApi(_chosenValue)
                                                        .then((value) {
                                                        Get.close(3);
                                                        // Get.off(MealTypeScreen(
                                                        //   mealsListData: value,
                                                        // ));
                                                        Get.to(CaloriesStats());
                                                      })
                                                    : Get.to(CaloriesStats());
                                                Get.snackbar('Logged!',
                                                    '${camelize(updatedFoodDetails.dish)} logged successfully.',
                                                    icon: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Icon(Icons.check_circle,
                                                            color: Colors.white)),
                                                    margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                                    backgroundColor: widget.foodCategory == null
                                                        ? (widget.mealtype.startColor)
                                                        : widget.screenColor,
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
                                                    'Cannot login multiple foods in same time. Please try again',
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
                                        : null
                                    : () async {
                                        mystate(() {
                                          serveCheck = false;
                                        });
                                      },
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

  Future<LogUserFood> prepareForLog(FoodDetail fooddetail, double quantity) async {
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
            calculateCalories(updatedFoodDetails.calories, quantity.toString(), unitDropDown)
                .toStringAsFixed(0),
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
            // Get.to(ViewGoalSettingScreen());
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

      ///here condiotin will change according to the updated api data
      ///lose weight by both
      else if (goal['goal_type'] == 'lose_weight' && goal['goal_sub_type'] == 'both') {
        // var bmrRateForAlert = maxDuration(goal['activitiy_level']);
        double loseWeight = double.tryParse(currentWeight) - double.tryParse(targetWeight);
        var goalDuration = (loseWeight / noOfDays) * 7;
        tagetCalorie = ((double.parse(goalCaloriesIntake) * maxDuration(goal['activitiy_level'])) -
                (500 * goalDuration))
            .toStringAsFixed(0);
      }

      ///gain weight
      else if (goal['goal_type'] == 'gain_weight') {
        tagetCalorie = goalCaloriesIntake.toStringAsFixed(0);
      }

      ///maintain weight
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
//
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
//
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
