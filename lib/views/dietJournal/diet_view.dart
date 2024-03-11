import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/screenutil.dart';
import 'dietJournal.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../../new_design/app/utils/imageAssets.dart';
import '../../new_design/app/utils/textStyle.dart';
import '../../new_design/presentation/Widgets/healthJournalCard.dart';
import '../../new_design/presentation/controllers/healthJournalControllers/getTodayLogController.dart';

class MediterranesnDietViewNew extends StatefulWidget {
  const MediterranesnDietViewNew({Key key, this.isNavigation}) : super(key: key);
  final isNavigation;

  @override
  State<MediterranesnDietViewNew> createState() => _MediterranesnDietViewNewState();
}

class _MediterranesnDietViewNewState extends State<MediterranesnDietViewNew> {
  StreamingSharedPreferences preferences;
  int dailytarget = 0;
  @override
  void initState() {
    super.initState();
    // async();
    // WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  // void async() async {
  //   preferences = await StreamingSharedPreferences.instance;
  // }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    StreamingSharedPreferences.instance.then((StreamingSharedPreferences value) {
      if (mounted) {
        setState(() {
          preferences = value;
        });
      }
    });
    dailyTarget().then((String value) {
      if (mounted) {
        setState(() {
          dailytarget = int.parse(value);
          prefs.setInt('daily_target', dailytarget);
          prefs.setInt('weekly_target', dailytarget * 7);
          prefs.setInt('monthly_target', dailytarget * daysInMonth(DateTime.now()));
        });
      }
    });
  }

  Future<String> dailyTarget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int dailyTarget = prefs.getInt('daily_target');

    if (dailyTarget == null || dailyTarget == 0) {
      Object userData = prefs.get('data');
      preferences.setBool('maintain_weight', true);
      Map res = jsonDecode(userData);
      String height;
      DateTime birthDate;
      String datePattern = "MM/dd/yyyy";
      String dob = res['User']['dateOfBirth'].toString();
      DateTime today = DateTime.now();
      try {
        birthDate = DateFormat(datePattern).parse(dob);
      } catch (e) {
        birthDate = DateFormat('MM-dd-yyyy').parse(dob);
      }
      int age = today.year - birthDate.year;
      if (res['User']['heightMeters'] is num) {
        height = (res['User']['heightMeters'] * 100).toInt().toString();
      }
      String weight = res['User']['userInputWeightInKG'].toString() ?? '0';
      if (weight == '') {
        weight = prefs.get('userLatestWeight').toString();
      }
      var m = res['User']['gender'];
      num maleBmr =
          (10 * double.parse(weight.toString()) + 6.25 * double.parse(height) - (5 * age) + 5);
      num femaleBmr = (10 * double.parse(weight) + 6.25 * double.parse(height) - (5 * age) - 161);
      return (m == 'm' || m == 'M' || m == 'male' || m == 'Male')
          ? maleBmr.toStringAsFixed(0)
          : femaleBmr.toStringAsFixed(0);
    } else {
      bool maintainWeight = prefs.getBool('maintain_weight');
      if (maintainWeight == null) {
        preferences.setBool('maintain_weight', true);
      }
      return dailyTarget.toString();
    }
  }

  int daysInMonth(DateTime date) {
    DateTime firstDayThisMonth = DateTime(date.year, date.month, date.day);
    DateTime firstDayNextMonth =
        DateTime(firstDayThisMonth.year, firstDayThisMonth.month + 1, firstDayThisMonth.day);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        allowFontScaling: true);
    return GetBuilder<TodayLogController>(
        id: "Today Food",
        init: TodayLogController(),
        builder: (TodayLogController todayLog) {
          return GestureDetector(
              onTap: () {
                //Get.to(ViewGoalSettingScreen());
                if (widget.isNavigation) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (BuildContext context) => DietJournal()),
                      (Route<dynamic> route) => false);
                }
              },
              child: Container(
                child: Card(
                  elevation: 3,
                  child: Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.035),
                      Image.asset(
                        'newAssets/runner.png',
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.26,
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          // preferences != null
                          //     ? PreferenceBuilder<int>(
                          //     preference: preferences.getInt('burnedCalorie', defaultValue: 0),
                          //     builder: (BuildContext context, int burnedCounter) {
                          //       return PreferenceBuilder<int>(
                          //           preference:
                          //           preferences.getInt('eatenCalorie', defaultValue: 0),
                          //           builder: (BuildContext context, int eatenCounter) {
                          //             return SizedBox(
                          //               height: 28.w,
                          //               width: 28.w,
                          //               child: PercentageCircularProgressIndicator(
                          //                 backgroundColor: AppColors.calNeed3,
                          //                 // bottomLayerColor: Colors.blue.shade200,
                          //                 // progressColor: (((dailytarget - eatenCounter) +
                          //                 //     burnedCounter) >
                          //                 //     dailytarget)
                          //                 //     ? Colors.orangeAccent
                          //                 //     : ((dailytarget - eatenCounter) + burnedCounter) >
                          //                 //     0
                          //                 //     ? AppColors.calNeed
                          //                 //     : AppColors.calExtra,
                          //                 progressColor: [AppColors.calExtra, AppColors.calExtraOpc],
                          //                 percentage:
                          //                 (((dailytarget - eatenCounter) + burnedCounter) <
                          //                     0)?100
                          //                     // ? (100) *
                          //                     // ((dailytarget -
                          //                     //     eatenCounter -
                          //                     //     burnedCounter) /
                          //                     //     eatenCounter)
                          //                     : (100) *
                          //                     ((eatenCounter - burnedCounter) /
                          //                         dailytarget),
                          //                 strokeWidth: 10,
                          //                 centerWidget: burnedCounter != 0 && eatenCounter != 0
                          //                     ? Column(
                          //                   mainAxisAlignment: MainAxisAlignment.center,
                          //                   children: [
                          //                     Text(
                          //                       '${todayLog.caloriesNeed}',
                          //                       textAlign: TextAlign.center,
                          //                       style: TextStyle(
                          //                         fontFamily: FitnessAppTheme.fontName,
                          //                         fontWeight: FontWeight.bold,
                          //                         fontSize: 15.px,
                          //                         color: (((dailytarget - eatenCounter) +
                          //                             burnedCounter) >
                          //                             dailytarget)
                          //                             ? Colors.orangeAccent
                          //                             : ((dailytarget - eatenCounter) +
                          //                             burnedCounter) >
                          //                             0
                          //                             ? AppColors.primaryColor
                          //                             : Colors.redAccent,
                          //                       ),
                          //                     ),
                          //                     Text(
                          //                       // ((dailytarget - eatenCounter) +
                          //                       //     burnedCounter) >
                          //                       //     0
                          //                       //     ? 'Cal Need'
                          //                       //     : 'Cal extra',
                          //                       "cal left",
                          //                       textAlign: TextAlign.center,
                          //                       style: TextStyle(
                          //                         fontFamily: FitnessAppTheme.fontName,
                          //                         fontWeight: FontWeight.bold,
                          //                         fontSize: ScUtil().setSp(12),
                          //                         letterSpacing: 0.0,
                          //                         color: FitnessAppTheme.grey
                          //                             .withOpacity(0.5),
                          //                       ),
                          //                     )
                          //                   ],
                          //                 )
                          //                     : Column(
                          //                   mainAxisAlignment: MainAxisAlignment.center,
                          //                   children: [
                          //                     Text(
                          //                       todayLog.limitExceed?"0":'${todayLog.caloriesNeed}',
                          //                       textAlign: TextAlign.center,
                          //                       style: TextStyle(
                          //                         fontFamily: FitnessAppTheme.fontName,
                          //                         fontWeight: FontWeight.normal,
                          //                         fontSize: 15.px,
                          //                         letterSpacing: 0.0,
                          //                         color: AppColors.primaryColor,
                          //                       ),
                          //                     ),
                          //                     Text(
                          //                       'Cal left',
                          //                       textAlign: TextAlign.center,
                          //                       style: TextStyle(
                          //                         fontFamily: FitnessAppTheme.fontName,
                          //                         fontWeight: FontWeight.bold,
                          //                         fontSize: ScUtil().setSp(14),
                          //                         letterSpacing: 0.0,
                          //                         color: FitnessAppTheme.grey
                          //                             .withOpacity(0.5),
                          //                       ),
                          //                     )
                          //                   ],
                          //                 ),
                          //               ),
                          //             );
                          //           });
                          //     })
                          //     : Shimmer.fromColors(
                          //   baseColor: Colors.white,
                          //   direction: ShimmerDirection.ltr,
                          //   highlightColor: Colors.grey.withOpacity(0.2),
                          //   child: Container(
                          //       height: 25.w,
                          //       width: 25.w,
                          //       decoration: BoxDecoration(
                          //         color: Colors.white,
                          //         borderRadius: BorderRadius.circular(2),
                          //       )),
                          // ),
                          Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: MediaQuery.of(context).size.width > 350 &&
                                        MediaQuery.of(context).size.height > 650
                                    ? 46
                                    : 38,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //0 calories removed and now we're showing extra calories
                                    Text(
                                      todayLog.limitExceed
                                          ? todayLog.exceedsCalories.toString()
                                          : "${todayLog.caloriesNeed}",
                                      style:
                                          //selectedAfficolor != null
                                          //     ? TextStyle(
                                          //   fontFamily: 'Poppins',
                                          //   fontSize: 13.sp,
                                          //   color: selectedAfficolor,
                                          //   fontWeight: FontWeight.w800,
                                          // )
                                          todayLog.limitExceed
                                              ? AppTextStyles.limitExceed
                                              : AppTextStyles.withinLimit,
                                    ),
                                    Text(
                                      todayLog.limitExceed ? "Cal Extra" : "Cal Left",
                                      style: AppTextStyles.regularFont,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width > 350 &&
                                        MediaQuery.of(context).size.height > 650
                                    ? 95
                                    : 78,
                                height: MediaQuery.of(context).size.height > 650 ? 95 : 78,
                                child: CircularProgressIndicator(
                                  strokeWidth: 9,
                                  backgroundColor: AppColors.backgroundScreenColor,
                                  color: AppColors.calNeed3,
                                  value: 1,
                                ),
                              ),
                              LinearGradientCircularProgressIndicator(
                                strokeWidth: 10,
                                radius: 23.8,
                                // value: todayLog.limitExceed
                                //     // ? todayLog.caloriesNeed / int.parse(todayLog.totalCalories)
                                //   ?1
                                //     : todayLog.caloriesNeed > int.parse(todayLog.totalCalories)
                                //     ? (todayLog.caloriesNeed /
                                //     int.parse(todayLog.totalCalories)) -
                                //     1
                                //     : todayLog.caloriesNeed != 0
                                //     ? (todayLog.caloriesGained.toDouble() /
                                //     double.parse(todayLog.totalCalories))
                                //  : 1, // Change this value to update the progress
                                value: todayLog.limitExceed
                                    ? 1
                                    : 1 -
                                        (todayLog.caloriesNeed / int.parse(todayLog.totalCalories)),
                                gradientColors: todayLog.limitExceed
                                    ? [AppColors.calExtra, AppColors.calExtraOpc]
                                    : [
                                        AppColors.calNeed,
                                        AppColors.calNeedOpc
                                      ], // Set your gradient colors
                              ),
                            ],
                          ),
                          // Stack(
                          //   clipBehavior: Clip.none,
                          //   children: <Widget>[
                          //     if (false)
                          //       Padding(
                          //         // padding: EdgeInsets.symmetric(horizontal: ScUtil().setWidth(8),vertical: ScUtil().setHeight(8)),
                          //         padding: EdgeInsets.only(
                          //             left: MediaQuery.of(context).size.width * 0.07,
                          //             top: MediaQuery.of(context).size.width * 0.02),
                          //         child: preferences != null
                          //             ? PreferenceBuilder<int>(
                          //             preference:
                          //             preferences.getInt('burnedCalorie', defaultValue: 0),
                          //             builder: (BuildContext context, int burnedCounter) {
                          //               return PreferenceBuilder<int>(
                          //                   preference: preferences.getInt('eatenCalorie',
                          //                       defaultValue: 0),
                          //                   builder: (BuildContext context, int eatenCounter) {
                          //                     // return CustomPaint(
                          //                     //   painter: CurvePainter(colors: [
                          //                     //     defaultColor,
                          //                     //     defaultColor,
                          //                     //     defaultColor
                          //                     //   ], angle: 360, srokeWidth: 8),
                          //                     //   child: SizedBox(
                          //                     //     width: 27.w,
                          //                     //     height: 27.w,
                          //                     //   ),
                          //                     // );
                          //                     return Container(
                          //                       width: MediaQuery.of(context).size.width * 0.28,
                          //                       height:
                          //                       MediaQuery.of(context).size.height * 0.13,
                          //                       decoration: BoxDecoration(
                          //                         color: FitnessAppTheme.white,
                          //                         borderRadius: const BorderRadius.all(
                          //                           Radius.circular(120.0),
                          //                         ),
                          //                         border: ((dailytarget - eatenCounter) +
                          //                             burnedCounter) <
                          //                             0
                          //                             ? Border.all(
                          //                             width: 10, color: Colors.green)
                          //                             : Border.all(
                          //                             width: 4,
                          //                             color: AppColors.primaryColor
                          //                                 .withOpacity(0.2)),
                          //                       ),
                          //                       child: Padding(
                          //                         padding: const EdgeInsets.all(10.0),
                          //                         child: Column(
                          //                           mainAxisAlignment: MainAxisAlignment.center,
                          //                           crossAxisAlignment:
                          //                           CrossAxisAlignment.center,
                          //                           children: <Widget>[
                          //                             preferences != null
                          //                                 ? PreferenceBuilder<int>(
                          //                                 preference: preferences.getInt(
                          //                                     'burnedCalorie',
                          //                                     defaultValue: 0),
                          //                                 builder: (BuildContext context,
                          //                                     int burnedCounter) {
                          //                                   return PreferenceBuilder<int>(
                          //                                       preference: preferences
                          //                                           .getInt('eatenCalorie',
                          //                                           defaultValue: 0),
                          //                                       builder:
                          //                                           (BuildContext context,
                          //                                           int eatenCounter) {
                          //                                         return Text(
                          //                                           // '$dailytarget',
                          //                                           '${todayLog.caloriesNeed}',
                          //                                           textAlign:
                          //                                           TextAlign.center,
                          //                                           style: TextStyle(
                          //                                             fontFamily:
                          //                                             FitnessAppTheme
                          //                                                 .fontName,
                          //                                             fontWeight:
                          //                                             FontWeight.bold,
                          //                                             fontSize: ScUtil()
                          //                                                 .setSp(18),
                          //                                             color: (((dailytarget -
                          //                                                 eatenCounter) +
                          //                                                 burnedCounter) >
                          //                                                 dailytarget)
                          //                                                 ? Colors
                          //                                                 .orangeAccent
                          //                                                 : ((dailytarget -
                          //                                                 eatenCounter) +
                          //                                                 burnedCounter) >
                          //                                                 0
                          //                                                 ? AppColors
                          //                                                 .primaryColor
                          //                                                 : Colors
                          //                                                 .redAccent,
                          //                                           ),
                          //                                         );
                          //                                       });
                          //                                 })
                          //                                 : Text(
                          //                               '${todayLog.caloriesNeed}',
                          //                               textAlign: TextAlign.center,
                          //                               style: TextStyle(
                          //                                 fontFamily:
                          //                                 FitnessAppTheme.fontName,
                          //                                 fontWeight: FontWeight.normal,
                          //                                 fontSize: ScUtil().setSp(27),
                          //                                 letterSpacing: 0.0,
                          //                                 color: AppColors.primaryColor,
                          //                               ),
                          //                             ),
                          //                             preferences != null
                          //                                 ? PreferenceBuilder<int>(
                          //                                 preference: preferences.getInt(
                          //                                     'burnedCalorie',
                          //                                     defaultValue: 0),
                          //                                 builder: (BuildContext context,
                          //                                     int burnedCounter) {
                          //                                   return PreferenceBuilder<int>(
                          //                                       preference: preferences
                          //                                           .getInt('eatenCalorie',
                          //                                           defaultValue: 0),
                          //                                       builder:
                          //                                           (BuildContext context,
                          //                                           int eatenCounter) {
                          //                                         return Text(
                          //                                           ((dailytarget - eatenCounter) +
                          //                                               burnedCounter) >
                          //                                               0
                          //                                               ? 'Cal Taken'
                          //                                               : 'Cal extra',
                          //                                           textAlign:
                          //                                           TextAlign.center,
                          //                                           style: TextStyle(
                          //                                             fontFamily:
                          //                                             FitnessAppTheme
                          //                                                 .fontName,
                          //                                             fontWeight:
                          //                                             FontWeight.bold,
                          //                                             fontSize: ScUtil()
                          //                                                 .setSp(12),
                          //                                             letterSpacing: 0.0,
                          //                                             color: FitnessAppTheme
                          //                                                 .grey
                          //                                                 .withOpacity(0.5),
                          //                                           ),
                          //                                         );
                          //                                       });
                          //                                 })
                          //                                 : Text(
                          //                               'Cal left',
                          //                               textAlign: TextAlign.center,
                          //                               style: TextStyle(
                          //                                 fontFamily:
                          //                                 FitnessAppTheme.fontName,
                          //                                 fontWeight: FontWeight.bold,
                          //                                 fontSize: ScUtil().setSp(14),
                          //                                 letterSpacing: 0.0,
                          //                                 color: FitnessAppTheme.grey
                          //                                     .withOpacity(0.5),
                          //                               ),
                          //                             ),
                          //                           ],
                          //                         ),
                          //                       ),
                          //                     );
                          //                   });
                          //             })
                          //             : Container(
                          //           width: 120,
                          //           height: 120,
                          //           decoration: BoxDecoration(
                          //             color: FitnessAppTheme.white,
                          //             borderRadius: const BorderRadius.all(
                          //               Radius.circular(120.0),
                          //             ),
                          //             border: Border.all(
                          //                 width: 4,
                          //                 color: AppColors.primaryColor.withOpacity(0.2)),
                          //           ),
                          //           child: Column(
                          //             mainAxisAlignment: MainAxisAlignment.center,
                          //             crossAxisAlignment: CrossAxisAlignment.center,
                          //             children: <Widget>[
                          //               preferences != null
                          //                   ? PreferenceBuilder<int>(
                          //                   preference: preferences
                          //                       .getInt('burnedCalorie', defaultValue: 0),
                          //                   builder: (BuildContext context,
                          //                       int burnedCounter) {
                          //                     return PreferenceBuilder<int>(
                          //                         preference: preferences.getInt(
                          //                             'eatenCalorie',
                          //                             defaultValue: 0),
                          //                         builder: (BuildContext context,
                          //                             int eatenCounter) {
                          //                           return Text(
                          //                             '${((dailytarget - eatenCounter) + burnedCounter).abs()}',
                          //                             textAlign: TextAlign.center,
                          //                             style: TextStyle(
                          //                               fontFamily:
                          //                               FitnessAppTheme.fontName,
                          //                               fontWeight: FontWeight.normal,
                          //                               fontSize: ScUtil().setSp(28),
                          //                               letterSpacing: 0.0,
                          //                               color: (((dailytarget -
                          //                                   eatenCounter) +
                          //                                   burnedCounter) >
                          //                                   dailytarget)
                          //                                   ? Colors.orangeAccent
                          //                                   : ((dailytarget -
                          //                                   eatenCounter) +
                          //                                   burnedCounter) >
                          //                                   0
                          //                                   ? AppColors.primaryColor
                          //                                   : Colors.redAccent,
                          //                             ),
                          //                           );
                          //                         });
                          //                   })
                          //                   : Text(
                          //                 '$dailytarget',
                          //                 textAlign: TextAlign.center,
                          //                 style: TextStyle(
                          //                   fontFamily: FitnessAppTheme.fontName,
                          //                   fontWeight: FontWeight.normal,
                          //                   fontSize: ScUtil().setSp(28),
                          //                   letterSpacing: 0.0,
                          //                   color: AppColors.primaryColor,
                          //                 ),
                          //               ),
                          //               preferences != null
                          //                   ? PreferenceBuilder<int>(
                          //                   preference: preferences
                          //                       .getInt('burnedCalorie', defaultValue: 0),
                          //                   builder: (BuildContext context,
                          //                       int burnedCounter) {
                          //                     return PreferenceBuilder<int>(
                          //                         preference: preferences.getInt(
                          //                             'eatenCalorie',
                          //                             defaultValue: 0),
                          //                         builder: (BuildContext context,
                          //                             int eatenCounter) {
                          //                           return Text(
                          //                             ((dailytarget - eatenCounter) +
                          //                                 burnedCounter) >
                          //                                 0
                          //                                 ? 'Cal left'
                          //                                 : 'Cal extra',
                          //                             textAlign: TextAlign.center,
                          //                             style: TextStyle(
                          //                               fontFamily:
                          //                               FitnessAppTheme.fontName,
                          //                               fontWeight: FontWeight.bold,
                          //                               fontSize: ScUtil().setSp(14),
                          //                               letterSpacing: 0.0,
                          //                               color: FitnessAppTheme.grey
                          //                                   .withOpacity(0.5),
                          //                             ),
                          //                           );
                          //                         });
                          //                   })
                          //                   : Text(
                          //                 'Cal left',
                          //                 textAlign: TextAlign.center,
                          //                 style: TextStyle(
                          //                   fontFamily: FitnessAppTheme.fontName,
                          //                   fontWeight: FontWeight.bold,
                          //                   fontSize: ScUtil().setSp(14),
                          //                   letterSpacing: 0.0,
                          //                   color:
                          //                   FitnessAppTheme.grey.withOpacity(0.5),
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //     if (false)
                          //       Padding(
                          //         // padding: EdgeInsets.symmetric(horizontal: ScUtil().setWidth(8),vertical: ScUtil().setHeight(8)),
                          //         padding: const EdgeInsets.all(1),
                          //         child: preferences != null
                          //             ? PreferenceBuilder<int>(
                          //             preference:
                          //             preferences.getInt('burnedCalorie', defaultValue: 0),
                          //             builder: (BuildContext context, int burnedCounter) {
                          //               return PreferenceBuilder<int>(
                          //                   preference: preferences.getInt('eatenCalorie',
                          //                       defaultValue: 0),
                          //                   builder: (BuildContext context, int eatenCounter) {
                          //                     return CustomPaint(
                          //                       painter: CurvePainter(
                          //                           colors: (((dailytarget - eatenCounter) +
                          //                               burnedCounter) >
                          //                               dailytarget)
                          //                               ? [
                          //                             Colors.orangeAccent,
                          //                             Colors.orangeAccent,
                          //                             Colors.orangeAccent
                          //                           ]
                          //                               : ((dailytarget - eatenCounter) +
                          //                               burnedCounter) >
                          //                               0
                          //                               ? [
                          //                             AppColors.primaryColor,
                          //                             AppColors.primaryColor,
                          //                             AppColors.primaryColor,
                          //                           ]
                          //                               : [
                          //                             Colors.redAccent,
                          //                             Colors.redAccent,
                          //                             Colors.redAccent
                          //                           ],
                          //                           angle: ((dailytarget - eatenCounter) +
                          //                               burnedCounter) <
                          //                               0
                          //                               ? (360) *
                          //                               ((dailytarget -
                          //                                   eatenCounter -
                          //                                   burnedCounter) /
                          //                                   eatenCounter)
                          //                               : (360) *
                          //                               ((eatenCounter - burnedCounter) /
                          //                                   dailytarget)),
                          //                       child: //Text('kgh')
                          //                       Container(
                          //                         width:
                          //                         MediaQuery.of(context).size.width * 0.4,
                          //                         height:
                          //                         MediaQuery.of(context).size.height * 0.13,
                          //                       ),
                          //                     );
                          //                   });
                          //             })
                          //             : CustomPaint(
                          //           painter: CurvePainter(colors: [
                          //             AppColors.primaryColor,
                          //             AppColors.primaryColor,
                          //             AppColors.primaryColor
                          //           ], angle: (360) * (0.0)),
                          //           child: const SizedBox(
                          //             width: 128,
                          //             height: 128,
                          //           ),
                          //         ),
                          //       )
                          //   ],
                          // ),
                          SizedBox(height: 2.h),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: SizedBox(
                                  // width: 10.w,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Image.asset(
                                        ImageAssets.calConsumed,
                                        height: 4.h,
                                        width: 4.w,
                                        // color: AppColors.primaryColor,
                                      ),
                                      SizedBox(
                                        width: 2.w,
                                      ),
                                      Text(
                                        'Consumed',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScUtil().setSp(12),
                                          color: FitnessAppTheme.grey.withOpacity(0.5),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      Text(
                                        '-',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScUtil().setSp(12),
                                          color: FitnessAppTheme.grey.withOpacity(0.5),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      preferences != null
                                          ? PreferenceBuilder<int>(
                                              preference: preferences.getInt('eatenCalorie',
                                                  defaultValue: 0),
                                              builder: (BuildContext context, int eatenCounter) {
                                                return Text(
                                                  '$eatenCounter',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: FitnessAppTheme.fontName,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: ScUtil().setSp(12),
                                                    color: FitnessAppTheme.grey.withOpacity(0.5),
                                                  ),
                                                );
                                              })
                                          : Text(
                                              '0',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: FitnessAppTheme.fontName,
                                                fontWeight: FontWeight.w600,
                                                fontSize: ScUtil().setSp(12),
                                                color: FitnessAppTheme.grey.withOpacity(0.5),
                                              ),
                                            ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: ScUtil().setWidth(4),
                                          // bottom: ScUtil().setHeight(2)
                                        ),
                                        child: Text(
                                          'Cal',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w600,
                                            fontSize: ScUtil().setSp(12),
                                            letterSpacing: -0.2,
                                            color: FitnessAppTheme.grey.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: SizedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Image.asset(
                                        ImageAssets.calBurnt2,
                                        height: 4.h,
                                        width: 4.w,
                                        // color: AppColors.primaryColor,
                                      ),
                                      SizedBox(
                                        width: 2.w,
                                      ),
                                      Text(
                                        'Burnt',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScUtil().setSp(12),
                                          letterSpacing: -0.2,
                                          color: FitnessAppTheme.grey.withOpacity(0.5),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      Text(
                                        '-',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScUtil().setSp(12),
                                          color: FitnessAppTheme.grey.withOpacity(0.5),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      preferences != null
                                          ? PreferenceBuilder<int>(
                                              preference: preferences.getInt('burnedCalorie',
                                                  defaultValue: 0),
                                              builder: (BuildContext context, int burnedCounter) {
                                                return Text(
                                                  '$burnedCounter',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: FitnessAppTheme.fontName,
                                                    fontSize: ScUtil().setSp(12),
                                                    letterSpacing: -0.2,
                                                    color: FitnessAppTheme.grey.withOpacity(0.5),
                                                  ),
                                                );
                                              })
                                          : const Text(''),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: ScUtil().setWidth(4),
                                          // bottom: ScUtil().setHeight(0)
                                        ),
                                        child: Text(
                                          'Cal',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w600,
                                            fontSize: ScUtil().setSp(12),
                                            letterSpacing: -0.2,
                                            color: FitnessAppTheme.grey.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      const Spacer()
                    ],
                  ),
                ),
              ));
        });
  }
}

