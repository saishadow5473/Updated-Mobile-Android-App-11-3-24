import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/app/config/permission_config.dart';
import 'package:ihl/new_design/app/services/health%20challenge/update_challenge_services.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../health_challenge/controllers/challenge_api.dart';
import '../../../app/utils/appColors.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../../data/model/retriveUpcomingDetails/upcomingDetailsModel.dart';
import '../../../data/providers/network/apis/dashboardApi/retriveUpcommingDetails.dart';
import '../../Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../healthchallenge/googlefitcontroller.dart';

class UpcomingDetailsController extends SuperController {
  bool loading = false, buttonLoading = false;
  EnrolledChallenge selectedEnrolledChallenge;
  String challengeWidgetUpdateId = 'ChallengeWidgetUpdateId', progressUpdateId = 'progressUpdateId';
  SharedPreferences prefs;
  String affi;
  bool _progressLoading = false;
  get progressLoading => _progressLoading;
  @override
  void onDetached() {}

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    // TODO: implement onClose
    super.onClose();
  }

  // Mandatory
  @override
  void onInactive() {}

  // Mandatory
  @override
  void onPaused() {}

  // Mandatory
  @override
  void onResumed() async {
    CheckUpcomingDataIsLoaded.showShimmer.value = true;
    // Check if GoogleFit is installed
    bool _googleFitInstalled = localSotrage.read('fit') ?? false;
    // If GoogleFit is installed and there is any enrolChallengeList
    if (_googleFitInstalled && upComingDetails.enrolChallengeList.length > 0) {
      // Set loading to true

      var _storedEnroll = SpUtil.getObjectList('enrollList') ?? [];
      if (_storedEnroll.length < 1) {
        loading = true;
      }
      // Clear the enrolChallengeList
      // Update the user_enroll_challenge and user_upcoming_detils
      update(['user_enroll_challenge', 'user_upcoming_detils']);

      EnrolledChallenge enrolledChallenge;
      // If the selectedEnrolledChallenge is null, set the enrolledChallenge to the first element in the upComingDetails.enrolChallengeList
      if (selectedEnrolledChallenge == null)
        enrolledChallenge = upComingDetails.enrolChallengeList.first;
      // Else, set the enrolledChallenge to the selectedEnrolledChallenge
      else
        enrolledChallenge = selectedEnrolledChallenge;
      // Get the GoogleFitController
      final GoogleFitController _googleFitController = Get.put(GoogleFitController());
      var _enroll;
      try {
        _enroll = await ChallengeApi().getEnrollDetail(enrolledChallenge.enrollmentId);
        enrolledChallenge.last_updated = _enroll.last_updated;
      } catch (e) {
        debugPrint('enrol error');
      }
      // Update the GoogleFit with the last updated time
      await _googleFitController.updateGoogleFit(int.parse(
        enrolledChallenge.last_updated ?? DateTime.now().millisecondsSinceEpoch,
      ));
      // Update the challenge with the GoogleFitController
      await UpdateChallengeServices.updateChallenge(
          enrolledChallenge: enrolledChallenge, googleFitController: _googleFitController);
      // Retrieve the upcoming details
      upComingDetails =
          await RetriveDetials().upcomingDetails(affilist: [affi], fromChallenge: false);
      // Set loading to false
      if (_storedEnroll.length < 1) {
        loading = false;
      }
      // Update the user_enroll_challenge and user_upcoming_detils
      update(['user_enroll_challenge', 'user_upcoming_detils', challengeWidgetUpdateId]);
      // Else, if GoogleFit is not installed and the current route is either LandingPage, Home, or OnGoingChallenge
    } else if (upComingDetails.enrolChallengeList.isNotEmpty &&
        !_googleFitInstalled &&
        (Get.currentRoute == "/LandingPage" ||
            Get.currentRoute == "/Home" ||
            Get.currentRoute == "/OnGoingChallenge")) {
      // Set _showGoogleFit to false
      bool _showGoogleFit = false;
      // For each element in the upComingDetails.enrolChallengeList
      upComingDetails.enrolChallengeList.forEach((element) {
        // If the selectedFitnessApp is google fit, set _showGoogleFit to true
        if (element.selectedFitnessApp == "google fit") {
          _showGoogleFit = true;
        }
      });
      // If _showGoogleFit is true, request for GoogleFitPermission
      if (_showGoogleFit) {
        await PermissionHandlerUtil.googleFitPermission();
      }
    }
    // Set CheckUpcomingDataIsLoaded.showShimmer.value to false
    CheckUpcomingDataIsLoaded.showShimmer.value = false;
  }

  @override
  void onInit() async {
    // var _storedEnroll = SpUtil.getObjectList('enrollList') ?? [];
    // if (_storedEnroll.length > 0) {
    //   upComingDetails.enrolChallengeList =
    //       _storedEnroll.map((x) => EnrolledChallenge.fromJson(x)).toList();
    // }
    prefs = await SharedPreferences.getInstance();
    // Get the saved SSO flow affiliation
    String ss = prefs.getString("sso_flow_affiliation");
    // If there is a saved SSO flow affiliation, decode it and set the affiliation
    if (ss != null) {
      Map<String, dynamic> exsitingAffi = jsonDecode(ss);
      UpdatingColorsBasedOnAffiliations.ssoAffiliation = {
        "affiliation_unique_name": exsitingAffi["affiliation_unique_name"]
      };
    }
    // If the affiliation is null or the affiliation unique name is null, set it to "Global"
    affi = (UpdatingColorsBasedOnAffiliations.ssoAffiliation == null ||
            UpdatingColorsBasedOnAffiliations.ssoAffiliation['affiliation_unique_name'] == null)
        ? "Global"
        : UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"];
    // Purpose of the code observe the app lifecycle
    WidgetsBinding.instance.addObserver(this);
    // Retrive the dashboard enroll list

    await updateUpcomingDetails(fromChallenge: false);

    super.onInit();
  }

  UpcomingDetails upComingDetails = UpcomingDetails();
  Color objectColor = AppColors.primaryAccentColor;
  Future updateChangedChallenge({@required bool fromChallenge}) async {
    fromChallenge = fromChallenge ?? false;
    _progressLoading = true;
    update([progressUpdateId]);
    final GoogleFitController _googleFitController = Get.put(GoogleFitController());
    await UpdateChallengeServices.updateChallenge(
        enrolledChallenge: selectedEnrolledChallenge, googleFitController: _googleFitController);
    upComingDetails =
        await RetriveDetials().upcomingDetails(affilist: [affi], fromChallenge: fromChallenge);

    update([challengeWidgetUpdateId]);
  }

  Future updateUpcomingDetails({@required bool fromChallenge}) async {
    prefs = await SharedPreferences.getInstance();
    String ss = prefs.getString("sso_flow_affiliation");
    if (ss != null) {
      Map<String, dynamic> exsitingAffi = jsonDecode(ss);
      UpdatingColorsBasedOnAffiliations.ssoAffiliation = {
        "affiliation_unique_name": exsitingAffi["affiliation_unique_name"]
      };
    }
    affi = (UpdatingColorsBasedOnAffiliations.ssoAffiliation == null ||
            UpdatingColorsBasedOnAffiliations.ssoAffiliation['affiliation_unique_name'] == null)
        ? "Global"
        : UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"];
    CheckUpcomingDataIsLoaded.showShimmer.value = true;
    // CheckUpcomingDataIsLoaded().showShimmer.notifyListeners();
    objectColor = AppColors.primaryAccentColor;

    upComingDetails =
        await RetriveDetials().upcomingDetails(affilist: [affi], fromChallenge: fromChallenge);
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    update(['user_enroll_challenge', 'user_upcoming_detils']);

    bool _googleFitInstalled = _prefs.getBool('fit') ?? false;
    if (_googleFitInstalled && upComingDetails.enrolChallengeList.length > 0) {
      EnrolledChallenge enrolledChallenge;
      if (selectedEnrolledChallenge == null) {
        enrolledChallenge = upComingDetails.enrolChallengeList[0];
      } else {
        enrolledChallenge = selectedEnrolledChallenge;
      }

      final GoogleFitController _googleFitController = Get.put(GoogleFitController());
      //pop-up restricted only for home ,affiliation and dashboard screen
      var _storedEnroll = SpUtil.getObjectList('enrollList') ?? [];
      if (_storedEnroll.length < 1) {
        loading = false;
      }
      update([challengeWidgetUpdateId]);
      await UpdateChallengeServices.updateChallenge(
          enrolledChallenge: enrolledChallenge, googleFitController: _googleFitController);
      upComingDetails =
          await RetriveDetials().upcomingDetails(affilist: [affi], fromChallenge: fromChallenge);
      update([challengeWidgetUpdateId]);
    } else if (upComingDetails.enrolChallengeList.isNotEmpty &&
        !_googleFitInstalled &&
        (Get.currentRoute == "/LandingPage" ||
            Get.currentRoute == "/Home" ||
            Get.currentRoute == "/OnGoingChallenge")) {
      bool _showGoogleFit = false;
      upComingDetails.enrolChallengeList.forEach((element) {
        if (element.selectedFitnessApp == "google fit") {
          _showGoogleFit = true;
        }
      });
      if (_showGoogleFit) {
        bool _gFit = await PermissionHandlerUtil.googleFitPermission();
        if (_gFit) {
          await updateUpcomingDetails(fromChallenge: false);
        }
      }
      loading = false;
      update([challengeWidgetUpdateId]);
    } else {
      loading = false;
      update([challengeWidgetUpdateId]);
    }
    localSotrage.write("updateCalled", "update");

    // CheckUpcomingDataIsLoaded.showShimmer.notifyListeners();
  }

  updatingvalues() async {
    upComingDetails =
        await RetriveDetials().upcomingDetails(affilist: [affi], fromChallenge: false);
    localSotrage.write("updateCalled", "update");
    update(['user_upcoming_detils']);
  }

  updatingColors(String uniqueName) {
    switch (uniqueName) {
      case "ihl_care":
        objectColor = AppColors.primaryAccentColor;
        break;
      case "dev_testing":
        objectColor = AppColors.primaryAccentColor;
        break;
      case "persistent":
        objectColor = const Color(0XFFFD630C);
        break;
      default:
        objectColor = AppColors.primaryAccentColor;
    }
    update(["user_upcoming_detils"]);
    // update();
    return objectColor;
  }

  static getPlatformDatas() async {
    Map res = await RetriveDetials().getPlatformDatas();

    if (res['consult_type'] != null) {
      if ((res['consult_type'] is List) || res['consult_type'].isNotEmpty) {
        return res['consult_type'][1];
      }
    } else {
      return [];
    }
  }
}

class CheckUpcomingDataIsLoaded {
  static ValueNotifier<bool> showShimmer = ValueNotifier(false);
}
