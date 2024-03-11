import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ihl/checkin_notification/checkinDataFcm.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/widgets/signin_email.dart';

import 'constants/spKeys.dart';
import 'new_design/app/utils/localStorageKeys.dart';
import 'new_design/data/model/loginModel/vitalsData.dart';
import 'new_design/data/providers/network/api_provider.dart' as notify;
// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'health_challenge/models/challenge_detail.dart';
import 'main.dart';
import 'new_design/module/online_serivices/data/model/get_spec_class_list.dart';
import 'new_design/module/online_serivices/presentation/online_class_screens/book_class_before_subscription.dart';
import 'new_design/presentation/controllers/splashScreenController/splash_screen_controller.dart';
import 'new_design/presentation/pages/healthTips/tipsDetailedScreen.dart';
import 'new_design/presentation/pages/manageHealthscreens/manageHealthScreentabs.dart';
import 'new_design/presentation/pages/myVitals/myVitalsDashBoard.dart';
import 'views/affiliation/bookClassForAffiliation.dart';
import 'views/news_letter/news_letter_screen.dart';
import 'new_design/presentation/bindings/initialControllerBindings.dart';
import 'views/tips/tips_screen.dart';
import 'widgets/teleconsulation/bookClass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants/api.dart';
import 'health_challenge/controllers/challenge_api.dart';
import 'health_challenge/models/enrolled_challenge.dart';
import 'health_challenge/views/challenge_details_screen.dart';
import 'health_challenge/views/on_going_challenge.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data != null) {
    //_showNotification();
    Get.offAll(TipsScreen());
  }
  if (message.data.containsKey('data')) {
    // Handle data message
    final data = message.data['data'];
  }

  if (message.data.containsKey('notification')) {
    // Handle notification message
    final notification = message.data['notification'];
  }
  // Or do other work.
}

class FCM {
  http.Client _client = http.Client(); //3gb

  final _firebaseMessaging = FirebaseMessaging.instance;

  final streamCtlr = StreamController<String>.broadcast();
  final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();

  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.setString('affUniqueNameList', jsonEncode(affUniqueNameList));
  var affUniqueNameList_cpy = [];

  setNotifications() async {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging _messaging = FirebaseMessaging.instance;
    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
        alert: true, badge: true, provisional: false, sound: true, criticalAlert: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // TODO: handle the received notifications
    }

    // handle when app in active state
    forgroundNotification();

    // handle when app running in background state
    backgroundNotification();

