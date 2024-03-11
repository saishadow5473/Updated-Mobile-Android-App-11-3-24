import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../pages/basicData/functionalities/percentage_calculations.dart';
import '../../pages/basicData/models/basic_data.dart';
import '../../../../widgets/signin_email.dart';
import '../dashboardControllers/dashBoardContollers.dart';

// import 'package:ihl/constants/routes.dart';
import '../../../../main.dart';
import '../../../data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../../data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';
import '../healthchallenge/googlefitcontroller.dart';
import '../../pages/home/landingPage.dart';
import '../../pages/spalshScreen/splashScreen.dart';
import '../../../../utils/SpUtil.dart';
import '../../../../views/screens.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import '../../../../Getx/controller/listOfChallengeContoller.dart';
import '../../../../constants/api.dart';
import '../../../../constants/spKeys.dart';
import '../../../../notification_controller.dart';
import '../../../../views/dietDashboard/edit_profile_screen.dart';
import '../../../../views/otherVitalController/otherVitalController.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../Widgets/appBar.dart';
import '../../pages/spalshScreen/splashScreen.dart' as splash;
import '../../../data/providers/network/api_provider.dart' as notify;

class SplashScreenController extends GetxController {
  final TabBarController tabController = Get.put(TabBarController());

  @override
  void onInit() {
    SpUtil.getInstance();
    var logged = localSotrage.read(LSKeys.logged) ?? false;
    getData();

    tabController.programsTab.value = 0;
    getStoreData();
    handleInitialUri();
    getUserDetails();
    super.onInit();
  }

