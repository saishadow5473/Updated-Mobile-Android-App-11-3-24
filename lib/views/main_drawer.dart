import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/health_challenge/views/health_challenges_types.dart';
import 'package:ihl/main.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:ihl/notification_controller.dart';
import 'package:ihl/repositories/new_dashboard_navigation.dart';
import 'package:ihl/tabs/re_designed_home_screen.dart';
import 'package:ihl/tabs/tips.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/about_screen.dart';
import 'package:ihl/views/affiliation/affiliations.dart';
import 'package:ihl/views/cardiovascular_views/cardio_dashboard.dart';
import 'package:ihl/views/crisp/ask_us_screen.dart';
import 'package:ihl/views/newScreens/dashboard_navigation.dart';

// import 'package:ihl/views/googleSign/google_sign_int 'package:ihl/views/home_screen.dart';
import 'package:ihl/views/news_letter/news_letter_screen.dart';
import 'package:ihl/views/qrScanner/qr_scanner_screen.dart';
import 'package:ihl/views/splash_screen.dart';
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:ihl/views/tips/tips_screen.dart';
import 'package:ihl/widgets/profileScreen/photo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../cardio_dashboard/views/cardio_dashboard_new.dart';
import 'cardiovascular_views/hpod_locations.dart';
import 'dietJournal/dietJournal.dart';
import 'gamification/stepsScreen.dart';
import 'googleSign/google_sign_in_screen.dart';

// ignore: must_be_immutable
class MainDrawer extends StatefulWidget {
  bool open;
  Function openDrawer;
  Function closeDrawer;
  String name;
  String score;
  PageController pageController;

  MainDrawer({
    this.name,
    this.pageController,
    this.openDrawer,
    this.closeDrawer,
    this.score,
    this.open,
  });

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  http.Client _client = http.Client(); //3gb
  var userAffiliate;
  String afNo1, afNo2, afNo3, afNo4, afNo5, afNo6, afNo7, afNo8, afNo9;
  bool afNo1bool,
      afNo2bool,
      afNo3bool,
      afNo4bool,
      afNo5bool,
      afNo6bool,
      afNo7bool,
      afNo8bool,
      afNo9bool;
  String afUnique1,
      afUnique2,
      afUnique3,
      afUnique4,
      afUnique5,
      afUnique6,
      afUnique7,
      afUnique8,
      afUnique9;
  bool _logedSso = false;

  bool q;
  bool isDVisible;

  bool isTVisible;

  bool isPVisible;

  bool isGVisible;

  bool isRVisible;

  ValueNotifier<bool> isGroupExpandedOnline = ValueNotifier<bool>(false);
  ValueNotifier<bool> isGroupExpandedHealth = ValueNotifier<bool>(false);

  List companies = [];

