import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/cardiovascular_views/cardio_dashboard.dart';
import 'package:ihl/views/cardiovascular_views/cardio_navbar.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';

class CardioResultView extends StatefulWidget {
  final double weight;
  final String analysis;
  const CardioResultView({this.weight, this.analysis});

  @override
  _CardioResultViewState createState() => _CardioResultViewState();
}

class _CardioResultViewState extends State<CardioResultView> {
  @override
  Widget build(BuildContext context) {
    return DietJournalUI(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text(
          // "Cardio Dashboard",
          "Cardiovascular",
          style: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Center(
            //     child: Text("Cardiovascular",
            //         style: TextStyle(
            //             fontSize: 20, color: Color.fromRGBO(93, 95, 96, 1)))),
            SizedBox(height: 15),
            Container(
              child: RichText(
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: ' Your Result',
                      style: TextStyle(
                        color: FitnessAppTheme.grey,
                        fontSize: ScUtil().setSp(30),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.28,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 10),
            Neumorphic(
              style: NeumorphicStyle(
                shape: NeumorphicShape.concave,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(12),
                ),
                depth: 8,
                lightSource: LightSource.topLeft,
                color: Color(0xFFf6f9fe),
              ),
              padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Center(
                      child: Text(widget.analysis,
                          style: TextStyle(
                              fontSize: ScUtil().setSp(22),
                              color: Colors.yellow.shade900,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins'))),
                  Center(
                      child: Text("${widget.weight}",
                          style: TextStyle(
                              fontSize: ScUtil().setSp(50),
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins'))),
                  // Center(child: Text("Score", style: TextStyle(fontSize:  ScUtil().setSp(22), color:AppColors.appTextColor,fontWeight: FontWeight.w600,fontFamily: 'Poppins'))),
                  SizedBox(height: ScUtil().setHeight(17)),
                  SfLinearGauge(
                      ranges: <LinearGaugeRange>[
                        LinearGaugeRange(
                            startValue: 0, endValue: 30, color: Colors.orange),
                        LinearGaugeRange(
                            startValue: 30, endValue: 75, color: Colors.green),
                        LinearGaugeRange(
                            startValue: 75, endValue: 110, color: Colors.red)
                      ],
                      minimum: 0,
                      maximum: 110,
                      markerPointers: [
                        LinearShapePointer(value: widget.weight)
                      ]),
                  SizedBox(height: ScUtil().setHeight(20)),
                  // ElevatedButton(
                  //   onPressed: () {},
                  //   child: Text("Save Result"),
                  //   style: TextButton.styleFrom(
                  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  //     padding: EdgeInsets.all(14),
                  //     backgroundColor: Color.fromRGBO(119, 118, 254, 1),
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      text: 'Advice : ',
                      style: TextStyle(
                          fontSize: ScUtil().setSp(20),
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins'),
                      children: <TextSpan>[
                        TextSpan(
                            text:
                                'The best way to lose weight if you are overweight is through a combination of diet and exercise',
                            style: TextStyle(
                                fontSize: ScUtil().setSp(20),
                                color: AppColors.appTextColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.only(top: 20),
                //   child: Center(
                //     child: NeumorphicButton(
                //       onPressed: () {},
                //       style: NeumorphicStyle(
                //         color: Colors.white,
                //         shape: NeumorphicShape.flat,
                //         boxShape: NeumorphicBoxShape.roundRect(
                //             BorderRadius.circular(15)),
                //       ),
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 40, vertical: 15),
                //       child: const Text('more'),
                //     ),
                //   ),
                // ),
                SizedBox(height: 30),
                Container(
                  child: ButtonTheme(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            // builder: (context) => CardioDashboard(),
                            builder: (context) => CardioNavBar(),
                          ),
                        );
                        // Navigator.pushAndRemoveUntil(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => CardioDashboard(),
                        //     ),
                        //         (Route<dynamic> route) => false);
                      },
                      child: Text("Dashboard"),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                        backgroundColor: AppColors.primaryAccentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
