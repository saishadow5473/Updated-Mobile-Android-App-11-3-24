import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class HealthJouranlTabView extends StatefulWidget {
  HealthJouranlTabView({Key key}) : super(key: key);

  @override
  _HealthJouranlTabViewState createState() => _HealthJouranlTabViewState();
}

class _HealthJouranlTabViewState extends State<HealthJouranlTabView> {
  StreamingSharedPreferences preferences;
  int dailytarget = 0;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    StreamingSharedPreferences.instance.then((value) {
      if (this.mounted) {
        setState(() {
          preferences = value;
        });
      }
    });
    dailyTarget().then((value) {
      if (this.mounted) {
        setState(() {
          dailytarget = int.parse(value);
          prefs.setInt('daily_target', dailytarget);
          prefs.setInt('weekly_target', dailytarget * 7);
          prefs.setInt('monthly_target', dailytarget * daysInMonth(DateTime.now()));
        });
      }
    });
  }

  int daysInMonth(DateTime date) {
    var firstDayThisMonth = new DateTime(date.year, date.month, date.day);
    var firstDayNextMonth =
        new DateTime(firstDayThisMonth.year, firstDayThisMonth.month + 1, firstDayThisMonth.day);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  Future<String> dailyTarget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int dailyTarget = prefs.getInt('daily_target');
    if (dailyTarget == null || dailyTarget == 0) {
      var userData = prefs.get('data');
      preferences.setBool('maintain_weight', true);
      Map res = jsonDecode(userData);
      var height;
      DateTime birthDate;
      String datePattern = "MM/dd/yyyy";
      var dob = res['User']['dateOfBirth'].toString();
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
      var weight = res['User']['userInputWeightInKG'] ?? '0';
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // Container(
              //   height: 80,
              //   width: 100,
              //   color: Colors.green,
              // ),
              Container(
                // height: 20,
                height: MediaQuery.of(context).size.height / 22,
                // decoration: BoxDecoration(
                //   color: Colors.greenAccent,
                // ),
                // width: 120,
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Colors.tealAccent,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  // indicatorPadding: EdgeInsets.all(2.0),
                  // indicatorSize: TabBarIndicatorSize.,
                  labelColor: Colors.black,
                  labelStyle: TextStyle(fontSize: 16.0),
                  tabs: [
                    Tab(
                      text: 'Eaten',
                    ),
                    Tab(
                      text: 'Burned',
                    ),
                    // Tab(
                    //   text: 'Food Log',
                    // )
                  ],
                ),
              ),
              SizedBox(
                height: 80,
                child: TabBarView(children: [
                  // eaten starts
                  Center(
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 48,
                            width: 2,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.5),
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                                  child: Text(
                                    'Eaten',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
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
                                      width: 30,
                                      height: 30,
                                      child: Image.asset("assets/images/diet/eaten.png"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4, bottom: 3),
                                      child: preferences != null
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
                                                    fontSize: 16,
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
                                                fontSize: 16,
                                                color: FitnessAppTheme.darkerText,
                                              ),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4, bottom: 3),
                                      child: Text(
                                        'Cal',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
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
                    ),
                  ),
                  // eaten ends
                  // Burned starts
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 48,
                          width: 2,
                          decoration: BoxDecoration(
                            color: HexColor('#F56E98').withOpacity(0.5),
                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 0),
                              child: Text(
                                'Burned',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
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
                                  width: 30,
                                  height: 30,
                                  child: Image.asset("assets/images/diet/burned.png"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 3),
                                  child: preferences != null
                                      ? PreferenceBuilder<int>(
                                          preference:
                                              preferences.getInt('burnedCalorie', defaultValue: 0),
                                          builder: (BuildContext context, int burnedCounter) {
                                            return Text(
                                              '$burnedCounter',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: FitnessAppTheme.fontName,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
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
                                            fontSize: 16,
                                            color: FitnessAppTheme.darkerText,
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8, bottom: 3),
                                  child: Text(
                                    'Cal',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      letterSpacing: -0.2,
                                      color: FitnessAppTheme.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