  // ignore: prefer_typing_uninitialized_variables
  var userAffiliated;
  String name = 'IHL User';
  String score = 'N/A';

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object raw = prefs.get(SPKeys.userData);
    Object password = prefs.get(SPKeys.password);
    if (raw == '' || raw == null) {
      raw = '{}';
    }
    Map data = jsonDecode(raw);
    Map user = data['User'];
    var userInputWeight;
    try {
      userInputWeight =
          data['User']['userInputWeightInKG'] ?? data['LastCheckin']['weightKG'].toStringAsFixed(2);

      prefs.setString('userInputWeight', userInputWeight);
    } catch (e) {
      userInputWeight = null;
    }
    BasicDataModel basicData;
    try {
      basicData = BasicDataModel(
        name: '${user['firstName']} ${user['lastName']}',
        dob: user.containsKey('dateOfBirth') ? user['dateOfBirth'].toString() : null,
        gender: user.containsKey('gender') ? user['gender'].toString() : null,
        height: user.containsKey("heightMeters") ? user["heightMeters"].toString() : null,
        mobile: user.containsKey("mobileNumber") ? user['mobileNumber'].toString() : null,
        weight: userInputWeight ?? null,
      );

      final GetStorage box = GetStorage();
      box.write('BasicData', basicData);
      PercentageCalculations().checkHowManyFilled();
      PercentageCalculations().calculatePercentageFilled();
    } catch (e) {
      print(e);
    }

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
      debugPrint(API.affNmLst.toString());
    }

    ///
    if (isSubscribedToTopic == false) {
      ////this two line
      final FCM firebaseMessaging = FCM();
      firebaseMessaging.setNotifications();
      firebaseMessaging.TopicSubscription(affUniqueNameList);
      isSubscribedToTopic = true;
      debugPrint(isSubscribedToTopic.toString());
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
    // if (this.mounted) {
    //   setState(() {});
    // }
    try {
      Get.find<ListChallengeController>().enrolledChallenge();
    } catch (e) {
      Get.put(ListChallengeController()).enrolledChallenge();
    }
  }

  Future getStoreData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    log('User Id SplashScreen :${SpUtil.getString(LSKeys.ihlUserId)}');

    debugPrint(
        'SharedPref Keys : ${prefs.getKeys.toString()} GetStorage Keys+${localSotrage.getKeys()}');
    debugPrint(prefs.get(
      'sso_token',
    ));

    //below is just setting to check is there any new app version available is so it will show in dashboard
    splash.localSotrage.write(LSKeys.needToCheckAppVersion, "yes");
    prefs.setString(SPKeys.needToCheckAppVersion, "yes");
    await Tabss.ssoFlow();
  }

  //Splash screen Variables 🏳‍🌈
  bool _initialUriIsHandled = false;
  Timer timerSplashScreen;
  Session approveOrRejectAppointmentSession;
  Client approveOrRejectAppointmentClient;
  String iHLUserId;

  Future<void> handleInitialUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final Uri uri = await getInitialUri();
        if (uri == null) {
          noDeepLink();
        } else {
          timerSplashScreen?.cancel();
          isLoggedIn(deepLink: true);
          debugPrint('got initial uri: $uri');
        }
      } on PlatformException {
        debugPrint('Falied to get initial uri');
      } on FormatException catch (err) {
        debugPrint('malformed initial uri: $err');
      }
    }
  }

  void noDeepLink({bool deepLink}) {
    _requestPermissions();
    timerSplashScreen?.cancel();
    isLoggedIn(deepLink: deepLink);
    // subscribeAppointmentApproved();// removed get user details
    // consultationStagesSessionMaintainer();// removed get user details

    //initailising timer CAM
    //deleting if older one exists🚩🚩🚩🚩🚩
    // timerCAM?.cancel();
    // isTimer90seconds = false;
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

  Future<bool> isLoggedIn({bool deepLink}) async {
    timerForSplashScreen();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object password = prefs.get(SPKeys.password);
    Object email = prefs.get(SPKeys.email);
    debugPrint('Email $email');
    Object authToken = prefs.get(SPKeys.authToken);
    Object isSso = prefs.get(SPKeys.is_sso);
    debugPrint(isSso);
    if ((password == '' ||
            password == null ||
            email == '' ||
            email == null ||
            authToken == '' ||
            authToken == null) &&
        (isSso == '' || isSso == "false" || isSso == null)) {
      logOut(deepLink: deepLink);
      return false;
    } else {
      try {
        login(deepLink: deepLink);
      } catch (e) {
        timerSplashScreen.cancel();
        // Navigator.of(context).pushNamedAndRemoveUntil(Routes.Home, (Route<dynamic> route) => false);
      }
      return true;
    }
  }

  Future login({bool deepLink}) async {
    String userInputWeight;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object password = prefs.get(SPKeys.password);
    Object email = prefs.get(SPKeys.email);
    Object authToken = prefs.get(SPKeys.authToken);
    // ignore: non_constant_identifier_names
    Object is_sso = prefs.get(SPKeys.is_sso);
    TabBarController tabController = Get.put(TabBarController());
    try {
      var response1 = await SplashScreenApiCalls().loginApi();
      if (response1 != null) {
        var resjd = response1;
        String encodedValue = jsonEncode(response1);
        if (encodedValue == 'null' ||
            encodedValue == null ||
            resjd == "Object reference not set to an instance of an object." ||
            encodedValue == "Object reference not set to an instance of an object.") {
          logOut(deepLink: deepLink);
          return;
        } else {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString(SPKeys.userData, jsonEncode(response1));
          await MyvitalsApi().vitalDatas(response1);
          print("Second");
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
          var decodedResponse = jsonDecode(encodedValue);
          try {
            userInputWeight = decodedResponse['User']['userInputWeightInKG'].toString();
          } catch (e) {
            userInputWeight = null;
          }
          String iHLUserToken = decodedResponse['Token'];
          iHLUserId = decodedResponse['User']['id'];
          SharedPreferences prefs1 = await SharedPreferences.getInstance();
          prefs1.setString("ihlUserId", iHLUserId);
          log('User Id: $iHLUserId');
          API.headerr = {};
          API.headerr['Token'] = iHLUserToken;
          API.headerr['ApiToken'] = is_sso != "true"
              ? '$authToken'
              : "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==";
          debugPrint("##############################################${API.headerr}");
          prefs1.setBool(LSKeys.logged, true);
          localSotrage.write(LSKeys.logged, true);
          // timerSplashScreen.cancel();

          /// this conditon is called from home screen already , no need here
          ////this two line
          // final firebaseMessaging = FCM();
          // firebaseMessaging.setNotifications();
          if (deepLink == true) {
            if (notify.API.formNotifcation == false) {
              Get.offAll(LandingPage(),
                  binding: BindingsBuilder(
                      () => Get.lazyPut<GoogleFitController>(() => GoogleFitController())));
            }
          } else {
            if (userInputWeight.toString() == 'null') {
              if (notify.API.formNotifcation == false) {
                // Get.offAll(const EditProfileScreen(    //old flow
                //   kisokAccountWithoutWeight: true,
                // ));
                Get.offAll(LandingPage(),
                    binding: BindingsBuilder(
                        () => Get.lazyPut<GoogleFitController>(() => GoogleFitController())));
              }
            } else {
              await MyvitalsApi().vitalDatas(response1);
              tabController.programsTab.value = 0;
              if (notify.API.formNotifcation == false) Get.offAll(LandingPage());
            }
          }

          // Fetch all Vital data API call
          final vitalData = await SplashScreenApiCalls()
              .checkinData(ihlUID: iHLUserId, ihlUserToken: iHLUserToken);
          // await http.get(
          //   Uri.parse(API.iHLUrl + '/data/user/' + iHLUserId + '/checkin'),
          //   headers: {
          //     'Content-Type': 'application/json',
          //     'Token': iHLUserToken,
          //     'ApiToken':
          //         "GHG5118RtDtd7C9AXHa9d/i0WDated53MlFmHgDK4n+8s86uo2s4HMvJkWCbKM5485lCRsBc6uTSlUuuzbWMGsJV3q+PEmAfvoVmjF8bKUgBAA=="
          //   },
          // );
          if (vitalData != null) {
            final SharedPreferences sharedUserVitalData = await SharedPreferences.getInstance();
            sharedUserVitalData
                .setString(SPKeys.vitalsData, jsonEncode(vitalData))
                .then(((bool value) {
              timerSplashScreen.cancel();
            }));
          } else {
            timerSplashScreen.cancel();
          }
        }
      } else {
        logOut(deepLink: deepLink);
      }
    } catch (e) {
      debugPrint("Internet is not stable");
    }
  }

  Future logOut({bool deepLink}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    timerSplashScreen.cancel();
    final GetStorage box = GetStorage();
    localSotrage.remove(LSKeys.vitalsData);
    localSotrage.remove((LSKeys.vitalStatus));
    await localSotrage.erase();

    box.write(LSKeys.logged, false);
    prefs.clear().then((bool value) async {
      timerSplashScreen.cancel();
      if (notify.API.formNotifcation == false) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        SpUtil.clear();
        localSotrage.erase();
        await Future.delayed(Duration(seconds: 3), () {
          Get.offAll(LoginEmailScreen(
            deepLink: deepLink,
          ));
          // Code to execute after a 2-second delay
        });

        // });
        // Get.offAll(WelcomePage(
        //   deepLink: deepLink,
        // ));
      }
    });
  }

  //timer to check splashscreenkeeps on loading Function for 30seconds
  Future<void> timerForSplashScreen() async {
    timerSplashScreen = Timer.periodic(const Duration(seconds: 40), (Timer timer30sec) {
      // ignore: no_leading_underscores_for_local_identifiers
      _buildChild(BuildContext context) => Container(
            height: 36.h,
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
                        children: [
                          Icon(
                            // ignore: deprecated_member_use
                            FontAwesomeIcons.frown,
                            size: 30.sp,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 4.h,
                          ),
                          Text(
                            'Poor Internet Connection',
                            style: TextStyle(
                                fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16),
                  child: Text(
                    'Please Try Loading Again',
                    style: TextStyle(color: Colors.black, fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 3.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 65.w,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffE57373),
                          textStyle: const TextStyle(color: Colors.white),
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Center(
                          child: Text(
                            'RETRY',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                        onPressed: () {
                          timerSplashScreen.cancel();
                          if (notify.API.formNotifcation == false) {
                            Get.offAll(const splash.SplashScreen());
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
      showDialog(
          context: Get.context,
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
                reconnectCount: 10, reconnectTime: const Duration(milliseconds: 200)))
        .first;

    try {
      final Subscribed subscription = await approveOrRejectAppointmentSession.subscribe(
          'ihl_send_data_to_user_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((Event event) {
        Map<String, dynamic> data = event.arguments[0];
        var status = data['data']['status'];
        if (status == 'Approved') {
          // getUserDetails();
        }
        if (status == 'Rejected') {
          // getUserDetails();
        }
        if (status == 'CancelAppointment') {
          // getUserDetails();
        }
      });
      await subscription.onRevoke.then(
          (String reason) => debugPrint('The server has killed my subscription due to: $reason'));
    } on Abort catch (abort) {
      print(abort.message.message);
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

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userid = prefs.getString("ihlUserId");
    if (SpUtil.getString(LSKeys.ihlUserId) != null) {
      final getUserDetails = await SplashScreenApiCalls().getDetailsApi(ihlUID: userid);
      if (getUserDetails != null) {
        final SharedPreferences userDetailsResponse = await SharedPreferences.getInstance();
        userDetailsResponse.setString(SPKeys.userDetailsResponse, jsonEncode(getUserDetails));
      } else {
        print(getUserDetails.toString());
      }
    }
  }

  //timer to run checkAndMaintainSeesion Function for every 3seconds
  Future<void> consultationStagesSessionMaintainer() async {
    // ignore: unused_local_variable
    Timer timerConsultationStagesSession = Timer.periodic(
      const Duration(seconds: 3),
      (Timer timer3secConsultationStagesSession) {
        if (approveOrRejectAppointmentSession != null) {
          approveOrRejectAppointmentSession.onConnectionLost
              .then((value) => subscribeAppointmentApproved());
        } else {
          subscribeAppointmentApproved();
        }
      },
    );
  }
}
