import 'package:flutter/material.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/app_colors.dart';

/// Basic Page UI without scroll implemented, pass appbar and body, uses app primary colors 😇

class ScrollessBasicPageUI extends StatelessWidget {
  final Widget appBar;
  final Widget body;
  final Color appBarColor;

  ScrollessBasicPageUI({Key key, this.appBar, this.body, this.appBarColor}) : super(key: key);

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
                  primary: appBarColor ?? AppColors.primaryColor.withOpacity(0.7),
                  secondary: AppColors.primaryColor.withOpacity(0.0),
                ),
                child: Container(),
              ),
              Container(child: appBar),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: body,
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
