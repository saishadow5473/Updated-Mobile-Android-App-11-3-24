// import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:ihl/constants/routes.dart';
// import 'package:ihl/constants/spKeys.dart';
// import 'dart:typed_data';
// import 'package:connectivity_wrapper/connectivity_wrapper.dart';
// import 'package:ihl/tabs/homeTab.dart';
// import 'package:ihl/utils/ScUtil.dart';
// import 'package:ihl/utils/SpUtil.dart';
// import 'package:ihl/utils/app_colors.dart';
// import 'package:ihl/constants/vitalUI.dart';
// import 'package:http/http.dart' as http;
// import 'package:ihl/views/about_screen.dart';
// import 'package:ihl/views/affiliation/affiliations.dart';
// import 'package:ihl/views/dietDashboard/diet_dashBoard_New.dart';
// import 'package:ihl/views/dietDashboard/profile_screen.dart';
// import 'package:ihl/views/dietJournal/dietJournal.dart';
// import 'package:ihl/views/dietJournal/fit_view.dart';
// import 'package:ihl/views/goal_settings/apis/goal_apis.dart';
// import 'package:ihl/views/goal_settings/goal_setting_screen.dart';
// import 'package:ihl/views/teleconsultation/viewallneeds.dart';
// import 'package:ihl/widgets/offline_widget.dart';
// import 'package:ihl/widgets/profileScreen/photo.dart';
// import 'package:ihl/widgets/toc.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
// import 'package:flutter/material.dart';
// import 'package:ihl/views/screens.dart';
// import 'package:flutter/rendering.dart';
// import 'package:marquee_widget/marquee_widget.dart';
// import 'package:ihl/tabs/tabs.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:showcaseview/showcaseview.dart';
// import 'package:ihl/views/teleconsultation/wellness_cart.dart';
// import 'package:strings/strings.dart';
//
// import 'goal_settings/edit_goal_screen.dart';
//
// /*
//  😃Code organization😃
//  all tabs are located in lib/tabs
//  */
//
// class BottomNavBarItem {
//   BottomNavBarItem({this.iconData, this.text});
//   IconData iconData;
//   String text;
// }
//
// class HomeScreen extends StatelessWidget {
//   final bool introDone;
//   static const String id = 'home_screen';
//
//   const HomeScreen({Key key, this.introDone}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: ShowCaseWidget(
//       onFinish: () async {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         var authToken = prefs.get('auth_token');
//         var data = prefs.get('data');
//         Map res = jsonDecode(data);
//         String iHLUserId = res['User']['id'];
//         String iHLUserToken = res['Token'];
//         final userIntroDone = await http.post(
//           Uri.parse(iHLUrl + '/data/user/' + iHLUserId + ''),
//           headers: {
//             'Content-Type': 'application/json',
//             'Token': iHLUserToken,
//             'ApiToken': authToken,
//             'Accept': 'application/json'
//           },
//           body: jsonEncode(<String, dynamic>{'introDone': true}),
//         );
//         if (userIntroDone.statusCode == 200) {
//           print("Intro Done is true now!");
//         } else {
//           print(userIntroDone.body);
//         }
//       },
//       builder: Builder(
//           builder: (context) => BottomNavBar(introDone: introDone ?? false)),
//     ));
//   }
// }
//
// class BottomNavBar extends StatefulWidget {
//   final bool introDone;
//   BottomNavBar({Key key, this.introDone}) : super(key: key);
//
//   @override
//   _BottomNavBarState createState() => _BottomNavBarState();
// }
//
// class _BottomNavBarState extends State<BottomNavBar>
//     with TickerProviderStateMixin {
//   GlobalKey _one = GlobalKey();
//   GlobalKey _two = GlobalKey();
//
//   int currentIndex = 0;
//   bool drawerOpen = false;
//   PageController _pageController;
//   ZoomDrawerController _zoomDrawerController = ZoomDrawerController();
//   String name = 'IHL User';
//   String score = 'N/A';
//   Image avatar = maleAvatar;
//   bool surveyDone = false;
//   var userAffiliate;
//   String afNo1, afNo2, afNo3, afNo4, afNo5, afNo6, afNo7, afNo8, afNo9;
//   String afUnique1,
//       afUnique2,
//       afUnique3,
//       afUnique4,
//       afUnique5,
//       afUnique6,
//       afUnique7,
//       afUnique8,
//       afUnique9;
//   void openDrawer() {
//     if (drawerOpen) {
//       return;
//     }
//     _zoomDrawerController.open();
//     drawerOpen = true;
//     if (this.mounted) {
//       setState(() {});
//     }
//     getData();
//   }
//
//   void closeDrawer() {
//     if (!drawerOpen) {
//       return;
//     }
//     _zoomDrawerController.close();
//     drawerOpen = false;
//     if (this.mounted) {
//       setState(() {});
//     }
//   }
//
//   Future<void> getData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var raw = prefs.get(SPKeys.userData);
//     if (raw == '' || raw == null) {
//       raw = '{}';
//     }
//     Map data = jsonDecode(raw);
//     Map user = data['User'];
//     user ??= {};
//     user['firstName'] ??= 'you';
//     user['user_score'] ??= {};
//     user['user_score']['T'] ??= 'N/A';
//     score = user['user_score']['T'].toString();
//     user['lastName'] ??= '';
//     name = user['firstName'] + ' ' + user['lastName'];
//     prefs.setString('name', name);
//     List notAns = [];
//     Map sscore = user['user_score'];
//     sscore.forEach((k, v) {
//       if (v == 0) {
//         notAns.add(k);
//       }
//     });
//     notAns.remove('E1');
//     notAns.remove('E2');
//     notAns.remove('E3');
//     notAns.remove('E4');
//     if (notAns.isEmpty) {
//       surveyDone = true;
//       prefs.setBool('allAns', true);
//     } else {
//       surveyDone = false;
//       prefs.setBool('allAns', false);
//     }
//     afNo1 ??= "empty";
//     afNo2 ??= "empty";
//     afNo3 ??= "empty";
//     afNo4 ??= "empty";
//     afNo5 ??= "empty";
//     afNo6 ??= "empty";
//     afNo7 ??= "empty";
//     afNo8 ??= "empty";
//     afNo9 ??= "empty";
//
//     userAffiliate = data['User']['user_affiliate'];
//     if (userAffiliate != null) {
//       if (userAffiliate.containsKey("af_no1")) {
//         afNo1 = userAffiliate['af_no1']['affilate_name'] ?? "empty";
//         afUnique1 = userAffiliate['af_no1']['affilate_unique_name'] ?? "empty";
//       }
//       if (userAffiliate.containsKey("af_no2")) {
//         afNo2 = userAffiliate['af_no2']['affilate_name'] ?? "empty";
//         afUnique2 = userAffiliate['af_no2']['affilate_unique_name'] ?? "empty";
//       }
//       if (userAffiliate.containsKey("af_no3")) {
//         afNo3 = userAffiliate['af_no3']['affilate_name'] ?? "empty";
//         afUnique3 = userAffiliate['af_no3']['affilate_unique_name'] ?? "empty";
//       }
//       if (userAffiliate.containsKey("af_no4")) {
//         afNo4 = userAffiliate['af_no4']['affilate_name'] ?? "empty";
//         afUnique4 = userAffiliate['af_no4']['affilate_unique_name'] ?? "empty";
//       }
//       if (userAffiliate.containsKey("af_no5")) {
//         afNo5 = userAffiliate['af_no5']['affilate_name'] ?? "empty";
//         afUnique5 = userAffiliate['af_no5']['affilate_unique_name'] ?? "empty";
//       }
//       if (userAffiliate.containsKey("af_no6")) {
//         afNo6 = userAffiliate['af_no6']['affilate_name'] ?? "empty";
//         afUnique6 = userAffiliate['af_no6']['affilate_unique_name'] ?? "empty";
//       }
//       if (userAffiliate.containsKey("af_no7")) {
//         afNo7 = userAffiliate['af_no7']['affilate_name'] ?? "empty";
//         afUnique7 = userAffiliate['af_no7']['affilate_unique_name'] ?? "empty";
//       }
//       if (userAffiliate.containsKey("af_no8")) {
//         afNo8 = userAffiliate['af_no8']['affilate_name'] ?? "empty";
//         afUnique8 = userAffiliate['af_no8']['affilate_unique_name'] ?? "empty";
//       }
//       if (userAffiliate.containsKey("af_no9")) {
//         afNo9 = userAffiliate['af_no9']['affilate_name'] ?? "empty";
//         afUnique9 = userAffiliate['af_no9']['affilate_unique_name'] ?? "empty";
//       }
//     }
//     if (this.mounted) {
//       setState(() {});
//     }
//   }
//
//   Image imageFromBase64String(String base64String) {
//     return Image.memory(base64Decode(base64String));
//   }
//
//   Uint8List dataFromBase64String(String base64String) {
//     return base64Decode(base64String);
//   }
//
//   String base64String(Uint8List data) {
//     return base64Encode(data);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     getData();
//     widget.introDone == false
//         ? WidgetsBinding.instance.addPostFrameCallback(
//             (_) => ShowCaseWidget.of(context).startShowCase([_one, _two]))
//         : null;
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   Widget drawer() {
//     return Theme(
//       data: Theme.of(context).copyWith(
//         canvasColor: Colors.transparent,
//       ),
//       child: SizedBox(
//         width: MediaQuery.of(context).size.width * 0.85,
//         child: Drawer(
//           elevation: 0.0,
//           child: SafeArea(
//             bottom: false,
//             child: Container(
//               color: AppColors.cardColor,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: <Widget>[
//                   SizedBox(
//                     child: Container(
//                       height: 140,
//                       padding: EdgeInsets.only(bottom: 10),
//                       margin: EdgeInsets.all(0),
//                       color: AppColors.primaryAccentColor,
//                       child: Column(
//                         children: [
//                           ListTile(
//                             trailing: Padding(
//                               padding: const EdgeInsets.only(top: 6.0),
//                               child: IconButton(
//                                 icon: Icon(Icons.close, color: Colors.white),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                             ),
//                           ),
//                           ListTile(
//                             leading: DrawerProfilePhoto(),
//                             title: Text(
//                               camelize(name ?? 'Guest User'),
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             subtitle: (surveyDone == true)
//                                 ? Text(
//                                     "IHL Score: ${score ?? 'N/A'}",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 : InkWell(
//                                     onTap: () {
//                                       Navigator.pop(context);
//                                       _survey(context);
//                                     },
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           'IHL Score: ',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 4,
//                                         ),
//                                         Icon(
//                                           Icons.info,
//                                           color: Colors.white,
//                                           size: 22,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                             trailing: Icon(Icons.arrow_forward_ios_rounded,
//                                 color: Colors.white),
//                             onTap: () {
//                               Navigator.pop(context);
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => ProfileScreen()));
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Divider(
//                     height: 0,
//                     thickness: 1,
//                   ),
//                   Expanded(
//                     child: Container(
//                       color: AppColors.cardColor,
//                       child: ListView(
//                         children: [
//                           ListTile(
//                             //  dense:true,
//                             // visualDensity: VisualDensity(vertical: -4,),
//                             trailing: Icon(Icons.arrow_forward_ios_sharp),
//                             subtitle: Text(
//                               'All-in-one place to have a tab of your health',
//                               style: TextStyle(
//                                 fontSize: 12,
//                               ),
//                             ),
//                             title: Text("Home",
//                                 style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColors.textitemTitleColor)),
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                           ),
//                           // SizedBox(height: 10,),
//                           Divider(
//                             height: 0,
//                             thickness: 1,
//                           ),
//                           Visibility(
//                             visible: userAffiliate != null ? true : false,
//                             child: ListTile(
//                               trailing: Icon(Icons.arrow_forward_ios_sharp),
//                               subtitle: Text(
//                                 'Enjoy and manage Your exclusive Memebership benefits',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                 ),
//                               ),
//                               title: Text("Membership Services",
//                                   style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w500,
//                                       color: AppColors.textitemTitleColor)),
//                               onTap: () {
//                                 Navigator.pop(context);
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           AffiliationsDashboard(
//                                             afNo1:
//                                                 afNo1 == "" ? "empty" : afNo1,
//                                             afUnique1: afUnique1 == ""
//                                                 ? "empty"
//                                                 : afUnique1,
//                                             afNo2:
//                                                 afNo2 == "" ? "empty" : afNo2,
//                                             afUnique2: afUnique2 == ""
//                                                 ? "empty"
//                                                 : afUnique2,
//                                             afNo3:
//                                                 afNo3 == "" ? "empty" : afNo3,
//                                             afUnique3: afUnique3 == ""
//                                                 ? "empty"
//                                                 : afUnique3,
//                                             afNo4:
//                                                 afNo4 == "" ? "empty" : afNo4,
//                                             afUnique4: afUnique4 == ""
//                                                 ? "empty"
//                                                 : afUnique4,
//                                             afNo5:
//                                                 afNo5 == "" ? "empty" : afNo5,
//                                             afUnique5: afUnique5 == ""
//                                                 ? "empty"
//                                                 : afUnique5,
//                                             afNo6:
//                                                 afNo6 == "" ? "empty" : afNo6,
//                                             afUnique6: afUnique6 == ""
//                                                 ? "empty"
//                                                 : afUnique6,
//                                             afNo7:
//                                                 afNo7 == "" ? "empty" : afNo7,
//                                             afUnique7: afUnique7 == ""
//                                                 ? "empty"
//                                                 : afUnique7,
//                                             afNo8:
//                                                 afNo8 == "" ? "empty" : afNo8,
//                                             afUnique8: afUnique8 == ""
//                                                 ? "empty"
//                                                 : afUnique8,
//                                             afNo9:
//                                                 afNo9 == "" ? "empty" : afNo9,
//                                             afUnique9: afUnique9 == ""
//                                                 ? "empty"
//                                                 : afUnique9,
//                                           )),
//                                 );
//                               },
//                             ),
//                           ),
//                           Divider(
//                             height: 0,
//                             thickness: 1,
//                           ),
//                           ListTile(
//                             trailing: Icon(Icons.arrow_forward_ios_sharp),
//                             subtitle: Text(
//                               'Sync and have a tab on your Health vitals',
//                               style: TextStyle(
//                                 fontSize: 12,
//                               ),
//                             ),
//                             title: Text("Your Health Vitals",
//                                 style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColors.textitemTitleColor)),
//                             onTap: () {
//                               Navigator.pop(context);
//                               // Navigator.push(
//                               //     context,
//                               //     MaterialPageRoute(
//                               //         builder: (context) => FitViewScreen()));
//                             },
//                           ),
//                           Divider(
//                             height: 0,
//                             thickness: 1,
//                           ),
//                           ListTile(
//                             trailing: Icon(Icons.arrow_forward_ios_sharp),
//                             subtitle: Text(
//                               'Instant consult, book appointments etc.,',
//                               style: TextStyle(
//                                 fontSize: 12,
//                               ),
//                             ),
//                             title: Text("Tele-Consultation",
//                                 style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColors.textitemTitleColor)),
//                             onTap: () {
//                               Navigator.pop(context);
//                               openTocDialog(context);
//                             },
//                           ),
//                           Divider(
//                             height: 0,
//                             thickness: 1,
//                           ),
//                           ListTile(
//                             trailing: Icon(Icons.arrow_forward_ios_sharp),
//                             subtitle: Text(
//                               'Curated Health & Wellness tips from IHL',
//                               style: TextStyle(
//                                 fontSize: 12,
//                               ),
//                             ),
//                             title: Text("Tips",
//                                 style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColors.textitemTitleColor)),
//                             onTap: () {
//                               Navigator.pop(context);
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => Tab1()));
//                             },
//                           ),
//                           Divider(
//                             height: 0,
//                             thickness: 1,
//                           ),
//                           ListTile(
//                             trailing: Icon(Icons.arrow_forward_ios_sharp),
//                             subtitle: Text(
//                               'Set and manage goals that reflects your lifestyle',
//                               style: TextStyle(
//                                 fontSize: 12,
//                               ),
//                             ),
//                             title: Text("My Goals",
//                                 style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColors.textitemTitleColor)),
//                             onTap: () {
//                               Navigator.pop(context);
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         ViewGoalSettingScreen()),
//                               );
//                             },
//                           ),
//                           Divider(
//                             height: 0,
//                             thickness: 1,
//                           ),
//                           ListTile(
//                             trailing: Icon(Icons.arrow_forward_ios_sharp),
//                             subtitle: Text(
//                               'Track Your Diet, Excercises, Activities etc.',
//                               style: TextStyle(
//                                 fontSize: 12,
//                               ),
//                             ),
//                             title: Text("Health Journal",
//                                 style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColors.textitemTitleColor)),
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => DietJournal()),
//                               );
//                             },
//                           ),
//                           Divider(
//                             height: 0,
//                             thickness: 1,
//                           ),
//                           ListTile(
//                             trailing: Icon(Icons.arrow_forward_ios_sharp),
//                             subtitle: Text(
//                               'Engage in Yoga and Wellness Classes etc.,',
//                               style: TextStyle(
//                                 fontSize: 12,
//                               ),
//                             ),
//                             title: Text("Health-E-Market",
//                                 style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColors.textitemTitleColor)),
//                             onTap: () {
//                               Navigator.pop(context);
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => WellnessCart()));
//                             },
//                           ),
//                           Divider(
//                             height: 0,
//                             thickness: 1,
//                           ),
//                           ListTile(
//                             trailing: Icon(Icons.arrow_forward_ios_sharp),
//                             subtitle: Text(
//                               'Know and Connect with us',
//                               style: TextStyle(
//                                 fontSize: 12,
//                               ),
//                             ),
//                             title: Text("About IHL",
//                                 style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColors.textitemTitleColor)),
//                             onTap: () {
//                               Navigator.pop(context);
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => About()),
//                               );
//                             },
//                           ),
//                           Divider(
//                             height: 0,
//                             thickness: 1,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Divider(),
//                   InkWell(
//                     onTap: () => _exitApp(context),
//                     child: Container(
//                         height: 60,
//                         // width: 100,
//                         color: AppColors.cardColor,
//                         child: ListTile(
//                           title: Text(
//                             'Log Out',
//                             style: TextStyle(
//                                 color: Colors.red,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 20),
//                           ),
//                           leading:
//                               Icon(Icons.exit_to_app_sharp, color: Colors.red),
//                         )),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
//     return WillPopScope(
//       onWillPop: () async {
//         if (drawerOpen) {
//           closeDrawer();
//           return false;
//         }
//         if (_pageController.page == 0) {
//           return true;
//         } else {
//           _pageController.animateToPage(0,
//               duration: Duration(milliseconds: 300), curve: Curves.bounceIn);
//           return false;
//         }
//       },
//       child: ConnectivityWidgetWrapper(
//         disableInteraction: true,
//         offlineWidget: OfflineWidget(),
//         child: Scaffold(
//           drawer: drawer(),
//           drawerEnableOpenDragGesture: true,
//           floatingActionButton: widget.introDone == false
//               ? Theme(
//                   data: ThemeData(
//                       textTheme:
//                           TextTheme(headline1: TextStyle(fontSize: 26.0))),
//                   child: Showcase(
//                     descTextStyle: TextStyle(
//                         letterSpacing: 3.0,
//                         color: AppColors.primaryAccentColor,
//                         fontFamily: "Poppins",
//                         wordSpacing: 3.0),
//                     showArrow: true,
//                     textColor: Colors.blue,
//                     overlayColor: Colors.transparent,
//                     key: _one,
//                     shapeBorder: CircleBorder(),
//                     description:
//                         'Tap here to connect with\nHealth Consultants ',
//                     child: FloatingActionButton(
//                       onPressed: () {
//                         openTocDialog(context);
//                       },
//                       elevation: 0,
//                       child: Icon(FontAwesomeIcons.userMd),
//                     ),
//                   ),
//                 )
//               : FloatingActionButton(
//                   onPressed: () {
//                     openTocDialog(context);
//                   },
//                   elevation: 0,
//                   child: Icon(FontAwesomeIcons.userMd),
//                 ),
//           floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//           body: Container(
//             color: AppColors.bgColorTab,
//             child: PageView(
//               controller: _pageController,
//               onPageChanged: (index) {
//                 if (this.mounted) {
//                   setState(() => currentIndex = index);
//                 }
//               },
//               children: [
//                 Tab(
//                   child: HomeTab(
//                     username: name,
//                     openDrawer: openDrawer,
//                     closeDrawer: closeDrawer,
//                     userScore: score,
//                     goToProfile: () {
//                       _pageController.jumpToPage(2);
//                     },
//                   ),
//                 ),
//                 Tab(
//                   child: ClipRRect(
//                     child: SizedBox(
//                       child: Tab1(),
//                       width: MediaQuery.of(context).size.width,
//                     ),
//                   ),
//                 ),
//                 Tab(
//                   child: ClipRRect(
//                     child: SizedBox(
//                       child: ProfileTab(),
//                       width: MediaQuery.of(context).size.width,
//                     ),
//                   ),
//                 ),
//                 Tab(
//                   child: ClipRRect(
//                     child: SizedBox(
//                       child: WellnessCart(),
//                       width: MediaQuery.of(context).size.width,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           /*bottomNavigationBar: Container(
//             width: MediaQuery.of(context).size.height -
//                 MediaQuery.of(context).padding.top -
//                 kToolbarHeight -
//                 kBottomNavigationBarHeight,
//             child: BubbleBottomBar(
//               opacity: .2,
//               currentIndex: currentIndex,
//               onTap: (index) {
//                 if (this.mounted) {
//                   setState(() => currentIndex = index);
//                 }
//                 _pageController.jumpToPage(index);
//               },
//               borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//               elevation: 8,
//               fabLocation: BubbleBottomBarFabLocation.end, //new
//               hasNotch: true, //new
//               hasInk: true, //new, gives a cute ink effect
//               inkColor:
//                   Colors.blue, //optional, uses theme color if not specified
//               items: <BubbleBottomBarItem>[
//                 BubbleBottomBarItem(
//                   backgroundColor: Color(0xFF19a9e5),
//                   icon: Icon(
//                     Icons.dashboard,
//                     size: 28,
//                     color: Colors.grey,
//                   ),
//                   activeIcon: Icon(
//                     Icons.dashboard,
//                     size: 28,
//                     color: Color(0xFF19a9e5),
//                   ),
//                   title: Text(
//                     'HOME',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 14),
//                   ),
//                 ),
//                 BubbleBottomBarItem(
//                   backgroundColor: Color(0xFF19a9e5),
//                   icon: Icon(
//                     FontAwesomeIcons.solidLightbulb,
//                     color: Colors.grey,
//                   ),
//                   activeIcon: Icon(
//                     FontAwesomeIcons.solidLightbulb,
//                     color: Color(0xFF19a9e5),
//                   ),
//                   title: Text(
//                     'TIPS',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 14),
//                   ),
//                 ),
//                 BubbleBottomBarItem(
//                   backgroundColor: Color(0xFF19a9e5),
//                   icon: Icon(
//                     Icons.person,
//                     size: 24,
//                     color: Colors.grey,
//                   ),
//                   activeIcon: Icon(
//                     Icons.person,
//                     size: 24,
//                     color: Color(0xFF19a9e5),
//                   ),
//                   title: Text(
//                     'PROFILE',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 14),
//                   ),
//                 ),
//                 BubbleBottomBarItem(
//                   backgroundColor: Color(0xFF19a9e5),
//                   icon: Showcase(
//                     descTextStyle: TextStyle(
//                         letterSpacing: 3.0,
//                         color: AppColors.primaryAccentColor,
//                         fontFamily: "Poppins",
//                         wordSpacing: 3.0),
//                     textColor: Colors.blue,
//                     overlayColor: Colors.transparent,
//                     key: _two,
//                     description: 'Tap here to subscribe for\nWellness Classes ',
//                     child: Icon(
//                       FontAwesomeIcons.walking,
//                       size: 24,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   activeIcon: Icon(
//                     FontAwesomeIcons.walking,
//                     size: 24,
//                     color: Color(0xFF19a9e5),
//                   ),
//                   title: Marquee(
//                     child: Text(
//                       'HEALTH \nE-MARKET',
//                       textAlign: TextAlign.center,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(fontSize: 12),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),*/
//         ),
//       ),
//     );
//   }
//
//   Future<bool> _exitApp(BuildContext context) {
//     return showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text('Do you want to logout this application?'),
//                 actions: <Widget>[
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop(false);
//                     },
//                     child: Text('No'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       setState(() {
//                         clear();
//                       });
//                     },
//                     child: Text('Yes'),
//                   ),
//                 ],
//               );
//             }) ??
//         false;
//   }
//
//   Future<bool> _survey(BuildContext context) {
//     return showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Column(
//                   children: [
//                     Text(
//                       'Finish Health Assessment\nto get IHL Score',
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 8),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 40),
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           primary: AppColors.primaryColor,
//                           textStyle: TextStyle(color: Colors.white),
//                         ),
//                         child: Text(
//                           'Proceed Now',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         onPressed: () {
//                           Navigator.of(context)
//                               .pushNamed(Routes.Survey, arguments: false);
//                         },
//                       ),
//                     ),
//                     SizedBox(height: 6),
//                     InkWell(
//                       onTap: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Text(
//                         'Try later',
//                         style: new TextStyle(
//                             fontSize: 14,
//                             color: AppColors.primaryColor,
//                             fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }) ??
//         false;
//   }
//
//   Future<void> _deleteCacheDir() async {
//     final cacheDir = await getTemporaryDirectory();
//
//     if (cacheDir.existsSync()) {
//       cacheDir.deleteSync(recursive: true);
//     }
//   }
//
//   Future<void> _deleteAppDir() async {
//     final appDir = await getApplicationSupportDirectory();
//
//     if (appDir.existsSync()) {
//       appDir.deleteSync(recursive: true);
//     }
//   }
//
//   void clear() async {
//     final prefs = await SharedPreferences.getInstance();
//     var x = await SpUtil.remove('qAns');
//     await SpUtil.remove('survey');
//     var y = await SpUtil.clear();
//     _deleteCacheDir();
//     _deleteAppDir();
//     if (x == true && y == true) {
//       await prefs.clear().then((value) {
//         Navigator.of(context).pushNamedAndRemoveUntil(
//             Routes.Welcome, (Route<dynamic> route) => false,
//             arguments: false);
//       });
//     }
//   }
// }
//
// Future updateTeleMedTOC() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   var email = prefs.get('email');
//   var password = prefs.get('password');
//   var data = prefs.get('data');
//   Map res = jsonDecode(data);
//   String iHLUserId = res['User']['id'];
//   String iHLUserToken = res['Token'];
//   var authToken = prefs.get('auth_token');
//   await http
//       .post(
//     Uri.parse(iHLUrl + '/data/user/' + iHLUserId + ''),
//     headers: {
//       'Content-Type': 'application/json',
//       'Token': iHLUserToken,
//       'ApiToken': authToken,
//       'Accept': 'application/json'
//     },
//     body: jsonEncode(<String, dynamic>{'isTeleMedPolicyAgreed': true}),
//   )
//       .then((value) async {
//     if (value.statusCode == 200) {
//       await http
//           .post(
//         Uri.parse(iHLUrl + '/login/qlogin2'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Token': 'bearer ',
//           'ApiToken': authToken
//         },
//         body: jsonEncode(<String, String>{
//           'email': email,
//           'password': password,
//         }),
//       )
//           .then((value) {
//         if (value.statusCode == 200) {
//           prefs.setString('data', value.body);
//         }
//       });
//     }
//   });
// }
//
// void goalSetting(context) {
//   GoalApis.listGoal().then((value) {
//     if (value != null && value.isNotEmpty) {
//       Navigator.push(context,
//           MaterialPageRoute(builder: (context) => ViewGoalSettingScreen()));
//     } else {
//       Navigator.push(context,
//           MaterialPageRoute(builder: (context) => GoalSettingScreen()));
//     }
//   });
// }
//
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
//       prefs.setBool('TOCAccepted', true);
//       updateTeleMedTOC();
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
