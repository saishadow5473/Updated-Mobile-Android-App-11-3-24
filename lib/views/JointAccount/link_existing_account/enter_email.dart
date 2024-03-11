import 'dart:convert';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/views/dietDashboard/profile_screen.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:ihl/widgets/sigin_pwd.dart';
import 'package:ihl/constants/routes.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ihl/constants/api.dart';

final iHLUrl = API.iHLUrl;
final ihlToken = API.ihlToken;

class EnterEmail extends StatefulWidget {
  final Apirepository apiRepository;

  final bool deepLink;

  const EnterEmail({Key key, this.deepLink, this.apiRepository})
      : assert(apiRepository != null),
        super(key: key);
  @override
  _EnterEmailState createState() => _EnterEmailState();
}

class _EnterEmailState extends State<EnterEmail> {
  String apiToken;
  bool userExistR = true;
  bool hasError = false;
  bool isChecking = false;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool emailchar = false;
  bool mobilechar = false;
  final emailController = TextEditingController();
  http.Client _client = http.Client(); //3gb

  Future<bool> userExist() async {
    final response = await _client.get(
      Uri.parse(iHLUrl + '/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (response.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(response.body));
      apiToken = reponseToken.apiToken;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', reponseToken.apiToken);
      final userExits = await _client.get(
        Uri.parse(iHLUrl +
            '/login/emailormobileused?email=' +
            emailController.text +
            '&mobile=&aadhaar='),
        headers: {'ApiToken': reponseToken.apiToken},
      );
      if (userExits.statusCode == 200) {
        var userExistResponse =
            userExits.body.replaceAll(new RegExp(r'[^\w\s]+'), '');
        if (userExistResponse == "You never registered with this Email ID") {
          if (this.mounted) {
            setState(() {
              userExistR = false;
              isChecking = false;
            });
          }
          return userExistR;
        } else {
          if (this.mounted) {
            setState(() {
              userExistR = true;
            });
          }

          var userExistResponse = "User already exist";
          return userExistR;
        }
      } else {
        throw Exception('Authorization Failed');
      }
    }
    return userExistR;
  }

  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
    emailController.addListener(() {
      if (this.mounted) {
        setState(() {
          emailchar = emailController.text.contains(
              RegExp(
                  "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$"),
              0);
          mobilechar = emailController.text
              .contains(RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)'));
        });
      }
    });
  }

  Widget emailTextField() {
    return StreamBuilder<String>(
      builder: (context, snapshot) {
        return TextFormField(
          keyboardType: TextInputType.visiblePassword,
          controller: emailController,
          autocorrect: true,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Your Credentials';
            } else if (!(emailchar) && (!(mobilechar)) && value.isNotEmpty) {
              return "Invalid Credentials";
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.person),
            ),
            labelText: "Email",
            fillColor: Colors.white24,
            border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(15.0),
                borderSide: new BorderSide(color: Colors.blueGrey)),
          ),
          maxLines: 1,
          style: TextStyle(fontSize: 16.0),
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            // title: Text(
            //   'Link Existing Account',
            //   style: TextStyle(
            //     color: Colors.black,
            //     fontFamily: 'Poppins',
            //     fontWeight: FontWeight.bold,
            //     fontSize: ScUtil().setSp(16),
            //   ),
            // ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.JointAccount),
              color: Colors.black,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  if (this.mounted) {
                    setState(() {
                      isChecking = true;
                    });
                  }
                  if (_formKey.currentState.validate()) {
                    userExist();
                    new Future.delayed(new Duration(seconds: 6), () {
                      if (userExistR == true) {
                        if (this.mounted) {
                          setState(() {
                            SpUtil.putString('email', emailController.text);
                            isChecking = false;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPasswordPage(
                                  deepLink: widget.deepLink,
                                ),
                              ),
                            );
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
                      fontSize: ScUtil().setSp(16),
                    )),
                style: TextButton.styleFrom(
                    shape: CircleBorder(
                        side: BorderSide(color: Colors.transparent)),
                    textStyle: TextStyle(color: Color(0xFF19a9e5))),
              ),
            ],
          ),
          backgroundColor: Color(0xffF4F6FA),
          body: Form(
            key: _formKey,
            autovalidateMode:AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 8 * SizeConfig.heightMultiplier,
                  ),
                  Center(
                      child: Text(
                    'Enter Email',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: ScUtil().setSp(26),
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                        height: 1.33,
                        color: Color(0xff6D6E71)),
                  )),
                  SizedBox(
                    height: 10.0,
                  ),
                  // Center(
                  //   child: Text(
                  //     'or Mobile number',
                  //     style: TextStyle(
                  //         fontFamily: 'Poppins',
                  //         fontSize: ScUtil().setSp(26),
                  //         letterSpacing: 0,
                  //         fontWeight: FontWeight.bold,
                  //         height: 1.33,
                  //         color: Color(0xff6D6E71)),
                  //   ),
                  // ),
                  SizedBox(
                    height: 2 * SizeConfig.heightMultiplier,
                  ),
                  Center(
                      child: Text(
                    'Registered Email',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: ScUtil().setSp(15),
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.normal,
                      height: 1.75,
                      color: Color(0xff6D6E71),
                    ),
                  )),
                  // SizedBox(
                  //   height: 1 * SizeConfig.heightMultiplier,
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  //   child: Text(
                  //     AppTexts.familysubtxt,
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //         color: Color.fromRGBO(109, 110, 113, 1),
                  //         fontFamily: 'Poppins',
                  //         fontSize: ScUtil().setSp(13),
                  //         letterSpacing: 0.2,
                  //         fontWeight: FontWeight.normal,
                  //         height: 1),
                  //   ),
                  // ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Container(
                      child: Column(
                        children: [
                          emailTextField(),
                          SizedBox(
                            height: 2 * SizeConfig.heightMultiplier,
                          ),
                          userExistR == false
                              ? Column(children: [
                                  RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Uh-ho! Looks like you haven\'t registered!',
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
                                              fontSize: ScUtil().setSp(12),
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Register Here!',
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: 16,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () =>
                                                  Navigator.of(context)
                                                      .pushNamed(Routes.Cname),
                                          ),
                                        ],
                                      ))
                                ])
                              : SizedBox(
                                  height: 1 * SizeConfig.heightMultiplier)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 4 * SizeConfig.heightMultiplier,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    child: Center(
                      child: Container(
                        height: 60.0,
                        child: GestureDetector(
                          onTap: () {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            if (this.mounted) {
                              setState(() {
                                isChecking = true;
                              });
                            }

                            if (_formKey.currentState.validate()) {
                              userExist();

                              new Future.delayed(new Duration(seconds: 6), () {
                                if (userExistR == true) {
                                  if (this.mounted) {
                                    setState(() {
                                      SpUtil.putString(
                                          'email', emailController.text);
                                      isChecking = false;
                                    });
                                  }
                                }
                              });
                              Get.snackbar(
                                'Hi',
                                'Confirmation mail has been sent to ${emailController.text}',
                                margin: EdgeInsets.only(
                                    top: 20, left: 20, right: 20),
                                backgroundColor: AppColors.primaryAccentColor,
                                colorText: Colors.white,
                                duration: Duration(seconds: 5),
                              );
                              new Future.delayed(new Duration(seconds: 8), () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(),
                                  ),
                                );
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        )
                                      : Text(
                                          'Send',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
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
