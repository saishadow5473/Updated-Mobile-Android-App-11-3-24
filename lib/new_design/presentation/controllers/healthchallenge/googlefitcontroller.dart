import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:ihl/new_design/app/services/health challenge/healthappservices.dart';
import 'package:ihl/new_design/presentation/controllers/dashboardControllers/upComingDetailsController.dart';

class GoogleFitController extends GetxController {
  final UpcomingDetailsController upComingDetailsController = Get.find();
  int steps = 0, duration = 0;
  double distance = 0.0;
  void updateGoogleFit(int milliseconds) async {
    DateTime _from = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    print('Last Updated $_from');
    DateTime _now = DateTime.now();
    DateTime _today = DateTime(_now.year, _now.month, _now.day);
    var healthData;
    try {
      healthData = await HealthServices.fetchDataFromLastUpdate(
        lastUpdate: milliseconds,
      );
    } catch (e) {
      print('Google Fit Error');
    }
    steps = 0;
    duration = 0;
    distance = 0;
    for (var data in healthData) {
      switch (data.type) {
        case HealthDataType.STEPS:
          if (Platform.isAndroid) {
            steps += (data.value as NumericHealthValue).numericValue.toInt();
          } else if (Platform.isIOS) {
            steps += (data.value as NumericHealthValue).numericValue.toInt();
          }
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
    if (duration < 0) {
      duration = 0;
    }
    log('Steps :$steps');
  }
}
