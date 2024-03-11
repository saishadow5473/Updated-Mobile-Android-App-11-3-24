import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../repositories/api_register.dart';
import '../../constants/routes.dart';
import '../../constants/app_texts.dart';
import '../../utils/SpUtil.dart';
import '../../utils/ScUtil.dart';
import '../../utils/sizeConfig.dart';
import '../../widgets/offline_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../new_design/presentation/pages/home/landingPage.dart';

class SignupNameSso extends StatefulWidget {
  const SignupNameSso({Key key, this.title, this.ssoToken}) : super(key: key);

  final String title, ssoToken;

  @override
  _SignupNameSsoState createState() => _SignupNameSsoState();
}

class _SignupNameSsoState extends State<SignupNameSso> {
  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();
  FocusNode fnameFocusNode;
  FocusNode lnameFocusNode;
  // Special Character check
  final _specialCharacterPattern = RegExp(r'^[a-zA-Z0-9 ]+$');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool registrationProgress = false;
  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    fnameFocusNode = FocusNode();
    lnameFocusNode = FocusNode();
    _initAsync();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    Widget _customButton() {
      return SizedBox(
        height: 60,
        child: GestureDetector(
          onTap: () async {
            registrationProgress = true;
            setState(() {});
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            if (_formKey.currentState.validate()) {
              SpUtil.putString('fname', fnameController.text);
              SpUtil.putString('lname', lnameController.text);
              String userRegister = await RegisterUserWithPic().registerUser(
                  firstName: fnameController.text,
                  lastName: lnameController.text,
                  email: '',
                  password: '',
                  // mobileNumber: mobile,
                  // gender: gender,
                  // dob: dob,
                  // height: height,
                  // weight: weight,
                  // profilepic: img64,
                  isSso: true,
                  ssoToken: widget.ssoToken);
              if (userRegister == 'User Registration Failed') {
                Navigator.pop(context);
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
                registrationProgress = true;
                setState(() {});
              } else {
                Get.off(LandingPage());
                registrationProgress = true;
                setState(() {});
              }
            } else {
              if (mounted) {
                setState(() {
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
                registrationProgress
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
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
              //         value: 0.25, // percent filled
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
                        SpUtil.putString('fname', fnameController.text);
                        SpUtil.putString('lname', lnameController.text);
                        Navigator.of(context).pushNamed(Routes.Spwd);
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
                    child: const Text(AppTexts.next,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
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
                    const SizedBox(
                      height: 5.0,
                    ),
                    // Text(
                    //   AppTexts.step2,
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //       color: Color(0xFF19a9e5),
                    //       fontFamily: 'Poppins',
                    //       fontSize: ScUtil().setSp(12),
                    //       letterSpacing: 1.5,
                    //       fontWeight: FontWeight.bold,
                    //       height: 1.1),
                    // ),
                    SizedBox(
                      height: 2 * SizeConfig.heightMultiplier,
                    ),
                    Text(
                      AppTexts.email,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                      child: Text(
                        AppTexts.sub2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color.fromRGBO(109, 110, 113, 1),
                            fontFamily: 'Poppins',
                            fontSize: ScUtil().setSp(15),
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.normal,
                            height: 1.75),
                      ),
                    ),
                    SizedBox(
                      height: 6 * SizeConfig.heightMultiplier,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Container(
                          child: TextFormField(
                            keyboardType: TextInputType.visiblePassword,
                            controller: fnameController,
                            focusNode: fnameFocusNode,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Please Enter Your First Name';
                              } else if (!(value.length >= 3)) {
                                return "Min. 3 Characters Required";
                              }
                              if (_specialCharacterPattern.hasMatch(value)) {
                                return null;
                              } else {
                                return 'Special characters are not allowed';
                              }
                              return null;
                            },
                            autofocus: false,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(lnameFocusNode);
                            },
                            textInputAction: TextInputAction.next,
                            style: TextStyle(
                              fontSize: ScUtil().setSp(16),
                            ),
                            decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 17.0, horizontal: 15.0),
                                labelText: "First Name",
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: const BorderSide(color: Colors.blueGrey))),
                          ),
                        )),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: lnameController,
                          focusNode: lnameFocusNode,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Please enter your Last Name!';
                            } else if (!(value.length >= 3)) {
                              return "Min. 3 Characters Required";
                            }
                            if (_specialCharacterPattern.hasMatch(value)) {
                              return null;
                            } else {
                              return 'Special characters are not allowed';
                            }
                            return null;
                          },
                          style: TextStyle(
                            fontSize: ScUtil().setSp(16),
                          ),
                          decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 17.0, horizontal: 15.0),
                              labelText: "Last Name",
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: const BorderSide(color: Colors.blueGrey))),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 6 * SizeConfig.heightMultiplier,
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
      ),
    );
  }
}
