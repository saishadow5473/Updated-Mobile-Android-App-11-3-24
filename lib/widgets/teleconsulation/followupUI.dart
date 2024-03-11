import 'package:flutter/material.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/app_colors.dart';

/// Follow screen, no logic 😐
class FollowupUI extends StatelessWidget {
  final Widget appBar;
  final Widget body;
  final Widget card;
  FollowupUI({Key key, this.appBar, this.body, this.card}) : super(key: key);

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
                  primary: AppColors.followUp.withOpacity(0.7),
                  secondary: AppColors.followUp,
                ),
                child: Container(),
              ),
              Container(child: appBar),
              SizedBox(
                height: 30,
              ),
              Container(child: card),
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
