import 'dart:io';

import 'package:health/health.dart';

class HealthService {
  static HealthFactory health = HealthFactory();

  static Future<List<HealthDataPoint>> fetchDataFromLastUpdate({int milliseconds}) async {
    List<HealthDataPoint> _healthData = [];
    final types = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];
    if (Platform.isIOS) {
      types.add(HealthDataType.DISTANCE_WALKING_RUNNING);
      types.add(HealthDataType.EXERCISE_TIME);
    } else {
      types.add(HealthDataType.DISTANCE_DELTA);
      types.add(HealthDataType.MOVE_MINUTES);
    }
    bool requested = await health.requestAuthorization(types, permissions: [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ]);
    if (requested) {
      _healthData = await health.getHealthDataFromTypes(
          DateTime.fromMillisecondsSinceEpoch(milliseconds), DateTime.now(), types);
      print(DateTime.fromMillisecondsSinceEpoch(milliseconds));
    }
  }

  static Future<List<HealthDataPoint>> fetchDaySteps() async {
    List<HealthDataPoint> _healthData = [];
    final now = DateTime.now();

    final midnight = DateTime(now.year, now.month, now.day);

    final types = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];
    if (Platform.isIOS) {
      types.add(HealthDataType.DISTANCE_WALKING_RUNNING);
      types.add(HealthDataType.EXERCISE_TIME);
    } else {
      types.add(HealthDataType.DISTANCE_DELTA);
      types.add(HealthDataType.MOVE_MINUTES);
    }
    bool requested = await health.requestAuthorization(types, permissions: [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ]);
    if (requested) {
      _healthData = await health.getHealthDataFromTypes(midnight, DateTime.now(), types);
    }
  }

  static Future<List<HealthDataPoint>> fetchDataFromChallengDate({
    int milliseconds,
  }) async {
    /// Give a HealthDataType with the given identifier

    final types = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];
    if (Platform.isIOS) {
      types.add(HealthDataType.DISTANCE_WALKING_RUNNING);
      types.add(HealthDataType.EXERCISE_TIME);
    } else {
      types.add(HealthDataType.DISTANCE_DELTA);
      types.add(HealthDataType.MOVE_MINUTES);
    }

    /// Give a permissions for the given HealthDataTypes
    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    /// current time
    final now = DateTime.now();

    /// to store HealthDataPoint
    List<HealthDataPoint> healthData = [];

    /// request google Authorization when the app is opened for the first time
    bool requested = await health.requestAuthorization(types, permissions: permissions);

    ///check if the request is successful
    if (requested) {
      /// fetch the data from the health store
      healthData = await health.getHealthDataFromTypes(
          DateTime.fromMillisecondsSinceEpoch(milliseconds), now, types);
    } else {
      /// if the request is not successful
      throw AuthenticationRequired();
    }
    return healthData;
  }

  static Future<List<HealthDataPoint>> fetchHealthData({int createdTime, bool requested}) async {
    /// Give a HealthDataType with the given identifier

    final types = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];
    if (Platform.isIOS) {
      types.add(HealthDataType.DISTANCE_WALKING_RUNNING);
      types.add(HealthDataType.EXERCISE_TIME);
    } else {
      types.add(HealthDataType.DISTANCE_DELTA);
      types.add(HealthDataType.MOVE_MINUTES);
    }

    /// Give a permissions for the given HealthDataTypes
    // final permissions = [
    //   HealthDataAccess.READ,
    //   HealthDataAccess.READ,
    //   HealthDataAccess.READ,
    //   HealthDataAccess.READ,
    // ];

    /// current time
    final now = DateTime.now();

    /// Give a yesterday's time
    final yesterday = now.subtract(const Duration(days: 1));
    final lastMidnight = DateTime(now.year, now.month, now.day);
    //  print('midnight time and date is $lastMidnight');

    /// to store HealthDataPoint
    List<HealthDataPoint> healthData = [];

    /// request google Authorization when the app is opened for the first time
    if (Platform.isIOS) {
      requested = await health.requestAuthorization(types);
    }

    ///check if the request is successful
    if (requested) {
      final midnight = DateTime(now.year, now.month, now.day);
      final DateTime minutes = DateTime.fromMillisecondsSinceEpoch(createdTime);
      if (minutes.isBefore(midnight)) {
        healthData = await health.getHealthDataFromTypes(midnight, now, types);
      } else {
        healthData = await health.getHealthDataFromTypes(minutes, now, types);
      }
      print(healthData);

      /// fetch the data from the health store
    } else {
      /// if the request is not successful
      throw AuthenticationRequired();
    }
    return healthData;
  }
static Future<List<HealthDataPoint>> caloriesHealthData(DateTime startTime,DateTime endTime)async{
    final types = [
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];
    final healthData = await health.getHealthDataFromTypes(startTime, endTime, types);
    return healthData;
  }

  static Future<List<HealthDataPoint>> lastUpdatedHealthData(
      {int createdTime, bool requested}) async {
    /// Give a HealthDataType with the given identifier

    final types = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];
    if (Platform.isIOS) {
      types.add(HealthDataType.DISTANCE_WALKING_RUNNING);
      types.add(HealthDataType.EXERCISE_TIME);
    } else {
      types.add(HealthDataType.DISTANCE_DELTA);
      types.add(HealthDataType.MOVE_MINUTES);
    }

    /// Give a permissions for the given HealthDataTypes
    // final permissions = [
    //   HealthDataAccess.READ,
    //   HealthDataAccess.READ,
    //   HealthDataAccess.READ,
    //   HealthDataAccess.READ,
    // ];

    /// current time
    final now = DateTime.now();

    /// to store HealthDataPoint
    List<HealthDataPoint> healthData = [];

    /// request google Authorization when the app is opened for the first time
    // bool requested = await health.requestAuthorization(types, permissions: permissions);
    if (Platform.isIOS) requested = await health.requestAuthorization(types);

    ///check if the request is successful
    if (requested) {
      final DateTime minutes = DateTime.fromMillisecondsSinceEpoch(createdTime);
      print(minutes);
      healthData = await health.getHealthDataFromTypes(minutes, now, types);
      return healthData;

      /// fetch the data from the health store
    } else {
      /// if the request is not successful
      throw AuthenticationRequired();
    }
  }
}

class AuthenticationRequired extends Error {}
