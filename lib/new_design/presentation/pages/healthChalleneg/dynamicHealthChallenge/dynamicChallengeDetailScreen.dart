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

import '../../../../app/utils/appColors.dart';
import 'dynamicChallengeNicknameScreen.dart';

class DynamicChallengeDetailScreen extends StatefulWidget {
  const DynamicChallengeDetailScreen({
    Key key,
    @required this.challengeDetail,
    @required this.fromNotification,
  }) : super(key: key);
  final ChallengeDetail challengeDetail;
  final bool fromNotification;
  @override
  State<DynamicChallengeDetailScreen> createState() => _DynamicChallengeDetailScreenState();
}

class _DynamicChallengeDetailScreenState extends State<DynamicChallengeDetailScreen> {
  @override
  void initState() {
    type = widget.challengeDetail.challengeType == 'Weight Loss Challenge' ? ' in Kg' : ' in Steps';
    super.initState();
  }

  String type;
  // String losstype = type == 'Weight Loss Challenge' ? ' in Kg' : ' in Steps';
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title:
            Text(widget.challengeDetail.challengeName, style: const TextStyle(color: Colors.white)),
        leading: InkWell(
          onTap: () {
            if (widget.fromNotification) {
              Get.offAll(LandingPage());
            } else {
              Navigator.pop(context);
            }
          },
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: width / 1.9,
            margin: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 6)
                ],
                borderRadius: BorderRadius.circular(2),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.challengeDetail.challengeImgUrl))),
          ),

          Container(
            margin: EdgeInsets.symmetric(vertical: 18.sp, horizontal: 16.sp),
            // width: width - 40,
            // height: wordCounterForContainerSize(
            //             widget.challengeDetail.challengeDescription) <
            //         30
            //     ? 200
            //     : null,
            //uncommand the code to set the box decoration for description with shadow
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.circular(10),
            //   boxShadow: [
            //     BoxShadow(
            //         color: Colors.grey,
            //         offset: Offset(1, 1),
            //         blurRadius: 6)
            //   ],
            // ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible:
                      (DateFormat('MM-dd-yyyy').format(widget.challengeDetail.challengeStartTime))
                              .toString() !=
                          "01-01-2000",
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: const [
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
                                "Start Date",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 18.sp,
                                    letterSpacing: 0.8),
                              ),
                              SizedBox(
                                width: 8.sp,
                              ),
                              Text(
                                "End Date",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.primaryColor,
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
                                        .format("dd-MM-yyyy"))
                                    .toString(),
                                style: TextStyle(fontSize: 16.sp, letterSpacing: 0.3),
                              ),
                              const Text(
                                "-",
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                (Jiffy(widget.challengeDetail.challengeEndTime)
                                        .format("dd-MM-yyyy"))
                                    .toString(),
                                style: TextStyle(fontSize: 16.sp, letterSpacing: 0.3),
                              )
                            ],
                          ),
                          // Row(
                          //     // mainAxisSize: MainAxisSize.min,
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     crossAxisAlignment: CrossAxisAlignment.end,
                          //     children: [
                          //       SizedBox(
                          //         width: 46.sp,
                          //         child: Column(
                          //           mainAxisAlignment: MainAxisAlignment.end,
                          //           children: [
                          //             Text(
                          //               "Active from",
                          //               style: TextStyle(
                          //                   color: Colors.blue,
                          //                   fontSize: 18.sp,
                          //                   letterSpacing: 0.8),
                          //             ),
                          //             SizedBox(
                          //               height: 10,
                          //             ),
                          //             Text(
                          //               (Jiffy(widget.challengeDetail.challengeStartTime)
                          //                       .format("do MMM yyyy"))
                          //                   .toString(),
                          //               style: TextStyle(
                          //                   fontSize: 16.sp, letterSpacing: 0.3),
                          //             )
                          //           ],
                          //         ),
                          //       ),
                          //       Container(
                          //         margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
                          //         alignment: Alignment.center,
                          //         child: Text(
                          //           "-",
                          //           style: TextStyle(
                          //               color: Colors.blue, fontWeight: FontWeight.bold),
                          //         ),
                          //       ),
                          //       SizedBox(
                          //         width: 45.sp,
                          //         child: Column(
                          //           mainAxisAlignment: MainAxisAlignment.end,
                          //           children: [
                          //             Text(
                          //               "Expired at",
                          //               style: TextStyle(
                          //                   color: Colors.blue,
                          //                   fontSize: 18.sp,
                          //                   letterSpacing: 0.8),
                          //             ),
                          //             SizedBox(
                          //               height: 10,
                          //             ),
                          //             Text(
                          //               (Jiffy(widget.challengeDetail.challengeEndTime)
                          //                       .format("do MMM yyyy"))
                          //                   .toString(),
                          //               style: TextStyle(
                          //                   fontSize: 16.sp, letterSpacing: 0.3),
                          //             )
                          //           ],
                          //         ),
                          //       )
                          //     ]),
                          const SizedBox(
                            height: 10,
                          ),
                          // Column(
                          //   children: [
                          //     Text(
                          //       "Time",
                          //       style: TextStyle(
                          //         color: Colors.blue,
                          //         // fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //     Text(
                          //         "  ${DateFormat('hh:mm a').format(widget.challengeDetail.challengeStartTime)}  to  ${DateFormat('hh:mm a').format(widget.challengeDetail.challengeEndTime)}  "),
                          //   ],
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('About this challenge',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: 0.8,
                        color: AppColors.primaryColor,
                      )),
                ),
                Container(
                  // width: width - 40,
                  height:
                      wordCounterForContainerSize(widget.challengeDetail.challengeDescription) < 30
                          ? Device.height / 3.5
                          : Device.height / 3.3,
                  padding: EdgeInsets.symmetric(vertical: 12.sp),
                  child: RawScrollbar(
                    radius: const Radius.circular(10),
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
            // child: Column(children: [
            //   SizedBox(
            //     height: 10,
            //   ),
            //   customListTile(
            //       'Challenge Name',
            //       widget.challengeDetail.challengeName,
            //       Icons.text_fields_rounded,
            //       () {}),
            //   customDivider(),
            //   customListTile(
            //       'Challenge Category',
            //       widget.challengeDetail.challengeType,
            //       Icons.alternate_email_sharp,
            //       () {}),
            //   customDivider(),
            //   customListTile(
            //       'Description',
            //       widget.challengeDetail.challengeDescription,
            //       Icons.align_horizontal_left,
            //       () {}),
            //   customDivider(),
            //   customListTile('Mode', widget.challengeDetail.challengeMode,
            //       Icons.person_add, () {}),
            //   customDivider(),
            //   customListTile('City', widget.challengeDetail.targetCity,
            //       Icons.share_location_sharp, () {}),
            //   Visibility(
            //     visible:
            //         widget.challengeDetail.challengeMode.toLowerCase() ==
            //             'group',
            //     child: Column(
            //       children: [
            //         customDivider(),
            //         customListTile(
            //             'Minimum Users',
            //             widget.challengeDetail.minUsersGroup.toString(),
            //             Icons.arrow_downward,
            //             () {}),
            //         customDivider(),
            //         customListTile(
            //             'Maximum Users',
            //             widget.challengeDetail.maxUsersGroup.toString(),
            //             Icons.arrow_upward,
            //             () {}),
            //       ],
            //     ),
            //   ),
            //   customDivider(),
            //   customListTile(
            //       'Department',
            //       widget.challengeDetail.targetDepartment,
            //       Icons.share_location_sharp,
            //       () {}),
            //   customDivider(),
            //   customListTile(
            //       'Target to Archive',
            //       widget.challengeDetail.targetToAchieve + type,
            //       Icons.accessibility_new_outlined,
            //       () {}),
            // ]),
          ),
          // SizedBox(
          //   height: 30,
          // ),
          ElevatedButton(
            onPressed: () async {
              //TODO no need activity permission for dynamic health challenge
              /*  var status = Platform.isAndroid
                  ? await Permission.activityRecognition.status
                  : await Permission.sensors.request();
              if (status.isGranted) {*/
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var k = jsonDecode(prefs.getString(SPKeys.jUserData));
              List<EnrolledChallenge> enr =
                  await ChallengeApi().listofUserEnrolledChallenges(userId: k["User"]["id"]);
              enr.removeWhere(
                  (element) => element.challengeId != widget.challengeDetail.challengeId);
              if (enr.isEmpty) {
                Get.to(DynamicChallengeNickName(
                  challengeDetail: widget.challengeDetail,
                ));
              } else {
                Get.defaultDialog(
                    barrierDismissible: false,
                    backgroundColor: Colors.lightBlue.shade50,
                    title: "You've already joined this challenge.",
                    titlePadding: EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
                    titleStyle:
                        TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                    contentPadding: const EdgeInsets.only(top: 0),
                    content: Column(
                      children: [
                        const Divider(
                          thickness: 2,
                        ),
                        Icon(
                          Icons.error,
                          size: 50,
                          color: Colors.blue.shade300,
                        ),
                        const SizedBox(
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
                                color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Ok'),
                              ),
                            ),
                          ),
                        )
                      ],
                    ));
              }
              /* } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => CupertinoAlertDialog(
                          title: new Text("Physical Activity Access Denied"),
                          content: new Text("Allow physical permission to continue"),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: Text("Yes"),
                              onPressed: () async {
                                await openAppSettings();
                                Get.back();
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text("No"),
                              onPressed: () => Get.back(),
                            )
                          ],
                        ));
              }*/
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                primary: Colors.lightBlue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                textStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            child: const Text('Join'),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
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
        style: const TextStyle(color: Colors.blue),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          key,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
      onTap: onTap,
    );
  }
}
