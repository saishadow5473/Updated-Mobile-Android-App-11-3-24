import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:ihl/constants/routes.dart';
import 'package:ihl/models/models.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/views/survey/waitingScreen.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ihl/models/surveyQuestion.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihl/constants/api.dart';

/// ignore: todo
/// TODO(Completed):
/// [x] Getting user details after registration
///*Done 😃* On last Question change 'Next' in button to 'Proceed'
/// [x]API Check
///*Done 😃* Store last attempted qus in prefs

List<IconData> _icons = [
  FontAwesomeIcons.heartbeat,
  FontAwesomeIcons.tint,
  FontAwesomeIcons.handHoldingHeart,
  FontAwesomeIcons.child,
  FontAwesomeIcons.diagnoses,
  FontAwesomeIcons.tachometerAlt,
  FontAwesomeIcons.heartbeat,
  FontAwesomeIcons.running,
  FontAwesomeIcons.wineBottle,
  FontAwesomeIcons.smoking,
  FontAwesomeIcons.brain,
  FontAwesomeIcons.pizzaSlice,
  FontAwesomeIcons.carrot,
  FontAwesomeIcons.appleAlt,
  Icons.restaurant,
  FontAwesomeIcons.utensils,
  FontAwesomeIcons.handHoldingHeart,
  FontAwesomeIcons.houseUser,
  FontAwesomeIcons.dna,
  FontAwesomeIcons.mapMarkerAlt
];

int qindex = 0;

class SurveyUi extends StatefulWidget {
  final bool signup;
  SurveyUi({this.signup, Key key}) : super(key: key);

  @override
  _SurveyUiState createState() => _SurveyUiState();
}

class _SurveyUiState extends State<SurveyUi> {
  http.Client _client = http.Client(); //3gb
  final iHLUrl = API.iHLUrl;
  final ihlToken = API.ihlToken;
  String apiToken;
  int qindex = 0;
  int unqindex = 0;
  bool answered = false;
  bool loading = true;
  bool isSubmitted = false;
  double _value = 0;
  String selectedChoice = "";
  bool isSelected = false;
  bool notConnected = false;
  int questionIndex;
  List notAns = [];
  List unAns = [];
  List<SurveyQuestion> _surveyQuestion = [];
  Map qMap = {};

  void _initSp() async {
    await SpUtil.getInstance();
  }

  getQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    String surveyjson = await rootBundle.loadString('assets/survey.json');
    List ok = jsonDecode(surveyjson);
    var q = prefs.get('qAns');
    q ??= '{}';
    Map qm = jsonDecode(q);
    _surveyQuestion = [];
    qMap = qm;
    ok.forEach((element) {
      _surveyQuestion.add(
        SurveyQuestion(element, preset: qm),
      );
    });
    SpUtil.putBool('close', false);
    if (widget.signup == true) {
      if (SpUtil.getBool('close') == true) {
        qindex = SpUtil.getInt('SkipQus');
      } else {
        qindex = 0;
      }
    } else {
      var raw = prefs.get('data');
      if (raw == '' || raw == null) {
        raw = '{}';
      }
      Map data = jsonDecode(raw);
      Map user = data['User'];
      user ??= {};
      user['user_score'] ??= {};
      Map score = user['user_score'];
      score.forEach((k, v) {
        if (v == 0) {
          notAns.add(k);
        }
      });
      notAns.remove('E1');
      notAns.remove('E2');
      notAns.remove('E3');
      notAns.remove('E4');
      if (notAns.isNotEmpty) {
        for (var i = 0; i < _surveyQuestion.length; i++) {
          for (var j = 0; j < notAns.length; j++) {
            if (_surveyQuestion[i].qid == notAns[j]) {
              unAns.add(i);
            }
          }
        }
      } else {
        //if not ans is compeletly empty when account created on kiosk then adding not ans manually
        unAns = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19];
        notAns = unAns;
      }
      qindex = unAns[0];
    }
    final response = await _client.get(
      Uri.parse(iHLUrl + '/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (response.statusCode == 200) {
      Signup survey = Signup.fromJson(json.decode(response.body));
      apiToken = survey.apiToken;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', apiToken);
    }
    loading = false;
    if (this.mounted) {
      setState(() {});
    }
  }

  _buildChoiceList() {
    List<Widget> choices = [];
    for (var i = 0; i < _surveyQuestion[qindex].options.length; i++) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChipTheme(
          data: ChipThemeData.fromDefaults(
              secondaryColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
              brightness: Brightness.light),
          child: ChoiceChip(
            label: Text(
              _surveyQuestion[qindex].options[i].mainAnswer.status,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            backgroundColor: Color(0xffededed),
            selectedColor: Color(0xFF19a9e5),
            selected: _value == i.toDouble(),
            onSelected: (selected) {
              if (this.mounted) {
                setState(() {
                  isSelected = true;
                  _value = i.toDouble();
                  answered = true;
                  selectedChoice = _surveyQuestion[qindex].options[i].mainAnswer.status;
                });
              }
            },
          ),
        ),
      ));
    }
    return choices;
  }

  Future onAnswered(String qId, String answer) async {
    var x;
    final prefs = await SharedPreferences.getInstance();
    var userData = prefs.get('data');
    String apikey = prefs.get('auth_token');
    var decodedResponse = jsonDecode(userData);
    String iHLUserToken = decodedResponse['Token'];
    String iHLUserId = decodedResponse['User']['id'];
    if (qId == 'D3') {
      x = jsonEncode(<String, List<String>>{
        'Q' + qId: answer == 'no' ? <String>[] : [answer]
      });
    } else {
      x = jsonEncode(<String, String>{'Q' + qId: answer});
    }
    final submitAnswerAPI = await _client.post(
      Uri.parse(iHLUrl + '/login/submit_answers?id=' + iHLUserId),
      headers: {
        'Content-Type': 'application/json',
        'Token': 'bearer ' + iHLUserToken,
        'ApiToken': apikey
      },
      body: x,
    );
    if (submitAnswerAPI.statusCode == 200) {
      if (submitAnswerAPI.body == null) {
        if (this.mounted) {
          setState(() {
            notConnected = true;
          });
        }
        throw Exception('Request body is not properly encoded');
      } else if (submitAnswerAPI.body == 'Api Security Token \'ApiToken\' not recognized.') {
        if (this.mounted) {
          setState(() {
            notConnected = true;
          });
        }
      } else {
        qMap[qId] = answer;
        SpUtil.remove('qAns');
        SpUtil.putObject('qAns', qMap);
        if (this.mounted) {
          setState(() {
            isSubmitted = false;
          });
        }
      }
    } else {
      if (this.mounted) {
        setState(() {
          notConnected = true;
        });
      }
    }
    return;
  }

  void onBackButtonPressed() {
    if (widget.signup == true) {
      if (qindex > 0) {
        if (this.mounted) {
          setState(() {
            qindex--;
            _value = _surveyQuestion[qindex].value.toDouble();
          });
        }
      }
    } else {
      if (unqindex > 0) {
        if (this.mounted) {
          setState(() {
            unqindex--;
            qindex = unAns[unqindex];
            _value = _surveyQuestion[qindex].value.toDouble();
          });
        }
      }
    }
    var y = SpUtil.getObject('qAns');
  }

  void onNextButtonPressed() {
    onAnswered(_surveyQuestion[qindex].qid,
            _surveyQuestion[qindex].options[_value.toInt()].mainAnswer.value)
        .whenComplete(() {
      _surveyQuestion[qindex].selectFromIndex(_value.toInt(), context).then((val) {
        if (val != null) {
          if (this.mounted) {
            setState(() {
              isSubmitted = true;
            });
          }
          val.qid = val.qid.replaceAll("Yes", "");
          onAnswered(val.qid, val.answer.mainAnswer.value).whenComplete(() {
            if (isSubmitted == false) {
              if (widget.signup == true) {
                if (_surveyQuestion[qindex].qid == 'A3') {
                  bmiCalc();
                }
                if (qindex < (_surveyQuestion.length) - 1) {
                  if (this.mounted) {
                    setState(() {
                      qindex++;

                      _value = _surveyQuestion[qindex].value.toDouble();
                    });
                  }
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SurveyWaiting(),
                    ),
                  );
                }
              } else {
                if (unqindex < unAns.length && qindex < (_surveyQuestion.length) - 1) {
                  if (this.mounted) {
                    setState(() {
                      unqindex++;
                      qindex = unAns[unqindex];
                      _value = _surveyQuestion[qindex].value.toDouble();
                    });
                  }
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SurveyWaiting(),
                    ),
                  );
                }
              }
            } else if (notConnected == true) {
              AwesomeDialog(
                      context: context,
                      animType: AnimType.TOPSLIDE,
                      headerAnimationLoop: true,
                      dialogType: DialogType.INFO,
                      dismissOnTouchOutside: false,
                      title: 'Info',
                      desc:
                          'Issues were encountered while submitting answer\nYou can try later from dashboard',
                      btnOkOnPress: () {
                        SpUtil.putBool('survey', false);
                        Navigator.of(context).pushReplacementNamed(Routes.SurveyProceed);
                      },
                      btnOkText: 'Take me to Dashboard',
                      btnOkIcon: Icons.dashboard,
                      onDismissCallback: (_) {})
                  .show();
            }
          });
        } else {
          if (isSubmitted == false) {
            if (widget.signup == true) {
              if (_surveyQuestion[qindex].qid == 'A3') {
                bmiCalc();
              }
              if (qindex < (_surveyQuestion.length) - 1) {
                if (this.mounted) {
                  setState(() {
                    qindex++;

                    _value = _surveyQuestion[qindex].value.toDouble();
                  });
                }
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurveyWaiting(),
                  ),
                );
              }
            } else {
              if (unqindex < unAns.length && qindex < (_surveyQuestion.length) - 1) {
                if (this.mounted) {
                  setState(() {
                    unqindex++;
                    qindex = unAns[unqindex];
                    _value = _surveyQuestion[qindex].value.toDouble();
                  });
                }
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurveyWaiting(),
                  ),
                );
              }
            }
          } else if (notConnected == true) {
            AwesomeDialog(
                    context: context,
                    animType: AnimType.SCALE,
                    headerAnimationLoop: true,
                    dialogType: DialogType.INFO,
                    dismissOnTouchOutside: false,
                    title: 'Info',
                    desc:
                        'Issues were encountered\nwhile submitting your answer.\nYou can try later from dashboard!',
                    btnOkOnPress: () {
                      SpUtil.putBool('survey', false);
                      Navigator.of(context).pushReplacementNamed(Routes.SurveyProceed);
                    },
                    btnOkText: 'Take me to Dashboard',
                    btnOkIcon: Icons.dashboard,
                    btnOkColor: Colors.blue,
                    onDismissCallback: (_) {})
                .show();
          }
        }
      });
    });
  }

  void bmiCalc() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    data = data == null || data == '' ? '{"User":{}}' : data;
    Map res = jsonDecode(data);
    var height = res['User']['heightMeters'].toString();
    var weight = res['User']['userInputWeightInKG'].toString();
    double parsedH;
    double parsedW;
    parsedH = double.tryParse(height);
    parsedW = double.tryParse(weight);
    if (parsedH != null && parsedW != null) {
      int bmi = parsedW ~/ (parsedH * parsedH);

      if (bmi == null) {
        onAnswered('A4', 'dont_know');
      }
      if (bmi > 30) {
        onAnswered('A4', 'obese');
      }
      if (bmi > 25) {
        onAnswered('A4', 'overweight');
      }
      if (bmi < 18) {
        onAnswered('A4', 'underweight');
      }
      onAnswered('A4', 'normal');
    } else {
      onAnswered('A4', 'dont_know');
    }
  }

  @override
  void initState() {
    super.initState();
    _initSp();
    getQuestion();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    var ht = MediaQuery.of(context).size.height;
    return SafeArea(
      top: true,
      child: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: () {
                  SpUtil.putBool('close', true);
                  SpUtil.putInt('SkipQus', qindex);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      widget.signup == true ? Routes.SProceed : Routes.SurveyProceed,
                      (Route<dynamic> route) => false);
                }),
            actions: <Widget>[
              // (qindex != null && qindex > 5)
              //     ? TextButton(
              //         onPressed: () {
              //           Navigator.of(context).pushNamedAndRemoveUntil(
              //               Routes.SurveyProceed,
              //               (Route<dynamic> route) => false);
              //         },
              //         child: Text('Skip',
              //             style: TextStyle(
              //               fontWeight: FontWeight.normal,
              //               fontSize: 18,
              //               color: Colors.white,
              //             )),
              //         style: TextButton.styleFrom(
              //             textStyle: TextStyle(color: Colors.white),
              //             shape: CircleBorder(
              //               side: BorderSide(color: Colors.transparent),
              //             )),
              //       )
              //     : Container(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.SurveyProceed, (Route<dynamic> route) => false);
                },
                child: Text('Skip',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                      color: Colors.white,
                    )),
                style: TextButton.styleFrom(
                    textStyle: TextStyle(color: Colors.white),
                    shape: CircleBorder(
                      side: BorderSide(color: Colors.transparent),
                    )),
              )
            ],
          ),
          extendBodyBehindAppBar: true,
          backgroundColor: AppColors.bgColorTab,
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                CustomPaint(
                  painter: BackgroundPainter(
                    primary: AppColors.primaryColor.withOpacity(0.7),
                    secondary: AppColors.primaryColor,
                  ),
                  child: Container(),
                ),
                Center(
                  child: Container(
                      margin: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Container(
                          child: Text(
                            "Health\nQuestionnarie",
                            style: TextStyle(
                                fontSize: ScUtil().setSp(22),
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
                ),
                Center(
                  child: loading
                      ? Dialog(
                          child: Container(
                            height: 100,
                            child: Center(
                              child: new Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  new CircularProgressIndicator(),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  new Text("Loading... Please wait"),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          child: Column(
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 5,
                                        right: (MediaQuery.of(context).size.width / 1.4)),
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: (widget.signup == true)
                                              ? (qindex + 1).toString()
                                              : (unqindex + 1).toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: ScUtil().setSp(24)),
                                        ),
                                        TextSpan(
                                          text: (widget.signup == true)
                                              ? '/' + _surveyQuestion.length.toString()
                                              : '/' + notAns.length.toString(),
                                          style: TextStyle(
                                              color: Colors.black, fontSize: ScUtil().setSp(14)),
                                        )
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                thickness: 1,
                                color: Colors.black12,
                                indent: 20,
                                endIndent: MediaQuery.of(context).size.width / 1.4,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  margin: const EdgeInsets.only(top: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(50),
                                      topRight: const Radius.circular(50),
                                      bottomLeft: const Radius.circular(50),
                                      bottomRight: const Radius.circular(50),
                                    ),
                                  ),
                                  color: CardColors.bgColor,
                                  child: Container(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(top: 40),
                                      height: ht / 1.85,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 5),
                                              child: Column(
                                                children: [
                                                  Center(
                                                    child: Icon(
                                                      _icons[qindex],
                                                      color: Color.fromRGBO(67, 147, 207, 1),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        top: 8.0, left: 8, right: 8),
                                                    child: _surveyQuestion == null ||
                                                            _surveyQuestion.isEmpty
                                                        ? CircularProgressIndicator()
                                                        : Text(
                                                            _surveyQuestion[qindex].question,
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                color: Colors.black, fontSize: 18),
                                                          ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Divider(
                                              thickness: 1,
                                              color: Colors.black12,
                                              indent: 50,
                                              endIndent: 50,
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  SingleChildScrollView(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Column(
                                                            verticalDirection:
                                                                VerticalDirection.down,
                                                            children: _buildChoiceList(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    margin: const EdgeInsets.only(left: 10, top: 5),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18.0),
                                          side: BorderSide(color: Colors.grey),
                                        ),
                                      ),
                                      onPressed: isSubmitted == true
                                          ? null
                                          : () {
                                              if (this.mounted) {
                                                setState(() {
                                                  onBackButtonPressed();
                                                });
                                              }
                                            },
                                      child: Text(
                                        "Back".toUpperCase(),
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  Spacer(flex: 1),
                                  Container(
                                    margin: const EdgeInsets.only(right: 10, top: 5),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Color(0xFF19a9e5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18.0),
                                          side: BorderSide(color: Colors.blue),
                                        ),
                                      ),
                                      onPressed: isSubmitted == true
                                          ? null
                                          : () async {
                                              if (this.mounted) {
                                                setState(() {
                                                  isSubmitted = true;
                                                });
                                              }
                                              onNextButtonPressed();
                                            },
                                      child: isSubmitted == true
                                          ? Container(
                                              height: 25,
                                              width: 25,
                                              child: new CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              (qindex + 1) != _surveyQuestion.length.toInt()
                                                  ? 'NEXT'
                                                  : 'Proceed'.toUpperCase(),
                                              style: TextStyle(color: Colors.white),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
