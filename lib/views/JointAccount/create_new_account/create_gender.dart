import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/views/JointAccount/create_new_account/create_height.dart';
import 'package:ihl/widgets/offline_widget.dart';

class CreateGender extends StatefulWidget {
  CreateGender({Key key}) : super(key: key);

  @override
  _CreateGenderState createState() => _CreateGenderState();
}

class _CreateGenderState extends State<CreateGender> {
  bool maleTap = true;
  bool femaleTap = false;
  bool otherTap = false;
  Color tapped = Color(0xff56CCF2);
  Color notTapped = Colors.white;
  String selectedGender = 'm';
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
            SpUtil.putString(SPKeys.jGender, selectedGender);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CreateHeight(gender: selectedGender),
              ),
            );
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
                    value: 0.4, // percent filled//.75
                    backgroundColor: Color(0xffDBEEFC),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pushNamed(Routes.Cdob),
              // onPressed: () => Get.back(),
              color: Colors.black,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  SpUtil.putString(SPKeys.jGender, selectedGender);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateHeight(gender: selectedGender),
                    ),
                  );
                  //nxt
                  // Get.to(CreateHt(gender: selectedGender));
                },
                child: Text(AppTexts.next,
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
                  AppTexts.step6,
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
                  height: 6 * SizeConfig.heightMultiplier,
                ),
                Text(
                  AppTexts.gender,
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
                //   height: 1 * SizeConfig.heightMultiplier,
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                //   child: Text(
                //     AppTexts.sub6,
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
                  height: 1 * SizeConfig.heightMultiplier,
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
                        height: 1),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 45, left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        highlightColor: Colors.blueAccent,
                        splashColor: Colors.blue,
                        onTap: () {
                          if (this.mounted) {
                            setState(() => maleTap = true);
                            setState(() => femaleTap = false);
                            setState(() => otherTap = false);
                            setState(() => selectedGender = 'm');
                          }
                        },
                        child: Container(
                          width: 120,
                          height: 150,
                          decoration: BoxDecoration(
                            color: maleTap == true
                                ? Color(0xFF19a9e5)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Image.network(
                                    'https://i.postimg.cc/1z5LTN7w/1996679-2.png', //https://i.postimg.cc/9FfT4BNP/img-2.pnghttps://i.postimg.cc/5NQT8HkW/1996679-1.png',
                                    height: 100,
                                    fit: BoxFit.fitWidth),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  'Male',
                                  style: TextStyle(
                                    color: maleTap == true
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        highlightColor: Colors.blueAccent,
                        splashColor: Colors.blue,
                        onTap: () {
                          if (this.mounted) {
                            setState(() => femaleTap = true);
                            setState(() => maleTap = false);
                            setState(() => otherTap = false);
                            setState(() => selectedGender = 'f');
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 120,
                            height: 150,
                            decoration: BoxDecoration(
                              color: femaleTap == true
                                  ? Color(0xFF19a9e5)
                                  : Colors.white,
                              //borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                  ),
                                  child: Image.network(
                                      'https://i.postimg.cc/59YMbL4m/1996681-2.png', //https://i.postimg.cc/zX9BJSmG/img-3.pnghttps://i.postimg.cc/0ysvQd5B/1996681-1.png',
                                      height: 100,
                                      fit: BoxFit.fitWidth),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Female',
                                    style: TextStyle(
                                      color: femaleTap == true
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 2 * SizeConfig.heightMultiplier,
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 50.0, right: 50.0, top: 50.0),
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
