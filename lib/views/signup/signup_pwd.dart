import 'dart:math' as math;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_texts.dart';
import '../../constants/routes.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../repositories/api_register.dart';
import '../../utils/ScUtil.dart';
import '../../utils/SpUtil.dart';
import '../../utils/sizeConfig.dart';
import '../../utils/validators.dart';
import 'signup_pic.dart';
import '../../widgets/offline_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPwd extends StatefulWidget {
  const SignupPwd({Key key}) : super(key: key);

  static const String id = '/signup_pwd';

  @override
  _SignupPwdState createState() => _SignupPwdState();
}

class _SignupPwdState extends State<SignupPwd> with TickerProviderStateMixin {
  TextEditingController pwdController = TextEditingController();

  AnimationController _controller;
  Animation<double> _fabScale;
  bool passwordHide;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  FocusNode pwdFocusNode;
  bool eightChars = false;
  bool specialChar = false;
  bool upperCaseChar = false;
  bool number = false;
  // bool containsConsecutive = false;
  bool registrationProcess = false;
  bool buttonClicked = false;
  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    passwordHide = true;
    pwdFocusNode = FocusNode();
    _initAsync();
    pwdController.addListener(() {
      if (mounted) {
        setState(() {
          eightChars = pwdController.text.length >= 8;
          number = pwdController.text.contains(RegExp(r'\d'), 0);
          upperCaseChar = pwdController.text.contains(RegExp(r'[A-Z]'), 0);
          specialChar = pwdController.text.isNotEmpty &&
              !pwdController.text.contains(RegExp(r'^[\w&.-]+$'), 0);
          // containsConsecutive = !containsConsecutiveAlphanumeric(pwdController.text);
        });
      }

      if (_allValid()) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _fabScale = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));

    _fabScale.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  bool containsConsecutiveAlphanumeric(String str) {
    RegExp pattern =
        RegExp(r'[a-zA-Z0-9]+'); // Matches one or more consecutive alphanumeric characters
    Iterable<Match> matches = pattern.allMatches(str);
    for (Match match in matches) {
      String matchedString = match.group(0).toString();
      for (int i = 0; i < matchedString.length - 1; i++) {
        String currentChar = matchedString[i];
        String nextChar = matchedString[i + 1];
        if (isNumeric(currentChar) && isNumeric(nextChar)) {
          // Check if current and next characters are numeric
          if (int.parse(nextChar) - int.parse(currentChar) == 1) {
            // Check if current and next characters form a consecutive sequence
            return true;
          }
        } else if (isLetter(currentChar) && isLetter(nextChar)) {
          // Check if current and next characters are letters
          if (nextChar.codeUnitAt(0) - currentChar.codeUnitAt(0) == 1) {
            // Check if current and next characters form a consecutive sequence
            return true;
          }
        }
      }
    }
    return false;
  }

  bool isNumeric(String str) {
    // Utility function to check if a string is numeric
    return double.tryParse(str) != null;
  }

  bool isLetter(String str) {
    // Utility function to check if a string is a letter
    return str.toLowerCase() != str.toUpperCase();
  }

