import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/policyDialog.dart';

///  this
class ReusableAlertBox extends StatefulWidget {
  ReusableAlertBox(
      {this.allow,
      this.isAgree,
      this.alertText,
      this.txtColor,
      this.context,
      this.mystate,
      this.continueOnTap,
      this.changeOnTap});

  final allow;
  bool isAgree;
  final alertText;
  final txtColor;
  final context;
  final mystate;
  Function continueOnTap;
  Function changeOnTap;

  @override
  _ReusableAlertBoxState createState() => _ReusableAlertBoxState();
}

class _ReusableAlertBoxState extends State<ReusableAlertBox> {
  @override
  var wisAgree = false;
  void initState() {
    // TODO: implement initState
    wisAgree = widget.isAgree;
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    return Container(
      height: widget.alertText.length > 30 ? 390 : 350,
      decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Column(
        children: <Widget>[
          Container(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.network(
                          'https://i.postimg.cc/gj4Dfy7g/Objective-PNG-Free-Download.png'),
                    ),
                    // Icon(
                    //   FontAwesomeIcons.palette,
                    //   size: 80,
                    //   color: Colors.white,
                    // ),
                    // SizedBox(
                    //   height: 20,
                    // ),
                  ],
                )),
            width: double.infinity,
            decoration: const BoxDecoration(
                color: AppColors.primaryColor, //AppColors.primaryColor,
                shape: BoxShape.rectangle,
                borderRadius:
                    BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          ),
          const SizedBox(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16),
            child: Text(
              widget
                  .alertText, //+'\n'+(int.parse((goalCaloriesIntake))*bmrRateForAlert).toString(),
              style: TextStyle(color: widget.txtColor, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment:
                widget.allow ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
            children: [
              // SizedBox(
              //   width: MediaQuery.of(context).size.width / 10,
              // ),
              Visibility(
                visible: widget.allow,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    primary: wisAgree ? AppColors.primaryColor : Colors.grey,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 13.0, bottom: 13.0, right: 15, left: 15),
                    child: Text(
                      'Continue',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  onPressed: () async {
                    if (widget.allow && wisAgree) {
                      widget.continueOnTap();
                      // Get.to(
                      //   LoseWeightByActivityGoalScreen(
                      //     targetWeight: widget.targetWeight,
                      //     currentWeight: widget.currentWeight,
                      //     bmrRate: maxDuration(goalPlan),
                      //     targetDate: goalDurationDate(),
                      //     goalPace: goalDuration.toStringAsFixed(1),
                      //     activityLevel: goalPlan,
                      //     goalID: widget.goalID,
                      //   ),
                      // );
                    }
                  },
                ),
              ),

              // SizedBox(
              //   width: MediaQuery.of(context).size.width / 8,
              // ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  primary: AppColors.primaryColor,
                ),
                child: const Padding(
                  padding: EdgeInsets.only(top: 13.0, bottom: 13.0, right: 15, left: 15),
                  child: Text(
                    'Change',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                onPressed: () {
                  if (widget.changeOnTap == null) {
                    Navigator.pop(context);
                  } else {
                    widget.changeOnTap();
                  }
                },
              ),
            ],
          ),
          const SizedBox(
            height: 18,
          ),
          Visibility(
            visible: widget.allow,
            child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: wisAgree,
              onChanged: (val) {
                setState(() {
                  wisAgree = val;
                });
                widget.mystate(() {
                  wisAgree = val;
                });

                // mystate(
                //         () {
                //       isAgree =
                //           val;
                //       print(
                //           isAgree);
                //     });
              },

              title: RichText(
                text: TextSpan(
                    // text: 'I agree to the ',
                    children: [
                      const TextSpan(
                        text: "I agree to the ",
                        style: TextStyle(color: AppColors.appTextColor, fontSize: 12),
                      ),
                      TextSpan(
                        text: "Terms & Conditions",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.dialog(PolicyDialog(
                              title: "Goal Setting T & C",
                              mdFileName: 'GoalTOC.md',
                            ));
                          },
                      ),
                      const TextSpan(
                        text: " for the service",
                        style: TextStyle(color: AppColors.appTextColor, fontSize: 12),
                      ),
                    ]),
                // 'I agree to the Terms and Condition for the service',
                // style: TextStyle(
                //     color: AppColors
                //         .appTextColor,
                //     fontSize:
                //     12),
              ),
              // isThreeLine: false,
              contentPadding: const EdgeInsets.only(left: 16),
            ),
          ),
        ],
      ),
    );
  }
}
