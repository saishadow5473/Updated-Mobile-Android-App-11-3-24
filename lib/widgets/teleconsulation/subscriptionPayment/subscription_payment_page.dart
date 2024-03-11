import 'dart:convert';

//for coupan
import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/teleconsultation/payment/coupen_model.dart';
import 'package:ihl/widgets/teleconsulation/payment/paymentUI.dart';
import 'package:ihl/widgets/teleconsulation/subscriptionPayment/subscription_check.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/SpUtil.dart';
import 'subscription_payment_success.dart';

class SubscriptionPaymentPage extends StatefulWidget {
  final Map details;

  const SubscriptionPaymentPage({Key key, this.details}) : super(key: key);

  @override
  _SubscriptionPaymentPageState createState() => _SubscriptionPaymentPageState();
}

class _SubscriptionPaymentPageState extends State<SubscriptionPaymentPage> {
  http.Client _client = http.Client(); //3gb
  String email, mobileNumber;
  bool _isLoading = false;

  //Coupen cotroller
  TextEditingController coupenController = TextEditingController();
  String selectedSpecality = "";
  var affiliationUniqueName;
  GlobalKey<FormState> form = GlobalKey<FormState>();
  bool coupenApplied = false;
  String ihlId = '';
  int fullAmount = 0;
  double coupenDiscountedAmount = 0.0;
  double amountTobePaid;
  bool coupenProgress = false;

  Map dataToSend() {
    print(widget.details);
    return {
      'email': email,
      'mobile': mobileNumber,
      "course_img_url": widget.details['course_img_url']!=null?widget.details['course_img_url'].toString():"",
      "title": widget.details['title'].toString(),
      "course_id": widget.details['course_id'].toString(),
      "course_time": widget.details['course_time'],
      "course_on": widget.details['course_on'],
      "reason_for_visit": "",
      "category": "",
      "course_type": widget.details['fees_for'].toString(),
      "appointment_date_time": "",
      "provider": widget.details['provider'].toString(),
      "fees_for": widget.details['fees_for'].toString(),
      "consultant_name": widget.details['consultant_name'].toString(),
      "consultant_gender": widget.details['consultant_gender'].toString(),
      "course_fees": widget.details['course_fees'].toString(),
      "consultant_id": widget.details['consultant_id'].toString(),
      "subscriber_count": widget.details['subscriber_count'].toString(),
      "available_slot_count": widget.details['available_slot_count'].toString(),
      "course_duration": widget.details['course_duration'].toString(),
      "available_slot": widget.details['available_slot'],
      "approval_status": widget.details['approval_status'],
      'invoiceNumber': widget.details['invoiceNumber'].toString(),
      'transaction_id': widget.details['transaction_id'].toString()
    };
  }

  @override
  void initState() {
    // TODO: implement initState
    personalDetails();
    super.initState();
  }

  String _firstname;
  String _lastname;

