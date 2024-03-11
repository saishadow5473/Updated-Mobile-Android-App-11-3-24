import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ihl/new_design/presentation/pages/onlineServices/consultationStages.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../constants/app_texts.dart';
import '../../../../constants/routes.dart';
import '../../../../constants/spKeys.dart';
import '../../../../models/freeconsultant_model.dart';
import '../../../../utils/app_colors.dart';
// import '../../../../views/teleconsultation/genix_livecall_signal.dart';
import '../../../../views/teleconsultation/payment/coupen_model.dart';
// import 'package:ihl/constants/api.dart';
import '../../../../views/teleconsultation/view_all_appoinments_free.dart';
import '../../../../widgets/teleconsulation/payment/check.dart';
import '../../../data/model/TeleconsultationModels/doctorModel.dart';
import '../../../data/providers/network/api_provider.dart';
import '../../../firebase_utils/firestore_instructions.dart';
import '../../../jitsi/genix_signal.dart';
import '../../Widgets/appBar.dart';
import '../../Widgets/dashboardWidgets/affiliation_widgets.dart';
import 'MyAppointment.dart';
import 'confirmVisitPage.dart';

class CouponPage extends StatefulWidget {
  DoctorModel doctorDetails;
  Map purposeDetails;
  Map datadecode;
  String startDate;
  String endDate;
  FreeConsultation freeconsult;

  CouponPage(
      {Key key,
      this.doctorDetails,
      this.purposeDetails,
      this.endDate,
      this.datadecode,
      this.startDate,
      this.freeconsult})
      : super(key: key);

  @override
  State<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  TextEditingController coupenController = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();
  http.Client _client = http.Client();

  // bool coupenApplied = false;
  int fullAmount = 0;
  double amountTobePaid;
  var affiliationUniqueName;
  double coupenDiscountedAmount = 0.0;
  ValueNotifier<bool> _startTimer = ValueNotifier<bool>(false);
  ValueNotifier<bool> coupenApplied = ValueNotifier<bool>(false);
  var ss;
  bool coupenProgress = false;
  Map vitals = {};

  String selectedSpecality = "";

  ValueNotifier<int> currentIndex = ValueNotifier<int>(-1);

