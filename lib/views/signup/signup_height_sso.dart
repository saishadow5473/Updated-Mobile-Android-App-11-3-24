import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/views/signup/signup_gender_sso.dart';
import 'package:ihl/views/signup/signup_weight_sso.dart';
import 'package:ihl/widgets/height.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SignupHtSso extends StatefulWidget {
  final String gender;
  SignupHtSso({Key key, @required this.gender}) : super(key: key);

  @override
  _SignupHtSsoState createState() => _SignupHtSsoState();
}

class _SignupHtSsoState extends State<SignupHtSso> {
  int height = 170;
  double _height = 1.70;
  bool isMaleSelected = true;
  TextEditingController heightController = TextEditingController();

  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    Widget _customButton() {
      return Container(
        height: 60,
        child: GestureDetector(
          onTap: () {
            SpUtil.putString('height', _height.toString());
            Get.to(SignupWtSso());
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
                    AppTexts.continuee,
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
                    value: 0.875, // percent filled
                    backgroundColor: Color(0xffDBEEFC),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Get.to(SignupGenSso()),
              color: Colors.black,
            ),
            actions: <Widget>[
              Visibility(visible: false,
                replacement: SizedBox(width: 10.w,),
                child: TextButton(
                  onPressed: () {
                    SpUtil.putString('height', _height.toString());
                    Get.to(SignupWtSso());
                  },
                  child:  Text(AppTexts.next,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: ScUtil().setSp(16),
                        )),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      color: Color(0xFF19a9e5),
                    ),
                    shape:
                        CircleBorder(side: BorderSide(color: Colors.transparent)),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xffF4F6FA),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  AppTexts.step7,
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
                  height: 4 * SizeConfig.heightMultiplier,
                ),
                Text(
                  AppTexts.height,
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
                  height: 1 * SizeConfig.heightMultiplier,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: Text(
                    AppTexts.sub7,
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
                  height: 1.5 * SizeConfig.heightMultiplier,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  height: 450,
                  child: HeightSlider(
                    height: this.height,
                    numberLineColor: Colors.black,
                    currentHeightTextColor: Colors.black,
                    sliderCircleColor: Colors.blue,
                    onChange: (val) {
                      if (this.mounted) {
                        setState(() {
                          this.height = val;
                          this._height = val / 100;
                        });
                      }
                    },
                    personImagePath: widget.gender == 'm'
                        ? 'assets/svgs/boy.svg'
                        : widget.gender == 'f'
                            ? 'assets/svgs/lady.svg'
                            : 'assets/svgs/others.svg',
                  ),
                ),
                SizedBox(
                  height: 1.5 * SizeConfig.heightMultiplier,
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
    );
  }
}
