import 'dart:developer';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/new_design/app/utils/imageAssets.dart';
import 'package:ihl/new_design/app/utils/textStyle.dart';
import 'package:ihl/new_design/data/model/retriveUpcomingDetails/upcomingDetailsModel.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../Getx/controller/google_fit_controller.dart';
import '../../../health_challenge/controllers/challenge_api.dart';
import '../../../health_challenge/models/get_selfie_image_model.dart';
import '../../../health_challenge/models/update_challenge_target_model.dart';
import '../../../health_challenge/persistent/PersistenGetxController/PersistentGetxController.dart';
import '../../app/services/health challenge/update_challenge_services.dart';
import '../../app/utils/appColors.dart';
import '../../app/utils/appText.dart';
import '../controllers/dashboardControllers/upComingDetailsController.dart';
import '../controllers/healthchallenge/googlefitcontroller.dart';

class ChallengeCard {
  Widget noChallenegs(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.lightBlue.shade300, Colors.blue.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
        // borderRadius: BorderRadius.circular(5)
      ),
      // height: 33.h,
      width: 95.w,
      child: Padding(
        padding: EdgeInsets.only(top: 1.5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.8.h),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                      alignment: Alignment.topCenter,
                      //height: 20.h,
                      width: 95.w,
                      child: Image(
                        image: ImageAssets.badgePopUp,
                        height: 10.h,
                        width: 20.w,
                      )),
                  Image.asset(
                    ImageAssets.badgeParticle,
                    height: 10.h,
                    width: 35.w,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 1.h, bottom: 1.5.h),
              child: Text(
                AppTexts.healthChallengeWelcomeText,
                style: AppTextStyles.subContent,
                textAlign: TextAlign.center,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget newChallenge(BuildContext context, {Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.h, left: 3.w),
          child: Text(
            AppTexts.newChallenge,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.sp,
              color: color != null ? color : AppColors.primaryAccentColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 2.h, left: 2.w),
          child: Text(
            AppTexts.askToJoin,
            style: AppTextStyles.boldContnet,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 1.5.h, top: 2.h, left: 3.w),
          child: Container(
            width: 90.w,
            child: Text(
              AppTexts.joinDescription,
              style: AppTextStyles.secondaryContentFont,
            ),
          ),
        ),
        Stack(children: [
          Image(image: ImageAssets.newRun, height: 22.h, width: 95.w, fit: BoxFit.fill),
          Positioned(
            left: 37.w,
            top: 11.5.h,
            right: 37.w,
            child: SizedBox(
              height: 3.5.h,
              //width: 5.w,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: color != null ? color : AppColors.primaryColor),
                child: Text(
                  "START NOW",
                  style: TextStyle(fontSize: 6.sp),
                ),
              ),
            ),
          )
        ])
      ],
    );
  }

  Widget enrolledChallenge(BuildContext context, {Color color}) {
    final UpcomingDetailsController _upcomingDetailsController = Get.find();
    final PersistentGetXController _persistentGetXController = Get.put(PersistentGetXController());
    final pageController = PageController(initialPage: 0, keepPage: true, viewportFraction: .95);
    //var caloriesM = print(userAchived);
    return Container(
      color: AppColors.backgroundScreenColor,
      height: 24.5.h,
      child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: pageController,
          padEnds: false,
          onPageChanged: (index) async {
            log('Challenge Index :$index');
            pageController.animateToPage(index,
                duration: Duration(milliseconds: 700), curve: Curves.easeOut);
            EnrolledChallenge _enrolledChallenge =
                _upcomingDetailsController.upComingDetails.enrolChallengeList[index];
            Get.put(HealthRepository()).caloriesCalculationFromChallengeStart(
                _enrolledChallenge.enrollmentId,
                fromChallengeChange: true);
            _upcomingDetailsController.selectedEnrolledChallenge = _enrolledChallenge;
            await _upcomingDetailsController.updateChangedChallenge(fromChallenge: true);
          },
          itemCount: _upcomingDetailsController.upComingDetails.enrolChallengeList.length ?? 0,
          itemBuilder: (context, challengeIndex) {
            final _stepController = Get.put(HealthRepository());
            try {
              EnrolledChallenge _enrolledChallenge =
                  _upcomingDetailsController.upComingDetails.enrolChallengeList[challengeIndex];
              bool _started = DateTime.now().isAfter(_enrolledChallenge.challenge_start_time);
              var achivedPercentage;
              if (_enrolledChallenge.challengeMode != 'group') {
                achivedPercentage =
                    _enrolledChallenge.userAchieved * 100 / _enrolledChallenge.target;
              } else {
                achivedPercentage =
                    _enrolledChallenge.groupAchieved * 100 / _enrolledChallenge.target;
              }

              var challenegeUnit;
              if (_enrolledChallenge.challengeUnit == "kilometeres" ||
                  _enrolledChallenge.challengeUnit == "km") {
                challenegeUnit = "KM";
              } else if (_enrolledChallenge.challengeUnit == "meters" ||
                  _enrolledChallenge.challengeUnit == "m") {
                challenegeUnit = "M";
              } else {
                challenegeUnit = "steps";
              }
              if (_upcomingDetailsController.upComingDetails.enrolChallengeList.length < 1) {
                Get.put(HealthRepository()).caloriesCalculationFromChallengeStart(
                    _enrolledChallenge.enrollmentId,
                    fromChallengeChange: false);
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: challengeIndex == 0 ? 0 : 5.sp,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(children: [
                      FadeInImage.assetNetwork(
                        placeholder:
                            "newAssets/images/131474443-620d0777-5b42-4914-839d-e6250b083538.gif",
                        image: _enrolledChallenge.challengeImageUrl,
                        fit: BoxFit.cover,
                        height: 24.5.h,
                        width: double.infinity,
                      ),
                      Image(
                          height: 24.5.h,
                          width: double.infinity,
                          image: ImageAssets.shadowOverlay,
                          fit: BoxFit.fill),
                      GetBuilder<UpcomingDetailsController>(
                        init: UpcomingDetailsController(),
                        id: 'button_loading',
                        builder: (_upcomingDetail) {
                          return Visibility(
                            // visible: true,
                            visible: _enrolledChallenge.userProgress == null &&
                                _enrolledChallenge.selectedFitnessApp == 'google fit' &&
                                _enrolledChallenge.challengeMode != "group",
                            child: Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: InkWell(
                                  onTap: _started
                                      ? () async {
                                          _upcomingDetailsController.buttonLoading = true;
                                          _upcomingDetailsController.update(['button_loading']);
                                          await ChallengeApi().updateChallengeTarget(
                                            updateChallengeTarget: UpdateChallengeTarget(
                                              firstTime: true,
                                              enrollmentId: _enrolledChallenge.enrollmentId,
                                            ),
                                          );
                                          await _upcomingDetailsController.updateUpcomingDetails(
                                              fromChallenge: false);
                                          _upcomingDetailsController.buttonLoading = false;
                                          _upcomingDetailsController.update(['button_loading']);
                                        }
                                      : null,
                                  child: AnimatedContainer(
                                    curve: Curves.easeInOutCubic,
                                    alignment: Alignment.center,
                                    width: _upcomingDetailsController.buttonLoading ? 40 : 100,
                                    height: _upcomingDetailsController.buttonLoading ? 40 : 35,
                                    decoration: BoxDecoration(
                                      borderRadius: _upcomingDetailsController.buttonLoading
                                          ? BorderRadius.circular(50)
                                          : BorderRadius.circular(10),
                                      color: _started
                                          ? _upcomingDetailsController.buttonLoading
                                              ? Colors.transparent
                                              : (color != null
                                                  ? color
                                                  : _upcomingDetailsController.objectColor)
                                          : Colors.grey,
                                    ),
                                    duration: Duration(milliseconds: 600),
                                    child: _upcomingDetailsController.buttonLoading
                                        ? CircularProgressIndicator(
                                            color: color != null
                                                ? color
                                                : _upcomingDetailsController.objectColor,
                                          )
                                        : Text(
                                            'START NOW',
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w600,
                                                color: _started ? Colors.white : Colors.white),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 55.w,
                              child: Text(_enrolledChallenge.challenge_name,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.imageTextTitle),
                            ),
                            InkWell(
                              onTap:
                                  // _started && _enrolledChallenge.userProgress != null
                                  //     ?
                                  () async {
                                var _data = await ChallengeApi()
                                    .getSelfieImageData(enroll_id: _enrolledChallenge.enrollmentId);
                                var _groupMembers = [];
                                ChallengeDetail _challengeDetail = await ChallengeApi()
                                    .challengeDetail(challengeId: _enrolledChallenge.challengeId);
                                if (_enrolledChallenge.challengeMode == 'group') {
                                  _groupMembers = await ChallengeApi()
                                      .listofGroupUsers(groupId: _enrolledChallenge.groupId);
                                }
                                if (_data.length == 10) {
                                  const snackBar = SnackBar(
                                    content: Text('Image upload limit reached (Max: 10)'),
                                    duration: Duration(seconds: 3),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                } else if (_started && _enrolledChallenge.userProgress != null ||
                                    DateFormat('MM-dd-yyyy')
                                                .format(_enrolledChallenge.challenge_start_time) ==
                                            "01-01-2000" &&
                                        _enrolledChallenge.userProgress != null &&
                                        _data.length < 11 &&
                                        _enrolledChallenge.challengeMode != 'group' ||
                                    _enrolledChallenge.challengeMode == 'group' &&
                                        _groupMembers.length >= _challengeDetail.minUsersGroup) {
                                  var _enroll = await ChallengeApi()
                                      .getEnrollDetail(_enrolledChallenge.enrollmentId);
                                  _persistentGetXController.imageSelection(
                                      challengeDetail: _challengeDetail,
                                      isSelfi: true,
                                      enrollChallenge: _enroll);
                                } else if ((_started ||
                                        DateFormat('MM-dd-yyyy')
                                                .format(_enrolledChallenge.challenge_start_time) ==
                                            "01-01-2000") &&
                                    _enrolledChallenge.selectedFitnessApp == "other_apps" &&
                                    _data.length < 11) {
                                  ChallengeDetail _challengeDetail = await ChallengeApi()
                                      .challengeDetail(challengeId: _enrolledChallenge.challengeId);
                                  var _enroll = await ChallengeApi()
                                      .getEnrollDetail(_enrolledChallenge.enrollmentId);
                                  _persistentGetXController.imageSelection(
                                      challengeDetail: _challengeDetail,
                                      isSelfi: true,
                                      enrollChallenge: _enroll);
                                } else {
                                  const snackBar = SnackBar(
                                    content: Text('Challenge has not started yet. Stay tuned!'),
                                    duration: Duration(seconds: 3),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                }
                              },
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4.5.h,
                        child: Visibility(
                          visible: DateFormat('MM-dd-yyyy')
                                  .format(_enrolledChallenge.challenge_start_time) !=
                              "01-01-2000",
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Gap(14.sp),
                              Icon(
                                Icons.calendar_month,
                                size: 12.sp,
                                color: Colors.white,
                              ),
                              Gap(2.sp),
                              Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(_enrolledChallenge.challenge_start_time),
                                  style: AppTextStyles.nrmlText),
                              Gap(2.sp),
                              Icon(
                                Icons.access_time,
                                size: 12.sp,
                                color: Colors.white,
                              ),
                              Gap(2.sp),
                              Text(
                                  DateFormat('HH:mm')
                                      .format(_enrolledChallenge.challenge_start_time),
                                  style: AppTextStyles.nrmlText),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _enrolledChallenge.selectedFitnessApp == 'google fit',
                        child: Positioned(
                          left: 5.w,
                          right: 5.w,
                          top: 16.h,
                          child:
                              Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                            _enrolledChallenge.challengeMode != "group"
                                ? _enrolledChallenge.userAchieved > _enrolledChallenge.target
                                    ? Text(
                                        "${(challenegeUnit == 'steps' || challenegeUnit == 's') ? _enrolledChallenge.target.toStringAsFixed(0) : _enrolledChallenge.target.toStringAsFixed(2)} $challenegeUnit",
                                        style: AppTextStyles.nrmlText,
                                      )
                                    : Text(
                                        "${(challenegeUnit == 'steps' || challenegeUnit == 's') ? _enrolledChallenge.userAchieved.toStringAsFixed(0) : _enrolledChallenge.userAchieved.toStringAsFixed(2)} $challenegeUnit",
                                        style: AppTextStyles.nrmlText,
                                      )
                                : (_enrolledChallenge.groupAchieved > _enrolledChallenge.target ||
                                        _enrolledChallenge.userAchieved > _enrolledChallenge.target)
                                    ? Text(
                                        "${(challenegeUnit == 'steps' || challenegeUnit == 's') ? _enrolledChallenge.target.toStringAsFixed(0) : _enrolledChallenge.target.toStringAsFixed(2)} $challenegeUnit",
                                        style: AppTextStyles.nrmlText,
                                      )
                                    : Text(
                                        "${(challenegeUnit == 'steps' || challenegeUnit == 's') ? _enrolledChallenge.groupAchieved.toStringAsFixed(0) : _enrolledChallenge.groupAchieved.toStringAsFixed(2)} $challenegeUnit",
                                        style: AppTextStyles.nrmlText,
                                      ),
                            NeumorphicIndicator(
                              style: IndicatorStyle(
                                  variant: color != null
                                      ? color
                                      : _upcomingDetailsController.objectColor,
                                  accent: color != null
                                      ? color
                                      : _upcomingDetailsController.objectColor),
                              orientation: NeumorphicIndicatorOrientation.horizontal,
                              height: 1.4.h,
                              width: 75.w,
                              percent: achivedPercentage / 100,
                            ),
                          ]),
                        ),
                      ),
                      Visibility(
                        visible: _enrolledChallenge.selectedFitnessApp == 'google fit',
                        child: Positioned(
                            top: 21.h,
                            left: 2.w,
                            right: 2.w,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                              ),
                              child: Row(
                                children: [
                                  Image(
                                    image: ImageAssets.caloriesBurntIcon,
                                    height: 2.h,
                                    width: 7.w,
                                  ),
                                  GetBuilder<HealthRepository>(
                                      id: _stepController.caloryUpdate,
                                      builder: (_) {
                                        return Text(
                                          _.burnedCalories.toStringAsFixed(2),
                                          style: AppTextStyles.nrmlText,
                                        );
                                      }),
                                  Spacer(),
                                  Text("${_enrolledChallenge.target ?? "0"} $challenegeUnit",
                                      style: AppTextStyles.nrmlText),
                                ],
                              ),
                            )),
                      ),
                    ]),
                  ],
                ),
              );
            } catch (r) {
              return SizedBox();
            }
          }),
    );
  }
}
