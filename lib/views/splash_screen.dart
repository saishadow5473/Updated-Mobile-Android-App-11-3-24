import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/Getx/controller/listOfChallengeContoller.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/main.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:ihl/utils/CrossbarUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/home_screen.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

import '../new_design/app/utils/localStorageKeys.dart';
import 'dietDashboard/edit_profile_screen.dart';
import 'otherVitalController/otherVitalController.dart';

/// Checks if user is logged in and navigates accordingly 🎈🎈
var showFromSharedPref = false;
var isSubscribedToTopic = false;
GetStorage gs;

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';
  final bool isReload;

  const SplashScreen({Key key, this.isReload}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  http.Client _client = http.Client(); //3gb
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool notificationsAllowed = false;
  bool _initialUriIsHandled = false;
  String iHLUserId;
  Session approveOrRejectAppointmentSession;
  Client approveOrRejectAppointmentClient;
  Timer timerSplashScreen;
  Uri _initialUri;
  Uri _latestUri;
  Object _err;
  StreamSubscription _sub;
  Future getStoreData() async {
    final prefs = await SharedPreferences.getInstance();
    if (Platform.isIOS) prefs.setBool("fit", true);
    print('SharedPref Keys : ${prefs.getKeys()}');
    print(prefs.get(
      'sso_token',
    ));

    //below is just setting to check is there any new app version available is so it will show in dashboard

    prefs.setString(SPKeys.needToCheckAppVersion, "yes");
  }

  @override
  void initState() {
    print('Token  ${API.headerr['Token']}');
    gs = GetStorage();
    getStoreData();
    // timerForSplashScreen();
    //initDynamicLinks();
    _handleInitialUri();
    //_handleIncomingLinks();
    showFromSharedPref = true;
    super.initState();
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void noDeepLink({bool deepLink}) {
    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if (!isAllowed) {
    //     notificationPermission(deepLink: deepLink);
    //   } else {
    _requestPermissions();
    timerSplashScreen?.cancel();
    isLoggedIn(deepLink: deepLink);
    // }
    // });
    // subscribeAppointmentApproved();
    // consultationStagesSessionMaintainer();

    //initailising timer CAM
    //deleting if older one exists
    timerCAM?.cancel();
    //creating new
    // istimerForCAM = false;
    // isNavigatedToNoInternetPage = false;
    // timerForCAM();
    //timerSplashScreen?.cancel();
    //timerForSplashScreen();
    isTimer90seconds = false;

    // if (widget.isReload != true) {
    //   // FlutterLocalNotifications()
    //       AwesomeNotifications()
    //       .actionStream
    //       .listen((receivedNotification) async {
    //     SharedPreferences prefs = await SharedPreferences.getInstance();
    //
    //     String path = prefs.getString("pathFromBillView");
    //
    //     String instructionsPath = prefs.getString("pathFromInstructions");
    //
    //     String summaryPath =
    //         prefs.getString("pathFromBillViewConsultationSummary");
    //
    //     if (receivedNotification.channelKey == "prescription_progress") {
    //       if (instructionsPath != null && instructionsPath != "") {
    //         OpenFile.open(instructionsPath);
    //         prefs.setString("pathFromInstructions", "");
    //       }
    //     } else if (receivedNotification.channelKey == "bill_progress") {
    //       if (path != null && path != "") {
    //         OpenFile.open(path);
    //         prefs.setString("pathFromBillView", "");
    //       }
    //     } else if (receivedNotification.channelKey ==
    //         "bill_progress_consultation_summary") {
    //       if (summaryPath != null && summaryPath != "") {
    //         OpenFile.open(summaryPath);
    //         prefs.setString("pathFromBillViewConsultationSummary", "");
    //       }
    //     } else if (receivedNotification.channelKey == "daily_tips") {
    //       Get.offAll(TipsScreen());
    //     } else if (receivedNotification.channelKey == "news_letter") {
    //       if (receivedNotification.payload.containsKey('file') ||
    //           !receivedNotification.payload.containsKey('path')) {
    //         Get.offAll(NewsLetterScreen());
    //       } else {
    //         var news_path = receivedNotification.payload['path'];
    //         OpenFile.open(news_path);
    //       }
    //     } else if (receivedNotification.channelKey ==
    //         "class_created_notification") {
    //       SharedPreferences prr = await SharedPreferences.getInstance();
    //       // var c = prr.get('fcmN_c');
    //       // var d = prr.get('fcmN_d');
    //       // var course = jsonDecode(c);
    //
    //       ///todo remove this dummy var use proper data that received from the firebase api
    //       // var company_name = receivedNotification.payload["affiliation_name"];//fpr
    //       var ihl_app = receivedNotification.payload["ihl"];
    //       if (ihl_app == "true") {
    //         Map course = jsonDecode(receivedNotification.payload["course"]);
    //         List affUniqueNameList =
    //             jsonDecode(receivedNotification.payload["affUniqueNameList"]);
    //         // var courses = jsonDecode(d);
    //         var courses = {};
    //         List clsAffNameList =
    //             jsonDecode(receivedNotification.payload["affiliation_name"]);
    //         var company_name = '';
    //         clsAffNameList.forEach((element) {
    //           if (affUniqueNameList.contains(element) == true) {
    //             company_name = element.toString();
    //           }
    //         });
    //         // if (message.data['affiliation_name'] == '') {
    //
    //         var exclusive = receivedNotification.payload["exclusive_only"];
    //         if (exclusive == 'false' && company_name != '') {
    //           var affClassNav = false;
    //           affUniqueNameList.forEach((element) {
    //             if (clsAffNameList.contains(element) == true) {
    //               //affiliation class
    //               affClassNav = true;
    //             }
    //           });
    //
    //           if (affClassNav) {
    //             Get.offAll(BookClassForAffiliation(
    //               notificationRoute: true,
    //               course: course,
    //               courses: courses,
    //               companyName: company_name,
    //             ));
    //           } else {
    //             Get.offAll(BookClass(
    //               course: course,
    //               courses: courses,
    //               notificationRoute: true,
    //             ));
    //           }
    //         } else {
    //           if (company_name == '') {
    //             Get.offAll(BookClass(
    //               course: course,
    //               courses: courses,
    //               notificationRoute: true,
    //             ));
    //             // Navigator.pushAndRemoveUntil(
    //             //     context,
    //             //     MaterialPageRoute(
    //             //       builder: (context) => BookClass(
    //             //         course: course,
    //             //         courses: courses,
    //             //         notificationRoute: true,
    //             //       ),
    //             //     ),
    //             //         (Route<dynamic> route) => false);
    //           } else {
    //             //affiliation class
    //             Get.offAll(BookClassForAffiliation(
    //               notificationRoute: true,
    //               course: course,
    //               courses: courses,
    //               companyName: company_name,
    //             ));
    //           }
    //         }
    //       } else {
    //         ///url launcher
    //         ///var ihl_app = receivedNotification.payload["ihl"];
    //         var url = receivedNotification.payload["url"];
    //         if (await canLaunch(url)) {
    //           await launch(url);
    //         } else {
    //           throw 'Could not launch $url';
    //         }
    //       }
    //     }
    //   });
    // }
  }

  /* void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink.link;
      if (deepLink != null) {
        Get.offNamedUntil(
            Routes.MyAppointments, (route) => Get.currentRoute == Routes.Home);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    if (deepLink == null) {
      noDeepLink(deepLink: false);
    } else {
      timerSplashScreen?.cancel();
      isLoggedIn(deepLink: true);
    }
  }
*/
  void _handleIncomingLinks() {
    _sub = uriLinkStream.listen((Uri uri) {
      if (!mounted) return;
      print('got uri: $uri');
      Get.offNamedUntil(Routes.MyAppointments, (route) => Get.currentRoute == Routes.Home);
    }, onError: (Object err) {
      if (!mounted) return;
      print('got err: $err');
      if (this.mounted) {
        setState(() {
          _latestUri = null;
          if (err is FormatException) {
            _err = err;
          } else {
            _err = null;
          }
        });
      }
    });
  }

  Future<void> _handleInitialUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final uri = await getInitialUri();
        if (uri == null) {
          noDeepLink();
        } else {
          timerSplashScreen?.cancel();
          isLoggedIn(deepLink: true);
          print('got initial uri: $uri');
        }
      } on PlatformException {
        print('Falied to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('malformed initial uri: $err');
      }
    }
  }

  @override
  void dispose() {
    timerSplashScreen?.cancel();
    //_sub.cancel();
    super.dispose();
  }

  //timer to check splashscreenkeeps on loading Function for 30seconds
  Future<void> timerForSplashScreen() async {
    timerSplashScreen = Timer.periodic(const Duration(seconds: 40), (timer30sec) {
      _buildChild(BuildContext context) => Container(
            height: 350,
            decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(12))),
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Color(0xffE57373),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                  child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: const [
                          Icon(
                            FontAwesomeIcons.frown,
                            size: 80,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Something went wrong!',
                            style: TextStyle(
                                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                ),
                const SizedBox(
                  height: 24,
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16, left: 16),
                  child: Text(
                    'Please try loading again',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xffE57373),
                        textStyle: const TextStyle(color: Colors.white),
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Center(
                        child: Text(
                          'RETRY',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      onPressed: () {
                        timerSplashScreen.cancel();
                        Get.offAll(const SplashScreen(
                          isReload: true,
                        ));
                      },
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 4.5,
                    ),
                  ],
                ),
              ],
            ),
          );
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: _buildChild(context),
              ),
            );
          });
    });
  }

  Future login({bool deepLink}) async {
    var userInputWeight;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var password = prefs.get(SPKeys.password);
    var email = prefs.get(SPKeys.email);
    var authToken = prefs.get(SPKeys.authToken);
    var ihlUserId = prefs.get("ihlUserId");
    var is_sso = prefs.get(SPKeys.is_sso);
    var loginUrl = is_sso == "true" ? '/login/get_user_login' : '/login/qlogin2';
    var body = jsonEncode(<String, String>{
      'email': email,
      'password': password,
    });
    var bodySso = jsonEncode(<String, String>{
      "id": ihlUserId,
    });
    Map<String, String> header = {'Content-Type': 'application/json', 'ApiToken': authToken};
    Map<String, String> headerSso = {
      'Content-Type': 'application/json',
      'Token': 'bearer ',
      'ApiToken':
          "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA=="
    };
    try {
      final response1 = await _client.post(
        Uri.parse(API.iHLUrl + loginUrl),
        headers: is_sso == "true" ? headerSso : header,
        body: is_sso == "true" ? bodySso : body,
      );
      if (response1.statusCode == 200) {
        var resjd = jsonDecode(response1.body);
        if (response1.body == 'null' ||
            response1.body == null ||
            resjd == "Object reference not set to an instance of an object." ||
            response1.body == "Object reference not set to an instance of an object.") {
          logOut(deepLink: deepLink);
          return;
        } else {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString(SPKeys.userData, response1.body);
          Get.put(ListChallengeController());
          Get.put(VitalsContoller());
          try {
            ///because when sso true password is null and you can not set null inshare prefrence
            prefs.setString(SPKeys.password, password);
          } catch (e) {
            debugPrint(is_sso);
            debugPrint(e.toString());
          }
          prefs.setString(SPKeys.email, email);
          var decodedResponse = jsonDecode(response1.body);
          try {
            userInputWeight = decodedResponse['User']['userInputWeightInKG'].toString();
          } catch (e) {
            userInputWeight = null;
          }
          String iHLUserToken = decodedResponse['Token'];
          iHLUserId = decodedResponse['User']['id'];
          bool introDone = decodedResponse['User']['introDone'];
          SharedPreferences prefs1 = await SharedPreferences.getInstance();
          prefs1.setString("ihlUserId", iHLUserId);
          API.headerr = {};
          API.headerr['Token'] = '$iHLUserToken';
          API.headerr['ApiToken'] = is_sso != "true"
              ? '$authToken'
              : "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==";
          print("##############################################" + API.headerr.toString());
          timerSplashScreen.cancel();
          prefs1.setBool(LSKeys.logged, true);
          localSotrage.write(LSKeys.logged, true);

          /// this conditon is called from home screen already , no need here
          ////this two line
          // final firebaseMessaging = FCM();
          // firebaseMessaging.setNotifications();
          if (deepLink == true) {
            Get.offNamedUntil(Routes.MyAppointments, (route) => Get.currentRoute == Routes.Home);
          } else {
            // Get.offAll(HomeDashBoard(introDone: introDone));
            if (userInputWeight.toString() == 'null') {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                            kisokAccountWithoutWeight: true,
                          )),
                  (Route<dynamic> route) => false);
            } else {
              // Get.offAll(HomeScreen(introDone: introDone));
              Get.offAll(LandingPage());
            }
          }
          /*
          final getUserDetails =
              await _client.post(Uri.parse(API.iHLUrl + "/consult/get_user_details"),
                  headers: {
                    'Content-Type': 'application/json',
                    'ApiToken': '${API.headerr['ApiToken']}',
                    'Token': '${API.headerr['Token']}',
                  },
                  body: jsonEncode(<String, String>{
                    'ihl_id': iHLUserId,
                  }));
          if (getUserDetails.statusCode == 200) {
            final userDetailsResponse = await SharedPreferences.getInstance();
            userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
          } else {
            print(getUserDetails.body);
          }*/
          // Fetch all Vital data API call
          final vitalData = await _client.get(
            Uri.parse('${API.iHLUrl}/data/user/$iHLUserId/checkin'),
            headers: {
              'Content-Type': 'application/json',
              'Token': iHLUserToken,
              'ApiToken':
                  "GHG5118RtDtd7C9AXHa9d/i0WDated53MlFmHgDK4n+8s86uo2s4HMvJkWCbKM5485lCRsBc6uTSlUuuzbWMGsJV3q+PEmAfvoVmjF8bKUgBAA=="
            },
          );
          if (vitalData.statusCode == 200) {
            final sharedUserVitalData = await SharedPreferences.getInstance();
            sharedUserVitalData.setString(SPKeys.vitalsData, vitalData.body).then(((value) {
              timerSplashScreen.cancel();
              /*if (deepLink == true) {
                Get.offNamedUntil(Routes.MyAppointments,
                    (route) => Get.currentRoute == Routes.Home);
              } else {
                // Get.offAll(HomeDashBoard(introDone: introDone));
                Get.offAll(HomeScreen(introDone: introDone));
              }*/
            }));
          } else {
            timerSplashScreen.cancel();
            // Navigator.pushAndRemoveUntil(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => HomeDashBoard(introDone: introDone)),
            //     (Route<dynamic> route) => false);
            /*Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(introDone: introDone)),
                (Route<dynamic> route) => false);*/
          }
        }
      } else {
        logOut(deepLink: deepLink);
      }
    } catch (e) {
      timerSplashScreen.cancel();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  //  HomeScreen(introDone: true)),
                  LandingPage()),
          (Route<dynamic> route) => false);
      // Navigator.of(context).pushNamedAndRemoveUntil(
      //     Routes.Home, (Route<dynamic> route) => false);
    }
  }

  Future logOut({bool deepLink}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    timerSplashScreen.cancel();
    await localSotrage.erase();
    prefs.clear().then((value) {
      timerSplashScreen.cancel();
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.Welcome, (Route<dynamic> route) => false,
          arguments: deepLink);
    });
  }

  Future<bool> isLoggedIn({bool deepLink}) async {
    timerForSplashScreen();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var password = prefs.get(SPKeys.password);
    var email = prefs.get(SPKeys.email);
    print('Email $email');
    var authToken = prefs.get(SPKeys.authToken);
    var is_sso = prefs.get(SPKeys.is_sso);
    print(is_sso);
    if ((password == '' ||
            password == null ||
            email == '' ||
            email == null ||
            authToken == '' ||
            authToken == null) &&
        (is_sso == '' || is_sso == "false" || is_sso == null)) {
      logOut(deepLink: deepLink);
      return false;
    } else {
      try {
        login(deepLink: deepLink);
      } catch (e) {
        timerSplashScreen.cancel();
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.Home, (Route<dynamic> route) => false);
      }
    }
  }

  void approveOrRejectAppointmentConnect() async {
    approveOrRejectAppointmentClient = Client(
        realm: 'crossbardemo',
        transport: WebSocketTransport(
          API.crossbarUrl,
          Serializer(),
          WebSocketSerialization.SERIALIZATION_JSON,
        ));
  }

  void subscribeAppointmentApproved() async {
    //reseting valuses for genix
    if (approveOrRejectAppointmentSession != null) {
      approveOrRejectAppointmentSession.close();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('genixAppoinmentID', "");
    prefs.setBool('isGenixCallAlive', false);
    approveOrRejectAppointmentConnect();
    approveOrRejectAppointmentSession = await approveOrRejectAppointmentClient
        .connect(
            options: ClientConnectOptions(
                reconnectCount: 10, reconnectTime: Duration(milliseconds: 200)))
        .first;

    try {
      final subscription = await approveOrRejectAppointmentSession.subscribe(
          'ihl_send_data_to_user_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) {
        Map<String, dynamic> data = event.arguments[0];
        var status = data['data']['status'];
        // if (status == 'Approved') {
        //   getUserDetails();
        // }
        // if (status == 'Rejected') {
        //   getUserDetails();
        // }
        // if (status == 'CancelAppointment') {
        //   getUserDetails();
        // }
      });
      await subscription.onRevoke
          .then((reason) => print('The server has killed my subscription due to: ' + reason));
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

//timer to run checkAndMaintainSeesion Function for every 3seconds
  Future<void> consultationStagesSessionMaintainer() async {
    // ignore: unused_local_variable
    var timerConsultationStagesSession = new Timer.periodic(
      Duration(seconds: 3),
      (timer3secConsultationStagesSession) {
        if (approveOrRejectAppointmentSession != null) {
          approveOrRejectAppointmentSession.onConnectionLost
              .then((value) => subscribeAppointmentApproved());
        } else {
          subscribeAppointmentApproved();
        }
      },
    );
  }

  // getUserDetails() async {
  //   final getUserDetails = await _client.post(Uri.parse(API.iHLUrl + "/consult/get_user_details"),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'ApiToken': '${API.headerr['ApiToken']}',
  //         'Token': '${API.headerr['Token']}',
  //       },
  //       body: jsonEncode(<String, String>{
  //         'ihl_id': iHLUserId,
  //       }));
  //   if (getUserDetails.statusCode == 200) {
  //     final userDetailsResponse = await SharedPreferences.getInstance();
  //     userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
  //   } else {
  //     print(getUserDetails.body);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAccentColor,
      body: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              end: Alignment.topRight,
              begin: Alignment.bottomLeft,
              colors: [
                AppColors.primaryColor,
                // AppColors.primaryColor,

                Color.fromRGBO(42, 178, 231, 1),
                Colors.white.withOpacity(0.5),
                // Color.fromRGBO(42, 178, 231,1),
                // Color.fromRGBO(42, 178, 231,1)
              ],
            ),
          ),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2.5,
                ),
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    //   boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black38,
                    //     offset: const Offset(
                    //       5.0,
                    //       5.0,
                    //     ),
                    //     blurRadius: 10.0,
                    //     spreadRadius: 2.0,
                    //   ), //BoxShadow
                    //   BoxShadow(
                    //     color: Colors.grey,
                    //     offset: const Offset(-0.3, -1.5),
                    //     blurRadius: 0.0,
                    //     spreadRadius: 1.0,
                    //   ), //BoxShadow
                    // ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/ihl.png',
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                ),
                Text(
                  "India Health Link © 2024 \n   All Rights Reserved",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      fontFamily: 'Poppins-Black',
                      color: Colors.white),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 80,
                ),
                SpinKitThreeBounce(
                  color: Colors.white,
                  size: 17,
                ),
              ],
            ),
          ),
          // child: Stack(
          //   children: [
          //     SpinKitRipple(
          //       color: Colors.white,
          //       duration: Duration(seconds: 4),
          //       size: 300,
          //       borderWidth: 50,
          //     ),
          //     Center(
          //       child: Container(
          //         width: 80,
          //         decoration: BoxDecoration(
          //             color: Colors.white, shape: BoxShape.circle),
          //         child: Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Image.asset(
          //             'assets/images/ihl.png',
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }

  Future<void> notificationPermission({bool deepLink}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Permission Request',
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Need user permission for Notification'),
                Text('Decline would cause issues in Notification'),
              ],
            ),
          ),
          actions: <Widget>[
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.primaryColor,
              ),
              child: Text('Allow'),
              onPressed: () async {
                // await AwesomeNotifications()
                //     .requestPermissionToSendNotifications();
                Get.back();
                isLoggedIn(deepLink: deepLink);
                //
                // notificationsAllowed =
                //     await AwesomeNotifications().isNotificationAllowed();
                if (this.mounted) {
                  setState(() {
                    notificationsAllowed = notificationsAllowed;
                  });
                }
              },
            ),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.primaryColor,
              ),
              child: Text('Later'),
              onPressed: () async {
                Get.back();
                isLoggedIn(deepLink: deepLink);
                // notificationsAllowed =
                //     await AwesomeNotifications().isNotificationAllowed();
                if (this.mounted) {
                  setState(() {
                    notificationsAllowed = notificationsAllowed;
                  });
                }
              },
            ),
            SizedBox(
              width: 60,
            ),
          ],
        );
      },
    );
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
