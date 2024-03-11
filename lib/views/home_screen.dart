import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../Getx/controller/listOfChallengeContoller.dart';
import '../health_challenge/views/listofchallenges.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/constants/vitalUI.dart';
import 'package:ihl/notification_controller.dart';
import 'package:ihl/tabs/re_designed_home_screen.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/goal_settings/apis/goal_apis.dart';
import 'package:ihl/views/goal_settings/goal_setting_screen.dart';
import 'package:ihl/views/screens.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import 'goal_settings/edit_goal_screen.dart';

/*
 😃Code organization😃
 all tabs are located in lib/tabs
 */

class BottomNavBarItem {
  BottomNavBarItem({this.iconData, this.text});
  IconData iconData;
  String text;
}

class HomeSSScreen extends StatelessWidget {
  final bool introDone;
  final bool isJointAccount;
  static const String id = 'home_screen';

  const HomeSSScreen({Key key, this.introDone, this.isJointAccount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ///the value of affiliateUniqueName will be null and while payment success , it will be converted to
    ///global_service and if user will go through the member service than according to the affiliation
    ///the value will be changed
    SpUtil.putString(SPKeys.affiliateUniqueName, 'null');
    http.Client _client = http.Client(); //3gb

    return Scaffold(
        body: ShowCaseWidget(
      onFinish: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var authToken = prefs.get('auth_token');
        var data = prefs.get('data');
        Map res = jsonDecode(data);
        String iHLUserId = res['User']['id'];
        String iHLUserToken = res['Token'];
        final userIntroDone = await _client.post(
          Uri.parse(iHLUrl + '/data/user/' + iHLUserId + ''),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
          // headers: {
          //   'Content-Type': 'application/json',
          //   'Token': iHLUserToken,
          //   'ApiToken': authToken,
          //   'Accept': 'application/json'
          // },
          body: jsonEncode(<String, dynamic>{'introDone': true}),
        );
        if (userIntroDone.statusCode == 200) {
          print("Intro Done is true now!");
        } else {
          print(userIntroDone.body);
        }
      },
      builder: Builder(
          builder: (context) => BottomNavBar(title: 'Flutter App', introDone: introDone ?? false)),
    ));
  }
}

class BottomNavBar extends StatefulWidget {
  final bool introDone;
  final String title;
  BottomNavBar({Key key, this.title, this.introDone}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with TickerProviderStateMixin {
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();

  int currentIndex = 0;
  bool drawerOpen = false;
  PageController _pageController;
  ZoomDrawerController _zoomDrawerController = ZoomDrawerController();
  String name = 'IHL User';
  String score = 'N/A';
  Image avatar = maleAvatar;
  var userAffiliated;

  ///from this var we will know that user is affiliated or not

  _BottomNavBarState();
  void openDrawer() {
    if (drawerOpen) {
      return;
    }
    _zoomDrawerController.open();
    drawerOpen = true;
    if (this.mounted) {
      setState(() {});
    }
    getData();
  }

  void closeDrawer() {
    if (!drawerOpen) {
      return;
    }
    _zoomDrawerController.close();
    drawerOpen = false;
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var raw = prefs.get(SPKeys.userData);
    if (raw == '' || raw == null) {
      raw = '{}';
    }
    Map data = jsonDecode(raw);
    Map user = data['User'];
    user ??= {};

    ///from this variable we will  now that user is affiliated or not
    userAffiliated = user['user_affiliate'];
    List affUniqueNameList = [];
    if (userAffiliated == null) {
      userAffiliated = [];
    } else {
      userAffiliated.removeWhere((k, v) {
        if (v["affilate_unique_name"] != "" && v["affilate_unique_name"] != "null") {
          affUniqueNameList.add(v["affilate_unique_name"]);
          API.affNmLst.add(v['affilate_name'].toString().replaceAll(' Pvt Ltd', ''));
        }
        return v["affilate_unique_name"] == "";
      });
      print(API.affNmLst);
    }

    ///
    if (isSubscribedToTopic == false) {
      ////this two line
      final firebaseMessaging = FCM();
      firebaseMessaging.TopicSubscription(affUniqueNameList);
      isSubscribedToTopic = true;
      print(isSubscribedToTopic);
    }
    if (user['firstName'] == '' || user['firstName'] == null) {
      user['firstName'] = 'you';
    }
    user['user_score'] ??= {};
    user['user_score']['T'] ??= 'N/A';
    score = user['user_score']['T'].toString();
    user['lastName'] ??= '';
    name = user['firstName'] + ' ' + user['lastName'];
    prefs.setString('name', name);
    List notAns = [];
    Map sscore = user['user_score'];
    sscore.forEach((k, v) {
      if (v == 0) {
        notAns.add(k);
      }
    });
    notAns.remove('E1');
    notAns.remove('E2');
    notAns.remove('E3');
    notAns.remove('E4');
    if (notAns.isEmpty) {
      prefs.setBool('allAns', true);
    } else {
      prefs.setBool('allAns', false);
    }
    if (this.mounted) {
      setState(() {});
    }
    Get.find<ListChallengeController>().enrolledChallenge();
  }

  Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }

  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  String base64String(Uint8List data) {
    return base64Encode(data);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    getData();
    widget.introDone == false
        ? WidgetsBinding.instance
            .addPostFrameCallback((_) => ShowCaseWidget.of(context).startShowCase([_one, _two]))
        : null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      onWillPop: () async {
        if (drawerOpen) {
          closeDrawer();
          return false;
        }
        if (_pageController.page == 0) {
          return true;
        } else {
          _pageController.animateToPage(0,
              duration: Duration(milliseconds: 300), curve: Curves.bounceIn);
          return false;
        }
      },
      child: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: Container(
          color: AppColors.primaryAccentColor,
          child: GestureDetector(
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              if (details.delta.dx < -6) {
                closeDrawer();
              }
            },
            child: ZoomDrawer(
              controller: _zoomDrawerController,
              menuScreen: MainDrawer(
                name: name,
                pageController: _pageController,
                closeDrawer: closeDrawer,
                openDrawer: openDrawer,
                open: drawerOpen,
                score: score,
              ),
              mainScreen: ColorFiltered(
                colorFilter: drawerOpen
                    ? ColorFilter.mode(Colors.grey, BlendMode.saturation)
                    : ColorFilter.mode(Colors.transparent, BlendMode.saturation),
                child: GestureDetector(
                  onTap: closeDrawer,
                  child: AbsorbPointer(
                    absorbing: drawerOpen,

                    ///condition for showing the old and  new dashboard
                    // child: userAffiliated!=null&&userAffiliated.length>0?Scaffold(
                    child: Scaffold(
                      appBar: GlobalAppBar(openDrawer: openDrawer),
                      body: ReDesignedHomeScreen(
                        username: name,
                        openDrawer: openDrawer,
                        closeDrawer: closeDrawer,
                        userScore: score,
                        goToProfile: () {
                          Navigator.of(context).pushNamed(Routes.Profile, arguments: false);
                        },
                      ),
                    )

                    ///old dashboard for showing if condition didn't match
                    // : VitalTab(
                    //    username: name,
                    //    openDrawer: openDrawer,
                    //    closeDrawer: closeDrawer,
                    //    userScore: score,
                    //    goToProfile: () {
                    //      Navigator.of(context)
                    //          .pushNamed(Routes.Profile, arguments: false);
                    //    },
                    //    isShowAsMainScreen: true,
                    //  )
                    ,
                  ),
                ),
              ),
              borderRadius: 24.0,
              showShadow: false,
              angle: 0.0,
              backgroundColor: AppColors.appBackgroundColor,
              slideWidth: MediaQuery.of(context).size.width * .65,
              openCurve: Curves.fastOutSlowIn,
              closeCurve: Curves.fastOutSlowIn,
            ),
          ),
        ),
      ),
    );
  }
}

