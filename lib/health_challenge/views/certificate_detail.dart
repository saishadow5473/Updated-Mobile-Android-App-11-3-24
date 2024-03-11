import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/challenge_detail.dart';
import '../models/enrolled_challenge.dart';
import '../models/group_details_model.dart';
import 'certificate_screen.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../utils/app_colors.dart';
import '../../widgets/BasicPageUI.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../Getx/controller/google_fit_controller.dart';
import '../../widgets/offline_widget.dart';
import '../persistent/PersistenGetxController/PersistentGetxController.dart';
import '../widgets/custom_imageScroller.dart';
import 'group_member_lists.dart';

class CertificateDetail extends StatefulWidget {
  final ChallengeDetail challengeDetail;
  final EnrolledChallenge enrolledChallenge;
  final GroupDetailModel groupDetail;
  final bool currentUserIsAdmin;
  final bool firstCopmlete;

  const CertificateDetail(
      {@required this.challengeDetail,
      @required this.enrolledChallenge,
      @required this.firstCopmlete,
      this.groupDetail,
      this.currentUserIsAdmin});

  @override
  State<CertificateDetail> createState() => _CertificateDetailState();
}

class _CertificateDetailState extends State<CertificateDetail> {
  final _stepController = Get.put(HealthRepository());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final controller = Get.put(PersistentGetXController());

    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: WillPopScope(
        onWillPop: () {
          if (widget.firstCopmlete) {
            // Get.offAll(HomeScreen(introDone: true), transition: Transition.size);
            Get.off(LandingPage());
          } else {
            Navigator.pop(context);
          }
        },
        child: BasicPageUI(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              widget.challengeDetail.challengeName,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
            ),
            leading: InkWell(
              onTap: () {
                if (widget.firstCopmlete) {
                  // Get.offAll(HomeScreen(introDone: true), transition: Transition.size);
                  Get.off(LandingPage());
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
                height: 35.h,
                width: 100.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4.0,
                        spreadRadius: 2.0)
                  ],
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22.sp), topRight: Radius.circular(22.sp)),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      radius: 30.sp,
                      backgroundImage: NetworkImage(
                        widget.challengeDetail.challengeImgUrl,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(14.sp),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(16.sp)),
                      child: RichText(
                        text: TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
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
                            TextSpan(
                                text: '- ${widget.enrolledChallenge.user_bib_no}',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.primaryColor,
                                  fontSize: 17.sp,
                                )),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      widget.challengeDetail.challengeName,
                      style: TextStyle(
                          color: AppColors.appItemTitleTextColor,
                          fontSize: 19.sp,
                          letterSpacing: -1),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
                height: 50.h,
                width: 100.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4.0,
                        spreadRadius: 2.0)
                  ],
                ),
                alignment: Alignment.center,
                child: ListView(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GetBuilder(
                          id: 'photoUpload',
                          init: PersistentGetXController(),
                          builder: (context) {
                            return CustomImageScroller(
                              enrolledChallenge: widget.enrolledChallenge,
                              challengeDetail: widget.challengeDetail,
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Container(
                            height: 7.h,
                            width: 95.w,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              boxShadow: [
                                BoxShadow(color: Colors.grey, offset: Offset(3, 3), blurRadius: 6)
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 2.w,
                                ),
                                widget.challengeDetail.challengeMode == "individual"
                                    ? Text("My Challenge",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white))
                                    : Text(widget.groupDetail.groupName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white)),
                                Visibility(
                                  visible: (widget.challengeDetail.challengeMode != "individual" &&
                                      widget.currentUserIsAdmin),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => GroupMemberList(
                                                  challengeDetail: widget.challengeDetail,
                                                  filteredData: widget.enrolledChallenge,
                                                )),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.play_arrow,
                                    ),
                                    color: Colors.white,
                                  ),
                                  replacement: SizedBox.shrink(),
                                )
                              ],
                            ),
                          ),
                          Container(
                            // height: 24.h,
                            width: 95.w,
                            decoration: const BoxDecoration(
                              color: AppColors.appBackgroundColor,
                              boxShadow: [
                                BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 6)
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  // crossAxisAlignment:
                                  //     CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: size.width / 3.5,
                                      child: Column(
                                        children: [
                                          Column(
                                            children: [
                                              const Text("Achieved",
                                                  // challengeDetail
                                                  //             .challengeMode ==
                                                  //         "individual"
                                                  //     ? "Achieved"
                                                  //     : "Contribution",
                                                  style: FitnessAppTheme.challengeKeyText),
                                              Text(
                                                  (widget.challengeDetail.challengeUnit ==
                                                              'steps' ||
                                                          widget.challengeDetail.challengeUnit ==
                                                              's')
                                                      ? 'Steps'
                                                      : widget.challengeDetail.challengeUnit == 'm'
                                                          ? 'Distance (m)'
                                                          : "Distance (km)",
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: Colors.grey.withOpacity(0.8)))
                                            ],
                                          ),
                                          widget.enrolledChallenge.challengeMode == "group"
                                              ? widget.enrolledChallenge.groupAchieved <
                                                      widget.enrolledChallenge.target
                                                  ? Text(
                                                      (widget.challengeDetail.challengeUnit ==
                                                                  'steps' ||
                                                              widget.challengeDetail.challengeUnit ==
                                                                  's')
                                                          ? widget.enrolledChallenge.groupAchieved
                                                              .toStringAsFixed(0)
                                                          : widget.enrolledChallenge.groupAchieved
                                                              .toStringAsFixed(2),
                                                      style: FitnessAppTheme.challengeValueText)
                                                  : Text('${widget.enrolledChallenge.target}',
                                                      style: FitnessAppTheme.challengeValueText)
                                              : widget.enrolledChallenge.userAchieved <
                                                      widget.enrolledChallenge.target
                                                  ? Text(
                                                      (widget.challengeDetail.challengeUnit ==
                                                                  'steps' ||
                                                              widget.challengeDetail
                                                                      .challengeUnit ==
                                                                  's')
                                                          ? widget.enrolledChallenge.userAchieved
                                                              .toStringAsFixed(0)
                                                          : widget.enrolledChallenge.userAchieved
                                                              .toStringAsFixed(2),
                                                      style: FitnessAppTheme.challengeValueText)
                                                  : Text('${widget.enrolledChallenge.target}',
                                                      style: FitnessAppTheme.challengeValueText),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width / 3.2,
                                      child: Column(
                                        children: [
                                          Column(
                                            children: [
                                              const Text("Pending",
                                                  // challengeDetail
                                                  //             .challengeMode ==
                                                  //         "individual"
                                                  //     ? "Remaining"
                                                  //     : "Yet to Achieve",
                                                  style: FitnessAppTheme.challengeKeyText),
                                              Text(
                                                  (widget.challengeDetail.challengeUnit ==
                                                              'steps' ||
                                                          widget.challengeDetail.challengeUnit ==
                                                              's')
                                                      ? 'Steps'
                                                      : widget.challengeDetail.challengeUnit == 'm'
                                                          ? 'Distance (m)'
                                                          : "Distance (km)",
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: Colors.grey.withOpacity(0.8)))
                                            ],
                                          ),
                                          Builder(builder: (_) {
                                            double typeTotal;
                                            if (widget.enrolledChallenge.challengeMode != 'group') {
                                              typeTotal = widget.enrolledChallenge.userAchieved;
                                            } else {
                                              typeTotal = widget.enrolledChallenge.groupAchieved;
                                            }
                                            return Text(
                                                widget.enrolledChallenge.userAchieved != null
                                                    ? '${typeTotal > widget.enrolledChallenge.target ? 0 : (widget.challengeDetail.challengeUnit == 'steps' || widget.challengeDetail.challengeUnit == 's') ? (widget.enrolledChallenge.target - typeTotal).toStringAsFixed(0) : (widget.enrolledChallenge.target - typeTotal).toStringAsFixed(2)}'

                                                    // ? '${int.parse(widget.filteredList.target) - int.parse(widget.filteredList.userAchieved)}'
                                                    : "0",
                                                style: FitnessAppTheme.challengeValueText);
                                          })
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width / 4.5,
                                      child: Column(
                                        children: [
                                          Column(
                                            children: [
                                              const Text("Total",
                                                  style: FitnessAppTheme.challengeKeyText),
                                              Text(
                                                  (widget.challengeDetail.challengeUnit ==
                                                              'steps' ||
                                                          widget.challengeDetail.challengeUnit ==
                                                              's')
                                                      ? 'Steps'
                                                      : widget.challengeDetail.challengeUnit == 'm'
                                                          ? 'Distance (m)'
                                                          : "Distance (km)",
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: Colors.grey.withOpacity(0.8)))
                                            ],
                                          ),
                                          Text('${widget.enrolledChallenge.target}',
                                              style: FitnessAppTheme.challengeValueText)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: Divider(thickness: 2),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      height: 40,
                                      child: Image.asset("assets/images/diet/burned.png"),
                                    ),
                                    const Text(
                                      "Burned Calories ",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1,
                                          color: Colors.blueGrey),
                                    ),
                                    GetBuilder<HealthRepository>(
                                        id: _stepController.caloryUpdate,
                                        initState: (_) {
                                          _stepController.caloriesCalculationFromChallengeStart(
                                              widget.enrolledChallenge.enrollmentId,
                                              fromChallengeChange: false);
                                        },
                                        builder: (_) {
                                          return Text(
                                            _.burnedCalories.toStringAsFixed(2),
                                            style: FitnessAppTheme.challengeValueText,
                                          );
                                        }),
                                    Text(
                                      " Cal",
                                      style: FitnessAppTheme.challengeValueText,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 15.sp),
                        width: 100.w,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                widget.enrolledChallenge.userAchieved <
                                        widget.enrolledChallenge.target
                                    ? Text(
                                        'You have successfully \nparticipated in the above challenge!!!',
                                        style: TextStyle(
                                            color: AppColors.textitemTitleColor,
                                            height: 2.5,
                                            fontSize: 15.sp),
                                      )
                                    : Text(
                                        'Congrats you have successfully \ncompleted the above challenge!!!',
                                        style: TextStyle(
                                            color: AppColors.textitemTitleColor,
                                            height: 2.5,
                                            fontSize: 15.sp),
                                      ),
                                Image.asset(
                                  'assets/images/certificatemen.png',
                                  height: 15.h,
                                  width: 20.5.w,
                                )
                              ],
                            ),
                            InkWell(
                              onTap: () => Get.to(
                                  CertificateScreen(
                                      challengeDetail: widget.challengeDetail,
                                      enrolledChallenge: widget.enrolledChallenge,
                                      duration: widget.enrolledChallenge.userduration,
                                      groupName:
                                          widget.challengeDetail.challengeMode == 'individual'
                                              ? ''
                                              : widget.groupDetail.groupName),
                                  transition: Transition.rightToLeft),
                              child: Container(
                                width: 53.w,
                                height: 5.5.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50.sp),
                                    color: AppColors.primaryColor),
                                child: const Text(
                                  'Download Certificate',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                             SizedBox(
                              height: 10.h,
                            )
                          ],
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
