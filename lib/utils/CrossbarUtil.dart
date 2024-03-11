import 'dart:async';
import 'dart:convert';

import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/views/network_issue/noInternetPage.dart';
import 'package:ihl/views/screens.dart';
import 'package:ihl/views/teleconsultation/mySubscriptions.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../new_design/data/providers/FireStoreServices/FireStoreServiceProvider.dart';
import '../new_design/presentation/pages/onlineServices/MyAppointment.dart';
import '../views/teleconsultation/MySubscription.dart';

Client client;
Session session;
Subscribed subscription;
Subscribed statusSubscription;
var data;
String userId;
bool iscallError = false;
var callErrorAppointmentId;
bool isTimer90seconds = false;
Timer timerCAM;
bool isNavigatedToNoInternetPage = false;
bool istimerForCAM = false;
String currentPage = "";
bool isCallTerminated = false;
http.Client _client = http.Client(); //3gb
//timer to run checkAndMaintainSeesion Function for every 5 seconds
Future<void> timerForCAM() async {
  timerCAM = new Timer.periodic(
    Duration(seconds: 1),
    (timer3secCAM) {
      if (istimerForCAM == false) {
        checkAndMaintainSession();
      } else {
        timer3secCAM.cancel();
      }
    },
  );
}

//public function to check the internet status and maintain the appointmentSubscribe sessions alive
checkAndMaintainSession() async {
  bool result = await DataConnectionChecker().hasConnection;

  var connectivityResult = await Connectivity().checkConnectivity();

  if ((connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) &&
      result == true) {
  } else if (isNavigatedToNoInternetPage == false) {
    JitsiMeet.closeMeeting();
    Get.offAll(NoInternetPage());
    isNavigatedToNoInternetPage = true;
  }
}

/// Creates Websocket connection to Crossbar
void connect() async {
  client = Client(
      realm: 'crossbardemo',
      transport: WebSocketTransport(
        API.crossbarUrl,
        Serializer(),
        WebSocketSerialization.SERIALIZATION_JSON,
      ));
}

/// Subscribes to topics at start of App
///
/// (Sometimes , pauses and resumes if load is high)
void initSubscribe() {
  //appointmentSubscribe();
}

/// Subscribes to `ihl_update_doctor_status_channel` for getting live status updates
///
/// Called at `SelectConsultantCard()`
void statusSubscribe() async {
  if (session != null) {
    session.close();
  }
  connect();
  session = await client.connect().first;
  try {
    statusSubscription = await session.subscribe('ihl_update_doctor_status_channel',
        options: SubscribeOptions(get_retained: true));
    /*await subscription.onRevoke.then((reason) =>
        print('The server has killed my subscription due to: ' + reason));*/
  } on Abort catch (abort) {
    print(abort.message.message);
  }
}

///Subscribes to get appointment updates for live call
///
/// If appointment approved, Launches call screen.
///
/// If Declined, Pop up shows.
///
///Format: [{sender_id: 34234, sender_session_id: 6835954973544287, receivers_id: xCderfSde4fD, data: {cmd: CallDeclinedByDoctor, room_id: ihl_teleconsulation_OojhY789Uh, Doctor_id: 34234}}]

