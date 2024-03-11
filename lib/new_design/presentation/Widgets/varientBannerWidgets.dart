import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/controllers/challenge_api.dart';
import 'package:ihl/new_design/data/providers/network/apis/socialApiCalls/challengeInviteApiandFunctionalities.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../Getx/controller/BannerChallengeController.dart';
import '../../../Getx/controller/listOfChallengeContoller.dart';
import '../../../health_challenge/models/enrolled_challenge.dart';
import '../../../health_challenge/models/group_details_model.dart';
import '../../../health_challenge/models/list_of_users_in_group.dart';
import '../../../health_challenge/persistent/views/persistent_onGoingScreen.dart';
import '../../../health_challenge/views/certificate_detail.dart';
import '../../../health_challenge/views/challenge_details_screen.dart';
import '../../../health_challenge/views/on_going_challenge.dart';
import '../../app/utils/appColors.dart';
import '../../app/utils/textStyle.dart';
import '../../data/model/Banner/BannerChallengeModel.dart';
import 'bannerInviteBottomSheet.dart';
import 'dashboardWidgets/affiliation_widgets.dart';

class VariantBannerWidget {
  static Widget bannerWidget(
    BannerChallengeController bannerChallengeController,
    ListChallengeController listChallengeController,
  ) {
    return Padding(
      padding:  EdgeInsets.all(6.sp),
      child: GetBuilder<BannerChallengeController>(
        id: bannerChallengeController.BANNERCHALLENGEUPDATE,
        initState: (_) => bannerChallengeController.getChallenges(),
        builder: (_) {
          if (_.bannerChallenges.isNotEmpty) {
            return AnimatedContainer(
              margin: EdgeInsets.only(top: 2.5.h),
              width: 100.w,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              duration: const Duration(milliseconds: 800),
              height: _.inviteVisible ? 30.5.h : 27.h,
              child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  padEnds: false,
                  itemCount: _.bannerChallenges.length == 0 ? 0 : 1,
                  onPageChanged: (index) async {
                    List<Datum> _list = _.bannerChallenges[index]['data'];

                    _.inviteVisible = _.bannerChallenges[index]['invite'];
                    await _.inviteCount(_list[0].challengeId);

                    // _.inviteVisible = !_.inviteVisible;
                    _.update([bannerChallengeController.BANNERCHALLENGEUPDATE]);
                  },
                  controller: PageController(initialPage: 0, keepPage: true, viewportFraction: .95),
                  itemBuilder: (ctx, index) {
                    Datum challenge;
                    List<Datum> _list = _.bannerChallenges[index]['data'];
                    _.inviteVisible = _.bannerChallenges[index]['invite'];

                    bool _inviteVisible = _.bannerChallenges[index]['invite'];
                    return ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 8.sp,left: 15.sp,right: 3.sp),
                          height: 16.h,
                          width: 100.w,
                          // margin: EdgeInsets.only(top: 5.sp, right: 5.sp, left: 5.sp),
                          child: Image.network(
                            _list[0].bannerImgUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: Shimmer.fromColors(
                                    direction: ShimmerDirection.ltr,
                                    period: const Duration(seconds: 2),
                                    baseColor: const Color.fromARGB(255, 240, 240, 240),
                                    highlightColor: Colors.grey.withOpacity(0.2),
                                    child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.width / 3,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text('Hello'))),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.sp,left: 15.sp,right: 3.sp),
                          child: GetBuilder<BannerChallengeController>(
                              id: 'challengeUpdate',
                              builder: (_) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  height: 6.h,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 208, 208, 212),
                                        blurRadius: 1.0,
                                        offset: Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  // margin: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 6.sp),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4.sp,
                                    horizontal: 10.sp,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      value: challenge,
                                      hint: const Text('Select Challenge'),
                                      isDense: true,
                                      items: _list.map((items) {
                                        return DropdownMenuItem(
                                          value: items,
                                          child: Text(
                                            '${items.challengeName}',
                                            style: TextStyle(fontSize: 11.sp),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (Datum newValue) async {
                                        challenge = newValue;
                                        _.update(['challengeUpdate']);
                                        var _challengeDetail = await ChallengeApi()
                                            .challengeDetail(challengeId: challenge.challengeId);
                                        var _enrollChallenge = _.enrollList.where((element) =>
                                            element.challengeId == _challengeDetail.challengeId);

                                        if (_enrollChallenge.isNotEmpty) {
                                          EnrolledChallenge _enrol = await ChallengeApi()
                                              .getEnrollDetail(_enrollChallenge.first.enrollmentId);
                                          if (_enrol.userProgress == 'completed') {
                                            if (_enrol.challengeMode == 'individual') {
                                              Get.to(CertificateDetail(
                                                challengeDetail: _challengeDetail,
                                                enrolledChallenge: _enrol,
                                                groupDetail: null,
                                                currentUserIsAdmin: false,
                                                firstCopmlete: false,
                                              ));
                                            } else {
                                              bool currentUserIsAdmin = false;
                                              GroupDetailModel groupDetailModel;
                                              String userid = bannerChallengeController.userId;
                                              await ChallengeApi()
                                                  .listofGroupUsers(groupId: _enrol.groupId)
                                                  .then((value) {
                                                for (var i in value) {
                                                  if (i.userId == userid && i.role == "admin") {
                                                    currentUserIsAdmin = true;
                                                    break;
                                                  }
                                                }
                                              });
                                              groupDetailModel = await ChallengeApi()
                                                  .challengeGroupDetail(groupID: _enrol.groupId);
                                              Get.to(CertificateDetail(
                                                challengeDetail: _challengeDetail,
                                                enrolledChallenge: _enrol,
                                                groupDetail: groupDetailModel,
                                                currentUserIsAdmin: currentUserIsAdmin,
                                                firstCopmlete: false,
                                              ));
                                            }
                                          } else {
                                            GroupDetailModel _groupDetailModel;
                                            if (_enrol.challengeMode != 'individual') {
                                              _groupDetailModel = await ChallengeApi()
                                                  .challengeGroupDetail(groupID: _enrol.groupId);
                                              List<GroupUser> liGroup = await ChallengeApi()
                                                  .listofGroupUsers(
                                                      groupId: _groupDetailModel.groupId);
                                              if (liGroup.length < _challengeDetail.minUsersGroup) {
                                                Get.defaultDialog(
                                                    barrierDismissible: false,
                                                    backgroundColor: Colors.lightBlue.shade50,
                                                    title:
                                                        'The challenge will commence once at least ${_challengeDetail.minUsersGroup} participants join.',
                                                    titlePadding: EdgeInsets.only(
                                                        top: 18.sp,
                                                        bottom: 0,
                                                        left: 11.sp,
                                                        right: 11.sp),
                                                    titleStyle: TextStyle(
                                                        letterSpacing: 1,
                                                        color: Colors.blue.shade400,
                                                        fontSize: 19.sp),
                                                    content: Column(
                                                      children: [
                                                        const Divider(
                                                          thickness: 2,
                                                        ),
                                                        Icon(
                                                          Icons.task_alt,
                                                          size: 40,
                                                          color: Colors.blue.shade300,
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(Get.context);
                                                          },
                                                          child: Container(
                                                            width: MediaQuery.of(Get.context)
                                                                    .size
                                                                    .width /
                                                                4,
                                                            decoration: BoxDecoration(
                                                                color: Colors.blue,
                                                                borderRadius:
                                                                    BorderRadius.circular(20)),
                                                            child: const Center(
                                                              child: Padding(
                                                                padding: EdgeInsets.all(8.0),
                                                                child: Text(
                                                                  'Ok',
                                                                  style:
                                                                      TextStyle(color: Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ));
                                              } else {
                                                Get.to(OnGoingChallenge(
                                                    challengeDetail: _challengeDetail,
                                                    navigatedNormal: true,
                                                    groupDetail: _groupDetailModel,
                                                    filteredList: _enrol));
                                              }
                                            } else if (_enrol.challengeMode == 'individual') {
                                              if (_enrol.selectedFitnessApp == 'google fit') {
                                                Get.to(OnGoingChallenge(
                                                    challengeDetail: _challengeDetail,
                                                    navigatedNormal: true,
                                                    groupDetail: _groupDetailModel,
                                                    filteredList: _enrol));
                                              } else {
                                                Get.to(PersistentOnGoingScreen(
                                                  challengeDetail: _challengeDetail,
                                                  challengeStarted: true,
                                                  enrolledChallenge: _enrol,
                                                  nrmlJoin: true,
                                                ));
                                              }
                                            }
                                          }
                                        } else {
                                          Get.to(ChallengeDetailsScreen(
                                            challengeDetail: _challengeDetail,
                                            fromNotification: false,
                                          ));
                                          print('New Challenge');
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }),
                        ),
                        Visibility(
                          visible: _inviteVisible,
                          child: Padding(
                            padding:  EdgeInsets.all(4.sp),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: 48.w,
                                      child: Text('Invite your friends & family',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 10.sp,
                                            color: const Color(0xde000000),
                                          )),
                                    ),
                                    Obx(() => Text("(${_.invited.value}/5 invite left)",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11.sp,
                                          letterSpacing: 0.6,
                                        ),
                                        textAlign: TextAlign.center)),
                                  ],
                                ),
                                InkWell(
                                  onTap: () => showModalBottomSheet<void>(
                                    backgroundColor: Colors.transparent,
                                    context: Get.context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return BannerInviteBottomSheet().bottomSheetContentInvite(
                                          challengeName: _list[0].challengeName,
                                          challengeId: _list[0].challengeId,
                                          bannerChallengeController: bannerChallengeController,
                                          index: index,
                                          context: context);
                                    },
                                  ),
                                  child: Container(
                                      padding:  EdgeInsets.all(4.sp),
                                      decoration: BoxDecoration(
                                          color: AppColors.ihlPrimaryColor,
                                          borderRadius: BorderRadius.circular(4)),
                                      child: Center(
                                        child: Text('SEND INVITE', style: AppTextStyles.sendInvite),
                                      )),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  }),
            );
          } else if (_.loading) {
            return Shimmer.fromColors(
                direction: ShimmerDirection.ltr,
                period: const Duration(seconds: 2),
                baseColor: const Color.fromARGB(255, 240, 240, 240),
                highlightColor: Colors.grey.withOpacity(0.2),
                child: Container(
                    margin: EdgeInsets.all(8.sp),
                    width: 90.w,
                    height: 15.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Hello')));
          } else {
            return const SizedBox(
              height: 0,
            );
          }
        },
      ),
    );
  }
}
