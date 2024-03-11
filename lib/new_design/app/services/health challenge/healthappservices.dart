import 'dart:io';

import 'package:health/health.dart';
import 'package:ihl/new_design/app/utils/localStorageKeys.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';

class HealthServices {
  static HealthFactory health = HealthFactory();
  static Future<List<HealthDataPoint>> fetchDataFromLastUpdate({int lastUpdate}) async {
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
          DateTime.fromMillisecondsSinceEpoch(lastUpdate), DateTime.now(), types);
    }
    return _healthData;
  }
}
