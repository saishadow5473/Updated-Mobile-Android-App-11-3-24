import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class InfoScreen extends StatelessWidget {
  final int score;

  InfoScreen({Key key, this.score}) : super(key: key);
  colorForStatus(riskLevel) {
    if (riskLevel == 'Low') {
      return Color(0xfffdc135);
    } else if (riskLevel == 'Healthy') {
      return Color(0xff7ac744);
    } else if (riskLevel == 'Intermediate') {
      return Color(0xfffd712c);
    } else if (riskLevel == 'High') {
      return Color(0xffed4438);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BasicPageUI(
          appBar: Container(
            height: 8.h,
            alignment: Alignment.center,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back_ios_new),
                  color: Colors.white,
                ),
                SizedBox(
                  width: 33.sp,
                ),
                Text(
                  'Heart Health',
                  style: TextStyle(fontSize: 21.sp, color: Colors.white),
                ),
              ],
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Status : ',
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w300),
                  ),
                  Text(
                      score >= 20
                          ? 'High'
                          : score < 20 && score >= 7.5
                              ? 'Intermediate'
                              : score < 7.5 && score >= 5
                                  ? 'Healthy'
                                  : 'Low',
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: colorForStatus(score >= 20
                            ? 'High'
                            : score < 20 && score >= 7.5
                                ? 'Intermediate'
                                : score < 7.5 && score >= 5
                                    ? 'Healthy'
                                    : 'Low'),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      )),
                ],
              )),
              Center(
                child: Text(
                  score.toString(),
                  style: TextStyle(
                      fontSize: 25.sp,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins'),
                ),
              ),
              SfLinearGauge(
                  interval: 10.0,
                  ranges: <LinearGaugeRange>[
                    LinearGaugeRange(
                      startValue: 0,
                      endValue: 4.9,
                      color: colorForStatus('Low'),
                    ),
                    LinearGaugeRange(
                      startValue: 5,
                      endValue: 7.4,
                      color: colorForStatus('Healthy'),
                    ),
                    LinearGaugeRange(
                      startValue: 7.5,
                      endValue: 20,
                      color: colorForStatus('Intermediate'),
                    ),
                    LinearGaugeRange(
                      startValue: 20,
                      endValue: 100,
                      color: colorForStatus('High'),
                    )
                  ],
                  minimum: 0,
                  maximum: 100,
                  markerPointers: [LinearShapePointer(value: score.toDouble())]),
              SizedBox(height: 15.sp),
              Container(
                margin: EdgeInsets.symmetric(vertical: 13.sp, horizontal: 10.sp),
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        offset: Offset(0, 2),
                        blurRadius: 3.0,
                        spreadRadius: 2.0)
                  ],
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                child: Column(
                  children: [
                    Text(
                        'What does my risk score mean? The ASCVD risk score is given as a percentage. This is your chance of having heart disease or stroke in the next 10 years. There are different treatment recommendations depending on your risk score.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                          letterSpacing: 0.1,
                        )),
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 13.sp, horizontal: 10.sp),
                  padding: EdgeInsets.all(15.sp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: Offset(0, 2),
                          blurRadius: 3.0,
                          spreadRadius: 1.5)
                    ],
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: '0 to 4.9 percent risk is considered low.', // default text style
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              ' Eating a healthy diet and exercising will help keep your risk low. Medication is not recommended unless your LDL, or “bad” cholesterol, is greater than or equal to 190. · ',
                          style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              letterSpacing: 0.1,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    softWrap: true,
                    style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        letterSpacing: 0.1,
                        color: colorForStatus('Low')),
                    textAlign: TextAlign.justify,
                  )),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 13.sp, horizontal: 10.sp),
                  padding: EdgeInsets.all(15.sp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: Offset(0, 2),
                          blurRadius: 3.0,
                          spreadRadius: 1.5)
                    ],
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: '5 to 7.4 percent risk is considered Healthy.', // default text style
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              'These conditions may increase your risk of heart disease or stroke. Talk with your primary care provider to see if you have any of the risk enhancers in the list below.  ',
                          style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              letterSpacing: 0.1,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    softWrap: true,
                    style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        letterSpacing: 0.1,
                        color: colorForStatus('Healthy')),
                    textAlign: TextAlign.justify,
                  )),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 13.sp, horizontal: 10.sp),
                  padding: EdgeInsets.all(15.sp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: Offset(0, 2),
                          blurRadius: 3.0,
                          spreadRadius: 1.5)
                    ],
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text:
                          'A 7.5 to 20 percent risk is considered intermediate. ', // default text style
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Talk with your primary care provider',
                          style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              letterSpacing: 0.1,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    softWrap: true,
                    style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        letterSpacing: 0.1,
                        color: colorForStatus('Intermediate')),
                    textAlign: TextAlign.justify,
                  )),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 13.sp, horizontal: 10.sp),
                  padding: EdgeInsets.all(15.sp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: Offset(0, 2),
                          blurRadius: 3.0,
                          spreadRadius: 1.5)
                    ],
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text:
                          'A greater than 20 percent risk is considered high. ', // default text style
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Talk with your primary care provider ',
                          style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              letterSpacing: 0.1,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    softWrap: true,
                    style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        letterSpacing: 0.1,
                        color: colorForStatus('High')),
                    textAlign: TextAlign.justify,
                  )),
              Text(
                'ASCVD Risk Enhancers',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                  fontSize: 17.sp,
                  letterSpacing: 0.1,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 13.sp, horizontal: 10.sp),
                padding: EdgeInsets.all(15.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        offset: Offset(0, 2),
                        blurRadius: 3.0,
                        spreadRadius: 1.5)
                  ],
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                child: Text(
                    'Talk with your primary care provider if you have any of the following conditions or risk enhancers:',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      letterSpacing: 0.1,
                    )),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 13.sp, horizontal: 10.sp),
                padding: EdgeInsets.all(15.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        offset: Offset(0, 2),
                        blurRadius: 3.0,
                        spreadRadius: 1.5)
                  ],
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Family history of early-onset ASCVD ·',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                            letterSpacing: 0.1,
                            color: Colors.black)),
                    Text(
                        '• Continually elevated LDL greater than or equal to 160 mg /dL (≥ 4.1 mmol/L)',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                            letterSpacing: 0.1,
                            color: Colors.black)),
                    Text('• Chronic kidney disease',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                            letterSpacing: 0.1,
                            color: Colors.black)),
                    Text('• Metabolic syndrome',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                            letterSpacing: 0.1,
                            color: Colors.black)),
                    Text('• Preeclampsia or premature menopause',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                            letterSpacing: 0.1,
                            color: Colors.black)),
                    Text(
                        '• Continually elevated triglycerides greater than or equal to 175 mg /dL (≥ 2.0 mmol/L',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                            letterSpacing: 0.1,
                            color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
