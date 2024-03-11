import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/views/cardiovascular_views/cardio_dashboard.dart';
import 'package:ihl/views/cardiovascular_views/cardio_navbar.dart';
import 'package:ihl/views/cardiovascular_views/cardio_result_view.dart';
import 'package:ihl/views/cardiovascular_views/cardio_showing_data_from_kisok.dart';
import 'package:ihl/views/cardiovascular_views/cardiovascular_survey.dart';
import 'package:ihl/views/signup/signup_height.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CardioFamilyHypertension extends StatefulWidget {
  CardioFamilyHypertension({Key key}) : super(key: key);

  @override
  _CardioFamilyHypertensionState createState() =>
      _CardioFamilyHypertensionState();
}

class _CardioFamilyHypertensionState extends State<CardioFamilyHypertension> {
  bool yesTap = true;
  bool noTap = false;
  bool otherTap = false;
  Color tapped = Color(0xff56CCF2);
  Color notTapped = Colors.white;
  String selectedHypertensionCondition = 'n';
  void _initAsync() async {
    await SpUtil.getInstance();
    _initAsync1();
    var cardio_hyper;
    try {
      cardio_hyper = SpUtil.getString('cardio_isFamilyHypertension');
      if (cardio_hyper.toString() != 'null' && cardio_hyper.toString() != '') {
        setState(() {
          selectedHypertensionCondition = cardio_hyper;
          if (selectedHypertensionCondition == 'y') {
            yesTap = true;
            noTap = false;
          } else if (selectedHypertensionCondition == 'n') {
            yesTap = false;
            noTap = true;
          }
        });
      }
      if (cardio_hyper.toString() == '') {
        setState(() {
          noTap = true;
          yesTap = false;
          selectedHypertensionCondition = 'n';
        });
      }
    } catch (e) {
      print(e.toString());
      _initAsync1();
    }
  }

  var cardio_gen;
  var cardio_cholestrol;
  var cardio_smoke;
  var cardio_diab;
  var systolic;
  var diastolic;
  var _iHLUserId;
  getIhlUserId() async {
    final prefs = await SharedPreferences.getInstance();
    var userData = prefs.get('data');
    var decodedResponse = jsonDecode(userData);
    _iHLUserId = decodedResponse['User']['id'];
    var vitals = decodedResponse["LastCheckin"];
    systolic = vitals['systolic'].toString();
    diastolic = vitals['diastolic'].toString();
    print(_iHLUserId);
    print(systolic);
    print(diastolic);
  }

  void _initAsync1() async {
    // await SpUtil.getInstance();
    getIhlUserId();

    ///get the 10 question here by simply sputil getString()
    // cardio_age = SpUtil.getString('cardio_age');
    cardio_gen = SpUtil.getString('cardio_gender') == 'm' ? 'Male' : 'Female';
    // cardio_ht = SpUtil.getString('cardio_height');
    // cardio_wt = SpUtil.getString('cardio_weight');
    // cardio_ldl = SpUtil.getString('cardio_ldl');
    // cardio_hdl = SpUtil.getString('cardio_hdl');
    cardio_cholestrol = SpUtil.getString('cardio_cholestrol');
    cardio_smoke = SpUtil.getString('cardio_isSmoker');
    cardio_diab = SpUtil.getString('cardio_isFamilyDiabetes');
    // cardio_hyper = SpUtil.getString('cardio_isFamilyHypertension');
    print(cardio_gen + cardio_cholestrol + cardio_diab + cardio_smoke);

    ///api call after this , with all the
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
    _initAsync1();
  }

