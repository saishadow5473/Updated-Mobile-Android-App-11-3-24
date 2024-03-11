import 'dart:convert';
import 'package:crisp/crisp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AskUsScreen extends StatefulWidget {
  AskUsScreen({Key key}) : super(key: key);

  @override
  State<AskUsScreen> createState() => _AskUsScreenState();
}

class _AskUsScreenState extends State<AskUsScreen> {
  CrispMain crispMain;
  bool _isLoading = true;
  @override
  Future<void> initState() {
    super.initState();
    setValue();
  }

  setValue() async {
    crispMain = CrispMain(
      websiteId: 'cd2470a0-af57-46ef-9e05-8441dd73e827',
      locale: 'en',
    );
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var raw = prefs.get(SPKeys.userData);
      if (raw == '' || raw == null) {
        raw = '{}';
      }
      Map data = jsonDecode(raw);
      Map user = data['User'];
      user ??= {};
      if (user == {} || user == "" || user == null) {
        crispMain.register(
          user: CrispUser(
            email: "user@gmail.com",
            avatar: 'https://avatars2.githubusercontent.com/u/16270189?s=200&v=4',
            nickname: "IHL USER",
            phone: "000000000",
          ),
        );
      } else {
        var name = user['firstName'];
        var email = user['email'];
        var phnNUmber = user['mobileNumber'];
        var photo = 'https://avatars2.githubusercontent.com/u/16270189?s=200&v=4';
        crispMain.register(
          user: CrispUser(
            email: email,
            avatar: photo,
            nickname: name,
            phone: phnNUmber,
          ),
        );
        crispMain.userToken = email;
      }
    } catch (e) {
      crispMain.register(
        user: CrispUser(
          email: "user@gmail.com",
          avatar: 'https://avatars2.githubusercontent.com/u/16270189?s=200&v=4',
          nickname: "IHL USER",
          phone: "000000000",
        ),
      );
    }

    crispMain.setMessage("Hello");

    crispMain.setSessionData({
      "order_id": "11231",
      "app_version": "0.1.1",
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => HomeScreen(
          //             introDone: true,
          //           )),
          //   (Route<dynamic> route) => false);
          Get.back();
        },
        child: SafeArea(
          child: Scaffold(
            body: Container(
              color: AppColors.bgColorTab,
              child: Column(
                children: <Widget>[
                  CustomPaint(
                    painter: BackgroundPainter(
                        primary: Color(0xff0157cd), secondary: Color(0xff0157cd).withOpacity(0.7)
                        //secondary: Color(0xff0157cd).withOpacity(0.0),
                        ),
                    child: Container(),
                  ),
                  Container(
                    child: Column(
                      children: [
                        AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0.0,
                          leading: IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              // Navigator.pushAndRemoveUntil(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => HomeScreen(introDone: true)),
                              //       (Route<dynamic> route) => false);
                              Get.back();
                            },
                            color: Colors.white,
                            tooltip: 'Back',
                          ),
                          title: Text(
                            'Ask IHL',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: ScUtil().setSp(26),
                              color: Colors.white,
                            ),
                          ),
                          centerTitle: true,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Container(
                            child: _isLoading
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : CrispView(
                                    crispMain: crispMain,
                                    clearCache: false,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
