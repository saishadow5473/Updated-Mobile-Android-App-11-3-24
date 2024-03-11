import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/views/JointAccount/joint_account_api_repo/joint_acc_register_api.dart';
import 'package:ihl/widgets/image_picker_handler.dart';
import 'package:ihl/repositories/api_register.dart';
import 'package:flutter/gestures.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ihl/widgets/offline_widget.dart';

String jFname, jLname, jEmail, jPwd, jMobile, jDob, jGender, jHeight, jWeight;

class CreateSignupPic extends StatefulWidget {
  @override
  _CreateSignupPicState createState() => _CreateSignupPicState();
}

class _CreateSignupPicState extends State<CreateSignupPic>
    with TickerProviderStateMixin, ImagePickerListener {
  Future<bool> jEmailGiven = SpUtil.putBool(SPKeys.jEmailGiven, true);
  Future<bool> jMobileGiven = SpUtil.putBool(SPKeys.jMobileGiven, true);
  int _index = 0;
  List<String> emoji = [
    'https://cdn.shopify.com/s/files/1/1061/1924/products/Happy_Emoji_Icon_5c9b7b25-b215-4457-922d-fef519a08b06_large.png',
    'https://cdn.shopify.com/s/files/1/1061/1924/products/Emoji_Icon_-_Sunglasses_cool_emoji_large.png',
    'https://cdn.shopify.com/s/files/1/1061/1924/products/Emoji_Icon_-_Smiling_large.png',
    'https://cdn.shopify.com/s/files/1/1061/1924/products/Heart_Eyes_Emoji_2_large.png',
    'https://cdn.shopify.com/s/files/1/1061/1924/products/Tongue_Out_Emoji_3_large.png?v=1571606093',
    'https://cdn.shopify.com/s/files/1/1061/1924/products/Smiling_With_Sweat_Emoji_2_03db33ba-4c3b-4e9e-8f29-8bac5b9b9166_large.png'
  ];
  List<Object> myList = ['😁', '😎', '😃', '😍', '😛', '😅'];
  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;
  var jUserReg;
  var jUserRegister;
  bool isloading;
  bool done;
  http.Client _client = http.Client(); //3gb

  void _initAsync() async {
    await SpUtil.getInstance();
  }

  Future<String> networkImageToBase64(String imageUrl) async {
    http.Response response = await _client.get(
      Uri.parse(imageUrl),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    final bytes = response?.bodyBytes;
    return (bytes != null ? base64Encode(bytes) : null);
  }

  void _imgupload(File image) async {
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      String img64 = base64Encode(bytes);
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 100,
                child: Center(
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      new CircularProgressIndicator(),
                      SizedBox(
                        width: 10,
                      ),
                      new Text("Processing... Please wait"),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        jUserRegister = await JointAccountRegisterUserWithPic().jointAccountRegisterUser(
            jFirstName: jFname,
            jLastName: jLname,
            jEmail: jEmail,
            jPassword: jPwd,
            jMobileNumber: jMobile,
            jGender: jGender,
            jDob: jDob,
            jHeight: jHeight,
            jWeight: jWeight,
            jProfilepic: img64);
        if (jUserRegister == 'User Registration Failed') {
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
        } else if (jUserRegister == 'Photo upload Failed') {
          Navigator.pop(context);
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: false,
              dialogType: DialogType.INFO,
              dismissOnTouchOutside: true,
              title: 'Unable to upload profile picture. Please try again.',
              desc:
                  'Your Registration was Success!\nBut Profile Picture wasn\'t Uploaded!\nTry Again in Profile section!',
              btnOkText: 'Continue',
              btnOkColor: Color(0xFF19a9e5),
              btnOkOnPress: () {
                // Navigator.of(context).pushReplacementNamed(Routes.CProceed);
                if (jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty) {
                  // Navigator.of(context).pushReplacementNamed(Routes.Home);
                  Get.off(LandingPage());
                } else {
                  Navigator.of(context).pushReplacementNamed(Routes.CProceed);
                }
                debugPrint('OnClcik');
              },
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        } else {
          Navigator.pop(context);
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: true,
              dialogType: DialogType.SUCCES,
              dismissOnTouchOutside: false,
              title: 'Success!',
              desc: 'Your hCare registration has been successfully completed.',
              btnOkOnPress: () {
                // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                if (jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty) {
                  Navigator.of(context).pushReplacementNamed(Routes.CProceed);
                } else {
                  // Navigator.of(context).pushReplacementNamed(Routes.Home);
                  Get.off(LandingPage());
                }
                debugPrint('OnClcik');
              },
              btnOkText: 'Proceed',
              btnOkIcon: Icons.check_circle,
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        }
      } catch (error) {
        print(error);
      }
    } else if (image == null) {
      final img64 = await networkImageToBase64(emoji[_index]);
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 100,
                child: Center(
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      new CircularProgressIndicator(),
                      SizedBox(
                        width: 10,
                      ),
                      new Text("Processing... Please wait"),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        jUserRegister = await JointAccountRegisterUserWithPic().jointAccountRegisterUser(
            jFirstName: jFname,
            jLastName: jLname,
            jEmail: jEmail,
            jPassword: jPwd,
            jMobileNumber: jMobile,
            jGender: jGender,
            jDob: jDob,
            jHeight: jHeight,
            jWeight: jWeight,
            jProfilepic: img64);
        if (jUserRegister == 'User Registration Failed') {
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
        } else if (jUserRegister == 'Photo upload Failed') {
          Navigator.pop(context);
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: false,
              dialogType: DialogType.INFO,
              dismissOnTouchOutside: true,
              title: 'Unable to upload profile picture. Please try again.',
              desc:
                  'Your Registration was Success!\nBut Profile Picture wasn\'t Uploaded!\nTry Again in Profile section!',
              btnOkText: 'Continue',
              btnOkColor: Color(0xFF19a9e5),
              btnOkOnPress: () {
                // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                if (jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty) {
                  Navigator.of(context).pushReplacementNamed(Routes.CProceed);
                } else {
                  // Navigator.of(context).pushReplacementNamed(Routes.Home);
                  Get.off(LandingPage());
                }
                debugPrint('OnClcik');
              },
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        } else {
          Navigator.pop(context);
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: true,
              dialogType: DialogType.SUCCES,
              dismissOnTouchOutside: false,
              title: 'Success!',
              desc: 'Your hCare registration has been successfully completed.',
              btnOkOnPress: () {
                // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                if (jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty) {
                  Navigator.of(context).pushReplacementNamed(Routes.CProceed);
                } else {
                  // Navigator.of(context).pushReplacementNamed(Routes.Home);
                  Get.off(LandingPage());
                }
                debugPrint('OnClcik');
              },
              btnOkText: 'Proceed',
              btnOkIcon: Icons.check_circle,
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        }
      } catch (error) {
        print(error);
      }
    } else {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 100,
                child: Center(
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      new CircularProgressIndicator(),
                      SizedBox(
                        width: 10,
                      ),
                      new Text("Processing... Please wait"),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        jUserReg = await JointAccountRegisterUser().jointAccountRegisterUser(
          jFirstName: jFname,
          jLastName: jLname,
          jEmail: jEmail,
          jPassword: jPwd,
          jMobileNumber: jMobile,
          jGender: jGender,
          jDob: jDob,
          jHeight: jHeight,
          jWeight: jWeight,
        );
        if (jUserReg == 'User Registration Failed') {
          Navigator.pop(context);
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: false,
              dialogType: DialogType.ERROR,
              dismissOnTouchOutside: true,
              title: 'Failed!',
              desc: 'Registration failed\nTry Again!',
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        } else {
          Navigator.pop(context);
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: true,
              dialogType: DialogType.SUCCES,
              dismissOnTouchOutside: false,
              title: 'Success!',
              desc: 'Your hCare registration has been successfully completed.',
              btnOkOnPress: () {
                // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                if (jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty) {
                  Navigator.of(context).pushReplacementNamed(Routes.CProceed);
                } else {
                  // Navigator.of(context).pushReplacementNamed(Routes.Home);
                  Get.off(LandingPage());
                }
                debugPrint('OnClcik');
              },
              btnOkText: 'Proceed',
              btnOkIcon: Icons.check_circle,
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        }
      } catch (error) {
        print(error);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
    jFname = SpUtil.getString('jFname');
    jLname = SpUtil.getString('jLname');
    jEmail = SpUtil.getString('jEmail');
    jPwd = SpUtil.getString('jPwd');
    jMobile = SpUtil.getString('jMobile').toString();
    jDob = SpUtil.getString('jDob');
    jGender = SpUtil.getString('jGender');
    jHeight = SpUtil.getString('jHeight');
    jWeight = SpUtil.getString('jWeight');

    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = new ImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: false);
    Widget _customButton() {
      return Container(
        height: 60,
        child: GestureDetector(
          onTap: () {
            _imgupload(_image);
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
                    'Sign Up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontFamily: 'Poppins',
                        fontSize: 16,
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
            title: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 5,
                  child: LinearProgressIndicator(
                    value: 1, // percent filled
                    backgroundColor: Color(0xffDBEEFC),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pushNamed(Routes.Cweight),
              // Navigator.of(context).pushNamed(Routes.Aff),
              color: Colors.black,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Navigator.of(context).pushNamed(Routes.CProceed),
                  if (jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty) {
                    Navigator.of(context).pushReplacementNamed(Routes.CProceed);
                  } else {
                    // Navigator.of(context).pushReplacementNamed(Routes.Home);
                    Get.off(LandingPage());
                  }
                },
                child: Text("Next",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: ScUtil().setSp(16),
                    )),
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    color: Color(0xFF19a9e5),
                  ),
                  shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xffF4F6FA),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color.fromRGBO(244, 246, 250, 1), Color.fromRGBO(255, 255, 255, 1)],
              ),
            ),
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'One more step . . .',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF19a9e5),
                        fontFamily: 'Poppins',
                        fontSize: ScUtil().setSp(12),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        height: 1.16),
                  ),
                  SizedBox(
                    height: 5 * SizeConfig.heightMultiplier,
                  ),
                  Text(
                    'Choose your\n Profile Picture',
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
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                  //   child: Text(
                  //     'Customise your profile !',
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
                  // SizedBox(
                  //   height: 1 * SizeConfig.heightMultiplier,
                  // ),
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
                          height: 1),
                    ),
                  ),
                  SizedBox(
                    height: 4 * SizeConfig.heightMultiplier,
                  ),
                  _image != null
                      ? Stack(children: <Widget>[
                          CircleAvatar(
                            radius: 80,
                            backgroundColor: Color(0xFF19a9e5),
                            child: CircleAvatar(
                              radius: 75,
                              backgroundImage: FileImage(_image),
                            ),
                          ),
                          Positioned(
                              left: 110,
                              top: 0,
                              child: ClipOval(
                                child: Material(
                                  elevation: 6,
                                  color: Colors.white, // button color
                                  child: InkWell(
                                      splashColor: Colors.red, // inkwell color
                                      child: SizedBox(
                                          child: Icon(
                                        Icons.cancel,
                                        size: 36,
                                        color: Colors.red,
                                      )),
                                      onTap: () => {
                                            if (this.mounted)
                                              {
                                                setState(() {
                                                  this._image = null;
                                                }),
                                              },
                                          }),
                                ),
                              ))
                        ])
                      : SizedBox(
                          height: 150,
                          width: 300, // card height
                          child: PageView.builder(
                            itemCount: myList.length,
                            controller: PageController(viewportFraction: 0.5),
                            onPageChanged: (int index) => setState(() => _index = index),
                            itemBuilder: (_, int index) {
                              return Transform.scale(
                                scale: index == _index ? 1 : 0.8,
                                child: Card(
                                  color: index == _index ? Color(0xFF19a9e5) : Colors.white,
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Center(
                                    child: Text(
                                      myList[index],
                                      style: TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(height: 4 * SizeConfig.heightMultiplier),
                  _image != null
                      ? RichText(
                          text: TextSpan(
                          text: 'Change Picture',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: ScUtil().setSp(16),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => imagePicker.showDialog(context),
                        ))
                      : RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Or Upload Custom Picture',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: ScUtil().setSp(16),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => imagePicker.showDialog(context),
                              ),
                            ],
                          ),
                        ),
                  SizedBox(
                    height: 4 * SizeConfig.heightMultiplier,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    child: Center(
                      child: _customButton(),
                    ),
                  ),
                  SizedBox(
                    height: 2 * SizeConfig.heightMultiplier,
                  ),
                  RichText(
                      text: TextSpan(
                    text: 'Skip and Sign Up!',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: ScUtil().setSp(16),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Container(
                                height: 100,
                                child: Center(
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      new CircularProgressIndicator(),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      new Text("Processing... Please wait"),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                        jUserReg = await JointAccountRegisterUser().jointAccountRegisterUser(
                          jFirstName: jFname,
                          jLastName: jLname,
                          jEmail: jEmail,
                          jPassword: jPwd,
                          jMobileNumber: jMobile,
                          jGender: jGender,
                          jDob: jDob,
                          jHeight: jHeight,
                          jWeight: jWeight,
                        );
                        if (jUserReg == 'User Registration Failed') {
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
                        } else {
                          Navigator.pop(context);
                          AwesomeDialog(
                              context: context,
                              animType: AnimType.TOPSLIDE,
                              headerAnimationLoop: true,
                              dialogType: DialogType.SUCCES,
                              dismissOnTouchOutside: false,
                              title: 'Success!',
                              desc: 'Your hCare registration has been successfully completed.',
                              btnOkOnPress: () {
                                // Navigator.of(context)
                                //     .pushReplacementNamed(Routes.SProceed);

                                if (jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty) {
                                  // Navigator.of(context).pushReplacementNamed(Routes.Home);
                                  Get.off(LandingPage());
                                } else {
                                  Navigator.of(context).pushReplacementNamed(Routes.CProceed);
                                }

                                debugPrint('OnClcik');
                              },
                              btnOkText: 'Proceed',
                              btnOkIcon: Icons.check_circle,
                              onDismissCallback: (_) {
                                debugPrint('Dialog Dissmiss from callback');
                              }).show();
                        }
                      },
                  )),
                  SizedBox(
                    height: 4 * SizeConfig.heightMultiplier,
                  ),
                  Text(
                    'By Signing Up,\n You Accept the Terms and Conditions of IHL Pvt. Ltd',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: ScUtil().setSp(10),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.normal,
                        height: 1.1),
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
  userImage(File _image) {
    if (this.mounted) {
      setState(() {
        this._image = _image;
      });
    }
  }
}
