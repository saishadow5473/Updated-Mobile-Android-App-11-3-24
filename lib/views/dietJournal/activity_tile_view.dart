import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/screenutil.dart';

class RunningView extends StatelessWidget {
  final Function onTap;
  const RunningView({Key key, this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    ScUtil.init(context,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        allowFontScaling: true);
    print(MediaQuery.of(context).size.width);
    print(MediaQuery.of(context).size.height);
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      bottomLeft: Radius.circular(4.0),
                      bottomRight: Radius.circular(4.0),
                      topRight: Radius.circular(4.0)),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: const <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                left: 120,
                                right: 16,
                                top: 16,
                              ),
                              child: Text(
                                "You're on the right track!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 0.0,
                                  color: AppColors.primaryColor,
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
                            "Stay committed to your plan.\nClick here to record your activity now.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
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
              Positioned(
                top: -16,
                left: 0,
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: Image.asset("newAssets/Icons/vitalsDetails/runners.png"),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class SetGoal extends StatelessWidget {
  final Function onTap;
  final Function onClose;
  final bool curvedBorder;
  final List activeGoal;
  const SetGoal({Key key, this.onTap, this.onClose, this.curvedBorder, this.activeGoal})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        allowFontScaling: true);
    return const Text('');
    //   Column(
    //   children: <Widget>[
    //     GestureDetector(
    //       onTap: onTap,
    //       child: Padding(
    //         padding:
    //             const EdgeInsets.only(left: 28, right: 28, top: 0, bottom: 0),
    //         child: Stack(
    //           clipBehavior: Clip.none,
    //           children: <Widget>[
    //             Padding(
    //               padding: EdgeInsets.only(top: 16, bottom: 16),
    //               child: Container(
    //                 decoration: BoxDecoration(
    //                   color: FitnessAppTheme.white,
    //                   borderRadius: BorderRadius.only(
    //                       topLeft: Radius.circular(8.0),
    //                       bottomLeft: Radius.circular(8.0),
    //                       bottomRight: Radius.circular(8.0),
    //                       topRight: curvedBorder == null
    //                           ? Radius.circular(8.0)
    //                           : Radius.circular(50)),
    //                   boxShadow: <BoxShadow>[
    //                     BoxShadow(
    //                         color: FitnessAppTheme.grey.withOpacity(0.4),
    //                         offset: Offset(1.1, 1.1),
    //                         blurRadius: 10.0),
    //                   ],
    //                 ),
    //                 child: Stack(
    //                   alignment: Alignment.topLeft,
    //                   children: <Widget>[
    //                     ClipRRect(
    //                       borderRadius: BorderRadius.all(Radius.circular(8.0)),
    //                       child: SizedBox(
    //                         height: MediaQuery.of(context).size.height >= 570
    //                             ? ScUtil().setHeight(74)
    //                             : ScUtil().setHeight(54),
    //                         child: AspectRatio(
    //                           aspectRatio: 1.714,
    //                           child: Image.asset("assets/images/diet/back.png",
    //                               color: Colors.green),
    //                         ),
    //                       ),
    //                     ),
    //                     Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: <Widget>[
    //                         Row(
    //                           children: <Widget>[
    //                             Padding(
    //                               padding: EdgeInsets.only(
    //                                 left:
    //                                     MediaQuery.of(context).size.width >= 350
    //                                         ? ScUtil().setWidth(110)
    //                                         : ScUtil().setWidth(90), //120
    //                                 // right: ScUtil().setWidth(16),
    //                                 top: ScUtil().setHeight(16),
    //                               ),
    //                               child:
    //                               Text(
    //                                 "Set your goal today to  \nmanage optimal weight.",
    //                                 textAlign: TextAlign.left,
    //                                 style: TextStyle(
    //                                   fontFamily: FitnessAppTheme.fontName,
    //                                   fontWeight: FontWeight.w600,
    //                                   fontSize: ScUtil().setSp(14), //16
    //                                   // letterSpacing: 0.0,
    //                                   color: Colors.green,
    //                                 ),
    //                                 overflow: TextOverflow.ellipsis,
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                         Padding(
    //                           padding: EdgeInsets.only(
    //                             left: ScUtil().setWidth(110), //120
    //                             bottom: ScUtil().setHeight(12),
    //                             top: ScUtil().setHeight(4),
    //                             // right: ScUtil().setWidth(16),
    //                           ),
    //                           child: Text(
    //                          activeGoal.length >0 ? "Tap here to view your goal":   "Tap here to set your goal.",
    //                             textAlign: TextAlign.left,
    //                             style: TextStyle(
    //                               fontFamily: FitnessAppTheme.fontName,
    //                               fontWeight: FontWeight.w500,
    //                               fontSize: ScUtil().setSp(14),
    //                               letterSpacing: 0.0,
    //                               color: FitnessAppTheme.grey,
    //                             ),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             Positioned(
    //               top: -12,
    //               left: -28,
    //               child: SizedBox(
    //                 width: MediaQuery.of(context).size.width >= 350
    //                     ? ScUtil().setWidth(150)
    //                     : ScUtil().setWidth(120),
    //                 height: ScUtil().setHeight(150),
    //                 child: Image.network(
    //                     'https://i.postimg.cc/gj4Dfy7g/Objective-PNG-Free-Download.png'),
    //               ),
    //             ),
    //             Visibility(
    //               visible: false,
    //               child: Positioned(
    //                 top: 0,
    //                 right: -6,
    //                 child: InkWell(
    //                   onTap: onClose,
    //                   child: CircleAvatar(
    //                     child: Icon(
    //                       Icons.cancel_rounded,
    //                       size: 22,
    //                       color: Colors.black,
    //                     ),
    //                     backgroundColor: Color(0xfff4f6fa),
    //                     radius: 14,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}