  Widget pwdTextField() {
    return StreamBuilder<String>(
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return TextFormField(
          keyboardType: TextInputType.visiblePassword,
          controller: pwdController,
          obscureText: passwordHide,
          autofocus: false,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Please Enter Password';
            } else if (validatePassword(pwdController.text) != null) {
              // if (!containsConsecutive) {
              //   return 'should not contains any sequence Ex.123 or abc';
              // } else {
              //   return "Invalid password";
              // }
              return "Invalid password";
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
            suffixIcon: IconButton(
              icon: Icon(
                passwordHide ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    passwordHide = !passwordHide;
                  });
                }
              },
            ),
            labelText: "Password",
            errorText: validatePassword(pwdController.text),
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(color: Colors.blueGrey)),
          ),
          maxLines: 1,
          style: TextStyle(
            fontSize: ScUtil().setSp(16),
          ),
          focusNode: pwdFocusNode,
          textInputAction: TextInputAction.done,
        );
      },
    );
  }

  String validatePassword(String value) {
    if (!(eightChars && number && specialChar && upperCaseChar) && value.isNotEmpty) {
      // if (!containsConsecutive) {
      //   return 'should not contains any sequence Ex.123 or abc';
      // } else {
      //   return "Invalid password";
      // }
      return "Invalid password";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: false);

    Widget _customButton() {
      return SizedBox(
        height: 60,
        child: GestureDetector(
          onTap: registrationProcess
              ? () {}
              : () async {
                  if (!buttonClicked) {
                    buttonClicked = true;
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    if (_formKey.currentState.validate()) {
                      SpUtil.putString('pwd', pwdController.text);
                      prefs.setString('password', pwdController.text);
                      // Get.to(SignupPic());
                      // Navigator.of(context).pushNamed(Routes.Smob);
                      register();
                    } else {
                      if (mounted) {
                        setState(() {
                          _autoValidate = true;
                        });
                      }
                    }
                  }
                },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF19a9e5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                registrationProcess
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Center(
                        child: Text(
                          AppTexts.continuee,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: const Color.fromRGBO(255, 255, 255, 1),
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

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SafeArea(
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
              //         value: 0.375, // percent filled
              //         backgroundColor: Color(0xffDBEEFC),
              //       ),
              //     ),
              //   ),
              // ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pushNamed(Routes.Semail),
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
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (_formKey.currentState.validate()) {
                        SpUtil.putString('pwd', pwdController.text);
                        Navigator.of(context).pushNamed(Routes.Smob);
                      } else {
                        if (mounted) {
                          setState(() {
                            _autoValidate = true;
                          });
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                        color: Color(0xFF19a9e5),
                      ),
                      shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),
                    child: Text(AppTexts.next,
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: ScUtil().setSp(16))),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xffF4F6FA),
            body: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 5.h,
                    ),
                    // Text(
                    //   AppTexts.step3,
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     color: Color(0xFF19a9e5),
                    //     fontFamily: 'Poppins',
                    //     fontSize: ScUtil().setSp(12),
                    //     letterSpacing: 1.5,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    SizedBox(
                      height: 5 * SizeConfig.heightMultiplier,
                    ),
                    Text(
                      AppTexts.pwd,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: const Color.fromRGBO(109, 110, 113, 1),
                          fontFamily: 'Poppins',
                          fontSize: ScUtil().setSp(26),
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                          height: 1.33),
                    ),
                    SizedBox(
                      height: 1 * SizeConfig.heightMultiplier,
                    ),
                    SizedBox(
                      height: 3.5.h,
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    //   child: Text(
                    //     AppTexts.sub3,
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //         color: const Color.fromRGBO(109, 110, 113, 1),
                    //         fontFamily: 'Poppins',
                    //         fontSize: ScUtil().setSp(15),
                    //         letterSpacing: 0.2,
                    //         fontWeight: FontWeight.normal,
                    //         height: 1),
                    //   ),
                    // ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(72, 20, 40, 10),
                        child: _validationStack()),
                    SizedBox(
                      height: 2 * SizeConfig.heightMultiplier,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Container(
                        child: pwdTextField(),
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
      ),
    );
  }

  Widget _separator() {
    return Container(
      height: 1,
      decoration: BoxDecoration(color: Colors.blue.withAlpha(100)),
    );
  }

  Stack _validationStack() {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: <Widget>[
        const Card(
          shape: CircleBorder(),
          color: Colors.grey,
          child: SizedBox(
            height: 150,
            width: 150,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0, left: 10),
          child: Transform.rotate(
            angle: -math.pi / 20,
            child: const Icon(
              Icons.lock,
              color: Colors.black26,
              size: 60,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 50.0, right: 60),
          child: Transform.rotate(
            angle: -math.pi / -60,
            child: SizedBox(
              width: 60,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                elevation: 4,
                color: Colors.yellow.shade800,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 0, 4),
                      child: Container(
                          alignment: Alignment.centerLeft,
                          child: const Icon(
                            Icons.brightness_1,
                            color: Colors.black12,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
                      child: Container(
                          alignment: Alignment.centerLeft,
                          child: const Icon(
                            Icons.brightness_1,
                            color: Colors.black12,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
                      child: Container(
                          alignment: Alignment.centerLeft,
                          child: const Icon(
                            Icons.brightness_1,
                            color: Colors.black12,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 0, 8),
                      child: Container(
                          alignment: Alignment.centerLeft,
                          child: const Icon(
                            Icons.brightness_1,
                            color: Colors.black12,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80),
          child: Transform.rotate(
            angle: math.pi / -45,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ValidationItem("8 Characters +", eightChars),
                        _separator(),
                        ValidationItem("1 Special character", specialChar),
                        _separator(),
                        ValidationItem("1 Upper case", upperCaseChar),
                        _separator(),
                        ValidationItem("1 Number", number),
                        // _separator(),
                        // ValidationItem('shouldn' "'t " 'contains sequence', containsConsecutive),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Transform.scale(
                      scale: _fabScale.value,
                      child: const Card(
                        shape: CircleBorder(),
                        color: Colors.green,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  void register() async {
    registrationProcess = true;
    setState(() {});
    fname = SpUtil.getString('fname');
    lname = SpUtil.getString('lname');
    email = SpUtil.getString('email');
    pwd = SpUtil.getString('pwd');
    String userRegister = await RegisterUserWithPic()
        .registerUser(firstName: fname, lastName: lname, email: email, password: pwd, isSso: false);

    if (userRegister == 'User Registration Failed') {
      AwesomeDialog(
          context: context,
          animType: AnimType.TOPSLIDE,
          headerAnimationLoop: false,
          dialogType: DialogType.ERROR,
          dismissOnTouchOutside: true,
          title: 'Failed!',
          desc: 'Registration failed\nTry Again',
          onDismissCallback: (_) {
            debugPrint('Dialog Dissmiss from callback');
          }).show();
      registrationProcess = false;
      buttonClicked = false;
      setState(() {});
      Get.back();
    } else {
      registrationProcess = false;
      setState(() {});

      Get.offAll(LandingPage());
    }
  }

  bool _allValid() {
    return eightChars && number && specialChar && upperCaseChar;
  }
}
