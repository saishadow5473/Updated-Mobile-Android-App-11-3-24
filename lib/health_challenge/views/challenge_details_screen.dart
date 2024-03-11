// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/health_challenge/controllers/challenge_api.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/health_challenge/views/nick_name_screen.dart';
import 'package:ihl/new_design/presentation/bindings/initialControllerBindings.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/views/home_screen.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Getx/controller/listOfChallengeContoller.dart';

class ChallengeDetailsScreen extends StatefulWidget {
  const ChallengeDetailsScreen({
    Key key,
    @required this.challengeDetail,
    @required this.fromNotification,
  }) : super(key: key);
  final ChallengeDetail challengeDetail;
  final bool fromNotification;
  @override
  State<ChallengeDetailsScreen> createState() => _ChallengeDetailsScreenState();
}

class _ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
  @override
  void initState() {
    type = widget.challengeDetail.challengeType == 'Weight Loss Challenge' ? ' in Kg' : ' in Steps';
    super.initState();
  }

  String type;
  // String losstype = type == 'Weight Loss Challenge' ? ' in Kg' : ' in Steps';
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        if (widget.fromNotification)
          Get.offAll(LandingPage());
        else
          Navigator.pop(context);

        return Future.value(false);
      },
      child: ScrollessBasicPageUI(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
              widget.challengeDetail.challengeType.toLowerCase() == 'step challenge'
                  ? 'Step Challenge'
                  : 'Other Challenges',
              style: TextStyle(color: Colors.white)),
          leading: InkWell(
            onTap: () {
              if (widget.fromNotification)
                Get.offAll(LandingPage());
              else
                Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          width: width - 10,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 6)],
                ),
                child: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.all(15.sp),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                                child: Text(
                              "${widget.challengeDetail.challengeName}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 17.sp,
                                letterSpacing: 0.8,
                                color: Colors.lightBlue,
                              ),
                            ))
                          ],
                        )),
                    Container(
                      height: width / 1.9,
                      width: width / 1.9,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 6)
                          ],
                          borderRadius: BorderRadius.circular(25),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(widget.challengeDetail.challengeImgUrl))),
                    ),

                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: (DateFormat('MM-dd-yyyy')
                                        .format(widget.challengeDetail.challengeStartTime))
                                    .toString() !=
                                "01-01-2000",
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 2)
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.sp),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Active from",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 18.sp,
                                              letterSpacing: 0.8),
                                        ),
                                        SizedBox(
                                          width: 8.sp,
                                        ),
                                        Text(
                                          "Expired on",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 18.sp,
                                              letterSpacing: 0.8),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.sp,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          (Jiffy(widget.challengeDetail.challengeStartTime)
                                                  .format("do MMM yyyy"))
                                              .toString(),
                                          style: TextStyle(fontSize: 16.sp, letterSpacing: 0.3),
                                        ),
                                        Text(
                                          "-",
                                          style: TextStyle(
                                              color: Colors.blue, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          (Jiffy(widget.challengeDetail.challengeEndTime)
                                                  .format("do MMM yyyy"))
                                              .toString(),
                                          style: TextStyle(fontSize: 16.sp, letterSpacing: 0.3),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          DateFormat('hh:mm a')
                                              .format(widget.challengeDetail.challengeStartTime)
                                              .toString(),
                                          style: TextStyle(fontSize: 16.sp, letterSpacing: 0.3),
                                        ),
                                        Text(
                                          "",
                                          style: TextStyle(
                                              color: Colors.blue, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          DateFormat('hh:mm a')
                                              .format(widget.challengeDetail.challengeEndTime)
                                              .toString(),
                                          style: TextStyle(fontSize: 16.sp, letterSpacing: 0.3),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Get.find<ListChallengeController>()
                                          .affiliateCmpnyList
                                          .contains("persistent") &&
                                      widget.challengeDetail.affiliations.contains("persistent") &&
                                      widget.challengeDetail.challengeMode == "individual"
                                  ? Text('About this Run',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        letterSpacing: 0.8,
                                        color: Colors.lightBlue,
                                      ))
                                  : Text('About this challenge',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        letterSpacing: 0.8,
                                        color: Colors.lightBlue,
                                      )),
                            ),
                          ),
                          Container(
                            // width: width - 40,
                            height: wordCounterForContainerSize(
                                        widget.challengeDetail.challengeDescription) <
                                    30
                                ? Device.height / 3.5
                                : Device.height / 3.3,
                            padding: EdgeInsets.only(left: 15, top: 8, right: 15),
                            child: RawScrollbar(
                              radius: Radius.circular(10),
                              thickness: 3,
                              thumbColor: Colors.grey.shade300,
                              // isAlwaysShown: true,
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Text(
                                    widget.challengeDetail.challengeDescription,
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(
                    //   height: 30,
                    // ),
                    ElevatedButton(
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        var k = jsonDecode(prefs.getString(SPKeys.jUserData));
                        List<EnrolledChallenge> enr = await ChallengeApi()
                            .listofUserEnrolledChallenges(userId: k["User"]["id"]);
                        enr.removeWhere(
                            (element) => element.challengeId != widget.challengeDetail.challengeId);
                        if (enr.isEmpty) {
                          Get.to(NickName(
                            challengeDetail: widget.challengeDetail,
                          ));
                        } else {
                          Get.defaultDialog(
                              barrierDismissible: false,
                              backgroundColor: Colors.lightBlue.shade50,
                              title: "You've already joined this challenge.",
                              titlePadding:
                                  EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
                              titleStyle: TextStyle(
                                  letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                              contentPadding: EdgeInsets.only(top: 0),
                              content: Column(
                                children: [
                                  Divider(
                                    thickness: 2,
                                  ),
                                  Icon(
                                    Icons.error,
                                    size: 50,
                                    color: Colors.blue.shade300,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // Navigator.pop(context);
                                      Get.offAll(LandingPage(), binding: InitialBindings());
                                      // Get.offAll(HomeScreen(introDone: true),
                                      //     transition: Transition.size);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width / 4,
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Ok'),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          primary: Colors.lightBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                          textStyle: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5)),
                      child: const Text('Join'),
                    ),
                    SizedBox(
                      height: 5,
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

  Widget customDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Divider(
        color: Colors.grey.shade300,
        thickness: 1,
      ),
    );
  }

  int wordCounterForContainerSize(String description) {
    List words = description.split(' ');
    return words.length;
  }

  Widget customListTile(String key, value, IconData iconvalue, VoidCallback onTap) {
    return ListTile(
      horizontalTitleGap: 5.0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          iconvalue,
          color: Colors.blue.shade300,
        ),
      ),
      title: Text(
        value,
        style: TextStyle(color: Colors.blue),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          key,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
      onTap: onTap,
    );
  }
}
