import 'dart:convert';
import 'dart:typed_data';

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

class HomeScreen extends StatelessWidget {
  final bool introDone;
  final bool isJointAccount;
  static const String id = 'home_screen';

  const HomeScreen({Key key, this.introDone, this.isJointAccount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ///the value of affiliateUniqueName will be null and while payment success , it will be converted to
    ///global_service and if user will go through the member service than according to the affiliation
    ///the value will be changed
    SpUtil.putString(SPKeys.affiliateUniqueName, 'null');
    return Scaffold(
        body: ShowCaseWidget(
      onFinish: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var authToken = prefs.get('auth_token');
        var data = prefs.get('data');
        Map res = jsonDecode(data);
        String iHLUserId = res['User']['id'];
        String iHLUserToken = res['Token'];
        http.Client _client = http.Client(); //3gb
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
    user['firstName'] ??= 'you';
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
                    child: Scaffold(
                      appBar: GlobalAppBar(openDrawer: openDrawer),
                      // floatingActionButton: widget.introDone == false
                      //     ? Theme(
                      //         data: ThemeData(
                      //           textTheme: TextTheme(
                      //             headline1: TextStyle(fontSize: 26.0),
                      //           ),
                      //         ),
                      //         child: Showcase(
                      //           descTextStyle: TextStyle(
                      //               letterSpacing: 3.0,
                      //               color: AppColors.primaryAccentColor,
                      //               fontFamily: "Poppins",
                      //               wordSpacing: 3.0),
                      //           showArrow: true,
                      //           textColor: Colors.blue,
                      //           overlayColor: Colors.transparent,
                      //           key: _one,
                      //           shapeBorder: CircleBorder(),
                      //           description:
                      //               'Tap here to connect with\nHealth Consultants ',
                      //           child: FloatingActionButton(
                      //             onPressed: () {
                      //               Get.to(ViewallTeleDashboard(
                      //                 backNav: false,
                      //               ));
                      //             },
                      //             elevation: 0,
                      //             child: Icon(FontAwesomeIcons.userMd),
                      //           ),
                      //         ),
                      //       )
                      //     : FloatingActionButton(
                      //         onPressed: () {
                      //           openTocDialog(context);
                      //         },
                      //         elevation: 0,
                      //         child: Icon(FontAwesomeIcons.userMd),
                      //       ),
                      // floatingActionButtonLocation:
                      //     FloatingActionButtonLocation.endDocked,
                      body: ReDesignedHomeScreen(
                        username: name,
                        openDrawer: openDrawer,
                        closeDrawer: closeDrawer,
                        userScore: score,
                        goToProfile: () {
                          Navigator.of(context).pushNamed(Routes.Profile, arguments: false);
                        },
                      ),
                      // body: Container(
                      //   color: AppColors.bgColorTab,
                      //   child: PageView(
                      //     controller: _pageController,
                      //     onPageChanged: (index) {
                      //       if (this.mounted) {
                      //         setState(() => currentIndex = index);
                      //       }
                      //     },
                      //     children: [
                      //       Tab(
                      //         child: HomeTab(
                      //           username: name,
                      //           openDrawer: openDrawer,
                      //           closeDrawer: closeDrawer,
                      //           userScore: score,
                      //           goToProfile: () {
                      //             _pageController.jumpToPage(2);
                      //           },
                      //         ),
                      //       ),
                      //       Tab(
                      //         child: ClipRRect(
                      //           child: SizedBox(
                      //             //child: Tab1(),
                      //              child: StepsScreen(),
                      //             width: MediaQuery.of(context).size.width,
                      //           ),
                      //         ),
                      //       ),
                      //       Tab(
                      //         child: ClipRRect(
                      //           child: SizedBox(
                      //             child: Tab1(),
                      //             width: MediaQuery.of(context).size.width,
                      //           ),
                      //         ),
                      //       ),
                      //       Tab(
                      //         child: ClipRRect(
                      //           child: SizedBox(
                      //             child: WellnessCart(),
                      //             width: MediaQuery.of(context).size.width,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // bottomNavigationBar: Container(
                      //   width: MediaQuery.of(context).size.height -
                      //       MediaQuery.of(context).padding.top -
                      //       kToolbarHeight -
                      //       kBottomNavigationBarHeight,
                      //   child: BubbleBottomBar(
                      //     opacity: .2,
                      //     currentIndex: currentIndex,
                      //     onTap: (index) {
                      //       if (this.mounted) {
                      //         setState(() => currentIndex = index);
                      //       }
                      //       _pageController.jumpToPage(index);
                      //     },
                      //     borderRadius:
                      //         BorderRadius.vertical(top: Radius.circular(16)),
                      //     elevation: 8,
                      //     fabLocation: BubbleBottomBarFabLocation.end, //new
                      //     hasNotch: true, //new
                      //     hasInk: true, //new, gives a cute ink effect
                      //     inkColor: Colors
                      //         .blue, //optional, uses theme color if not specified
                      //     items: <BubbleBottomBarItem>[
                      //       BubbleBottomBarItem(
                      //         backgroundColor: Color(0xFF19a9e5),
                      //         icon: Icon(
                      //           Icons.dashboard,
                      //           size: 28,
                      //           color: Colors.grey,
                      //         ),
                      //         activeIcon: Icon(
                      //           Icons.dashboard,
                      //           size: 28,
                      //           color: Color(0xFF19a9e5),
                      //         ),
                      //         title: Text(
                      //           'HOME',
                      //           textAlign: TextAlign.center,
                      //           style: TextStyle(fontSize: ScUtil().setSp(10)),
                      //         ),
                      //       ),
                      //       BubbleBottomBarItem(
                      //         backgroundColor: Color(0xFF19a9e5),
                      //         icon: Icon(
                      //           FontAwesomeIcons.shoePrints,
                      //           color: Colors.grey,
                      //         ),
                      //         activeIcon: Icon(
                      //           FontAwesomeIcons.shoePrints,
                      //           color: Color(0xFF19a9e5),
                      //         ),
                      //         title: Text(
                      //           //'TIPS',
                      //           'Steps', //Step Walker
                      //           textAlign: TextAlign.center,
                      //           style: TextStyle(fontSize: ScUtil().setSp(10)),
                      //         ),
                      //       ),
                      //       BubbleBottomBarItem(
                      //         backgroundColor: Color(0xFF19a9e5),
                      //         icon: Icon(
                      //           Icons.lightbulb,
                      //           size: 24,
                      //           color: Colors.grey,
                      //         ),
                      //         activeIcon: Icon(
                      //           Icons.lightbulb,
                      //           size: 24,
                      //           color: Color(0xFF19a9e5),
                      //         ),
                      //         title: Text(
                      //           'Tips',
                      //           textAlign: TextAlign.center,
                      //           style: TextStyle(fontSize: ScUtil().setSp(10)),
                      //         ),
                      //       ),
                      //       BubbleBottomBarItem(
                      //         backgroundColor: Color(0xFF19a9e5),
                      //         icon: Showcase(
                      //           descTextStyle: TextStyle(
                      //               letterSpacing: 3.0,
                      //               color: AppColors.primaryAccentColor,
                      //               fontFamily: "Poppins",
                      //               wordSpacing: 3.0),
                      //           textColor: Colors.blue,
                      //           overlayColor: Colors.transparent,
                      //           key: _two,
                      //           description:
                      //               'Tap here to subscribe for\nWellness Classes ',
                      //           child: Icon(
                      //             FontAwesomeIcons.walking,
                      //             size: 24,
                      //             color: Colors.grey,
                      //           ),
                      //         ),
                      //         activeIcon: Icon(
                      //           FontAwesomeIcons.walking,
                      //           size: 24,
                      //           color: Color(0xFF19a9e5),
                      //         ),
                      //         title: Marquee(
                      //           child: Text(
                      //             'HEALTH \nE-MARKET',
                      //             textAlign: TextAlign.center,
                      //             overflow: TextOverflow.ellipsis,
                      //             style:
                      //                 TextStyle(fontSize: ScUtil().setSp(10)),
                      //           ),
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                    ),
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

// Future openTocDialog(context) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   var data = prefs.get('data');
//   var tocAccepted = prefs.get('TOCAccepted');
//   Map res = jsonDecode(data);
//   var userTOCAccepted = res['User']['isTeleMedPolicyAgreed'];
//   var address = res['User']['address'].toString();
//   var area = res['User']['area'].toString();
//   var city = res['User']['city'].toString();
//   var state = res['User']['state'].toString();
//   var pincode = res['User']['pincode'].toString();
//
//   if ((tocAccepted == null || tocAccepted == false) &&
//       (userTOCAccepted == null || userTOCAccepted == false)) {
//     String result = await Navigator.of(context).push(MaterialPageRoute(
//         builder: (BuildContext context) {
//           return Toc();
//         },
//         fullscreenDialog: true));
//     if (result == 'User Agreed') {
//       ///we are not setting it to true
//       ///prefs.setBool('TOCAccepted', true);
//       ///instead we are setting it to false
//       prefs.setBool('TOCAccepted', false);
//
//       ///and we are not calling the api also to update the telemed terms
//       // updateTeleMedTOC();
//       if (area == null ||
//           area == "" ||
//           area == "null" ||
//           address == null ||
//           address == "" ||
//           address == "null" ||
//           city == null ||
//           city == "" ||
//           city == "null" ||
//           state == null ||
//           state == "" ||
//           state == "null" ||
//           pincode == null ||
//           pincode == "" ||
//           pincode == "null") {
//         Get.to(ProfileTab(
//           editing: true,
//         ));
//       } else {
//         Get.to(ViewallTeleDashboard(
//           backNav: false,
//         ));
//       }
//     } else {
//       Get.dialog(
//         AlertDialog(
//           title: Column(
//             children: [
//               Text(
//                 'Info !',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: AppColors.primaryColor, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 12),
//               Text(
//                 'Please agree to the Terms & Conditions to access and use the TeleConsultation features',
//                 style: TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 12),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 40),
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     primary: AppColors.primaryColor,
//                     textStyle: TextStyle(color: Colors.white),
//                   ),
//                   child: Text(
//                     'Proceed Now',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   onPressed: () {
//                     Get.close(1);
//                     openTocDialog(context);
//                   },
//                 ),
//               ),
//               SizedBox(height: 10),
//               InkWell(
//                 onTap: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text(
//                   'Cancel',
//                   style: new TextStyle(
//                       fontSize: 16,
//                       color: AppColors.primaryColor,
//                       fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//       print('Not Accepted');
//     }
//   } else {
//     if (area == null ||
//         area == "" ||
//         area == "null" ||
//         address == null ||
//         address == "" ||
//         address == "null" ||
//         city == null ||
//         city == "" ||
//         city == "null" ||
//         state == null ||
//         state == "" ||
//         state == "null" ||
//         pincode == null ||
//         pincode == "" ||
//         pincode == "null") {
//       Get.offAll(ProfileTab(
//         editing: true,
//       ));
//     } else {
//       Get.to(ViewallTeleDashboard(
//         backNav: false,
//       ));
//     }
//   }
// }
