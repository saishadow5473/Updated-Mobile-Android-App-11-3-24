import 'dart:convert';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:strings/strings.dart';

class AffilicationAppDescription extends StatefulWidget {
  final String iHLUserId;
  final dynamic userMobile;
  final String userEmail;
  AffilicationAppDescription({this.iHLUserId, this.userMobile, this.userEmail});

  @override
  State<AffilicationAppDescription> createState() =>
      _AffilicationAppDescriptionState();
}

class _AffilicationAppDescriptionState
    extends State<AffilicationAppDescription> {
  var clickCount = 0;
  Future<dynamic> updateExternalAppCount(
      {userID, mobileNumber, emailId}) async {
    http.Client _client = http.Client();
    try {
      final response = await _client.post(
          Uri.parse(API.iHLUrl + '/consult/create_update_external_app_detail'),
          body: json.encode({
            "user_id": userID,
            "email": emailId,
            "click_count": clickCount,
            "app_name": "smitfit",
            "mobile_number": mobileNumber
          }));
      print(response.statusCode);
      if (response.statusCode == 200) {
        var openAppresult = await LaunchApp.openApp(
            androidPackageName: 'com.smitfit',
            iosUrlScheme: 'com.smit.fit://',
            appStoreLink:
                'https://apps.apple.com/in/app/smit-fit/id1525550488');
        print('openAppResult => $openAppresult ${openAppresult.runtimeType}');
        print(response.body);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Not Evalouated'),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Widget appLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            margin: EdgeInsets.all(0),
            color: Color(0xfff4f6fa),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 100.0,
                        child: CircleAvatar(
                          radius: 90.0,
                          backgroundImage: ExactAssetImage(
                              'assets/images/Smitfit_playstore.png'),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    camelize("SmitFit Application"),
                    // camelize(widget.course['title'].toString()),
                    style: TextStyle(
                      letterSpacing: 2.0,
                      color: AppColors.primaryColor,
                      fontSize: 22.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  Widget appProfie() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Column(children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  size: 30.0,
                  color: AppColors.primaryAccentColor,
                ),
                SizedBox(
                  width: 70.w,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      child: Text(
                        "Application Description",
                        style: TextStyle(
                          color: AppColors.primaryAccentColor,
                          fontSize: 22.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              "Smit.fit is a self-care solution designed to enable people living with (or at risk of) chronic lifestyle conditions(starting with diabetes, heart disease, and hypertension) to achieve mastery over their conditions and live life with a smile (‘smit’ means smile in Sanskrit).\nSmit.fit’s vision is to enable participants to achieve a clear health impact in the 3-6 months time frame and overall move them to a new model of living with these conditions. Smit.fit thus aims to take participants from a life constrained by disease to one where participants have mastered their self-care and are leading happier, fuller lives.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                letterSpacing: 0.20,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: 5.0,
            ),
            // FloatingActionButton.extended(
            //     backgroundColor: AppColors.primaryAccentColor.withOpacity(0.75),
            //     onPressed: () {},
            //     label: Text(
            //       "Connect to SMIT.Fit",
            //       style: TextStyle(color: Colors.white),
            //     ))
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasicPageUI(
      appBar: AppBar(
        leading:
            IconButton(
                icon:
                Icon(Icons.arrow_back_ios),
                color: Colors.white,
                onPressed: () => {Navigator.of(context).pop()}
                // Get.offAll(DietJournal(),
                //     predicate: (route) =>
                //         Get.currentRoute == Routes.Home),
                ),
        centerTitle: true,
        backgroundColor: Colors.transparent,elevation: 0,
        title:
                Text(
                  'SMIT.Fit',
                  style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
      ),

      // Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   //crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     IconButton(
      //         icon:
      //         Icon(Icons.arrow_back_ios),
      //         color: Colors.white,
      //         onPressed: () => {Navigator.of(context).pop()}
      //         // Get.offAll(DietJournal(),
      //         //     predicate: (route) =>
      //         //         Get.currentRoute == Routes.Home),
      //         ),
      //     // SizedBox(
      //     //   width: ScUtil().setHeight(110),
      //     // ),
      //     Flexible(
      //       child: Center(
      //         child:
      //         Text(
      //           'SMIT.Fit',
      //           style: TextStyle(
      //               fontSize: 25.0,
      //               fontWeight: FontWeight.w500,
      //               color: Colors.white),
      //         ),
      //       ),
      //     )
      //   ],
      // ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: appLogo(),
            ),
            // SizedBox(
            //   height: ScUtil().setHeight(40),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: appProfie(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.extended(
                  backgroundColor:
                      AppColors.primaryAccentColor.withOpacity(0.75),
                  onPressed: () {
                    setState(() {
                      clickCount += 1;
                    });
                    // i
                    updateExternalAppCount(
                        userID: widget.iHLUserId,
                        mobileNumber: widget.userMobile,
                        emailId: widget.userEmail);
                  },
                  label: Text(
                    "Connect to SMIT.Fit",
                    style: TextStyle(color: Colors.white),
                  )),
            )
            // SizedBox(
            //   width: ScUtil().setHeight(40),
            // ),
          ],
        ),
      ),
    );
    //  Scaffold(
    //   body: SafeArea(
    //     child: Container(
    //       color: AppColors.bgColorTab,
    //       // height: ScUtil.screenHeight * 2,
    //       child: CustomPaint(
    //         painter: BackgroundPainter(
    //             primary: AppColors.primaryAccentColor.withOpacity(0.8),
    //             secondary: AppColors.primaryAccentColor),
    //         child: Column(
    //           children: [
    // Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   //crossAxisAlignment: CrossAxisAlignment.center,
    //   children: [
    //     IconButton(
    //         icon: Icon(Icons.arrow_back_ios),
    //         color: Colors.white,
    //         onPressed: () => {}
    //         // Get.offAll(DietJournal(),
    //         //     predicate: (route) =>
    //         //         Get.currentRoute == Routes.Home),
    //         ),
    //     // SizedBox(
    //     //   width: ScUtil().setHeight(110),
    //     // ),
    //     Flexible(
    //       child: Center(
    //         child: Text(
    //           'SMIT.Fit',
    //           style: TextStyle(
    //               fontSize: 25.0,
    //               fontWeight: FontWeight.w500,
    //               color: Colors.white),
    //         ),
    //       ),
    //     )
    //   ],
    // ),
    //             Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: Container(
    //                 decoration: BoxDecoration(
    //                   color: Colors.white,
    //                   borderRadius: BorderRadius.circular(30),
    //                 ),
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(8.0),
    //                   child: Expanded(
    //                     child: ListView(
    //                       shrinkWrap: true,
    //                       children: [
    // appLogo(),
    // SizedBox(
    //   width: ScUtil().setHeight(40),
    // ),
    // appProfie(),
    //                         // Text("Application Description",
    //                         //     style: TextStyle(
    //                         //       letterSpacing: 2.0,
    //                         //       color: AppColors.primaryColor,
    //                         //       fontSize: 22.0,
    //                         //     ),
    //                         //     textAlign: TextAlign.center)
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             )
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
