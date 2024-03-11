import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/views/achived_challenge.dart';
import 'package:ihl/health_challenge/widgets/custom_card.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../new_design/app/utils/appColors.dart';
import '../../new_design/presentation/controllers/healthchallenge/dynamicHealthChallengeController.dart';
import '../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../widgets/custom_listview_widget.dart';
import 'dynamic_enrolled_health_challenge.dart';

class DynamicHealthChallengesComponents extends StatefulWidget {
  DynamicHealthChallengesComponents({
    Key key,
    @required this.challengeCategory,
  }) : super(key: key);
  final String challengeCategory;
  @override
  State<DynamicHealthChallengesComponents> createState() =>
      _DynamicHealthChallengesComponentsState();
}

class _DynamicHealthChallengesComponentsState extends State<DynamicHealthChallengesComponents> {
  final DynamicHealthChallengeController _dynhealthChallengeController =
      Get.put(DynamicHealthChallengeController());

  @override
  void dispose() {
    Get.delete<DynamicHealthChallengesComponents>();
    // TODO: implement dispose
    super.dispose();
  }

  List challengeComponents = [];
  @override
  void initState() {//_fetchNewChallengeList
    _dynhealthChallengeController.getEnrolledCompletedList();
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
Get.to(DynamicHealthChallengeTypes(
            challengeCategory: widget.challengeCategory,
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
          Get.to(DynamicEnrolledChallengesListScreen(
            challengeCategory: widget.challengeCategory,
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
              challengeCategory:widget.challengeCategory
          ));
        }
      }
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
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
      content:GetBuilder<DynamicHealthChallengeController>(
        init: DynamicHealthChallengeController(),
        id: _dynhealthChallengeController.fetchId,
    builder: (_) {
    return Padding(
    padding: EdgeInsets.all(8.sp),
    child: SizedBox(
    height: 100.h,
    child: SingleChildScrollView(
    child: Column(
    children: challengeComponents
        .map((e) => _.listofChallenges.isNotEmpty&&e['title']=='New Health Challenges'?
    CustomCardForHealthchallenges(
        title: e['title'], imageUrl: e["imagePath"], onTap: e["voidcallback"]):(_.sortedEnrolledCompleted!=null&&_.sortedEnrolledCompleted.started.isNotEmpty&&_.sortedEnrolledCompleted.notStarted.isNotEmpty&&e['title']=='Active')?CustomCardForHealthchallenges(
        title: e['title'], imageUrl: e["imagePath"], onTap: e["voidcallback"]):    CustomCardForHealthchallenges(
        title: e['title'], imageUrl: e["imagePath"], onTap: e["voidcallback"]))
        .toList()),
    ),
    ),
    );
    })
    );
  }
}

class DynamicHealthChallengeTypes extends StatefulWidget {
  const DynamicHealthChallengeTypes({Key key, @required this.challengeCategory}) : super(key: key);
  final String challengeCategory;

  @override
  State<DynamicHealthChallengeTypes> createState() => _DynamicHealthChallengeTypesState();
}

class _DynamicHealthChallengeTypesState extends State<DynamicHealthChallengeTypes> {
  @override
  void dispose() {
    Get.delete<DynamicHealthChallengesComponents>();
    // TODO: implement dispose
    super.dispose();
  }

  List challengetypes = ['sdfgtyhu', 'sdfg'];
  @override
  void initState() {
    // challengetypes = [
    //   {
    //     'title': 'Step Challenge',
    //     'imagePath': 'assets/icons/steps.png',
    //     "voidcallback": () {
    //       Get.to(ListofChallenges(
    //         list: widget.list,
    //         challengeType: "Step Challenge",
    //       ));
    //     }
    //   },
    //   {
    //     'title': 'Water Challenge',
    //     'imagePath': 'assets/icons/exercise.png',
    //     "voidcallback": () {
    //       Get.to(ListofChallenges(
    //         list: widget.list,
    //         challengeType: "Other",
    //       ));
    //       // SharedPreferences prefs1 = await SharedPreferences.getInstance();
    //       // String userid = prefs1.getString("ihlUserId");
    //       // List<EnrolledChallenge> currentUserEnrolledChallenges =
    //       //     await ChallengeApi().listofUserEnrolledChallenges(userId: userid);
    //     }
    //   },
    // ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DynamicHealthChallengeController _dynhealthChallengeController =
        Get.put(DynamicHealthChallengeController());

    double width = MediaQuery.of(context).size.width;
    return CommonScreenForNavigation(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          title: Text(widget.challengeCategory, style: TextStyle(color: Colors.white)),
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
        content: SizedBox(
            width: 100.w,
            height: 100.h,
            child: GetBuilder<DynamicHealthChallengeController>(
                id: _dynhealthChallengeController.updateId,
                init: DynamicHealthChallengeController(),
                builder: (_builder) {
                  if (_builder.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                 else if(!_builder.isLoading && _builder.listofChallenges.isNotEmpty) {
                  return GetBuilder<DynamicHealthChallengeController>(
                      init: DynamicHealthChallengeController(),
                      id: _builder.fetchId,
                      builder: (_) {
                        return  ListView.builder(
                            itemCount: _builder.listofChallenges.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _builder.listofChallenges.length) {
                                return Center(
                                    child: _builder.isFetching
                                        ?  Center(child: CircularProgressIndicator())
                                        : const SizedBox.shrink());
                              }
                              return _builder.listofChallenges[index].challengeType!=widget.challengeCategory?SizedBox():PlaningGrid(
                                title: _builder.listofChallenges[index].challengeName,
                                challengeType: _builder.listofChallenges[index].challengeType,
                                groupOrIndividual: _builder.listofChallenges[index].challengeMode,
                                imageUrl: _builder.listofChallenges[index].challengeImgUrlThumbnail,
                                challangeID: _builder.listofChallenges[index].challengeId,
                              );
                            });
                      });
                }
                 return const Center(child: Text('No Challenge Available!!!'));})));
  }
}
