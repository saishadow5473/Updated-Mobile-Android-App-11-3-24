import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/views/JointAccount/create_new_account/create_name.dart';
import 'package:ihl/views/JointAccount/link_existing_account/enter_email.dart';
import 'package:ihl/widgets/offline_widget.dart';

class LinkExistAccount extends StatefulWidget {
  final apirepository = Apirepository();
  LinkExistAccount({Key key}) : super(key: key);

  @override
  _LinkExistAccountState createState() => _LinkExistAccountState();
}

class _LinkExistAccountState extends State<LinkExistAccount> {
  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    Widget _customButton() {
      return Column(
        children: [
          Container(
            height: 60,
            child: GestureDetector(
              onTap: () {
                Get.to(
                  EnterEmail(
                    apiRepository: widget.apirepository,
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
          ),
          SizedBox(
            height: 2 * SizeConfig.heightMultiplier,
          ),
          InkWell(
            onTap: () {
              Get.to(CreateName());
            },
            child: Text(
              'Create new account here',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFF19a9e5),
                  fontFamily: 'Poppins',
                  fontSize: ScUtil().setSp(12),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  height: 1.1),
            ),
          ),
        ],
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
              onPressed: () => Navigator.of(context)
                  .pushNamed(Routes.JointAccount, arguments: false),
              color: Colors.black,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Get.to(
                    EnterEmail(
                      apiRepository: widget.apirepository,
                    ),
                  );
                },
                child: Text(AppTexts.next,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                // Text(
                //   AppTexts.Lstep1,
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
                Container(
                  padding: EdgeInsets.fromLTRB(15.0, 50.0, 0.0, 0.0),
                  child: Text(AppTexts.Linfo1,
                      style: TextStyle(
                          fontSize: ScUtil().setSp(26),
                          fontFamily: 'Poppins',
                          color: Color.fromRGBO(109, 110, 113, 1),
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 1 * SizeConfig.heightMultiplier,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: Text(
                    AppTexts.Lsub0,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(109, 110, 113, 1),
                        fontFamily: 'Poppins',
                        fontSize: ScUtil().setSp(15),
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.normal,
                        height: 1.5),
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
    );
  }
}
