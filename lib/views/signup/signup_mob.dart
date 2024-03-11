import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ihl/models/models.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/views/signup/signup_verify_mobile.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

final iHLUrl1 = API.iHLUrl;
final ihlToken1 = API.ihlToken;

class SignupMob extends StatefulWidget {
  final Apirepository apiRepository;

  SignupMob({Key key, @required this.apiRepository})
      : assert(apiRepository != null),
        super(key: key);

  @override
  _SignupMobState createState() => _SignupMobState();
}

class _SignupMobState extends State<SignupMob> with TickerProviderStateMixin {
  http.Client _client = http.Client(); //3gb
  TextEditingController mobController = TextEditingController();
  String initialCountry = 'IN';
  FocusNode mobFocusNode;
  String apiToken;
  bool userExistR = false;
  bool isChecking = false;

  Future<bool> userExist() async {
    final response = await _client.get(
      Uri.parse(iHLUrl1 + '/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken1},
    );
    if (response.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(response.body));
      apiToken = reponseToken.apiToken;
      final userExits = await _client.get(
        Uri.parse(
            iHLUrl1 + '/login/emailormobileused?email=&mobile=' + mobController.text + '&aadhaar='),
        headers: {'ApiToken': reponseToken.apiToken},
      );
      if (userExits.statusCode == 200) {
        var userExistResponse = userExits.body.replaceAll(new RegExp(r'[^\w\s]+'), '');
        if (userExistResponse == "You never registered with this Mobile number") {
          userExistR = false;
          return userExistR;
        } else {
          if (this.mounted) {
            setState(() {
              //remove it when abha testing finished
              userExistR = true;
              isChecking = false;
            });
          }
          // ignore: unused_local_variable
          var userExistResponse = "User already exist";
          return userExistR;
        }
      } else {
        throw Exception('Authorization Failed');
      }
    }
    return userExistR;
  }

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    mobFocusNode = FocusNode();
    _initAsync();
  }

  Widget mobTextField() {
    return StreamBuilder<String>(
      builder: (context, snapshot) {
        return TextFormField(
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: mobController,
          validator: (value) {
            if (value.isEmpty) {
              return 'Mobile number can\'t be empty!';
            } else if ((value.length < 10)) {
              return "Invalid Mobile";
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 5, top: 2, end: 6.0),
              child: Image.network(
                'https://github.com/niinyarko/flutter-international-phone-input/blob/master/assets/flags/in.png?raw=true',
                height: 20,
                width: 40,
                fit: BoxFit.fitWidth,
              ),
            ),
            prefixText: '+91-',
            labelText: "Mobile Number",
            counterText: "",
            counterStyle: TextStyle(fontSize: 0),
            fillColor: Colors.white,
            border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(15.0),
                borderSide: new BorderSide(color: Colors.blueGrey)),
            errorText: validatemob(mobController.text),
          ),
          keyboardType: TextInputType.phone,
          style: TextStyle(
            fontSize: ScUtil().setSp(16),
          ),
          focusNode: mobFocusNode,
          textInputAction: TextInputAction.done,
        );
      },
    );
  }

  String validatemob(String value) {
    if (!(value.length >= 10) && value.isNotEmpty) {
      return "Invalid Mobile";
    }
    return null;
  }

  Future<bool> invalidphone(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(0),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: AppColors.appTextColor),
                    children: [
                      TextSpan(
                          text:
                              'The Mobile number you entered is either incorrect or unavailable for OTP service\nPlease enter valid Mobile number.'),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: TextButton(
                      child: Text('Ok'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              )
            ],
            title: Text('Invalid Mobile number'),
          );
        });
  }

  Future<bool> ask(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(0),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: AppColors.appTextColor),
                    children: [
                      TextSpan(text: 'We will be sending a 4 digit OTP to '),
                      TextSpan(
                          text: mobController.text, style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' , would you like to continue?'),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: TextButton(
                      child: Text('cancel'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      child: Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ),
                ],
              )
            ],
            title: Text('Verify phone number?'),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: false);
    Widget _customButton() {
      return Container(
        height: 60,
        child: GestureDetector(
          onTap: () {
            if (this.mounted) {
              setState(() {
                isChecking = true;
              });
            }
            if (_formKey.currentState.validate()) {
              userExist().then((v) {
                if (userExistR == false) {
                  if (this.mounted) {
                    setState(() {
                      SpUtil.putString('mob', mobController.text.toString());
                      isChecking = false;
                      //Navigator.of(context).pushNamed(Routes.Sdob);
                      Get.to(SignupVerifyMob(mobileNumber: mobController.text.toString()));
                    });
                  }
                }
              });
            } else {
              if (this.mounted) {
                setState(() {
                  isChecking = false;
                  _autoValidate = true;
                });
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
                  child: isChecking == true
                      ? new CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Continue',
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
            //         value: 0.5, // percent filled
            //         backgroundColor: Color(0xffDBEEFC),
            //       ),
            //     ),
            //   ),
            // ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pushNamed(Routes.Spwd),
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
                    if (this.mounted) {
                      setState(() {
                        isChecking = true;
                      });
                    }
                    if (_formKey.currentState.validate()) {
                      userExist().then((v) {
                        if (userExistR == false) {
                          if (this.mounted) {
                            setState(() {
                              SpUtil.putString('mob', mobController.text.toString());
                              isChecking = false;
                              //Navigator.of(context).pushNamed(Routes.Sdob);
                              Get.to(SignupVerifyMob(mobileNumber: mobController.text.toString()));
                            });
                          }
                        }
                      });
                    } else {
                      if (this.mounted) {
                        setState(() {
                          isChecking = false;
                          _autoValidate = true;
                        });
                      }
                    }
                  },
                  child: Text(AppTexts.next,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: ScUtil().setSp(16))),
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
            autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 5.0),
                  // Text(
                  //   'AppTexts.step4',
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
                    AppTexts.mob,
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
                    height: 3 * SizeConfig.heightMultiplier,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    child: Text(
                      AppTexts.sub4,
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
                  SizedBox(
                    height: 6 * SizeConfig.heightMultiplier,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Container(
                      child: Column(
                        children: [
                          mobTextField(),
                          SizedBox(
                            height: 2 * SizeConfig.heightMultiplier,
                          ),
                          userExistR == true
                              ? Column(children: [
                                  RichText(
                                      text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Looks like you already registered!',
                                        style: TextStyle(
                                          color: Color(0xff6d6e71),
                                          fontSize: ScUtil().setSp(12),
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' ',
                                        style: TextStyle(
                                          color: Color(0xff66688f),
                                          fontSize: ScUtil().setSp(14),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Login Here!',
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: ScUtil().setSp(16),
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => Navigator.of(context)
                                              .pushNamed(Routes.Login, arguments: false),
                                      ),
                                    ],
                                  ))
                                ])
                              : SizedBox(height: 1 * SizeConfig.heightMultiplier)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5 * SizeConfig.heightMultiplier,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    child: Center(
                      child: _customButton(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    mobController?.dispose();
    super.dispose();
  }
}
