import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../data/providers/network/api_provider.dart';

class FireStoreServices {
  FireStoreCollections fireStoreCollections = FireStoreCollections();
  static Future<void> updateDoctorStatus({String consultantId, String status}) async {
    DocumentSnapshot<dynamic> consultantDocument =
        await FireStoreCollections.consultantOnlineStatus.doc(consultantId).get();
    if (consultantDocument.exists) {
      FireStoreCollections.consultantOnlineStatus
          .doc(consultantId)
          .update(<String, dynamic>{'consultantId': consultantId, 'status': status});
    } else {
      FireStoreCollections.consultantOnlineStatus
          .doc(consultantId)
          .set(<String, dynamic>{'consultantId': consultantId, 'status': status});
    }
  }

  static Future<void> newAppointment({dynamic data, String appointmentId}) async {
    log("Published => ");
    log(data.toString());
    await FireStoreCollections.teleconsultationServices.doc(appointmentId).set(data);
  }

  static Future<void> appointmentStatusUpdate({AppointmentStatusModel attributes}) async {
    print(attributes.toJson().toString());
    await FireStoreCollections.teleconsultationAppointment
        .doc(attributes.appointmentID)
        .set(attributes.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> appointmentCallSnapshot({
    String consultId,
  }) =>
      FireStoreCollections.teleconsultationServices
          .where('receiver_ids', arrayContains: consultId)
          .snapshots();
}

class AppointmentStatusModel {
  String docID;
  String userID;
  String status;
  String appointmentID;
  AppointmentStatusModel(
      {@required this.docID,
      @required this.userID,
      @required this.status,
      @required this.appointmentID});
  Map<String, dynamic> toJson() => <String, dynamic>{
        "docID": docID,
        "userID": userID,
        "status": status,
        "appointmentID": appointmentID
      };
  factory AppointmentStatusModel.fromJson({Map<String, dynamic> json}) => AppointmentStatusModel(
      docID: json["docID"],
      userID: json["userID"],
      status: json["status"],
      appointmentID: json["appointmentID"]);
}
