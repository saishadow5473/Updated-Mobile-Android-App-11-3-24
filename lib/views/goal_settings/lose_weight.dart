import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/controllers/healthJournalControllers/getTodayLogController.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/goal_settings/apis/update_weight_api.dart';
import 'package:ihl/views/goal_settings/lose_by_activity.dart';
import 'package:ihl/views/goal_settings/lose_by_both.dart';
import 'package:ihl/views/goal_settings/lose_by_diet.dart';
import 'package:ihl/views/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoseWeightScreen extends StatefulWidget {
  final String goalID;

  const LoseWeightScreen({Key key, this.goalID}) : super(key: key);

  @override
  _LoseWeightScreenState createState() => _LoseWeightScreenState();
}

class _LoseWeightScreenState extends State<LoseWeightScreen> {
  final todayLogController = Get.put(TodayLogController());
  TextEditingController currentWeightController = TextEditingController();
  TextEditingController targetWeightController = TextEditingController();
  final key = new GlobalKey();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  double goalDuration = 0.5;
  String goalPlan = 'Diet';
  var _proceedLoading = false;

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = prefs.get('data');
    Map res = jsonDecode(userData);
    var weight = prefs.get('userLatestWeight').toString();
    if (weight == 'null' || weight == null) {
      weight = res['User']['userInputWeightInKG'].toString();
    }
    setState(() {
      currentWeightController.text = double.tryParse(weight).toStringAsFixed(2);
    });
  }