///Publishes the booked appointment details for live call appointments
void appointmentPublish(String action, String notification, List<String> docId, String userId,
    String appointmentId) async {
  if (session != null) {
    session.close();
  }
  print('$action , $notification , $docId , $userId , $appointmentId');
  connect();
  session = await client.connect().first;
  Map q = {};
  Map x = {};

  if (action == 'CallEndedByUser') {
    x['cmd'] = action;
    x['vid'] = appointmentId;
    x['vid_type'] = notification;
    q['sender_id'] = userId;
    q['sender_session_id'] = session.id;
    q['receiver_ids'] = docId;
    q['data'] = x;
  } else if (notification == "BookAppointment") {
    x['cmd'] = action;
    x['notification_domain'] = notification;
    q['sender_id'] = userId;
    q['sender_session_id'] = session.id;
    q['receiver_ids'] = docId;
    q['data'] = x;
  } else {
    x['cmd'] = action;
    x['notification_domain'] = notification;
    x['appointment_id'] = appointmentId;
    q['sender_id'] = userId;
    q['sender_session_id'] = session.id;
    q['receiver_ids'] = docId;
    q['data'] = x;
  }
  try {
    print('published from user ssside');
    await session.publish('ihl_send_data_to_doctor_channel',
        arguments: [q], options: PublishOptions(retain: false));

    ///before retain : true ,   but we have chnged it to false , because we want to close the session after appointment/subscription publish.

    session.close();
    print(session.toString());
  } on Abort catch (abort) {
    print(abort.message.message);
  }
  print('published from user ssside');
  session.close();
  print(session.toString());
}

void publishCallDetails(String action, List<String> receiverIds, String userId,
    String appointmentId, String userName) async {
  print('cccalled the publish function');
  connect();
  session = await client
      .connect()
      .first; //Session creating a tunnel between the app and server and it should be closed once the job is done
  Map q = {};
  Map x = {};
  x['cmd'] = action;
  x['appointment_id'] = appointmentId;
  x['username'] = userName;
  q['sender_id'] = userId;
  q['sender_session_id'] = session.id;
  q['receiver_ids'] = receiverIds;
  q['data'] = x;
  try {
    print('published from uuuser');
    await session.publish('ihl_send_data_to_doctor_channel',
        arguments: [q], options: PublishOptions(retain: false)); //Session create and publish
  } on Abort catch (abort) {
    print(abort.message.message);
    print('published from uuuser is failed');
  }
}

Future<String> getUserID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = prefs.get('data');
  Map res = jsonDecode(data);
  userId = res['User']['id'];
  return userId;
}

