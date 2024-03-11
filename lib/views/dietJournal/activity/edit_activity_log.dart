import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:loading_skeleton/loading_skeleton.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:strings/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:ihl/views/dietJournal/apis/log_apis.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/apis/delete_apis.dart';
import 'package:ihl/views/dietJournal/activity/today_activity.dart';
import 'package:ihl/views/dietJournal/models/user_bookmarked_activity_model.dart';

import '../../../new_design/presentation/controllers/healthJournalControllers/calendarController.dart';
import '../../../new_design/presentation/controllers/healthJournalControllers/getTodayLogController.dart';
import '../../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../models/log_user_activity_model.dart';

class EditActivityLogScreen extends StatefulWidget {
  final String activityId;
  final String duration;
  final String logTime;
  final bool today;
  final String logId;
  const EditActivityLogScreen(
      {Key key, this.activityId, this.duration, this.logTime, this.today, this.logId})
      : super(key: key);
  @override
  _EditActivityLogScreenState createState() => _EditActivityLogScreenState();
}

class _EditActivityLogScreenState extends State<EditActivityLogScreen> {
  bool bookmarked = false;
  List bookmarkedActivityList = [];
  bool submitted = false;
  bool deleted = false;
  BookMarkedActivity activityObj;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String weight;
  String duration;
  List<BookMarkedActivity> allActivitylist = [];
  bool loaded = false;
  bool empty = false;
  final ClendarController _calController = Get.put(ClendarController());
  TextEditingController minutesController = TextEditingController();
  TextEditingController calorieController = TextEditingController();

  @override
  void initState() {
    getAllActivityList();
    checkbookmark();
    getWeight();
    super.initState();
  }

  void getAllActivityList() async {
    List<BookMarkedActivity> details = await ListApis.getActivityList();

    for (int i = 0; i < details.length; i++) {
      if (widget.activityId == details[i].activityId) {
        setState(() {
          activityObj = details[i];
          duration = minutesController.text = widget.duration;
          loaded = true;
        });
      } else {}
    }
  }

