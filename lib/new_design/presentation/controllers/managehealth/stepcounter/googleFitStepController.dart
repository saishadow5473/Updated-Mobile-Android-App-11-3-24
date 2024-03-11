import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health/health.dart';
import '../../../../data/providers/network/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/providers/network/networks.dart';
import '../../../pages/spalshScreen/splashScreen.dart';

ValueNotifier<List<StepsData>> stepsListDateWise = ValueNotifier([]);
ValueNotifier<List<StepsDataHourly>> stepsListHourlyWise = ValueNotifier([]);
ValueNotifier<List<StepsData>> stepsListMonthlyWise = ValueNotifier([]);
// ValueNotifier<List<StepsDataHourly>> stepsListHourlyWiseBackWards = ValueNotifier([]);
// ValueNotifier<List<StepsDataHourly>> stepsListHourlyWiseForwards = ValueNotifier([]);
List<StepsDataHourly> stepsListHourlyWiseBackWards1 = [];
List<StepsDataHourly> stepsListHourlyWiseForwards1 = [];
List<StepsData> stepsListWeeklyWiseBackWards = [];
List<StepsData> stepsListWeeklyWiseForwards = [];
List<StepsData> stepsListMonthlyWiseBackWards = [];
List<StepsData> stepsListMonthlyWiseForwards = [];
ValueNotifier<int> stepsCount = ValueNotifier(0);
ValueNotifier<int> stepsCountw = ValueNotifier(0);
ValueNotifier<int> stepsCountM = ValueNotifier(0);
ValueNotifier<bool> showArrows = ValueNotifier(true);
ValueNotifier<bool> showShimmer = ValueNotifier(false);

class StepsDatawithSession {
  DateTime time;
  int steps;
  String session;

  StepsDatawithSession(this.time, this.steps, this.session);
}

class StepsData {
  final DateTime date;
  final int steps;

  StepsData(this.date, this.steps);
}

class StepsDataHourly {
  final int date;
  final int steps;
  final int activeTime;
  final DateTime timeStamp;
  StepsDataHourly(this.date, this.steps, this.activeTime, this.timeStamp);
}

class GoogleFitStepController extends SuperController {
  List<StepsData> stepsList = [];
  HealthFactory health = HealthFactory();
  List<HealthDataPoint> _healthData = [];
  SharedPreferences _prefs;

  Map<String, int> stepsBySession = {};
  RxBool fitConnected = false.obs;
  DateTime now = DateTime.now();
  RxBool popupshow = true.obs;
  final List<HealthDataType> androidtypes = [
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.MOVE_MINUTES
  ];
  final List<HealthDataType> iostypes = [
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.BODY_MASS_INDEX,
  ];
  RxInt todaySteps = 0.obs, todayDuration = 0.obs;
  RxDouble todayDistance = 0.0.obs, todayCalories = 0.0.obs;
  bool weeklyChartLoaded = true;
  DateTime _startDate, _endDate;

