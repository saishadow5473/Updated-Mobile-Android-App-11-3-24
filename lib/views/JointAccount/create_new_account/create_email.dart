import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ihl/models/models.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/views/JointAccount/create_new_account/create_mobile_number.dart';
import 'package:ihl/views/JointAccount/create_new_account/create_password.dart';
import 'package:ihl/widgets/offline_widget.dart';

final iHLUrl = API.iHLUrl;
final ihlToken = API.ihlToken;

class CreateEmail extends StatefulWidget {
  static const id = '/create_email';
  final Apirepository apiRepository;

  CreateEmail({Key key, @required this.apiRepository})
      : assert(apiRepository != null),
        super(key: key);

  @override
  _CreateEmailState createState() => _CreateEmailState();
}

class _CreateEmailState extends State<CreateEmail> {
  String apiToken;
  bool jUserExistR = false;
  http.Client _client = http.Client(); //3gb

  Future<bool> jUserExist() async {
    final response = await _client.get(
      Uri.parse(
          'https://azureapi.indiahealthlink.com/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (response.statusCode == 200) {
      JointAccountSignup reponseToken =
          JointAccountSignup.fromJson(json.decode(response.body));
      apiToken = reponseToken.apiToken;
      final jUserExits = await _client.get(
        Uri.parse(iHLUrl +
            '/login/emailormobileused?email=' +
            _jEmailController.text +
            '&mobile=&aadhaar='),
        headers: {'ApiToken': reponseToken.apiToken},
      );
      if (jUserExits.statusCode == 200) {
        var jUserExistResponse =
            jUserExits.body.replaceAll(new RegExp(r'[^\w\s]+'), '');
        if (jUserExistResponse == "You never registered with this Email ID") {
          jUserExistR = false;
          return jUserExistR;
        } else {
          if (this.mounted) {
            setState(() {
              jUserExistR = true;
              isChecking = false;
            });
          }
          // ignore: unused_local_variable
          var jUserExistResponse = "User already exist";
          return jUserExistR;
        }
      } else {
        throw Exception('Authorization Failed');
      }
    }
    return jUserExistR;
  }

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool isChecking = false;
  FocusNode emailFocusNode;
  bool emailchar = false;
  final _jEmailController = TextEditingController();
  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    emailFocusNode = FocusNode();
    _initAsync();
    _jEmailController.addListener(() {
      if (this.mounted) {
        setState(() {
          emailchar = _jEmailController.text.contains(
              RegExp(
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$'),
              0);
        });
      }
    });
  }

  Widget emailTextField() {
    return StreamBuilder<String>(
      builder: (context, snapshot) {
        return TextFormField(
          keyboardType: TextInputType.visiblePassword,
          controller: _jEmailController,
          autocorrect: true,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Your Credentials';
              // return null;
            } else if (!(emailchar)) {
              return "Invalid Email";
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.email),
            ),
            labelText: "E-mail address.. (Optional)",
            hintText: 'johndoe@example.com',
            fillColor: Colors.white24,
            border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(15.0),
                borderSide: new BorderSide(color: Colors.blueGrey)),
          ),
          maxLines: 1,
          style: TextStyle(
            fontSize: ScUtil().setSp(16),
          ),
          focusNode: emailFocusNode,
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
      child: SafeArea(
        top: true,
        child: ConnectivityWidgetWrapper(
          disableInteraction: true,
          offlineWidget: OfflineWidget(),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              title: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 5,
                    child: LinearProgressIndicator(
                      value: 0.25, // percent filled
                      backgroundColor: Color(0xffDBEEFC),
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pushNamed(Routes.Cname),
                // onPressed: () => Get.back(),
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
                    if (_jEmailController.text.isNotEmpty) {
                      if (_formKey.currentState.validate()) {
                        jUserExist();
                        new Future.delayed(new Duration(seconds: 6), () {
                          if (jUserExistR == false) {
                            if (this.mounted) {
                              setState(() {
                                SpUtil.putString(
                                    SPKeys.jEmail, _jEmailController.text);
                                SpUtil.putBool(SPKeys.jEmailGiven, true);
                                isChecking = false;
                                // Navigator.of(context).pushNamed(Routes.Spwd);
                                // navigate to nxt page
                                Get.to(
                                  CreatePwd(),
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
                    } else {
                      setState(() {
                        isChecking = false;
                      });
                      SpUtil.putBool(SPKeys.jEmailGiven, false);
                      Get.to(
                        CreateMob(apiRepository: widget.apiRepository),
                      );
                    }
                  },
                  child: Text(AppTexts.next,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      color: Color(0xFF19a9e5),
                    ),
                    shape: CircleBorder(
                        side: BorderSide(color: Colors.transparent)),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xffF4F6FA),
            body: Form(
              key: _formKey,
              // autovalidateMode:AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 5.0),
                    Text(
                      AppTexts.step2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.primaryAccentColor,
                          fontFamily: 'Poppins',
                          fontSize: ScUtil().setSp(12),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                          height: 1.1),
                    ),
                    SizedBox(
                      height: 8 * SizeConfig.heightMultiplier,
                    ),
                    Text(
                      AppTexts.email,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromRGBO(109, 110, 113, 1),
                          fontFamily: 'Poppins',
                          fontSize: ScUtil().setSp(26),
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                          height: 1.33),
                    ),
                    // SizedBox(
                    //   height: 3 * SizeConfig.heightMultiplier,
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    //   child: Text(
                    //     AppTexts.sub2,
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //         color: Color.fromRGBO(109, 110, 113, 1),
                    //         fontFamily: 'Poppins',
                    //         fontSize: ScUtil().setSp(15),
                    //         letterSpacing: 0.2,
                    //         fontWeight: FontWeight.normal,
                    //         height: 1),
                    //   ),
                    // ),
                    SizedBox(
                      height: 3 * SizeConfig.heightMultiplier,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                      child: Text(
                        AppTexts.familysubtxt,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(109, 110, 113, 1),
                            fontFamily: 'Poppins',
                            fontSize: ScUtil().setSp(13),
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.normal,
                            height: 1.2),
                      ),
                    ),
                    SizedBox(
                      height: 4 * SizeConfig.heightMultiplier,
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
                            jUserExistR == true
                                ? Column(children: [
                                    RichText(
                                        text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              'Looks like you already registered!',
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
                                          // text: 'Login Here!',
                                          text: 'Link Your Account Here!',
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () =>
                                                Navigator.of(context).pushNamed(
                                                    Routes.Eemail,
                                                    arguments: false),
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
                          height: 60,
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
                              if (_jEmailController.text.isNotEmpty) {
                                if (_formKey.currentState.validate()) {
                                  jUserExist();
                                  new Future.delayed(new Duration(seconds: 6),
                                      () {
                                    if (jUserExistR == false) {
                                      if (this.mounted) {
                                        setState(() {
                                          SpUtil.putString('jEmail',
                                              _jEmailController.text ?? '');
                                          // SpUtil.putBool('jEmailGiven', true);
                                          isChecking = false;
                                          Get.to(
                                            CreatePwd(),
                                          );
                                          //navigate to nxt page
                                          // Navigator.of(context)
                                          //     .pushNamed(Routes.Spwd);
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
                              } else {
                                SpUtil.putBool(SPKeys.jEmailGiven, false);
                                // SpUtil.putString(
                                //     'jEmail', _emailController.text);
                                // setState(() {
                                //   isChecking = false;
                                // });
                                Get.to(
                                  CreateMob(
                                    apiRepository: widget.apiRepository,
                                  ),
                                );
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
                                            'Continue',
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
      ),
    );
  }
}