// Dart code to get the weight when bmi and height in meters given
  double calculateWeight(double bmi, double height) {
    double weight = bmi * height * height;
    return weight;
  }

  int calcBmi({height, weight}) {
    double parsedH;
    double parsedW;
    if (height == null || weight == null) {
      return null;
    }

    parsedH = double.tryParse(height);
    parsedW = double.tryParse(weight);
    if (parsedH != null && parsedW != null) {
      int bmi = parsedW ~/ (parsedH * parsedH);

      return bmi;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    getData();
    targetWeightController.text = todayLogController.targetWeight;
    if (targetWeightController.text == '0.0') {
      targetWeightController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var weightInside;
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Get.back();
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          if (_formKey.currentState.validate()) {
          } else {
            if (this.mounted) {
              setState(() {
                _autoValidate = true;
              });
            }
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Container(
              color: AppColors.bgColorTab,
              child: CustomPaint(
                painter: BackgroundPainter(
                    primary: Colors.green.withOpacity(0.8), secondary: Colors.green),
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 40,
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.network(
                                'https://i.postimg.cc/gj4Dfy7g/Objective-PNG-Free-Download.png'),
                          ),
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_back_ios),
                                      color: Colors.white,
                                      onPressed: () => Get.back(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScUtil().setWidth(40),
                                  ),
                                ],
                              ),
                              Container(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 35),
                        child: Text(
                          'Set Your Goal',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScUtil().setSp(24),
                          ),
                        ),
                      ),
                    ),
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                          side: BorderSide(width: 5, color: Color(0xfff4f6fa))),
                                      child: Container(
                                        height: 100,
                                        width: ScUtil().setWidth(285),
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Color(0xfff4f6fa),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              width: 64,
                                              height: 64,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                color: Colors.green,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.arrow_circle_down,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Great choice! You've opted to lose weight.",
                                                    style: TextStyle(
                                                      color: Color(0xff2d3142),
                                                      fontSize: ScUtil().setSp(14),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "We're excited to witness your transformation.",
                                                    style: TextStyle(
                                                      color: Color(0xff4c5980),
                                                      fontSize: ScUtil().setSp(11),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 25),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'Your current weight',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 150,
                                            margin: EdgeInsets.only(left: 25),
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return "Current Weight can't\nbe empty";
                                                } else if (double.tryParse(value) == null) {
                                                  return "Invalid Weight";
                                                } else if (double.parse(value) > 200) {
                                                  return "Max. Weight cannot surpass 200 Kg";
                                                } else if (double.parse(value) < 40) {
                                                  return "Min. Weight is 40 Kgs";
                                                }
                                                return null;
                                              },
                                              autofocus: true,
                                              enabled: true,
                                              controller: currentWeightController,
                                              cursorColor: Colors.green,
                                              decoration: InputDecoration(
                                                suffixIcon: Padding(
                                                  padding: const EdgeInsets.only(top: 6.0),
                                                  child: Text(
                                                    'Kgs',
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 24,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                counterText: '',
                                                counterStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 0,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.green),
                                                ),
                                                focusColor: Colors.green,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.green),
                                                ),
                                              ),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 28,
                                                // fontWeight: FontWeight.bold,
                                              ),
                                              textInputAction: TextInputAction.next,
                                              keyboardType: TextInputType.numberWithOptions(
                                                  decimal: false, signed: false),
                                              maxLength: 5,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Tooltip(
                                            key: key,
                                            child: IconButton(
                                              icon: Icon(Icons.info),
                                              onPressed: () {
                                                final dynamic tooltip = key.currentState;
                                                tooltip.ensureTooltipVisible();
                                              },
                                            ),
                                            message:
                                                'Note: The weight displayed here is based on your last update. '
                                                'Please enter your recent weight, if any ',
                                            padding: EdgeInsets.all(20),
                                            margin: EdgeInsets.all(20),
                                            showDuration: Duration(seconds: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.9),
                                              borderRadius:
                                                  const BorderRadius.all(Radius.circular(4)),
                                            ),
                                            textStyle: TextStyle(color: Colors.white),
                                            preferBelow: true,
                                            verticalOffset: 20,
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 25),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'Your target weight',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        width: 150,
                                        margin: EdgeInsets.only(left: 25),
                                        child: TextFormField(
                                          controller: targetWeightController,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "Target Weight can't\nbe empty";
                                            } else if (double.tryParse(value) == null) {
                                              return "Invalid Weight";
                                            } else if (double.tryParse(
                                                    currentWeightController.text) ==
                                                null) {
                                              return "Please set current\nweight first!";
                                            } else if (double.parse(value) >=
                                                double.tryParse(currentWeightController.text)) {
                                              return "Invalid Target weight\nto lose.";
                                            } else if (double.tryParse(
                                                        currentWeightController.text) -
                                                    (double.parse(value)) <
                                                1) {
                                              return "Invalid Target weight\nto lose.";
                                            } else if (double.parse(value) < 45)
                                            // (double.parse(currentWeightController
                                            //         .text)/2))
                                            {
                                              return "Min. Weight is 45 Kgs";
                                              // "${(double.parse(currentWeightController
                                              //       .text)/2).toStringAsFixed(0)} Kgs";
                                            }
                                            return null;
                                          },
                                          cursorColor: Colors.green,
                                          decoration: InputDecoration(
                                            suffixIcon: Padding(
                                              padding: const EdgeInsets.only(top: 6.0),
                                              child: Text(
                                                'Kgs',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 24,
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            hintText: '00.00',
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 28,
                                              // fontWeight: FontWeight.bold,
                                            ),
                                            counterText: '',
                                            counterStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 0,
                                            ),
                                            enabled: true,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.green),
                                            ),
                                            focusColor: Colors.green,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.green),
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 28,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.number,
                                          maxLength: 5,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 25),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'Choose your plan',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: Container(
                                        child: DropdownButton<String>(
                                          focusColor: Colors.white,
                                          value: goalPlan,
                                          isExpanded: true,
                                          underline: Container(
                                            height: 2.0,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.green,
                                                  width: 2.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          style: TextStyle(color: Colors.white),
                                          iconEnabledColor: Colors.black,
                                          items: <String>[
                                            'Diet',
                                            'Exercise',
                                            'Both Diet and Exercise'
                                          ].map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Container(
                                                padding: const EdgeInsets.only(bottom: 5),
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          hint: Text(
                                            "Select goal plan",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          onChanged: (String value) {
                                            setState(() {
                                              goalPlan = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 120)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
              onPressed: !_proceedLoading
                  ? () async {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (_formKey.currentState.validate()) {
                        ///if weight changed than we update the weight and set the goal otherwise normally set the goal
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        var userData = prefs.get('data');
                        Map res = jsonDecode(userData);
                        print(res['User']['userInputWeightInKG'].toString());
                        if (weightInside == null) {
                          weightInside = res['User']['userInputWeightInKG'].toString();
                        } else {
                          weightInside = prefs.get('userLatestWeight').toString();
                        }
                        if (currentWeightController.text !=
                            double.tryParse(weightInside).toStringAsFixed(2)) {
                          setState(() {
                            _proceedLoading = true;
                          });
                          UpdateWeight updateWeightController = UpdateWeight();
                          var isSuccess = await updateWeightController.updateWeight(
                              currentWeightController.text, false);
                          if (isSuccess) {
                            setState(() {
                              _proceedLoading = false;
                            });
                            proceed();
                          } else {
                            setState(() {
                              _proceedLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.primaryAccentColor,
                                content: Text('Failed to update Weight Please try Again...'),
                              ),
                            );
                          }
                        } else {
                          proceed();
                        }
                      } else {
                        if (this.mounted) {
                          setState(() {
                            _autoValidate = true;
                          });
                        }
                      }
                    }
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.greenColor,
                          content: Text('Loading...'),
                        ),
                      );
                    },
              backgroundColor: Colors.green,
              label: Text(!_proceedLoading ? 'Continue' : 'Loading',
                  style: TextStyle(fontWeight: FontWeight.w600, color: FitnessAppTheme.white)),
              icon: !_proceedLoading
                  ? Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                    )
                  : SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3.0,
                      ))),
        ),
      ),
    );
  }

  void proceed() {
    if (goalPlan == 'Diet') {
      Get.to(LoseWeightByDietScreen(
          fromManageHealth: true,
          targetWeight: targetWeightController.text,
          currentWeight: currentWeightController.text,
          goalID: widget.goalID));
    } else if (goalPlan == 'Exercise') {
      Get.to(LoseWeightByActivityScreen(
          fromManageHealth: true,
          targetWeight: targetWeightController.text,
          currentWeight: currentWeightController.text,
          goalID: widget.goalID));
    } else {
      Get.to(LoseWeightByBothScreen(
          fromManageHealth: true,
          targetWeight: targetWeightController.text,
          currentWeight: currentWeightController.text,
          goalID: widget.goalID));
    }
  }
}
