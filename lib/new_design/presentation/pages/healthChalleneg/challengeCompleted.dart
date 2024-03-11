import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../health_challenge/models/challenge_detail.dart';
import '../../../../health_challenge/models/enrolled_challenge.dart';
import '../../../../health_challenge/models/group_details_model.dart';
import '../../../../health_challenge/views/certificate_screen.dart';
import '../home/landingPage.dart';
import '../../../../utils/app_colors.dart';
import '../../../../widgets/BasicPageUI.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../Getx/controller/google_fit_controller.dart';
import '../../../../health_challenge/persistent/PersistenGetxController/PersistentGetxController.dart';
import '../../../../health_challenge/views/group_member_lists.dart';
import '../../../../health_challenge/widgets/custom_imageScroller.dart';
import '../../../../widgets/offline_widget.dart';
import '../home/home_view.dart';

class ChallengeCompleted extends StatelessWidget {
  final ChallengeDetail challengeDetail;
  final EnrolledChallenge enrolledChallenge;
  final GroupDetailModel groupDetail;
  final bool currentUserIsAdmin;
  final bool firstCopmlete;

  const ChallengeCompleted(
      {Key key,
      @required this.challengeDetail,
      @required this.enrolledChallenge,
      @required this.firstCopmlete,
      this.groupDetail,
      this.currentUserIsAdmin})
      : super(key: key);

  calculate() {
    return enrolledChallenge.userAchieved;
  }

  @override
  Widget build(BuildContext context) {
    final HealthRepository stepController = Get.put(HealthRepository());

    final Size size = MediaQuery.of(context).size;
    final PersistentGetXController controller = Get.put(PersistentGetXController());

    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: WillPopScope(
        onWillPop: () {
          Get.off(LandingPage());
        },
        child: BasicPageUI(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(challengeDetail.challengeName, style: const TextStyle(color: Colors.white)),
            leading: InkWell(
              onTap: () {
                Get.off(LandingPage());
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
                        challengeDetail.challengeImgUrl,
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
                                text: '- ${enrolledChallenge.user_bib_no}',
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
                      challengeDetail.challengeName,
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
                              enrolledChallenge: enrolledChallenge,
                              challengeDetail: challengeDetail,
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
                                challengeDetail.challengeMode == "individual"
                                    ? const SizedBox(
                                        width: 1,
                                      )
                                    : const SizedBox(
                                        width: 50,
                                      ),
                                challengeDetail.challengeMode == "individual"
                                    ? Text("My Challenge",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white))
                                    : Text(groupDetail.groupName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white)),
                                Visibility(
                                  visible: challengeDetail.challengeMode != "individual" &&
                                      currentUserIsAdmin,
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) => GroupMemberList(
                                                  challengeDetail: challengeDetail,
                                                  filteredData: enrolledChallenge,
                                                )),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.play_arrow,
                                    ),
                                    color: Colors.white,
                                  ),
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
                                                  (challengeDetail.challengeUnit == 'steps' ||
                                                          challengeDetail.challengeUnit == 's')
                                                      ? 'Steps'
                                                      : challengeDetail.challengeUnit == 'm'
                                                          ? 'Distance (m)'
                                                          : "Distance (km)",
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: Colors.grey.withOpacity(0.8)))
                                            ],
                                          ),
                                          enrolledChallenge.userAchieved < enrolledChallenge.target
                                              ? Text('${enrolledChallenge.userAchieved}',
                                                  style: FitnessAppTheme.challengeValueText)
                                              : Text('${enrolledChallenge.target}',
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
                                                  (challengeDetail.challengeUnit == 'steps' ||
                                                          challengeDetail.challengeUnit == 's')
                                                      ? 'Steps'
                                                      : challengeDetail.challengeUnit == 'm'
                                                          ? 'Distance (m)'
                                                          : "Distance (km)",
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: Colors.grey.withOpacity(0.8)))
                                            ],
                                          ),
                                          Builder(builder: (_) {
                                            double typeTotal;
                                            if (enrolledChallenge.challengeMode != 'group') {
                                              typeTotal = enrolledChallenge.userAchieved;
                                            } else {
                                              typeTotal = enrolledChallenge.groupAchieved;
                                            }
                                            return Text(
                                                enrolledChallenge.userAchieved != null
                                                    ? '${typeTotal > enrolledChallenge.target ? 0 : (challengeDetail.challengeUnit == 'steps' || challengeDetail.challengeUnit == 's') ? (enrolledChallenge.target - typeTotal).toStringAsFixed(0) : (enrolledChallenge.target - typeTotal).toStringAsFixed(2)}'

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
                                                  (challengeDetail.challengeUnit == 'steps' ||
                                                          challengeDetail.challengeUnit == 's')
                                                      ? 'Steps'
                                                      : challengeDetail.challengeUnit == 'm'
                                                          ? 'Distance (m)'
                                                          : "Distance (km)",
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: Colors.grey.withOpacity(0.8)))
                                            ],
                                          ),
                                          Text('${enrolledChallenge.target}',
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
                                        id: stepController.caloryUpdate,
                                        initState: (_) {
                                          stepController.caloriesCalculationFromChallengeStart(
                                              enrolledChallenge.enrollmentId,
                                              fromChallengeChange: false);
                                        },
                                        builder: (_) {
                                          return Text(
                                            _.burnedCalories.toStringAsFixed(2),
                                            style: FitnessAppTheme.challengeValueText,
                                          );
                                        }),
                                    const Text(
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
                                enrolledChallenge.userAchieved < enrolledChallenge.target
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
                                      challengeDetail: challengeDetail,
                                      enrolledChallenge: enrolledChallenge,
                                      duration: enrolledChallenge.userduration,
                                      groupName: 'Group Name'),
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
                            const SizedBox(
                              height: 10,
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
