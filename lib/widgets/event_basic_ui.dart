import 'package:flutter/material.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';

/// Basic Page UI with scroll implemented, pass appbar and body, uses app primary colors 😇
class EventPageUI extends StatelessWidget {
  final Widget appBar;
  final Widget body;
  final Widget floatingActionButton;
  Color backgroundColor;
  EventPageUI({Key key, this.appBar, this.body, this.backgroundColor,this.floatingActionButton}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: floatingActionButton,
        body: Container(width: double.infinity, color: backgroundColor,
          child: Container(
            color: AppColors.bgColorTab,
            child: Column(
              children: <Widget>[
                CustomPaint(
                  painter: BackgroundPainter(
                    primary: AppColors.primaryColor.withOpacity(0.7),
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
      ),
    );
  }
}