// Future updateTeleMedTOC() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   var email = prefs.get('email');
//   var password = prefs.get('password');
//   var data = prefs.get('data');
//   Map res = jsonDecode(data);
//   String iHLUserId = res['User']['id'];
//   String iHLUserToken = res['Token'];
//   var authToken = prefs.get('auth_token');
//   http.Client _client = http.Client(); //3gb
//   await _client
//       .post(
//     Uri.parse(iHLUrl + '/data/user/' + iHLUserId + ''),
//     headers: {
//       'Content-Type': 'application/json',
//       'ApiToken': '${API.headerr['ApiToken']}',
//       'Token': '${API.headerr['Token']}',
//     },
//     // headers: {
//     //   'Content-Type': 'application/json',
//     //   'Token': iHLUserToken,
//     //   'ApiToken': authToken,
//     //   'Accept': 'application/json'
//     // },
//     body: jsonEncode(<String, dynamic>{'isTeleMedPolicyAgreed': true}),
//   )
//       .then((value) async {
//     if (value.statusCode == 200) {
//       // await http
//       //     .post(
//       //   Uri.parse(iHLUrl + '/login/qlogin2'),
//       //   headers: {
//       //     'Content-Type': 'application/json',
//       //     'Token': 'bearer ',
//       //     'ApiToken': authToken
//       //   },
//       //   body: jsonEncode(<String, String>{
//       //     'email': email,
//       //     'password': password,
//       //   }),
//       // )
//       var is_sso = prefs.get(SPKeys.is_sso);
//       var ihlUserId = '';
//       if (is_sso.toString() == 'true') {
//         // ihlUserId = await getTheIhlIdForSso();
//         ihlUserId = prefs.getString('ihlUserId');
//         // prefs.setString('IHL_User_ID', ihlUserId);
//       }
//       var loginUrl =
//           is_sso == "true" ? '/login/get_user_login' : '/login/qlogin2';
//       var body = jsonEncode(<String, String>{
//         'email': email,
//         'password': password,
//       });
//       var bodySso = jsonEncode(<String, String>{
//         "id": ihlUserId,
//       });
//       Map<String, String> header = {
//         'Content-Type': 'application/json',
//         'Token': 'bearer ',
//         'ApiToken': authToken
//       };
//       Map<String, String> headerSso = {
//         'Content-Type': 'application/json',
//         'Token': 'bearer ',
//         'ApiToken': authToken
//       };
//       http.Client _client = http.Client(); //3gb
//       await _client
//           .post(
//         Uri.parse(iHLUrl + loginUrl),
//         // headers: is_sso=="true"?headerSso:header,
//         headers: {
//           'Content-Type': 'application/json',
//           'ApiToken':
//               "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
//         },
//         body: is_sso == "true" ? bodySso : body,
//       )
//           .then((value) {
//         if (value.statusCode == 200) {
//           prefs.setString('data', value.body);
//         }
//       });
//     }
//   });
//   API.headerr = {};
//   API.headerr['Token'] = '$iHLUserToken';
//   API.headerr['ApiToken'] = '$authToken';
// }

void goalSetting(context) {
  GoalApis.listGoal().then((value) {
    if (value != null && value.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewGoalSettingScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => GoalSettingScreen()));
    }
  });
}
