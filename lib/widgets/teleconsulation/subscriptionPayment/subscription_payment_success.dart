import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/teleconsultation/mySubscriptions.dart';
import 'package:ihl/widgets/teleconsulation/payment/paymentUI.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ihl/utils/CrossbarUtil.dart' as s;

import '../../../Modules/online_class/presentation/pages/view_all_class.dart';
import '../../../models/invoice.dart';
import '../../../repositories/api_consult.dart';
import '../../../views/teleconsultation/MySubscription.dart';
import '../../../views/view_past_bill/view_subscription_invoice.dart';
import '../selectClassSlot.dart';

class SubscriptionSuccessPage extends StatefulWidget {
  final Map details;
  final selectedCourseDate;
  final selectedTime;

  SubscriptionSuccessPage({this.details, this.selectedCourseDate, this.selectedTime});

  @override
  _SubscriptionSuccessPageState createState() => _SubscriptionSuccessPageState();
}

class _SubscriptionSuccessPageState extends State<SubscriptionSuccessPage> {
  http.Client _client = http.Client(); //3gb
  var subscriptionId;
  bool loading = true;
  bool success = false;
  var courseDate;
  var courseTime;
  var email;
  var firstName;
  var lastName;
  var mobile;
  var currentSubscription;

  void bookSubscription() async {
    var invoiceBase64;
    String ihlId;
    try {
      print(widget.details);
      courseDate = SpUtil.getString("selectedDateFromPicker")!=""?SpUtil.getString("selectedDateFromPicker"):widget.details["course_duration"];
      courseTime = SpUtil.getString("selectedTime")!=""?SpUtil.getString("selectedTime"):widget.details["course_time"];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      ihlId = prefs.getString("ihlUserId");
      String apiToken = prefs.get('auth_token');
      email = prefs.get('email');
      Object data = prefs.get('data');
      Map res = jsonDecode(data);
      firstName = res['User']['firstName'];
      lastName = res['User']['lastName'];
      mobile = res['User']['mobileNumber'];
      var ihlUserID = res['User']['id'];
      var approval_status = widget.details['approval_status'];
      String filteredDate = changeDateFormat(courseDate.toString());
      //Change date format from 09-12-2020 - 08-06-2021 to 09/12/2020 - 08/06/2021

      final http.Response response = await _client.post(
        Uri.parse('${API.iHLUrl}/consult/createsubscription'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        // headers: {
        //   'ApiToken': apiToken,
        //   'Token':
        //       '9Jk4Kqbm4qVOwRbftbg2s9Qu7tXxxiPvKcdLl/kPwbckzpWyrZc6OLaJ6KbiGBDDCSCHayHvYnDmxHqk9sND9uhRNhjflKmXsxnDes/YHSdBhka4Msh5zoheHPRCiPtyvtRHVz6yxBOpUBexiFIRCZJDswg7j198BH9+6ITZoNZhwe3RV9+43FlbbMlPkaFDAQA='
        // },
        body: jsonEncode(<String, dynamic>{
          "user_ihl_id": ihlUserID,
          "course_id": widget.details['course_id'].toString(),
          "name": "$firstName $lastName",
          "email": email.toString(),
          "mobile_number": mobile.toString(),
          "course_type": widget.details['course_type'].toString(),
          "course_time": courseTime.toString(),
          "provider": widget.details['provider'].toString(),
          "fees_for": widget.details['fees_for'].toString(),
          "consultant_name": widget.details['consultant_name'].toString(),
          "course_duration": widget.details["course_duration"],
          "course_fees": widget.details['course_fees'].toString(),
          "consultation_id": widget.details['consultant_id'].toString(),
          "approval_status": "$approval_status",
        }),
      );

      if (response.statusCode == 200) {
        String parsedString = response.body.replaceAll('&quot', '"');
        String parsedString2 = parsedString.replaceAll(";", "");
        String parsedString3 = parsedString2.replaceAll('"{', '{');
        String parsedString4 = parsedString3.replaceAll('}"', '}');
        var finalResponse = json.decode(parsedString4);

        subscriptionId = finalResponse['subscription_id'];

        if (mounted) {
          setState(() {
            loading = false;
            success = true;
          });
        }
        final http.Response paymentUpdateStatusResponse = await _client.post(
          Uri.parse("${API.iHLUrl}/consult/update_payment_transaction"),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
          body: jsonEncode(<String, String>{
            'MRPCost': widget.details['MRPCost'].toString(),
            'CouponNumber': widget.details['CouponNumber'],
            'DiscountType': widget.details['DiscountType'],
            'Discounts': widget.details['Discounts'],
            "ihl_id": ihlUserID,
            "TotalAmount": widget.details['course_fees'],
            "payment_status": "completed",
            "transactionId": widget.details['transaction_id'],
            "payment_for": "online-class",
            "MobileNumber": mobile,
            "payment_mode": "online",
            "Service_Provided": 'true',
            "appointment_id": subscriptionId,
            "AppointmentID": subscriptionId,
            "razorpay_payment_id": widget.details["razorpay_payment_id"],
            "razorpay_order_id": widget.details["razorpay_order_id"],
            "razorpay_signature": widget.details["razorpay_signature"]
          }),
        );

        if (paymentUpdateStatusResponse.statusCode == 200) {
          print(paymentUpdateStatusResponse.body);
          Invoice invoiceModel = await ConsultApi().getInvoiceNumber(ihlId, subscriptionId);
          currentSubscription = await getDataSubID(subID: subscriptionId);
          invoiceModel.ihlInvoiceNumbers = prefs.getString('invoice');
          print(invoiceModel.ihlInvoiceNumbers);
          invoiceBase64 = await subscriptionBillView(
              context,
              widget.details["title"],
              widget.details['provider'].toString(),
              currentSubscription,
              invoiceModel.ihlInvoiceNumbers,
              invoiceModel: invoiceModel);
          String jsontext =
              '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobile","invoice_id":"$invoiceNumber","date":"${DateTime.now().toString().replaceAll("-", "/")}","amount":"${widget.details['course_fees']}","invoice_base64":"$invoiceBase64"}';
          // '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","prescription_number":"IHL-21-22/0000000001","prescription_base64":"$prescription_base64","security_hash":"$calculatedHash"}';
          print('api yet to be called');
          log('send invoice time start ${DateTime.now().toString()}');
          final http.Response response = await _client.post(
            Uri.parse("${API.iHLUrl}/login/sendInvoiceToUser"),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
            body: jsontext,
          );
          if (response.statusCode == 200) {
            print(response.body);
            // Get.close(1);
            print(response.body);
          }
          /*
          List<String> receiverIds = [];
          receiverIds
              //.add(widget.details['doctor']['ihl_consultant_id'].toString());
              .add(widget.details['consultant_id'].toString());
          var abcd = [];
          abcd.add('GenerateNotification');
          abcd.add('SubscriptionClass');
          abcd.add('$receiverIds');
          abcd.add('$ihlUserID');
          abcd.add('${finalResponse['appointment_id'].toString()}');
          print(abcd.toString());
          s.appointmentPublish(
              'GenerateNotification',
              'SubscriptionClass',
              receiverIds,
              ihlUserID,
              finalResponse['subscription_id'].toString());*/
        } else {
          if (mounted) {
            setState(() {
              loading = false;
              success = true;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            loading = false;
            success = false;
          });
        }
      }
    } catch (error) {
      print(error);
    }
  }

  Future<bool> _onBackPressed() {
    return (loading == true)
        ? showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Column(
                      children: [
                        const Text(
                          'Info !\n',
                          style: TextStyle(color: AppColors.primaryColor),
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          'Please Wait...\nDO NOT GO BACK while Subscribing for course',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: AppColors.primaryColor,
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                            child: const Text(
                              'Okay',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }) ??
            false
        : true;
  }

  @override
  void initState() {
    bookSubscription();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: PaymentUI(
        color: (loading == false && success == true)
            ? AppColors.bookApp
            : (loading == false && success == false)
                ? Colors.red
                : AppColors.myApp,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            (loading == false && success == true)
                ? 'Subscription Confirmed!'
                : (loading == false && success == false)
                    ? 'Subscription Failed !'
                    : 'Confirming your Subscription...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: (loading == false)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                          builder: (BuildContext ctx) =>
                              ViweAllClass(
                                subscribed: true,
                                subcriptionList: [],
                              )),
                    );
                    // Navigator.pushAndRemoveUntil(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => MySubscription(
                    //               afterCall: false,
                    //             )),
                    //     (Route<dynamic> route) => false);
                  },
                  color: Colors.white,
                  tooltip: 'Back',
                )
              : Container(),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              (loading == false && success == true)
                  ? Lottie.network('https://assets2.lottiefiles.com/packages/lf20_pn7kzizl.json',
                      height: 300, width: 300)
                  : (loading == false && success == false)
                      ? Lottie.network(API.declinedLottieFileUrl, height: 300, width: 300)
                      : Lottie.network(
                          'https://assets5.lottiefiles.com/packages/lf20_e5fibvuv.json',
                          height: 400,
                          width: 400),
              Container(
                child: (loading == false && success == true)
                    ? Text(
                        '${"${'Your Subscription for course ' +
                            "\n" +
                            widget.details['title'] +
                            ' from ' +
                            courseDate} at " +
                            courseTime}\nis Confirmed',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      )
                    : (loading == false && success == false)
                        ? Text(
                            '${"${'Your Subscription for course ' +
                                "\n" +
                                widget.details['title'] +
                                ' from ' +
                                courseDate} at " +
                                courseTime} failed!\n Try Again!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                            ))
                        : const Text(
                            'Please Wait...\nDO NOT GO BACK while\n Subscribing for course',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
              ),
              const SizedBox(height: 30),
              (loading == false && success == true)
                  ? Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: AppColors.bookApp,
                            textStyle: const TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<dynamic>(
                                  builder: (BuildContext ctx) =>
                                      ViweAllClass(
                                        subscribed: true,
                                        subcriptionList: [],
                                      )),
                            );
                            // Navigator.pushAndRemoveUntil(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => MySubscription(
                            //               afterCall: false,
                            //             )),
                            //     (Route<dynamic> route) => false);
                          },
                          child: const Text(
                            "View Subscription",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            primary: AppColors.bookApp,
                            textStyle: const TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            currentSubscription = await getDataSubID(subID: subscriptionId);
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String ihlId = prefs.getString("ihlUserId");
                            Object data = prefs.get(SPKeys.userData);
                            data = data == null || data == '' ? '{"User":{}}' : data;

                            Map res = jsonDecode(data);
                            firstName = res['User']['firstName'];
                            lastName = res['User']['lastName'];
                            firstName ??= "";
                            lastName ??= "";
                            email = res['User']['email'];
                            mobile = res['User']['mobileNumber'];
                            address = res['User']['address'].toString();
                            address = address == 'null' ? '' : address;
                            area = res['User']['area'].toString();
                            area = area == 'null' ? '' : area;
                            city = res['User']['city'].toString();
                            city = city == 'null' ? '' : city;
                            state = res['User']['state'].toString();
                            state = state == 'null' ? '' : state;
                            pincode = res['User']['pincode'].toString();
                            pincode = pincode == 'null' ? '' : pincode;

                            // AwesomeNotifications().cancelAll();
                            bool permissionGrandted = false;
                            if (Platform.isAndroid) {
                              final AndroidDeviceInfo deviceInfo = await DeviceInfoPlugin().androidInfo;
                              Map<Permission, PermissionStatus> _status;
                              if (deviceInfo.version.sdkInt <= 32) {
                                _status = await [Permission.storage].request();
                              } else {
                                _status = await [Permission.photos, Permission.videos].request();
                              }
                              _status.forEach((Permission permission, PermissionStatus status) {
                                if (status == PermissionStatus.granted) {
                                  permissionGrandted = true;
                                }
                              });
                            } else {
                              permissionGrandted = true;
                            }
                            if (permissionGrandted) {
                              // SharedPreferences prefs =
                              //     await SharedPreferences.getInstance();
                              prefs.setString("userFirstNameFromHistory", firstName);
                              prefs.setString("userLastNameFromHistory", lastName);
                              prefs.setString("userEmailFromHistory", email);
                              prefs.setString("userContactFromHistory", mobile);
                              prefs.setString("subsIdFromHistory", subscriptionId);
                              prefs.setString("useraddressFromHistory", address);
                              prefs.setString("userareaFromHistory", area);
                              prefs.setString("usercityFromHistory", city);
                              prefs.setString("userstateFromHistory", state);
                              prefs.setString("userpincodeFromHistory", pincode);
                              Get.snackbar(
                                '',
                                'Invoice will be saved in your mobile!',
                                backgroundColor: AppColors.primaryAccentColor,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 5),
                                isDismissible: false,
                              );
                              Invoice invoiceModel =
                                  await ConsultApi().getInvoiceNumber(ihlId, subscriptionId);
                              invoiceModel.ihlInvoiceNumbers = prefs.getString('invoice');
                              print(invoiceModel.ihlInvoiceNumbers);
                              Future.delayed(const Duration(seconds: 3), () {
                                subscriptionBillView(
                                    context,
                                    widget.details["title"],
                                    widget.details['provider'].toString(),
                                    currentSubscription,
                                    invoiceModel.ihlInvoiceNumbers,
                                    invoiceModel: invoiceModel);
                              });
                            } else {
                              Get.snackbar(
                                  'Storage Access Denied', 'Allow Storage permission to continue',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 5),
                                  isDismissible: false,
                                  mainButton: TextButton(
                                      onPressed: () async {
                                        await openAppSettings();
                                      },
                                      child: const Text('Allow')));
                            }
                          },
                          child: const Text(
                            "Download Invoice",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  //Function to format date from 09-12-2020 - 08-06-2021 to 12/09/2020 - 06/08/2021

  changeDateFormat(var date) {
    String date1 = date;
    String finaldate;
    List<String> test2 = date1.split('');

    List<String> test1 = List<String>(23);
    test1[0] = test2[3];
    test1[1] = test2[4];
    test1[2] = '/';
    test1[3] = test2[0];
    test1[4] = test2[1];
    test1[5] = '/';
    test1[6] = test2[6];
    test1[7] = test2[7];
    test1[8] = test2[8];
    test1[9] = test2[9];
    test1[10] = test2[10];
    test1[11] = test2[11];
    test1[12] = test2[12];
    test1[13] = test2[16];
    test1[14] = test2[17];
    test1[15] = '/';
    test1[16] = test2[13];
    test1[17] = test2[14];
    test1[18] = '/';
    test1[19] = test2[19];
    test1[20] = test2[20];
    test1[21] = test2[21];
    test1[22] = test2[22];
    finaldate = test1.join('');
    return (finaldate);
  }
}