class MediterranesnDietView extends StatefulWidget {
  const MediterranesnDietView({Key key, this.isNavigation}) : super(key: key);
  final isNavigation;

  @override
  _MediterranesnDietViewState createState() => _MediterranesnDietViewState();
}

class _MediterranesnDietViewState extends State<MediterranesnDietView> {
  StreamingSharedPreferences preferences;
  int dailytarget = 0;
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    init();
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    StreamingSharedPreferences.instance.then((StreamingSharedPreferences value) {
      if (mounted) {
        setState(() {
          preferences = value;
        });
      }
    });
    dailyTarget().then((String value) {
      if (mounted) {
        setState(() {
          dailytarget = int.parse(value);
          prefs.setInt('daily_target', dailytarget);
          prefs.setInt('weekly_target', dailytarget * 7);
          prefs.setInt('monthly_target', dailytarget * daysInMonth(DateTime.now()));
        });
      }
    });
  }

  Future<String> dailyTarget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int dailyTarget = prefs.getInt('daily_target');

    if (dailyTarget == null || dailyTarget == 0) {
      Object userData = prefs.get('data');
      preferences.setBool('maintain_weight', true);
      Map res = jsonDecode(userData);
      String height;
      DateTime birthDate;
      String datePattern = "MM/dd/yyyy";
      String dob = res['User']['dateOfBirth'].toString();
      DateTime today = DateTime.now();
      try {
        birthDate = DateFormat(datePattern).parse(dob);
      } catch (e) {
        birthDate = DateFormat('MM-dd-yyyy').parse(dob);
      }
      int age = today.year - birthDate.year;
      if (res['User']['heightMeters'] is num) {
        height = (res['User']['heightMeters'] * 100).toInt().toString();
      }
      String weight = res['User']['userInputWeightInKG'].toString() ?? '0';
      if (weight == '') {
        weight = prefs.get('userLatestWeight').toString();
      }
      var m = res['User']['gender'];
      num maleBmr =
          (10 * double.parse(weight.toString()) + 6.25 * double.parse(height) - (5 * age) + 5);
      num femaleBmr = (10 * double.parse(weight) + 6.25 * double.parse(height) - (5 * age) - 161);
      return (m == 'm' || m == 'M' || m == 'male' || m == 'Male')
          ? maleBmr.toStringAsFixed(0)
          : femaleBmr.toStringAsFixed(0);
    } else {
      bool maintainWeight = prefs.getBool('maintain_weight');
      if (maintainWeight == null) {
        preferences.setBool('maintain_weight', true);
      }
      return dailyTarget.toString();
    }
  }

  int daysInMonth(DateTime date) {
    DateTime firstDayThisMonth = DateTime(date.year, date.month, date.day);
    DateTime firstDayNextMonth =
        DateTime(firstDayThisMonth.year, firstDayThisMonth.month + 1, firstDayThisMonth.day);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        allowFontScaling: true);
    return GestureDetector(
      onTap: () {
        //Get.to(ViewGoalSettingScreen());
        if (widget.isNavigation) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context) => DietJournal()),
              (Route<dynamic> route) => false);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
            left: ScUtil().setWidth(16),
            right: ScUtil().setWidth(16),
            top: ScUtil().setHeight(18),
            bottom: ScUtil().setHeight(16)),
        child: Container(
          decoration: BoxDecoration(
            color: FitnessAppTheme.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
                topRight: Radius.circular(68.0)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: FitnessAppTheme.grey.withOpacity(0.2),
                  offset: const Offset(1.1, 1.1),
                  blurRadius: 10.0),
            ],
          ),
          child: Column(
            children: <Widget>[
              Padding(
                // padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                padding: EdgeInsets.only(top: ScUtil().setHeight(16), left: ScUtil().setWidth(10)),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: ScUtil().setWidth(8),
                            right: ScUtil().setWidth(8),
                            top: ScUtil().setHeight(4)),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  height: ScUtil().setWidth(48),
                                  width: ScUtil().setHeight(2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(0.5),
                                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScUtil().setWidth(8),
                                      vertical: ScUtil().setHeight(8)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: ScUtil().setHeight(4),
                                            bottom: ScUtil().setHeight(2)),
                                        child: Text(
                                          'Eaten',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScUtil().setSp(16),
                                            letterSpacing: -0.1,
                                            color: FitnessAppTheme.grey.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          SizedBox(
                                            // width: 30,
                                            // height: 30,
                                            width: ScUtil().setWidth(30),
                                            height: ScUtil().setHeight(30),
                                            child: Image.asset("assets/images/diet/eaten.png"),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: ScUtil().setWidth(4),
                                                bottom: ScUtil().setHeight(3)),
                                            child: preferences != null
                                                ? PreferenceBuilder<int>(
                                                    preference: preferences.getInt('eatenCalorie',
                                                        defaultValue: 0),
                                                    builder:
                                                        (BuildContext context, int eatenCounter) {
                                                      return Text(
                                                        '$eatenCounter',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily: FitnessAppTheme.fontName,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: ScUtil().setSp(16),
                                                          color: FitnessAppTheme.darkerText,
                                                        ),
                                                      );
                                                    })
                                                : Text(
                                                    '0',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: FitnessAppTheme.fontName,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: ScUtil().setSp(16),
                                                      color: FitnessAppTheme.darkerText,
                                                    ),
                                                  ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: ScUtil().setWidth(4),
                                                bottom: ScUtil().setHeight(3)),
                                            child: Text(
                                              'Cal',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: FitnessAppTheme.fontName,
                                                fontWeight: FontWeight.w600,
                                                fontSize: ScUtil().setSp(13),
                                                letterSpacing: -0.2,
                                                color: FitnessAppTheme.grey.withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: ScUtil().setHeight(8),
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  height: ScUtil().setHeight(48),
                                  width: ScUtil().setWidth(2),
                                  decoration: BoxDecoration(
                                    color: HexColor('#F56E98').withOpacity(0.5),
                                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScUtil().setWidth(8),
                                      vertical: ScUtil().setHeight(8)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: ScUtil().setHeight(4),
                                            bottom: ScUtil().setHeight(2)),
                                        child: Text(
                                          'Burned',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScUtil().setSp(16),
                                            letterSpacing: -0.1,
                                            color: FitnessAppTheme.grey.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          SizedBox(
                                            width: ScUtil().setWidth(30),
                                            height: ScUtil().setHeight(30),
                                            child: Image.asset("assets/images/diet/burned.png"),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: ScUtil().setHeight(4),
                                                bottom: ScUtil().setHeight(2)),
                                            child: preferences != null
                                                ? PreferenceBuilder<int>(
                                                    preference: preferences.getInt('burnedCalorie',
                                                        defaultValue: 0),
                                                    builder:
                                                        (BuildContext context, int burnedCounter) {
                                                      return Text(
                                                        '$burnedCounter',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily: FitnessAppTheme.fontName,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: ScUtil().setSp(16),
                                                          color: FitnessAppTheme.darkerText,
                                                        ),
                                                      );
                                                    })
                                                : Text(
                                                    '0',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: FitnessAppTheme.fontName,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: ScUtil().setSp(16),
                                                      color: FitnessAppTheme.darkerText,
                                                    ),
                                                  ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: ScUtil().setHeight(8),
                                                bottom: ScUtil().setHeight(3)),
                                            child: Text(
                                              'Cal',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: FitnessAppTheme.fontName,
                                                fontWeight: FontWeight.w600,
                                                fontSize: ScUtil().setSp(13),
                                                letterSpacing: -0.2,
                                                color: FitnessAppTheme.grey.withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    ///Circular Calorie Indicator
                    Padding(
                      padding: EdgeInsets.only(right: ScUtil().setWidth(1)),
                      // padding:  EdgeInsets.zero,
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Padding(
                              // padding: EdgeInsets.symmetric(horizontal: ScUtil().setWidth(8),vertical: ScUtil().setHeight(8)),
                              padding: const EdgeInsets.all(4),
                              child: preferences != null
                                  ? PreferenceBuilder<int>(
                                      preference:
                                          preferences.getInt('burnedCalorie', defaultValue: 0),
                                      builder: (BuildContext context, int burnedCounter) {
                                        return PreferenceBuilder<int>(
                                            preference:
                                                preferences.getInt('eatenCalorie', defaultValue: 0),
                                            builder: (BuildContext context, int eatenCounter) {
                                              return Container(
                                                width: 120,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  color: FitnessAppTheme.white,
                                                  borderRadius: const BorderRadius.all(
                                                    Radius.circular(120.0),
                                                  ),
                                                  border: ((dailytarget - eatenCounter) +
                                                              burnedCounter) <
                                                          0
                                                      ? Border.all(width: 10, color: Colors.green)
                                                      : Border.all(
                                                          width: 4,
                                                          color: AppColors.primaryColor
                                                              .withOpacity(0.2)),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    preferences != null
                                                        ? PreferenceBuilder<int>(
                                                            preference: preferences.getInt(
                                                                'burnedCalorie',
                                                                defaultValue: 0),
                                                            builder: (BuildContext context,
                                                                int burnedCounter) {
                                                              return PreferenceBuilder<int>(
                                                                  preference: preferences.getInt(
                                                                      'eatenCalorie',
                                                                      defaultValue: 0),
                                                                  builder: (BuildContext context,
                                                                      int eatenCounter) {
                                                                    return Text(
                                                                      '${((dailytarget - eatenCounter) + burnedCounter).abs()}',
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                        fontFamily: FitnessAppTheme
                                                                            .fontName,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        fontSize:
                                                                            ScUtil().setSp(28),
                                                                        letterSpacing: 0.0,
                                                                        color: (((dailytarget -
                                                                                        eatenCounter) +
                                                                                    burnedCounter) >
                                                                                dailytarget)
                                                                            ? Colors.orangeAccent
                                                                            : ((dailytarget -
                                                                                            eatenCounter) +
                                                                                        burnedCounter) >
                                                                                    0
                                                                                ? AppColors
                                                                                    .primaryColor
                                                                                : Colors.redAccent,
                                                                      ),
                                                                    );
                                                                  });
                                                            })
                                                        : Text(
                                                            '$dailytarget',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontFamily: FitnessAppTheme.fontName,
                                                              fontWeight: FontWeight.normal,
                                                              fontSize: ScUtil().setSp(28),
                                                              letterSpacing: 0.0,
                                                              color: AppColors.primaryColor,
                                                            ),
                                                          ),
                                                    preferences != null
                                                        ? PreferenceBuilder<int>(
                                                            preference: preferences.getInt(
                                                                'burnedCalorie',
                                                                defaultValue: 0),
                                                            builder: (BuildContext context,
                                                                int burnedCounter) {
                                                              return PreferenceBuilder<int>(
                                                                  preference: preferences.getInt(
                                                                      'eatenCalorie',
                                                                      defaultValue: 0),
                                                                  builder: (BuildContext context,
                                                                      int eatenCounter) {
                                                                    return Text(
                                                                      ((dailytarget - eatenCounter) +
                                                                                  burnedCounter) >
                                                                              0
                                                                          ? 'Cal left'
                                                                          : 'Cal extra',
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                        fontFamily: FitnessAppTheme
                                                                            .fontName,
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize:
                                                                            ScUtil().setSp(14),
                                                                        letterSpacing: 0.0,
                                                                        color: FitnessAppTheme.grey
                                                                            .withOpacity(0.5),
                                                                      ),
                                                                    );
                                                                  });
                                                            })
                                                        : Text(
                                                            'Cal left',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontFamily: FitnessAppTheme.fontName,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: ScUtil().setSp(14),
                                                              letterSpacing: 0.0,
                                                              color: FitnessAppTheme.grey
                                                                  .withOpacity(0.5),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              );
                                            });
                                      })
                                  : Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: FitnessAppTheme.white,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(120.0),
                                        ),
                                        border: Border.all(
                                            width: 4,
                                            color: AppColors.primaryColor.withOpacity(0.2)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          preferences != null
                                              ? PreferenceBuilder<int>(
                                                  preference: preferences.getInt('burnedCalorie',
                                                      defaultValue: 0),
                                                  builder:
                                                      (BuildContext context, int burnedCounter) {
                                                    return PreferenceBuilder<int>(
                                                        preference: preferences.getInt(
                                                            'eatenCalorie',
                                                            defaultValue: 0),
                                                        builder: (BuildContext context,
                                                            int eatenCounter) {
                                                          return Text(
                                                            '${((dailytarget - eatenCounter) + burnedCounter).abs()}',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontFamily: FitnessAppTheme.fontName,
                                                              fontWeight: FontWeight.normal,
                                                              fontSize: ScUtil().setSp(28),
                                                              letterSpacing: 0.0,
                                                              color: (((dailytarget -
                                                                              eatenCounter) +
                                                                          burnedCounter) >
                                                                      dailytarget)
                                                                  ? Colors.orangeAccent
                                                                  : ((dailytarget - eatenCounter) +
                                                                              burnedCounter) >
                                                                          0
                                                                      ? AppColors.primaryColor
                                                                      : Colors.redAccent,
                                                            ),
                                                          );
                                                        });
                                                  })
                                              : Text(
                                                  '$dailytarget',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: FitnessAppTheme.fontName,
                                                    fontWeight: FontWeight.normal,
                                                    fontSize: ScUtil().setSp(28),
                                                    letterSpacing: 0.0,
                                                    color: AppColors.primaryColor,
                                                  ),
                                                ),
                                          preferences != null
                                              ? PreferenceBuilder<int>(
                                                  preference: preferences.getInt('burnedCalorie',
                                                      defaultValue: 0),
                                                  builder:
                                                      (BuildContext context, int burnedCounter) {
                                                    return PreferenceBuilder<int>(
                                                        preference: preferences.getInt(
                                                            'eatenCalorie',
                                                            defaultValue: 0),
                                                        builder: (BuildContext context,
                                                            int eatenCounter) {
                                                          return Text(
                                                            ((dailytarget - eatenCounter) +
                                                                        burnedCounter) >
                                                                    0
                                                                ? 'Cal left'
                                                                : 'Cal extra',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontFamily: FitnessAppTheme.fontName,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: ScUtil().setSp(14),
                                                              letterSpacing: 0.0,
                                                              color: FitnessAppTheme.grey
                                                                  .withOpacity(0.5),
                                                            ),
                                                          );
                                                        });
                                                  })
                                              : Text(
                                                  'Cal left',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: FitnessAppTheme.fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: ScUtil().setSp(14),
                                                    letterSpacing: 0.0,
                                                    color: FitnessAppTheme.grey.withOpacity(0.5),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                            ),
                            Padding(
                              // padding: EdgeInsets.symmetric(horizontal: ScUtil().setWidth(8),vertical: ScUtil().setHeight(8)),
                              padding: const EdgeInsets.all(1),
                              child: preferences != null
                                  ? PreferenceBuilder<int>(
                                      preference:
                                          preferences.getInt('burnedCalorie', defaultValue: 0),
                                      builder: (BuildContext context, int burnedCounter) {
                                        return PreferenceBuilder<int>(
                                            preference:
                                                preferences.getInt('eatenCalorie', defaultValue: 0),
                                            builder: (BuildContext context, int eatenCounter) {
                                              return CustomPaint(
                                                painter: CurvePainter(
                                                    colors: (((dailytarget - eatenCounter) +
                                                                burnedCounter) >
                                                            dailytarget)
                                                        ? [
                                                            Colors.orangeAccent,
                                                            Colors.orangeAccent,
                                                            Colors.orangeAccent
                                                          ]
                                                        : ((dailytarget - eatenCounter) +
                                                                    burnedCounter) >
                                                                0
                                                            ? [
                                                                AppColors.primaryColor,
                                                                AppColors.primaryColor,
                                                                AppColors.primaryColor
                                                              ]
                                                            : [
                                                                Colors.redAccent,
                                                                Colors.redAccent,
                                                                Colors.redAccent
                                                              ],
                                                    angle: ((dailytarget - eatenCounter) +
                                                                burnedCounter) <
                                                            0
                                                        ? (360) *
                                                            ((dailytarget -
                                                                    eatenCounter -
                                                                    burnedCounter) /
                                                                eatenCounter)
                                                        : (360) *
                                                            ((eatenCounter - burnedCounter) /
                                                                dailytarget)),
                                                child: const SizedBox(
                                                  width: 128,
                                                  height: 128,
                                                ),
                                              );
                                            });
                                      })
                                  : CustomPaint(
                                      painter: CurvePainter(colors: [
                                        AppColors.primaryColor,
                                        AppColors.primaryColor,
                                        AppColors.primaryColor
                                      ], angle: (360) * (0.0)),
                                      child: const SizedBox(
                                        width: 128,
                                        height: 128,
                                      ),
                                    ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              /*Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 8, bottom: 8),
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.background,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 8, bottom: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Steps',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              letterSpacing: -0.2,
                              color: FitnessAppTheme.darkText,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              height: 4,
                              width: 70,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 70,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        HexColor('#87A0E5'),
                                        HexColor('#87A0E5').withOpacity(0.5),
                                      ]),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '2587 out of 5600',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: FitnessAppTheme.grey.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Distance',
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  letterSpacing: -0.2,
                                  color: FitnessAppTheme.darkText,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 0, top: 4),
                                child: Container(
                                  height: 4,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: HexColor('#F1B440').withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0)),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: ((70)),
                                        height: 4,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [
                                            HexColor('#F1B440')
                                                .withOpacity(0.1),
                                            HexColor('#F1B440'),
                                          ]),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '2.3 Kms covered',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color:
                                        FitnessAppTheme.grey.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )*/
            ],
          ),
        ),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final double angle;
  final List<Color> colors;
  final double srokeWidth;

  CurvePainter({this.colors, this.angle = 140, this.srokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = [];
    if (colors != null) {
      colorsList = colors ?? [];
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final Paint shdowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = srokeWidth ?? 14;
    final Offset shdowPaintCenter = Offset(size.width / 2, size.height / 2);
    final double shdowPaintRadius = math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278), degreeToRadians(360 - (365 - angle)), false, shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.3);
    shdowPaint.strokeWidth = srokeWidth ?? 16;
    canvas.drawArc(Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278), degreeToRadians(360 - (365 - angle)), false, shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.2);
    shdowPaint.strokeWidth = srokeWidth ?? 20;
    canvas.drawArc(Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278), degreeToRadians(360 - (365 - angle)), false, shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.1);
    shdowPaint.strokeWidth = srokeWidth ?? 22;
    canvas.drawArc(Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278), degreeToRadians(360 - (365 - angle)), false, shdowPaint);

    final Rect rect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final SweepGradient gradient = SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = srokeWidth ?? 14;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), degreeToRadians(278),
        degreeToRadians(360 - (365 - angle)), false, paint);

    const SweepGradient gradient1 = SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.transparent, Colors.transparent],
    );

    Paint cPaint = Paint();
    cPaint.shader = gradient1.createShader(rect);
    cPaint.color = Colors.white;
    cPaint.strokeWidth = 14 / 2;
    canvas.save();

    final double centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + 14 / 2);
    canvas.drawCircle(const Offset(0, 0), 14 / 5, cPaint);

    canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    double redian = (math.pi / 180) * degree;
    return redian;
  }
}

