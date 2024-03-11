import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class askIhlControllers extends GetxController {
  RxBool dataLoaded = false.obs;

  updateCurrentState({@required bool val}) {
    dataLoaded.value = val;
  }
}
