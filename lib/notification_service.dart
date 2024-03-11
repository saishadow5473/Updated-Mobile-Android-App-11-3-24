import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ihl/views/affiliation/bookClassForAffiliation.dart';
import 'package:ihl/views/news_letter/news_letter_screen.dart';
import 'package:ihl/views/tips/tips_detail_screen.dart';
import 'package:ihl/widgets/signin_email.dart';
import 'package:ihl/widgets/teleconsulation/bookClass.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'constants/api.dart';
import 'constants/spKeys.dart';
import 'health_challenge/controllers/challenge_api.dart';
import 'health_challenge/models/challenge_detail.dart';
import 'health_challenge/models/enrolled_challenge.dart';
import 'health_challenge/views/challenge_details_screen.dart';
import 'health_challenge/views/on_going_challenge.dart';
import 'main.dart';
import 'new_design/module/online_serivices/data/model/get_spec_class_list.dart';
import 'new_design/module/online_serivices/presentation/online_class_screens/book_class_before_subscription.dart';
import 'new_design/presentation/bindings/initialControllerBindings.dart';
import 'new_design/presentation/pages/healthTips/tipsDetailedScreen.dart';

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

const MethodChannel platform = MethodChannel('dexterx.dev/flutter_local_notifications_example');

class ReceivedNotification {
  const ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
  });
  final int id;
  final String title;
  final String body;
  final String payload;
}

String selectedNotificationPayload;

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('sample_large_icon');

    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
        defaultPresentBadge: true,
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (
          int id,
          String title,
          String body,
          String payload,
        ) async {
          didReceiveLocalNotificationSubject.add(
            ReceivedNotification(
              id: id,
              title: title,
              body: body,
              payload: payload,
            ),
          );
        });

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS, macOS: null);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
        selectNotification(jsonDecode(payload));
      }
      // selectedNotificationPayload = payload;
      // selectNotificationSubject.add(payload);
      else {
        ///probabbly restart or somethig
      }
    });
  }

  Future selectNotification(payload) async {
    var channelKey = payload['channelKey'];
    var isReload = false;
    if (isReload != true) {
      // FlutterLocalNotifications()
      //     AwesomeNotifications()
      //     .actionStream
      //     .listen((receivedNotification) async
      {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        String path = prefs.getString("pathFromBillView");

        String instructionsPath = prefs.getString("pathFromInstructions");
        String certificatePath = prefs.getString("certificate");

        String summaryPath = prefs.getString("pathFromBillViewConsultationSummary");

        if (channelKey == "prescription_progress") {
          if (instructionsPath != null && instructionsPath != "") {
            OpenFile.open(instructionsPath);
            prefs.setString("pathFromInstructions", "");
          }
        } else if (channelKey == "certificateKey") {
          if (certificatePath != null && certificatePath != "") {
            OpenFile.open(certificatePath);
            prefs.setString("certificate", "");
          }
        } else if (channelKey == "bill_progress") {
          if (path != null && path != "") {
            OpenFile.open(path);
            prefs.setString("pathFromBillView", "");
          }
        } else if (channelKey == "bill_progress_consultation_summary") {
          if (summaryPath != null && summaryPath != "") {
            OpenFile.open(summaryPath);
            prefs.setString("pathFromBillViewConsultationSummary", "");
          }
        } else if (channelKey == "daily_tips") {
          var _imageUrl;
          var _content;
          var _title;
          http.Response response = await http.get(Uri.parse(
              '${API.iHLUrl}/pushnotification/get_health_tip_detail?health_tip_id=' +
                  payload['id']));
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
            message: _content,
            fromNotification: true,
            title: _title,
          ));
        } else if (channelKey == "news_letter") {
          // if (receivedNotification.payload.containsKey('file') ||
          if (payload.containsKey('file') ||
              // !receivedNotification.payload.containsKey('path')) {
              !payload.containsKey('path')) {
            Get.offAll(NewsLetterScreen());
          } else {
            var news_path = payload['path'];
            debugPrint(news_path);
            final _result = await OpenFile.open(news_path);
          }
        } else if (channelKey == "class_created_notification") {
          SharedPreferences prr = await SharedPreferences.getInstance();
          // var c = prr.get('fcmN_c');
          // var d = prr.get('fcmN_d');
          // var course = jsonDecode(c);

          ///todo remove this dummy var use proper data that received from the firebase api
          // var company_name = receivedNotification.payload["affiliation_name"];//fpr
          var ihl_app = payload["ihl"];
          if (ihl_app == "true") {
            dynamic course = jsonDecode(payload["course"]);
            List affUniqueNameList = jsonDecode(payload["affUniqueNameList"]);
            // var courses = jsonDecode(d);
            var courses = {};
            List clsAffNameList = jsonDecode(payload["affiliation_name"]);
            var company_name = '';
            clsAffNameList.forEach((element) {
              if (affUniqueNameList.contains(element) == true) {
                company_name = element.toString();
              }
            });
            // if (message.data['affiliation_name'] == '') {

            var exclusive = payload["exclusive_only"];
            if (exclusive == 'false' && company_name != '') {
              var affClassNav = false;
              affUniqueNameList.forEach((element) {
                if (clsAffNameList.contains(element) == true) {
                  //affiliation class
                  affClassNav = true;
                }
              });

              if (affClassNav) {
                Get.to(BookClassbeforeSubscription(
                  classDetail: SpecialityClassList.fromJson(course.toJson()),
                ));
                // Get.offAll(BookClassForAffiliation(
                //   notificationRoute: true,
                //   course: course,
                //   courses: courses,
                //   companyName: company_name,
                // ));
              } else {
                Get.to(BookClassbeforeSubscription(
                  classDetail: SpecialityClassList.fromJson(course),
                ));
                // Get.offAll(BookClass(
                //   course: course,
                //   courses: courses,
                //   notificationRoute: true,
                // ));
              }
            } else {
              if (company_name == '') {
                Get.to(BookClassbeforeSubscription(
                  classDetail: SpecialityClassList.fromJson(course),
                ));
                // Get.offAll(BookClass(
                //   course: course,
                //   courses: courses,
                //   notificationRoute: true,
                // ));
                // Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => BookClass(
                //         course: course,
                //         courses: courses,
                //         notificationRoute: true,
                //       ),
                //     ),
                //         (Route<dynamic> route) => false);
              } else {
                //affiliation class
                // Get.offAll(BookClassForAffiliation(
                //   notificationRoute: true,
                //   course: course,
                //   courses: courses,
                //   companyName: company_name,
                // ));
                Get.to(BookClassbeforeSubscription(
                  classDetail: SpecialityClassList.fromJson(course),
                ));
              }
            }
          } else {
            ///url launcher
            ///var ihl_app = receivedNotification.payload["ihl"];
            var url = payload["url"];
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          }
        } else if (channelKey == 'challenge') {
          SharedPreferences prefs1 = await SharedPreferences.getInstance();
          var iHLUserId = prefs1.getString("ihlUserId");
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
            Get.offAll(const LoginEmailScreen(
              deepLink: false,
            ));
          } else {
            List<EnrolledChallenge> _enrollList =
                await ChallengeApi().listofUserEnrolledChallenges(userId: iHLUserId);
            ChallengeDetail challengeDetail =
                await ChallengeApi().challengeDetail(challengeId: payload['challenge_id']);
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
    }
  }
}