    // handle when app completely closed by the user
    terminateNotification();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ihlId = prefs.getString("ihlUserId");
    // With this token you can test it easily on your phone
    final token = _firebaseMessaging.getToken().then((value) => updateTokenApi(ihlId, value));
  }

  getClassDetails(id) async {
    try {
      final response =
          await _client.get(Uri.parse('${API.iHLUrl}/consult/getClassDetail?classId=$id'));
      if (response.statusCode == 200) {
        if (response.body != 'null' && response.body != '') {
          return jsonDecode(response.body);
        }
      }
    } catch (e) {}
    //5fdf6bdb22f842ec8c46144d9d3aebcc
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'plain title',
      'plain body',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> _showVitalsNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Results Ready!',
      'Thanks for using hPod.',
      platformChannelSpecifics,
      payload: 'item x',
    );
    // Set up the onSelectNotification callback
    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings(
            '@mipmap/ic_launcher'), // Replace 'app_icon' with your app's launcher icon
        iOS: IOSInitializationSettings(),
      ),
      onSelectNotification: onSelectNotification,
    );
  }

  Future<void> onSelectNotification(String payload) async {
    // Handle notification tap here
    // You can use the payload to determine which page to navigate to

    // For example, navigate to a DetailsPage
    Get.to(ManageHealthScreenTabs(
      naviBack: 0,
    ));
  }

  forgroundNotification() {
    FirebaseMessaging.onMessage.listen(
      (message) async {
        notify.API.formNotifcation = true;
        // _showNotification();
        if (message.data.containsKey('about')) {
          // Handle data message
          if (message.data['about'] == "checkin") {
            await _showVitalsNotification();
            CheckinDataFcm().updateCheckinData(message.data['vitals']);
            listenVitals.value = true;
            listenVitals.notifyListeners();
            // SpUtil.putString(LSKeys.lastCheckin, message.data['vitals']);
            // VitalData().updateData();
          }
          if (message.data['about'] == "tips") {
            // await AwesomeNotifications().createNotification(
            //     content: NotificationContent(
            //         id: 1,
            //         channelKey: 'daily_tips',
            //         title: message.notification.title,
            //         body: message.notification.body,
            //         payload: {"file": message.notification.body},
            //         locked: false));
            await flutterLocalNotificationsPlugin.show(
              1,
              message.notification.title,
              message.notification.body,
              daily_tips,
              payload: jsonEncode({
                "file": message.notification.body,
                'channelKey': 'daily_tips',
                'id': message.data['healthtip_id']
              }),
            );
          } else if (message.data['about'] == "news_letter") {
            // await AwesomeNotifications().createNotification(
            //     content: NotificationContent(
            //         id: 1,
            //         channelKey: 'news_letter',
            //         title: message.notification.title,
            //         body: message.notification.body,
            //         payload: {"file": message.notification.body},
            //         locked: false));
            await flutterLocalNotificationsPlugin.show(
              1,
              message.notification.title,
              message.notification.body,
              news_letter,
              payload: jsonEncode({"file": message.notification.body, 'channelKey': 'news_letter'}),
            );
          } else if (message.data['about'] == "class_created_notification") {
            if (message.data["ihl"] == "true") {
              // SharedPreferences prr = await SharedPreferences.getInstance();
              Map course = await getClassDetails(message.data['class_id']);
              var courses = {};
              await flutterLocalNotificationsPlugin.show(
                1,
                message.notification.title,
                message.notification.body,
                class_created_notification,
                payload: jsonEncode({
                  "affiliation_name": message.data['affiliation_name'],
                  "ihl": message.data["ihl"],
                  "url": message.data["url"],
                  "course": jsonEncode(course),
                  "affUniqueNameList": jsonEncode(affUniqueNameList_cpy),
                  "exclusive_only": message.data['exclusive_only'].toString(),
                  'channelKey': 'class_created_notification'
                }),
              );
            } else {
              // await AwesomeNotifications().createNotification(
              //     content: NotificationContent(
              //         id: 1,
              //         channelKey: 'class_created_notification',
              //         title: message.notification.title,
              //         body: message.notification.body,
              //         // payload: {"file": jsonEncode(message.data)},
              //         // payload: {"file": message.notification.body},
              //         payload: {
              //           "affiliation_name": message.data['affiliation_name'],
              //           "ihl": message.data["ihl"],
              //           "url": message.data["url"],
              //           "affUniqueNameList": jsonEncode(affUniqueNameList_cpy),
              //           "exclusive_only":
              //               message.data['exclusive_only'].toString(),
              //         },
              //         locked: false));
              await flutterLocalNotificationsPlugin.show(
                1,
                message.notification.title,
                message.notification.body,
                class_created_notification,
                payload: jsonEncode({
                  "affiliation_name": message.data['affiliation_name'],
                  "ihl": message.data["ihl"],
                  "url": message.data["url"],
                  "affUniqueNameList": jsonEncode(affUniqueNameList_cpy),
                  "exclusive_only": message.data['exclusive_only'].toString(),
                  'channelKey': 'class_created_notification'
                }),
              );
            }
          } else if (message.data['about'] == "challenge") {
            await flutterLocalNotificationsPlugin.show(
              1,
              message.notification.title,
              message.notification.body,
              news_letter,
              payload: jsonEncode({
                "title": message.notification.body,
                'challenge_id': message.data['challenge_id'],
                'channelKey': 'challenge'
              }),
            );
          }

          streamCtlr.sink.add(message.data['data']);
        }
        if (message.data.containsKey('data')) {
          // Handle data message
          streamCtlr.sink.add(message.data['data']);
        }
        if (message.data.containsKey('notification')) {
          // Handle notification message
          streamCtlr.sink.add(message.data['notification']);
        }
        // Or do other work.
        titleCtlr.sink.add(message.notification.title);
        bodyCtlr.sink.add(message.notification.body);
      },
    );
  }

  backgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        notify.API.formNotifcation = true;

        print("open tips background");
        print('Message From Notification ${message.data}');

        if (message.data.containsKey('about')) {
          // Handle data message
          if (message.data['about'] == "tips") {
            var _imageUrl;
            var _content;
            var _title;
            http.Response response = await http.get(Uri.parse(
                '${API.iHLUrl}/pushnotification/get_health_tip_detail?health_tip_id=' +
                    message.data['healthtip_id']));
            if (response.statusCode == 200) {
              var deCodeData = json.decode(response.body);
              _title = deCodeData['health_tip_title'];
              var message = deCodeData['message'];
              message = message.replaceAll('&amp;', '&');
              message = message.replaceAll('&quot;', '"');
              message = message.replaceAll("\\r\\n", '');

              _content = message;
              _imageUrl = deCodeData['health_tip_blob_url'];
            }
            Get.offAll(TipsDetailedScreen(
              imagepath: _imageUrl,
              fromNotification: true,
              message: _content,
              title: _title,
            ));
          } else if (message.data['about'] == "news_letter") {
            Get.offAll(NewsLetterScreen());
          } else if (message.data['about'] == "class_created_notification") {
            SharedPreferences prr = await SharedPreferences.getInstance();
            // var c = prr.get('fcmN_c');
            // var d = prr.get('fcmN_d');
            // var course = jsonDecode(c);
            if (message.data['ihl'] == "true") {
              var course = await getClassDetails(message.data['class_id']);
              // var courses = jsonDecode(d);
              var courses = {};
              String company_name = '';
              List clsAffNameList = jsonDecode(message.data['affiliation_name']);
              clsAffNameList.forEach((element) {
                if (affUniqueNameList_cpy.contains(element) == true) {
                  company_name = element.toString();
                }
              });
              var exclusive_only = message.data['exclusive_only'].toString();

              ///todo

              if (exclusive_only == 'false' && company_name != '') {
                var affClassNav = false;
                affUniqueNameList_cpy.forEach((element) {
                  if (clsAffNameList.contains(element) == true) {
                    //affiliation class
                    affClassNav = true;
                  }
                });
                if (affClassNav) {
                  Get.to(BookClassbeforeSubscription(
                    classDetail: course,
                  ));
                  // Get.offAll(
                  //     BookClassForAffiliation(
                  //       notificationRoute: true,
                  //       course: course,
                  //       courses: courses,
                  //       companyName: company_name,
                  //     ),
                  //     binding: InitialBindings());
                } else {
                  Get.to(BookClassbeforeSubscription(
                    classDetail: course,
                  ));
                  // Get.offAll(
                  //     BookClass(
                  //       course: course,
                  //       courses: courses,
                  //       notificationRoute: true,
                  //     ),
                  //     binding: InitialBindings());
                }
              } else {
                if (company_name == '') {
                  Get.to(BookClassbeforeSubscription(
                    classDetail: course,
                  ));
                  // Get.offAll(
                  //     BookClass(
                  //       notificationRoute: true,
                  //       course: course,
                  //       courses: courses,
                  //     ),
                  //     binding: InitialBindings());
                } else {
                  Get.to(BookClassbeforeSubscription(
                    classDetail: course,
                  ));
                  // Get.offAll(
                  //     BookClassForAffiliation(
                  //       notificationRoute: true,
                  //       course: course,
                  //       courses: courses,
                  //       companyName: company_name,
                  //     ),
                  //     binding: InitialBindings());
                }
              }
            } else {
              ///url launcher
              var url = message.data["url"];
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            }
          } else if (message.data['about'] == "challenge") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var iHLUserId = prefs.getString("ihlUserId");
            Object password = prefs.get(SPKeys.password);
            Object email = prefs.get(SPKeys.email);
            Object authToken = prefs.get(SPKeys.authToken);
            Object isSso = prefs.get(SPKeys.is_sso);
            if ((password == '' ||
                    password == null ||
                    email == '' ||
                    email == null ||
                    authToken == '' ||
                    authToken == null) &&
                (isSso == '' || isSso == "false" || isSso == null)) {
              Get.offAll(const LoginEmailScreen(
                deepLink: false,
              ));
            } else {
              List<EnrolledChallenge> _enrollList =
                  await ChallengeApi().listofUserEnrolledChallenges(userId: iHLUserId);
              ChallengeDetail challengeDetail =
                  await ChallengeApi().challengeDetail(challengeId: message.data['challenge_id']);
              var _enroll = _enrollList
                  .where((element) => element.challengeId == challengeDetail.challengeId);
              if (_enroll.isNotEmpty) {
                var _groupModel;
                if (challengeDetail.challengeMode != 'individual') {
                  _groupModel =
                      await ChallengeApi().challengeGroupDetail(groupID: _enroll.first.groupId);
                }
                Get.to(OnGoingChallenge(
                  challengeDetail: challengeDetail,
                  navigatedNormal: false,
                  filteredList: _enroll.first,
                  groupDetail: _groupModel,
                ));
              } else {
                Get.to(
                    ChallengeDetailsScreen(
                      fromNotification: true,
                      challengeDetail: challengeDetail,
                    ),
                    binding: InitialBindings());
              }
            }
          }

          streamCtlr.sink.add(message.data['data']);
        } else {
          Get.offAll(TipsScreen());
        }
        if (message.data.containsKey('notification')) {
          // Handle notification message
          streamCtlr.sink.add(message.data['notification']);
        }
        // Or do other work.
        titleCtlr.sink.add(message.notification.title);
        bodyCtlr.sink.add(message.notification.body);
      },
    );
  }

  Future<void> terminateNotification() async {
    RemoteMessage initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      notify.API.formNotifcation = true;
      if (initialMessage.data.containsKey('about')) {
        // Handle data message
        if (initialMessage.data['about'] == "tips") {
          var _imageUrl;
          var _content;
          var _title;
          http.Response response = await http.get(Uri.parse(
              '${API.iHLUrl}/pushnotification/get_health_tip_detail?health_tip_id=' +
                  initialMessage.data['healthtip_id']));
          if (response.statusCode == 200) {
            var deCodeData = json.decode(response.body);
            _title = deCodeData['health_tip_title'];
            var message = deCodeData['message'];
            message = message.replaceAll('&amp;', '&');
            message = message.replaceAll('&quot;', '"');
            message = message.replaceAll("\\r\\n", '');

            _content = message;
            _imageUrl = deCodeData['health_tip_blob_url'];
          }
          Get.offAll(TipsDetailedScreen(
            fromNotification: true,
            imagepath: _imageUrl,
            message: _content,
            title: _title,
          ));
        } else if (initialMessage.data['about'] == "news_letter") {
          Get.offAll(NewsLetterScreen());
        } else if (initialMessage.data['about'] == "class_created_notification") {
          SharedPreferences prr = await SharedPreferences.getInstance();
          // var c = prr.get('fcmN_c');
          // var d = prr.get('fcmN_d');
          // var course = jsonDecode(c);
          if (initialMessage.data['ihl'] == 'true') {
            var course = await getClassDetails(initialMessage.data['class_id']);
            // var courses = jsonDecode(d);
            var courses = {};
            String company_name = '';
            List clsAffNameList = jsonDecode(initialMessage.data['affiliation_name']);
            clsAffNameList.forEach((element) {
              if (affUniqueNameList_cpy.contains(element) == true) {
                company_name = element.toString();
              }
            });
            var exclusive_only = initialMessage.data['exclusive_only'].toString();

            ///todo here we have to navigate to the particular class

            if (exclusive_only == 'false' && company_name != '') {
              var affClassNav = false;
              affUniqueNameList_cpy.forEach((element) {
                if (clsAffNameList.contains(element) == true) {
                  //affiliation class
                  affClassNav = true;
                }
              });
              if (affClassNav) {
                Get.to(BookClassbeforeSubscription(
                  classDetail: SpecialityClassList.fromJson(course),
                ));
                // Get.offAll(
                //     BookClassForAffiliation(
                //       notificationRoute: true,
                //       course: course,
                //       courses: courses,
                //       companyName: company_name,
                //     ),
                //     binding: InitialBindings());
              } else {
                Get.to(BookClassbeforeSubscription(
                  classDetail: SpecialityClassList.fromJson(course),
                ));
                // Get.offAll(
                //     BookClass(
                //       course: course,
                //       courses: courses,
                //       notificationRoute: true,
                //     ),
                //     binding: InitialBindings());
              }
            } else {
              if (company_name == '') {
                Get.to(BookClassbeforeSubscription(
                  classDetail: SpecialityClassList.fromJson(course),
                ));
                // Get.offAll(
                //     BookClass(
                //       notificationRoute: true,
                //       course: course,
                //       courses: courses,
                //     ),
                //     binding: InitialBindings());
              } else {
                Get.to(BookClassbeforeSubscription(
                  classDetail: SpecialityClassList.fromJson(course),
                ));
                // Get.offAll(
                //     BookClassForAffiliation(
                //       notificationRoute: true,
                //       course: course,
                //       courses: courses,
                //       companyName: company_name,
                //     ),
                //     binding: InitialBindings());
              }
            }
          } else {
            ///URL LAUNCHER
            var url = initialMessage.data["url"];
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          }
        } else if (initialMessage.data['about'] == "challenge") {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var iHLUserId = prefs.getString("ihlUserId");

          Object password = prefs.get(SPKeys.password);
          Object email = prefs.get(SPKeys.email);
          Object authToken = prefs.get(SPKeys.authToken);
          Object isSso = prefs.get(SPKeys.is_sso);
          if ((password == '' ||
                  password == null ||
                  email == '' ||
                  email == null ||
                  authToken == '' ||
                  authToken == null) &&
              (isSso == '' || isSso == "false" || isSso == null)) {
            Get.offAll(const LoginEmailScreen(
              deepLink: false,
            ));
          } else {
            List<EnrolledChallenge> _enrollList =
                await ChallengeApi().listofUserEnrolledChallenges(userId: iHLUserId);
            ChallengeDetail challengeDetail = await ChallengeApi()
                .challengeDetail(challengeId: initialMessage.data['challenge_id']);
            var _enroll =
                _enrollList.where((element) => element.challengeId == challengeDetail.challengeId);
            if (_enroll.isNotEmpty) {
              var _groupModel;
              if (challengeDetail.challengeMode != 'individual') {
                _groupModel =
                    await ChallengeApi().challengeGroupDetail(groupID: _enroll.first.groupId);
              }
              Get.offAll(OnGoingChallenge(
                challengeDetail: challengeDetail,
                navigatedNormal: false,
                filteredList: _enroll.first,
                groupDetail: _groupModel,
              ));
            } else {
              Get.offAll(
                  ChallengeDetailsScreen(
                    fromNotification: true,
                    challengeDetail: challengeDetail,
                  ),
                  binding: InitialBindings());
            }
          }
        }
      }
      if (initialMessage.data.containsKey('data')) {
        // Handle data message
        streamCtlr.sink.add(initialMessage.data['data']);
      }
      if (initialMessage.data.containsKey('notification')) {
        // Handle notification message
        streamCtlr.sink.add(initialMessage.data['notification']);
      }
      // Or do other work.
      titleCtlr.sink.add(initialMessage.notification.title);
      bodyCtlr.sink.add(initialMessage.notification.body);
    }
  }

  dispose() {
    streamCtlr.close();
    bodyCtlr.close();
    titleCtlr.close();
  }

  updateTokenApi(String iHLUserId, String fcmToken) async {
    print('FCM $fcmToken');

    ///Todo  in sign up flow(watingn screen) and sign in (sign in pwd) -> //done
    final updateFcmToken = await _client.post(
        Uri.parse("${API.iHLUrl}/consult/fire_base_instance_upload_replace"),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(
            <String, String>{'ihl_user_id': iHLUserId, 'fcm_token': fcmToken, 'app': "care"}));
    var rep = updateFcmToken.body;
    //if user is affiliated then call a function and send the affilation name list in that
    // and in that function ->  we will have a for loop that will subscribe for every unique name in the list,
  }

  TopicSubscription(List affUniqueNameList) async {
    affUniqueNameList_cpy = affUniqueNameList;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ihlId = prefs.getString("ihlUserId");
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('affUniqueNameList', jsonEncode(affUniqueNameList));

    await FirebaseMessaging.instance.subscribeToTopic('${API.extraKeyWord}' + 'TipsTopic');
    await FirebaseMessaging.instance.subscribeToTopic('${API.extraKeyWord}' + 'NewspaperTopic');
    await FirebaseMessaging.instance.subscribeToTopic('${API.extraKeyWord}' + 'ClassIhlTopic');
    await FirebaseMessaging.instance.subscribeToTopic('${API.extraKeyWord}' + 'ClassOthersTopic');
    await FirebaseMessaging.instance
        .subscribeToTopic('${API.extraKeyWord}' + 'newcheckin' + ihlId.toString());
    if (affUniqueNameList.length < 1) {
      await FirebaseMessaging.instance.subscribeToTopic('${API.extraKeyWord}' + 'ChallengeTopic');
    }
    // var affUniqueNameList = [];///instead of here this will be sent from where we call this function
    for (int i = 0; i < affUniqueNameList.length; i++) {
      print('${API.extraKeyWord}' + '${affUniqueNameList[i].toString()}_TipsTopic');
      await FirebaseMessaging.instance
          .subscribeToTopic('${API.extraKeyWord}' + '${affUniqueNameList[i].toString()}_TipsTopic');
      await FirebaseMessaging.instance.subscribeToTopic(
          '${API.extraKeyWord}' + '${affUniqueNameList[i].toString()}_ClassOthersTopic');
      await FirebaseMessaging.instance.subscribeToTopic(
          '${API.extraKeyWord}' + '${affUniqueNameList[i].toString()}_ClassIhlTopic');
      await FirebaseMessaging.instance.subscribeToTopic(
          '${API.extraKeyWord}' + '${affUniqueNameList[i].toString()}_ChallengeTopic');
    }
  }

  TopicUnsubscription(List affUniqueNameList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ihlId = prefs.getString("ihlUserId");
    await FirebaseMessaging.instance.subscribeToTopic('${API.extraKeyWord}' + 'newcheckin' + ihlId);
    await FirebaseMessaging.instance.unsubscribeFromTopic('${API.extraKeyWord}' + 'TipsTopic');
    await FirebaseMessaging.instance.unsubscribeFromTopic('${API.extraKeyWord}' + 'NewspaperTopic');
    await FirebaseMessaging.instance.unsubscribeFromTopic('${API.extraKeyWord}' + 'ClassIhlTopic');
    await FirebaseMessaging.instance
        .unsubscribeFromTopic('${API.extraKeyWord}' + 'ClassOthersTopic');
    await FirebaseMessaging.instance.unsubscribeFromTopic('${API.extraKeyWord}' + 'ChallengeTopic');
    // var affUniqueNameList = [];///instead of here this will be sent from where we call this function
    for (int i = 0; i < affUniqueNameList.length; i++) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(
          '${API.extraKeyWord}' + '${affUniqueNameList[i].toString()}_TipsTopic');
      await FirebaseMessaging.instance.unsubscribeFromTopic(
          '${API.extraKeyWord}' + '${affUniqueNameList[i].toString()}_ClassOthersTopic');
      await FirebaseMessaging.instance.unsubscribeFromTopic(
          '${API.extraKeyWord}' + '${affUniqueNameList[i].toString()}_ClassIhlTopic');
      await FirebaseMessaging.instance.unsubscribeFromTopic(
          '${API.extraKeyWord}' + '${affUniqueNameList[i].toString()}_ChallengeTopic');
    }
    try {
      // final _firebaseMessaging = FirebaseMessaging.instance;
      _firebaseMessaging.deleteToken();
    } catch (e) {
      print('delete instance failed');
    }
  }
}
