import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/controllers/challenge_api.dart';
import 'package:ihl/health_challenge/models/challengemodel.dart';
import 'package:ihl/health_challenge/models/listchallenge.dart';
import 'package:ihl/health_challenge/views/achived_challenge.dart';
import 'package:ihl/health_challenge/views/enrolled_challenges_list_screen.dart';
import 'package:ihl/health_challenge/views/listofchallenges.dart';
import 'package:ihl/health_challenge/widgets/custom_card.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Getx/controller/listOfChallengeContoller.dart';
import '../../new_design/presentation/controllers/dashboardControllers/upComingDetailsController.dart';
import '../../widgets/offline_widget.dart';
import '../models/enrolled_challenge.dart';

class HealthChallengesComponents extends StatefulWidget {
  HealthChallengesComponents({
    Key key,
    @required this.list,
  }) : super(key: key);
  final List list;
  @override
  State<HealthChallengesComponents> createState() => _HealthChallengesComponentsState();
}

class _HealthChallengesComponentsState extends State<HealthChallengesComponents> {
  List challengeComponents = [];
  @override
  void initState() {
    challengeComponents = [
      {
        'title': 'New Health Challenges',
        'imagePath': 'assets/icons/challenges1.png',
        "voidcallback": () async {
          // ListChallenge _listChallenge = ListChallenge(
          //     challenge_mode: '',
          //     pagination_start: 0,
          //     pagination_end: 1000,
          //     email: Get.find<ListChallengeController>().email,
          //     affiliation_list: widget.list);
          // SharedPreferences prefs1 = await SharedPreferences.getInstance();
          // String userid = prefs1.getString("ihlUserId");
          // List<Challenge> _listofChallenges =
          //     await ChallengeApi().listOfChallenges(challenge: _listChallenge);
          // _listofChallenges.removeWhere((element) => element.challengeStatus != 'active');
          // List<EnrolledChallenge> enrolledChallenge =
          //     await ChallengeApi().listofUserEnrolledChallenges(userId: userid);
          // if (enrolledChallenge.isNotEmpty) {
          //   for (var i in enrolledChallenge) {
          //     _listofChallenges.removeWhere((element) => element.challengeId == i.challengeId);
          //   }
          // }
          // List types = [];
          // for (int i = 0; i < _listofChallenges.length; i++) {
          //   types.add(_listofChallenges[i].challengeType);
          // }
          // types = types.toSet().toList();
          // if (types.length > 1) {
          //   Get.to(HealthChallengeTypes(
          //     list: widget.list,
          //   ));
          // } else {
          Get.to(HealthChallengeTypes(
            list: widget.list,
          ));
          // Get.to(ListofChallenges(list: widget.list));
          // }
          // Get.to(ListofChallenges(
          //   list: widget.list,
          // ));
        }
      },
      {
        'title': 'Active',
        'imagePath': 'assets/icons/challenges2.png',
        "voidcallback": () async {
          SharedPreferences prefs1 = await SharedPreferences.getInstance();
          String userid = prefs1.getString("ihlUserId");
          Get.to(EnrolledChallengesListScreen(
            uid: userid,
          ));
        }
      },
      {
        'title': 'Participated',
        'imagePath': 'assets/icons/challenges3.png',
        "voidcallback": () async {
          SharedPreferences prefs1 = await SharedPreferences.getInstance();
          String userid = prefs1.getString("ihlUserId");
          Get.to(AchievedChallengesListScreen(
            uid: userid,
          ));
        }
      }
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: ScrollessBasicPageUI(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text("Health Challenges", style: TextStyle(color: Colors.white)),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          child: SingleChildScrollView(
            child: Column(
                children: challengeComponents
                    .map((e) => CustomCardForHealthchallenges(
                        title: e['title'], imageUrl: e["imagePath"], onTap: e["voidcallback"]))
                    .toList()),
          ),
        ),
      ),
    );
  }
}

class HealthChallengeTypes extends StatefulWidget {
  const HealthChallengeTypes({Key key, @required this.list}) : super(key: key);
  final List list;

  @override
  State<HealthChallengeTypes> createState() => _HealthChallengeTypesState();
}

class _HealthChallengeTypesState extends State<HealthChallengeTypes> {
  List challengetypes = [];
  @override
  void initState() {
    challengetypes = [
      {
        'title': 'Step Challenge',
        'imagePath': 'assets/icons/steps.png',
        "voidcallback": () {
          Get.to(ListofChallenges(
            list: widget.list,
            challengeType: "Step Challenge",
          ));
        }
      },
      // {
      //   'title': 'Other Challenges',
      //   'imagePath': 'assets/icons/exercise.png',
      //   "voidcallback": () {
      //     Get.to(ListofChallenges(
      //       list: widget.list,
      //       challengeType: "Other",
      //     ));
      //     // SharedPreferences prefs1 = await SharedPreferences.getInstance();
      //     // String userid = prefs1.getString("ihlUserId");
      //     // List<EnrolledChallenge> currentUserEnrolledChallenges =
      //     //     await ChallengeApi().listofUserEnrolledChallenges(userId: userid);
      //   }
      // },
      // {
      //   'title': 'Water Challenge',
      //   'imagePath': 'assets/icons/exercise.png',
      //   "voidcallback": () {
      //     Get.to(ListofChallenges(
      //       list: widget.list,
      //       challengeType: "Other",
      //     ));
      //     // SharedPreferences prefs1 = await SharedPreferences.getInstance();
      //     // String userid = prefs1.getString("ihlUserId");
      //     // List<EnrolledChallenge> currentUserEnrolledChallenges =
      //     //     await ChallengeApi().listofUserEnrolledChallenges(userId: userid);
      //   }
      // },
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: ScrollessBasicPageUI(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text("Health Challenges Types", style: TextStyle(color: Colors.white)),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          child: SingleChildScrollView(
            child: Column(
                children: challengetypes
                    .map((e) => CustomCardForHealthchallenges(
                        title: e['title'], imageUrl: e["imagePath"], onTap: e["voidcallback"]))
                    .toList()),
          ),
        ),
      ),
    );
  }
}
