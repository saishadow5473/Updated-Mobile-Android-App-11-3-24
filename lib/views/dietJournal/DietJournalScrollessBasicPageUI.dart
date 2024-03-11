import 'package:flutter/material.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/app_colors.dart';

class DietJournalScrollessBasicPageUI extends StatelessWidget {

  final Widget appBar;
  final Widget body;
  final Widget fab;
  final Color topColor;
  final FloatingActionButtonLocation floatingActionButtonLocation;

  DietJournalScrollessBasicPageUI({Key key, this.appBar, this.topColor, this.body, this.fab, this.floatingActionButtonLocation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          color: AppColors.bgColorTab,
          child: Column(
            children: <Widget>[
              CustomPaint(
                painter: BackgroundPainter(
                  primary: topColor!=null?topColor.withOpacity(0.8):AppColors.primaryAccentColor.withOpacity(0.8),
                  secondary: topColor??AppColors.primaryColor.withOpacity(0.0),
                ),
                child: Container(),
              ),
              Container(child: appBar),
              Expanded(
                child:ClipRRect(
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
              )
            ],
          ),
        ),
        floatingActionButton: fab,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }
}
