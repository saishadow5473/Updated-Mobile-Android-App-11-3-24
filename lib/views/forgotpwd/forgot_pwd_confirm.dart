import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../constants/spKeys.dart';
import '../../new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../new_design/presentation/pages/basicData/functionalities/percentage_calculations.dart';
import '../../new_design/presentation/pages/basicData/models/basic_data.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../repositories/api_repository.dart';
import '../../utils/screenutil.dart';
import 'forgot_pwd_enter.dart';
import '../../widgets/offline_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../new_design/data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';

class ForgotPwdConfirm extends StatefulWidget {
  final tempPwd;

  const ForgotPwdConfirm({Key key, this.tempPwd}) : super(key: key);

  @override
  _ForgotPwdConfirmState createState() => _ForgotPwdConfirmState();
}

class _ForgotPwdConfirmState extends State<ForgotPwdConfirm> {
  String apiToken;
  bool _passwordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool isChecking = false;
  final TextEditingController newPwdController = TextEditingController();
  final TextEditingController confirmPwdController = TextEditingController();
  String pwd;
  String conPwd;
  String email;
  bool eightChars = false;
  bool specialChar = false;
  bool upperCaseChar = false;
  bool number = false;
  bool resetSuccess;
  var tempPwd;
  final Apirepository _apirepository = Apirepository();

