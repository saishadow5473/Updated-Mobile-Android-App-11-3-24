import 'dart:convert';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import '../../constants/api.dart';
import '../../repositories/api_repository.dart';
import '../../utils/SpUtil.dart';
import '../../utils/screenutil.dart';
import '../../utils/sizeConfig.dart';
import 'forgot_password_screen.dart';
import 'forgot_pwd_confirm.dart';
import '../../widgets/offline_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../new_design/app/utils/localStorageKeys.dart';
import '../../new_design/presentation/pages/spalshScreen/splashScreen.dart';

final String iHLUrl = API.iHLUrl;
final String ihlToken = API.ihlToken;

class ForgotPwdEnter extends StatefulWidget {
  const ForgotPwdEnter({Key key}) : super(key: key);

  @override
  _ForgotPwdEnterState createState() => _ForgotPwdEnterState();
}

class _ForgotPwdEnterState extends State<ForgotPwdEnter> {
  final http.Client _client = http.Client(); //3gb
  var temp;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final TextEditingController tempPwdController = TextEditingController();
  bool isLoading = false;
  bool isPwdCorrect;

  Future<bool> authenticate(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = SpUtil.getString('email');
    Object authToken = prefs.get('auth_token');
    final http.Response response1 = await _client.post(
      Uri.parse('$iHLUrl/login/qlogin2'),
      headers: {'Content-Type': 'application/json', 'ApiToken': authToken},
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    if (response1.statusCode == 200) {
      if (response1.body == 'null') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('data', '');
        if (mounted) {
          setState(() {
            isPwdCorrect = false;
            isLoading = false;
          });
        }
        return isPwdCorrect;
      } else {
        if (mounted) {
          setState(() {
            isPwdCorrect = true;
          });
        }
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('data', response1.body);
        prefs.setString('password', password);
        prefs.setString('email', email);
        localSotrage.write(LSKeys.email, email);
        if (mounted) {
          setState(() {
            isLoading = false;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ForgotPwdConfirm(tempPwd: tempPwdController.text)));
          });
        }

        var decodedResponse = jsonDecode(response1.body);
        String iHLUserToken = decodedResponse['Token'];
        String iHLUserId = decodedResponse['User']['id'];

        return isPwdCorrect;
      }
    } else {
      throw Exception('Authorization Failed');
    }
  }

  Widget tempPwdTextField() {
    return StreamBuilder<String>(
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return TextFormField(
          keyboardType: TextInputType.visiblePassword,
          controller: tempPwdController,
          autocorrect: true,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Please enter the credential';
            }
            return null;
          },
          onChanged: (String val) {
            final String trimVal = val.trim();
            if (val != trimVal) if (mounted) {
              setState(() {
                tempPwdController.text = trimVal;
                temp = tempPwdController.text;
                tempPwdController.selection =
                    TextSelection.fromPosition(TextPosition(offset: trimVal.length));
              });
            }
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            prefixIcon: const Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.lock),
            ),
            labelText: "Temporary password",
            fillColor: Colors.white24,
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
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ForgotPasswordPage(apiRepository: Apirepository()))),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  if (mounted) {
                    setState(() {
                      isLoading = true;
                    });
                  }
                  if (_formKey.currentState.validate()) {
                    authenticate(tempPwdController.text);
                    Future.delayed(const Duration(seconds: 6), () {
                      if (isPwdCorrect == true) {
                        if (mounted) {
                          setState(() {
                            SpUtil.putString('email', tempPwdController.text);
                            isLoading = false;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => const ForgotPwdConfirm()));
                          });
                        }
                      }
                    });
                  } else {
                    if (mounted) {
                      setState(() {
                        isLoading = false;
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
                child: Text("Next",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScUtil().setSp(16),
                    )),
              ),
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
                    'Input the temporary',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScUtil().setSp(24),
                        color: const Color(0xff6D6E71)),
                  )),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Center(
                      child: Text(
                    'password received',
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
                          tempPwdTextField(),
                          isPwdCorrect == false
                              ? Text(
                                  'Temporary Password Entered is Incorrect',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: ScUtil().setSp(12),
                                  ),
                                )
                              : SizedBox(height: 1 * SizeConfig.heightMultiplier),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    child: Center(
                      child: SizedBox(
                        height: 60.0,
                        child: GestureDetector(
                          onTap: () async {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            if (mounted) {
                              setState(() {
                                isLoading = true;
                              });
                            }
                            if (_formKey.currentState.validate()) {
                              authenticate(tempPwdController.text);
                              Future.delayed(const Duration(seconds: 6), () {
                                if (isPwdCorrect == true) {
                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              });
                            } else {
                              if (mounted) {
                                setState(() {
                                  isLoading = false;
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
                                  child: isLoading == true
                                      ? const CircularProgressIndicator(
                                          valueColor:
                                              const AlwaysStoppedAnimation<Color>(Colors.white),
                                        )
                                      : Text(
                                          'Continue',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