  void showAlert(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.all(0.0),
              content: Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
                decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [Colors.lightBlue.shade300, Colors.blue.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // SharedPreferences prefs = await SharedPreferences.getInstance();
                        // prefs.setBool("firstTime", false);
                        Get.back();
                      },
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Stack(
                      children: [
                        Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.width / 1.8,
                            width: MediaQuery.of(context).size.width / 1.8,
                            child: Image.asset(
                              "assets/images/IHL_QR.png",
                              height: MediaQuery.of(context).size.width / 2.4,
                              width: MediaQuery.of(context).size.width / 2.4,
                            )),
                        // Image.asset(
                        //   "assets/images/badgeParticle.png",
                        //   height: MediaQuery.of(context).size.width / 1.8,
                        //   width: MediaQuery.of(context).size.width / 1.8,
                        // ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "> Select the vitals from Hpod. \n> Proceed by tapping on the Start Button.\n> Choose QR Code login option.\n> Scan the QR.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool("firstTime", false);
                        Get.back();
                        Get.to(QRScannerScreen());
                      },
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(250),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  void _initSp() async {
    await SpUtil.getInstance();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userData);
    data = data == null || data == '' ? '{"User":{}}' : data;
    var _prefValue = prefs.get(
      SPKeys.is_sso,
    );
    _logedSso = _prefValue == 'true' ? true : false;

    Map res = jsonDecode(data);

    afNo1 ??= "empty";
    afNo2 ??= "empty";
    afNo3 ??= "empty";
    afNo4 ??= "empty";
    afNo5 ??= "empty";
    afNo6 ??= "empty";
    afNo7 ??= "empty";
    afNo8 ??= "empty";
    afNo9 ??= "empty";

    userAffiliate = res['User']['user_affiliate'];
    // userAffiliate = null;
    if (userAffiliate == null) {
      userAffiliate = [];
    } else {
      userAffiliate.removeWhere((k, v) => v["affilate_unique_name"] == "");
    }
    if (userAffiliate != null && userAffiliate.length > 0) {
      if (userAffiliate.containsKey("af_no1")) {
        afNo1 = userAffiliate['af_no1']['affilate_name'] ?? "empty";
        afUnique1 = userAffiliate['af_no1']['affilate_unique_name'] ?? "empty";
        afNo1bool = userAffiliate['af_no1']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no2")) {
        afNo2 = userAffiliate['af_no2']['affilate_name'] ?? "empty";
        afUnique2 = userAffiliate['af_no2']['affilate_unique_name'] ?? "empty";
        afNo2bool = userAffiliate['af_no2']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no3")) {
        afNo3 = userAffiliate['af_no3']['affilate_name'] ?? "empty";
        afUnique3 = userAffiliate['af_no3']['affilate_unique_name'] ?? "empty";
        afNo3bool = userAffiliate['af_no3']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no4")) {
        afNo4 = userAffiliate['af_no4']['affilate_name'] ?? "empty";
        afUnique4 = userAffiliate['af_no4']['affilate_unique_name'] ?? "empty";
        afNo4bool = userAffiliate['af_no4']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no5")) {
        afNo5 = userAffiliate['af_no5']['affilate_name'] ?? "empty";
        afUnique5 = userAffiliate['af_no5']['affilate_unique_name'] ?? "empty";
        afNo5bool = userAffiliate['af_no5']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no6")) {
        afNo6 = userAffiliate['af_no6']['affilate_name'] ?? "empty";
        afUnique6 = userAffiliate['af_no6']['affilate_unique_name'] ?? "empty";
        afNo6bool = userAffiliate['af_no6']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no7")) {
        afNo7 = userAffiliate['af_no7']['affilate_name'] ?? "empty";
        afUnique7 = userAffiliate['af_no7']['affilate_unique_name'] ?? "empty";
        afNo7bool = userAffiliate['af_no7']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no8")) {
        afNo8 = userAffiliate['af_no8']['affilate_name'] ?? "empty";
        afUnique8 = userAffiliate['af_no8']['affilate_unique_name'] ?? "empty";
        afNo8bool = userAffiliate['af_no8']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no9")) {
        afNo9 = userAffiliate['af_no9']['affilate_name'] ?? "empty";
        afUnique9 = userAffiliate['af_no9']['affilate_unique_name'] ?? "empty";
        afNo9bool = userAffiliate['af_no9']['is_sso'] ?? false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initSp();
  }

  List affUniqueNameList = [];
  bool logOutLoading = true;

  Future<void> _showNotification() async {
    // const AndroidNotificationDetails androidPlatformChannelSpecifics =
    //     AndroidNotificationDetails(
    //   'your channel id',
    //   'your channel name',
    //   channelDescription: 'your channel description',
    //   importance: Importance.max,
    //   priority: Priority.high,
    //   ticker: 'ticker',
    // );
    // const NotificationDetails platformChannelSpecifics =
    //     NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'plain title', 'plain body', bill_progress,
        payload: 'item x');
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    q = SpUtil.getBool('allAns');
    widget.name ??= 'Guest';
    widget.score ??= 'N/A';
    widget.score = widget.score == '0' ? 'N/A' : widget.score;

    return Container(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              gradient:
                  LinearGradient(begin: Alignment.bottomRight, end: Alignment.topLeft, colors: [
                AppColors.buttonBackgroundColor,
                AppColors.primaryAccentColor,
              ], stops: [
                0,
                0.5
              ]),
            ),
            child: ListView(children: <Widget>[
              Visibility(
                visible: false,
                child: GestureDetector(
                    onTap: () {
                      _showNotification();
                    },
                    child: Text('dfghjcvbnvgbnm')),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    /* Row(
                      children: [
                        DrawerProfilePhoto(
                          update: widget.open,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            (q == true)
                                ? Text(
                                    'IHL Score: ' + widget.score,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.left,
                                  )
                                : InkWell(
                                    onTap: () {
                                      _survey(context);
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          'IHL Score: ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Icon(
                                          Icons.info,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.white,
                indent: 10,
                endIndent: 60,
              ),
              SizedBox(height: 20),*/
                    ProfilePhoto(
                      update: widget.open,
                    ),
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    (q == true)
                        ? Text(
                            'IHL Score: ' + widget.score,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              _survey(context);
                            },
                            child: Row(
                              children: [
                                Text(
                                  'IHL Score: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Icon(
                                  Icons.info,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
              // new ListTile(
              //     leading: Icon(
              //       Icons.dashboard,
              //       color: Colors.white,
              //     ),
              //     title: Text(
              //       'Home',
              //       style: TextStyle(
              //           fontSize: 18,
              //           color: Colors.white,
              //           fontWeight: FontWeight.w500),
              //     ),
              //     onTap: () {
              //       widget.closeDrawer();
              //       widget.pageController.animateToPage(0,
              //           duration: Duration(milliseconds: 300),
              //           curve: Curves.bounceIn);
              //     }),
              Visibility(
                visible: userAffiliate != null &&
                        (afNo1bool == _logedSso ||
                            afNo2bool == _logedSso ||
                            afNo3bool == _logedSso ||
                            afNo4bool == _logedSso ||
                            afNo5bool == _logedSso ||
                            afNo6bool == _logedSso ||
                            afNo7bool == _logedSso ||
                            afNo8bool == _logedSso ||
                            afNo9bool == _logedSso)
                    ? true
                    : false,
                child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.building,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Member Services',
                      style: TextStyle(
                          fontSize: ScUtil().setSp(16.0),
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                      // style: TextStyle(
                      //     fontSize: ScUtil().setSp(16.0),
                      //     color: Colors.white,
                      //     fontWeight: FontWeight.w500),
                    ),
                    key: Key('affiliationsDrawer'),
                    onTap: () {
                      widget.closeDrawer();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AffiliationsDashboard(
                                    afNo1: afNo1 == ""
                                        ? "empty"
                                        : afNo1.replaceAll('IHL Care', 'India Health Link'),
                                    afUnique1: afUnique1 == "" ? "empty" : afUnique1,
                                    afNo1bool: _logedSso ? true : _logedSso == afNo1bool,
                                    afNo2: afNo2 == ""
                                        ? "empty"
                                        : afNo2.replaceAll('IHL Care', 'India Health Link'),
                                    afUnique2: afUnique2 == "" ? "empty" : afUnique2,
                                    afNo2bool: _logedSso ? true : _logedSso == afNo2bool,
                                    afNo3: afNo3 == ""
                                        ? "empty"
                                        : afNo3.replaceAll('IHL Care', 'India Health Link'),
                                    afUnique3: afUnique3 == "" ? "empty" : afUnique3,
                                    afNo3bool: _logedSso ? true : _logedSso == afNo3bool,
                                    afNo4: afNo4 == ""
                                        ? "empty"
                                        : afNo4.replaceAll('IHL Care', 'India Health Link'),
                                    afUnique4: afUnique4 == "" ? "empty" : afUnique4,
                                    afNo4bool: _logedSso ? true : _logedSso == afNo4bool,
                                    afNo5: afNo5 == ""
                                        ? "empty"
                                        : afNo5.replaceAll('IHL Care', 'India Health Link'),
                                    afUnique5: afUnique5 == "" ? "empty" : afUnique5,
                                    afNo5bool: _logedSso ? true : _logedSso == afNo5bool,
                                    afNo6: afNo6 == ""
                                        ? "empty"
                                        : afNo6.replaceAll('IHL Care', 'India Health Link'),
                                    afUnique6: afUnique6 == "" ? "empty" : afUnique6,
                                    afNo6bool: _logedSso ? true : _logedSso == afNo6bool,
                                    afNo7: afNo7 == ""
                                        ? "empty"
                                        : afNo7.replaceAll('IHL Care', 'India Health Link'),
                                    afUnique7: afUnique7 == "" ? "empty" : afUnique7,
                                    afNo7bool: _logedSso ?? _logedSso == afNo7bool,
                                    afNo8: afNo8 == ""
                                        ? "empty"
                                        : afNo8.replaceAll('IHL Care', 'India Health Link'),
                                    afUnique8: afUnique8 == "" ? "empty" : afUnique8,
                                    afNo8bool: _logedSso ? true : _logedSso == afNo8bool,
                                    afNo9: afNo9 == ""
                                        ? "empty"
                                        : afNo9.replaceAll('IHL Care', 'India Health Link'),
                                    afUnique9: afUnique9 == "" ? "empty" : afUnique9,
                                    afNo9bool: _logedSso ? true : _logedSso == afNo9bool,
                                  )),
                          (Route<dynamic> route) => false);
                    }),
              ),
              Visibility(
                visible: false,
                child: TextButton(
                    onPressed: () => Get.to(() => DashBoardNavigation(
                        title: 'Social',
                        backNav: true,
                        navigationList: Platform.isAndroid
                            ? NewDashBoardNavigation.socialNavigation
                            : NewDashBoardNavigation.socialNavigationIOS)),
                    child: Text(
                      'Social',
                      style: TextStyle(
                          fontSize: ScUtil().setSp(16.0),
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    )),
              ),
              Visibility(
                visible: false,
                child: TextButton(
                    onPressed: () => Get.to(() => DashBoardNavigation(
                        title: 'Manage Health',
                        backNav: true,
                        navigationList: NewDashBoardNavigation.manageHealth)),
                    child: Text(
                      'Manage Health',
                      style: TextStyle(
                          fontSize: ScUtil().setSp(16.0),
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    )),
              ),
              Visibility(
                visible: false,
                child: TextButton(
                    onPressed: () => Get.to(() => DashBoardNavigation(
                        title: 'Health Programs',
                        backNav: true,
                        navigationList: NewDashBoardNavigation.healthProgram)),
                    child: Text(
                      'Health Programs',
                      style: TextStyle(
                          fontSize: ScUtil().setSp(16.0),
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    )),
              ),
              Visibility(
                visible: true,
                child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.solidThumbsUp,
                      color: Colors.white,
                    ),
                    title: Row(
                      children: [
                        Text(
                          'Health Challenges',
                          style: TextStyle(
                              fontSize: ScUtil().setSp(16.0),
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                          // style: TextStyle(
                          //     fontSize: ScUtil().setSp(16.0),
                          //     color: Colors.white,
                          //     fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.fiber_new,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    onTap: () async {
                      // SharedPreferences prefs1 = await SharedPreferences.getInstance();
                      // String userid = prefs1.getString("ihlUserId");
                      // // String userid = 'sdf';
                      // List<EnrolledChallenge> currentUserEnrolledChallenges =
                      //     await ChallengeApi().listofUserEnrolledChallenges(userId: userid);
                      // if (currentUserEnrolledChallenges.length != 0) {
                      //   Get.to(HealthChallengesComponents(
                      //     list: ["global", "Global"],
                      //   ));
                      // } else if (currentUserEnrolledChallenges.isEmpty) {
                      //   ListChallenge _listChallenge = ListChallenge(
                      //       challenge_mode: '',
                      //       pagination_start: 0,
                      //       email: Get.find<ListChallengeController>().email,
                      //       pagination_end: 1000,
                      //       affiliation_list: ["global", "Global"]);
                      //   List<Challenge> _listofChallenges =
                      //       await ChallengeApi().listOfChallenges(challenge: _listChallenge);
                      //   _listofChallenges
                      //       .removeWhere((element) => element.challengeStatus == "deactive");
                      //   List types = [];
                      //   for (int i = 0; i < _listofChallenges.length; i++) {
                      //     types.add(_listofChallenges[i].challengeType);
                      //     //Step Challenge
                      //     //Weight Loss Challenge
                      //   }
                      //   types = types.toSet().toList();
                      //   if (types.length == 1) {
                      //     Get.to(ListofChallenges(
                      //       list: ["global", "Global"],
                      //       challengeType: types[0],
                      //     ));
                      //   } else {
                      //     Get.to(
                      //         HealthChallengeTypes(
                      //           list: ["global", "Global"],
                      //         ),
                      //         transition: Transition.rightToLeftWithFade);
                      //   }
                      // }
                      Get.to(HealthChallengesComponents(
                        list: ["global", "Global"],
                      ));
                      widget.closeDrawer();
                    }),
              ),

              Visibility(
                visible: false,
                //visible: userAffiliate != null && userAffiliate.length!=0? true : false,
                child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.handHoldingHeart,
                      color: Colors.white,
                    ),
                    title: Row(
                      children: [
                        Text(
                          'Heart Health',
                          style: TextStyle(
                              fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.fiber_new,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    onTap: () => Get.to(CardioDashboard())
                    // onTap: () => Get.to(RedignedCardioDashboard(),
                    // transition: Transition.rightToLeft),
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => ShowingKisokValues(),
                    //   ),
                    // );
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => CardioNavBar(
                    //       affiliatedCompanyNamesList: [
                    //         afNo1,
                    //         afNo2,
                    //         afNo3,
                    //         afNo4,
                    //         afNo5,
                    //         afNo6,
                    //         afNo7,
                    //         afNo8,
                    //         afNo9
                    //       ],
                    //     ),
                    //   ),
                    // );
                    // widget.closeDrawer();
                    ),
              ),
              Visibility(
                visible: true,
                //visible: userAffiliate != null && userAffiliate.length!=0? true : false,
                child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.handHoldingHeart,
                      color: Colors.white,
                    ),
                    title: Row(
                      children: [
                        Text(
                          'Heart Health',
                          style: TextStyle(
                              fontSize: ScUtil().setSp(16.0),
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.fiber_new,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    onTap: () => Get.to(CardioDashboardNew(
                          tabView: false,
                        ))),
              ),
              Visibility(
                visible: false,
                child: ListTile(
                    leading: Icon(
                      Icons.place_rounded,
                      color: Colors.white,
                    ),
                    title: Row(
                      children: [
                        Text(
                          'H-Pod Stations',
                          style: TextStyle(
                              fontSize: ScUtil().setSp(16.0),
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.fiber_new,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    onTap: () async {
                      widget.closeDrawer();
                      // widget.pageController.animateToPage(1,
                      //     duration: Duration(milliseconds: 300),
                      //     curve: Curves.bounceIn);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HpodLocations(
                                    isGeneric: true,
                                  )),
                          (Route<dynamic> route) => false);
                    }),
              ),

              // ListTile(
              //     leading: Icon(
              //       FontAwesomeIcons.file,
              //       color: Colors.white,
              //     ),
              //     title: Row(
              //       children: [
              //         Text(
              //           'Daily Health Tips',
              //           style: TextStyle(
              //               fontSize: 18,
              //               color: Colors.white,
              //               fontWeight: FontWeight.w500),
              //         ),
              //         SizedBox(width: 4),
              //         Icon(
              //           Icons.fiber_new,
              //           color: Colors.white,
              //         ),
              //       ],
              //     ),
              //     onTap: () {
              //       widget.closeDrawer();
              //       Navigator.pushAndRemoveUntil(
              //           context,
              //           MaterialPageRoute(builder: (context) => TipsScreen()),
              //           (Route<dynamic> route) => false);
              //       // widget.pageController.animateToPage(2,
              //       //     duration: Duration(milliseconds: 300),
              //       //     curve: Curves.bounceIn);
              //     }),
              Visibility(
                visible: false,
                //visible: userAffiliate != null && userAffiliate.length!=0? true : false,
                child: ListTile(
                    leading: Icon(
                      Icons.whatshot_outlined,
                      color: Colors.white,
                    ),
                    title: Row(
                      children: [
                        Text(
                          'Health Journal',
                          style: TextStyle(
                              fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.fiber_new,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => DietJournal()),
                          (Route<dynamic> route) => false);
                      //goalSetting(context);
                      widget.closeDrawer();
                    }),
              ),
              // Visibility(
              //   visible: userAffiliate != null && userAffiliate.length != 0
              //       ? true
              //       : false,
              //   child: ListTile(
              //       leading: Icon(
              //         FontAwesomeIcons.userMd,
              //         color: Colors.white,
              //       ),
              //       title: Text(
              //         'TeleConsultation',
              //         style: TextStyle(
              //             fontSize: 18,
              //             color: Colors.white,
              //             fontWeight: FontWeight.w500),
              //       ),
              //       onTap: () {
              //         widget.closeDrawer();
              //         openTocDialog(context);
              //       }),
              // ),
              // Visibility(
              //   //visible: userAffiliate != null && userAffiliate.length!=0? true : false,
              //   child: ListTile(
              //       leading: Icon(
              //         FontAwesomeIcons.walking,
              //         color: Colors.white,
              //       ),
              //       title: Text(
              //         'Health E-Market',
              //         style: TextStyle(
              //             fontSize: 18,
              //             color: Colors.white,
              //             fontWeight: FontWeight.w500),
              //       ),
              //       onTap: () {
              //         Navigator.of(context)
              //             .pushReplacementNamed(Routes.WellnessCart);
              //         // widget.pageController.animateToPage(3,
              //         //     duration: Duration(milliseconds: 300),
              //         //     curve: Curves.bounceIn);
              //         widget.closeDrawer();
              //       }),
              // ),

              // ListTile(
              //     leading: Icon(
              //       Icons.person,
              //       color: Colors.white,
              //     ),
              //     title: Text(
              //       'Profile',
              //       style: TextStyle(
              //           fontSize: 18,
              //           color: Colors.white,
              //           fontWeight: FontWeight.w500),
              //     ),
              //     onTap: () {
              //       // widget.pageController.animateToPage(2,
              //       //     duration: Duration(milliseconds: 300),
              //       //     curve: Curves.bounceIn);
              //       widget.closeDrawer();
              //       Navigator.of(context)
              //           .pushNamed(Routes.Profile, arguments: false);
              //     }),

              Visibility(
                visible: false,
                //visible: userAffiliate != null && userAffiliate.length!=0? true : false,
                child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.shoePrints,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Step Tracker',
                      style:
                          TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      widget.closeDrawer();
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => StepsScreen()));
                      // Navigator.pushAndRemoveUntil(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => StepsScreen()),
                      //         (Route<dynamic> route) => false);
                      // widget.pageController.animateToPage(1,
                      //     duration: Duration(milliseconds: 300),
                      //     curve: Curves.bounceIn);
                    }),
              ),

              // ListTile(
              //     leading: Icon(
              //       FontAwesomeIcons.solidLightbulb,
              //       color: Colors.white,
              //     ),
              //     title: Text(
              //       'Recommendations',
              //       style: TextStyle(
              //           fontSize: 18,
              //           color: Colors.white,
              //           fontWeight: FontWeight.w500),
              //     ),
              //     onTap: () {
              //       widget.closeDrawer();
              //       Navigator.pushAndRemoveUntil(
              //           context,
              //           MaterialPageRoute(builder: (context) => Tab1()),
              //           (Route<dynamic> route) => false);
              //       // widget.pageController.animateToPage(2,
              //       //     duration: Duration(milliseconds: 300),
              //       //     curve: Curves.bounceIn);
              //     }),

              // ListTile(
              //     leading: Icon(
              //       FontAwesomeIcons.newspaper,
              //       color: Colors.white,
              //     ),
              //     title: Row(
              //       children: [
              //         Text(
              //           'E - News Letter',
              //           style: TextStyle(
              //               fontSize: 18,
              //               color: Colors.white,
              //               fontWeight: FontWeight.w500),
              //         ),
              //         SizedBox(width: 4),
              //         Icon(
              //           Icons.fiber_new,
              //           color: Colors.white,
              //         ),
              //       ],
              //     ),
              //     onTap: () {
              //       widget.closeDrawer();
              //       Navigator.pushAndRemoveUntil(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => NewsLetterScreen()),
              //           (Route<dynamic> route) => false);
              //       // widget.pageController.animateToPage(2,
              //       //     duration: Duration(milliseconds: 300),
              //       //     curve: Curves.bounceIn);
              //     }),
              /*ListTile(
                  leading: Icon(
                    Icons.track_changes_rounded,
                    color: Colors.white,
                  ),
                  title: Text(
                    'My Goal',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    widget.closeDrawer();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewGoalSettingScreen()));
                    /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GoalSettingScreen()));*/
                    //goalSetting(context);
                  }),*/
              /*ListTile(
                  leading: Icon(
                    Icons.track_changes_rounded,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Fit',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    widget.closeDrawer();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DietDashBoard()));
                  }),*/

              // ListTile(
              //     leading: Icon(
              //       Icons.info,
              //       color: Colors.white,
              //     ),
              //     title: Text(
              //       'liveee',
              //       style: TextStyle(
              //           fontSize: 18,
              //           color: Colors.white,
              //           fontWeight: FontWeight.w500),
              //     ),
              //     onTap: () async {
              //       widget.closeDrawer();
              //       // widget.pageController.animateToPage(1,
              //       //     duration: Duration(milliseconds: 300),
              //       //     curve: Curves.bounceIn);
              //       // Navigator.push(
              //       //   context,
              //       //   MaterialPageRoute(
              //       //       builder: (context) => GenixLiveSignal(
              //       //         genixAppointId: 'genixAppointId',
              //       //         iHLUserId: 'iHLUserId.toString()',
              //       //         specality: ''
              //       //         // widget.details['specality'].toString(),
              //       //         // vendor_consultant_id: widget.details['doctor']
              //       //         // ['vendor_consultant_id']
              //       //         //     .toString(),
              //       //       )),
              //       // );
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => GeoLocation()),
              //       );

              // }),
              Visibility(
                visible: true,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: new ExpansionTile(
                    onExpansionChanged: (value) {
                      isGroupExpandedOnline.value = !isGroupExpandedOnline.value;
                    },
                    leading: Icon(
                      FontAwesomeIcons.globe,
                      color: Colors.white,
                    ),
                    initiallyExpanded: false,
                    trailing: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    title: Row(
                      children: [
                        Text(
                          'Online Services ',
                          style: TextStyle(
                              fontSize: ScUtil().setSp(16.0),
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        ValueListenableBuilder(
                          valueListenable: isGroupExpandedOnline,
                          builder: (BuildContext context, bool value, Widget child) {
                            return Icon(
                              isGroupExpandedOnline.value
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: Colors.white,
                            );
                          },
                        ),
                      ],
                    ),
                    children: [
                      Visibility(
                        // visible:
                        //     userAffiliate != null && userAffiliate.length != 0
                        //         ? true
                        //         : false,
                        child: ListTile(
                            leading: Icon(
                              FontAwesomeIcons.userMd,
                              color: Colors.white,
                            ),
                            title: Text(
                              'Teleconsultations',
                              style: TextStyle(
                                  fontSize: ScUtil().setSp(16.0),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                            onTap: () {
                              widget.closeDrawer();
                              Get.to(ViewallTeleDashboard(
                                backNav: false,
                              ));
                            }),
                      ),
                      Visibility(
                        //visible: userAffiliate != null && userAffiliate.length!=0? true : false,
                        child: ListTile(
                            leading: Icon(
                              FontAwesomeIcons.walking,
                              color: Colors.white,
                            ),
                            title: Text(
                              'Health E-Market',
                              style: TextStyle(
                                  fontSize: ScUtil().setSp(16.0),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed(Routes.WellnessCart);
                              // widget.pageController.animateToPage(3,
                              //     duration: Duration(milliseconds: 300),
                              //     curve: Curves.bounceIn);
                              widget.closeDrawer();
                            }),
                      ),
                      Divider(color: Colors.white, thickness: 2)
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: true,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: new ExpansionTile(
                    onExpansionChanged: (value) {
                      isGroupExpandedHealth.value = !isGroupExpandedHealth.value;
                    },
                    leading: Icon(
                      FontAwesomeIcons.bookOpen,
                      color: Colors.white,
                    ),
                    initiallyExpanded: false,
                    trailing: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    title: Row(
                      children: [
                        Text(
                          'Health Management',
                          style: TextStyle(
                              fontSize: ScUtil().setSp(16.0),
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        ValueListenableBuilder(
                          valueListenable: isGroupExpandedHealth,
                          builder: (BuildContext context, bool value, Widget child) {
                            return Icon(
                              isGroupExpandedHealth.value
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: Colors.white,
                            );
                          },
                        ),
                      ],
                    ),
                    children: [
                      ListTile(
                          leading: Icon(
                            FontAwesomeIcons.solidLightbulb,
                            color: Colors.white,
                          ),
                          title: Text(
                            'Recommendations',
                            style: TextStyle(
                                fontSize: ScUtil().setSp(16.0),
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                          onTap: () {
                            widget.closeDrawer();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => Tab1()),
                                (Route<dynamic> route) => false);
                            // widget.pageController.animateToPage(2,
                            //     duration: Duration(milliseconds: 300),
                            //     curve: Curves.bounceIn);
                          }),
                      ListTile(
                          leading: Icon(
                            FontAwesomeIcons.file,
                            color: Colors.white,
                          ),
                          title: Row(
                            children: [
                              Text(
                                'Daily Health Tips',
                                style: TextStyle(
                                    fontSize: ScUtil().setSp(16.0),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.fiber_new,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          onTap: () {
                            widget.closeDrawer();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => TipsScreen()),
                                (Route<dynamic> route) => false);
                            // widget.pageController.animateToPage(2,
                            //     duration: Duration(milliseconds: 300),
                            //     curve: Curves.bounceIn);
                          }),
                      ListTile(
                          leading: Icon(
                            FontAwesomeIcons.newspaper,
                            color: Colors.white,
                          ),
                          title: Row(
                            children: [
                              Text(
                                'E - News Letter',
                                style: TextStyle(
                                    fontSize: ScUtil().setSp(16.0),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.fiber_new,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          onTap: () {
                            widget.closeDrawer();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => NewsLetterScreen()),
                                (Route<dynamic> route) => false);
                            // widget.pageController.animateToPage(2,
                            //     duration: Duration(milliseconds: 300),
                            //     curve: Curves.bounceIn);
                          }),
                      Divider(color: Colors.white, thickness: 2)
                    ],
                  ),
                ),
              ),

              Visibility(
                //visible: userAffiliate != null && userAffiliate.length!=0? true : false,
                child: ListTile(
                    leading: Icon(
                      Icons.whatshot_outlined,
                      color: Colors.white,
                    ),
                    title: Row(
                      children: [
                        Text(
                          'Health Journal',
                          style: TextStyle(
                              fontSize: ScUtil().setSp(16.0),
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        // SizedBox(width: 4),
                        // Icon(
                        //   Icons.fiber_new,
                        //   color: Colors.white,
                        // ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => DietJournal()),
                          (Route<dynamic> route) => false);
                      //goalSetting(context);
                      widget.closeDrawer();
                    }),
              ),
              Visibility(
                //visible: userAffiliate != null && userAffiliate.length!=0? true : false,
                child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.shoePrints,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Step Tracker',
                      style: TextStyle(
                          fontSize: ScUtil().setSp(16.0),
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      widget.closeDrawer();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  StepsScreen(activities: ssglobaltodaysActivityData)));
                      // Navigator.pushAndRemoveUntil(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => StepsScreen()),
                      //         (Route<dynamic> route) => false);
                      // widget.pageController.animateToPage(1,
                      //     duration: Duration(milliseconds: 300),
                      //     curve: Curves.bounceIn);
                    }),
              ),
              Visibility(
                visible: false, //change for live
                //visible: userAffiliate != null && userAffiliate.length!=0? true : false,
                child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.handHoldingHeart,
                      color: Colors.white,
                    ),
                    title: Row(
                      children: [
                        Text(
                          'Heart Health Management',
                          style: TextStyle(
                              fontSize: ScUtil().setSp(16.0),
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.fiber_new,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => ShowingKisokValues(),
                      //   ),
                      // );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CardioDashboard(),
                        ),
                      );
                      // widget.closeDrawer();
                    }),
              ),
              Visibility(
                visible: true,
                child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.qrcode,
                      color: Colors.white,
                    ),
                    title: Text(
                      'H Pod Login',
                      style: TextStyle(
                          fontSize: ScUtil().setSp(16.0),
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () async {
                      var status = await Permission.camera.status;
                      // widget.pageController.animateToPage(2,
                      //     duration: Duration(milliseconds: 300),
                      //     curve: Curves.bounceIn);
                      //widget.closeDrawer();
                      if (status.isGranted) {
                        Get.to(QRScannerScreen());
                      }
                      // await Permission.storage.request();
                      // await Permission.mediaLibrary.request();
                      // await Permission.activityRecognition.request();

                      if (status.isGranted) {
                        showAlert(context);
                        //Get.to(QRScannerScreen());
                        return true;
                      } else if (status.isDenied) {
                        //await Permission.camera.request();
                        status = await Permission.camera.status;
                        if (status.isGranted) {
                          ///here
                          return true;
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => CupertinoAlertDialog(
                                    title: new Text("Camera Access Denied"),
                                    content: new Text("Allow Camera permission to continue"),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        isDefaultAction: true,
                                        child: Text("Yes"),
                                        onPressed: () async {
                                          final result =
                                              await Permission.camera.request().isPermanentlyDenied;
                                          if (await Permission.camera.request().isGranted) {
                                            status = await Permission.camera.status;
                                            setState(() {});
                                          } else if (result) {
                                            await openAppSettings();
                                          }
                                          Get.back();
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: Text("No"),
                                        onPressed: () => Get.back(),
                                      )
                                    ],
                                  ));
                          return false;
                        }
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => CupertinoAlertDialog(
                                  title: new Text("Activity Access Denied"),
                                  content: new Text("Allow Activity permission to continue"),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      isDefaultAction: true,
                                      child: Text("Yes"),
                                      onPressed: () async {
                                        await openAppSettings();
                                        Get.back();
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: Text("No"),
                                      onPressed: () => Get.back(),
                                    )
                                  ],
                                ));

                        return false;
                        // Get.snackbar(
                        //     'Activity Access Denied', 'Allow Activity permission to continue',
                        //     backgroundColor: Colors.red,
                        //     colorText: Colors.white,
                        //     duration: Duration(seconds: 5),
                        //     isDismissible: false,
                        //     mainButton: TextButton(
                        //         onPressed: () async {
                        //           await openAppSettings();
                        //         },
                        //         child: Text('Allow')));
                      }

                      // Navigator.pushAndRemoveUntil(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => QRScannerScreen()),
                      //         (Route<dynamic> route) => false);
                    }),
              ),
              Visibility(
                visible: false,
                child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.signInAlt,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Sign In',
                      style: TextStyle(
                          fontSize: ScUtil().setSp(16.0),
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () async {
                      // widget.pageController.animateToPage(2,
                      //     duration: Duration(milliseconds: 300),
                      //     curve: Curves.bounceIn);
                      widget.closeDrawer();

                      // await Permission.storage.request();
                      // await Permission.mediaLibrary.request();
                      // await Permission.activityRecognition.request();
                      var status = await Permission.camera.status;
                      if (status.isGranted) {
                        Get.to(GoogleSignInScreen());
                        return true;
                      } else if (status.isDenied) {
                        //await Permission.camera.request();
                        status = await Permission.camera.status;
                        if (status.isGranted) {
                          ///here
                          return true;
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => CupertinoAlertDialog(
                                    title: new Text("Camera Access Denied"),
                                    content: new Text("Allow Camera permission to continue"),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        isDefaultAction: true,
                                        child: Text("Yes"),
                                        onPressed: () async {
                                          final result =
                                              await Permission.camera.request().isPermanentlyDenied;
                                          if (await Permission.camera.request().isGranted) {
                                            status = await Permission.camera.status;
                                            setState(() {});
                                          } else if (result) {
                                            await openAppSettings();
                                          }
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: Text("No"),
                                        onPressed: () => Get.back(),
                                      )
                                    ],
                                  ));
                          return false;
                        }
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => CupertinoAlertDialog(
                                  title: new Text("Activity Access Denied"),
                                  content: new Text("Allow Activity permission to continue"),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      isDefaultAction: true,
                                      child: Text("Yes"),
                                      onPressed: () async {
                                        await openAppSettings();
                                        Get.back();
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: Text("No"),
                                      onPressed: () => Get.back(),
                                    )
                                  ],
                                ));

                        return false;
                        // Get.snackbar(
                        //     'Activity Access Denied', 'Allow Activity permission to continue',
                        //     backgroundColor: Colors.red,
                        //     colorText: Colors.white,
                        //     duration: Duration(seconds: 5),
                        //     isDismissible: false,
                        //     mainButton: TextButton(
                        //         onPressed: () async {
                        //           await openAppSettings();
                        //         },
                        //         child: Text('Allow')));
                      }

                      // Navigator.pushAndRemoveUntil(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => QRScannerScreen()),
                      //         (Route<dynamic> route) => false);
                    }),
              ),
              ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Profile',
                    style: TextStyle(
                        fontSize: ScUtil().setSp(16.0),
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    // widget.pageController.animateToPage(2,
                    //     duration: Duration(milliseconds: 300),
                    //     curve: Curves.bounceIn);
                    widget.closeDrawer();
                    Navigator.of(context).pushNamed(Routes.Profile, arguments: false);
                  }),

              ListTile(
                  leading: Icon(
                    Icons.chat,
                    color: Colors.white,
                  ),
                  title: Row(
                    children: [
                      Text(
                        'Ask IHL',
                        style: TextStyle(
                            fontSize: ScUtil().setSp(16.0),
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.fiber_new,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  onTap: () async {
                    widget.closeDrawer();
                    // widget.pageController.animateToPage(1,
                    //     duration: Duration(milliseconds: 300),
                    //     curve: Curves.bounceIn);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => AskUsScreen()),
                        (Route<dynamic> route) => false);
                  }),

              ListTile(
                  leading: Icon(
                    Icons.info,
                    color: Colors.white,
                  ),
                  title: Text(
                    'About',
                    style: TextStyle(
                        fontSize: ScUtil().setSp(16.0),
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () async {
                    widget.closeDrawer();
                    // widget.pageController.animateToPage(1,
                    //     duration: Duration(milliseconds: 300),
                    //     curve: Curves.bounceIn);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => About()),
                        (Route<dynamic> route) => false);
                  }),

              // GestureDetector(
              //     onTap: () {
              //       //navigation
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => GenixLiveSignal(
              //               genixAppointId: '453a411d4b2b467395b231abc8d0d15e',
              //               iHLUserId: 'pM7UyDhBAkih16N7beZ0Rw',
              //               specality: "General Physician",
              //               vendor_consultant_id: "77de3d95-8387-4493-adef-6327186acdd6",
              //               vendorConsultantId: "77de3d95-8387-4493-adef-6327186acdd6",
              //               vendorAppointmentId: "b5e98038-2f28-4140-98ac-181cfa0d9698",
              //               vendorUserName: 'Nithin',
              //             )), //user_name
              //       );
              //     },
              //     child: Text('c summary mannual -->')),
              Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width / 1.6),
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      textStyle: TextStyle(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      _exitApp(context);
                    },
                    child: Text(
                      "Log Out".toUpperCase(),
                      style: TextStyle(
                        fontSize: ScUtil().setSp(16.0),
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          )),
    );
  }

  Future<bool> _survey(BuildContext context) {
    return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Column(
                  children: [
                    Text(
                      'Finish Health Assessment\nto get IHL Score',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: AppColors.primaryColor,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        child: Text(
                          'Proceed Now',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.Survey, arguments: false);
                        },
                      ),
                    ),
                    SizedBox(height: 6),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Try later',
                        style: new TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }) ??
        false;
  }

  _exitApp(BuildContext context) {
    return showDialog(
            context: context,
            barrierDismissible: logOutLoading,
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (context, StateSetter setState) {
                return AlertDialog(
                  title: Text('Do you want to logout this application?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        logOutLoading ? Navigator.of(context).pop(false) : {};
                      },
                      child: Text('No',
                          style: TextStyle(color: logOutLoading ? Colors.blue : Colors.black26)),
                    ),
                    TextButton(
                      onPressed: () {
                        if (logOutLoading) {
                          if (this.mounted) {
                            setState(() {
                              logOutLoading = false;

                              clear();
                              //Get.close(1);
                            });
                          }
                        } else {
                          null;
                        }
                      },
                      child: Text(
                        'Yes',
                        style: TextStyle(color: logOutLoading ? Colors.blue : Colors.black26),
                      ),
                    ),
                  ],
                );
              });
            }) ??
        false;
  }

  void clear() async {
    final prefs = await SharedPreferences.getInstance();
    var ihlId = prefs.getString("ihlUserId");
    await localSotrage.erase();
    Get.deleteAll();
    var val1 = await updateFirebaseTokenApi(ihlId);
    var x = await SpUtil.remove('qAns');
    await SpUtil.remove('survey');
    var y = await SpUtil.clear();
    _deleteCacheDir();
    _deleteAppDir();
    final firebaseMessaging = FCM();
    firebaseMessaging.TopicUnsubscription(affUniqueNameList);
    isSubscribedToTopic = false;
    print(isSubscribedToTopic);
    if (x == true && y == true) {
      final box = GetStorage();
      await localSotrage.erase();
      await prefs.clear().then((value) {
        Get.offAllNamed(Routes.Welcome, arguments: false);
      });
      if (mounted) {
        setState(() {
          logOutLoading = true;
        });
      }
    }
  }

  updateFirebaseTokenApi(String iHLUserId) async {
    final updateFcmToken = await _client.post(
        Uri.parse(API.iHLUrl + "/consult/fire_base_instance_upload_replace"),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(
            <String, String>{'ihl_user_id': iHLUserId, 'fcm_token': "NA", 'app': "care"}));
    if (updateFcmToken.statusCode == 200) {
      return "Success";
    }
  }

  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  Future<void> _deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

  void showReviewDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    "Consultant is preparing your report",
                    style: TextStyle(
                      color: Color(0xff6D6E71),
                      fontSize: 22.0,
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    "Meanwhile",
                    style: TextStyle(
                      color: Color(0xff6D6E71),
                      fontSize: 22.0,
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    "Rate your experience with the call",
                    style: TextStyle(
                      color: Color(0xff6D6E71),
                      fontSize: 22.0,
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Text(
                    "Your Ratings",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 22.0,
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  SmoothStarRating(
                      allowHalfRating: false,
                      onRated: (v) {},
                      starCount: 5,
                      rating: 5,
                      size: 30.0,
                      isReadOnly: true,
                      color: Colors.amberAccent,
                      borderColor: Colors.grey,
                      spacing: 0.0),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: AppColors.primaryAccentColor,
                        ),
                        onPressed: () {},
                      ),
                      labelText: "Your feedback for Dr. Abc",
                      fillColor: Colors.white24,
                      border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(15.0),
                          borderSide: new BorderSide(color: AppColors.primaryAccentColor)),
                    ),
                    style: TextStyle(fontSize: 16.0),
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ]),
              ),
            ),
          );
        });
  }
}
