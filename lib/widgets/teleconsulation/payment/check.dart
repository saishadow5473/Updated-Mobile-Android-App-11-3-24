import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../new_design/data/model/TeleconsultationModels/doctorModel.dart';
import '../../../new_design/presentation/pages/onlineServices/paymentSuccessNew.dart';

class CheckRazorNew extends StatefulWidget {
  final Map details;
  final Map datadecode;
  DoctorModel doctorDetails;
  Map purposeDetails;

  CheckRazorNew({Key key, this.details, this.datadecode, this.doctorDetails, this.purposeDetails})
      : super(key: key);

  @override
  _CheckRazorNewState createState() => _CheckRazorNewState();
}

class _CheckRazorNewState extends State<CheckRazorNew> {
  String email;
  String mobileNumber;
  Razorpay _razorpay = Razorpay();
  var options;

  Future payData() async {
    try {
      _razorpay.open(options);
    } catch (e) {
      print(e);
    }

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print(response);
    var _sendData = widget.details;
    _sendData['razorpay_order_id'] = response.orderId;
    _sendData["razorpay_payment_id"] = response.paymentId;
    _sendData["razorpay_signature"] = response.signature;
    Get.to(SuccessPageNew(
      details: _sendData,
      datadecode: widget.datadecode,
      doctorDetails: widget.doctorDetails,
      purposeDetails: widget.purposeDetails,
    ));
    // Navigator.pushReplacementNamed(context, Routes.PaymentSuccess, arguments: _sendData);
    _razorpay.clear();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    String finalReason = response.message;
    try {
      if (finalReason.contains("cancelled")) {
        Navigator.of(context).pop(context);
        Navigator.of(context).pop(context);
        _razorpay.clear();
      } else if (finalReason.contains("failed")) {
        Navigator.pushReplacementNamed(context, Routes.PaymentFailure, arguments: response);
        _razorpay.clear();
      }
    } catch (e) {
      Navigator.pushReplacementNamed(context, Routes.PaymentFailure, arguments: response);
      _razorpay.clear();
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _razorpay.clear();
  }

  @override
  void initState() {
    super.initState();
    email = widget.details['email'].toString();
    mobileNumber = widget.details['mobile'].toString();
    int fees = int.tryParse(widget.details['fees']);
    var orderID = widget.details['orderID'];
    options = {
      'key': API.paymentKey, //"rzp_live_keRAkk0ilTO72f", // Live mode key
      // "rzp_test_OCp8bDk51p2f96",
      'order_id': orderID,
      'amount': fees * 100,
      'name': 'India Health Link Ltd.',
      'currency': "INR",
      //'theme.color': "528FF0",
      'theme.color': "#1A90D9",
      'buttontext': "Pay with Razorpay",
      'description': 'Tele-Consultation Fees',
      'prefill': {
        'contact': widget.details['mobile'],
        'email': widget.details['email'],
      },
      'external': {
        'wallets': ['paytm', 'amazonpay']
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: payData(),
        builder: (context, snapshot) {
          return Container(
            child: Center(
              child: Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CheckRazor extends StatefulWidget {
  final Map details;

  CheckRazor({Key key, this.details}) : super(key: key);

  @override
  _CheckRazorState createState() => _CheckRazorState();
}

class _CheckRazorState extends State<CheckRazor> {
  String email;
  String mobileNumber;
  Razorpay _razorpay = Razorpay();
  var options;

  Future payData() async {
    try {
      _razorpay.open(options);
    } catch (e) {
      print(e);
    }

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print(response);
    var _sendData = widget.details;
    _sendData['razorpay_order_id'] = response.orderId;
    _sendData["razorpay_payment_id"] = response.paymentId;
    _sendData["razorpay_signature"] = response.signature;

    Navigator.pushReplacementNamed(context, Routes.PaymentSuccess, arguments: _sendData);
    _razorpay.clear();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    String finalReason = response.message;
    try {
      if (finalReason.contains("cancelled")) {
        Navigator.of(context).pop(context);
        _razorpay.clear();
      } else if (finalReason.contains("failed")) {
        Navigator.pushReplacementNamed(context, Routes.PaymentFailure, arguments: response);
        _razorpay.clear();
      }
    } catch (e) {
      Navigator.pushReplacementNamed(context, Routes.PaymentFailure, arguments: response);
      _razorpay.clear();
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _razorpay.clear();
  }

  @override
  void initState() {
    super.initState();
    email = widget.details['email'].toString();
    mobileNumber = widget.details['mobile'].toString();
    int fees = int.tryParse(widget.details['fees']);
    var orderID = widget.details['orderID'];
    options = {
      'key': API.paymentKey, //"rzp_live_keRAkk0ilTO72f", // Live mode key
      // "rzp_test_OCp8bDk51p2f96",
      'order_id': orderID,
      'amount': fees * 100,
      'name': 'India Health Link Ltd.',
      'currency': "INR",
      //'theme.color': "528FF0",
      'theme.color': "#1A90D9",
      'buttontext': "Pay with Razorpay",
      'description': 'Tele-Consultation Fees',
      'prefill': {
        'contact': widget.details['mobile'],
        'email': widget.details['email'],
      },
      'external': {
        'wallets': ['paytm', 'amazonpay']
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: payData(),
        builder: (context, snapshot) {
          return Container(
            child: Center(
              child: Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
