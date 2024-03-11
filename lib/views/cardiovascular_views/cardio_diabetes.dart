import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/views/cardiovascular_views/cardiovascular_survey.dart';
import 'package:ihl/views/signup/signup_height.dart';
import 'package:ihl/widgets/offline_widget.dart';

class CardioFamilyDiabetes extends StatefulWidget {
  CardioFamilyDiabetes({Key key}) : super(key: key);

  @override
  _CardioFamilyDiabetesState createState() => _CardioFamilyDiabetesState();
}

class _CardioFamilyDiabetesState extends State<CardioFamilyDiabetes> {
  bool yesTap = true;
  bool noTap = false;
  bool otherTap = false;
  Color tapped = Color(0xff56CCF2);
  Color notTapped = Colors.white;
  String selectedDiabetesCondition = 'n';
  void _initAsync() async {
    await SpUtil.getInstance();
    var cardio_diab;
    try {
      cardio_diab = SpUtil.getString('cardio_isFamilyDiabetes');
      if (cardio_diab.toString() != 'null' && cardio_diab.toString() != '') {
        setState(() {
          selectedDiabetesCondition = cardio_diab;
          if (selectedDiabetesCondition == 'y') {
            yesTap = true;
            noTap = false;
          } else if (selectedDiabetesCondition == 'n') {
            yesTap = false;
            noTap = true;
          }
        });
      }
      if (cardio_diab.toString() == '') {
        setState(() {
          yesTap = false;
          noTap = true;
          selectedDiabetesCondition = 'n';
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    Widget _customButton() {
      return Container(
        height: 60,
        child: GestureDetector(
          onTap: () {
            SpUtil.putString(
                'cardio_isFamilyDiabetes', selectedDiabetesCondition);
            currentIndexOfCardio.value = 4;
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => SignupHt(gender: selectedGender),
            //   ),
            // );
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
                  child: Text(
                    AppTexts.continuee,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontFamily: 'Poppins',
                        fontSize: ScUtil().setSp(16),
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.normal,
                        height: 1),
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
            'History of Diabetes?',
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
                      setState(() => selectedDiabetesCondition = 'y');
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
                              'assets/images/cardio/diabeties.png',
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
                      setState(() => selectedDiabetesCondition = 'n');
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
                                'assets/images/cardio/diabeties.png',
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
}
