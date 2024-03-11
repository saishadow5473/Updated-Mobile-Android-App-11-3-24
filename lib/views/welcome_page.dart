import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:ihl/abha/networks/network_calls_abha.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_text_styles.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/signin_email.dart';
import 'onboard.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key key, this.deepLink}) : super(key: key);

  final bool deepLink;

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    abhaSkipped = true;
    super.initState();
  }

  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    Widget _customButton() {
      return Container(
        height: 60.0,
        child: GestureDetector(
          onTap: () async {
            // Navigator.of(context).pushNamed(Routes.Onboard);
            final prefs = await SharedPreferences.getInstance();
            prefs.clear();
            SpUtil.clear();
            localSotrage.erase();
            Get.to(GooeyCarousel());
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
                    AppTexts.newuser,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontFamily: 'Poppins',
                        fontSize: ScUtil().setSp(18),
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.bold,
                        height: 1),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color.fromRGBO(244, 246, 250, 1), Color.fromRGBO(255, 255, 255, 1)],
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 10 * SizeConfig.heightMultiplier,
                ),
                Image.asset('assets/images/ihl.png'),
                SizedBox(
                  height: 5 * SizeConfig.heightMultiplier,
                ),
                Text(AppTexts.welcome, textAlign: TextAlign.center, style: AppTextStyles.homeTitle),
                Text("hCare",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF19a9e5),
                      fontSize: ScUtil().setSp(26),
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.normal,
                    )),
                SizedBox(
                  height: 1 * SizeConfig.heightMultiplier,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: Text(
                    AppTexts.wel_sub,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(109, 110, 113, 1),
                        fontFamily: 'Poppins',
                        fontSize: ScUtil().setSp(12),
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  ),
                ),
                SizedBox(
                  height: 1 * SizeConfig.heightMultiplier,
                ),
                Lottie.asset(
                  'assets/icons/splash.json',
                  width: 80 * SizeConfig.widthMultiplier,
                  height: 40 * SizeConfig.heightMultiplier,
                ),
                SizedBox(
                  height: 2.5 * SizeConfig.heightMultiplier,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: Center(
                    child: _customButton(),
                  ),
                ),
                SizedBox(
                  height: 1.5 * SizeConfig.heightMultiplier,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: AppTexts.exuser,
                        style: TextStyle(
                          color: Color(0xff6d6e71),
                          fontSize: ScUtil().setSp(16),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
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
                        text: AppTexts.signin,
                        style: TextStyle(
                          color: Color(0xFF19a9e5),
                          fontSize: ScUtil().setSp(18),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          // ..onTap = () => Get.toNamed(Routes.Login, arguments: false),
                          ..onTap = () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.clear();
                            SpUtil.clear();
                            localSotrage.erase();
                            Get.to(LoginEmailScreen(
                              deepLink: false,
                            ));
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 50)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
