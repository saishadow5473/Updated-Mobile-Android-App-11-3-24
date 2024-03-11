import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:ihl/views/cardiovascular_views/hpod_locations.dart';
import 'package:ihl/views/otherVitalController/otherVitalController.dart';

import '../cardio_dashboard/views/cardio_dashboard_new.dart';
import '../health_challenge/views/health_challenges_types.dart';
import '../utils/app_colors.dart';
import '../views/crisp/ask_us_screen.dart';
import '../views/gamification/stepsScreen.dart';
import '../views/goal_settings/edit_goal_screen.dart';
import '../views/news_letter/news_letter_screen.dart';
import '../views/other_vitals.dart';
import '../views/tips/tips_screen.dart';
import '../new_design/presentation/pages/manageHealthscreens/healthJournalScreens/createNewMealScreen.dart';

class NewDashBoardNavigation {
  static List socialNavigation = [
    {
      'text': 'Challenges',
      'icon': FontAwesomeIcons.personRunning,
      'iconSize': 40.0,
      'onTap': () => Get.to(HealthChallengesComponents(
            list: ["global", "Global"],
          )),
      'color': Colors.deepOrange,
    },
    {
      'text': 'Health Tips',
      'icon': FontAwesomeIcons.circlePlus,
      'iconSize': 40.0,
      'onTap': () => Get.to(TipsScreen()),
      'color': AppColors.bookApp,
    },
    {
      'text': 'News Letter',
      'icon': FontAwesomeIcons.newspaper,
      'iconSize': 40.0,
      'onTap': () => Get.to(NewsLetterScreen()),
      'color': Colors.brown,
    },
    {
      'text': 'Ask IHL',
      'icon': FontAwesomeIcons.facebookMessenger,
      'iconSize': 40.0,
      'onTap': () => Get.to(AskUsScreen()),
      'color': Colors.deepPurpleAccent,
    },
    {
      'text': 'Hpod Stations',
      'icon': FontAwesomeIcons.hardDrive,
      'iconSize': 40.0,
      'onTap': () => //Get.to(HpodLocations())
          Get.to(HpodLocations(
            isGeneric: true,
          )),
      'color': Colors.tealAccent
    },
  ];
  static List socialNavigationIOS = [
    {
      'text': 'Challenges',
      'icon': FontAwesomeIcons.personRunning,
      'iconSize': 40.0,
      'onTap': () => Get.to(HealthChallengesComponents(
            list: ["global", "Global"],
          )),
      'color': Colors.deepOrange,
    },
    {
      'text': 'Health Tips',
      'icon': FontAwesomeIcons.circlePlus,
      'iconSize': 40.0,
      'onTap': () => Get.to(TipsScreen()),
      'color': AppColors.bookApp,
    },
    {
      'text': 'News Letter',
      'icon': FontAwesomeIcons.newspaper,
      'iconSize': 40.0,
      'onTap': () => Get.to(NewsLetterScreen()),
      'color': Colors.brown,
    },
    {
      'text': 'Ask IHL',
      'icon': FontAwesomeIcons.facebookMessenger,
      'iconSize': 40.0,
      'onTap': () => Get.to(AskUsScreen()),
      'color': Colors.deepPurpleAccent,
    },
    // {
    //   'text': 'Hpod Stations',
    //   'icon': FontAwesomeIcons.hardDrive,
    //   'iconSize': 40.0,
    //   'onTap': () => //Get.to(HpodLocations())
    //       Get.to(HpodLocations(
    //         isGeneric: true,
    //       )),
    //   'color': Colors.tealAccent
    // },
  ];
  static List healthProgram = [
    {
      'text': 'Heart Health',
      'icon': FontAwesomeIcons.heartCirclePlus,
      'iconSize': 40.0,
      'onTap': () {
        Get.put(VitalsContoller);
        Get.to(CardioDashboardNew(
          cond: true,
          tabView: false,
        ));
      },
      'color': Colors.pink,
    },
    {
      'text': 'Weight Management',
      'icon': FontAwesomeIcons.bullseye,
      'iconSize': 40.0,
      'onTap': () {
        Get.to(
          ViewGoalSettingScreen(
            goalChangeNavigation: false,
          ),
        );
      },
      'color': Colors.amber,
    },
    {
      'text': 'Diabetics Health',
      'icon': FontAwesomeIcons.temperatureHigh,
      'iconSize': 40.0,
      'onTap': () {
        print('button pressed');
        // const snackBar = SnackBar(
        //   content: Text('Yay! A SnackBar!'),
        // );

        // ScaffoldMessenger.of(Get.context).showSnackBar(snackBar);
        Get.showSnackbar(
          GetSnackBar(
            title: "Coming Soon!",
            message: 'This feature is not available right now',
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      },
      'color': Colors.grey,
    },
  ];
  static List manageHealth = [
    {
      'text': 'Vitals',
      'icon': FontAwesomeIcons.heartPulse,
      'iconSize': 40.0,
      'onTap': () {
        // Get.find<VitalsContoller>().vitalData();
        // vitalsOnHome = [
        //   'bmi',
        //   'weightKG',
        //   // 'heightMeters',
        //   'temperature',
        //   'pulseBpm',
        //   'fatRatio',
        //   'ECGBpm',
        //   'bp',
        //   'spo2',
        //   'protien',
        //   'extra_cellular_water',
        //   'intra_cellular_water',
        //   'mineral',
        //   'skeletal_muscle_mass',
        //   'body_fat_mass',
        //   'body_cell_mass',
        //   'waist_hip_ratio',
        //   'percent_body_fat',
        //   'waist_height_ratio',
        //   'visceral_fat',
        //   'basal_metabolic_rate',
        //   'bone_mineral_content',
        // ];
        // Get.to(VitalTab(
        //   isShowAsMainScreen: false,
        // ));
        Get.to(VitalTab(
          isShowAsMainScreen: false,
        ));
      },
      'color': AppColors.bookApp,
    },
    {
      'text': 'Calorie Tracker',
      'icon': FontAwesomeIcons.kitMedical,
      'iconSize': 40.0,
      'onTap': () => Get.to(NewMeal()),
      // 'onTap': () => Get.to(DietJournal(
      //       Screen: 'manageHealth',
      //     )),
      'color': Colors.brown,
    },
    {
      'text': 'Step Tracker',
      'icon': FontAwesomeIcons.personWalking,
      'iconSize': 40.0,
      'onTap': () => Get.to(StepsScreen()),
      'color': Colors.redAccent,
    },
  ];
}
