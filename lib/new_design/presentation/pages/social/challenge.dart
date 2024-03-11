import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../health_challenge/views/dynamic_enrolled_health_challenge.dart';
import '../../../../health_challenge/views/dynamic_health_challenge_types.dart';
import '../../controllers/healthchallenge/dynamicHealthChallengeController.dart';
import '../home/landingPage.dart';
import '../../../data/model/SocialdashboardModels/affiliationFlagModel.dart';
import '../../../../health_challenge/controllers/challenge_api.dart';
import '../../../../health_challenge/models/challenge_detail.dart';
import '../../../../health_challenge/models/enrolled_challenge.dart';
import '../../../../health_challenge/views/achived_challenge.dart';
import '../../../app/utils/appText.dart';
import '../../../app/utils/textStyle.dart';
import '../../Widgets/appBar.dart';
import '../../Widgets/varientBannerWidgets.dart';
import '../dashboard/affiliation_dashboard/affiliationDasboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../../Getx/controller/BannerChallengeController.dart';
import '../../../../Getx/controller/listOfChallengeContoller.dart';
import '../../../../health_challenge/models/group_details_model.dart';
import '../../../../health_challenge/views/certificate_detail.dart';
import '../../../../health_challenge/views/enrolled_challenges_list_screen.dart';
import '../../../app/utils/appColors.dart';

import '../../Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../Widgets/healthChallengeCard.dart';
import '../../Widgets/staticChallengeCard.dart';
import '../../controllers/dashboardControllers/upComingDetailsController.dart';
import '../home/home_view.dart';

class ChallengeScreenSocial extends StatefulWidget {
  const ChallengeScreenSocial({Key key}) : super(key: key);

  @override
  State<ChallengeScreenSocial> createState() => _ChallengeScreenSocialState();
}

class _ChallengeScreenSocialState extends State<ChallengeScreenSocial> {
  List<AffiliationFlagModel> affiliationFlagModel = [];
  final BannerChallengeController _bannerController = Get.put(BannerChallengeController());
  final ListChallengeController _listofChallengeController = Get.put(ListChallengeController());

  bool challengeProgress = false;
  @override
  void initState() {
    super.initState();
    challengeListOnly();
    Future<void>.delayed(const Duration(seconds: 1), () {
      setState(() {
        challengeProgress = true;
      });
    });
    _upcomingDetailsController = Get.put(UpcomingDetailsController());
  }

  final PageController scrollPage =
      PageController(initialPage: 0, keepPage: true, viewportFraction: .95);