class PercentageCircularProgressIndicator extends StatelessWidget {
  final double percentage;
  final Color backgroundColor;
  final List<Color> progressColor;
  final double strokeWidth;
  final TextStyle textStyle;
  final Color bottomLayerColor;
  final double progressStrokeWidth;
  final Widget centerWidget;

  const PercentageCircularProgressIndicator({
    Key key,
    this.percentage,
    this.backgroundColor = Colors.grey,
    this.progressColor,
    this.strokeWidth = 10.0,
    this.textStyle = const TextStyle(fontSize: 20.0),
    this.bottomLayerColor = Colors.transparent,
    this.progressStrokeWidth = 10.0,
    this.centerWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        size: const Size(23.0 * 2, 23.0 * 2),
        painter: _CircleProgressPainter(
            percentage: percentage,
            backgroundColor: backgroundColor,
            progressColor: progressColor,
            strokeWidth: strokeWidth,
            progressStrokeWidth: progressStrokeWidth
            // bottomLayerColor: bottomLayerColor,
            ),
        child: Center(
          child: centerWidget,
        ));
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double percentage;
  final Color backgroundColor;
  final List<Color> progressColor;
  final double strokeWidth;
  final double progressStrokeWidth;

  _CircleProgressPainter(
      {@required this.percentage,
      @required this.backgroundColor,
      @required this.progressColor,
      @required this.strokeWidth,
      @required this.progressStrokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width / 2, size.height / 2) - strokeWidth / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 7.5);
    final LinearGradient gradient = LinearGradient(
      colors: progressColor,
      stops: const [0.0, 1.1],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final double arcAngle = 2 * math.pi * percentage;
    final SweepGradient sweepGradient = SweepGradient(
      colors: progressColor,
      stops: const [
        0.0,
        0.60,
      ],
      startAngle: 0.0,
      endAngle: arcAngle,
      transform: const GradientRotation(-math.pi / 2),
    );
    // Draw background circle
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final Paint progressPaint = Paint()
      // ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = progressStrokeWidth
      ..strokeCap = StrokeCap.round; // Add curved ends to the progress indicator
    final double progressAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2.1,
      progressAngle,
      false,
      progressPaint,
    );
    progressPaint.shader = gradient.createShader(rect);

    canvas.drawArc(rect, -math.pi / 2, arcAngle, false, progressPaint);

    progressPaint.shader = sweepGradient.createShader(rect);

    canvas.drawArc(rect, -math.pi / 2.15, arcAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    // return oldDelegate.percentage != percentage ||
    //     oldDelegate.backgroundColor != backgroundColor ||
    //     oldDelegate.progressColor != progressColor ||
    //     oldDelegate.strokeWidth != strokeWidth;
    return true;
  }
}