//call log
void calllog(
  String by,
  String userid,
  String action,
  String refrence,
  String courseid,
) async {
  print({
    'Content-Type': 'application/json',
    'ApiToken': '${API.headerr['ApiToken']}',
    'Token': '${API.headerr['Token']}',
  }.toString());
  print(API.iHLUrl +
      '/consult/call_log?by=' +
      by +
      '&user_id=' +
      userid +
      '&action=' +
      action +
      '&reference_id=' +
      refrence +
      '&course_id=' +
      courseid);
  print('printed');
  try {
    final response = await _client.get(
      Uri.parse(API.iHLUrl +
          '/consult/call_log?by=' +
          by +
          '&user_id=' +
          userid +
          '&action=' +
          action +
          '&reference_id=' +
          refrence +
          '&course_id=' +
          courseid),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    if (response.statusCode == 200) {
      print(
        API.iHLUrl +
            '/consult/call_log?by=' +
            by +
            '&user_id=' +
            userid +
            '&action=' +
            action +
            '&reference_id=' +
            refrence +
            '&course_id=' +
            courseid,
      );
      print('call log updated ' + action + ' successfull');
    } else {
      print('call log fail' + action + ' ${response.body}');
    }
  } catch (e) {
    print('  FAILED   =>>>>>    call_log?by=');
  }
}

// ignore: missing_return
Widget callErrorDialog(var callDetail) {
  Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(
            'Call Ended due to an Error.',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: callDetail.toString() != 'SubscriptionCall'
              ? Text("Visit 'My Appointments' and select 'Join Call' to reconnect.")
              : Text("Visit 'My Subscriptions' and select 'Join Call' to reconnect."),
          actions: [
            ElevatedButton.icon(
                onPressed: () {
                  if (callDetail.toString() != 'SubscriptionCall') {
                    Get.offAll(MyAppointment(
                      backNav: false,
                    ));
                  } else {
                    Get.offAll(MySubscription(
                      afterCall: false,
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0),
                    side: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                label: Text(
                  "Ok",
                  style: TextStyle(color: Colors.white),
                )),
            SizedBox(
              width: 100,
            ),
          ],
        ),
      ),
      barrierDismissible: false);
}

Future<String> kioskQrLoginCrossPublish(String kioskCode) async {
  /* var _data = await FirestoreServices.FirestoreKioskLogin(kiosId: kioskCode); //TODO Firestore QR login
  if (_data) {
    return 'success';
  } else {
    return 'failure';
  }*/
  print('cccalled the kioskQrLoginCrossPublish');
  userId = await getUserID();
  //String dataToFindHashKiosk= '$' + saltKiosk;
  //String decKiosk=encryptAes(kioskCode);
  String decKiosk = decryptAes(kioskCode); //decrypting the kiosk ID with web key
  String sessionToken = await getSessionTokenKiosk(userId); // getting session token
  if (sessionToken == "failed" || sessionToken == "") {
    return "failed";
  }
  String sessionTokenEncrypt = encryptAes(sessionToken); // encrypt sessionToken
  String calculatedHashKiosk = encryptAes(decKiosk); // encrypt kioskId with mobile key
  String calculatedHashUserId = encryptAes(userId); // encrypt userId with mobile key
  connect();
  session = await client
      .connect()
      .first; //Session creating a tunnel between the app and server and it should be closed once the job is done
  Map q = {};
  Map x = {};
  x['cmd'] = "loginDetails";
  x['token'] = sessionTokenEncrypt;
  q['sender_id'] = calculatedHashUserId;
  q['sender_session_id'] = session.id;
  q['receiver_ids'] = calculatedHashKiosk;
  q['data'] = x;
  try {
    var result = await session.publish('ihl_kiosk_login_channel',
        arguments: [q], options: PublishOptions(retain: false, acknowledge: true));
    print(result);
    return "success"; //Session create and publish
  } on Abort catch (abort) {
    print(abort.message.message);
    print('published from uuuser is failed');
    return "failed";
  }
}

String encryptAes(String data) {
  final key = encrypt.Key.fromUtf8('ad&^sd7SD987adf^%yOgEsh&G090sgK9'); //mobile encrypt key
  //final key = encrypt.Key.fromUtf8('va@8*&Asura*&*a7va(*a*7ha8*h&sp3');//web encrypt key
  final iv = encrypt.IV.fromUtf8('@87TeSla#9l!6#3p'); //mobile iv encrypt key
  //final iv = encrypt.IV.fromUtf8('&a@5CuRiE#%9a^)f');//web iv encrypt key

  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
  final encrypted = encrypter.encrypt(data, iv: iv);
  return encrypted.base64;
}

String decryptAes(String data) {
  final plainText = data;
  //final key = encrypt.Key.fromUtf8('ad&^sd7SD987adf^%yOgEsh&G090sgK9');//mobile encrypt key
  final key = encrypt.Key.fromUtf8('va@8*&Asura*&*a7va(*a*7ha8*h&sp3'); //web encrypt key
  //final iv = encrypt.IV.fromUtf8('@87TeSla#9l!6#3p');//mobile iv encrypt key
  final iv = encrypt.IV.fromUtf8('&a@5CuRiE#%9a^)f'); //web iv encrypt key
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
  final decrypted = encrypter.decrypt(encrypt.Encrypted.from64(plainText), iv: iv);
  return decrypted;
}

Future<String> getSessionTokenKiosk(String UserId) async {
  var rep = "";
  try {
    final getSessionKioskToken =
        await _client.post(Uri.parse(API.iHLUrl + "/consult/getloginauthcode"),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
            body: jsonEncode(<String, String>{"hpod_id_or_ihl_user_id": UserId}));

    if (getSessionKioskToken.statusCode == 200 &&
        getSessionKioskToken.body != null &&
        getSessionKioskToken.body != "") {
      var decodeBody = json.decode(getSessionKioskToken.body);
      rep = rep = decodeBody["access_token"];
    } else {
      rep = "failed";
    }
  } catch (e) {
    rep = "failed";
  }
  return rep;
}