  List<ChallengeDetailWithBadges> completedChallengesWithBadges = [];
  UpcomingDetailsController _upcomingDetailsController;
  bool completedExistence = false;
  String uniqueNme;
  void challengeListOnly() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    completedChallengesWithBadges = <ChallengeDetailWithBadges>[];
    uniqueNme =
        UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] ?? "global";
    String userid = prefs.getString("ihlUserId");
    List<EnrolledChallenge> userEnrolledChallenge =
        await ChallengeApi().listofUserEnrolledChallenges(userId: userid);
    for (EnrolledChallenge e in userEnrolledChallenge) {
      if (e.userProgress == 'completed') {
        completedExistence = true;
        ChallengeDetail challengeDetail =
            await ChallengeApi().challengeDetail(challengeId: e.challengeId);
        GroupDetailModel groupDetailModel;
        if (e.challengeMode != "individual") {
          groupDetailModel = await ChallengeApi().challengeGroupDetail(groupID: e.groupId);
        }
        completedChallengesWithBadges.add((ChallengeDetailWithBadges(
            challengeName: challengeDetail.challengeName,
            image: challengeDetail.challengeImgUrlThumbnail,
            challengeDesc: challengeDetail.challengeDescription,
            challengeDetail: challengeDetail,
            challengeId: e.challengeId,
            enrollmentId: e.enrollmentId,
            challengeMode: e.challengeMode,
            groupDetailModel: groupDetailModel)));
      }
    }
    completedChallengesWithBadges.retainWhere((ChallengeDetailWithBadges element) =>
        element.challengeDetail.affiliations.contains(uniqueNme));
    print("participated challenge lenght => ${completedChallengesWithBadges.length}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool aff = false;
    double width = MediaQuery.of(context).size.width;
    // final _tabController = Get.put(TabBarController());
    return WillPopScope(
        onWillPop: () async {
          await Get.to(LandingPage());
          return false;
        },
        child: Container(
          alignment: Alignment.center,
          height: 100.h,
          child: !Tabss.featureSettings.challenges
              ? const Text("Oops! There are no challenges available right now.")
              : ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.sp),
                      child: Text('Health Challenges', style: AppTextStyles.HealthChallengeTitle),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.sp),
                      child: Text(AppTexts.healthChallengeDescription,
                          style: AppTextStyles.HealthChallengeDescription),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.sp),
                      child: Text('Challenge Types', style: AppTextStyles.HealthChallengeTitle),
                    ),
      // Container(
      //   padding: EdgeInsets.all(8.sp),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: const [
      //       StaticChallengeCard(
      //         enable: true,
      //         imagePath: 'newAssets/Icons/stepsChallenge.png',
      //         title: 'Step Challenge',
      //       ),
      //       StaticChallengeCard(
      //         enable: false,
      //         imagePath: 'newAssets/Icons/weightChallenge.png',
      //         title: 'Other Challenges',
      //       ),
      //     ],
      //   ),),
      //               GetBuilder<ListChallengeController>(
      //                   builder: (ListChallengeController controller) {
      //                     return SingleChildScrollView(
      //                        scrollDirection: Axis.horizontal,
      //                       child: controller.getChallengeCategoryList==null?SizedBox():
      //                       GetBuilder<DynamicHealthChallengeController>(
      //                           init: DynamicHealthChallengeController(),
      //                           // id: _dynhealthChallengeController.fetchId,
      //                           builder: (_) {
      //                             return Padding(
      //                         padding:  EdgeInsets.only(left:2.sp),
      //                         child: Row(
      //                                 children: controller.getChallengeCategoryList.status.toSet().toList()
      //                                     .map((e) => GestureDetector(
      //                                   onTap: ()async
      //                                   {
      //                                     SharedPreferences prefs1 = await SharedPreferences.getInstance();
      //                                     String userid = prefs1.getString("ihlUserId");
      //                                     if(_.sortedEnrolledCompleted==null||_.listofChallenges==null){
      //                                       Get.to(DynamicHealthChallengesComponents(challengeCategory: e,));
      //                                     }
      //                                     else {
      //                                       _.sortedEnrolledCompleted == null &&
      //                                           _.sortedEnrolledCompleted.started.isEmpty &&
      //                                           _.sortedEnrolledCompleted.notStarted.isEmpty &&
      //                                           _.sortedEnrolledCompleted.completed.isEmpty ? Get
      //                                           .to(DynamicHealthChallengeTypes(
      //                                         challengeCategory: e,
      //                                       )) : _.listofChallenges.isEmpty &&
      //                                           _.sortedEnrolledCompleted.completed.isEmpty ? Get
      //                                           .to(DynamicEnrolledChallengesListScreen(
      //                                         challengeCategory: e,
      //                                         uid: userid,
      //                                       )) : _.listofChallenges.isEmpty &&
      //                                           _.sortedEnrolledCompleted.started.isEmpty &&
      //                                           _.sortedEnrolledCompleted.notStarted.isEmpty ?
      //                                       Get.to(AchievedChallengesListScreen(
      //                                           uid: userid,
      //                                           challengeCategory: e
      //                                       )) : Get.to(DynamicHealthChallengesComponents(
      //                                         challengeCategory: e,));
      //                                     } },
      //                                       child: SizedBox(height: 21.h,
      //                                         width: 60.w,
      //                                         child: Card(
      //                                   elevation: 4,
      //                                   child:Container(
      //                                     height: 100.h < 800 ? 28.h : 22.h,
      //                                     width: 45.w,
      //                                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      //                                     child: Padding(
      //                                       padding: EdgeInsets.only(top: 5.sp),
      //                                       child: Column(
      //                                         children: [
      //                                           e.contains('Step')?Image.asset('newAssets/Icons/stepsChallenge.png'):e.contains('Meditation')?Container(
      //                                               padding:  const EdgeInsets.fromLTRB(16, 0, 0, 0),
      //                                               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      //                                               height:11.8.h,child: Image.asset('newAssets/Icons/meditation.png')):Container(
      //                                               padding:  EdgeInsets.fromLTRB(16, 0, 0, 0),
      //                                               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),height:11.8.h,width:72.w,child: Image.asset('newAssets/Icons/waterdrinking.png')),
      //
      //                                           SizedBox(
      //                                             height: 2.h,
      //                                           ),
      //                                           Text(
      //                                             e,
      //                                             style: AppTextStyles.HealthChallengeDescription,
      //                                           )
      //                                         ],
      //                                       ),
      //                                     ),
      //                                   ),
      //                                   // Row(
      //                                   //     crossAxisAlignment: CrossAxisAlignment.center,
      //                                   //     mainAxisAlignment: MainAxisAlignment.center,
      //                                   //       children: [
      //                                   //         Padding(
      //                                   //           padding: const EdgeInsets.all(8.0),
      //                                   //           child: SizedBox(
      //                                   //             height: width / 9,
      //                                   //             width: width / 9,
      //                                   //             child: Image.asset(e.contains('Step')?'newAssets/Icons/stepsChallenge.png':'assets/icons/exercise.png'),
      //                                   //             // decoration: BoxDecoration(
      //                                   //             // borderRadius: BorderRadius.circular(10),
      //                                   //             //     // image: DecorationImage(
      //                                   //             //     //     fit: BoxFit.cover,
      //                                   //             //     //     image: NetworkImage(challengeDetail.challengeImgUrlThumbnail))
      //                                   //             // ),
      //                                   //           ),
      //                                   //         ),
      //                                   //         SizedBox(
      //                                   //           width: width / 60,
      //                                   //         ),
      //                                   //         Padding(
      //                                   //           padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
      //                                   //           child: FittedBox(
      //                                   //             fit: BoxFit.fill,
      //                                   //             child: Text(e,
      //                                   //                 style: const TextStyle(
      //                                   //                     fontSize: 16,
      //                                   //                     fontWeight: FontWeight.w600,
      //                                   //                     letterSpacing: 1,
      //                                   //                     color: Colors.blueGrey)),
      //                                   //           ),
      //                                   //         ),
      //                                   //       ],
      //                                   // ),
      //                                 ),
      //                                       ),
      //                                     ),)
      //                                     .toList()),
      //                       );})
      //                     );
      //                   }
      //               ),
      Container(
        padding: EdgeInsets.all(8.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            StaticChallengeCard(
              enable: true,
              imagePath: 'newAssets/Icons/stepsChallenge.png',
              title: 'Step Challenge',
            ),
            StaticChallengeCard(
              enable: false,
              imagePath: 'newAssets/Icons/weightChallenge.png',
              title: 'Other Challenges',
            ),
          ],
        ),
      ),
                    // Visibility(
                    //   visible: true,
                    //   child: SizedBox(
                    //     width: 100.w,
                    //     height: 63.w,
                    //     child: PageView.builder(
                    //         scrollDirection: Axis.horizontal,
                    //         padEnds: false,
                    //         controller: scrollPage,
                    //         itemCount: affiliationFlagModel.length,
                    //         itemBuilder: (ctx, index) {
                    //           return ValueListenableBuilder(
                    //               valueListenable:
                    //                   ChallengeInviteAndFunctions.invitedEmailCountlist[index],
                    //               builder: (context, child, i) {
                    //                 return Padding(
                    //                   padding: const EdgeInsets.only(left: 8),
                    //                   child: InkWell(
                    //                     onTap: () {
                    //                       Get.to(AllChallengeTypeScreen());
                    //                     },
                    //                     child: Container(
                    //                       width: 85.w,
                    //                       padding: EdgeInsets.only(
                    //                           top: 1.5.h, bottom: 2.h, left: 2.w, right: 2.w),
                    //                       decoration: BoxDecoration(
                    //                           color: Colors.white,
                    //                           borderRadius: BorderRadius.circular(5)),
                    //                       child: Column(
                    //                         crossAxisAlignment: CrossAxisAlignment.start,
                    //                         mainAxisAlignment: MainAxisAlignment.start,
                    //                         children: [
                    //                           Container(
                    //                             height: 18.h,
                    //                             width: 100.w,
                    //                             child: affiliationFlagModel[index]
                    //                                         .data
                    //                                         .first
                    //                                         .bannerImgUrl ==
                    //                                     null
                    //                                 ? Image.asset(
                    //                                     'newAssets/Icons/challengePic.png',
                    //                                     fit: BoxFit.cover,
                    //                                   )
                    //                                 : Image.network(
                    //                                     affiliationFlagModel[index]
                    //                                         .data
                    //                                         .first
                    //                                         .bannerImgUrl,
                    //                                     fit: BoxFit.cover,
                    //                                   ),
                    //                           ),
                    //                           Row(
                    //                             children: [
                    //                               Column(
                    //                                 children: [
                    //                                   Padding(
                    //                                     padding: const EdgeInsets.all(8.0),
                    //                                     child: SizedBox(
                    //                                       width: 48.w,
                    //                                       child: Text('Invite your friends & family',
                    //                                           textAlign: TextAlign.center,
                    //                                           style: TextStyle(
                    //                                             fontFamily: 'Poppins',
                    //                                             fontSize: 12.sp,
                    //                                             color: const Color(0xde000000),
                    //                                           )),
                    //                                     ),
                    //                                   ),
                    //                                   Text(
                    //                                       "(${ChallengeInviteAndFunctions.invitedEmailCountlist[index].value}/5 invite left)",
                    //                                       style: TextStyle(
                    //                                         color: Colors.black,
                    //                                         fontWeight: FontWeight.w500,
                    //                                         fontSize: 11.sp,
                    //                                         letterSpacing: 0.6,
                    //                                       ),
                    //                                       textAlign: TextAlign.center),
                    //                                 ],
                    //                               ),
                    //                               Spacer(),
                    //                               Column(
                    //                                 children: [
                    //                                   SizedBox(
                    //                                     height: 10,
                    //                                   ),
                    //                                   InkWell(
                    //                                     onTap: () => showModalBottomSheet<void>(
                    //                                       backgroundColor: Colors.transparent,
                    //                                       context: context,
                    //                                       isScrollControlled: true,
                    //                                       builder: (BuildContext context) {
                    //                                         return bottomSheetContentInvite(
                    //                                             challengeDetails:
                    //                                                 affiliationFlagModel[index]
                    //                                                     .data
                    //                                                     .first,
                    //                                             index: index,
                    //                                             context: context);
                    //                                       },
                    //                                     ),
                    //                                     child: Container(
                    //                                         padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                    //                                         decoration: BoxDecoration(
                    //                                             color: AppColors.ihlPrimaryColor,
                    //                                             borderRadius: BorderRadius.circular(6)),
                    //                                         child: Center(
                    //                                           child: Text('SEND INVITE',
                    //                                               style: AppTextStyles.sendInvite),
                    //                                         )),
                    //                                   )
                    //                                 ],
                    //                               )
                    //                             ],
                    //                           )
                    //                         ],
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 );
                    //               });
                    //         }),
                    //   ),
                    // ),
                    VariantBannerWidget.bannerWidget(
                      _bannerController,
                      _listofChallengeController,
                    ),
                    // ValueListenableBuilder(
                    //     valueListenable: ChallengeInviteAndFunctions.invitedEmailCount,
                    //     builder: (context, index, child) {
                    //       return Padding(
                    //         padding: const EdgeInsets.all(8.0),
                    //         child: InkWell(
                    //           onTap: () {
                    //             Get.to(AllChallengeTypeScreen());
                    //           },
                    //           child: Container(
                    //             padding:
                    //                 EdgeInsets.only(top: 1.5.h, bottom: 2.h, left: 2.w, right: 2.w),
                    //             decoration: BoxDecoration(
                    //                 color: Colors.white, borderRadius: BorderRadius.circular(5)),
                    //             child: Column(
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               mainAxisAlignment: MainAxisAlignment.start,
                    //               children: [
                    //                 Container(
                    //                   height: 18.h,
                    //                   width: double.infinity,
                    //                   child: Image.asset(
                    //                     'newAssets/Icons/challengePic.png',
                    //                     fit: BoxFit.cover,
                    //                   ),
                    //                 ),
                    //                 // SizedBox(
                    //                 //   height: 2.h,
                    //                 // ),
                    //                 Row(
                    //                   children: [
                    //                     Column(
                    //                       children: [
                    //                         Padding(
                    //                           padding: const EdgeInsets.all(8.0),
                    //                           child: SizedBox(
                    //                             width: 48.w,
                    //                             child: Text('Invite your friends & family',
                    //                                 textAlign: TextAlign.center,
                    //                                 style: TextStyle(
                    //                                   fontFamily: 'Poppins',
                    //                                   fontSize: 12.sp,
                    //                                   color: const Color(0xde000000),
                    //                                 )),
                    //                           ),
                    //                         ),
                    //                         Text(
                    //                             "(${ChallengeInviteAndFunctions.invitedEmailCount.value}/5 invite left)",
                    //                             style: TextStyle(
                    //                               color: Colors.black,
                    //                               fontWeight: FontWeight.w500,
                    //                               fontSize: 11.sp,
                    //                               letterSpacing: 0.6,
                    //                             ),
                    //                             textAlign: TextAlign.center),
                    //                       ],
                    //                     ),
                    //                     Spacer(),
                    //                     Column(
                    //                       children: [
                    //                         SizedBox(
                    //                           height: 10,
                    //                         ),
                    //                         InkWell(
                    //                           onTap: () => showModalBottomSheet<void>(
                    //                             backgroundColor: Colors.transparent,
                    //                             context: context,
                    //                             isScrollControlled: true,
                    //                             builder: (BuildContext context) {
                    //                               return bottomSheetContentInvite(context: context);
                    //                             },
                    //                           ),
                    //                           child: Container(
                    //                               padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                    //                               decoration: BoxDecoration(
                    //                                   color: AppColors.ihlPrimaryColor,
                    //                                   borderRadius: BorderRadius.circular(6)),
                    //                               child: Center(
                    //                                 child: Text('SEND INVITE',
                    //                                     style: AppTextStyles.sendInvite),
                    //                               )),
                    //                         )
                    //                       ],
                    //                     )
                    //                   ],
                    //                 )
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       );
                    //     }),
                    Builder(builder: (BuildContext ctx) {
                      try {
                        return Column(
                          children: [
                            if (_upcomingDetailsController
                                .upComingDetails.enrolChallengeList.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.all(8.sp),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('My Challenges',
                                        style: AppTextStyles.HealthChallengeTitle),
                                    GestureDetector(
                                      onTap: () async {
                                        SharedPreferences prefs =
                                            await SharedPreferences.getInstance();
                                        String userid = prefs.getString("ihlUserId");
                                        String ss = prefs.getString("sso_flow_affiliation");
                                        if (ss != null) {
                                          Map<String, dynamic> exsitingAffi = jsonDecode(ss);
                                          UpdatingColorsBasedOnAffiliations.ssoAffiliation = {
                                            "affiliation_unique_name":
                                                exsitingAffi["affiliation_unique_name"]
                                          };
                                        }

                                        Get.to(EnrolledChallengesListScreen(
                                          uid: userid,
                                        ));
                                      },
                                      child: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: AppColors.ihlPrimaryColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            if (_upcomingDetailsController
                                .upComingDetails.enrolChallengeList.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                height: 27.h,
                                width: double.infinity,
                                child: ChallengeCard().enrolledChallenge(context),
                              )
                          ],
                        );
                      } catch (e) {
                        return Container();
                      }
                    }),

                    Visibility(
                      visible: !(challengeProgress && completedChallengesWithBadges.isEmpty),
                      child: Visibility(
                        replacement: challengeProgress
                            ? Container()
                            : Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.sp),
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal, child: achievedShimmer()),
                              ),
                        visible: completedExistence,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 5.sp),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Participated Challenge',
                                      style: AppTextStyles.HealthChallengeTitle),
                                  GestureDetector(
                                    onTap: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      String userid = prefs.getString("ihlUserId");
                                      if (uniqueNme == "global") {
                                        Get.to(AchievedChallengesListScreen(
                                          uid: userid,
                                        ));
                                      } else {
                                        Get.to(AchievedChallengesListScreen(
                                          uid: userid,
                                        ));
                                      }
                                    },
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.ihlPrimaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: 5.sp),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: !completedChallengesWithBadges.isNotEmpty
                                    ? achievedShimmer()
                                    : Row(
                                        children: completedChallengesWithBadges
                                            .map((ChallengeDetailWithBadges e) {
                                          return achievedChallengeCard(
                                              e.image,
                                              e.challengeDesc,
                                              e.challengeDetail,
                                              e.challenegeBadge,
                                              e.challengeId,
                                              e.enrollmentId,
                                              e.challengeMode,
                                              e.groupDetailModel);
                                        }).toList(),
                                      ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 11.h,
                    )
                  ],
                ),
        ));
  }

  Row achievedShimmer() {
    return Row(
      children: [
        Container(
            height: 79.sp,
            width: 169.sp,
            color: AppColors.backgroundScreenColor,
            padding: EdgeInsets.all(3.sp),
            child: Shimmer.fromColors(
                direction: ShimmerDirection.ltr,
                period: const Duration(seconds: 2),
                baseColor: const Color.fromARGB(255, 240, 240, 240),
                highlightColor: Colors.grey.withOpacity(0.2),
                child: Container(
                    height: 30.h,
                    width: 44.w,
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                    decoration:
                        BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Hello')))),
        const SizedBox(
          width: 25,
        ),
        Container(
            height: 79.sp,
            width: 169.sp,
            color: AppColors.backgroundScreenColor,
            padding: EdgeInsets.all(3.sp),
            child: Shimmer.fromColors(
                direction: ShimmerDirection.ltr,
                period: const Duration(seconds: 2),
                baseColor: const Color.fromARGB(255, 240, 240, 240),
                highlightColor: Colors.grey.withOpacity(0.2),
                child: Container(
                    height: 30.h,
                    width: 44.w,
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                    decoration:
                        BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Hello'))))
      ],
    );
  }

  GestureDetector achievedChallengeCard(
      String imagePath,
      String desc,
      ChallengeDetail challengeDetail,
      var badgeUrl,
      String challengeId,
      String enrollmentId,
      String challengeMode,
      var groupDetailModel) {
    return GestureDetector(
      onTap: () async {
        EnrolledChallenge enrolledChallenges = await ChallengeApi().getEnrollDetail(enrollmentId);

        Get.to(CertificateDetail(
          challengeDetail: challengeDetail,
          firstCopmlete: false,
          enrolledChallenge: enrolledChallenges,
          groupDetail: groupDetailModel,
          currentUserIsAdmin: false,
        ));
      },
      child: Container(
        height: 79.sp,
        color: AppColors.backgroundScreenColor,
        padding: EdgeInsets.all(3.sp),
        child: Container(
          decoration:
              BoxDecoration(color: Colors.white60, borderRadius: BorderRadius.circular(8.sp)),
          padding: EdgeInsets.all(3.sp),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    height: 60.sp,
                    width: 60.sp,
                    decoration: BoxDecoration(
                        image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(imagePath)),
                        color: Colors.blue,
                        shape: BoxShape.circle),
                  ),
                  Positioned(
                    bottom: 0,
                    right: -2,
                    child: Container(
                      height: 30.sp,
                      width: 30.sp,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Center(
                        child: SizedBox(
                            height: 22.sp,
                            width: 22.sp,
                            child: badgeUrl != null
                                ? Image.network(badgeUrl)
                                : Image.network(
                                    'https://cdn1.iconfinder.com/data/icons/seo-and-marketing-icons-2/512/93-512.png')),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 15.sp,
              ),
              SizedBox(
                width: 130,
                child: Text(
                  challengeDetail.challengeName,
                  maxLines: 2,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChallengeDetailWithBadges {
  String image;
  String challengeName;
  String challengeDesc;
  ChallengeDetail challengeDetail;
  String challengeId;
  String enrollmentId;

  var challenegeBadge;
  String challengeMode;
  GroupDetailModel groupDetailModel;

  ChallengeDetailWithBadges(
      {this.image,
      this.challengeName,
      this.challengeDesc,
      this.challengeDetail,
      this.challenegeBadge,
      this.challengeId,
      this.enrollmentId,
      this.challengeMode,
      this.groupDetailModel});
}
