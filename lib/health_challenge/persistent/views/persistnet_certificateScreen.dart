import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../Getx/controller/listOfChallengeContoller.dart';
import '../../../new_design/presentation/pages/home/home_view.dart';
import '../../../utils/app_colors.dart';
import '../../../views/home_screen.dart';
import '../../models/challenge_detail.dart';
import '../../models/enrolled_challenge.dart';
import '../../views/certificate_screen.dart';
import '../../widgets/custom_imageScroller.dart';
import '../PersistenGetxController/PersistentGetxController.dart';

class PersistentCertificateScreen extends StatefulWidget {
  PersistentCertificateScreen(
      {Key key,
      @required this.firstComplete,
      @required this.challengedetail,
      @required this.enrolledChallenge,
      @required this.navNormal})
      : super(key: key);
  ChallengeDetail challengedetail;
  EnrolledChallenge enrolledChallenge;
  bool navNormal;
  bool firstComplete;

  @override
  State<PersistentCertificateScreen> createState() => _PersistentCertificateScreenState();
}

class _PersistentCertificateScreenState extends State<PersistentCertificateScreen> {
  final ListChallengeController _listChallengeController = Get.find();
  @override
  void initState() {
    if (widget.firstComplete) {
      //Temp fix for the vibration cause it's crashing the IOS 15 to 17⚪️⚪️
      // Vibration.vibrate(pattern: [500, 1000, 500]);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        Get.defaultDialog(
            barrierDismissible: false,
            backgroundColor: Colors.lightBlue.shade50,
            title: 'Kudos!',
            titlePadding: EdgeInsets.only(top: 20, bottom: 5, right: 10, left: 10),
            titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
            contentPadding: EdgeInsets.only(top: 0),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: Device.width / 1.5,
                  child: Text(
                    "You completed the run successfully.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.task_alt,
                  size: 40,
                  color: Colors.blue.shade300,
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 4,
                    decoration:
                        BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Ok',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ));
      });
      AudioPlayer().play(AssetSource('audio/challenge_completed.mp3'));
    } else {
      null;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        if (widget.navNormal) {
          _listChallengeController.enrolledChallenge();
          Navigator.of(context).pop(true);
        } else {
          _listChallengeController.enrolledChallenge();
          // Get.offAll(HomeScreen(introDone: true), transition: Transition.size);
          Get.off(LandingPage());
        }
      },
      child: ScrollessBasicPageUI(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(widget.challengedetail.challengeName, style: TextStyle(color: Colors.white)),
          leading: InkWell(
            onTap: () {
              if (widget.navNormal) {
                _listChallengeController.enrolledChallenge();
                Navigator.of(context).pop(true);
              } else {
                _listChallengeController.enrolledChallenge();
                // Get.offAll(HomeScreen(introDone: true), transition: Transition.size);
                Get.offAll(LandingPage(), transition: Transition.size);
              }
            },
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
              child: Container(
                width: 95.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 6)],
                ),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: 35.sp, // Image radius
                          // backgroundImage: NetworkImage(widget.challengeDetail.challengeImgUrl),
                          backgroundImage: NetworkImage(widget.challengedetail.challengeImgUrl),
                        ),
                        Container(
                          padding: EdgeInsets.all(14.sp),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(16.sp)),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'BIB ',
                                    style: TextStyle(
                                      color: AppColors.appItemTitleTextColor,
                                      fontSize: 17.sp,
                                    )),
                                widget.enrolledChallenge.user_bib_no != null
                                    ? TextSpan(
                                        text: '- ${widget.enrolledChallenge.user_bib_no ?? ''}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: AppColors.primaryColor,
                                          fontSize: 17.sp,
                                        ))
                                    : TextSpan(
                                        text: '- 1234',
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: AppColors.primaryColor,
                                          fontSize: 17.sp,
                                        )),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                          ),
                          child: Text(
                            widget.challengedetail.challengeName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: Colors.blueGrey),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 6)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GetBuilder(
                          id: 'photoUpload',
                          init: PersistentGetXController(),
                          builder: (context) {
                            return CustomImageScroller(
                              enrolledChallenge: widget.enrolledChallenge,
                              challengeDetail: widget.challengedetail,
                            );
                          }),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: widget.enrolledChallenge.selectedFitnessApp != "other_apps"
                              ? widget.enrolledChallenge.userAchieved <
                                          widget.enrolledChallenge.target ||
                                      widget.enrolledChallenge.docStatus.toLowerCase() == 'rejected'
                                  ? Text(
                                      'You have successfully \nparticipated in the above run!!!',
                                      style: TextStyle(
                                          color: Colors.blueGrey, height: 2.5, fontSize: 15.sp),
                                    )
                                  : Text(
                                      'Congrats you have successfully \ncompleted the above run!!!',
                                      style: TextStyle(
                                          color: Colors.blueGrey, height: 2.5, fontSize: 15.sp),
                                    )
                              : widget.enrolledChallenge.docStatus.toLowerCase() == 'rejected' ||
                                      widget.challengedetail.challengeStartTime
                                              .isBefore(DateTime.now()) &&
                                          (DateFormat('MM-dd-yyyy')
                                                  .format(widget.challengedetail.challengeEndTime)
                                                  .toString() !=
                                              "01-01-2000")
                                  ? Text(
                                      'You have successfully \nparticipated in the above run!!!',
                                      style: TextStyle(
                                          color: Colors.blueGrey, height: 2.5, fontSize: 15.sp),
                                    )
                                  : Text(
                                      'Congrats you have successfully \ncompleted the above run!!!',
                                      style: TextStyle(
                                          color: Colors.blueGrey, height: 2.5, fontSize: 15.sp),
                                    ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Image.asset(
                            'assets/images/certificatemen.png',
                            // height: 20.h,
                            width: Device.width / 3.5,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    ElevatedButton(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text('Download Certificate',
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0,
                                fontFamily: 'Popins',
                                color: Colors.white)),
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          primary: AppColors.primaryAccentColor),
                      onPressed: () {
                        Get.to(
                            CertificateScreen(
                                challengeDetail: widget.challengedetail,
                                enrolledChallenge: widget.enrolledChallenge,
                                duration: widget.enrolledChallenge.userduration,
                                groupName: 'Group Name'),
                            transition: Transition.rightToLeft);
                      },
                    ),
                    SizedBox(
                      height: 5.h,
                    )
                  ],
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
