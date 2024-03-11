import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:ihl/widgets/weight.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SignupWt extends StatefulWidget {
  SignupWt({Key key}) : super(key: key);

  @override
  _SignupWtState createState() => _SignupWtState();
}

class _SignupWtState extends State<SignupWt> {
  int weight = 70;
  bool mannual = false;
  FocusNode mobFocusNode;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  TextEditingController weightController = TextEditingController();

  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Widget weightTextField() {
    return StreamBuilder<String>(
      builder: (context, snapshot) {
        return TextFormField(
          controller: weightController,
          validator: (value) {
            if (value.isEmpty) {
              return 'Weight can\'t be empty!';
            } else if ((double.parse(value) < 5.00) && value.isNotEmpty) {
              return "Min. Weight is 5 Kgs";
            } else if ((double.parse(value) > 200.00) && value.isNotEmpty) {
              return "Max. Weight cannot surpass 200 Kg";
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
            suffixText: 'KGs',
            labelText: "Weight (in KG)",
            counterText: "",
            counterStyle: TextStyle(fontSize: 0),
            fillColor: Colors.white,
            border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(15.0),
                borderSide: new BorderSide(color: Colors.blueGrey)),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            fontSize: ScUtil().setSp(16),
          ),
          focusNode: mobFocusNode,
          textInputAction: TextInputAction.done,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    Widget _customButton() {
      return Container(
        height: 60,
        child: GestureDetector(
          onTap: () {
            if (mannual == false) {
              SpUtil.putString('weight', weight.toString());
              // Navigator.of(context).pushNamed(Routes.Aff);
              Navigator.of(context).pushNamed(Routes.Spic);
            } else {
              if (_formKey.currentState.validate()) {
                if (this.mounted) {
                  setState(() {
                    SpUtil.putString('weight', weightController.text);
                    // Navigator.of(context).pushNamed(Routes.Aff);
                    Navigator.of(context).pushNamed(Routes.Spic);
                  });
                }
              } else {
                if (this.mounted) {
                  setState(() {
                    _autoValidate = true;
                  });
                }
              }
            }
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

    return SafeArea(
      top: true,
      child: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            // title: Padding(
            //   padding: const EdgeInsets.only(left: 20),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(10),
            //     child: Container(
            //       height: 5,
            //       child: LinearProgressIndicator(
            //         value: 0.930, // percent filled
            //         backgroundColor: Color(0xffDBEEFC),
            //       ),
            //     ),
            //   ),
            // ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pushNamed(Routes.Sheight),
              color: Colors.black,
            ),
            actions: <Widget>[
              Visibility(
                visible: false,
                replacement: SizedBox(
                  width: 10.w,
                ),
                child: TextButton(
                  onPressed: () {
                    SpUtil.putString('weight', weight.toString());
                    // Navigator.of(context).pushNamed(Routes.Aff);
                    Navigator.of(context).pushNamed(Routes.Spic);
                  },
                  child: Text(
                    AppTexts.next,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: ScUtil().setSp(16),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      color: Color(0xFF19a9e5),
                    ),
                    shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xffF4F6FA),
          body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 5.0,
                  ),
                  // Text(
                  //   AppTexts.step8,
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
                    height: 6 * SizeConfig.heightMultiplier,
                  ),
                  Text(
                    AppTexts.weight,
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
                      AppTexts.sub8,
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
                  mannual == false
                      ? Container(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: WeightSlider(
                            weight: weight,
                            minWeight: 40,
                            maxWeight: 250,
                            onChange: (val) {
                              if (this.mounted) {
                                setState(() => this.weight = val);
                              }
                            },
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 40, left: 30.0, right: 30.0),
                          child: Container(
                            child: weightTextField(),
                          ),
                        ),
                  TextButton(
                      onPressed: () {
                        if (this.mounted) {
                          setState(() {
                            mannual = !mannual;
                          });
                        }
                      },
                      child: mannual == false
                          ? Text('Not Seeing your weight? Enter Manually',
                              style: TextStyle(
                                color: Color(0xFF19a9e5),
                                fontSize: ScUtil().setSp(14),
                              ))
                          : Text('Use Slider instead',
                              style: TextStyle(
                                color: Color(0xFF19a9e5),
                                fontSize: ScUtil().setSp(14),
                              ))),
                  SizedBox(
                    height: 2 * SizeConfig.heightMultiplier,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    child: Center(
                      child: _customButton(),
                    ),
                  ),
                  SizedBox(
                    height: 1 * SizeConfig.heightMultiplier,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
