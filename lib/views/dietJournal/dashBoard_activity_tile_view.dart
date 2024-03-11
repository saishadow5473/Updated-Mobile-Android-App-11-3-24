import 'package:flutter/material.dart';
import '../../utils/SpUtil.dart';
import '../../utils/app_colors.dart';
import '../../utils/screenutil.dart';

class DashBoardRunningView extends StatelessWidget {
  final Function onTap;
  const DashBoardRunningView({Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScUtil.screenHeight > 800 ? ScUtil().setHeight(140) : ScUtil().setHeight(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 0),
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: FitnessAppTheme.white,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                            topRight: Radius.circular(8.0)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: FitnessAppTheme.grey.withOpacity(0.4),
                              offset: const Offset(1.1, 1.1),
                              blurRadius: 10.0),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.topLeft,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                            child: SizedBox(
                              height: 74,
                              child: AspectRatio(
                                aspectRatio: 1.714,
                                child: Image.asset("assets/images/diet/back.png"),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 90,
                                      // right: 1,
                                      top: 16,
                                    ),
                                    child: Text(
                                      "You're on the right track!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: ScUtil().setSp(14),
                                        letterSpacing: 0.0,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 120,
                                  bottom: 12,
                                  top: 4,
                                  right: 10,
                                ),
                                child: Text(
                                  "Stay committed to your plan.\n Click here to record your activity now",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: ScUtil().setSp(10),
                                    letterSpacing: 0.0,
                                    color: FitnessAppTheme.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -16,
                    left: 0,
                    child: SizedBox(
                      width: 110,
                      height: 110,
                      child: Image.asset("assets/images/diet/runner.png"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SetGoal extends StatelessWidget {
  final Function onTap;
  final Function onClose;
  const SetGoal({Key key, this.onTap, this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 28, right: 28, top: 0, bottom: 0),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: FitnessAppTheme.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topRight: Radius.circular(8.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: FitnessAppTheme.grey.withOpacity(0.4),
                            offset: const Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                          child: SizedBox(
                            height: 74,
                            child: AspectRatio(
                              aspectRatio: 1.714,
                              child:
                                  Image.asset("assets/images/diet/back.png", color: Colors.green),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 120, //120
                                    right: 16,
                                    top: 16,
                                  ),
                                  child: Text(
                                    "Set your goal today to  \nmanage optimal weight.",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: ScUtil().setSp(14), //16
                                      letterSpacing: 0.0,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 120,
                                bottom: 12,
                                top: 4,
                                right: 16,
                              ),
                              child: Text(
                                "Tap here to set your goal.",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  letterSpacing: 0.0,
                                  color: FitnessAppTheme.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -12,
                  left: -28,
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.network(
                        'https://i.postimg.cc/gj4Dfy7g/Objective-PNG-Free-Download.png'),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: -6,
                  child: InkWell(
                    onTap: onClose,
                    child: const CircleAvatar(
                      backgroundColor: Color(0xfff4f6fa),
                      radius: 14,
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
