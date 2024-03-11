import 'package:flutter/material.dart';
import '../../../../constants/app_texts.dart';
import '../../../app/utils/appColors.dart';
import '../../../app/utils/textStyle.dart';
import '../../../../utils/SpUtil.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../app/utils/localStorageKeys.dart';
import '../../Widgets/appBar.dart';
import '../../Widgets/vitals/vitalCards.dart';

ValueNotifier<bool> listenVitals = ValueNotifier<bool>(true);

enum LegendShape { circle, rectangle }

class MyvitalsDetails extends StatelessWidget {
  const MyvitalsDetails({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //var vitals = localSotrage.read(LSKeys.lastCheckin);

    // var vitals = jsonDecode(SpUtil.getString(LSKeys.lastCheckin));
    int ihlScore = SpUtil.getInt(LSKeys.ihlScore);
    // bool aff = SpUtil.getBool(LSKeys.affiliation) ?? false;
    LegendShape legendShape = LegendShape.circle;
    List<String> pieTitles = [
      "Excellent       [900 & Above]",
      "Very Good    [800 & Above]",
      "Good             [400 & Above]",
      "Average        [Below  400]"
    ];
    if (!Tabss.featureSettings.myVitals) {
      return const Center(child: Text("No Vitals Available"));
    } else {
      return Scaffold(
        body: SingleChildScrollView(
          child: ValueListenableBuilder(
              valueListenable: listenVitals,
              builder: (_, v, __) {
                return v
                    ? Container(
                        color: const Color(0XFFefefef),
                        padding: EdgeInsets.only(top: 2.h, bottom: 1.5.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 3.w),
                              child: Text(
                                "Vitals",
                                style: AppTextStyles.primaryColorText,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Padding(
                              padding: EdgeInsets.only(left: 3.w, right: 3.w),
                              child: Text(
                                "Your health metrics provide insight into your body's current state, capturing crucial factors such as pulse, blood pressure, body temperature, and breathing rate. Regularly monitoring these indicators offers valuable insights into your overall well-being and can alert you to potential health concerns.",
                                textAlign: TextAlign.justify,
                                style: AppTextStyles.regularFont2,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            // ihlScore != 0 && ihlScore != null
                            //     ? Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           Text(
                            //             AppTexts.scoreTitle,
                            //             style: AppTextStyles.boldContnet,
                            //           ),
                            //           SizedBox(
                            //             width: 3.w,
                            //           ),
                            //           Text("$ihlScore",
                            //               style: TextStyle(
                            //                   fontFamily: 'Poppins',
                            //                   fontSize: 16.sp,
                            //                   color: getColorCode(ihlScore),
                            //                   fontWeight: FontWeight.w900))
                            //         ],
                            //       )
                            //     : Padding(
                            //         padding: EdgeInsets.only(top: 1.5.h, left: 3.w, right: 3.w),
                            //         child: VitalsCard().vitalsCardWithoutScore(context),
                            //       ),
                            // Visibility(
                            //   visible: ihlScore != 0 && ihlScore != null,
                            //   child: SizedBox(
                            //     height: 3.h,
                            //   ),
                            // ),
                            Visibility(
                              visible: ihlScore != 0 && ihlScore != null,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                      Text(AppTexts.scoreTitle,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16.sp,
                                            color: AppColors.textColor,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      Text("$ihlScore",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 19.sp,
                                              color: getColorCode(ihlScore),
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                  SizedBox(
                                    width: 7.w,
                                  ),
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    rangeCard(pieTitles[0], const Color(0xff113CFC)),
                                    SizedBox(
                                      height: .8.h,
                                    ),
                                    rangeCard(pieTitles[1], const Color(0xff0276c0)),
                                    SizedBox(
                                      height: .8.h,
                                    ),
                                    rangeCard(pieTitles[2], const Color(0xff3e93cb)),
                                    SizedBox(
                                      height: .8.h,
                                    ),
                                    rangeCard(pieTitles[3], const Color(0xff83c5ec)),

                                    // PieChart(
                                    //   dataMap: {
                                    //     "Excellent       [900 & Above]": 5,
                                    //     "Very Good    [800 & Above]": 1,
                                    //     "Good             [400 & Above]": 2,
                                    //     "Average        [Below  400]": 6,
                                    //   },
                                    //   ringStrokeWidth: 32,
                                    //   animationDuration: Duration(milliseconds: 800),

                                    //   chartRadius: 10.h,
                                    //   colorList: [
                                    //     Color(0xff113CFC),
                                    //     Color(0xff0276c0),
                                    //     Color(0xff3e93cb),
                                    //     Color(0xff83c5ec),
                                    //   ],
                                    //   initialAngleInDegree: 220,
                                    //   chartType: ChartType.ring,

                                    //   legendOptions: LegendOptions(
                                    //       showLegendsInRow: false,
                                    //       legendPosition: LegendPosition.right,
                                    //       showLegends: true,
                                    //       legendShape: _legendShape == LegendShape.circle
                                    //           ? BoxShape.rectangle
                                    //           : BoxShape.rectangle,
                                    //       legendTextStyle: AppTextStyles.regularFont3),
                                    //   chartValuesOptions: ChartValuesOptions(
                                    //     showChartValueBackground: true,
                                    //     showChartValues: false,
                                    //     showChartValuesInPercentage: false,
                                    //     showChartValuesOutside: false,
                                    //     decimalPlaces: 1,
                                    //   ),
                                    //   // gradientList: ---To add gradient colors---
                                    //   // emptyColorGradient: ---Empty Color gradient---
                                    // ),
                                    // Positioned(
                                    //   top: 2.3.h,
                                    //   left: 12.1.w,
                                    //   child: PieChart(
                                    //     dataMap: {
                                    //       "Excellent       [900 & Above]": 5,
                                    //       "Very Good    [800 & Above]": 1,
                                    //       "Good             [400 & Above]": 2,
                                    //       "Average       [Below 400]": 6,
                                    //     },
                                    //     ringStrokeWidth: 5,
                                    //     animationDuration: Duration(milliseconds: 800),
                                    //
                                    //     chartRadius: 58,
                                    //     colorList: [
                                    //       Colors.black26,
                                    //       Colors.black26,
                                    //       Colors.black26,
                                    //       Colors.black26,
                                    //     ],
                                    //     initialAngleInDegree: 220,
                                    //     chartType: ChartType.ring,
                                    //
                                    //     legendOptions: LegendOptions(
                                    //         showLegendsInRow: false,
                                    //         legendPosition: LegendPosition.right,
                                    //         showLegends: false,
                                    //         legendShape: _legendShape == LegendShape.circle
                                    //             ? BoxShape.rectangle
                                    //             : BoxShape.rectangle,
                                    //         legendTextStyle: AppTextStyles.regularFont3),
                                    //     chartValuesOptions: ChartValuesOptions(
                                    //       showChartValueBackground: true,
                                    //       showChartValues: false,
                                    //       showChartValuesInPercentage: false,
                                    //       showChartValuesOutside: false,
                                    //       decimalPlaces: 1,
                                    //     ),
                                    //     // gradientList: ---To add gradient colors---
                                    //     // emptyColorGradient: ---Empty Color gradient---
                                    //   ),
                                    // ),
                                  ]),
                                ],
                              ),
                            ),
                            SizedBox(height: ihlScore != 0 && ihlScore != null ? 5.h : 3.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "BMI",
                                    icon: const AssetImage('newAssets/Icons/vitalsDetails/BMI.png'),
                                    show: true,
                                  ),
                                ),
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "Weight",
                                    icon: const AssetImage(
                                        'newAssets/Icons/vitalsDetails/Weight.png'),
                                    show: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: .7.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "BCM",
                                    icon: const AssetImage('newAssets/Icons/vitalsDetails/BCM.png'),
                                    show: true,
                                  ),
                                ),
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "BFM",
                                    icon: const AssetImage('newAssets/Icons/vitalsDetails/BFM.png'),
                                    show: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: .7.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "BMC",
                                    icon: const AssetImage('newAssets/Icons/vitalsDetails/BMC.png'),
                                    show: true,
                                  ),
                                ),
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "BMR",
                                    icon: const AssetImage('newAssets/Icons/vitalsDetails/BMR.png'),
                                    show: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: .7.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "BP",
                                    icon: const AssetImage('newAssets/Icons/vitalsDetails/BP.png'),
                                    show: true,
                                  ),
                                ),
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "ECG",
                                    icon: const AssetImage('newAssets/Icons/vitalsDetails/ECG.png'),
                                    show: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: .7.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "ECW",
                                    icon: const AssetImage('newAssets/Icons/vitalsDetails/ECW.png'),
                                    show: true,
                                  ),
                                ),
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "ICW",
                                    icon: const AssetImage('newAssets/Icons/vitalsDetails/ICW.png'),
                                    show: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: .7.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "Mineral",
                                    icon: const AssetImage(
                                        'newAssets/Icons/vitalsDetails/Mineral.png'),
                                    show: true,
                                  ),
                                ),
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "PBF",
                                    icon: const AssetImage('newAssets/Icons/vitalsDetails/PBF.png'),
                                    show: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: .7.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "Protein",
                                    icon: const AssetImage(
                                        'newAssets/Icons/vitalsDetails/Protein.png'),
                                    show: true,
                                  ),
                                ),
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "Pulse",
                                    icon:
                                        const AssetImage('newAssets/Icons/vitalsDetails/Pulse.png'),
                                    show: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: .7.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "SMM",
                                    icon: const AssetImage('newAssets/Icons/vitalsDetails/SMM.png'),
                                    show: true,
                                  ),
                                ),
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "SPO2",
                                    icon:
                                        const AssetImage('newAssets/Icons/vitalsDetails/SPO2.png'),
                                    show: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: .7.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "TEMP",
                                    icon:
                                        const AssetImage('newAssets/Icons/vitalsDetails/TEMP.png'),
                                    show: true,
                                  ),
                                ),
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "VF",
                                    icon: const AssetImage('newAssets/Icons/vitalsDetails/VF.png'),
                                    show: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: .7.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "Waist Hip",
                                    icon: const AssetImage(
                                        'newAssets/Icons/vitalsDetails/Waist Hip.png'),
                                    show: true,
                                  ),
                                ),
                                SizedBox(
                                  height: 16.h,
                                  width: 47.w,
                                  child: VitalCardsIndiduval(
                                    vitalType: "WtHR",
                                    icon:
                                        const AssetImage('newAssets/Icons/vitalsDetails/WtHR.png'),
                                    show: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            )
                          ],
                        ),
                      )
                    : Container();
              }),
        ),
      );
    }
  }

  Container rangeCard(pieTitles, Color c) {
    return Container(
      child: Row(
        children: [
          Container(
            height: 2.5.h,
            width: 6.w,
            decoration: BoxDecoration(color: c, shape: BoxShape.rectangle),
          ),
          SizedBox(
            width: 5.w,
          ),
          Text(pieTitles)
        ],
      ),
    );
  }

  Color getColorCode(num score) {
    if (score > 0 && score < 400) {
      return const Color(0xff83c5ec);
    }
    if (score > 400 && score < 800) {
      return const Color(0xff3e93cb);
    }
    if (score > 800 && score < 900) {
      return const Color(0xff0276c0);
    }
    if (score > 900 && score < 18000) {
      return const Color(0xff113CFC);
    }
    return Colors.black;
  }
}