  @override
  Widget build(BuildContext context) {
    final FocusNode _focusNode = FocusNode();

    vitals = widget.datadecode["LastCheckin"] ?? {};
    print(widget.doctorDetails);
    print(widget.purposeDetails);
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            AppTexts.paymentTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Get.back();
            },
            color: Colors.white,
            tooltip: 'Back',
          ),
        ),
        body: ListView(children: [
          SizedBox(
            height: 20,
          ),
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                SizedBox(
                  width: 80.w,
                  height: 25.h,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Image.asset('assets/icons/couponCode.png', height: 200, width: 300),
                  ),
                ),
                SizedBox(
                  width: 80.w,
                  height: 10.h,
                  child: Center(
                      child: Text(
                    'Pay by Debit/Credit Cards, NetBanking, Wallets and UPI too!',
                    style: TextStyle(
                        color: Color(0xff6d6e71),
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.normal,
                        height: 1.4),
                    textAlign: TextAlign.center,
                  )),
                ),
                Form(
                  key: form,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 90.w,
                          // height: 64,
                          child: ValueListenableBuilder(
                              valueListenable: coupenController,
                              builder: (_, val, __) {
                                return TextFormField(
                                  focusNode: _focusNode,
                                  validator: (str) {
                                    if (str.isEmpty) {
                                      return "Enter Coupon Code";
                                    }
                                    return null;
                                  },
                                  controller: coupenController,
                                  textAlignVertical: TextAlignVertical.center,
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                  decoration: InputDecoration(
                                    hintText: " Enter Coupon Code (Optional)",
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(width: 1, color: AppColors.primaryColor),
                                        borderRadius: BorderRadius.circular(15)),
                                    suffixIcon: coupenController.text == ''
                                        ? SizedBox()
                                        : GestureDetector(
                                            onTap: () async {
                                              if (form.currentState.validate()) {
                                                _focusNode.unfocus();
                                                coupenProgress = true;
                                                CoupenModel s = await checkCouponCode(
                                                    widget.purposeDetails['ihl_consultant_id'],
                                                    coupenController.text,
                                                    'teleconsultation');
                                                if (s.status == "access_allowed") {
                                                  coupenApplied.value = true;
                                                  // s.discountPercentage = 100;
                                                  if (s.discountPercentage != 0.0) {
                                                    fullAmount = int.parse(
                                                        widget.purposeDetails['consultation_fees']);
                                                    double onePersentValue = (fullAmount / 100);
                                                    double amountDecrement = double.parse(
                                                        (s.discountPercentage * onePersentValue)
                                                            .toStringAsFixed(2));

                                                    ss = (fullAmount - amountDecrement);
                                                    // s.discountPercentage = 100;
                                                    if (s.discountPercentage == 100.00 ||
                                                        s.discountPercentage > 100) {
                                                      amountTobePaid = 0;
                                                      coupenDiscountedAmount =
                                                          fullAmount.toDouble();
                                                    } else {
                                                      amountTobePaid = ss;
                                                      coupenDiscountedAmount = amountDecrement;
                                                    }
                                                  } else {
                                                    fullAmount = int.parse(
                                                        widget.purposeDetails['consultation_fees']);
                                                    print(
                                                        widget.purposeDetails['consultation_fees']);
                                                    ss = (fullAmount - s.amount).toDouble();
                                                    // double ss = 300;
                                                    if (ss == fullAmount || ss > fullAmount) {
                                                      amountTobePaid = 0;
                                                      coupenDiscountedAmount =
                                                          fullAmount.toDouble();
                                                    } else {
                                                      amountTobePaid = fullAmount > s.amount
                                                          ? (fullAmount - s.amount).toDouble()
                                                          : 0;
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
                                                  coupenApplied.value = false;
                                                  Get.snackbar('Alert', 'Invalid Coupon!',
                                                      backgroundColor: Colors.lightBlue,
                                                      colorText: Colors.white,
                                                      icon: const Icon(
                                                        Icons.warning,
                                                        color: Colors.white,
                                                      ),
                                                      snackPosition: SnackPosition.BOTTOM);
                                                }
                                                coupenProgress = false;
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(15.0),
                                              child: Container(
                                                width: 10.w,
                                                height: 4.5.h,
                                                color: Colors.black54,
                                                child: coupenProgress
                                                    ? SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child: CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                    : Center(
                                                        child: Icon(
                                                          Icons.arrow_right_alt,
                                                          fill: 1.0,
                                                          color: Colors.white,
                                                          size: 25.sp,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                  ),
                                );
                              }),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                ValueListenableBuilder<bool>(
                    valueListenable: coupenApplied,
                    builder: (BuildContext context, bool value, Widget child) {
                      return Visibility(
                        visible: value,
                        child: SizedBox(
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
                                coupenDatas(title: "Total Amount", amount: fullAmount.toString()),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Coupon Discount"),
                                    Text("₹" +
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
                                const Divider(thickness: 1),
                                coupenDatas(
                                    title: "Amount to be paid",
                                    amount: amountTobePaid.toString().contains(".0")
                                        ? amountTobePaid.toStringAsFixed(0)
                                        : amountTobePaid.toString()),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                SizedBox(
                  height: 3.h,
                ),
                InkWell(
                  onTap: () async {
                    Get.to(PaymentScreen());
                    _startTimer.value = true;

                    if (UpdatingColorsBasedOnAffiliations.sso == false && Tabss.isAffi) {
                      affiliationUniqueName = 'global_services';
                    } else {
                      try {
                        affiliationUniqueName = widget.doctorDetails.affilationExcusiveData
                            .affilationArray[0].affilationUniqueName;
                      } catch (e) {
                        affiliationUniqueName = 'global_services';
                      }
                    }
                    var affiliationMRP;
                    try {
                      affiliationMRP = widget
                          .doctorDetails.affilationExcusiveData.affilationArray[0].affilationMrp;
                    } catch (e) {
                      affiliationMRP = null;
                    }
                    var affiliationPrice;
                    try {
                      affiliationPrice = widget
                          .doctorDetails.affilationExcusiveData.affilationArray[0].affilationPrice;
                    } catch (e) {
                      affiliationPrice = null;
                    }
                    var discountPrice;
                    try {
                      discountPrice = double.parse(affiliationMRP) - double.parse(affiliationPrice);
                    } catch (e) {
                      discountPrice = null;
                    }
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    var data1 = prefs.get('data');
                    Map res = jsonDecode(data1);
                    print(widget.datadecode);
                    var iHLUserId = res['User']['id'];
                    Map finalData = widget.purposeDetails;
                    String name = prefs.getString('name');
                    finalData['consultant_name'] = name;
                    String principalAmt = coupenApplied.value
                        ? (double.parse(amountTobePaid.toString()) / 1.18).toStringAsFixed(2)
                        : (double.parse(widget.purposeDetails["consultation_fees"].toString()) /
                                1.18)
                            .toStringAsFixed(2);
                    principalAmt = principalAmt == "0.00" ? "" : principalAmt;
                    String gstAmt = "";
                    if (principalAmt != "") {
                      gstAmt = ((double.parse(principalAmt) * 18) / 100).toStringAsFixed(2);
                    }

                    print("principalAmt = $principalAmt");
                    print("gstAmt = $gstAmt");
                    Map<String, String> datasToSend = {
                      "principalAmt": principalAmt,
                      "gstAmt": gstAmt,
                      "CouponNumber": coupenApplied.value ? coupenController.text : '',
                      "DiscountType": coupenApplied.value ? "discount" : '',
                      "Discounts": coupenApplied.value ? coupenDiscountedAmount.toString() : "",
                      "MRPCost": widget.doctorDetails.affilationExcusiveData == null
                          ? widget.purposeDetails['consultation_fees']
                          : widget.doctorDetails.affilationExcusiveData.affilationArray[0]
                                      .affilationPrice !=
                                  "none"
                              ? widget.doctorDetails.affilationExcusiveData.affilationArray[0]
                                  .affilationPrice
                              : widget.purposeDetails['consultation_fees'],
                      // 'MRPCost': affiliationMRP.toString(),
                      // 'Discounts': discountPrice.toString(),
                      'ConsultantID': widget.purposeDetails['ihl_consultant_id'].toString(),
                      'ConsultantName': widget.doctorDetails.name.toString(),
                      'PurposeDetails': jsonEncode(finalData),
                      'purpose': 'teleconsult',
                      'AppointmentID': '',
                      'AffilationUniqueName': widget.doctorDetails.affilationExcusiveData == null
                          ? "global_services"
                          : widget.doctorDetails.affilationExcusiveData.affilationArray[0]
                              .affilationUniqueName,
                      'Service_Provided': 'false',
                      'SourceDevice': 'mobile_app',
                      'user_ihl_id': iHLUserId,
                      'user_email': widget.datadecode['User']['email'],
                      'user_mobile_number': widget.datadecode['User']['mobileNumber'],
                      'TotalAmount': coupenApplied.value
                          ? amountTobePaid.toString()
                          : widget.doctorDetails.affilationExcusiveData != null
                              ? widget.doctorDetails.affilationExcusiveData.affilationArray[0]
                                  .affilationPrice
                              : widget.purposeDetails['consultation_fees'],
                      "MobileNumber": widget.datadecode['User']['mobileNumber'],
                      "payment_status": "initiated",
                      "vendor_name": widget.doctorDetails.vendorId.toString(),
                      "account_name": widget.doctorDetails.vendorId.toString() == "GENIX"
                          ? widget.doctorDetails.accountName.toString()
                          : '',
                      "service_provided_date": widget.startDate
                    };
                    // if (coupenApplied) {
                    //   datasToSend["UsageType"] = "coupon";
                    // }
                    log(datasToSend.toString());
                    if (amountTobePaid != 0) {
                      startTimer();
                      final paymentInitiateResponse = await _client.post(
                        Uri.parse("${API.iHLUrl}/data/paymenttransaction"),
                        headers: {
                          'Content-Type': 'application/json',
                          'ApiToken':
                              '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==',
                          'Token': '${API.headerr['Token']}',
                        },
                        body: jsonEncode(datasToSend),
                      );
                      if (paymentInitiateResponse.statusCode == 200) {
                        // if (this.mounted)
                        //   setState(() {
                        _startTimer.value = false;
                        // });
                        var sendData = dataToSend();
                        var finalResponse = json.decode(paymentInitiateResponse.body);
                        var invoiceNumber = finalResponse['invoice_number'];
                        var transactionId = finalResponse['transaction_id'];
                        sendData['invoiceNumber'] = invoiceNumber;
                        sendData['transaction_id'] = transactionId;
                        var orderID = await getOrderID(
                            API.orderIdValue,
                            coupenApplied.value
                                ? amountTobePaid.toString()
                                : widget.purposeDetails['consultation_fees']);

                        ///for live this one
                        /*var orderID = await getOrderID(
                                'true', widget.details['fees']);*/
                        sendData['orderID'] = orderID;
                        sendData['affiliationPrice'] = widget.purposeDetails['consultation_fees'];
                        // rp.Razorpay _rp = rp.Razorpay();
                        // _rp.open({
                        //   'key': API.paymentKey,
                        //   'amount': 100,
                        //   'name': 'Acme Corp.',
                        //   'description': 'Fine T-Shirt',
                        //   'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'}
                        // });

                        Get.to(CheckRazorNew(
                            details: sendData,
                            purposeDetails: widget.purposeDetails,
                            datadecode: widget.datadecode,
                            doctorDetails: widget.doctorDetails));

                        // if (mounted) setState(() {});
                      } else {
                        AwesomeDialog(
                            context: Get.context,
                            animType: AnimType.topSlide,
                            headerAnimationLoop: true,
                            dialogType: DialogType.warning,
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
                      }
                    } else {
                      // if (mounted) setState(() {});
                      log("zero payment flow");
                      Get.to(TeleConsultationStagesScreen(
                        doctorDetails: widget.doctorDetails,
                        startDate: widget.startDate,
                        endDate: widget.endDate,
                        JoinCall: widget.doctorDetails.livecall,
                        // freeConsultation: _freeConsultation,
                        loading: _startTimer.value,
                      ));
                      freeConsultationProceed();
                    }
                    // _isLoading = false;
                    // setState(() {});
                  },
                  child: Container(
                      width: 30.w,
                      height: 5.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColors.myApp, borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        "PROCEED",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Future<CoupenModel> checkCouponCode(
      String consultant_id, String couponCode, String purpose) async {
    var res = await Dio().get(API.iHLUrl +
        "/data/check_access_code?code=${couponCode}&ihl_id=${consultant_id}&source=mobile&consultant_id=${consultant_id}&course_id=&purpose=${purpose}");
    log(res.data.toString());
    // if (res.data['status'] == 'access_allowed') {
    //   return 'allowed';
    // } else {
    //   return 'Denied';
    // }
    return CoupenModel.fromJson(res.data);
  }

  Future<String> getOrderID(String livePaymentMode, String fees) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    String finalFees = (double.parse(fees) * 100).toInt().toString();
    // String finalFees = (int.parse('1') * 100).toString();
    print(
        "${API.updatedIHLurl}/payment/tele_consult/pay.php?paymentLiveMode=$livePaymentMode&receipt=mobile$timeStamp&amount=$finalFees");
    final generateOrderID = await _client.get(
      Uri.parse(
          "${API.updatedIHLurl}/payment/tele_consult/pay.php?paymentLiveMode=$livePaymentMode&receipt=mobile$timeStamp&amount=$finalFees"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    print({
      'Content-Type': 'application/json',
      'ApiToken': '${API.headerr['ApiToken']}',
      'Token': '${API.headerr['Token']}',
    }.toString());

    if (generateOrderID.statusCode == 200) {
      var response = generateOrderID.body;
      var finalResponse = json.decode(response);
      return finalResponse['order'];
    } else {
      AwesomeDialog(
          context: context,
          animType: AnimType.topSlide,
          headerAnimationLoop: true,
          dialogType: DialogType.warning,
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

  Map dataToSend() {
    return {
      'email': widget.datadecode['User']['email'],
      'mobile': widget.datadecode['User']['mobileNumber'],
      'fees': widget.purposeDetails["consultation_fees"],
      'livecall': widget.doctorDetails.livecall,
      'start_date': widget.startDate.toString(),
      'end_date': widget.purposeDetails['end_date'].toString(),
      'doctor': widget.doctorDetails.name,
      'reason': widget.purposeDetails['reason'] ?? "",
      'alergy': widget.purposeDetails['alergy'] ?? "",
      'specality': widget.doctorDetails.consultantSpeciality.toString(),
      'invoiceNumber': widget.purposeDetails['invoiceNumber'].toString(),
      'transaction_id': widget.purposeDetails['transaction_id'].toString(),
      'purposeDetails': widget.purposeDetails,
      'document_id': widget.purposeDetails['document_id'],
      "CouponNumber": coupenApplied.value ? coupenController.text : "",
      "DiscountType": coupenApplied.value ? "discount" : "",
      "Discounts": coupenApplied.value ? coupenDiscountedAmount.toString() : "",
      // "UsageType": coupenApplied.value ? "coupon" : "",
      "MRPCost": coupenApplied.value ? amountTobePaid.toString() : ""
    };
  }

  void startTimer() async {
    Duration duration = Duration(seconds: 5);
    await Timer.periodic(duration, (Timer timer) {
      if (currentIndex.value < 3) {
        currentIndex.value++;
      } else {
        timer.cancel();
        currentIndex.value = 0;
        _startTimer.value = false;
      }
    });
  }

  void freeConsultationProceed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    Map res = jsonDecode(data);
    dynamic vitals = res["LastCheckin"] ?? {};
    selectedSpecality = widget.doctorDetails.consultantSpeciality.first ?? "N/A";
    String ihlId = prefs.getString("ihlUserId");

    String apiToken = prefs.get('auth_token');
    prefs.setString('consultantName', widget.doctorDetails.name.toString());
    prefs.setString('consultantId', widget.doctorDetails.ihlConsultantId.toString());
    prefs.setString('vendorName', widget.doctorDetails.vendorId.toString());
    prefs.setString('vendorConId', widget.doctorDetails.ihlConsultantId.toString());

    final response = await _client.post(
      Uri.parse('${API.iHLUrl}/consult/BookAppointment'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, dynamic>{
        "user_ihl_id": ihlId.toString(),
        "consultant_name": widget.doctorDetails.name.toString(),
        "vendor_consultant_id": widget.doctorDetails.vendorConsultantId.toString(),
        "ihl_consultant_id": widget.doctorDetails.ihlConsultantId.toString(),
        "vendor_id": widget.doctorDetails.vendorId.toString(),
        "specality": selectedSpecality.toString(),
        "consultation_fees": widget.purposeDetails["consultation_fees"],
        "mode_of_payment": "discount",
        "alergy": widget.purposeDetails["alergy"] ?? "",
        "kiosk_checkin_history": widget.purposeDetails["kiosk_checkin_history"],
        "appointment_start_time":
            widget.startDate.toString().replaceAll("-", "/"), //yyyy-mm-dd 03:00 PM
        "appointment_end_time": widget.endDate.toString().replaceAll("-", "/"),
        "appointment_duration": "30 Min",
        "appointment_status": widget.doctorDetails.livecall == true ? "Approved" : "Requested",
        "vendor_name": widget.doctorDetails.vendorId.toString(),
        "appointment_model": "appointment",
        "reason_for_visit": widget.purposeDetails["reason_for_visit"],
        "notes": "",
        "document_id": widget.purposeDetails["document_id"],
        "direct_call": widget.doctorDetails.vendorId.toString() == "GENIX" &&
                widget.doctorDetails.livecall == true
            ? true
            : false,
        "affiliation_unique_name": affiliationUniqueName
      }),
    );

    // widget.details['doctor']['vendor_id'].toString() == "GENIX" && widget.details['livecall'] == true ? true:false,
    if (response.statusCode == 200) {
      dynamic bookedDate = bookingDate();
      var parsedString = response.body.replaceAll('&quot', '"');
      var parsedString2 = parsedString.replaceAll(";", "");
      var parsedString3 = parsedString2.replaceAll('"{', '{');
      var parsedString4 = parsedString3.replaceAll('}"', '}');
      var finalResponse = json.decode(parsedString4);
      // ignore: unused_local_variable
      var appointId =
          finalResponse['appointment_id']; //'ihl_consultant_' + finalResponse['appointment_id'];
      var vendorAppointId = finalResponse['vendor_appointment_id'];
      String appointmentId = finalResponse['appointment_id'];
      final paymentInitiateResponse = await _client.post(
        Uri.parse("${API.iHLUrl}/data/paymenttransaction"),
        headers: {
          'Content-Type': 'application/json',
          // 'ApiToken': '${API.headerr['ApiToken']}',
          'ApiToken':
              '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, String>{
          "principalAmt": "",
          "gstAmt": "",
          "CouponNumber": coupenController.text,
          "DiscountType": "discount",
          // 'MRPCost': 'FREE',
          "MRPCost": widget.purposeDetails["consultation_fees"],
          'Discounts': coupenDiscountedAmount.toString(),
          'ConsultantID': widget.doctorDetails.ihlConsultantId.toString(),
          'ConsultantName': widget.doctorDetails.name.toString(),
          'PurposeDetails': jsonEncode(widget.purposeDetails),
          'purpose': 'teleconsult',
          "appointment_id": finalResponse['appointment_id'],
          'AppointmentID': '',
          'AffilationUniqueName': affiliationUniqueName,
          'Service_Provided': 'false',
          'SourceDevice': 'mobile_app',
          'user_ihl_id': ihlId,
          'user_email': widget.doctorDetails.email,
          'user_mobile_number': widget.doctorDetails.contactNumber,
          'TotalAmount': '0',
          "MobileNumber": widget.doctorDetails.contactNumber,
          "payment_status": "completed",
          "vendor_name": widget.doctorDetails.vendorId.toString(),
          // "account_name":"default account",
          // "service_provided_date"://appointment or subscription start date
          "account_name": widget.doctorDetails.vendorId.toString() == "GENIX"
              ? widget.doctorDetails.accountName.toString()
              : '',
          "service_provided_date": bookedDate[0]
        }),
      );
      if (paymentInitiateResponse.statusCode == 200) {
        print(paymentInitiateResponse.body);
        var parsedString = paymentInitiateResponse.body;
        var finalResponsepayment = json.decode(parsedString);
        var invoiceNumber = finalResponsepayment['invoice_number'];
        var transactionId = finalResponsepayment['transaction_id'];
        if (!widget.doctorDetails.livecall) {
          FireStoreServices.appointmentStatusUpdate(
              attributes: AppointmentStatusModel(
                  docID: widget.doctorDetails.ihlConsultantId.toString(),
                  userID: ihlId,
                  status: "Requested",
                  appointmentID: appointmentId));
        }
        final paymentUpdateStatusResponse = await _client.post(
          Uri.parse("${API.iHLUrl}/consult/update_payment_transaction"),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
          body: jsonEncode(<String, String>{
            'MRPCost': "FREE",
            'ConsultantID': widget.doctorDetails.ihlConsultantId.toString(),
            'ConsultantName': widget.doctorDetails.name.toString(),
            "ihl_id": ihlId,
            "PurposeDetails": jsonEncode(widget.purposeDetails),
            "TotalAmount": "0",
            "payment_status": "completed",
            "transactionId": transactionId,
            "payment_for": "teleconsultation",
            "MobileNumber": widget.doctorDetails.contactNumber,
            //"payment_mode": "online",
            "UsageType": "Coupon",
            "Service_Provided": 'false',
            "appointment_id": finalResponse['appointment_id'],
            "AppointmentID": finalResponse['appointment_id'],
            "razorpay_payment_id": "",
            "razorpay_order_id": "",
            "razorpay_signature": ""
          }),
        );
        if (paymentUpdateStatusResponse.statusCode == 200) {
          print(paymentUpdateStatusResponse.body);
        }
      }
      // Updating getUserDetails API
      final getUserDetails = await _client.post(Uri.parse("${API.iHLUrl}/consult/get_user_details"),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
          body: jsonEncode(<String, String>{
            'ihl_id': ihlId,
          }));
      if (getUserDetails.statusCode == 200) {
        // if (this.mounted) {
        //   setState(() {
        //     // loading = false;
        //   });
        // }
        final userDetailsResponse = await SharedPreferences.getInstance();
        userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
        userDetailsResponse.setString(
          'consultantId_for_share',
          widget.doctorDetails.ihlConsultantId.toString(),
        );
        var data = prefs.get('data');
        Map res = jsonDecode(data);
        String userFirstName, userLastName, ihlUserName;
        userFirstName = res['User']['firstName'];
        userLastName = res['User']['lastName'];
        userFirstName ??= "";
        userLastName ??= "";
        ihlUserName = "$userFirstName $userLastName";

        if (widget.doctorDetails.livecall == true) {
          if (widget.doctorDetails.vendorId.toString() == 'GENIX') {
            String date =
                "${widget.startDate.replaceAll("/", "-")} - ${widget.endDate.replaceAll("/", "-")}";
            String appointmentId = finalResponse['appointment_id'];
            Get.to(FreeSuccessPage(
                date: date,
                appointment_ID: appointmentId,
                liveCall: true,
                // materialPageRoute:
                materialPageRoute: () {
                  Get.to(GenixSignal(
                      genixCallDetails: GenixCallDetails(
                          genixAppointId: appointmentId.replaceAll("ihl_consultant_", ''),
                          ihlUserId: ihlId,
                          specality: widget.doctorDetails.consultantSpeciality.first,
                          vendorAppointmentId: vendorAppointId,
                          vendorConsultantId: widget.doctorDetails.vendorConsultantId,
                          vendorUserName: widget.doctorDetails.userName)));
                }));
          } else {
            String date =
                widget.startDate.replaceAll("/", "-") + " - " + widget.endDate.replaceAll("/", "-");
            String appointment_ID = finalResponse['appointment_id'];
            Get.to(FreeSuccessPage(
                date: date,
                appointment_ID: appointment_ID,
                liveCall: true,
                // materialPageRoute:
                materialPageRoute: () {
                  Get.offNamedUntil(Routes.CallWaitingScreen, (route) => false, arguments: [
                    appointId.toString(),
                    widget.doctorDetails.ihlConsultantId.toString(),
                    ihlId.toString(),
                    "LiveCall",
                    ihlUserName
                  ]);
                }));
          }
        } else {
          String date =
              "${widget.startDate.replaceAll("/", "-")} - ${widget.endDate.replaceAll("/", "-")}";
          String appointment_ID = finalResponse['appointment_id'];
          Get.to(FreeSuccessPage(
              date: date,
              appointment_ID: appointment_ID,
              liveCall: false,
              // materialPageRoute:
              materialPageRoute: () {
                Get.to(MyAppointment(backNav: false));
              }));
        }
        // AwesomeDialog(
        //     context: context,
        //     animType: AnimType.TOPSLIDE,
        //     headerAnimationLoop: true,
        //     dialogType: DialogType.SUCCES,
        //     dismissOnTouchOutside: false,
        //     title: 'Success!',
        //     desc: widget.details['doctor']['livecall']
        //         ? 'Appointment confirmed! Join in and kindly wait for the doctor to connect.'
        //         : 'Appointment Booked Successfully ',
        //     btnOkOnPress: () {
        //       if (widget.details['doctor']['livecall'] == true) {
        //         if (widget.details['doctor']['vendor_id'].toString() == 'GENIX') {
        //           String date = widget.details["start_date"].replaceAll("/", "-") +
        //               " - " +
        //               widget.details["end_date"].replaceAll("/", "-");
        //           String appointment_ID = finalResponse['appointment_id'];
        //           Get.to(FreeSuccessPage(
        //               date: date,
        //               appointment_ID: appointment_ID,
        //               liveCall: true,
        //               // materialPageRoute:
        //               materialPageRoute: () {
        //                 Navigator.push(
        //                   context,
        //                   MaterialPageRoute(
        //                     builder: (context) => GenixLiveSignal(
        //                       // genixAppointId: appointId.toString().replaceAll('ihl_consultant_', ''),
        //                       genixAppointId: appointmentId,
        //                       iHLUserId: ihlId.toString(),
        //                       specality: selectedSpecality.toString(),
        //                       vendor_consultant_id:
        //                           widget.details['doctor']['vendor_consultant_id'].toString(),
        //                       vendorConsultantId:
        //                           widget.details['doctor']['vendor_consultant_id'].toString(),
        //                       vendorAppointmentId: vendorAppointId,
        //                       vendorUserName: widget.details['doctor']['user_name'],
        //                     ),
        //                   ), //user_name
        //                 );
        //               }));
        //         } else {
        //           String date = widget.details["start_date"].replaceAll("/", "-") +
        //               " - " +
        //               widget.details["end_date"].replaceAll("/", "-");
        //           String appointment_ID = finalResponse['appointment_id'];
        //           Get.to(FreeSuccessPage(
        //               date: date,
        //               appointment_ID: appointment_ID,
        //               liveCall: true,
        //               // materialPageRoute:
        //               materialPageRoute: () {
        //                 Get.offNamedUntil(Routes.CallWaitingScreen, (route) => false, arguments: [
        //                   appointId.toString(),
        //                   widget.details['doctor']['ihl_consultant_id'].toString(),
        //                   ihlId.toString(),
        //                   "LiveCall",
        //                   ihlUserName
        //                 ]);
        //               }));
        //         }
        //       } else {
        //         String date = widget.details["start_date"].replaceAll("/", "-") +
        //             " - " +
        //             widget.details["end_date"].replaceAll("/", "-");
        //         String appointment_ID = finalResponse['appointment_id'];
        //         Get.to(FreeSuccessPage(
        //             date: date,
        //             appointment_ID: appointment_ID,
        //             liveCall: true,
        //             // materialPageRoute:
        //             materialPageRoute: () {}));
        //         Navigator.of(context).pushNamed(Routes.MyAppointments);
        //       }
        //     },
        //     btnOkText:
        //         widget.details['doctor']['livecall'] == true ? 'Join Call' : 'View My Appointments',
        //     onDismissCallback: (_) {
        //       debugPrint('Dialog Dissmiss from callback');
        //     }).show();
      } else {
        // if (this.mounted) {
        //   setState(() {
        //     // loading = false;
        //   });
        // }

        final userDetailsResponse = await SharedPreferences.getInstance();
        userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
        var data = prefs.get('data');
        Map res = jsonDecode(data);
        String userFirstName, userLastName, ihlUserName;
        userFirstName = res['User']['firstName'];
        userLastName = res['User']['lastName'];
        userFirstName ??= "";
        userLastName ??= "";
        ihlUserName = "$userFirstName $userLastName";
        if (widget.doctorDetails.livecall == true) {
          if (widget.doctorDetails.vendorId.toString() == 'GENIX') {
            String date =
                widget.startDate.replaceAll("/", "-") + " - " + widget.endDate.replaceAll("/", "-");
            String appointment_ID = finalResponse['appointment_id'];
            Get.to(FreeSuccessPage(
                date: date,
                appointment_ID: appointment_ID,
                liveCall: true,
                // materialPageRoute:
                materialPageRoute: () {
                  Get.to(GenixSignal(
                      genixCallDetails: GenixCallDetails(
                          genixAppointId: appointmentId.replaceAll("ihl_consultant_", ''),
                          ihlUserId: ihlId,
                          specality: widget.doctorDetails.consultantSpeciality.first,
                          vendorAppointmentId: vendorAppointId,
                          vendorConsultantId: widget.doctorDetails.vendorConsultantId,
                          vendorUserName: widget.doctorDetails.userName)));
                }));
          } else {
            String date =
                widget.startDate.replaceAll("/", "-") + " - " + widget.endDate.replaceAll("/", "-");
            String appointmentId = finalResponse['appointment_id'];
            Get.to(FreeSuccessPage(
                date: date,
                appointment_ID: appointmentId,
                liveCall: true,
                // materialPageRoute:
                materialPageRoute: () {
                  Get.offNamedUntil(Routes.CallWaitingScreen, (route) => false, arguments: [
                    appointId.toString(),
                    widget.doctorDetails.ihlConsultantId.toString(),
                    ihlId.toString(),
                    "LiveCall",
                    ihlUserName
                  ]);
                }));
          }
        } else {
          String date =
              widget.startDate.replaceAll("/", "-") + " - " + widget.endDate.replaceAll("/", "-");
          String appointmentId = finalResponse['appointment_id'];
          Get.to(FreeSuccessPage(
              date: date,
              appointment_ID: appointmentId,
              liveCall: false,
              // materialPageRoute:
              materialPageRoute: () {
                Navigator.of(context).pushNamed(Routes.MyAppointments);
              }));
        }
        // AwesomeDialog(
        //     context: context,
        //     animType: AnimType.TOPSLIDE,
        //     headerAnimationLoop: true,
        //     dialogType: DialogType.SUCCES,
        //     dismissOnTouchOutside: false,
        //     title: 'Success!',
        //     desc: widget.details['doctor']['livecall']
        //         ? 'Appointment confirmed! Join in and kindly wait for the doctor to connect.'
        //         : 'Appointment Booked Successfully',
        //     btnOkOnPress: () {
        //       if (widget.details['doctor']['livecall'] == true) {
        //         if (widget.details['doctor']['vendor_id'].toString() == 'GENIX') {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => GenixLiveSignal(
        //                       // genixAppointId: appointId.toString().replaceAll('ihl_consultant_', ''),
        //                       genixAppointId: appointmentId,
        //                       iHLUserId: ihlId.toString(),
        //                       specality: selectedSpecality.toString(),
        //                       vendor_consultant_id:
        //                           widget.details['doctor']['vendor_consultant_id'].toString(),
        //                       vendorConsultantId:
        //                           widget.details['doctor']['vendor_consultant_id'].toString(),
        //                       vendorAppointmentId: vendorAppointId,
        //                       vendorUserName: widget.details['doctor']['user_name'],
        //                     )), //user_name
        //           );
        //         }
        //         Get.offNamedUntil(Routes.CallWaitingScreen, (route) => false, arguments: [
        //           appointId.toString(),
        //           widget.details['doctor']['ihl_consultant_id'].toString(),
        //           ihlId.toString(),
        //           "LiveCall",
        //           ihlUserName
        //         ]);
        //       } else {
        //         Navigator.of(context).pushNamed(Routes.MyAppointments);
        //       }
        //     },
        //     btnOkText:
        //         widget.details['doctor']['livecall'] == true ? 'Join Call' : 'View My Appointments',
        //     onDismissCallback: (_) {
        //       debugPrint('Dialog Dissmiss from callback');
        //     }).show();
        print(getUserDetails.body);
      }
    } else {
      AwesomeDialog(
              context: context,
              animType: AnimType.topSlide,
              headerAnimationLoop: true,
              dialogType: DialogType.info,
              dismissOnTouchOutside: false,
              title: 'Failed!',
              desc: 'Appointment not Booked. Please try again later.',
              btnOkOnPress: () {
                Navigator.of(context).pop();
              },
              btnOkColor: AppColors.primaryAccentColor,
              btnOkText: 'Try Later',
              btnOkIcon: Icons.refresh,
              onDismissCallback: (_) {})
          .show();
    }
  }

  bookingDate() {
    var dataa = dataToSend();
    print(dataa);
    return [dataa['start_date'], dataa['end_date']];
  }

  Widget coupenDatas({String title, String amount}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text("₹" + amount),
      ],
    );
  }
}