  void checkbookmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList("bookmarked_activity");
    if (bookmarks != null) {
      bookmarked = bookmarks.contains(widget.activityId);
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

  void bookmarkActivity() async {
    if (!bookmarked) {
      Get.snackbar('Bookmarked!', '${camelize(activityObj.activityName)} bookmarked successfully.',
          icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Icon(bookmarked ? Icons.favorite : Icons.favorite_border, color: Colors.white)),
          margin: const EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: HexColor('#6F72CA'),
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
          snackPosition: SnackPosition.BOTTOM);
      await LogApis.logBookMarkActivity(activiytID: widget.activityId).then((bool data) async {
        if (data != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> bookmarks = prefs.getStringList("bookmarked_activity") ?? [];
          if (!bookmarks.contains(widget.activityId)) {
            bookmarks.add(widget.activityId);
            prefs.setStringList("bookmarked_activity", bookmarks);
          }
          setState(() {
            bookmarked = true;
          });
        } else {
          Get.snackbar('Bookmark error!', 'Try Later',
              icon: const Padding(
                  padding: EdgeInsets.all(8.0), child: Icon(Icons.favorite, color: Colors.white)),
              margin: const EdgeInsets.all(20).copyWith(bottom: 40),
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
          bookmarked = false;
        }
      });
      _calController.updateFavActivity();
    } else {
      Get.snackbar(
          'Bookmark Removed!', '${camelize(activityObj.activityName)} removed from your bookmarks.',
          icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Icon(bookmarked ? Icons.favorite : Icons.favorite_border, color: Colors.white)),
          margin: const EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: HexColor('#6F72CA'),
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
          snackPosition: SnackPosition.BOTTOM);
      await DeleteApis.deleteBookMarkActivity(activityID: widget.activityId)
          .then((bool data) async {
        if (data != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> bookmarks = prefs.getStringList("bookmarked_activity") ?? [];
          if (bookmarks.contains(widget.activityId)) {
            bookmarks.remove(widget.activityId);
            prefs.setStringList("bookmarked_activity", bookmarks);
          }
          setState(() {
            bookmarked = false;
          });
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
    DateTime tempDate = DateFormat("dd-MM-yyyy HH:mm:ss").parse(widget.logTime);

    var formatedDate = DateFormat('dd-MM-yyyy').format(tempDate);
    var formatedTime = DateFormat('hh:mm a').format(tempDate);

    // MaterialLocalizations localizations = MaterialLocalizations.of(context);
    // var formattedTime = localizations.formatTimeOfDay(_startTime);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
      height: ScUtil().setHeight(80),
      width: double.maxFinite,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 42.w,
                child: AutoSizeText(
                  camelize(activityObj.activityName ?? 'Unknown Activity') ?? '',
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  maxLines: 2,
                ),
              ),
              SizedBox(
                width: 20.w,
              ),
              Text(
                formatedDate,
                maxLines: 2,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                activityObj.activityType == 'L'
                    ? 'Light Impact'
                    : activityObj.activityType == 'M'
                        ? 'Medium Impact'
                        : activityObj.activityType == 'V'
                            ? 'High Impact'
                            : 'Impact unknown',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                  color: AppColors.textitemTitleColor.withOpacity(0.8),
                ),
              ),
              // SizedBox(
              //   width: 45.w,
              // ),
              Spacer(),
              Text(
                formatedTime,
                maxLines: 2,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  num calculateCalories(String duration) {
    if (duration != null && weight != null) {
      return (double.parse(duration == '' ? '0' : duration) *
          (double.parse(activityObj.activityMetValue) * 3.5 * double.parse(weight)) /
          200);
    } else {
      return double.parse('0');
    }
  }

  Widget noData() {
    return DietJournalUI(
      topColor: HexColor('#6F72CA'),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
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
          children: <Widget>[
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

  @override
  Widget build(BuildContext context) {
    return loaded
        ? CommonScreenForNavigation(
            content: DietJournalUI(
              topColor: HexColor('#6F72CA'),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Edit Activity Log',
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500, color: Colors.white),
                  // style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold, color: Colors.white),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        deleteActivity();
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
                    if (this.mounted) {
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
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //  SizedBox(
                        //   height: 3.h,
                        // ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.5.h),
                          child: SizedBox(
                            height: 25.h,
                            width: 80.w,
                            child: Image.asset(
                              'assets/images/diet/editactivity.jpg',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        // const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: impactCard(),
                        ),
                        Card(
                          margin: const EdgeInsets.all(8.0).copyWith(left: 20, right: 20),
                          color: CardColors.bgColor,
                          child: Column(
                            children: [
                              // const SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Text(
                                      calculateCalories(duration).toStringAsFixed(0),
                                      style: TextStyle(
                                        color: HexColor('#6F72CA'),
                                        fontSize: 22.sp,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                                          child: SizedBox(
                                            width: 18.sp,
                                            height: 18.sp,
                                            child: Image.asset(
                                              'assets/images/diet/kcal.png',
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        // const SizedBox(width: 5,),
                                        const Text(
                                          "Cal burned",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // const SizedBox(height: 40),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 2.w),
                                      child: const Text(
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
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: TextFormField(
                                        controller: minutesController,
                                        validator: (String value) {
                                          if (value.isEmpty) {
                                            return 'Minutes can\'t\nbe empty!';
                                          } else if (int.parse(value) > 1440) {
                                            return "Max. 1440 mins allowed";
                                          } else if (int.parse(value) == 0) {
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
                              // const SizedBox(height: 20),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Visibility(
                          visible: MediaQuery.of(context).viewInsets.bottom == 0,
                          child: FloatingActionButton.extended(
                              onPressed: () {
                                FocusScopeNode currentFocus = FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                if (_formKey.currentState.validate()) {
                                  logActivity();
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
                                submitted
                                    ? 'Logging'
                                    : deleted
                                        ? 'Deleting'
                                        : 'Log Activity',
                                style: const TextStyle(color: FitnessAppTheme.white),
                              ),
                              icon: submitted || deleted
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    )
                                  : const Icon(Icons.run_circle, color: FitnessAppTheme.white)),
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : noData();
  }

  void deleteActivity() async {
    setState(() {
      deleted = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    Map<String, Object> data = {
      "user_ihl_id": iHLUserId,
      "activity_log_time": DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(DateFormat('dd-MM-yyyy HH:mm:ss').parse(widget.logTime)),
      "calories_burned": '0',
      "activity_log_id": widget.logId,
      "activity_details": []
    };

    LogApis.editLogUserActivityApi(data: data).then((LogUserActivity value) {
      if (value != null) {
        setState(() {
          submitted = false;
        });
        ListApis listApis = ListApis();
        listApis.getUserTodaysFoodLogHistoryApi().then((value) {
          Get.off(TodayActivityScreen(
            todaysActivityData: value['activity'],
            otherActivityData: value['previous_activity'],
          ));
        });
        // Get.delete<TodayLogController>();
        Get.find<TodayLogController>().onInit();
        Get.snackbar('Deleted!', '${camelize(activityObj.activityName)} deleted successfully.',
            icon: const Padding(
                padding: EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: HexColor('#6F72CA'),
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        setState(() {
          deleted = false;
        });
        Get.snackbar(
            'Actvity log not deleted!', 'Encountered some error while deleted. Please try later',
            icon: const Padding(
                padding: EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  void logActivity() async {
    setState(() {
      submitted = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    Map<String, Object> data = {
      "user_ihl_id": iHLUserId,
      "activity_log_time": DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(DateFormat('dd-MM-yyyy HH:mm:ss').parse(widget.logTime)),
      "calories_burned": calculateCalories(duration).toStringAsFixed(0),
      "activity_log_id": widget.logId,
      "activity_details": [
        {
          "activity_details": [
            {
              "activity_id": activityObj.activityId,
              "activity_name": activityObj.activityName,
              "activity_duration": duration
            },
          ]
        }
      ]
    };

    LogApis.editLogUserActivityApi(data: data).then((LogUserActivity value) {
      if (value != null) {
        setState(() {
          submitted = false;
        });
        ListApis listApis = ListApis();
        listApis.getUserTodaysFoodLogHistoryApi().then((value) {
          Get.off(TodayActivityScreen(
            todaysActivityData: value['activity'],
            otherActivityData: value['previous_activity'],
          ));
        });
        // Get.delete<TodayLogController>();
        Get.find<TodayLogController>().onInit();
        Get.snackbar('Changed!', '${camelize(activityObj.activityName)} logged successfully.',
            icon: const Padding(
                padding: EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.white)),
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
            'Actvity log not changed!', 'Encountered some error while logging. Please try again',
            icon: const Padding(
                padding: EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }
}