  Future<bool> _change({BuildContext context}) async {
    if (specialChar && upperCaseChar && number && eightChars && pwd == conPwd) {
      SnackBar snackBar = const SnackBar(
        content: Text('Password Reset Successful'),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _apirepository
          .userProfileResetPasswordAPI(email: email, newPassword: conPwd, password: widget.tempPwd)
          .then((String value) async {
        SnackBar snackBar1 = const SnackBar(
          content: Text('Password Reset Successful'),
          backgroundColor: Colors.green,
        );
        resetSuccess = true;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool ma = await prefs.setString(SPKeys.email, email);
        bool pa = await prefs.setString(SPKeys.password, conPwd);
        String res = prefs.getString('data');
        Map<dynamic, dynamic> map = json.decode(res);
        // ignore: unrelated_type_equality_checks
        if (ma != 'jotaro' && pa != 'jotaro') {
          // Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => HomeScreen(introDone: true)),
          //     (Route<dynamic> route) => false);
          try {
            SharedPreferences prefs1 = await SharedPreferences.getInstance();

            final vitalDatas = await SplashScreenApiCalls()
                .checkinData(ihlUID: map["User"]["id"], ihlUserToken: map["Token"]);
            prefs1.setString(SPKeys.vitalsData, jsonEncode(vitalDatas));
            print(vitalDatas);
            await MyvitalsApi().vitalDatas(map);
          } catch (e) {
            print(e);
          }

          Get.to(LandingPage());
        }
        ScaffoldMessenger.of(context).showSnackBar(snackBar1);
        return resetSuccess;
      }).catchError((onError) {
        SnackBar snackBar = SnackBar(
          content: Text('Failed to Update Password:$onError'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      resetSuccess = false;
      isChecking = false;
      SnackBar snackBar = const SnackBar(
        content: Text('Enter valid password'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return resetSuccess;
    }
    return resetSuccess;
  }

  String validateCon() {
    if (conPwd != pwd) {
      return 'Both the Passwords do not Match';
    }
    return null;
  }

  String validatePassword(String value) {
    if (!(eightChars && number && specialChar && upperCaseChar) && value.isNotEmpty) {
      return "Password should contain Alphanumeric and Special Characters";
    }
    return null;
  }

  Future<String> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get('data');
    Map res = jsonDecode(data);
    return res['User']['email'];
  }

  getData() async {
    email = await getEmail();
  }

  @override
  void initState() {
    super.initState();
    newPwdController.clear();
    confirmPwdController.clear();
    getData();
  }

  Widget newPwdTextField() {
    return StreamBuilder<String>(
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return TextFormField(
          keyboardType: TextInputType.visiblePassword,
          controller: newPwdController,
          obscureText: !_passwordVisible,
          autofocus: false,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Please Enter Password';
            }
            return null;
          },
          onChanged: (String value) {
            pwd = value;
            eightChars = pwd.length >= 8;
            number = pwd.contains(RegExp(r'\d'), 0);
            upperCaseChar = pwd.contains(RegExp(r'[A-Z]'), 0);
            specialChar = pwd.isNotEmpty && !pwd.contains(RegExp(r'^[\w&.-]+$'), 0);
            if (mounted) {
              setState(() {});
            }
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
            prefixIcon: const Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.lock),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                // Based on passwordVisible state choose the icon
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xff252529),
              ),
              onPressed: () {
                // Update the state i.e. toogle the state of passwordVisible variable
                if (mounted) {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                }
              },
            ),
            labelText: "Type your new password",
            errorText: validatePassword(newPwdController.text),
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(color: Colors.blueGrey)),
          ),
          maxLines: 1,
          style: const TextStyle(fontSize: 16.0),
          textInputAction: TextInputAction.done,
        );
      },
    );
  }

  Widget confirmPwdTextField() {
    return StreamBuilder<String>(
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return TextFormField(
          keyboardType: TextInputType.visiblePassword,
          controller: confirmPwdController,
          autofocus: false,
          obscureText: !_passwordVisible,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Please Enter Password';
            }
            return null;
          },
          onChanged: (String value) {
            if (mounted) {
              setState(() {
                conPwd = value;
              });
            }
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
            prefixIcon: const Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.lock),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                // Based on passwordVisible state choose the icon
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xff252529),
              ),
              onPressed: () {
                // Update the state i.e. toogle the state of passwordVisible variable
                if (mounted) {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                }
              },
            ),
            labelText: "Confirm your new password",
            errorText: validateCon(),
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(color: Colors.blueGrey)),
          ),
          maxLines: 1,
          style: const TextStyle(fontSize: 16.0),
          textInputAction: TextInputAction.done,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: Scaffold(
          backgroundColor: const Color(0xffF4F6FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            title: Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff6D6E71),
                  fontSize: ScUtil().setSp(18),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) => const ForgotPwdEnter())),
            ),
            actions: <Widget>[
              Builder(
                builder: (BuildContext context) {
                  return TextButton(
                    onPressed: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (mounted) {
                        setState(() {
                          isChecking = true;
                        });
                      }
                      if (_formKey.currentState.validate()) {
                        _change(context: context);
                        Future.delayed(const Duration(seconds: 6), () {
                          if (resetSuccess == true) {
                            if (mounted) {
                              setState(() {
                                isChecking = false;
                              });
                            }
                          }
                        });
                      } else {
                        if (mounted) {
                          setState(() {
                            isChecking = false;
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
                    child: Text("Reset",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScUtil().setSp(16),
                        )),
                  );
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 35.0,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Center(
                      child: Text(
                    'Reset your password',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScUtil().setSp(24),
                        color: const Color(0xff6D6E71)),
                  )),
                  const SizedBox(
                    height: 50.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Container(
                      child: Column(
                        children: [
                          newPwdTextField(),
                          const SizedBox(
                            height: 30.0,
                          ),
                          confirmPwdTextField(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                  Builder(
                    builder: (BuildContext context) => Padding(
                      padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                      child: Center(
                        child: SizedBox(
                          height: 60.0,
                          child: GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              Object raw = prefs.get(SPKeys.userData);
                              Object password = prefs.get(SPKeys.password);
                              if (raw == '' || raw == null) {
                                raw = '{}';
                              }
                              Map data = jsonDecode(raw);
                              Map user = data['User'];

                              BasicDataModel basicData;
                              try {
                                basicData = BasicDataModel(
                                  name: '${user['firstName']} ${user['lastName']}',
                                  dob: user.containsKey('dateOfBirth')
                                      ? user['dateOfBirth'].toString()
                                      : null,
                                  gender:
                                      user.containsKey('gender') ? user['gender'].toString() : null,
                                  height: user.containsKey("heightMeters")
                                      ? user["heightMeters"].toString()
                                      : null,
                                  mobile: user.containsKey("mobileNumber")
                                      ? user['mobileNumber'].toString()
                                      : null,
                                  weight: user.containsKey("userInputWeightInKG")
                                      ? user['userInputWeightInKG'].toString()
                                      : null,
                                );

                                final GetStorage box = GetStorage();
                                box.write('BasicData', basicData);
                                PercentageCalculations().checkHowManyFilled();
                                PercentageCalculations().calculatePercentageFilled();
                              } catch (e) {
                                print(e);
                              }
                              FocusScopeNode currentFocus = FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              if (mounted) {
                                setState(() {
                                  isChecking = true;
                                });
                              }
                              if (_formKey.currentState.validate()) {
                                _change(context: context);
                                Future.delayed(const Duration(seconds: 6), () {
                                  if (resetSuccess == true) {
                                    if (mounted) {
                                      setState(() {
                                        isChecking = false;
                                      });
                                    }
                                  }
                                });
                              } else {
                                if (mounted) {
                                  setState(() {
                                    isChecking = false;
                                    _autoValidate = true;
                                  });
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
                                  Center(
                                    child: isChecking == true
                                        ? const CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          )
                                        : Text(
                                            'Reset',
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
                        ),
                      ),
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
}