  void personalDetails() async {
    amountTobePaid = double.parse(widget.details["course_fees"]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ihlId = prefs.getString("ihlUserId");
    var data = prefs.get(SPKeys.userData);
    Map res = jsonDecode(data);
    email = res['User']['email'] ?? 'User@gmail.com';
    mobileNumber = res['User']['mobileNumber'] ?? '9999999999';
    _firstname = res['User']['firstName'];
    _lastname = res['User']['lastName'];
  }

  Future<String> getOrderID(String livePaymentMode, String fees) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    String finalFees = (double.parse(fees) * 100).toInt().toString();
    final generateOrderID = await _client.get(
      Uri.parse(
          "${API.updatedIHLurl}/payment/tele_consult/pay.php?paymentLiveMode=$livePaymentMode&receipt=mob$timeStamp&amount=$finalFees"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    if (generateOrderID.statusCode == 200) {
      var response = generateOrderID.body;
      var finalResponse = json.decode(response);
      return finalResponse['order'];
    } else {
      AwesomeDialog(
          context: context,
          animType: AnimType.TOPSLIDE,
          headerAnimationLoop: true,
          dialogType: DialogType.WARNING,
          dismissOnTouchOutside: true,
          title: 'Oh-ho!',
          desc: 'Unable to process your payment at the moment. Please try again.',
          btnOkOnPress: () {
            Navigator.of(context).pop();
          },
          btnOkIcon: Icons.replay_outlined,
          btnOkText: 'Try Again',
          onDismissCallback: (_) {
            debugPrint('Dialog Dissmiss from callback');
          }).show();
      return 'No OrderID generated for payment';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaymentUI(
      color: AppColors.myApp,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "Proceed to Pay",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(context),
          color: Colors.white,
          tooltip: 'Back',
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Lottie.network('https://assets8.lottiefiles.com/packages/lf20_XjtJt8.json',
                      height: 200, width: 300),
                ),
                SizedBox(
                  height: 80,
                  child: Center(
                      child: Text(
                    'Pay by Debit/Credit Cards, NetBanking, Wallets and UPI too!',
                    style: TextStyle(
                        color: Color(0xff6d6e71),
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.normal,
                        height: 1),
                    textAlign: TextAlign.center,
                  )),
                ),
                Visibility(
                  visible: !coupenApplied,
                  child: Form(
                    key: form,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 3,
                        child: ExpansionTile(
                          title: Text('Coupon Code'),
                          children: [
                            SizedBox(
                              width: 80.w,
                              // height: 64,
                              child: TextFormField(
                                validator: (str) {
                                  if (str.isEmpty) {
                                    return "Enter Coupon Code";
                                  }
                                  return null;
                                },
                                controller: coupenController,
                                textAlignVertical: TextAlignVertical.center,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "Coupon Code",
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1, color: AppColors.myApp),
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            InkWell(
                              onTap: () async {
                                if (form.currentState.validate()) {
                                  coupenProgress = true;
                                  if (mounted) setState(() {});
                                  log("Claim Coupon");
                                  CoupenModel s = await checkCouponCode(
                                      widget.details['course_id'].toString(),
                                      coupenController.text,
                                      'class');
                                  if (s.status == "access_allowed") {
                                    coupenApplied = true;
                                    if (s.discountPercentage != 0.0) {
                                      fullAmount = int.parse(widget.details['course_fees']);
                                      double onePersentValue = (fullAmount / 100);
                                      double amountDecrement = double.parse(
                                          (s.discountPercentage * onePersentValue)
                                              .toStringAsFixed(2));

                                      double ss = (fullAmount - amountDecrement);
                                      // double ss = 129;
                                      if (s.discountPercentage == 100.00 ||
                                          s.discountPercentage > 100) {
                                        amountTobePaid = 0;
                                        coupenDiscountedAmount = fullAmount.toDouble();
                                      } else {
                                        amountTobePaid = ss;
                                        coupenDiscountedAmount = amountDecrement;
                                      }
                                    } else {
                                      fullAmount = int.parse(widget.details['course_fees']);
                                      print(widget.details['course_fees']);
                                      double ss = (fullAmount - s.amount).toDouble();
                                      // double ss = 101;//
                                      if (ss == fullAmount || ss > fullAmount) {
                                        amountTobePaid = 0;
                                        coupenDiscountedAmount = fullAmount.toDouble();
                                      } else {
                                        amountTobePaid = (fullAmount - s.amount).toDouble();
                                        coupenDiscountedAmount = s.amount.toDouble();
                                      }
                                    }
                                    Get.snackbar('Congrats ! ! !', 'Coupon Applied!',
                                        backgroundColor: Colors.lightBlue,
                                        colorText: Colors.white,
                                        icon: Icon(
                                          Icons.thumb_up_alt,
                                          color: Colors.white,
                                        ),
                                        snackPosition: SnackPosition.BOTTOM);
                                  } else {
                                    coupenApplied = false;
                                    Get.snackbar('Alert', 'Invalid Coupon!',
                                        backgroundColor: Colors.lightBlue,
                                        colorText: Colors.white,
                                        icon: Icon(
                                          Icons.warning,
                                          color: Colors.white,
                                        ),
                                        snackPosition: SnackPosition.BOTTOM);
                                  }
                                  coupenProgress = false;
                                }
                                if (mounted) setState(() {});
                              },
                              child: Container(
                                  width: 20.w,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: AppColors.myApp,
                                      borderRadius: BorderRadius.circular(250)),
                                  child: coupenProgress
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          "Claim",
                                          style: TextStyle(color: Colors.white),
                                        )),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: coupenApplied,
                  child: Card(
                    elevation: 4,
                    // elevation: 50,
                    shadowColor: Colors.black,
                    color: Colors.lightBlue[50],
                    child: Container(
                      width: 90.w,
                      // decoration: BoxDecoration(
                      //     border: Border.all(
                      //       color: Colors.blue,
                      //       width: 1,
                      //     ),
                      //     borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text("Bill Details"),
                            Divider(thickness: 1, color: Colors.blueGrey),
                            coupenDatas(title: "Total Amount", ammount: fullAmount.toString()),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Coupon Discount"),
                                Text("-₹" +
                                    (coupenDiscountedAmount.toString().contains(".0")
                                        ? coupenDiscountedAmount.toStringAsFixed(0)
                                        : coupenDiscountedAmount.toString())),
                              ],
                            ),
                            // SizedBox(height: 5),
                            // coupenDatas(
                            //     title: "IGST 18% ",
                            //     ammount: (amountTobePaid - (amountTobePaid * 100 / (100 + 18)))
                            //         .toStringAsFixed(1)
                            //         .toString()),
                            // SizedBox(height: 10),
                            Divider(thickness: 1),
                            coupenDatas(
                                title: "Amount to be paid",
                                ammount: amountTobePaid.toString().contains(".0")
                                    ? amountTobePaid.toStringAsFixed(0)
                                    : amountTobePaid.toString()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.myApp,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    onPressed: _isLoading
                        ? () {}
                        : () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            var courseDate = SpUtil.getString("selectedDateFromPicker");
                            var courseTime = SpUtil.getString("selectedTime")==""?widget.details["course_time"]:SpUtil.getString("selectedTime");
                            print(widget.details);
                            String filteredDate = courseDate==""?widget.details["class_duration"]:changeDateFormat(courseDate.toString());

                            setState(() {
                              _isLoading = true;
                            });

                            var data = prefs.get('data');
                            Map res = jsonDecode(data);
                            var mobile = res['User']['mobileNumber'];
                            var ihlUserID = res['User']['id'];
                            String principalAmt = coupenApplied
                                ? (double.parse(amountTobePaid.toString()) / 1.18)
                                    .toStringAsFixed(2)
                                : (double.parse(widget.details['course_fees'].toString()) / 1.18)
                                    .toStringAsFixed(2);
                            principalAmt = principalAmt == "0.00" ? "" : principalAmt;
                            String gstAmt = "";
                            if (principalAmt != "") {
                              gstAmt = ((double.parse(principalAmt) * 18) / 100).toStringAsFixed(2);
                            }

                            print("principalAmt = $principalAmt");
                            print("gstAmt = $gstAmt");
                            final paymentInitiateResponse = await _client.post(
                              Uri.parse("${API.iHLUrl}/data/paymenttransaction"),
                              headers: {
                                'Content-Type': 'application/json',
                                'ApiToken': '${API.headerr['ApiToken']}',
                                'Token': '${API.headerr['Token']}',
                              },
                              // headers: {
                              //   'ApiToken':
                              //       '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==',
                              // },
                              body: jsonEncode(<String, String>{
                                'user_email': email.toString(),
                                'user_mobile_number': mobile.toString(),
                                "principal_amount": principalAmt.toString(),
                                "gst_amount": gstAmt.toString(),
                                'MRPCost': widget.details['AffilationUniqueName'] != "none"
                                    ? widget.details['affiliationPrice'].toString()
                                    : widget.details['course_fees'].toString(),
                                'DiscountType': coupenApplied ? "discount" : "",
                                'Discounts': coupenDiscountedAmount != 0.0
                                    ? (coupenDiscountedAmount.toString().contains(".0")
                                        ? coupenDiscountedAmount.toStringAsFixed(0)
                                        : coupenDiscountedAmount.toString())
                                    : "",
                                'CouponNumber': coupenApplied ? coupenController.text : "",
                                'ConsultantID': widget.details['consultant_id'].toString(),
                                'ConsultantName': widget.details['consultant_name'].toString(),
                                "ClassName": widget.details['title'].toString(),
                                'PurposeDetails': jsonEncode(<String, dynamic>{
                                  "user_ihl_id": ihlUserID,
                                  "course_id": widget.details['course_id'].toString(),
                                  "name": "$_firstname $_lastname",
                                  "email": email.toString(),
                                  "mobile_number": mobile.toString(),
                                  "course_type": widget.details['course_type'].toString(),
                                  "course_time": courseTime.toString(),
                                  "provider": widget.details['provider'].toString(),
                                  "fees_for": widget.details['fees_for'].toString(),
                                  "consultant_name": widget.details['consultant_name'].toString(),
                                  "course_duration": filteredDate,
                                  "course_fees": widget.details['course_fees'].toString(),
                                  "consultation_id": widget.details['consultant_id'].toString(),
                                  "approval_status":
                                      widget.details['auto_approve'].toString() == 'true'
                                          ? "Accepted"
                                          : 'Requested',
                                  "mode_of_payment": "online",
                                  // 'name': _firstname + " " + _lastname,
                                  // "user_ihl_id": ihlUserID.toString(),
                                  // 'user_email': email.toString(),
                                  // 'user_mobile_number': mobileNumber.toString(),
                                  // "consultant_name": widget.details['consultant_name'].toString(),
                                  // "vendor_consultant_id": '',
                                  // "ihl_consultant_id": widget.details['consultant_id'].toString(),
                                  // "vendor_id": '',
                                  // "specality": '',
                                  // "consultation_fees":
                                  //     widget.details['AffilationUniqueName'] != "none"
                                  //         ? widget.details['affiliationPrice'].toString()
                                  //         : widget.details['course_fees'].toString(),
                                  // "mode_of_payment": "online",
                                  // "alergy": "",
                                  // "kiosk_checkin_history": [],
                                  // // "appointment_start_time": '', //yyyy-mm-dd 03:00 PM
                                  // // "appointment_end_time": '',
                                  // "appointment_duration":
                                  //     widget.details['course_duration'] ?? "30 Min",
                                  // "appointment_status": "Requested",
                                  // "vendor_name": '',
                                  // "appointment_model": "",
                                  // "reason_for_visit": '',
                                  // "notes": ""
                                }),
                                'purpose': 'online_class',
                                'AppointmentID': '',
                                'AffilationUniqueName':
                                    widget.details['AffilationUniqueName'] != "none"
                                        ? widget.details['AffilationUniqueName']
                                        : "global_services",
                                'Service_Provided': 'false',
                                'SourceDevice': 'mobile_app',
                                'user_ihl_id': ihlUserID,
                                'TotalAmount': coupenApplied
                                    ? amountTobePaid.toString()
                                    : widget.details['AffilationUniqueName'] != "none"
                                        ? widget.details['affiliationPrice'].toString()
                                        : widget.details['course_fees'].toString(),
                                "MobileNumber": mobile,
                                "payment_status": "initiated",
                                "account_name": '',
                                "service_provided_date": widget.details['classStartTime']
                              }),
                            );
                            if (paymentInitiateResponse.statusCode == 200) {
                              print(paymentInitiateResponse.body);
                              /*{"status": "inserted","invoice_number": "IHL-21-22/0000000003"}*/
                              var parsedString = paymentInitiateResponse.body;
                              var finalResponse = json.decode(parsedString);
                              var invoiceNumber = finalResponse['invoice_number'];
                              var transactionId = finalResponse['transaction_id'];
                              var orderID;

                              ///change to true for live and false for test
                              // if(widget.details['fees']!=null){
                              //    orderID = await getOrderID('true', widget.details['fees']);
                              // }
                              // else{
                              if (amountTobePaid > 0) {
                                orderID = await getOrderID(
                                    API.orderIdValue,
                                    coupenApplied
                                        ? amountTobePaid.toString()
                                        : widget.details['course_fees']);
                              } else {
                                orderID = '';
                              }

                              //}
                              /*var orderID = await getOrderID(
                                'true', widget.details['course_fees']);*/
                              var sendData = dataToSend();
                              sendData['invoice_number'] = invoiceNumber;
                              sendData['transaction_id'] = transactionId;
                              sendData['orderID'] = orderID;
                              sendData['CouponNumber'] = coupenApplied ? coupenController.text : "";
                              sendData['DiscountType'] = coupenApplied ? "discount" : "";
                              sendData['Discounts'] = coupenDiscountedAmount != 0.0
                                  ? (coupenDiscountedAmount.toString().contains(".0")
                                      ? coupenDiscountedAmount.toStringAsFixed(0)
                                      : coupenDiscountedAmount.toString())
                                  : "";
                              sendData['MRPCost'] = widget.details['course_fees'].toString();
                              if (amountTobePaid == 0) {
                                Get.to(SubscriptionSuccessPage(details: sendData));
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        SubscriptionCheckRazor(details: sendData),
                                  ),
                                );
                              }

                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                    child: _isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                // Lottie.network(
                                //     "https://assets8.lottiefiles.com/packages/lf20_zjrmnlsu.json",
                                //     height: ScUtil().setHeight(155)),
                                SizedBox(
                                    height: 35,
                                    child: CircularProgressIndicator(color: Colors.white)),
                                // Text("Loading...",
                                //     style: TextStyle(
                                //         fontSize: ScUtil().setSp(10), fontWeight: FontWeight.w600))
                              ],
                            ),
                          )
                        : Text(
                            "Proceed",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget coupenDatas({String title, String ammount}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text("₹" + ammount),
      ],
    );
  }

  Future<CoupenModel> checkCouponCode(
      String consultant_id, String couponCode, String purpose) async {
//&kiosk_id=
    var res = await Dio().get(
        "${API.iHLUrl}/data/check_access_code?code=$couponCode&ihl_id=$ihlId&source=mobile&consultant_id=&course_id=$consultant_id&purpose=$purpose");
    log(res.data.toString());
    // if (res.data['status'] == 'access_allowed') {
    //   return 'allowed';
    // } else {
    //   return 'Denied';
    // }
    return CoupenModel.fromJson(res.data);
  }

  Future<CoupenModel> coupenDetail({String coupenCode}) async {
    var res = await Dio().get(
        API.iHLUrl + "/data/check_access_code?code=${coupenCode}&ihl_id=${ihlId}&source=mobile");
    log(res.data.toString());
    return CoupenModel.fromJson(res.data);
  }

  changeDateFormat(var date) {
    String date1 = date;
    String finaldate;
    List<String> test2 = date1.split('');

    List<String> test1 = []..length = 23;
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
