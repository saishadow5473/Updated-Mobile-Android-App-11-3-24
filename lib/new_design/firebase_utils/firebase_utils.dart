import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectanum/connectanum.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/providers/network/api_provider.dart';
import 'firestore_instructions.dart';

Future<void> publishCallDetails(
    {String action,
    List<String> receiverIds,
    String userId,
    String appointmentId,
    String userName,
    String transactionId}) async {
  Map<String, dynamic> attributes = <String, dynamic>{};
  Map<String, dynamic> subAttributes = <String, dynamic>{};
  subAttributes['cmd'] = action;
  subAttributes['appointment_id'] = appointmentId;
  subAttributes['username'] = userName;
  attributes['sender_id'] = userId;
  attributes['sender_session_id'] = userId;
  attributes['receiver_ids'] = receiverIds;
  attributes['data'] = subAttributes;
  if (action == "NewLiveAppointment") {
    attributes['published'] = true;
  }
  Dio dio = Dio();
  try {
    log('published from user ==> $attributes');
    await FireStoreServices.newAppointment(data: attributes, appointmentId: appointmentId);

    Response<dynamic> fcmTokens =
        await dio.get('${API.iHLUrl}/consult/fire_base_instance_get?ihl_user_id=${receiverIds[0]}');
    debugPrint(fcmTokens.data.toString());
    List<dynamic> fcmToken = fcmTokens.data;
    for (dynamic element in fcmToken) {
      Response<dynamic> response = await dio.post('https://fcm.googleapis.com/fcm/send',
          data: <String, dynamic>{
            "to": "$element",
            "data": <String, dynamic>{
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "username": userName,
              "appointment_id": appointmentId,
              "receiver_ids": receiverIds,
              "sender_id": userId,
              'transaction_id': transactionId
            },
            "notification": <String, dynamic>{
              "title": "$userName Calling you",
              "body": "New Appointment",
            },
            "android": <String, dynamic>{"priority": "high"},
            "priority": 10,
          },
          options:
              Options(contentType: 'application/json; charset=UTF-8', headers: <String, dynamic>{
            'Authorization':
                'key=AAAA-M0JnfM:APA91bHCOiC-Mz_0MhyDWq42CX4pUuPy-GupHmt1-ZJB3XhVk3FE2WPnD3ELekOFv7g4sLXfic-attPxrC4v3Qepmay0_nGNHNM6xCu3BG5FnvjJ2gXoOLvWfR7xSaNgIecLRPC_7KgQ'
          }));
      debugPrint(response.data.toString());
      debugPrint(jsonEncode(<String, dynamic>{
        "to": "$element",
        "data": <String, dynamic>{
          "username": userName,
          "appointment_id": appointmentId,
          "receiver_ids": receiverIds,
          "sender_id": userId,
          'transaction_id': transactionId
        },
        "notification": <String, dynamic>{
          "title": "$userName Calling you",
          "body": "New Appointment",
        },
        "android": <String, dynamic>{"priority": "high"},
        "priority": 10,
      }).toString());
    }
  } on DioError catch (abort) {
    debugPrint(abort.message.toString());
    debugPrint('published from uuuser is failed');
  }
}

//Publishes the booked appointment details for live call appointments
void appointmentPublish(String action, String notification, List<String> docId, String userId,
    String appointmentId) async {
  debugPrint('$action , $notification , $docId , $userId , $appointmentId');
  Map<String, dynamic> attributes = <String, dynamic>{};
  Map<String, dynamic> subAttributes = <String, dynamic>{};

  if (action == 'CallEndedByUser') {
    subAttributes['cmd'] = action;
    subAttributes['vid'] = appointmentId;
    subAttributes['vid_type'] = notification;
    attributes['sender_id'] = userId;
    attributes['sender_session_id'] = "session.id";
    attributes['receiver_ids'] = docId;
    attributes['data'] = subAttributes;
  } else if (notification == "BookAppointment") {
    subAttributes['cmd'] = action;
    subAttributes['notification_domain'] = notification;
    attributes['sender_id'] = userId;
    attributes['sender_session_id'] = "session.id";
    attributes['receiver_ids'] = docId;
    attributes['data'] = subAttributes;
  } else {
    subAttributes['cmd'] = action;
    subAttributes['notification_domain'] = notification;
    subAttributes['appointment_id'] = appointmentId;
    attributes['sender_id'] = userId;
    attributes['sender_session_id'] = "session.id";
    attributes['receiver_ids'] = docId;
    attributes['data'] = subAttributes;
  }
  try {
    debugPrint('published from user ssside');
    await FireStoreCollections.teleconsultationServices.doc(appointmentId).set(attributes);
    log(attributes.toString());
  } on Abort catch (abort) {
    debugPrint(abort.message.message);
  }
  debugPrint('published from user ssside');
}
