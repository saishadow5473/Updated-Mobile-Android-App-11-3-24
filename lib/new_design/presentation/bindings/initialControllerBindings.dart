import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ihl/Getx/controller/google_fit_controller.dart';
import 'package:ihl/Getx/controller/listOfChallengeContoller.dart';
import 'package:ihl/new_design/app/utils/localStorageKeys.dart';
import 'package:ihl/new_design/presentation/controllers/dashboardControllers/dashBoardContollers.dart';
import 'package:ihl/new_design/presentation/controllers/hpodControllers/hpodControllers.dart';
import 'package:ihl/new_design/presentation/controllers/vitalDetailsController/myVitalsController.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:ihl/views/screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../views/otherVitalController/otherVitalController.dart';
import '../controllers/dashboardControllers/upComingDetailsController.dart';
import '../controllers/healthJournalControllers/foodDetailController.dart';
import '../controllers/healthJournalControllers/getTodayLogController.dart';
import '../controllers/healthTipsController/healthTipsController.dart';
import '../controllers/splashScreenController/splash_screen_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    sharePref();
    localSotrage = GetStorage();
    gs = GetStorage();

    log('Google Fit ${localSotrage.read('fit')}');
    var logged = localSotrage.read(LSKeys.logged) ?? false;
    Get.put(SplashScreenController(), permanent: true).onInit();
  }

  sharePref() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var _fit = _prefs.getBool('fit');
    var _logged = _prefs.getBool(
          LSKeys.logged,
        ) ??
        false;

    if (_fit != null) {
      localSotrage.write('fit', _fit);
      localSotrage.write(LSKeys.logged, _logged);
      log('Google Fit ${localSotrage.read('fit')}');
    }
    if (_logged) {
      Get.put(() => VitalsContoller(), permanent: true);
      Get.put(() => FoodDetailController(), permanent: true);
      Get.put(() => ListChallengeController(), permanent: true);
      Get.put(() => MyVitalsController());
      Get.put(() => HealthRepository());
      Get.put(() => HpodControllers());
      Get.put(() => UpcomingDetailsController(), permanent: true);
      Get.put(() => HealthTipsController());
      Get.put(() => TodayLogController());
      Get.put(() => TabBarController());
    } else {
      localSotrage.erase();
    }
  }
}