initChanelPrescriptionProgress() {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'prescription_progress',
    'prescription',
    channelDescription: 'for prescription_progress',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    channelShowBadge: true,
  );
  const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  print('initialized for prescription_progress');
  return platformChannelSpecifics;
}

initChannelBillProgress() {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'bill_progress',
    'bill',
    channelDescription: 'for bill_progress',
    importance: Importance.max,
    priority: Priority.high,
    channelShowBadge: true,
    ticker: 'ticker',
  );
  const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  print('initialized for bill_progress');
  return platformChannelSpecifics;
}

initChannelBillProgressConsultationSummary() {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'bill_progress_consultation_summary',
    'bill_progress_consultation_summary',
    channelDescription: 'for bill_progress_consultation_summary',
    importance: Importance.max,
    priority: Priority.high,
    channelShowBadge: true,
    ticker: 'ticker',
  );
  const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  print('initialized for bill_progress_consultation_summary');
  return platformChannelSpecifics;
}

initChannelDailyTips() {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'daily_tips',
    'daily',
    channelDescription: 'for daily_tips',
    importance: Importance.max,
    priority: Priority.high,
    channelShowBadge: true,
    ticker: 'ticker',
  );
  const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  print('initialized for prescription_progress');
  return platformChannelSpecifics;
}

initChannelWaterReminder() {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'water',
    'water',
    channelDescription: 'for Water Reminder',
    importance: Importance.max,
    priority: Priority.high,
    channelShowBadge: true,
    ticker: 'ticker',
  );
  const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  print('initialized for prescription_progress');
  return platformChannelSpecifics;
}

initChannelNewsLetter() {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'news_letter',
    'news',
    channelDescription: 'for news_letter',
    importance: Importance.max,
    priority: Priority.high,
    channelShowBadge: true,
    ticker: 'ticker',
  );
  const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  print('initialized for prescription_progress');
  return platformChannelSpecifics;
}

initChannelClassCreated() {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'class_created_notification',
    'class_created',
    channelDescription: 'for class_created_notification',
    importance: Importance.max,
    priority: Priority.high,
    channelShowBadge: true,
    ticker: 'ticker',
  );
  const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  print('initialized for class_created_notification');
  return platformChannelSpecifics;
}
