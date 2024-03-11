import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectanum/connectanum.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';
import '../../../../constants/spKeys.dart';
import '../../../../models/invoice.dart';
import '../../../data/providers/network/api_end_points.dart';
import '../../../data/providers/network/api_provider.dart';

import '../../../../utils/CrossbarUtil.dart' as s;

class TeleConsultationApiCalls {
  static Dio dio = Dio();

  static Future searchByDocAndSpec({String query, List searchTypes}) async {
    Response response = await dio.post(
        '${API.iHLUrl}/platformservice/consultant_and_class_platform_search',
        data: {"source": "", "searchString": query, "search_type": searchTypes.toList()});
    try {
      if (response.statusCode == 200) {
        print("success");
      }
      return response.data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future medicalHealthConsultantsSpeciality({int startIndex, int endIndex}) async {
    Response response = await dio
        .post('${API.iHLUrl}/platformservice/medical_health_consultants_speciality', data: {
      "source": "",
      "affilation_list": ["ihl_care", "dev_testing", "persistent"],
      "start_index": startIndex ?? 1,
      "end_index": endIndex ?? 10
    });
    try {
      if (response.statusCode == 200) {
        debugPrint("success medicalHealthConsultantsSpeciality");
      }
      return response.data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future gettingDoctorsBySpeciality({int startIndex, int endIndex, String specName}) async {
    Response response =
        await dio.post('${API.iHLUrl}/platformservice/doctor_consultant_specialty_name', data: {
      "source": "",
      "speciality_list": [specName ?? "Diet Consultation"],
      "start_index": startIndex ?? 1,
      "end_index": endIndex ?? 25
    });
    try {
      if (response.statusCode == 200) {
        debugPrint("success gettingDoctorsBySpeciality");
      }
      return response.data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future gettingAllMedicalFilesList() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    Object data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    var iHLUserId = res['User']['id'];
    Response response = await dio.post('${API.iHLUrl}/consult/view_user_medical_document', data: {
      'ihl_user_id': "$iHLUserId", //"soTlvURs30uyrVP8osAZeQ",
    });
    try {
      if (response.statusCode == 200) {
        print("success");
      }
      return response.data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future shareMedicalDocAfterApointmentCall(
      {var selectedDocIdList, String appointmentId, String ihl_consultant_id}) async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    Object data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    var iHLUserId = res['User']['id'];
    Response response = await dio.post('${API.iHLUrl}/consult/share_medical_doc_after_appointment',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
        data: {
          'ihl_user_id': "$iHLUserId",
          "document_id": selectedDocIdList,
          "appointment_id": appointmentId.toString().replaceAll(
              'ihl_consultant_', ''), //"0b59bf916752496f98c53f94b0e50212",//appointmentId
          "ihl_consultant_id": ihl_consultant_id, //"soTlvURs30uyrVP8osAZeQ",
        });
    try {
      if (response.statusCode == 200) {
        print("success");
      }
      return response.data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future gettingUploadMedicalDocumentList(
      {filename, extension, chosenType, fileNametext, path, context}) async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    Object data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    var iHLUserId = res['User']['id'];
    FormData formData = FormData();
    formData.fields.addAll([
      MapEntry("ihl_user_id", iHLUserId.toString()),
      MapEntry("document_name", "${fileNametext + '.' + extension.toLowerCase()}"),
      MapEntry("document_format_type",
          extension.toLowerCase() == 'pdf' ? "${extension.toLowerCase()}" : 'image'),
      MapEntry("document_type", "$chosenType")
    ]);
    formData.files.add(
      MapEntry("data", await MultipartFile.fromFile(path, filename: filename)),
    );
    Response response = await dio.post('${API.iHLUrl}/consult/upload_medical_document',
        data: formData,
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ));
    print(response.statusCode);
    try {
      if (response.statusCode == 200) {
        print("success");
      }
      return response.data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  // formData.fields.addAll(MapEntry(
  //   "ihl_user_id": "$iHLUserId", "${fileNametext + '.' + extension.toLowerCase()}"
  //   "document_name":,
  //   "document_format_type": extension.toLowerCase() == 'pdf'
  //       ? "${extension.toLowerCase()}"
  //       : 'image', //"${extension.toLowerCase()}",
  //   "document_type": "$_chosenType",
  // }));
  // try {
  //   if (response.statusCode == 200) {
  //     print("success");
  //   }
  //   return response.data;
  // } catch (e) {
  //   print(e);
  //   return [];
  // }

  static Future vendorImageGetter({String vendorName}) async {
    Response response = await dio
        .get('${API.iHLUrl}/consult/fetch_vendor_account_logo_image?vendor_name=$vendorName');
    try {
      if (response.statusCode == 200) {
        print("success");
      }
      return response.data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<String> consultantLiveStatusCall({var consultant_id}) async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    Object data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    Response response = await dio.post('${API.iHLUrl}/consult/getConsultantLiveStatus', data: {
      'consultant_id': [consultant_id], //"soTlvURs30uyrVP8osAZeQ",
    });
    try {
      if (response.statusCode == 200) {
        print('status');
      }
      return response.data;
    } catch (e) {
      print(e);
      return '';
    }
  }

  static Future insertRatingApi(Map data) async {
    if (API.headerr['ApiToken'] == null || API.headerr['Token'] == null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var userData = jsonDecode(prefs.getString(
        SPKeys.userData,
      ));
      Object isSso = prefs.get(SPKeys.is_sso);
      Object authToken = prefs.get(SPKeys.authToken);
      String iHLUserToken = userData['Token'];
      API.headerr['Token'] = iHLUserToken;
      API.headerr['ApiToken'] = isSso != "true"
          ? '$authToken'
          : "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==";
    }
    try {
      final Response response = await dio.post('${API.iHLUrl}/consult/insert_telemed_reviews_new',
          options: Options(
            headers: <String, dynamic>{
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
          ),
          data: data);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Your review is appreciated. Thank you!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
        Get.back();
      } else {
        Fluttertoast.showToast(
            msg: "Reviewing failed!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
        Get.back();
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Reviewing failed!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
      Get.back();
    }
  }

//Getting Appointment Details by Appointment ID ⚪
  static Future<Map<String, dynamic>> appointmentDetailsCalls({String appointmentId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiToken = prefs.get('auth_token');
    final Response<dynamic> response =
        await dio.get('${API.iHLUrl}/consult/get_appointment_details?appointment_id=$appointmentId',
            options: Options(
              headers: <String, dynamic>{
                'Content-Type': 'application/json',
                'ApiToken': apiToken,
                'Token': API.headerr['Token'].toString(),
              },
            ));
    try {
      if (response.statusCode == 200) {
        debugPrint("successfully getted the appointment details");
        String data = response.data;
        data = data.replaceAll("\\&quot;", '"');
        data = data.replaceAll("&quot;", '"');
        data = data.replaceAll('"{', '{');
        data = data
            .replaceAll('}"', '}')
            .replaceAll('W/"', '')
            .replaceAll(';""}', ';"}')
            .replaceAll('"[{', '[{')
            .replaceAll('}]"', '}]');
        Map<String, dynamic> decodedData = jsonDecode(data);
        return decodedData;
      } else {
        return <String, dynamic>{};
      }
    } catch (e) {
      debugPrint(e.toString());
      return <String, dynamic>{};
    }
  }

  static Future consultantStatus({String consultantID}) async {
    String status = "Offline";
    final Response response = await dio.post(
      '${API.iHLUrl}/consult/getConsultantLiveStatus',
      data: {
        "consultant_id": [
          consultantID,
        ]
      },
    );
    if (response.statusCode == 200) {
      if (response.data != '"[]"') {
        var parsedString = response.data.replaceAll('&quot', '"');
        var parsedString1 = parsedString.replaceAll(";", "");
        var parsedString2 = parsedString1.replaceAll('"[', '[');
        var parsedString3 = parsedString2.replaceAll(']"', ']');
        var finalOutput = json.decode(parsedString3);
        String doctorId = consultantID;
        if (doctorId == finalOutput[0]['consultant_id']) {
          status = camelize(finalOutput[0]['status'].toString());
          if (status == null || status == "" || status == "null" || status == "Null") {
            status = "Offline";
          }
        }
      }
    }
    return status;
  }

  static Future MyAppointmentsApprovedCall({int startIndex, int endIndex}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    Response response =
        await dio.post('${API.iHLUrl}/consult/get_user_appointment_status_pagination', data: {
      "user_ihl_id": iHLUserId, // mandatory
      "start_index": 0,
      "end_index": 510, // mandatory
      "appointment_status": "Approved"
    });
    try {
      if (response.statusCode == 200) {
        print("success");
      }
      return response.data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  ///
  // static method to call the API to get the appointments based on the start and end index and type(Cancel and Completed ,Approved)
  static Future<dynamic> myAppointmentApi({int startIndex, int endIndex, String type}) async {
    // get the shared preferences instance
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // get the user id from shared preferences
    String iHLUserId = prefs.getString('ihlUserId');
    Map<String, Object> requestMap = {
      "user_ihl_id": iHLUserId, // mandatory
      "start_index": startIndex,
      "end_index": endIndex, // mandatory
      "appointment_status": type
    };
    // call the API to get the appointments
    Response<dynamic> response = await dio
        .post('${API.iHLUrl}/consult/get_user_appointment_status_pagination', data: requestMap);

    try {
      // check if the response is successful
      if (response.statusCode == 200) {
        // return the appointments
        return response.data["Appointments"];
      }
    } catch (e) {
      print(e);
      // return an empty list if there is an error
      return [];
    }
  }

  static Future getAvailableSlot({String ihlConsultantID, String vendorID}) async {
    final Response response = await dio.get(
      "${API.iHLUrl}/consult/consultant_timings_live_availablity_mobile?ihl_consultant_id=$ihlConsultantID&vendor_id=$vendorID",
    );
    try {
      if (response.statusCode == 200) {
        print("success");
      }
      return response.data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future getSlotsCancelled({var appointId, var reason, var consultId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId;
    Object data = prefs.get('data');
    Map res = jsonDecode(data);
    iHLUserId = res['User']['id'];
    String transcationId = '';

    Object apiToken = prefs.get('auth_token');
    final Response response = await dio.post(
      '${API.iHLUrl}/consult/cancel_appointment',
      options: Options(method: 'POST', headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      }),
      // headers: {'ApiToken': apiToken},
      data: jsonEncode(<String, dynamic>{
        "canceled_by": "user",
        "ihl_appointment_id": appointId.toString(),
        "reason": reason.toString(),
      }),
    );
    if (response.statusCode == 200) {
      if (response.data != '"[]"') {
        var finalOutput = response.data;
        var status = finalOutput["status"];
        var refundAmount = finalOutput["refund_amount"];
        if (status == "cancel_success") {
          final Response transresponce =
              await dio.get("${API.iHLUrl}/consult/user_transaction_from_ihl_id?ihl_id=$iHLUserId",
                  options: Options(
                    headers: {
                      'Content-Type': 'application/json',
                      'ApiToken': '${API.headerr['ApiToken']}',
                      'Token': '${API.headerr['Token']}',
                    },
                  ));
          if (transresponce.statusCode == 200) {
            if (transresponce.data != "[]" || transresponce.data != null) {
              var transcationList = transresponce.data;
              for (int i = 0; i <= transcationList.length - 1; i++) {
                if (transcationList[i]["ihl_appointment_id"] == appointId) {
                  transcationId = transcationList[i]["transaction_id"];
                }
              }
              if (transcationId != "") {
                final Response responsetrans = await dio.get(
                    '${API.iHLUrl}/consult/update_refund_status?transaction_id=$transcationId&refund_status=Initated',
                    options: Options(
                      headers: {
                        'Content-Type': 'application/json',
                        'ApiToken': '${API.headerr['ApiToken']}',
                        'Token': '${API.headerr['Token']}',
                      },
                    ));
                if (responsetrans.statusCode == 200 || refundAmount.toString() == '0') {
                  // if (responsetrans.body == '"Refund Status Update Success"') {
                  if (responsetrans.data == '"Refund Status Update Success"' ||
                      refundAmount.toString() == '0') {
                    // if (mounted) {
                    //   setState(() {
                    //     isChecking = false;
                    //   });
                    // }
                    //  isChecking = false;
                    log("canceled appointment id => $appointId");
                    currentAppointmentStatusUpdate(appointId, "Canceled");
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    Object data = prefs.get('data');
                    Map res = jsonDecode(data);

                    List<String> receiverIds = [];
                    receiverIds.add(consultId.toString());
                    // s.appointmentPublish('GenerateNotification', 'CancelAppointment', receiverIds,
                    //     iHLUserId, appointId);
                    Map q = {};
                    Map x = {};
                    x['cmd'] = "GenerateNotification";
                    x['notification_domain'] = "CancelAppointment";
                    x['appointment_id'] = appointId;
                    q['sender_id'] = iHLUserId;
                    q['sender_session_id'] = "1245";
                    q['receiver_ids'] = receiverIds;
                    q['data'] = x;
                    FireStoreCollections.teleconsultationServices.doc(appointId).set(
                        {"sender_id": iHLUserId, "receiver_ids": receiverIds, "data": x},
                        SetOptions(merge: false));
                    // AwesomeDialog(
                    //         context: context,
                    //         animType: AnimType.TOPSLIDE,
                    //         headerAnimationLoop: true,
                    //         dialogType: DialogType.SUCCES,
                    //         dismissOnTouchOutside: false,
                    //         title: 'Success!',
                    //         desc: 'Appointment Successfully Cancelled! Your Refund has been Initiated.',
                    //         btnOkOnPress: () => Get.offAll(MyAppointmentsTabs()),
                    //         // Get.offAll(MyAppointment(
                    //         //   backNav: false,
                    //         // )
                    //         // ),
                    //         btnOkColor: Colors.green,
                    //         btnOkText: 'Proceed',
                    //         btnOkIcon: Icons.check,
                    //         onDismissCallback: (_) {})
                    //     .show();
                  }
                } else {
                  // errorDialog();
                }
              } else {
                log("canceled appointment id => $appointId");
                currentAppointmentStatusUpdate(appointId, "Canceled");
                SharedPreferences prefs = await SharedPreferences.getInstance();
                Object data = prefs.get('data');
                Map res = jsonDecode(data);

                List<String> receiverIds = [];
                receiverIds.add(consultId.toString());
                // s.appointmentPublish(
                //     'GenerateNotification', 'CancelAppointment', receiverIds, iHLUserId, appointId);
                Map q = {};
                Map x = {};
                x['cmd'] = "GenerateNotification";
                x['notification_domain'] = "CancelAppointment";
                x['appointment_id'] = appointId;
                q['sender_id'] = iHLUserId;
                q['sender_session_id'] = "1245";
                q['receiver_ids'] = receiverIds;
                q['data'] = x;
                FireStoreCollections.teleconsultationServices.doc(appointId).set(
                    {"sender_id": iHLUserId, "receiver_ids": receiverIds, "data": x},
                    SetOptions(merge: false));
              }
            } else {
              // errorDialog();
            }
          } else {
            // errorDialog();
          }

          // Updating getUserDetails API
        } else {
          // errorDialog();
        }
      } else {
        print('');
      }
      // TeleConsultationFunctionsAndVariables.isChecking.value = false;
    } else {
      print('');
    }
  }

  static Future<String> currentAppointmentStatusUpdate(String appointId, String appStatus) async {
    final Response<dynamic> response = await dio.get(
        '${API.iHLUrl}/consult/update_appointment_status?appointment_id=$appointId&appointment_status=$appStatus',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ));
    String parsedString = response.data.replaceAll('&quot', '"');
    // String parsedString1 = parsedString.replaceAll(";", "");
    // String parsedString2 = parsedString1.replaceAll('"{', '{');
    // String parsedString3 = parsedString2.replaceAll('}"', '}');
    // dynamic currentAppointmentStatusUpdate = json.decode(parsedString3);
    if (parsedString == 'Database Updated') {
      return parsedString;
    } else {
      return parsedString;
    }
  }

  static Future<String> callStatusUpdate(String appointmentID, String appStatus) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object apiToken = prefs.get('auth_token');
    final Response<dynamic> response = await dio.get(
        '${API.iHLUrl}/consult/update_call_status?appointment_id=$appointmentID&call_status=$appStatus',
        options: Options(headers: <String, dynamic>{'ApiToken': apiToken}));
    if (response.statusCode == 200) {
      String parsedString = response.data.replaceAll('&quot;', '"');
      dynamic statusValue = json.decode(parsedString);
      String apiResponse = statusValue['status'].toString();
      if (apiResponse == 'Update Sucessfull') {
        log("Call Status Updated to = > $apiResponse");
        return apiResponse;
      } else {
        log("Issue while updating call status => $apiResponse");
        return apiResponse;
      }
    } else {
      return "Failed";
    }
  }

//appointmentIdKey = 'appointmentId',
// widget.appointmentDetails[0].toString().replaceAll("ihl_consultant_", ""),
  static Future<StreamSubscription<dynamic>> subcribeStream(
      {StreamSubscription<dynamic> stream, String appointmentId}) async {
    try {
      return stream = FireStoreCollections.teleconsultationServices
          .doc(appointmentId)
          .snapshots()
          .listen((DocumentSnapshot<dynamic> event) {
        // callListner(event, ihlUserId);
      });
    } on Abort catch (abort) {
      log(abort.message.message);
      return null;
    }
  }

  static void calllog(
      {String by, String userid, String action, String refrence, String courseid}) async {
    debugPrint(
        '${API.iHLUrl}/consult/call_log?by=$by&user_id=$userid&action=$action&reference_id=$refrence&course_id=$courseid');
    try {
      final Response<dynamic> response = await dio.get(
        '${API.iHLUrl}/consult/call_log?by=$by&user_id=$userid&action=$action&reference_id=$refrence&course_id=$courseid',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
      );
      if (response.statusCode == 200) {
        debugPrint('call log updated $action successfull');
      } else {
        debugPrint('call log fail$action ${response.data.toString()}');
      }
    } catch (e) {
      debugPrint('  FAILED   =>>>>>    call_log?by=');
    }
  }

  static Future<void> updateServiceProvided(String iHLUserID, String appointmentID) async {
    final Response<dynamic> getTransactionid =
        await dio.get("${API.iHLUrl}/consult/user_transaction_from_ihl_id?ihl_id=$iHLUserID");
    if (getTransactionid.statusCode == 200) {
      List<dynamic> appointmentList = getTransactionid.data;
      for (Map<String, dynamic> element in appointmentList) {
        if (element['ihl_appointment_id'] == appointmentID) {
          Response<dynamic> tranresponce = await dio.post(
              "${API.iHLUrl}/data/serviceProvidedPortal?transaction=${element['transaction_id']}",
              options: Options(headers: <String, dynamic>{
                'Content-Type': 'application/json',
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              }));
          if (tranresponce.statusCode == 200) {
          } else {
            debugPrint(tranresponce.statusMessage);
          }
        }
      }
    }
  }

// Getting invoice number for current appointment from user appointment list ✅
  static Future<Invoice> getInvoiceNumber(String iHLUserID, String appointmentID) async {
    Invoice invoice;
    String invoiceNumber;
    Response<dynamic> getInvoiceResponse = await dio.get(
      "${API.iHLUrl}/consult/user_transaction_from_ihl_id?ihl_id=$iHLUserID",
    );
    if (getInvoiceResponse.statusCode == 200) {
      List<dynamic> appointmentList = getInvoiceResponse.data;
      for (Map<dynamic, dynamic> element in appointmentList) {
        if (element['ihl_appointment_id'] == appointmentID) {
          invoice = Invoice.fromJson(element);
          invoiceNumber = element['ihl_invoice_numbers'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("invoice", invoiceNumber);
        }
      }
    }
    log('Invoice Number $invoiceNumber');
    return invoice;
  }

  static Future<List<dynamic>> getLogoUrl(String accId) async {
    dynamic footerDetail;
    Response<dynamic> logoUrlResponse = await dio.get(
      "${API.iHLUrl}/consult/get_logo_url?accountId=$accId",
      options: Options(headers: <String, dynamic>{
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      }),
    );
    try {
      if (accId == '499935c5-01a7-4b39-b7e2-bf08b5e787eb') {
        footerDetail = <dynamic, dynamic>{
          'Description': 'Please note the Emergency Helpline Numbers of Dr Mehta\'s Hospital',
          'line1': 'Chennai: Chetpet Unit: 044-40054005',
          'line2': 'Global Campus @ Velappanchavadi : 044-40474047'
        };
      } else {
        footerDetail = null;
      }
      if (logoUrlResponse.statusCode == 200) {
        dynamic res = jsonDecode(logoUrlResponse.data);
        // logoUrl = res.toString();
        res == 'https://indiahealthlink.com/affiliate_logo/ihl-plus.png'
            ? 'https://dashboard.indiahealthlink.com/affiliate_logo/ihl-plus.png'
            : res;
        return <dynamic>[res, footerDetail];
      } else {
        return <dynamic>["", footerDetail];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<dynamic>> getLogoForPrescriptionPDF({String accId}) async {
    Map<String, dynamic> footerDetail;
    Response<dynamic> logoUrlResponse = await dio.get(
      "${API.iHLUrl}/consult/genixAccountLogoFetch?accountid=$accId",
    );
    try {
      if (accId == '499935c5-01a7-4b39-b7e2-bf08b5e787eb') {
        footerDetail = {
          'Description': 'Please note the Emergency Helpline Numbers of Dr Mehta\'s Hospital',
          'line1': 'Chennai: Chetpet Unit: 044-40054005',
          'line2': 'Global Campus @ Velappanchavadi : 044-40474047'
        };
      } else {
        footerDetail = null;
      }
      if (logoUrlResponse.statusCode == 200) {
        Map<String, dynamic> res = logoUrlResponse.data;
        String temp = res['logo_list'][0];
        String base64Image = temp.replaceAll('data:image/jpeg;base64,', '');
        base64Image = base64Image.replaceAll('}', '');
        base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
        return <dynamic>[footerDetail, base64Image];
      } else {
        return <dynamic>[footerDetail, ""];
      }
    } catch (e) {
      debugPrint(e.toString());
      return <dynamic>[footerDetail, ''];
    }
  }

  static Future<dynamic> getSignature(String consultantId) async {
    Response<dynamic> signatureResponse =
        await dio.get('${API.iHLUrl}/consult/getGenixDoctorSign?ihl_consultant_id=$consultantId',
            options: Options(
              headers: <String, dynamic>{
                'Content-Type': 'application/json',
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              },
            ));

    if (signatureResponse.statusCode == 200) {
      String base64Signature = signatureResponse.data;

      base64Signature = base64Signature.replaceAll('&quot;', '');
      base64Signature = base64Signature.replaceAll('{ContentType:image/png,Content:', '');
      base64Signature = base64Signature.replaceAll('{ContentType:image/jpeg,Content:', '');
      base64Signature = base64Signature.replaceAll('}', '');
      base64Signature = base64Signature.replaceAll('"', '');
      if (base64Signature.contains('error')) {
      } else {
        return Image.memory(base64Decode(base64Signature));
      }
    } else {
      debugPrint('signatureAPI else part => ${signatureResponse.data}');
    }
  }

  static Future<List<dynamic>> getFilesSummary({String consultantId, String appID}) async {
    final Response<dynamic> getUserFile = await dio.post(
      "${API.iHLUrl}/consult/view_user_medical_document",
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      ),
      data: jsonEncode(<String, String>{
        'Appointment_id': appID.toString(),
      }),
    );
    if (getUserFile.statusCode == 200) {
      final List<dynamic> filesData = getUserFile.data;
      for (Map<String, dynamic> element in filesData) {
        element['document_name'] = element['document_name'].toString().replaceAll(consultantId, '');
      }
      return filesData;
    } else {
      debugPrint(getUserFile.data.toString());
      return <dynamic>[];
    }
  }

  static Future<dynamic> cancelAppointment({String appointmentId, String reason, String by}) async {
    if (API.headerr['ApiToken'] == null || API.headerr['Token'] == null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var userData = jsonDecode(prefs.getString(
        SPKeys.userData,
      ));
      Object isSso = prefs.get(SPKeys.is_sso);
      Object authToken = prefs.get(SPKeys.authToken);
      String iHLUserToken = userData['Token'];
      API.headerr['Token'] = iHLUserToken;
      API.headerr['ApiToken'] = isSso != "true"
          ? '$authToken'
          : "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==";
    }
    final Response<dynamic> canceled = await dio.post(
      "${API.iHLUrl}/consult/cancel_appointment",
      options: Options(
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      ),
      data: <String, dynamic>{
        "canceled_by": by.toString(),
        "ihl_appointment_id": appointmentId.toString(),
        "reason": reason.toString(),
      },
    );
    if (canceled.statusCode == 200 && canceled.data['status'] != "already_canceled_or_rejected") {
      String status = canceled.data["status"];
      String refundAmount;
      if (canceled.data.toString().contains("refund_amount")) {
        refundAmount = canceled.data["refund_amount"] ?? '0';
      } else {
        refundAmount = '0';
      }
      if (status == "cancel_success" && refundAmount != '0') {
        return transactionIdGetter(appointId: appointmentId, amount: refundAmount);
      }

      return canceled.data;
    } else {
      if (canceled.data['status'] == 'already_canceled_or_rejected') {
        return 'already_canceled_or_rejected';
      } else {
        debugPrint(canceled.data.toString());
        throw Exception('Cancel Appointment Failed');
      }
    }
  }

  static Future<void> transactionIdGetter({String appointId, String amount}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.get('data');
    Map<String, dynamic> userData = jsonDecode(data)["User"];
    String iHLUserId = userData['id'];
    String transcationId = '';
    String apiToken = prefs.get('auth_token');
    final Response<dynamic> tranId = await dio.get(
      "${API.iHLUrl}/consult/user_transaction_from_ihl_id?ihl_id=$iHLUserId",
      options: Options(
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'ApiToken': apiToken.toString(),
          'Token': '${API.headerr['Token']}',
        },
      ),
    );
    if (tranId.statusCode == 200) {
      if (tranId.data != "[]" || tranId.data != null) {
        List<dynamic> transcationList = tranId.data;
        for (int i = 0; i <= transcationList.length - 1; i++) {
          if (transcationList[i]["ihl_appointment_id"] == appointId) {
            transcationId = transcationList[i]["transaction_id"];
          }
        }
      }
      return refundAPI(transcationId: transcationId, amount: amount);
    } else {
      debugPrint(tranId.data.toString());
      throw Exception('Transaction Id Getter Failed');
    }
  }

  static Future<dynamic> refundAPI({String transcationId, String amount}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiToken = prefs.get('auth_token');
    final Response<dynamic> refund = await dio.get(
      '${API.iHLUrl}/consult/update_refund_status?transaction_id=$transcationId&refund_status=Initated',
      options: Options(
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'ApiToken': apiToken.toString(),
          'Token': '${API.headerr['Token']}',
        },
      ),
    );
    if (refund.statusCode == 200 || refund.toString() == '0') {
      if (refund.data == "Refund Status Update Success" || amount.toString() == '0') {
        return refund.data;
      }
    } else {
      debugPrint(refund.data.toString());
      throw Exception('Refund Failed');
    }
  }

  static Future<dynamic> generateURl(String genixAppointment) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('genixAppoinmentID', genixAppointment);
    prefs.setBool('isGenixCallAlive', true);
    final Response<dynamic> genixURLResponse = await dio.get(
      '${API.iHLUrl}/consult/get_existing_appointment_url_for_genix?ihl_appointment_id=$genixAppointment',
      options: Options(
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      ),
    );
    if (genixURLResponse.statusCode == 200) {
      String parsedString = genixURLResponse.data.replaceAll('&quot;', '"');
      String parsedString2 = parsedString.replaceAll('"[', "[");
      String parsedString3 = parsedString2.replaceAll(']"', ']');
      List<dynamic> finalResponse = json.decode(parsedString3);
      String genixURL;
      for (int i = 0; i < finalResponse.length; i++) {
        if (finalResponse[i]['Type'] == "Participant") {
          genixURL = finalResponse[i]['URL'];
          debugPrint("genix URL ==>  $genixURL");
        }
      }
      return genixURL;
    } else {
      return "failed";
    }
  }

  static Future<bool> genixPrescriptionMail(
      {String firstName,
      String lastName,
      String email,
      String mobileNumber,
      String affiliationUniqueName,
      String calculatedHash,
      String prescriptionBase64}) async {
    String jsontext =
        '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","prescription_number":"IHL-21-22/0000000001","prescription_base64":"$prescriptionBase64","security_hash":"$calculatedHash","affiliation_unique_name":"$affiliationUniqueName",' // find the affiliation code
        '"order_type":"medication"}';
    Response<dynamic> response =
        await dio.post("${API.iHLUrl}/login/sendPrescription", data: jsontext);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<dynamic> getClassDetails({String id}) async {
    try {
      Response<dynamic> response =
          await dio.get('${API.iHLUrl}/consult/getClassDetail?classId=$id');
      return response.data;
    } catch (e) {
      return "Remove";
    }
  }

  static Future<dynamic> upcomingDetailAPI({String userID, List<dynamic> li}) async {
    Response<dynamic> response = await dio.post(API.iHLUrl + ApiEndPoints.getUpcomingDetails,
        data: {"user_ihl_id": userID, "affiliation_list": li});
    if (response.data["Subcription_list"] != null && response.data["Subcription_list"].isNotEmpty) {
      List<dynamic> tempSubList = response.data["Subcription_list"];
      for (int i = 0; i < tempSubList.length; i++) {
        var check = await TeleConsultationApiCalls.getClassDetails(id: tempSubList[i]["course_id"]);
        if (check.runtimeType == String) {
          print(tempSubList);
        }
        try {
          Map<String, dynamic> ss =
              await TeleConsultationApiCalls.getClassDetails(id: tempSubList[i]["course_id"]);
          response.data["Subcription_list"][i]["external_url"] = ss["external_url"];
        } catch (e) {
          print("Corrupted Class");
        }
      }
    }
    return response.data;
  }
}
