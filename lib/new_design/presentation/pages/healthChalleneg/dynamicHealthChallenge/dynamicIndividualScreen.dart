import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/healthChalleneg/getX_widget_responsive/challange_ui_reponse.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../constants/api.dart';
import '../../../../../health_challenge/controllers/challenge_api.dart';
import '../../../../../health_challenge/models/challenge_detail.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../../health_challenge/models/enrolled_challenge.dart';
import '../../../../../health_challenge/models/sendInviteUserForChallengeModel.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text_styles.dart';
import '../../../../app/utils/appText.dart';
import '../../../../data/functions/healthChallengeFunctions.dart';
import '../../../clippath/subscriptionTagClipPath.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import '../blocWidget/challengeBloc.dart';
import '../blocWidget/challengeEvents.dart';
import '../blocWidget/challengeState.dart';
import '../widgets/on_going_challenge_widgets.dart';
import 'dynamicCertificateDetailScreen.dart';

class DynamicIndividualScreen extends StatelessWidget {
  final ChallengeDetail challengeDetail;
  EnrolledChallenge enrolledchallenge;
  bool firstTimeLog = false;
  DynamicIndividualScreen(
      {Key key, this.challengeDetail, this.enrolledchallenge, this.firstTimeLog})
      : super(key: key);
  int invitedEmailCount = 5;
  PageController scrollController = PageController();
  SessionSelectionController sessionSelectionController = Get.put(SessionSelectionController());

  TextEditingController _sendInviteEmailController = TextEditingController();
  String userName;
  RegExp emailRegExp =
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  emailValueCheck() {
    if (_sendInviteEmailController.value.text.isEmpty) {
      return null;
    } else if (!emailRegExp.hasMatch(_sendInviteEmailController.value.text)) {
      return "Invalid Email";
    } else
      return null;
  }

  calculateCompletedDate() {
    DateTime startDate = challengeDetail.challengeStartTime;
    DateTime endDate =
        startDate.add(Duration(days: int.parse(challengeDetail.challengeDurationDays)));
    if (enrolledchallenge != null) print('${enrolledchallenge.enrollmentId}');
    return DateFormat('dd MMM yyyy').format(endDate);
  }

