import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/teleconsultation/payment/coupen_model.dart';
import 'package:ihl/widgets/teleconsulation/payment/check.dart';
import 'package:ihl/widgets/teleconsulation/payment/paymentUI.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../constants/routes.dart';
import '../../../new_design/presentation/Widgets/appBar.dart';
import '../../../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../../new_design/presentation/pages/onlineServices/MyAppointment.dart';
import '../genix_livecall_signal.dart';
import '../view_all_appoinments_free.dart';

class PaymentPage extends StatefulWidget {
  final Map details;

  const PaymentPage({Key key, this.details}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  http.Client _client = http.Client(); //3gb
  String email;
  String mobileNumber;
  bool _isLoading = false;

  Map dataToSend() {
    return {
      'email': email,
      'mobile': mobileNumber,
      'fees': widget.details['fees'].toString(),
      'livecall': widget.details['livecall'],
      'start_date': widget.details['start_date'].toString(),
      'end_date': widget.details['end_date'].toString(),
      'doctor': widget.details['doctor'],
      'reason': widget.details['reason'] ?? "",
      'alergy': widget.details['alergy'] ?? "",
      'specality': widget.details['specality'].toString(),
      'invoiceNumber': widget.details['invoiceNumber'].toString(),
      'transaction_id': widget.details['transaction_id'].toString(),
      'purposeDetails': widget.details['purposeDetails'],
      'document_id': widget.details['document_id'],
      "CouponNumber": coupenApplied ? coupenController.text : "",
      "DiscountType": coupenApplied ? "discount" : "",
      "Discounts": coupenApplied ? coupenDiscountedAmount.toString() : "",
      // "UsageType": coupenApplied ? "coupon" : "",
      "MRPCost": coupenApplied ? amountTobePaid.toString() : ""
    };
  }

  @override
  void initState() {
    super.initState();
    log(widget.details["doctor"]["livecall"].toString());
    personalDetails();
  }

  //Coupen cotroller
  TextEditingController coupenController = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();
  bool coupenApplied = false;
  String ihlId = '';
  int fullAmount = 0;
  double coupenDiscountedAmount = 0.0;
  double amountTobePaid;
  bool coupenProgress = false;
  String selectedSpecality = "";
  var affiliationUniqueName;

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

  void personalDetails() async {
    log("Status Checking ======== ${widget.details.toString()}");
    amountTobePaid = double.parse(widget.details['fees']);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedSpecality = prefs.getString("selectedSpecality");
    ihlId = prefs.getString("ihlUserId");
    var data = prefs.get(SPKeys.userData);
    Map res = jsonDecode(data);
    email = res['User']['email'] ?? 'Enter your Email';
    mobileNumber = res['User']['mobileNumber'] ?? '9999999999';
    // DateTime now = DateTime.now();
    // var formattedDate = DateTime.parse("11/11/2011");
    // final String formatted = formatter.format(date);
    DateTime sDate = DateFormat('yyyy-MM-dd hh:mm a').parse(widget.details["start_date"]);
    DateTime eDate = DateFormat('yyyy-MM-dd hh:mm a').parse(widget.details["end_date"]);

    log(sDate.day.toString());
    final DateFormat formatter = DateFormat("MM-dd-yyyy hh:mm a");
    String sDa = formatter.format(sDate);
    String eDa = formatter.format(eDate);
    widget.details["start_date"] = sDa;
    widget.details["end_date"] = eDa;
    //     DateFormat format = DateFormat("dd.MM.yyyy");
    // print(format.parse(date));
    log(sDa);
    log(eDa);
  }

  int currentIndex = 0;
  bool _startTimer = false;

  void startTimer() {
    Duration duration = Duration(seconds: 6);
    Timer.periodic(duration, (Timer timer) {
      if (currentIndex < 3) {
        setState(() {
          currentIndex++;
        });
      } else {
        timer.cancel();
        currentIndex = 0;
        _startTimer = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PaymentUI(
      color: AppColors.myApp,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
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
                Visibility(
                  visible: !_startTimer,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Lottie.network(
                        'https://assets8.lottiefiles.com/packages/lf20_XjtJt8.json',
                        height: 200,
                        width: 300),
                  ),
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
                        height: 1.4),
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
                                print(widget.details['purposeDetails']);
                                if (form.currentState.validate()) {
                                  coupenProgress = true;
                                  if (mounted) setState(() {});
                                  log("Claim Coupon");
                                  CoupenModel s = await checkCouponCode(
                                      widget.details['doctor']['ihl_consultant_id'],
                                      coupenController.text,
                                      'teleconsultation');
                                  if (s.status == "access_allowed") {
                                    coupenApplied = true;
                                    // s.discountPercentage = 100;
                                    if (s.discountPercentage != 0.0) {
                                      fullAmount = int.parse(widget.details['fees']);
                                      double onePersentValue = (fullAmount / 100);
                                      double amountDecrement = double.parse(
                                          (s.discountPercentage * onePersentValue)
                                              .toStringAsFixed(2));

                                      double ss = (fullAmount - amountDecrement);
                                      // s.discountPercentage = 100;
                                      if (s.discountPercentage == 100.00 ||
                                          s.discountPercentage > 100) {
                                        amountTobePaid = 0;
                                        coupenDiscountedAmount = fullAmount.toDouble();
                                      } else {
                                        amountTobePaid = ss;
                                        coupenDiscountedAmount = amountDecrement;
                                      }
                                    } else {
                                      fullAmount = int.parse(widget.details['fees']);
                                      print(widget.details['fees']);
                                      double ss = (fullAmount - s.amount).toDouble();
                                      // double ss = 300;
                                      if (ss == fullAmount || ss > fullAmount) {
                                        amountTobePaid = 0;
                                        coupenDiscountedAmount = fullAmount.toDouble();
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
                SizedBox(height: 10),
                Container(
                  height: 51,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.myApp,
                    ),
                    onPressed: _isLoading
                        ? () {}
                        : () async {
                            log('Button Clicked Start ' + DateTime.now().toLocal().toString());
                            _startTimer = true;
                            _isLoading = true;
                            // widget.details['fees'] = '10';
                            if (this.mounted) setState(() {});
                            //Existing flow slashed below.
                            // try {
                            //   affiliationUniqueName = widget.details['doctor']
                            //           ['affilation_excusive_data']['affilation_array'][0]
                            //       ['affilation_unique_name'];
                            // } catch (e) {
                            //   affiliationUniqueName = 'global_services';
                            // }
                            //New Flow implemented for affiliationUniqueName value🔘🔘
                            if (UpdatingColorsBasedOnAffiliations.sso == false && Tabss.isAffi) {
                              affiliationUniqueName = 'global_services';
                            } else {
                              try {
                                affiliationUniqueName = widget.details['doctor']
                                        ['affilation_excusive_data']['affilation_array'][0]
                                    ['affilation_unique_name'];
                              } catch (e) {
                                affiliationUniqueName = 'global_services';
                              }
                            }
                            var affiliationMRP;
                            try {
                              affiliationMRP = widget.details['doctor']['affilation_excusive_data']
                                  ['affilation_array'][0]['affilation_mrp'];
                            } catch (e) {
                              affiliationMRP = null;
                            }
                            var affiliationPrice;
                            try {
                              affiliationPrice = widget.details['doctor']
                                      ['affilation_excusive_data']['affilation_array'][0]
                                  ['affilation_price'];
                            } catch (e) {
                              affiliationPrice = null;
                            }
                            var discountPrice;
                            try {
                              discountPrice =
                                  double.parse(affiliationMRP) - double.parse(affiliationPrice);
                            } catch (e) {
                              discountPrice = null;
                            }
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            Map finalData = widget.details["purposeDetails"];
                            String name = prefs.getString('name');
                            finalData['name'] = name;
                            String principalAmt = coupenApplied
                                ? (double.parse(amountTobePaid.toString()) / 1.18)
                                    .toStringAsFixed(2)
                                : (double.parse(widget.details['fees'].toString()) / 1.18)
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
                              "CouponNumber": coupenApplied ? coupenController.text : "",
                              "DiscountType": coupenApplied ? "discount" : "",
                              "Discounts": coupenDiscountedAmount != 0.0
                                  ? (coupenDiscountedAmount.toString().contains(".0")
                                      ? coupenDiscountedAmount.toStringAsFixed(0)
                                      : coupenDiscountedAmount.toString())
                                  : "",
                              "MRPCost": widget.details['affiliationPrice'] != "none"
                                  ? widget.details['affiliationPrice']
                                  : widget.details['doctor']['consultation_fees'],
                              // 'MRPCost': affiliationMRP.toString(),
                              // 'Discounts': discountPrice.toString(),
                              'ConsultantID':
                                  widget.details['doctor']['ihl_consultant_id'].toString(),
                              'ConsultantName': widget.details['doctor']['name'].toString(),
                              'PurposeDetails': jsonEncode(finalData),
                              'purpose': 'teleconsult',
                              'AppointmentID': '',
                              'AffilationUniqueName': affiliationUniqueName,
                              'Service_Provided': 'false',
                              'SourceDevice': 'mobile_app',
                              'user_ihl_id': ihlId,
                              'user_email': widget.details["email"],
                              'user_mobile_number': widget.details["mobile_number"],
                              'TotalAmount': coupenApplied
                                  ? amountTobePaid.toString()
                                  : widget.details['affiliationPrice'] != "none"
                                      ? widget.details['affiliationPrice']
                                      : widget.details['doctor']['consultation_fees'],
                              "MobileNumber": widget.details["mobile_number"],
                              "payment_status": "initiated",
                              "vendor_name": widget.details['doctor']['vendor_id'].toString(),
                              "account_name":
                                  widget.details['doctor']['vendor_id'].toString() == "GENIX"
                                      ? widget.details['doctor']['account_name'].toString()
                                      : '',
                              "service_provided_date": widget.details["start_date"]
                            };
                            // if (coupenApplied) {
                            //   datasToSend["UsageType"] = "coupon";
                            // }
                            if (amountTobePaid != 0) {
                              log('Payment API Start ' + DateTime.now().toLocal().toString());
                              startTimer();
                              final paymentInitiateResponse = await _client.post(
                                Uri.parse(API.iHLUrl + "/data/paymenttransaction"),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'ApiToken':
                                      '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==',
                                  'Token': '${API.headerr['Token']}',
                                },
                                body: jsonEncode(datasToSend),
                              );
                              if (paymentInitiateResponse.statusCode == 200) {
                                if (this.mounted)
                                  setState(() {
                                    _startTimer = false;
                                  });
                                var sendData = dataToSend();
                                var finalResponse = json.decode(paymentInitiateResponse.body);
                                var invoiceNumber = finalResponse['invoice_number'];
                                var transactionId = finalResponse['transaction_id'];
                                sendData['invoiceNumber'] = invoiceNumber;
                                sendData['transaction_id'] = transactionId;
                                var orderID = await getOrderID(
                                    API.orderIdValue,
                                    coupenApplied
                                        ? amountTobePaid.toString()
                                        : widget.details['fees']);

                                ///for live this one
                                /*var orderID = await getOrderID(
                                'true', widget.details['fees']);*/
                                sendData['orderID'] = orderID;
                                sendData['affiliationPrice'] = widget.details['affiliationPrice'];
                                // rp.Razorpay _rp = rp.Razorpay();
                                // _rp.open({
                                //   'key': API.paymentKey,
                                //   'amount': 100,
                                //   'name': 'Acme Corp.',
                                //   'description': 'Fine T-Shirt',
                                //   'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'}
                                // });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        CheckRazor(details: sendData),
                                  ),
                                );
                                _isLoading = false;
                                if (mounted) setState(() {});
                              }
                            } else {
                              _isLoading = true;
                              if (mounted) setState(() {});
                              log("zero payment flow");
                              await freeConsultationProceed();
                            }
                            // _isLoading = false;
                            setState(() {});
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
          AnimatedContainer(
            duration: Duration(seconds: 2),
            height: _startTimer ? 45.h : 0.h,
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: ListView(physics: NeverScrollableScrollPhysics(), children: [
              TimelineTile(
                alignment: TimelineAlign.center,
                isFirst: true,
                afterLineStyle: LineStyle(color: currentIndex >= 1 ? Colors.green : Colors.grey),
                startChild: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 2.w,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Initializing Payment...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.sp), color: Colors.green[100]),
                  height: 10.h,
                ),
                indicatorStyle: IndicatorStyle(color: Colors.green),
              ),
              TimelineTile(
                alignment: TimelineAlign.center,
                isFirst: false,
                indicatorStyle:
                    IndicatorStyle(color: currentIndex >= 1 ? Colors.green : Colors.grey),
                beforeLineStyle: LineStyle(color: currentIndex >= 1 ? Colors.green : Colors.grey),
                afterLineStyle: LineStyle(color: currentIndex >= 2 ? Colors.green : Colors.grey),
                endChild: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 2.w,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Checking Status...',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.sp),
                      color: currentIndex >= 1 ? Colors.green[100] : Colors.grey[200]),
                  height: 10.h,
                ),
              ),
              TimelineTile(
                alignment: TimelineAlign.center,
                isLast: true,
                indicatorStyle:
                    IndicatorStyle(color: currentIndex >= 2 ? Colors.green : Colors.grey),
                afterLineStyle: LineStyle(color: currentIndex >= 3 ? Colors.green : Colors.grey),
                beforeLineStyle: LineStyle(color: currentIndex >= 2 ? Colors.green : Colors.grey),
                startChild: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 2.w,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Connecting to Payment screen...',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.sp),
                      color: currentIndex >= 2 ? Colors.green[100] : Colors.grey[200]),
                  height: 10.h,
                ),
              ),
            ]),
          )
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
    var res = await Dio().get(API.iHLUrl +
        "/data/check_access_code?code=${couponCode}&ihl_id=${ihlId}&source=mobile&consultant_id=${consultant_id}&course_id=&purpose=${purpose}");
    log(res.data.toString());
    // if (res.data['status'] == 'access_allowed') {
    //   return 'allowed';
    // } else {
    //   return 'Denied';
    // }
    return CoupenModel.fromJson(res.data);
  }

  Future<CoupenModel> coupenDetail({String coupenCode}) async {
//&kiosk_id=
    var res = await Dio().get(
        API.iHLUrl + "/data/check_access_code?code=${coupenCode}&ihl_id=${ihlId}&source=mobile");
    log(res.data.toString());
    return CoupenModel.fromJson(res.data);
  }

  void freeConsultationProceed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    Map res = jsonDecode(data);
    dynamic vitals = res["LastCheckin"] ?? {};

    String apiToken = prefs.get('auth_token');
    prefs.setString('consultantName', widget.details['doctor']['name'].toString());
    prefs.setString('consultantId', widget.details['doctor']['ihl_consultant_id'].toString());
    prefs.setString('vendorName', widget.details['doctor']['vendor_id'].toString());
    prefs.setString('vendorConId', widget.details['doctor']['ihl_consultant_id'].toString());

    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/BookAppointment'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, dynamic>{
        "user_ihl_id": ihlId.toString(),
        "consultant_name": widget.details['doctor']['name'].toString(),
        "vendor_consultant_id": widget.details['doctor']['vendor_consultant_id'].toString(),
        "ihl_consultant_id": widget.details['doctor']['ihl_consultant_id'].toString(),
        "vendor_id": widget.details['doctor']['vendor_id'].toString(),
        "specality": selectedSpecality.toString(),
        "consultation_fees": widget.details['affiliationPrice'] != "none"
            ? widget.details['affiliationPrice']
            : widget.details['doctor']['consultation_fees'],
        "mode_of_payment": "discount",
        "alergy": widget.details["alergy"] ?? "",
        "kiosk_checkin_history": widget.details["purposeDetails"]["kiosk_checkin_history"],
        "appointment_start_time":
            widget.details["start_date"].toString().replaceAll("-", "/"), //yyyy-mm-dd 03:00 PM
        "appointment_end_time": widget.details["end_date"].toString().replaceAll("-", "/"),
        "appointment_duration": "30 Min",
        "appointment_status":
            widget.details['doctor']['livecall'] == true ? "Approved" : "Requested",
        "vendor_name": widget.details['doctor']['vendor_id'].toString(),
        "appointment_model": "appointment",
        "reason_for_visit": widget.details["reason"],
        "notes": "",
        "document_id": widget.details["purposeDetails"]["document_id"],
        "direct_call": widget.details['doctor']['vendor_id'].toString() == "GENIX" &&
                widget.details['doctor']['livecall'] == true
            ? true
            : false,
        "affiliation_unique_name": Tabss.isAffi ? 'global_services' : affiliationUniqueName
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
        Uri.parse(API.iHLUrl + "/data/paymenttransaction"),
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
          "MRPCost": widget.details['affiliationPrice'] != "none"
              ? widget.details['affiliationPrice']
              : widget.details['doctor']['consultation_fees'],
          'Discounts': coupenDiscountedAmount.toString(),
          'ConsultantID': widget.details['doctor']['ihl_consultant_id'].toString(),
          'ConsultantName': widget.details['doctor']['name'].toString(),
          'PurposeDetails': jsonEncode(widget.details["purposeDetails"]),
          'purpose': 'teleconsult',
          "appointment_id": finalResponse['appointment_id'],
          'AppointmentID': '',
          'AffilationUniqueName': affiliationUniqueName,
          'Service_Provided': 'false',
          'SourceDevice': 'mobile_app',
          'user_ihl_id': ihlId,
          'user_email': widget.details["email"],
          'user_mobile_number': widget.details["mobile_number"],
          'TotalAmount': '0',
          "MobileNumber": widget.details["mobile_number"],
          "payment_status": "completed",
          "vendor_name": widget.details['doctor']['vendor_id'].toString(),
          // "account_name":"default account",
          // "service_provided_date"://appointment or subscription start date
          "account_name": widget.details['doctor']['vendor_id'].toString() == "GENIX"
              ? widget.details['doctor']['account_name'].toString()
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

        final paymentUpdateStatusResponse = await _client.post(
          Uri.parse(API.iHLUrl + "/consult/update_payment_transaction"),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
          body: jsonEncode(<String, String>{
            'MRPCost': "FREE",
            'ConsultantID': widget.details['doctor']['ihl_consultant_id'].toString(),
            'ConsultantName': widget.details['doctor']['name'].toString(),
            "ihl_id": ihlId,
            "PurposeDetails": jsonEncode(widget.details["purposeDetails"]),
            "TotalAmount": "0",
            "payment_status": "completed",
            "transactionId": transactionId,
            "payment_for": "teleconsultation",
            "MobileNumber": widget.details["mobile_number"],
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
      final getUserDetails = await _client.post(Uri.parse(API.iHLUrl + "/consult/get_user_details"),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
          body: jsonEncode(<String, String>{
            'ihl_id': ihlId,
          }));
      if (getUserDetails.statusCode == 200) {
        _isLoading = false;
        if (this.mounted) {
          setState(() {
            // loading = false;
          });
        }
        final userDetailsResponse = await SharedPreferences.getInstance();
        userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
        userDetailsResponse.setString(
          'consultantId_for_share',
          widget.details['doctor']['ihl_consultant_id'].toString(),
        );
        var data = prefs.get('data');
        Map res = jsonDecode(data);
        String userFirstName, userLastName, ihlUserName;
        userFirstName = res['User']['firstName'];
        userLastName = res['User']['lastName'];
        userFirstName ??= "";
        userLastName ??= "";
        ihlUserName = userFirstName + " " + userLastName;

        if (widget.details['livecall'] == true) {
          if (widget.details['doctor']['vendor_id'].toString() == 'GENIX') {
            String date = widget.details["start_date"].replaceAll("/", "-") +
                " - " +
                widget.details["end_date"].replaceAll("/", "-");
            String appointment_ID = finalResponse['appointment_id'];
            Get.to(FreeSuccessPage(
                date: date,
                appointment_ID: appointment_ID,
                liveCall: true,
                // materialPageRoute:
                materialPageRoute: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenixLiveSignal(
                        // genixAppointId: appointId.toString().replaceAll('ihl_consultant_', ''),
                        genixAppointId: appointmentId,
                        iHLUserId: ihlId.toString(),
                        specality: selectedSpecality.toString(),
                        vendor_consultant_id:
                            widget.details['doctor']['vendor_consultant_id'].toString(),
                        vendorConsultantId:
                            widget.details['doctor']['vendor_consultant_id'].toString(),
                        vendorAppointmentId: vendorAppointId,
                        vendorUserName: widget.details['doctor']['user_name'],
                      ),
                    ), //user_name
                  );
                }));
          } else {
            String date = widget.details["start_date"].replaceAll("/", "-") +
                " - " +
                widget.details["end_date"].replaceAll("/", "-");
            String appointment_ID = finalResponse['appointment_id'];
            Get.to(FreeSuccessPage(
                date: date,
                appointment_ID: appointment_ID,
                liveCall: true,
                // materialPageRoute:
                materialPageRoute: () {
                  Get.offNamedUntil(Routes.CallWaitingScreen, (route) => false, arguments: [
                    appointId.toString(),
                    widget.details['doctor']['ihl_consultant_id'].toString(),
                    ihlId.toString(),
                    "LiveCall",
                    ihlUserName
                  ]);
                }));
          }
        } else {
          String date = widget.details["start_date"].replaceAll("/", "-") +
              " - " +
              widget.details["end_date"].replaceAll("/", "-");
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
        _isLoading = false;
        if (this.mounted) {
          setState(() {
            // loading = false;
          });
        }

        final userDetailsResponse = await SharedPreferences.getInstance();
        userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
        var data = prefs.get('data');
        Map res = jsonDecode(data);
        String userFirstName, userLastName, ihlUserName;
        userFirstName = res['User']['firstName'];
        userLastName = res['User']['lastName'];
        userFirstName ??= "";
        userLastName ??= "";
        ihlUserName = userFirstName + " " + userLastName;
        if (widget.details['doctor']['livecall'] == true) {
          if (widget.details['doctor']['vendor_id'].toString() == 'GENIX') {
            String date = widget.details["start_date"].replaceAll("/", "-") +
                " - " +
                widget.details["end_date"].replaceAll("/", "-");
            String appointment_ID = finalResponse['appointment_id'];
            Get.to(FreeSuccessPage(
                date: date,
                appointment_ID: appointment_ID,
                liveCall: true,
                // materialPageRoute:
                materialPageRoute: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenixLiveSignal(
                        // genixAppointId: appointId.toString().replaceAll('ihl_consultant_', ''),
                        genixAppointId: appointmentId,
                        iHLUserId: ihlId.toString(),
                        specality: selectedSpecality.toString(),
                        vendor_consultant_id:
                            widget.details['doctor']['vendor_consultant_id'].toString(),
                        vendorConsultantId:
                            widget.details['doctor']['vendor_consultant_id'].toString(),
                        vendorAppointmentId: vendorAppointId,
                        vendorUserName: widget.details['doctor']['user_name'],
                      ),
                    ), //user_name
                  );
                }));
          } else {
            String date = widget.details["start_date"].replaceAll("/", "-") +
                " - " +
                widget.details["end_date"].replaceAll("/", "-");
            String appointment_ID = finalResponse['appointment_id'];
            Get.to(FreeSuccessPage(
                date: date,
                appointment_ID: appointment_ID,
                liveCall: true,
                // materialPageRoute:
                materialPageRoute: () {
                  Get.offNamedUntil(Routes.CallWaitingScreen, (route) => false, arguments: [
                    appointId.toString(),
                    widget.details['doctor']['ihl_consultant_id'].toString(),
                    ihlId.toString(),
                    "LiveCall",
                    ihlUserName
                  ]);
                }));
          }
        } else {
          String date = widget.details["start_date"].replaceAll("/", "-") +
              " - " +
              widget.details["end_date"].replaceAll("/", "-");
          String appointment_ID = finalResponse['appointment_id'];
          Get.to(FreeSuccessPage(
              date: date,
              appointment_ID: appointment_ID,
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
      _isLoading = false;
      AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: true,
              dialogType: DialogType.INFO,
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

  changeDateFormat(var date) {
    String date1 = date;
    String finaldate;
    List<String> test2 = date1.split('');
    List<String> test1 = List<String>(19);
    test1[0] = test2[5];
    test1[1] = test2[6];
    test1[2] = '/';
    test1[3] = test2[8];
    test1[4] = test2[9];
    test1[5] = '/';
    test1[6] = test2[0];
    test1[7] = test2[1];
    test1[8] = test2[2];
    test1[9] = test2[3];
    test1[10] = test2[10];
    test1[11] = test2[11];
    test1[12] = test2[12];
    test1[13] = test2[13];
    test1[14] = test2[14];
    test1[15] = test2[15];
    test1[16] = test2[16];
    test1[17] = test2[17];
    test1[18] = test2[18];
    finaldate = test1.join('');
    return finaldate;
  }
}
