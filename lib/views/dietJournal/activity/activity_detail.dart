import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../new_design/presentation/controllers/healthJournalControllers/calendarController.dart';
import '../../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../../../new_design/presentation/pages/manageHealthscreens/healthJournalScreens/activityLog/activityLog1.dart';
import '../../../utils/screenutil.dart';
import '../../../utils/SpUtil.dart';
import '../../../utils/app_colors.dart';
import '../DietJournalUI.dart';
import '../apis/delete_apis.dart';
import '../apis/list_apis.dart';
import '../apis/log_apis.dart';
import '../models/user_bookmarked_activity_model.dart';
import '../stats/caloriesHiestory.dart';
import '../stats/caloriesStats.dart';
import '../../goal_settings/apis/goal_apis.dart';
import '../../goal_settings/edit_goal_screen.dart';
import '../../../widgets/goalSetting/resuable_alert_box.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../../new_design/presentation/controllers/healthJournalControllers/getTodayLogController.dart';
import '../models/get_todays_food_log_model.dart';
import '../models/log_user_activity_model.dart';

extension DateTimeExtension on DateTime {
  bool isAfterOrEqualTo(DateTime dateTime) {
    final DateTime date = this;
    if (date != null) {
      final bool isAtSameMomentAs = dateTime.isAtSameMomentAs(date);
      return isAtSameMomentAs | date.isAfter(dateTime);
    }
    return null;
  }

  bool isBeforeOrEqualTo(DateTime dateTime) {
    final DateTime date = this;
    if (date != null) {
      final bool isAtSameMomentAs = dateTime.isAtSameMomentAs(date);
      return isAtSameMomentAs | date.isBefore(dateTime);
    }
    return null;
  }

  bool isBetween(
    DateTime fromDateTime,
    DateTime toDateTime,
  ) {
    final DateTime date = this;
    if (date != null) {
      final bool isAfter = date.isAfterOrEqualTo(fromDateTime) ?? false;
      final bool isBefore = date.isBeforeOrEqualTo(toDateTime) ?? false;
      return isAfter && isBefore;
    }
    return null;
  }
}

class ActivityDetailScreen extends StatefulWidget {
  final activityObj;
  final List<dynamic> todayLogList;
  final dynamic searchData;
  String allList;
  DateTime selectedDate;

  ActivityDetailScreen(
      {Key key,
      @required this.activityObj,
      @required this.todayLogList,
      this.searchData,
      this.allList,
      @required this.selectedDate})
      : super(key: key);

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  bool bookmarked = false;
  List bookmarkedActivityList = [];
  bool submitted = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  var weight;
  String duration;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String _hour, _minute, _time;
  DateTime finalDate;
  var finalTime;
  var textDate;
  var formatedDate;
  var formattedTime;
  DateFormat dateFormate = DateFormat('dd-MM-yyyy');

  TextEditingController minutesController = TextEditingController();
  TextEditingController calorieController = TextEditingController();

  ///for checking the goals
  List goalLists = [];
  bool getGoalLoading = false;
  bool isAgree = false;
  String activityID;
  String activityName;
  String activityMetValue;
  String activityType;
  final ClendarController _calController = Get.put(ClendarController());
  @override
  void initState() {
    _selectedDate = widget.selectedDate;
    if (widget.activityObj != null) {
      activityID =
          widget.allList == '0' ? widget.activityObj["activity_id"] : widget.activityObj.activityId;
      activityName = widget.allList == '0'
          ? widget.activityObj["activity_name"]
          : widget.activityObj.activityName;
      activityMetValue = widget.allList == '0'
          ? widget.activityObj["activity_met_value"]
          : widget.activityObj.activityMetValue;
      activityType = widget.allList == '0'
          ? widget.activityObj["activity_type"]
          : widget.activityObj.activityType;
    } else {
      activityID = widget.searchData["activity_id"];
      activityName = widget.searchData["activity_name"];
      activityMetValue = widget.searchData["activity_met_value"];
      activityType = widget.searchData["activity_type"];
    }
    print(activityID);
    checkbookmark();
    addRecents();
    getWeight();
    super.initState();
  }

