import 'package:flutter/material.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/teleconsulation/payment/paymentUI.dart';

import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class FailedPage extends StatelessWidget {
  final PaymentFailureResponse response;

  FailedPage({
    @required this.response,
  });

  @override
  Widget build(BuildContext context) {
    int popCount = 0;
    return PaymentUI(
      color: AppColors.failure,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          AppTexts.paymentFailure,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => {
            Navigator.popUntil(context, (route) {
              return popCount++ == 2;
            })
          },
          color: Colors.white,
          tooltip: 'Back',
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Lottie.network('https://assets2.lottiefiles.com/packages/lf20_Dum1s3.json',
                height: 300, width: 300),
            Container(
              child: Text(
                "Payment Unsuccessful. The TRANSACTION HAS TIMED OUT!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.redAccent,
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: AppColors.myApp,
                ),
                onPressed: () => {
                  Navigator.popUntil(context, (route) {
                    return popCount++ == 2;
                  }),
                },
                child: Text(
                  "Try Again!",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