  bool resultLoading = false;
  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    Widget _customButton() {
      return Container(
        height: 60,
        child: GestureDetector(
          onTap: () async {
            SpUtil.putString(
                'cardio_isFamilyHypertension', selectedHypertensionCondition);
            // currentIndexOfCardio.value=10;

            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => CardioResultView(weight: 28.1, analysis: "Good"),
            //   ),
            // );
            if (mounted) {
              setState(() {
                resultLoading = true;
              });
            }
            var chscore = await cardiovascularDataSaveDBAPI();
            var score = double.parse(chscore['response']);
            var txt = calculateRiskLevel(score);
            await showPopupMenuDialog(context, score, txt);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF19a9e5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: resultLoading == false
                      ? Text(
                          AppTexts.continuee,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontFamily: 'Poppins',
                              fontSize: ScUtil().setSp(16),
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )
                      : CircularProgressIndicator(
                          color: FitnessAppTheme.white,
                        ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Text(
          //   AppTexts.step6,
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //       color: Color(0xFF19a9e5),
          //       fontFamily: 'Poppins',
          //       fontSize: ScUtil().setSp(12),
          //       letterSpacing: 1.5,
          //       fontWeight: FontWeight.bold,
          //       height: 1.16),
          // ),
          SizedBox(
            height: 4 * SizeConfig.heightMultiplier,
          ),
          Text(
            'On Hypertension Treatment?',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color.fromRGBO(109, 110, 113, 1),
                fontFamily: 'Poppins',
                fontSize: ScUtil().setSp(26),
                letterSpacing: 0,
                fontWeight: FontWeight.bold,
                height: 1.33),
          ),
          SizedBox(
            height: 1 * SizeConfig.heightMultiplier,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 50.0),
            child: Text(
              AppTexts.sub6,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color.fromRGBO(109, 110, 113, 1),
                  fontFamily: 'Poppins',
                  fontSize: ScUtil().setSp(15),
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.normal,
                  height: 1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 45, left: 10.0, right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  highlightColor: Colors.blueAccent,
                  splashColor: Colors.blue,
                  onTap: () {
                    if (this.mounted) {
                      setState(() => yesTap = true);
                      setState(() => noTap = false);
                      setState(() => otherTap = false);
                      setState(() => selectedHypertensionCondition = 'y');
                    }
                  },
                  child: Container(
                    width: 120,
                    height: 150,
                    decoration: BoxDecoration(
                      color: yesTap == true ? Color(0xFF19a9e5) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.asset(
                              'assets/images/cardio/hypertension.png',
                              // child: Image.network(
                              //   'https://i.postimg.cc/1z5LTN7w/1996679-2.png', //https://i.postimg.cc/9FfT4BNP/img-2.pnghttps://i.postimg.cc/5NQT8HkW/1996679-1.png',
                              height: 100,
                              fit: BoxFit.fitWidth),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'Yes',
                            style: TextStyle(
                              color:
                                  yesTap == true ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  highlightColor: Colors.blueAccent,
                  splashColor: Colors.blue,
                  onTap: () {
                    if (this.mounted) {
                      setState(() => noTap = true);
                      setState(() => yesTap = false);
                      setState(() => otherTap = false);
                      setState(() => selectedHypertensionCondition = 'n');
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 120,
                      height: 150,
                      decoration: BoxDecoration(
                        color: noTap == true ? Color(0xFF19a9e5) : Colors.white,
                        //borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                            ),
                            child: Image.asset(
                                'assets/images/cardio/hypertension.png',
                                // child: Image.network(
                                //   'https://i.postimg.cc/59YMbL4m/1996681-2.png', //https://i.postimg.cc/zX9BJSmG/img-3.pnghttps://i.postimg.cc/0ysvQd5B/1996681-1.png',
                                height: 100,
                                fit: BoxFit.fitWidth),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'No',
                              style: TextStyle(
                                color:
                                    noTap == true ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 2 * SizeConfig.heightMultiplier,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 50.0, top: 50.0),
            child: Center(
              child: _customButton(),
            ),
          ),
          SizedBox(
            height: 1 * SizeConfig.heightMultiplier,
          ),
        ],
      ),
    );
    // return Scaffold(
    // appBar: AppBar(
    //   backgroundColor: Colors.transparent,
    //   elevation: 0.0,
    //   title: Padding(
    //     padding: const EdgeInsets.only(left: 20),
    //     child: ClipRRect(
    //       borderRadius: BorderRadius.circular(10),
    //       child: Container(
    //         height: 5,
    //         child: LinearProgressIndicator(
    //           value: 0.75, // percent filled
    //           backgroundColor: Color(0xffDBEEFC),
    //         ),
    //       ),
    //     ),
    //   ),
    //   leading: IconButton(
    //     icon: Icon(Icons.arrow_back_ios),
    //     // onPressed: () => Navigator.of(context).pushNamed(Routes.Sdob),
    //     onPressed: () => Navigator.of(context).pushNamed(Routes.Sdob),
    //     color: Colors.black,
    //   ),
    //   actions: <Widget>[
    //     TextButton(
    //       onPressed: () {
    //         SpUtil.putString('cardio_gender', selectedGender);
    //         Navigator.of(context).push(
    //           MaterialPageRoute(
    //             builder: (context) => SignupHt(gender: selectedGender),
    //           ),
    //         );
    //       },
    //       child: Text(AppTexts.next,
    //           style: TextStyle(
    //             fontFamily: 'Poppins',
    //             fontWeight: FontWeight.bold,
    //             fontSize: ScUtil().setSp(16),
    //           )),
    //       style: TextButton.styleFrom(
    //         textStyle: TextStyle(
    //           color: Color(0xFF19a9e5),
    //         ),
    //         shape:
    //         CircleBorder(side: BorderSide(color: Colors.transparent)),
    //       ),
    //     ),
    //   ],
    // ),
    // backgroundColor: Color(0xffF4F6FA),
    // );
  }

  calculateRiskLevel(score) {
    var txt = score >= 20
        ? 'High'
        : score < 20 && score >= 7.5
            ? 'Intermediate'
            : score < 7.5 && score >= 5
                ? 'Borderline'
                : 'Low';
    // clr = colorForStatus(txt);
    return txt;
  }

  colorForStatus(riskLevel) {
    if (riskLevel == 'Low') {
      // return Colors.lightGreenAccent.shade400;
      return Colors.lightGreenAccent.shade700.withOpacity(1.0);
    } else if (riskLevel == 'Borderline') {
      return Colors.yellow.shade600;
    } else if (riskLevel == 'Intermediate') {
      return Colors.orange.shade200;
    } else if (riskLevel == 'High') {
      return Colors.redAccent.shade400;
    }
  }

  cardiovascularDataSaveDBAPI() async {
    genericDateTime(DateTime dateTime) {
      String str = dateTime.toString();
      var str1 = str.substring(0, str.indexOf(' '));
      var str2 = str.substring(str1.length + 1, str1.length + 6);
      // return DateTime.parse('$str1 00:00:00');
      var ss = str1 + " " + str2;
      print(ss);
      // return DateTime.parse('$str1 $str2'+':00');
      return '$str1 $str2' + ':00';
    }

    String dateTime = await genericDateTime(DateTime.now());
    print(dateTime);

    ///todo =>  get the questionariie data here and send in the api but what about the score.
    try {
      final response = await http.post(
        Uri.parse(API.iHLUrl + '/empcardiohealth/store_medical_data'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "ihl_user_id": _iHLUserId.toString() != 'null' ? _iHLUserId : '',
          "store_log_time": dateTime,
          "Cholesterol": cardio_cholestrol,
          "systolic_blood_pressure": systolic,
          "diastolic_blood_pressure": diastolic,
          "gender": cardio_gen == 'm' ? 'male' : 'female',
          "is_smoker": cardio_smoke == 'y' ? true : false,
          "have_diabetes": cardio_diab == 'y' ? true : false,
          "has_hypertension_treatment":
              selectedHypertensionCondition == 'y' ? true : false
        }),
      );
      if (response.statusCode == 200) {
        if (response.body != 'null' && response.body != '') {
          var data = jsonDecode(response.body);
          // var markersDetails = data;
          setState(() {
            resultLoading = false;
          });

          return data;
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> showPopupMenuDialog(
      BuildContext context, var chscore, String txt) async {
    // bool isChecking = false;
    // bool makeValidateVisible = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // String reasonRadioBtnVal = "";
        // final _formKey = GlobalKey<FormState>();
        return WillPopScope(
          onWillPop: () {
            Navigator.of(context).pop();
          },
          child: AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(12.0, 1.0, 12.0, 12.0),
            insetPadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.fromLTRB(1.0, 5.0, 1.0, 1.0),
            elevation: 10,
            // backgroundColor: Colors.blue.shade400,
            title: Text(
              'Cardiovascular\n'
              'Test Result',
              style: TextStyle(
                color: FitnessAppTheme.grey,
                fontSize: ScUtil().setSp(20),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                if (resultLoading == false) {
                  return SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 100,
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // SizedBox(height: 5),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Center(
                                  child: Text(txt,
                                      style: TextStyle(
                                          fontSize: ScUtil().setSp(22),
                                          color: colorForStatus(txt),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins'))),
                              Center(
                                  child: Text("$chscore",
                                      style: TextStyle(
                                          fontSize: ScUtil().setSp(50),
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Poppins'))),
                              // Center(child: Text("Score", style: TextStyle(fontSize:  ScUtil().setSp(22), color:AppColors.appTextColor,fontWeight: FontWeight.w600,fontFamily: 'Poppins'))),
                              SizedBox(height: ScUtil().setHeight(10)),
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
                                      color: colorForStatus('Borderline'),
                                    ),
                                    LinearGaugeRange(
                                      startValue: 7.5,
                                      endValue: 20,
                                      color: colorForStatus('Intermediate'),
                                    ),
                                    LinearGaugeRange(
                                      startValue: 21,
                                      endValue: 100,
                                      color: colorForStatus('High'),
                                    )
                                  ],
                                  minimum: 0,
                                  maximum: 100,
                                  markerPointers: [
                                    LinearShapePointer(value: chscore ?? 50.4)
                                  ]),
                              SizedBox(height: ScUtil().setHeight(15)),
                            ],
                          ),

                          Center(
                            child: Container(
                              child: ButtonTheme(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Navigator.pushAndRemoveUntil(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //       builder: (context) =>
                                    //           CardioDashboard(),
                                    //     ),
                                    //     (Route<dynamic> route) => false);
                                    final preferences =
                                        await SharedPreferences.getInstance();
                                    await preferences.setInt(
                                        'emp_cardio_score', chscore.toInt());
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => CardioNavBar(),
                                      ),
                                    );
                                  },
                                  child: Text("Dashboard"),
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 25),
                                    backgroundColor:
                                        AppColors.primaryAccentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 100,
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 10),
                          Center(child: CircularProgressIndicator()),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
