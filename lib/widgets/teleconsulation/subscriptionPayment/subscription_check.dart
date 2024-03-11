import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscriptionCheckRazor extends StatefulWidget {
  final Map details;

  const SubscriptionCheckRazor({Key key, this.details}) : super(key: key);
  @override
  _SubscriptionCheckRazorState createState() => _SubscriptionCheckRazorState();
}

class _SubscriptionCheckRazorState extends State<SubscriptionCheckRazor> {
  String email;
  String mobileNumber;
  Razorpay _razorpay = Razorpay();
  var options;

  Future payData() async {
    try {
      _razorpay.open(options);
    } catch (e) {}

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    var _sendData = widget.details;
    _sendData['razorpay_order_id'] = response.orderId;
    _sendData["razorpay_payment_id"] = response.paymentId;
    _sendData["razorpay_signature"] = response.signature;
    Navigator.pushReplacementNamed(context, Routes.SubscriptionPaymentSuccess,
        arguments: _sendData);
    _razorpay.clear();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    String finalReason = response.message;
    try {
      if (finalReason.contains("cancelled")) {
        Navigator.of(context).pop(context);
        _razorpay.clear();
      } else if (finalReason.contains("failed")) {
        Navigator.pushReplacementNamed(context, Routes.SubscriptionPaymentFailed,
            arguments: response);
        _razorpay.clear();
      }
    } catch (e) {
      Navigator.pushReplacementNamed(context, Routes.SubscriptionPaymentFailed,
          arguments: response);
      _razorpay.clear();
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _razorpay.clear();
  }

  @override
  void initState() {
    super.initState();
    int fees = int.tryParse(widget.details['course_fees']);
    var orderID = widget.details['orderID'];
    options = {
      'key': //"rzp_test_OCp8bDk51p2f96", //test key// Enter the Key ID generated from the Dashboard
          API.paymentKey, //rzp_live_keRAkk0ilTO72f
      'order_id': orderID,
      'amount': fees * 100,
      'name': 'India Health Link Ltd.',
      'currency': "INR",
      //'theme.color': "528FF0",
      'theme.color': "#1A90D9",
      'buttontext': "Pay with Razorpay",
      'description': 'Online Class',
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
          }),
    );
  }
}