  void checkbookmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList("bookmarked_activity");
    if (bookmarks != null) {
      setState(() {
        bookmarked = bookmarks.contains(activityID);
      });
    }
  }

  void getWeight() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object userData = prefs.get('data');
    Map res = jsonDecode(userData);
    weight = res['User']['userInputWeightInKG'].toString();
    if (weight == '') {
      weight = prefs.get('userLatestWeight').toString();
    }
  }

  void addRecents() async {
    await SpUtil.getInstance();
    List<BookMarkedActivity> recentList =
        SpUtil.getRecentActivityObjectList('recent_activity') ?? [];
    bool exists = recentList.any((BookMarkedActivity fav) => fav.activityId == activityID);
    if (!exists) {
      if (widget.activityObj != null) {
        BookMarkedActivity data = BookMarkedActivity(
            activityId: widget.activityObj['activity_id'],
            activityMetValue: widget.activityObj['activity_met_value'],
            activityName: widget.activityObj['activity_name'],
            activityType: widget.activityObj['activity_type']);
        recentList.add(data);
      } else {
        if (widget.searchData.runtimeType != BookMarkedActivity) {
          BookMarkedActivity data = BookMarkedActivity(
              activityId: widget.searchData['activity_id'],
              activityMetValue: widget.searchData['activity_met_value'],
              activityName: widget.searchData['activity_name'],
              activityType: widget.searchData['activity_type']);
          print(data);
          recentList.add(data);
        } else {
          print(widget.searchData.runtimeType);
          recentList.add(widget.searchData);
        }
      }
    }
    //SpUtil.putReactiveRecentObjectList(recentList);
    SpUtil.putRecentActivityObjectList('recent_activity', recentList);
    _calController.updateRecentActivity();
  }

  void bookmarkActivity() async {
    if (!bookmarked) {
      Get.snackbar('Bookmarked!', '${camelize(activityName)} bookmarked successfully.',
          icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Icon(Icons.favorite, color: Colors.white)),
          margin: const EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: HexColor('#6F72CA'),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.BOTTOM);
      await LogApis.logBookMarkActivity(activiytID: activityID).then((bool data) async {
        if (data != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> bookmarks = prefs.getStringList("bookmarked_activity") ?? [];
          setState(() {
            bookmarked = true;
          });
          if (!bookmarks.contains(activityID)) {
            bookmarks.add(activityID);
            prefs.setStringList("bookmarked_activity", bookmarks);
          }
        } else {
          bookmarked = false;
          Get.snackbar('Bookmark error!', 'Try Later',
              icon: const Padding(
                  padding: EdgeInsets.all(8.0), child: Icon(Icons.favorite, color: Colors.white)),
              margin: const EdgeInsets.all(20).copyWith(bottom: 40),
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        }
      });
      _calController.updateFavActivity();
    } else {
      Get.snackbar('Bookmark Removed!', '${camelize(activityName)} removed from your bookmarks.',
          icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Icon( Icons.favorite_border, color: Colors.white)),
          margin: const EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: HexColor('#6F72CA'),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.BOTTOM);
      await DeleteApis.deleteBookMarkActivity(activityID: activityID).then((bool data) async {
        if (data != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> bookmarks = prefs.getStringList("bookmarked_activity") ?? [];
          setState(() {
            bookmarked = false;
          });
          if (bookmarks.contains(activityID)) {
            bookmarks.remove(activityID);
            prefs.setStringList("bookmarked_activity", bookmarks);
          }

        } else {
          Get.snackbar('Bookmark not removed!', 'Try Later',
              icon: const Padding(
                  padding: EdgeInsets.all(8.0), child: Icon(Icons.favorite, color: Colors.white)),
              margin: const EdgeInsets.all(20).copyWith(bottom: 40),
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
          bookmarked = true;
        }
      });
      _calController.updateFavActivity();
    }
  }

  Widget impactCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      height: ScUtil().setHeight(53),
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            camelize(activityName ?? 'Unknown Activity') ?? '',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: ScUtil().setSp(17),
              // letterSpacing: 0.5,
              color: AppColors.textitemTitleColor,
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(top:10.sp),
            child: Text(
              activityType == 'L'
                  ? 'Light Impact'
                  : activityType == 'M'
                      ? 'Medium Impact'
                      : activityType == 'V'
                          ? 'High Impact'
                          : 'Impact unknown',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w200,
                fontSize: ScUtil().setSp(12.5),
                // letterSpacing: 0.5,
                color: AppColors.textitemTitleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  num calculateCalories(String duration) {
    if (duration != null && weight != null) {
      return (double.parse(duration == '' ? '0' : duration) *
          (double.parse(activityMetValue) * 3.5 * double.parse(weight)) /
          200);
    } else {
      return double.parse('0');
    }
  }

  void defaultDate() {
    setState(() {
      _hour = selectedTime.hour.toString();
      _minute = selectedTime.minute.toString();
      DayPeriod m = selectedTime.period;
      _time = '$_hour:$_minute';
      finalTime = _time.toString();
      formatedDate = DateFormat("dd-MM-yyyy").format(_selectedDate);
      MaterialLocalizations localizations = MaterialLocalizations.of(context);
      formattedTime = localizations.formatTimeOfDay(selectedTime);
      DateTime tempDate = DateFormat("dd-MM-yyyy HH:mm").parse(formatedDate + " " + finalTime);
      print(tempDate);
      finalDate = tempDate;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime d = await showDatePicker(
        context: context,
        initialDate: widget.selectedDate,
        firstDate: DateTime(2015),
        lastDate: DateTime.now(),
        builder: (BuildContext context, Widget child) {
          return Theme(
              data: Theme.of(context)
                  .copyWith(colorScheme: const ColorScheme.light(primary: Color(0xff6F72CA))),
              child: child);
        });
    if (d != null) {
      setState(() {
        _selectedDate = d;
        formatedDate = DateFormat("dd-MM-yyyy").format(_selectedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(colorScheme: const ColorScheme.light(primary: Color(0xff6F72CA))),
                child: child,
              ));
        });
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        MaterialLocalizations localizations = MaterialLocalizations.of(context);
        formattedTime = localizations.formatTimeOfDay(selectedTime);
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        print(selectedTime.period.toString());
        _time = '$_hour:$_minute';
        finalTime = _time;
        textDate = dateFormate.parse('$_selectedDate');
        // DateTime tempDate = Intl.withLocale(
        //     'en',
        //     () => DateFormat("dd-mm-yyyy hh:mm")
        //         .parse('$_selectedDate $finalTime'));
        String formatedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);
        String concartd = "$formatedDate " + finalTime;
        DateTime tempDate = DateFormat("dd-MM-yyyy hh:mm").parse(concartd);
        print(tempDate);
        finalDate = tempDate;
        // _timeController.text = _time;
        // _timeController.text = formatDate(
        //     DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
        //     [hh, ':', nn, " ", am]).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String defaultFormatedDate = DateFormat('dd.MM.yyyy').format(_selectedDate);
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    String defaultFormattedTime = localizations.formatTimeOfDay(selectedTime);
    return CommonScreenForNavigation(
      content: DietJournalUI(
          topColor: HexColor('#6F72CA'),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: AutoSizeText(
              camelize(activityName ?? 'Unknown Activity') ?? '',
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.white),
              // style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
              maxLines: 1,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Icon(bookmarked ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white),
                  onPressed: () {
                    bookmarkActivity();
                  },
                ),
              )
            ],
          ),
          body: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);

              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              if (_formKey.currentState.validate()) {
              } else {
                if (mounted) {
                  setState(() {
                    _autoValidate = true;
                  });
                }
              }
            },
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30.0,
                    ),
                    SizedBox(
                      height: 200,
                      width: 300,

                      // decoration: BoxDecoration(
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.grey[300],
                      //       offset: Offset(0.1, 0.1),
                      //       blurRadius: 18,
                      //     )
                      //   ],
                      //   borderRadius: BorderRadius.all(Radius.circular(12)),
                      // ),a
                      child: SizedBox(
                        height: 25.h,
                        width: 80.w,
                        child: Image.asset(
                          'assets/images/diet/training-isolated.jpg',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScUtil().setHeight(10),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical:6,horizontal:12.0),
                      child: impactCard(),
                    ),
                    // SizedBox(
                    //   height: ScUtil().setHeight(5),
                    // ),
                    Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 2,
                      shadowColor: FitnessAppTheme.nearlyWhite,
                      borderOnForeground: true,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          side: BorderSide(
                            width: 1,
                            color: FitnessAppTheme.nearlyWhite,
                          )),
                      color: FitnessAppTheme.white,
                      child: Column(
                        children: [
                          //SizedBox(height: 10),
                          Center(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  calculateCalories(duration).toStringAsFixed(0),
                                  style: TextStyle(
                                    color: HexColor('#6F72CA'),
                                    fontSize: 36,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18.sp,
                                      height: 18.sp,
                                      child: Image.asset(
                                        'assets/images/diet/burntCal.png',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      "Cal burned",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical:20,horizontal: 50),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: InkWell(
                                    onTap: () {
                                      _selectDate(context);
                                    },
                                    child: Image.asset(
                                      'assets/images/diet/Icon awesome-calendar.png',
                                    ),
                                  ),
                                ),

                                // onTap: () async {
                                //   _selectDate(context);
                                // },
                                // ),

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
                                            defaultFormatedDate,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: ScUtil().setSp(12),
                                            ),
                                          )),

                                SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: InkWell(
                                      onTap: () {
                                        _selectTime(context);
                                      },
                                      child: Image.asset(
                                        'assets/images/diet/Icon ionic-ios-clock.png',
                                        fit: BoxFit.fill,
                                      ),
                                    )),

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
                                            defaultFormattedTime,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: ScUtil().setSp(12),
                                            ),
                                          )),
                              ],
                            ),
                          ),
                          //SizedBox(height: 0),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                const Text(
                                  'Workout Minutes',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                    color: AppColors.textitemTitleColor,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: TextFormField(
                                    controller: minutesController,
                                    validator: (String value) {
                                      if (value.toString().contains('.') == true) {
                                        return "Negative values won't be decimal";
                                      }

                                      if (value.isEmpty) {
                                        return 'Minutes can\'t\nbe empty!';
                                      } else if (int.parse(value) > 1440) {
                                        return "Max. 1440 mins allowed";
                                      } else if (int.parse(value) == 0) {
                                        return "Min. mins is 1min.";
                                      } else if (double.parse(value) == 0.0) {
                                        return "Min. mins is 1min.";
                                      }
                                      return null;
                                    },
                                    cursorColor: HexColor('#6F72CA'),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: 18.0, horizontal: 15.0),
                                      labelText: "Mins.",
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      suffixText: 'Mins',
                                      counterText: "",
                                      counterStyle: const TextStyle(fontSize: 0),
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                          borderSide: BorderSide(color: HexColor('#6F72CA'))),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                          borderSide: BorderSide(color: HexColor('#6F72CA'))),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    onChanged: (String val) {
                                      setState(() {
                                        duration = val;
                                      });
                                    },
                                    onFieldSubmitted: (String val) {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                    },
                                    scrollPadding: const EdgeInsets.only(bottom: 40),
                                    maxLength: 4,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                        ],
                      ),
                    ),
                     SizedBox(height:4.h ),
                    Visibility(
                      visible: MediaQuery.of(context).viewInsets.bottom == 0,
                      child: FloatingActionButton.extended(
                          onPressed: () async {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            if (_formKey.currentState.validate()) {
                              // logActivity();
                              ///call a function from here that will return true or false
                              //according to that either user log the meal or we show an pop up
                              //that will say user to edit the goal
                              // logActivity();//this line should be commented and the if else condition below should be uncommented after complete this

                              try {
                                if (mounted) {
                                  setState(() {
                                    submitted = true;
                                  });
                                }
                                await isGoalNeedToChange().then((v) async {
                                  if (v) {
                                    if (mounted) {
                                      setState(() {
                                        submitted = false;
                                      });
                                    }
                                    alertBox('Change Your Goal', Colors.black, false);
                                  } else {
                                    logActivity();
                                  }
                                });
                              } catch (e) {
                                logActivity();
                              }
                            } else {
                              if (mounted) {
                                setState(() {
                                  _autoValidate = true;
                                });
                              }
                            }
                          },
                          backgroundColor: HexColor('#6F72CA'),
                          label: Text(
                            submitted ? 'Logging' : '\Log Activity',
                            style: const TextStyle(color: FitnessAppTheme.white),
                          ),
                          icon: submitted
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : const Icon(Icons.run_circle, color: FitnessAppTheme.white)),
                    ),
                    SizedBox(height:20.h)
                  ],
                ),
              ),
            ),
          ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          // fab: IgnorePointer(
          //   ignoring: submitted,
          //   child: Visibility(
          //     visible: MediaQuery.of(context).viewInsets.bottom == 0,
          //     child: FloatingActionButton.extended(
          //         onPressed: () async {
          //           FocusScopeNode currentFocus = FocusScope.of(context);
          //           if (!currentFocus.hasPrimaryFocus) {
          //             currentFocus.unfocus();
          //           }
          //           if (_formKey.currentState.validate()) {
          //             // logActivity();
          //             ///call a function from here that will return true or false
          //             //according to that either user log the meal or we show an pop up
          //             //that will say user to edit the goal
          //             // logActivity();//this line should be commented and the if else condition below should be uncommented after complete this
          //
          //             try {
          //               if (mounted) {
          //                 setState(() {
          //                   submitted = true;
          //                 });
          //               }
          //               await isGoalNeedToChange().then((v) async {
          //                 if (v) {
          //                   if (mounted) {
          //                     setState(() {
          //                       submitted = false;
          //                     });
          //                   }
          //                   alertBox('Change Your Goal', Colors.black, false);
          //                 } else {
          //                   logActivity();
          //                 }
          //               });
          //             } catch (e) {
          //               logActivity();
          //             }
          //           } else {
          //             if (mounted) {
          //               setState(() {
          //                 _autoValidate = true;
          //               });
          //             }
          //           }
          //         },
          //         backgroundColor: HexColor('#6F72CA'),
          //         label: Text(
          //           submitted ? 'Logging' : '\Log Activity',
          //           style: const TextStyle(color: FitnessAppTheme.white),
          //         ),
          //         icon: submitted
          //             ? const CircularProgressIndicator(
          //                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //               )
          //             : const Icon(Icons.run_circle, color: FitnessAppTheme.white)),
          //   ),
          // )
      ),
    );
  }

  void logActivity() async {
    if (finalDate == null) {
      defaultDate();
    }
    setState(() {
      submitted = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    print(finalDate);
    Map<String, Object> data = {
      "user_ihl_id": iHLUserId,
      "activity_log_time": DateFormat('yyyy-MM-dd HH:mm:ss').format(finalDate),
      "calories_burned": calculateCalories(duration).toStringAsFixed(0),
      "activity_details": [
        {
          "activity_details": [
            {
              "activity_id": activityID,
              "activity_name": activityName,
              "activity_duration": duration
            },
          ]
        }
      ]
    };
    if (widget.todayLogList.isNotEmpty) {
      bool _logAllow = false;
      for (Activity element in widget.todayLogList) {
        DateTime lastLogStartTime = DateFormat('dd-MM-yyyy HH:mm:ss').parse(element.logTime);
        DateTime lastLogEndTime = lastLogStartTime.add(Duration(
            minutes: int.parse(
          element.activityDetails[0].activityDetails[0].activityDuration,
        )));
        if (finalDate.isBetween(lastLogStartTime, lastLogEndTime)) _logAllow = true;
        print(_logAllow);

        // _logAllow = finalDate.difference(_lastLoggedTime).inMinutes < int.parse(duration);
      }
      if (DateTime.now().isBefore(finalDate)) {
        if (mounted) {
          setState(() {
            submitted = false;
          });
        }
        Get.snackbar('Activity not logged!', 'Invalid log Time',
            icon: const Padding(
                padding: EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      } else if (_logAllow) {
        if (mounted) {
          setState(() {
            submitted = false;
          });
        }
        Get.snackbar('Activity not logged!', 'Invalid log Time',
            icon: const Padding(
                padding: EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        LogApis.logUserActivityApi(data: data).then((LogUserActivity value) {
          print(value);
          if (value != null) {
            if (mounted) {
              setState(() {
                submitted = false;
              });
            }
            ListApis listApis = ListApis();
            listApis.getUserTodaysFoodLogHistoryApi().then((value) {
              Get.close(2);
              // Get.off(
              // // TodayActivityScreen(
              // //   todaysActivityData: value['activity'],
              // //   otherActivityData: value['previous_activity'],
              // ));
              tabControllerindex = 1;
              if (DateFormat("yyyy-MM-dd").format(
                      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)) ==
                  DateFormat("yyyy-MM-dd").format(
                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
                _calController.updateDate(Date: "Today", focusedDate: _selectedDate);
              } else {
                _calController.updateDate(
                    Date: DateFormat("dd MMM").format(_selectedDate), focusedDate: _selectedDate);
              }
              String endDate =
                  "${DateFormat("yyyy-MM-dd").format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day))} 23:59:00";
              String startDate = DateFormat("yyyy-MM-dd")
                  .format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day));
              _calController.updateActivityDetails(startDate, endDate);
              // Get.delete<TodayLogController>();
              Get.find<TodayLogController>().onInit();
              Get.to(ActivityLandingScreen());
            });

            Get.snackbar('Logged!', '${camelize(activityName)} logged successfully.',
                icon: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.check_circle, color: Colors.white)),
                margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                backgroundColor: HexColor('#6F72CA'),
                colorText: Colors.white,
                duration: const Duration(seconds: 5),
                snackPosition: SnackPosition.BOTTOM);
          } else {
            setState(() {
              submitted = false;
            });
            Get.snackbar(
                'Activity not logged!', 'Encountered some error while logging. Please try again',
                icon: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.check_circle, color: Colors.white)),
                margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
                duration: const Duration(seconds: 5),
                snackPosition: SnackPosition.BOTTOM);
          }
        });
      }
    } else if (DateTime.now().isBefore(finalDate)) {
      if (mounted) {
        setState(() {
          submitted = false;
        });
      }
      Get.snackbar('Activity not logged!', 'Future Activity not Allowed',
          icon: const Padding(
              padding: EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.white)),
          margin: const EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM);
    } else {
      LogApis.logUserActivityApi(data: data).then((LogUserActivity value) {
        if (value != null) {
          setState(() {
            submitted = false;
          });
          ListApis listApis = ListApis();
          listApis.getUserTodaysFoodLogHistoryApi().then((value) {
            Get.close(2);
            // Get.off(
            // // TodayActivityScreen(
            // //   todaysActivityData: value['activity'],
            // //   otherActivityData: value['previous_activity'],
            // ));
            tabControllerindex = 1;

            if (DateFormat("yyyy-MM-dd")
                    .format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)) ==
                DateFormat("yyyy-MM-dd").format(
                    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
              _calController.updateDate(Date: "Today", focusedDate: _selectedDate);
            } else {
              _calController.updateDate(
                  Date: DateFormat("dd MMM").format(_selectedDate), focusedDate: _selectedDate);
            }
            String endDate =
                "${DateFormat("yyyy-MM-dd").format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day))} 23:59:00";
            String startDate = DateFormat("yyyy-MM-dd")
                .format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day));
            _calController.updateActivityDetails(startDate, endDate);
            // Get.delete<TodayLogController>();
            Get.find<TodayLogController>().onInit();
            Get.to(ActivityLandingScreen());
          });
          Get.snackbar('Logged!', '${camelize(activityName)} logged successfully.',
              icon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.check_circle, color: Colors.white)),
              margin: const EdgeInsets.all(20).copyWith(bottom: 40),
              backgroundColor: HexColor('#6F72CA'),
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
              snackPosition: SnackPosition.BOTTOM);
        } else {
          setState(() {
            submitted = false;
          });
          Get.snackbar(
              'Activity not logged!', 'Encountered some error while logging. Please try again',
              icon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.check_circle, color: Colors.white)),
              margin: const EdgeInsets.all(20).copyWith(bottom: 40),
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
              snackPosition: SnackPosition.BOTTOM);
        }
      });
    }
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
                  builder: (BuildContext context) => const ViewGoalSettingScreen(
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
    bool needChange;

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
    List goalList1 = [];
    await GoalApis.listGoal().then((List value) async {
      if (value != null) {
        List<dynamic> activeGoalLists = [];
        for (int i = 0; i < value.length; i++) {
          if (value[i]['goal_status'] == 'active') {
            activeGoalLists.add(value[i]);
          }
        }
        setState(() {
          goalLists = activeGoalLists;
          getGoalLoading = true;
          goalList1 = goalLists;
        });
        return goalList1;
      } else {
        return [];
      }
    });
    return goalList1;
  }

  isGoalImpossible(value) async {
    bool impos;
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
    String height = prefs.get('userLatestHeight').toString();
    String currentWeight = await prefs.get('userLatestWeight').toString();

    ///conditon for knowing the type of goal
    await getGoalCalorieIntake(goal['target_weight']).then((goalCaloriesIntake) async {
      if (goal['goal_date'] == null || goal['goal_date'] == "") {
        return goalCaloriesIntake;
      }
      DateTime today = DateTime.now();
      // DateTime achieveBy = today.add(Duration(days: noOfDays));
      // var noD = goal['goal_date'].diffrence(today).inDays;
      DateTime previousAchivedDate = DateFormat('MMMM d, yyyy', 'en_US').parse(goal['goal_date']);
      int noOfDays = previousAchivedDate.difference(today).inDays;
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
        double bmrRateForAlert = maxDuration(goal['activitiy_level']);
        tagetCalorie = ((int.tryParse(goalCaloriesIntake)) * (bmrRateForAlert)).toStringAsFixed(0);
      }

      ///lose weight by both
      else if (goal['goal_type'] == 'lose_weight' && goal['goal_sub_type'] == 'both') {
        // var bmrRateForAlert = maxDuration(goal['activitiy_level']);
        double loseWeight = double.tryParse(currentWeight) - double.tryParse(targetWeight);
        double goalDuration = (loseWeight / noOfDays) * 7;
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
    Object userData = prefs.get('data');
    Map res = jsonDecode(userData);
    String height;
    String goalCaloriesIntake;
    String datePattern = "MM/dd/yyyy";
    String dob = res['User']['dateOfBirth'].toString();
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
      setState(() {
        goalCaloriesIntake = maleBmr.toStringAsFixed(0);
        // return goalCaloriesIntake;
      });
    } else {
      setState(() {
        goalCaloriesIntake = femaleBmr.toStringAsFixed(0);
        // return goalCaloriesIntake;
      });
    }
    return goalCaloriesIntake;
  }

  targetCalorieForLoseByDiet({currentWeight, targetWeight, noOfDays, goalCaloriesIntake}) {
    double loseWeight = double.tryParse(currentWeight) - double.tryParse(targetWeight);
    //here noOfDays we get by creting the diffrence from goal_date & todays date
    ///int noOfDays = ((loseWeight ~/ goalDuration) * 3.5).toInt();
    ///goalDuration we get from above formula by manipulating it
    double goalDuration = ((loseWeight / noOfDays) * 3.5);
    String tagetCalorie =
        (double.parse(goalCaloriesIntake) - (500 * goalDuration)).toStringAsFixed(0);
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
