import 'package:flutter/material.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/app_colors.dart';

class PaymentUI extends StatelessWidget {
  final Widget appBar;
  final Widget body;
  final Color color;
  PaymentUI({Key key, this.appBar, this.body, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: AppColors.bgColorTab,
          child: Column(
            children: <Widget>[
              CustomPaint(
                painter: BackgroundPainter(
                  primary: color.withOpacity(0.7),
                  secondary: color.withOpacity(0.0),
                ),
                child: Container(),
              ),
              Container(child: appBar),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(child: body),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
