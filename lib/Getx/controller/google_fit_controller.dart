import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:ihl/views/google_fit/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../health_challenge/controllers/challenge_api.dart';
import '../../health_challenge/models/challenge_detail.dart';
import '../../health_challenge/models/enrolled_challenge.dart';
import '../../new_design/data/functions/healthChallengeFunctions.dart';

class HealthRepository extends GetxController {
  var healthPoint = <HealthDataPoint>[].obs;
  int index = 0;
  var error = "".obs;
  var burnedCalories = 0.0;
  var isLoading = true;
  String updateStep = 'updateStepId';
  String widgetUpdate = 'widgetupdateId';
  var daysteps = 0.0, daydistance, dayduration;
  var daycal;
  String caloryUpdate = 'CaloriesUpdate';
  var steps = 0, distance = 0.0, duration = 0;
  bool started = true;
  var cal = 0.0;
  void updateIndex(v) {
    index = v;
    update(['dialogupdate']);
  }

  Duration calculateDurationFromSteps(int steps) {
    // Assuming an average walking speed of 3 miles per hour (4.8 kilometers per hour)
    double averageSpeedKPH = 4.8;
    double distanceInKilometers = steps / 2000.0 * 1.60934; // Convert steps to kilometers

    // Calculate duration in hours
    double hours = distanceInKilometers / averageSpeedKPH;

    // Convert hours to seconds and create a Duration object
    int seconds = (hours * 3600).toInt();
    return Duration(seconds: seconds);
  }

//TODO calculate calories from steps,km and meter
  void caloriesCalculationFromChallengeStart(String enrollChallengeid,
      {@required bool fromChallengeChange}) async {
    burnedCalories = 0;
    if (fromChallengeChange) update([caloryUpdate]);
    var enrollChallenge = await ChallengeApi().getEnrollDetail(enrollChallengeid);
    ChallengeDetail _challengeDetail =
        await ChallengeApi().challengeDetail(challengeId: enrollChallenge.challengeId);
    double _distance;
    var _weight;
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var userData = _prefs.get('data');
    Map res = jsonDecode(userData);
    var weight = _prefs.get('userLatestWeight').toString();
    if (weight == 'null' || weight == null) {
      weight = res['User']['userInputWeightInKG'].toString();
    }
    _weight = double.tryParse(weight).toStringAsFixed(2);
    DistanceUnit _unit;
    if (_challengeDetail.challengeUnit == 'steps') {
      _unit = DistanceUnit.Steps;
    } else if (_challengeDetail.challengeUnit == 's') {
      _unit = DistanceUnit.Steps;
    } else if (_challengeDetail.challengeUnit == 'km') {
      _unit = DistanceUnit.Kilometers;
    } else {
      _unit = DistanceUnit.Meters;
    }
    _weight = double.parse(_weight);
    if (_challengeDetail.challengeMode == "individual") {
      _distance = enrollChallenge.userAchieved > enrollChallenge.target.toDouble()
          ? enrollChallenge.target.toDouble()
          : enrollChallenge.userAchieved;
    } else {
      _distance = enrollChallenge.groupAchieved > enrollChallenge.target.toDouble()
          ? enrollChallenge.target.toDouble()
          : enrollChallenge.groupAchieved;
    }
    burnedCalories = HealthChallengeFunctions.calculateCaloriesBurned(_distance, _weight, _unit);
    update([caloryUpdate]);
  }

  void fetchHealthDataFromLastUpdateTime({int milliseconds, bool requested}) async {
    try {
      DateTime _from = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      print('Last Updated $_from');
      DateTime _now = DateTime.now();
      final healthData = await HealthService.lastUpdatedHealthData(
          createdTime: milliseconds, requested: requested);
      steps = 0;
      duration = 0;
      distance = 0;
      for (var data in healthData) {
        switch (data.type) {
          case HealthDataType.STEPS:
            if (Platform.isAndroid) {
              if (data.dateFrom.isAfter(_from)) {
                steps += (data.value as NumericHealthValue).numericValue.toInt();
              }
            } else if (Platform.isIOS) {
              if (data.dateFrom.isAfter(_from)) {
                steps += (data.value as NumericHealthValue).numericValue.toInt();
              }
            }
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            cal += (data.value as NumericHealthValue).numericValue.toDouble();
            break;

          case HealthDataType.DISTANCE_DELTA:
            distance += (data.value as NumericHealthValue).numericValue.toDouble();
            break;
          case HealthDataType.DISTANCE_WALKING_RUNNING:
            distance += (data.value as NumericHealthValue).numericValue.toDouble();
            break;
        }
      }
      duration = DateTime.now().difference(_from).inMinutes;
      if (steps < 0) {
        duration = 0;
      }
      isLoading = false;
      started = false;
      // if (steps > 0.0) update();
      print('Total Steps $steps');
      print('Total Distance $distance');
      error.value = "";
    } catch (e) {
      print('catching error ===========');
      error.value = e.toString();
    }
  }

  void fetchDayHealthData({int milliseconds, bool requested}) async {
    try {
      isLoading = true;
      final healthData =
          await HealthService.fetchHealthData(createdTime: milliseconds, requested: requested);
      healthPoint.addAll(healthData);

      for (var data in healthData) {
        switch (data.type) {
          case HealthDataType.STEPS:
            daysteps += (data.value as NumericHealthValue).numericValue.toInt();
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            daycal += data.value;
            break;
          case HealthDataType.MOVE_MINUTES:
            dayduration += data.value;
            break;
          case HealthDataType.DISTANCE_DELTA:
            daydistance += data.value;
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
          case HealthDataType.DISTANCE_WALKING_RUNNING:
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
          case HealthDataType.EXERCISE_TIME:
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
        }
      }
      isLoading = false;
      update([
        'individualachieved',
      ]);
      print('Total Day Steps $daysteps');
    } catch (e) {
      print('catching error ===========');
      error.value = e.toString();
    }
  }
}
