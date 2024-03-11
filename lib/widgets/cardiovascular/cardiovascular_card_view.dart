import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/diet_view.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class CardiovascularCardView extends StatefulWidget {
  // const CardiovascularCardView({Key key}) : super(key: key);

  @override
  State<CardiovascularCardView> createState() => _CardiovascularCardViewState();
}

class _CardiovascularCardViewState extends State<CardiovascularCardView> {
  @override
  var dailytarget = 1700;
  StreamingSharedPreferences preferences;
  Widget build(BuildContext context) {
    ScUtil.init(context,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        allowFontScaling: true);
    return GestureDetector(
      onTap: () {
        // if(widget.isNavigation){
        //   Navigator.pushAndRemoveUntil(
        //       context,
        //       MaterialPageRoute(builder: (context) => DietJournal()),
        //           (Route<dynamic> route) => false);
        // }
      },
      child: Padding(
        padding: EdgeInsets.only(
            left: ScUtil().setWidth(24),
            right: ScUtil().setWidth(24),
            top: ScUtil().setHeight(16),
            bottom: ScUtil().setHeight(18)),
        child: Container(
          decoration: BoxDecoration(
            color: FitnessAppTheme.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
                topRight: Radius.circular(68.0)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: FitnessAppTheme.grey.withOpacity(0.2),
                  offset: Offset(1.1, 1.1),
                  blurRadius: 10.0),
            ],
          ),
          child: Column(
            children: <Widget>[
              Padding(
                // padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                padding: EdgeInsets.only(top: ScUtil().setHeight(16), left: ScUtil().setWidth(10)),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: ScUtil().setWidth(8),
                            right: ScUtil().setWidth(8),
                            top: ScUtil().setHeight(4)),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  height: ScUtil().setWidth(48),
                                  width: ScUtil().setHeight(2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScUtil().setWidth(8),
                                      vertical: ScUtil().setHeight(8)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: ScUtil().setHeight(4),
                                            bottom: ScUtil().setHeight(2)),
                                        child: Text(
                                          'Recent Test ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScUtil().setSp(16),
                                            letterSpacing: -0.1,
                                            color: FitnessAppTheme.grey.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          SizedBox(
                                            // width: 30,
                                            // height: 30,
                                            width: ScUtil().setWidth(3), //30
                                            height: ScUtil().setHeight(3),
                                            // child: Icon(FontAwesomeIcons.handHoldingHeart,color: AppColors.primaryAccentColor,)
                                          ),
                                          // Padding(
                                          //   padding: EdgeInsets.only(
                                          //       left: ScUtil().setWidth(4),
                                          //       bottom: ScUtil().setHeight(3)),
                                          //   child: preferences != null
                                          //       ? PreferenceBuilder<int>(
                                          //           preference: preferences
                                          //               .getInt('eatenCalorie',
                                          //                   defaultValue: 0),
                                          //           builder:
                                          //               (BuildContext context,
                                          //                   int eatenCounter) {
                                          //             return Text(
                                          //               '$eatenCounter',
                                          //               textAlign:
                                          //                   TextAlign.center,
                                          //               style: TextStyle(
                                          //                 fontFamily:
                                          //                     FitnessAppTheme
                                          //                         .fontName,
                                          //                 fontWeight:
                                          //                     FontWeight.w600,
                                          //                 fontSize: ScUtil()
                                          //                     .setSp(16),
                                          //                 color: FitnessAppTheme
                                          //                     .darkerText,
                                          //               ),
                                          //             );
                                          //           })
                                          //       : Text(
                                          //           '0',
                                          //           textAlign: TextAlign.center,
                                          //           style: TextStyle(
                                          //             fontFamily:
                                          //                 FitnessAppTheme
                                          //                     .fontName,
                                          //             fontWeight:
                                          //                 FontWeight.w600,
                                          //             fontSize:
                                          //                 ScUtil().setSp(16),
                                          //             color: FitnessAppTheme
                                          //                 .darkerText,
                                          //           ),
                                          //         ),
                                          // ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: ScUtil().setWidth(4),
                                                bottom: ScUtil().setHeight(3)),
                                            child: Text(
                                              '02-Apr-2022',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: FitnessAppTheme.fontName,
                                                fontWeight: FontWeight.w600,
                                                fontSize: ScUtil().setSp(13),
                                                letterSpacing: -0.2,
                                                color: FitnessAppTheme.grey.withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: ScUtil().setHeight(8),
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  height: ScUtil().setHeight(48),
                                  width: ScUtil().setWidth(2),
                                  decoration: BoxDecoration(
                                    color: HexColor('#F56E98').withOpacity(0.5),
                                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScUtil().setWidth(8),
                                      vertical: ScUtil().setHeight(8)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: ScUtil().setHeight(4),
                                            bottom: ScUtil().setHeight(2)),
                                        child: Text(
                                          'Status',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScUtil().setSp(16),
                                            letterSpacing: -0.1,
                                            color: FitnessAppTheme.grey.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          SizedBox(
                                            width: ScUtil().setWidth(3),
                                            height: ScUtil().setHeight(3), //30
                                            // child: Image.asset(
                                            //     "assets/images/diet/burned.png"),
                                          ),
                                          // Padding(
                                          //   padding: EdgeInsets.only(
                                          //       left: ScUtil().setHeight(4),
                                          //       bottom: ScUtil().setHeight(2)),
                                          //   child: preferences != null
                                          //       ? PreferenceBuilder<int>(
                                          //           preference: preferences
                                          //               .getInt('burnedCalorie',
                                          //                   defaultValue: 0),
                                          //           builder:
                                          //               (BuildContext context,
                                          //                   int burnedCounter) {
                                          //             return Text(
                                          //               '$burnedCounter',
                                          //               textAlign:
                                          //                   TextAlign.center,
                                          //               style: TextStyle(
                                          //                 fontFamily:
                                          //                     FitnessAppTheme
                                          //                         .fontName,
                                          //                 fontWeight:
                                          //                     FontWeight.w600,
                                          //                 fontSize: ScUtil()
                                          //                     .setSp(16),
                                          //                 color: FitnessAppTheme
                                          //                     .darkerText,
                                          //               ),
                                          //             );
                                          //           })
                                          //       : Text(
                                          //           '0',
                                          //           textAlign: TextAlign.center,
                                          //           style: TextStyle(
                                          //             fontFamily:
                                          //                 FitnessAppTheme
                                          //                     .fontName,
                                          //             fontWeight:
                                          //                 FontWeight.w600,
                                          //             fontSize:
                                          //                 ScUtil().setSp(16),
                                          //             color: FitnessAppTheme
                                          //                 .darkerText,
                                          //           ),
                                          //         ),
                                          // ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: ScUtil().setHeight(3),
                                                bottom: ScUtil().setHeight(3)),
                                            child: Text(
                                              'Good',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: FitnessAppTheme.fontName,
                                                fontWeight: FontWeight.w600,
                                                fontSize: ScUtil().setSp(13),
                                                letterSpacing: -0.2,
                                                color: FitnessAppTheme.grey.withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    ///Circular Calorie Indicator
                    Padding(
                      padding: EdgeInsets.only(right: ScUtil().setWidth(1)),
                      // padding:  EdgeInsets.zero,
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Padding(
                              // padding: EdgeInsets.symmetric(horizontal: ScUtil().setWidth(8),vertical: ScUtil().setHeight(8)),
                              padding: EdgeInsets.all(4),
                              child: preferences != null
                                  ? PreferenceBuilder<int>(
                                      preference:
                                          preferences.getInt('burnedCalorie', defaultValue: 0),
                                      builder: (BuildContext context, int burnedCounter) {
                                        return PreferenceBuilder<int>(
                                            preference:
                                                preferences.getInt('eatenCalorie', defaultValue: 0),
                                            builder: (BuildContext context, int eatenCounter) {
                                              return Container(
                                                width: 120,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  color: FitnessAppTheme.white,
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(120.0),
                                                  ),
                                                  border: ((dailytarget - eatenCounter) +
                                                              burnedCounter) <
                                                          0
                                                      ? Border.all(width: 10, color: Colors.green)
                                                      : Border.all(
                                                          width: 4,
                                                          color: AppColors.primaryColor
                                                              .withOpacity(0.2)),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    preferences != null
                                                        ? PreferenceBuilder<int>(
                                                            preference: preferences.getInt(
                                                                'burnedCalorie',
                                                                defaultValue: 0),
                                                            builder: (BuildContext context,
                                                                int burnedCounter) {
                                                              return PreferenceBuilder<int>(
                                                                  preference: preferences.getInt(
                                                                      'eatenCalorie',
                                                                      defaultValue: 0),
                                                                  builder: (BuildContext context,
                                                                      int eatenCounter) {
                                                                    return Text(
                                                                      '${((dailytarget - eatenCounter) + burnedCounter).abs()}',
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                        fontFamily: FitnessAppTheme
                                                                            .fontName,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        fontSize:
                                                                            ScUtil().setSp(28),
                                                                        letterSpacing: 0.0,
                                                                        color: (((dailytarget -
                                                                                        eatenCounter) +
                                                                                    burnedCounter) >
                                                                                dailytarget)
                                                                            ? Colors.orangeAccent
                                                                            : ((dailytarget -
                                                                                            eatenCounter) +
                                                                                        burnedCounter) >
                                                                                    0
                                                                                ? AppColors
                                                                                    .primaryColor
                                                                                : Colors.redAccent,
                                                                      ),
                                                                    );
                                                                  });
                                                            })
                                                        : Text(
                                                            '$dailytarget',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontFamily: FitnessAppTheme.fontName,
                                                              fontWeight: FontWeight.normal,
                                                              fontSize: ScUtil().setSp(28),
                                                              letterSpacing: 0.0,
                                                              color: AppColors.primaryColor,
                                                            ),
                                                          ),
                                                    preferences != null
                                                        ? PreferenceBuilder<int>(
                                                            preference: preferences.getInt(
                                                                'burnedCalorie',
                                                                defaultValue: 0),
                                                            builder: (BuildContext context,
                                                                int burnedCounter) {
                                                              return PreferenceBuilder<int>(
                                                                  preference: preferences.getInt(
                                                                      'eatenCalorie',
                                                                      defaultValue: 0),
                                                                  builder: (BuildContextcontext,
                                                                      int eatenCounter) {
                                                                    return Text(
                                                                      ((dailytarget - eatenCounter) +
                                                                                  burnedCounter) >
                                                                              0
                                                                          ? 'Cal left'
                                                                          : 'Cal extra',
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                        fontFamily: FitnessAppTheme
                                                                            .fontName,
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize:
                                                                            ScUtil().setSp(14),
                                                                        letterSpacing: 0.0,
                                                                        color: FitnessAppTheme.grey
                                                                            .withOpacity(0.5),
                                                                      ),
                                                                    );
                                                                  });
                                                            })
                                                        : Text(
                                                            'Cal left',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontFamily: FitnessAppTheme.fontName,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: ScUtil().setSp(14),
                                                              letterSpacing: 0.0,
                                                              color: FitnessAppTheme.grey
                                                                  .withOpacity(0.5),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              );
                                            });
                                      })
                                  : Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: FitnessAppTheme.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(120.0),
                                        ),
                                        border: Border.all(
                                            width: 4,
                                            color: AppColors.primaryColor.withOpacity(0.2)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          preferences != null
                                              ? PreferenceBuilder<int>(
                                                  preference: preferences.getInt('burnedCalorie',
                                                      defaultValue: 0),
                                                  builder:
                                                      (BuildContext context, int burnedCounter) {
                                                    return PreferenceBuilder<int>(
                                                        preference: preferences.getInt(
                                                            'eatenCalorie',
                                                            defaultValue: 0),
                                                        builder: (BuildContext context,
                                                            int eatenCounter) {
                                                          return Text(
                                                            '${((dailytarget - eatenCounter) + burnedCounter).abs()}',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontFamily: FitnessAppTheme.fontName,
                                                              fontWeight: FontWeight.normal,
                                                              fontSize: ScUtil().setSp(28),
                                                              letterSpacing: 0.0,
                                                              color: (((dailytarget -
                                                                              eatenCounter) +
                                                                          burnedCounter) >
                                                                      dailytarget)
                                                                  ? Colors.orangeAccent
                                                                  : ((dailytarget - eatenCounter) +
                                                                              burnedCounter) >
                                                                          0
                                                                      ? AppColors.primaryColor
                                                                      : Colors.redAccent,
                                                            ),
                                                          );
                                                        });
                                                  })
                                              : Text(
                                                  '$dailytarget',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: FitnessAppTheme.fontName,
                                                    fontWeight: FontWeight.normal,
                                                    fontSize: ScUtil().setSp(28),
                                                    letterSpacing: 0.0,
                                                    color: AppColors.primaryColor,
                                                  ),
                                                ),
                                          Text(
                                            'Cardiovascular Score',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: ScUtil().setSp(12),
                                              letterSpacing: 0.0,
                                              color: FitnessAppTheme.grey.withOpacity(0.5),
                                            ),
                                          )
                                          // preferences != null
                                          //     ? PreferenceBuilder<int>(
                                          //         preference: preferences
                                          //             .getInt('burnedCalorie',
                                          //                 defaultValue: 0),
                                          //         builder:
                                          //             (BuildContext context,
                                          //                 int burnedCounter) {
                                          //           return PreferenceBuilder<
                                          //                   int>(
                                          //               preference:
                                          //                   preferences.getInt(
                                          //                       'eatenCalorie',
                                          //                       defaultValue:
                                          //                           0),
                                          //               builder: (BuildContext
                                          //                       context,
                                          //                   int eatenCounter) {
                                          //                 return Text(
                                          //                   ((dailytarget - eatenCounter) +
                                          //                               burnedCounter) >
                                          //                           0
                                          //                       ? 'Score'
                                          //                       : 'Kcal extra',
                                          //                   textAlign: TextAlign
                                          //                       .center,
                                          //                   style: TextStyle(
                                          //                     fontFamily:
                                          //                         FitnessAppTheme
                                          //                             .fontName,
                                          //                     fontWeight:
                                          //                         FontWeight
                                          //                             .bold,
                                          //                     fontSize: ScUtil()
                                          //                         .setSp(14),
                                          //                     letterSpacing:
                                          //                         0.0,
                                          //                     color: FitnessAppTheme
                                          //                         .grey
                                          //                         .withOpacity(
                                          //                             0.5),
                                          //                   ),
                                          //                 );
                                          //               });
                                          //         })
                                          //     : Text(
                                          //         'Kcal left',
                                          //         textAlign: TextAlign.center,
                                          //         style: TextStyle(
                                          //           fontFamily: FitnessAppTheme
                                          //               .fontName,
                                          //           fontWeight: FontWeight.bold,
                                          //           fontSize:
                                          //               ScUtil().setSp(14),
                                          //           letterSpacing: 0.0,
                                          //           color: FitnessAppTheme.grey
                                          //               .withOpacity(0.5),
                                          //         ),
                                          //       ),
                                        ],
                                      ),
                                    ),
                            ),
                            Padding(
                              // padding: EdgeInsets.symmetric(horizontal: ScUtil().setWidth(8),vertical: ScUtil().setHeight(8)),
                              padding: EdgeInsets.all(1),
                              child: preferences != null
                                  ? PreferenceBuilder<int>(
                                      preference:
                                          preferences.getInt('burnedCalorie', defaultValue: 0),
                                      builder: (BuildContext context, int burnedCounter) {
                                        return PreferenceBuilder<int>(
                                            preference:
                                                preferences.getInt('eatenCalorie', defaultValue: 0),
                                            builder: (BuildContext context, int eatenCounter) {
                                              return CustomPaint(
                                                painter: CurvePainter(
                                                    colors: (((dailytarget - eatenCounter) +
                                                                burnedCounter) >
                                                            dailytarget)
                                                        ? [
                                                            Colors.orangeAccent,
                                                            Colors.orangeAccent,
                                                            Colors.orangeAccent
                                                          ]
                                                        : ((dailytarget - eatenCounter) +
                                                                    burnedCounter) >
                                                                0
                                                            ? [
                                                                AppColors.primaryColor,
                                                                AppColors.primaryColor,
                                                                AppColors.primaryColor
                                                              ]
                                                            : [
                                                                Colors.redAccent,
                                                                Colors.redAccent,
                                                                Colors.redAccent
                                                              ],
                                                    angle: ((dailytarget - eatenCounter) +
                                                                burnedCounter) <
                                                            0
                                                        ? (360) *
                                                            ((dailytarget -
                                                                    eatenCounter -
                                                                    burnedCounter) /
                                                                eatenCounter)
                                                        : (360) *
                                                            ((eatenCounter - burnedCounter) /
                                                                dailytarget)),
                                                child: SizedBox(
                                                  width: 128,
                                                  height: 128,
                                                ),
                                              );
                                            });
                                      })
                                  : CustomPaint(
                                      painter: CurvePainter(colors: [
                                        AppColors.primaryColor,
                                        AppColors.primaryColor,
                                        AppColors.primaryColor
                                      ], angle: (360) * (0.0)),
                                      child: SizedBox(
                                        width: 128,
                                        height: 128,
                                      ),
                                    ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              /*Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 8, bottom: 8),
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.background,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 8, bottom: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Steps',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              letterSpacing: -0.2,
                              color: FitnessAppTheme.darkText,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              height: 4,
                              width: 70,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 70,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        HexColor('#87A0E5'),
                                        HexColor('#87A0E5').withOpacity(0.5),
                                      ]),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '2587 out of 5600',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: FitnessAppTheme.grey.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Distance',
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  letterSpacing: -0.2,
                                  color: FitnessAppTheme.darkText,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 0, top: 4),
                                child: Container(
                                  height: 4,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: HexColor('#F1B440').withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0)),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: ((70)),
                                        height: 4,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [
                                            HexColor('#F1B440')
                                                .withOpacity(0.1),
                                            HexColor('#F1B440'),
                                          ]),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '2.3 Kms covered',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color:
                                        FitnessAppTheme.grey.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )*/
            ],
          ),
        ),
      ),
    );
  }
}