  checkReferInviteCount(String challengeID) async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    String refer_by_email = prefs1.getString("email");
    var response = await ChallengeApi()
        .challengeReferInviteCount(challangeId: challengeID, refer_by_email: refer_by_email);
    if (response != null) {
      try {
        invitedEmailCount = 5 - int.parse(response);
      } catch (e) {}
    }
  }

  TextEditingController _stepsController = TextEditingController(text: "");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Rx<int> challengeDayImgBanner = 0.obs;
  @override
  Widget build(BuildContext context) {
    sessionSelectionController.isLoadinginSubmit.value=false;

    // sessionSelectionController.updateDayLoadingUpdate(false);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    calculateCompletedDate();
    return CommonScreenForNavigation(
        resizeToAvoidBottomInset: true,
        contentColor: "true",
        appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                Get.delete<SessionSelectionController>();

                Get.back();
              }, //replaces the screen to Main dashboard
              color: Colors.white,
            ),
            title: Text(
              challengeDetail.challengeName,
              style: AppTextStyles.appBarText,
            ),
            backgroundColor: AppColors.primaryColor),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 100.w,
            // height: 100.h,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  child: Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          print('TEST');
                          String _s =
                              "{\"feature_setting\":{\"health_jornal\":true,\"challenges\":true,\"news_letter\":true,\"ask_ihl\":true,\"hpod_locations\":false,\"teleconsultation\":false,\"online_classes\":false,\"my_vitals\":true,\"step_counter\":false,\"heart_health\":true,\"set_your_goals\":false,\"diabetics_health\":false,\"personal_data\":true,\"health_tips\":true}}";
                          var _p = jsonDecode(_s.replaceAll("&#39;", "\""));
                          _p['reminder'] = [
                            {'time': '03:00 PM', 'title': 'Set reminder title'}
                          ];
                          var response = await Dio()
                              .post('${API.iHLUrl}/healthchallenge/edit_reminder_detail', data: {
                            "enrollment_id": "enr_00de55dbeef341bc8518a0f337819c53",
                            "challenge_id": "hea_chal_9e94a433279c46f08eab1673e038e1ee",
                            "reminder_detail": jsonEncode(_p)
                          });
                          print(response.data);
                        },
                        child: Container(
                          height: 27.h,
                          width: 95.w,
                          decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 6)
                              ],
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(challengeDetail.challengeImgUrl))),
                        ),
                      ),
                      Positioned(
                        top: .5.h,
                        child: SizedBox(
                          child: ClipPath(
                            clipper: SubscriptionClipPath(),
                            child: Container(
                              height: 2.7.h,
                              width: 20.w,
                              color: AppColors.primaryAccentColor,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: GetBuilder<SessionSelectionController>(
                                      id: Get.put(SessionSelectionController()).dayTextUpdate,
                                      builder: (_) => Text(
                                        "${_.selectedDay}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Poppins',
                                            fontSize: 10.sp),
                                      )),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    width: 90.w,
                    child: Text(challengeDetail.challengeDescription.capitalizeFirst,
                        style: AppTextStyles.fontSize14b4RegularStyle)),

                onGoingchallengeLogDetails(
                    context,
                    challengeDetail,
                    firstTimeLog ? null : enrolledchallenge,
                    _stepsController,
                    firstTimeLog,
                    _formKey), //TODO need to pass enrollChallengeDetail
                GetBuilder<SessionSelectionController>(
                        id: sessionSelectionController.setReminder,
                        initState: (GetBuilderState<SessionSelectionController> v) async {
                          sessionSelectionController.getUserDetails(enrolledchallenge);
                        },
                        builder: (SessionSelectionController controller) {

                          return controller.reminderList == null
                              ||controller.reminderList.isEmpty
                                  ? SizedBox()
                                  : Visibility(
                            visible: challengeDetail.challengeRemaider && enrolledchallenge!=null,
                            child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: ScrollPhysics(),
                                        itemCount: controller.reminderList['reminder']?.length,
                                        itemBuilder: (ctx, i) {
                                          return controller.reminderList == null ||
                                                  controller.reminderList.isEmpty
                                              ? Padding(
                                                  padding: EdgeInsets.all(15.sp),
                                                  child: Shimmer.fromColors(
                                                      child: Container(
                                                          margin: EdgeInsets.all(8),
                                                          width: MediaQuery.of(context).size.width,
                                                          height:
                                                              MediaQuery.of(context).size.width / 5,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: Text('Hello')),
                                                      direction: ShimmerDirection.ltr,
                                                      period: Duration(seconds: 2),
                                                      baseColor: Colors.white,
                                                      highlightColor: Colors.grey.withOpacity(0.2)),
                                                )
                                              : Card(
                                                  elevation: 4,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(18.sp),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('Reminder ${i+1}',
                                                            style: TextStyle(
                                                                fontSize: 16.sp,
                                                                fontWeight: FontWeight.w700,
                                                                color: AppColors.primaryColor)),
                                                        Padding(
                                                          padding: EdgeInsets.all(10.sp),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Icon(
                                                                Icons.notifications_active,
                                                              ),
                                                              Spacer(),
                                                              Text(
                                                                  'Reminder alarm set at ${controller?.reminderList['reminder'][i]['time']} ',
                                                                  style:TextStyle(
                                                                    fontFamily: 'Poppins',
                                                                    fontSize: 15.5.sp,
                                                                    fontWeight: FontWeight.w500,
                                                                  )
                                                                  ),
                                                              Spacer(),
                                                              GestureDetector(
                                                                onTap: () async {
                                                                  EnrolledChallenge enroll =
                                                                      await ChallengeApi()
                                                                          .getEnrollDetail(
                                                                              enrolledchallenge
                                                                                  .enrollmentId);
                                                                  TimeOfDay picked =
                                                                      await showTimePicker(
                                                                    confirmText: 'EDIT SET',
                                                                    context: context,
                                                                    initialTime: TimeOfDay.now(),
                                                                  );
                                                                  List<Map<String, dynamic>> myList =
                                                                      [
                                                                    {
                                                                      'time':
                                                                          '${picked.hour}:${picked.minute} ${picked.hour >= 12 ? 'PM' : 'AM'}',
                                                                      'title': 'Set reminder title'
                                                                    }
                                                                  ];
                                                                  List _d = [];

                                                                  String _s =
                                                                      "{\"feature_setting\":{\"health_jornal\":true,\"challenges\":true,\"news_letter\":true,\"ask_ihl\":true,\"hpod_locations\":false,\"teleconsultation\":false,\"online_classes\":false,\"my_vitals\":true,\"step_counter\":false,\"heart_health\":true,\"set_your_goals\":false,\"diabetics_health\":false,\"personal_data\":true,\"health_tips\":true}}";
                                                                  if (enroll.reminder_detail ==
                                                                          "&quot;&quot;" ||
                                                                      enroll.reminder_detail ==
                                                                          "null") {
                                                                    enroll.reminder_detail = _s;
                                                                  }
                                                                  Map _p = jsonDecode(enroll
                                                                      .reminder_detail
                                                                      .replaceAll("&quot;", "\""));
                                                                  if (_p
                                                                      .toString()
                                                                      .contains('reminder')) {
                                                                   print('=======$_p');
                                                                  }
                                                                  // var response = await Dio().post(
                                                                  //     '${API.iHLUrl}/healthchallenge/edit_reminder_detail',
                                                                  //     data: {
                                                                  //       "enrollment_id":
                                                                  //           enrolledchallenge
                                                                  //               .enrollmentId,
                                                                  //       "challenge_id":
                                                                  //           challengeDetail
                                                                  //               .challengeId,
                                                                  //       "reminder_detail":
                                                                  //           jsonEncode(_p)
                                                                  //     });
                                                                  // print(response.data);
                                                                  await sessionSelectionController
                                                                      .getUserDetails(
                                                                          enrolledchallenge);
                                                                  print(
                                                                      '${picked.hour}:${picked.minute} ${picked.hour >= 12 ? 'PM' : 'AM'}');
                                                                },
                                                                child: Icon(
                                                                  Icons.edit,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                         }),
                                  );
                        }),
                enrolledchallenge == null
                    ? SizedBox()
                    : Padding(
                        padding: EdgeInsets.only(top: 3.h, left: 5.w),
                        child: Row(
                          children: <Widget>[
                            Text(AppTexts.yourInsightTex,
                                style: AppTextStyles.fontSize14V4RegularStyle),
                            const Spacer()
                          ],
                        ),
                      ),
                enrolledchallenge == null
                    ? SizedBox()
                    : GetBuilder<SessionSelectionController>(
                        id: sessionSelectionController.scrollUpdateId,
                        initState: (v) async {
                          await sessionSelectionController.firstDateGetter(
                              enrolledchallenge, challengeDetail);
                          scrollController.animateTo(
                            sessionSelectionController.isDaySelected.toDouble() * 12.w,
                            duration: Duration(seconds: 3),
                            curve: Curves.fastOutSlowIn,
                          );
                        },
                        builder: (SessionSelectionController controller) {
                          return SizedBox(
                            width: 100.w,
                            child: Padding(
                              padding: EdgeInsets.all(12.sp),
                              child: Card(
                                elevation: 4,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                        onTap: () => scrollController.previousPage(
                                            duration: const Duration(
                                              milliseconds: 1500,
                                            ),
                                            curve: Curves.easeInOut),
                                        child: const Icon(Icons.arrow_left_outlined)),
                                    SizedBox(
                                      height: 16.h,
                                      width: 76.w,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          controller: scrollController,
                                          itemCount: controller.userLogData.length,
                                          itemBuilder: (BuildContext ctx, int index) {
                                            return challengeDetail.mileStoneTotalTarget == null
                                                ? Column(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 10.sp),
                                                        child: Text("Day ${index + 1}",
                                                            style: AppTextStyles
                                                                .fontSize14b4RegularStyle),
                                                      ),
                                                      Container(
                                                        height: 9.h,
                                                        width: 15.w,
                                                        decoration: BoxDecoration(
                                                            color: controller.userLogData[index]
                                                                    ['logged']
                                                                ? AppColors.greenColor
                                                                    .withOpacity(0.75)
                                                                : controller.userLogData[index]
                                                                        ['expired']
                                                                    ? AppColors.failure
                                                                        .withOpacity(0.60)
                                                                    : AppColors.lightTextColor
                                                                        .withOpacity(0.40),
                                                            borderRadius: BorderRadius.circular(1)),
                                                        margin: EdgeInsets.symmetric(
                                                            vertical: 0.5.h, horizontal: 1.5.w),
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(
                                                              vertical: 1.5.h, horizontal: 3.w),
                                                          child: Center(
                                                              child: controller.userLogData[index]
                                                                      ['logged']
                                                                  ? Icon(
                                                                      Icons.check,
                                                                      size: 40.0,
                                                                      color: Colors.white,
                                                                    )
                                                                  : controller.userLogData[index]
                                                                          ['expired']
                                                                      ? Icon(
                                                                          Icons.close,
                                                                          size:
                                                                              40.0, // You can adjust the size as needed
                                                                          color: Colors
                                                                              .white, // You can set the color as needed
                                                                        )
                                                                      : null),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Column(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 10.sp),
                                                        child: Text("Day ${index + 1}",
                                                            style: AppTextStyles
                                                                .fontSize14b4RegularStyle),
                                                      ),
                                                      Container(
                                                        height: 9.h,
                                                        width: 16.w,
                                                        decoration: BoxDecoration(
                                                            color: controller.userLogData[index]
                                                                    ['logged']
                                                                ? AppColors.greenColor
                                                                    .withOpacity(0.75)
                                                                : controller.userLogData[index]
                                                                        ['expired']
                                                                    ? AppColors.failure
                                                                        .withOpacity(0.60)
                                                                    : AppColors.lightTextColor
                                                                        .withOpacity(0.40),
                                                            borderRadius: BorderRadius.circular(1)),
                                                        margin: EdgeInsets.symmetric(
                                                            vertical: 0.5.h, horizontal: 1.5.w),
                                                        child: Center(
                                                          child: Padding(
                                                            padding: EdgeInsets.symmetric(
                                                                vertical: 1.5.h, horizontal: 3.w),
                                                            child: Text(
                                                                "${enrolledchallenge == null || enrolledchallenge.enrollmentId.isEmpty ? "0" : "${controller.userLogData[index]['achieved']}"}\n${challengeDetail.challengeUnit=="Minutes"?'mins':challengeDetail.challengeUnit=="Hours"?'hrs':'ml'}",
                                                                textAlign: TextAlign.center,
                                                                style:
                                                                    AppTextStyles.contentSmallText),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                          }),
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          scrollController.nextPage(
                                              duration: const Duration(milliseconds: 1500),
                                              curve: Curves.easeInOut);
                                        },
                                        child: const Icon(Icons.arrow_right_outlined)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
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
                            const SizedBox(
                              width: 1,
                            ),
                            Text(
                                challengeDetail.challengeMode == "individual"
                                    ? "Send invite"
                                    : "Send invite",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                            // Expanded(
                            //   flex: 1,
                            //   child: Icon(
                            //     Icons.play_arrow,
                            //     color: Colors.white,
                            //   ),
                            // )
                            const SizedBox(
                              width: 1,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        // height: 15.h,
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
                              height: 15,
                            ),
                            Text(
                              "Invite up-to 5 family members\n ($invitedEmailCount/5 invite left)",
                              style: TextStyle(
                                  fontSize: height > 568 ? 14.sp : 16.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  color: Colors.blueGrey),
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              // padding:  EdgeInsets.only(left: 3.w,right: 3.w),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),

                              child: Material(
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                elevation: 2,
                                child: TextField(
                                  controller: _sendInviteEmailController,
                                  //keyboardType: TextInputType.emailAddress,
                                  // inputFormatters: [
                                  //   FilteringTextInputFormatter.allow(
                                  //       RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))
                                  // ],
                                  decoration: InputDecoration(
                                    // suffixIcon: Icon(
                                    //   Icons.edit,
                                    //   color: Colors.black45,
                                    // ),
                                    errorText: emailValueCheck(),

                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                                    hintText: "Email of friends/family member",
                                    hintStyle: TextStyle(color: Colors.black26, fontSize: 16.sp),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 0.5.h,
                            ),
                            SizedBox(
                              height: 5.h,
                              width: 30.w,
                              child: ElevatedButton(
                                child: Text('Invite',
                                    style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                        fontFamily: 'Popins',
                                        color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  primary: invitedEmailCount == 5
                                      ? AppColors.primaryAccentColor
                                      : (!_sendInviteEmailController.value.text.isEmpty &&
                                              !_sendInviteEmailController.value.text.isEmpty &&
                                              emailRegExp
                                                  .hasMatch(_sendInviteEmailController.value.text))
                                          ? AppColors.primaryAccentColor
                                          : Colors.grey,
                                ),
                                onPressed: () {
                                  if (!_sendInviteEmailController.value.text.isEmpty &&
                                      emailRegExp.hasMatch(_sendInviteEmailController.value.text)) {
                                    HealthChallengeFunctions.inviteThroughEmailApiCall(
                                        challengeDetail.challengeId,
                                        '',
                                        _sendInviteEmailController.value.text,
                                        invitedEmailCount,
                                        _sendInviteEmailController);
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                " By inviting your friends / family members will receive an welcome Email to download hCare APP subsequently, when they register with same Email Id they get access to this challenge.",
                                style: TextStyle(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                    color: Colors.blueGrey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
                )
              ],
            ),
          ),
        ));
  }
}