  Rx<PreviousActivityDetails> previousActivityImage = PreviousActivityDetails(
          caloriesBurned: '8122334.000',
          distanceCovered: '',
          trackMapImgUrl: '')
      .obs;
  bool showMap = false;
  String _getSessionLabel(int hour) {
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 18) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }

  void previousWeekChart() {
    _endDate = _startDate;
    _startDate = _startDate.subtract(const Duration(days: 6));
  }

  fetchPreviousActivity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object ihlUserId = prefs.get('ihlUserId');
    try {
      dynamic response = await dio.get(
          "${API.iHLUrl}/stepwalker/steptracker_fetch_log",
          queryParameters: {
            'ihl_user_id': ihlUserId,
          });
      if (response.statusCode == 200) {
        if (response.data['status'] == 'fail') {
          showMap = false;
        } else {
          showMap = true;
          try {
            print(response.data['old_responce'].runtimeType);
            var data = response.data['old_responce'];
            print(data.runtimeType);
            if (data.isNotEmpty) {
              previousActivityImage.value = PreviousActivityDetails(
                  caloriesBurned: data['calories_burned'],
                  distanceCovered: data['distance_covered'],
                  trackMapImgUrl: data['track_map_img_url']);
            } else {
              var data = response.data['new_responce'];
              previousActivityImage.value = PreviousActivityDetails(
                  caloriesBurned: data['calories_burned'],
                  distanceCovered: data['distance_covered'],
                  trackMapImgUrl: data['track_map_img_url']);
            }
          } catch (e) {
            print(e);
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchLastSevenDaysSteps() async {
    stepsList = [];
    weeklyChartLoaded = true;
    update(['chartdata']);
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day - 6);
    DateTime endDate = now;

    List<HealthDataType> types = [HealthDataType.STEPS];
    List<HealthDataPoint> healthDataList =
        await health.getHealthDataFromTypes(startDate, endDate, types);

    Map<DateTime, int> stepsMap = {};

    // Initialize the stepsMap with 0 steps for each day in the last 7 days
    for (DateTime date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      stepsMap[date] = 0;
    }

    // Populate the stepsMap with recorded steps for the available days
    for (HealthDataPoint dataPoint in healthDataList) {
      DateTime dataPointDate = DateTime(
        dataPoint.dateFrom.year,
        dataPoint.dateFrom.month,
        dataPoint.dateFrom.day,
      );

      if (stepsMap.containsKey(dataPointDate)) {
        stepsMap[dataPointDate] +=
            (dataPoint.value as NumericHealthValue).numericValue.toInt();
      }
    }

    // Create the StepsData list using the stepsMap
    stepsList = stepsMap.entries.map((MapEntry<DateTime, int> entry) {
      return StepsData(entry.key, entry.value);
    }).toList();

    // Add missing days with 0 steps to the stepsList
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      if (!stepsMap.containsKey(currentDate)) {
        stepsList.add(StepsData(currentDate, 0));
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Sort the stepsList by date
    stepsList.sort((StepsData a, StepsData b) => a.date.compareTo(b.date));
    weeklyChartLoaded = false;
    update(['chartdata']);
  }

  Future<void> fetchDataMonthly(DateTime startDate, String bias) async {
    showArrows.value = false;
    List<HealthDataType> types = [HealthDataType.STEPS];
    List<HealthDataPoint> healthDataList;
    if (bias == 'b') {
      startDate = DateTime(startDate.year, startDate.month - 1, startDate.day);
      // endOfWeek = startOfWeek.add(Duration(days: 7));
      //  endDate = endDate.subtract(Duration(days: 7));
    }
    if (bias == 'f') {
      startDate = DateTime(startDate.year, startDate.month + 1, startDate.day);
      // endDate = endDate.add(Duration(days: 7));
    }
    DateTime startOfMonth = DateTime(startDate.year, startDate.month, 1);

    // Get the end of the month (last day of the current month)
    DateTime endOfMonth = DateTime(startDate.year, startDate.month + 1, 0);

    try {
      healthDataList =
          await health.getHealthDataFromTypes(startOfMonth, endOfMonth, types);
    } catch (e) {
      print(e);
    }
    Map<DateTime, int> stepsMap = {};

    // Initialize the stepsMap with 0 steps for each day in the last 7 days
    for (DateTime date = startOfMonth;
        date.isBefore(endOfMonth) || date.isAtSameMomentAs(endOfMonth);
        date = date.add(const Duration(days: 1))) {
      stepsMap[date] = 0;
    }

    // Populate the stepsMap with recorded steps for the available days
    for (HealthDataPoint dataPoint in healthDataList) {
      DateTime dataPointDate = DateTime(dataPoint.dateFrom.year,
          dataPoint.dateFrom.month, dataPoint.dateFrom.day);

      if (stepsMap.containsKey(dataPointDate)) {
        stepsMap[dataPointDate] +=
            (dataPoint.value as NumericHealthValue).numericValue.toInt();
      }
    }

    if (bias == 'b') {
      List<StepsData> t = [];

      for (MapEntry<DateTime, int> e in stepsMap.entries) {
        t.add(StepsData(e.key, e.value));
      }
      stepsListMonthlyWiseBackWards = t;
    }
    if (bias == 'f') {
      List<StepsData> t = [];

      for (MapEntry<DateTime, int> e in stepsMap.entries) {
        t.add(StepsData(e.key, e.value));
      }
      stepsListMonthlyWiseForwards = t;
    }
    if (bias == '') {
      List<StepsData> t = [];

      for (MapEntry<DateTime, int> e in stepsMap.entries) {
        t.add(StepsData(e.key, e.value));
      }
      stepsListMonthlyWise.value = t;

      // stepsListDateWise.value.sort((a, b) => a.date.compareTo(b.date));

      num a = 0;
      for (StepsData element in stepsListMonthlyWise.value) {
        a += element.steps;
      }
      stepsCountM.value = a;
    }
    showArrows.value = true;
  }

  Future<void> fetchDataBasedOnDate(
      DateTime startDate, DateTime endDate, String bias) async {
    showArrows.value = false;
    List<HealthDataType> types = [HealthDataType.STEPS];
    List<HealthDataPoint> healthDataList;
    if (bias == 'b') {
      startDate = startDate.subtract(const Duration(days: 7));
      // endOfWeek = startOfWeek.add(Duration(days: 7));
      endDate = endDate.subtract(const Duration(days: 7));
    }
    if (bias == 'f') {
      startDate = startDate.add(const Duration(days: 7));
      endDate = endDate.add(const Duration(days: 7));
    }

    try {
      healthDataList =
          await health.getHealthDataFromTypes(startDate, endDate, types);
    } catch (e) {
      print(e);
    }
    Map<DateTime, int> stepsMap = {};

    // Initialize the stepsMap with 0 steps for each day in the last 7 days
    for (DateTime date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      stepsMap[date] = 0;
    }

    // Populate the stepsMap with recorded steps for the available days
    for (HealthDataPoint dataPoint in healthDataList) {
      DateTime dataPointDate = DateTime(dataPoint.dateFrom.year,
          dataPoint.dateFrom.month, dataPoint.dateFrom.day);

      if (stepsMap.containsKey(dataPointDate)) {
        stepsMap[dataPointDate] +=
            (dataPoint.value as NumericHealthValue).numericValue.toInt();
      }
    }

    if (bias == 'b') {
      List<StepsData> t = [];

      for (MapEntry<DateTime, int> e in stepsMap.entries) {
        t.add(StepsData(e.key, e.value));
      }
      stepsListWeeklyWiseBackWards = t;
    }
    if (bias == 'f') {
      List<StepsData> t = [];

      for (MapEntry<DateTime, int> e in stepsMap.entries) {
        t.add(StepsData(e.key, e.value));
      }
      stepsListWeeklyWiseForwards = t;
    }
    if (bias == '') {
      List<StepsData> t = [];

      for (MapEntry<DateTime, int> e in stepsMap.entries) {
        t.add(StepsData(e.key, e.value));
      }
      stepsListDateWise.value = t;

      // stepsListDateWise.value.sort((a, b) => a.date.compareTo(b.date));

      num a = 0;
      for (StepsData element in stepsListDateWise.value) {
        a += element.steps;
      }
      stepsCountw.value = a;
    }
    showArrows.value = true;
    // DateTime currentDate = startDate;
    // while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
    //   if (!stepsMap.containsKey(currentDate)) {
    //     stepsListDateWise.value.add(StepsData(currentDate, 0));
    //   }
    //   currentDate = currentDate.add(Duration(days: 1));
    // }
    // stepsListDateWise.notifyListeners();
    // print(stepsListDateWise.value);
    // print(stepsListDateWise.value);
  }

  Future<void> fetchHourlyBasis(
      DateTime startDate, DateTime endDate, String bias) async {
    showArrows.value = false;
    //  showArrows.notifyListeners();
    // Initialize the stepsMap with 0 steps for each hour in the last 24 hours
    Map<int, int> stepsMap = {};
    Map<int, dynamic> minutesMap = {};
    List<HealthDataType> types = [HealthDataType.STEPS];
    List<HealthDataPoint> healthDataList;
    if (bias == 'b') {
      DateTime previousDate = startDate.subtract(const Duration(days: 1));
      startDate =
          DateTime(previousDate.year, previousDate.month, previousDate.day);
      endDate = DateTime(
          previousDate.year, previousDate.month, previousDate.day, 23, 59, 59);
    }
    if (bias == 'f') {
      DateTime previousDate = startDate.add(const Duration(days: 1));
      startDate =
          DateTime(previousDate.year, previousDate.month, previousDate.day);
      endDate = DateTime(
          previousDate.year, previousDate.month, previousDate.day, 23, 59, 59);
    }
    try {
      healthDataList =
          await health.getHealthDataFromTypes(startDate, endDate, types);
    } catch (e) {
      print(e);
    }
    print(healthDataList);
    DateTime currentHour = DateTime.now()
        .subtract(const Duration(hours: 24))
        .subtract(Duration(
            minutes: DateTime.now().minute, seconds: DateTime.now().second));

    while (currentHour.isBefore(DateTime.now().subtract(Duration(
        minutes: DateTime.now().minute, seconds: DateTime.now().second)))) {
      stepsMap[currentHour.hour] = 0;
      minutesMap[currentHour.hour] = 0;
      currentHour = currentHour.add(const Duration(hours: 1));
    }

// Populate the stepsMap with recorded steps for the available days
    for (HealthDataPoint dataPoint in healthDataList) {
      DateTime dataPointHour = DateTime(
          dataPoint.dateFrom.year,
          dataPoint.dateFrom.month,
          dataPoint.dateFrom.day,
          dataPoint.dateFrom.hour);

      if (stepsMap.containsKey(dataPointHour.hour)) {
        print('${dataPoint.dateFrom} see the acaa ${dataPoint.dateTo}');
        Duration difference = dataPoint.dateFrom.difference(dataPoint.dateTo);

        // Get the difference in minutes
        int differenceInMinutes = difference.inMinutes.abs();
        stepsMap[dataPointHour.hour] +=
            (dataPoint.value as NumericHealthValue).numericValue.toInt();

        minutesMap[dataPointHour.hour] =
            minutesMap[dataPointHour.hour].toInt() +
                differenceInMinutes.toInt();
        print('');
      }
    }
    if (bias == 'b') {
      List<StepsDataHourly> t = [];
      // stepsListHourlyWiseBackWards.value.clear();
      // stepsListHourlyWiseBackWards1.clear();
      // stepsMap.entries.forEach((e) {
      //   stepsListHourlyWiseBackWards.value.add(StepsDataHourly(e.key, e.value));
      // });
      // stepsMap.entries.forEach((e) {
      //   t.add(StepsDataHourly(e.key, e.value));
      // });
      stepsMap.forEach((int key, int value) {
        if (minutesMap.containsKey(key)) {
          t.add(StepsDataHourly(key, value, minutesMap[key], startDate));
        }
      });
      stepsListHourlyWiseBackWards1 = t;
    } else if (bias == 'f') {
      List<StepsDataHourly> t = [];
      // stepsListHourlyWiseForwards.value.clear();
      // stepsListHourlyWiseForwards1.clear();

      // stepsMap.entries.forEach((e) {
      //   stepsListHourlyWiseForwards.value.add(StepsDataHourly(e.key, e.value));
      // });
      // stepsMap.entries.forEach((e) {
      //   t.add(StepsDataHourly(e.key, e.value));
      // });
      stepsMap.forEach((int key, int value) {
        if (minutesMap.containsKey(key)) {
          t.add(StepsDataHourly(key, value, minutesMap[key], startDate));
        }
      });
      stepsListHourlyWiseForwards1 = t;
    } else if (bias == '') {
      stepsListHourlyWise.value.clear();
      // stepsMap.entries.forEach((e) {
      //   stepsListHourlyWise.value.add(StepsDataHourly(e.key, e.value));
      // });
      stepsMap.forEach((int key, int value) {
        if (minutesMap.containsKey(key)) {
          stepsListHourlyWise.value
              .add(StepsDataHourly(key, value, minutesMap[key], startDate));
        }
      });
    }

    if (bias == 'b') {
      //stepsListHourlyWiseBackWards.value.sort((a, b) => a.date.compareTo(b.date));
      stepsListHourlyWiseBackWards1.sort(
          (StepsDataHourly a, StepsDataHourly b) => a.date.compareTo(b.date));
      // stepsListHourlyWiseBackWards.notifyListeners();
    } else if (bias == 'f') {
      //stepsListHourlyWiseForwards.value.sort((a, b) => a.date.compareTo(b.date));

      stepsListHourlyWiseForwards1.sort(
          (StepsDataHourly a, StepsDataHourly b) => a.date.compareTo(b.date));
      // stepsListHourlyWiseForwards.notifyListeners();
    } else if (bias == '') {
      stepsListHourlyWise.value.sort(
          (StepsDataHourly a, StepsDataHourly b) => a.date.compareTo(b.date));
      //  stepsListHourlyWise.notifyListeners();
      num a = 0;
      for (StepsDataHourly element in stepsListHourlyWise.value) {
        a += element.steps;
      }
      stepsCount.value = a;
      //   stepsCount.notifyListeners();
    }

    showArrows.value = true;
    // showArrows.notifyListeners();
  }

  Future<bool> authenticate() async {
    final List<HealthDataType> androidtypes = [
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.STEPS,
      HealthDataType.DISTANCE_DELTA,
      HealthDataType.MOVE_MINUTES
    ];
    final List<HealthDataType> iostypes = [
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.STEPS,
      HealthDataType.DISTANCE_WALKING_RUNNING,
      HealthDataType.EXERCISE_TIME
    ];
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    await googleSignIn.signOut();
    bool requested = await health.requestAuthorization(
        Platform.isAndroid ? androidtypes : iostypes,
        permissions: [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ]).then((bool value) async {
      print(value);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setBool('fit', value);
      fitConnected.value = value;
      return value;
    });
    return requested;
  }

  Future getSteps() async {
    int temp = 0;
    int duration = 0;
    double distance = 0.0;
    double calories = 0.0;

    final DateTime now = DateTime.now();
    final DateTime midnight = DateTime(now.year, now.month, now.day);
    int yftt = await health.getTotalStepsInInterval(midnight, now);
    print(yftt.toString());
    _healthData = await health.getHealthDataFromTypes(
        midnight, now, Platform.isAndroid ? androidtypes : iostypes);
    print(_healthData.length);
    for (HealthDataPoint data in _healthData) {
      print(data);
      switch (data.type) {
        case HealthDataType.STEPS:
          // DateTime dateFrom = data.dateFrom;
          // String session = _getSessionLabel(dateFrom.hour);
          // if (stepsBySession.containsKey(session)) {
          //   stepsBySession[session] += (data.value as NumericHealthValue).numericValue.toInt();
          // } else {
          //   stepsBySession[session] = (data.value as NumericHealthValue).numericValue.toInt();
          // }
          print(data.value);
          temp += (data.value as NumericHealthValue).numericValue.toInt();
          print(temp.toString());

          break;
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          calories +=
              (data.value as NumericHealthValue).numericValue.toDouble();
          break;

        case HealthDataType.DISTANCE_DELTA:
          distance +=
              (data.value as NumericHealthValue).numericValue.toDouble();
          break;
        case HealthDataType.DISTANCE_WALKING_RUNNING:
          distance +=
              (data.value as NumericHealthValue).numericValue.toDouble();
          break;
        case HealthDataType.MOVE_MINUTES:
          duration += (data.value as NumericHealthValue).numericValue.toInt();
          break;
        case HealthDataType.EXERCISE_TIME:
          duration += (data.value as NumericHealthValue).numericValue.toInt();
          break;
        case HealthDataType.AUDIOGRAM:
          // TODO: Handle this case.
          break;
        case HealthDataType.BASAL_ENERGY_BURNED:
          // TODO: Handle this case.
          break;
        case HealthDataType.BLOOD_GLUCOSE:
          // TODO: Handle this case.
          break;
        case HealthDataType.BLOOD_OXYGEN:
          // TODO: Handle this case.
          break;
        case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
          // TODO: Handle this case.
          break;
        case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
          // TODO: Handle this case.
          break;
        case HealthDataType.BODY_FAT_PERCENTAGE:
          // TODO: Handle this case.
          break;
        case HealthDataType.BODY_MASS_INDEX:
          // TODO: Handle this case.
          break;
        case HealthDataType.BODY_TEMPERATURE:
          // TODO: Handle this case.
          break;
        case HealthDataType.DIETARY_CARBS_CONSUMED:
          // TODO: Handle this case.
          break;
        case HealthDataType.DIETARY_ENERGY_CONSUMED:
          // TODO: Handle this case.
          break;
        case HealthDataType.DIETARY_FATS_CONSUMED:
          // TODO: Handle this case.
          break;
        case HealthDataType.DIETARY_PROTEIN_CONSUMED:
          // TODO: Handle this case.
          break;
        case HealthDataType.FORCED_EXPIRATORY_VOLUME:
          // TODO: Handle this case.
          break;
        case HealthDataType.HEART_RATE:
          // TODO: Handle this case.
          break;
        case HealthDataType.HEART_RATE_VARIABILITY_SDNN:
          // TODO: Handle this case.
          break;
        case HealthDataType.HEIGHT:
          // TODO: Handle this case.
          break;
        case HealthDataType.RESTING_HEART_RATE:
          // TODO: Handle this case.
          break;
        case HealthDataType.WAIST_CIRCUMFERENCE:
          // TODO: Handle this case.
          break;
        case HealthDataType.WALKING_HEART_RATE:
          // TODO: Handle this case.
          break;
        case HealthDataType.WEIGHT:
          // TODO: Handle this case.
          break;
        case HealthDataType.FLIGHTS_CLIMBED:
          // TODO: Handle this case.
          break;
        case HealthDataType.MINDFULNESS:
          // TODO: Handle this case.
          break;
        case HealthDataType.WATER:
          // TODO: Handle this case.
          break;
        case HealthDataType.SLEEP_IN_BED:
          // TODO: Handle this case.
          break;
        case HealthDataType.SLEEP_ASLEEP:
          // TODO: Handle this case.
          break;
        case HealthDataType.SLEEP_AWAKE:
          // TODO: Handle this case.
          break;
        case HealthDataType.WORKOUT:
          // TODO: Handle this case.
          break;
        case HealthDataType.HEADACHE_NOT_PRESENT:
          // TODO: Handle this case.
          break;
        case HealthDataType.HEADACHE_MILD:
          // TODO: Handle this case.
          break;
        case HealthDataType.HEADACHE_MODERATE:
          // TODO: Handle this case.
          break;
        case HealthDataType.HEADACHE_SEVERE:
          // TODO: Handle this case.
          break;
        case HealthDataType.HEADACHE_UNSPECIFIED:
          // TODO: Handle this case.
          break;
        case HealthDataType.HIGH_HEART_RATE_EVENT:
          // TODO: Handle this case.
          break;
        case HealthDataType.LOW_HEART_RATE_EVENT:
          // TODO: Handle this case.
          break;
        case HealthDataType.IRREGULAR_HEART_RATE_EVENT:
          // TODO: Handle this case.
          break;
        case HealthDataType.ELECTRODERMAL_ACTIVITY:
          // TODO: Handle this case.
          break;
        case HealthDataType.ELECTROCARDIOGRAM:
          // TODO: Handle this case.
          break;
      }
    }
    print(stepsBySession);
    todaySteps.value = temp;
    todayCalories.value = calories;
    todayDistance.value = distance;
    todayDuration.value = duration;
  }

  final List<StepsData> _stepsDataList = [];
  Future<void> _fetchStepsData() async {
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day);
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    List<HealthDataType> types = [HealthDataType.STEPS];
    List<HealthDataPoint> healthDataList =
        await health.getHealthDataFromTypes(startDate, endDate, types);

    List<StepsDatawithSession> stepsDataList = [];

    for (HealthDataPoint dataPoint in healthDataList) {
      DateTime dateFrom = dataPoint.dateFrom;
      int hour = dateFrom.hour;
      int minute = dateFrom.minute;
      DateTime intervalStart = DateTime(
        dateFrom.year,
        dateFrom.month,
        dateFrom.day,
        hour,
      );
      DateTime intervalEnd = DateTime(
        dateFrom.year,
        dateFrom.month,
        dateFrom.day,
        hour,
        59,
        59,
      );

      String session = _getSessionLabel(hour);
      StepsDatawithSession stepsDatas;

      if (stepsDataList.isNotEmpty &&
          stepsDataList.last.time.isAfter(intervalStart)) {
        stepsDatas = stepsDataList.last;
        stepsDatas.steps +=
            (dataPoint.value as NumericHealthValue).numericValue.toInt();
      } else {
        stepsDatas = StepsDatawithSession(
            intervalStart,
            (dataPoint.value as NumericHealthValue).numericValue.toInt(),
            session);
        stepsDataList.add(stepsDatas);
      }

      stepsDatas.session = session;
    }
  }

  Future getStepsFromGoogleFit() async {
    weeklyChartLoaded = true;
    update(['chartdata']);
    try {
      if (fitConnected.isFalse) {
        await authenticate().then((bool value) async {
          getSteps();
        });
      } else {
        getSteps();
      }
    } catch (e) {
      _prefs.setBool('fit', false);
      localSotrage.write('fit', false);

      fitConnected.value = false;
    }
  }

  @override
  void onInit() async {
    _prefs = await SharedPreferences.getInstance();
    fetchPreviousActivity();
    fitConnected.value = _prefs.getBool('fit') ?? false;
    if (fitConnected.isTrue) {
      getStepsFromGoogleFit();
      fetchLastSevenDaysSteps();
      try {
        DateTime timestamp = DateTime.now();

        DateTime startOfDay =
            DateTime(timestamp.year, timestamp.month, timestamp.day);
        DateTime timestamp1 = DateTime.now();

        DateTime endOfDay = DateTime(
            timestamp1.year, timestamp1.month, timestamp1.day, 23, 59, 59);

        fetchHourlyBasis(startOfDay, endOfDay, '');

        fetchHourlyBasis(startOfDay, endOfDay, 'b');
        fetchHourlyBasis(startOfDay, endOfDay, 'f');
      } catch (e) {
        print(e);
      }

      // DateTime startOfWeek = currentweekDayFinder();

      // DateTime endOfWeek =
      //     currentweekDayFinder().add(Duration(days: 7)).subtract(Duration(minutes: 1));

      // fetchDataBasedOnDate(
      //     DateTime.parse(startOfWeek.toString()), DateTime.parse(endOfWeek.toString()), '');
      // fetchDataBasedOnDate(
      //     DateTime.parse(startOfWeek.toString()), DateTime.parse(endOfWeek.toString()), 'b');
      // fetchDataBasedOnDate(
      //     DateTime.parse(startOfWeek.toString()), DateTime.parse(endOfWeek.toString()), 'f');
//

      // DateTime monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
      // fetchDataMonthly(monthStart, '');
      // fetchDataMonthly(monthStart, 'b');
      // fetchDataMonthly(monthStart, 'f');
      _fetchStepsData();
    }
    super.onInit();
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    fetchPreviousActivity();
    if (fitConnected.isTrue) {
      getStepsFromGoogleFit();
      fetchLastSevenDaysSteps();
      try {
        DateTime timestamp = DateTime.now();

        DateTime startOfDay =
            DateTime(timestamp.year, timestamp.month, timestamp.day);
        DateTime timestamp1 = DateTime.now();

        DateTime endOfDay = DateTime(
            timestamp1.year, timestamp1.month, timestamp1.day, 23, 59, 59);

        // fetchDataBasedOnDate(startOfDay, endOfDay);
        fetchHourlyBasis(startOfDay, endOfDay, '');
        // fetchHourlyBasis(startOfDay, endOfDay,'f');
        fetchHourlyBasis(startOfDay, endOfDay, 'b');
        fetchHourlyBasis(startOfDay, endOfDay, 'f');
      } catch (e) {
        print(e);
      }

      //   fetchDataBasedOnDate(startOfDay, endOfDay);
      _fetchStepsData();
    }

    // fetchWeeklyData(startDate: _startDate, endDate: _endDate);
  }

  DateTime currentweekDayFinder() {
    final DateTime now1 = DateTime.now();
    final DateTime now = DateTime(now1.year, now1.month, now1.day);
    // log("Current Day => " + DateFormat('EEEE').format(now));
    if (now.weekday == DateTime.sunday) {
      return now;
    }
    return DateTime(now.year, now.month, now.day - now.weekday);
  }
}

class PreviousActivityDetails {
  String distanceCovered;
  String caloriesBurned;
  String trackMapImgUrl;
  PreviousActivityDetails(
      {this.distanceCovered, this.caloriesBurned, this.trackMapImgUrl});
}
