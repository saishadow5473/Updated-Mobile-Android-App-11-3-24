import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../health_challenge/views/challenge_details_screen.dart';
import '../health_challenge/views/on_going_challenge.dart';
import '../new_design/app/utils/appColors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../health_challenge/controllers/challenge_api.dart';
import '../health_challenge/models/badgesController.dart';
import '../health_challenge/models/challenge_detail.dart';
import '../health_challenge/models/enrolled_challenge.dart';
import '../health_challenge/views/certificate_screen.dart';
import '../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';

class BadgesTab extends StatefulWidget {
  const BadgesTab({Key key}) : super(key: key);

  @override
  State<BadgesTab> createState() => _BadgesTabState();
}

class _BadgesTabState extends State<BadgesTab> {
  ChallengeDetail challengeDetail;
  EnrolledChallenge enrolledChallenge;
  ChallengeApi challengeApi = ChallengeApi();
  BadgesChallengeController badgesChallengeController = Get.put(BadgesChallengeController());

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return CommonScreenForNavigation(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                Get.back();
              }, //replaces the screen to Main dashboard
              color: Colors.white,
            ),
            title: const Text("Badges"),
            centerTitle: true,
            backgroundColor: AppColors.primaryColor),
        content: GetBuilder<BadgesChallengeController>(
          builder: (BadgesChallengeController listBadges) {
            return listBadges.BadgesList == null
                ? const Center(child: Text('No badges'))
                : listBadges.BadgesList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: listBadges.BadgesList.length,
                        itemBuilder: (BuildContext context, int index) {
                          var _item = listBadges.BadgesList[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0, bottom: 5.0, left: 5.0, right: 5.0),
                            child: GestureDetector(
                              onTap: () {
                                Widget okButton = ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                                      textStyle: const TextStyle(
                                          fontSize: 30, fontWeight: FontWeight.bold)),
                                  child: Text("OK",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.sp,
                                          color: Colors.white)),
                                  onPressed: () async {
                                    Get.back();
                                    var _groupDetail;
                                    if (_item.challengeDetail.challengeMode != "individual") {
                                      _groupDetail = await ChallengeApi().challengeGroupDetail(
                                          groupID: _item.enrolledChallenge.groupId);
                                    }
                                    Get.to(OnGoingChallenge(
                                        challengeDetail: _item.challengeDetail,
                                        navigatedNormal: true,
                                        groupDetail: _groupDetail,
                                        filteredList: _item.enrolledChallenge));
                                  },
                                );
                                Widget joinButton = ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                                      textStyle: const TextStyle(
                                          fontSize: 30, fontWeight: FontWeight.bold)),
                                  child: Text("JOIN",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.sp,
                                          color: Colors.white)),
                                  onPressed: () {
                                    Get.back();
                                    Get.to(ChallengeDetailsScreen(
                                      challengeDetail: _item.challengeDetail,
                                      fromNotification: false,
                                    ));
                                  },
                                );
                                AlertDialog enrolledNotcompleted = AlertDialog(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                  content: Builder(
                                    builder: (BuildContext context) {
                                      return SizedBox(
                                        height: height - 600,
                                        width: 1000,
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 3.h,
                                            ),
                                            Center(
                                                child: FittedBox(
                                              child: Text(
                                                _item.challengeName,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.sp,
                                                    color: AppColors.primaryColor),
                                              ),
                                            )),
                                            SizedBox(
                                              height: 4.h,
                                            ),
                                            Center(
                                                child: FittedBox(
                                              child: Text(
                                                'You are yet to complete the challenge.',
                                                style: TextStyle(
                                                    fontSize: 15.sp,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Poppins'),
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                              ),
                                            )),
                                            Center(
                                                child: Text(
                                              'Complete the challenge to unlock your badges!!',
                                              style: TextStyle(
                                                  fontSize: 15.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Poppins'),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                            )),
                                            SizedBox(
                                              height: 1.h,
                                            ),
                                            okButton
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                                AlertDialog enrolledNot = AlertDialog(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                  content: Builder(
                                    builder: (BuildContext context) {
                                      return SizedBox(
                                        height: height - 650,
                                        width: 1000,
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 3.h,
                                            ),
                                            Center(
                                                child: FittedBox(
                                              child: Text(
                                                _item.challengeName,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.sp,
                                                    color: AppColors.primaryColor),
                                              ),
                                            )),
                                            SizedBox(
                                              height: 3.h,
                                            ),
                                            Center(
                                                child: Text(
                                              'You are yet to join the challenge.',
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Poppins'),
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                            )),
                                            Center(
                                                child: Text(
                                              'Join the challenge to win your badge!!',
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Poppins'),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                            )),
                                            SizedBox(
                                              height: 2.h,
                                            ),
                                            joinButton
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                                listBadges.BadgesList[index].enrollementStatus == "notEnrolled" ||
                                        listBadges.BadgesList[index].enrollementStatus ==
                                            "progressing"
                                    ? listBadges.BadgesList[index].enrollementStatus ==
                                            "progressing"
                                        ? showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return enrolledNotcompleted;
                                            },
                                          )
                                        : showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return enrolledNot;
                                            },
                                          )
                                    : Get.to(CertificateScreen(
                                        groupName: listBadges
                                                .BadgesList[index].enrolledChallenge.groupname ??
                                            "",
                                        challengeDetail:
                                            listBadges.BadgesList[index].challengeDetail,
                                        enrolledChallenge:
                                            listBadges.BadgesList[index].enrolledChallenge,
                                        duration: listBadges
                                            .BadgesList[index].enrolledChallenge.userduration));
                              },
                              child: Card(
                                elevation: 4.0,
                                child: Stack(alignment: AlignmentDirectional.topEnd, children: [
                                  Column(
                                    children: [
                                      Column(
                                        children: [
                                          listBadges.BadgesList[index].enrollementStatus ==
                                                  "notEnrolled"
                                              ? Opacity(
                                                  opacity: 0.4,
                                                  child: Center(
                                                    child: SizedBox(
                                                        height: 12.h,
                                                        width: 15.w,
                                                        child: Image.network(listBadges
                                                            .BadgesList[index]
                                                            .challengeBadgeImgUrl)),
                                                  ),
                                                )
                                              : Center(
                                                  child: SizedBox(
                                                      height: 12.h,
                                                      width: 15.w,
                                                      child: Image.network(listBadges
                                                          .BadgesList[index].challengeBadgeImgUrl)),
                                                ),
                                          listBadges.BadgesList[index].enrollementStatus ==
                                                      "notEnrolled" ||
                                                  listBadges.BadgesList[index].enrollementStatus ==
                                                      "progressing"
                                              ? Opacity(
                                                  opacity: 0.4,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Container(
                                                      child: Text(
                                                        listBadges.BadgesList[index].challengeName
                                                            .toString(),
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 15.sp,
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.w500,
                                                            fontFamily: 'Poppins'),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    child: Text(
                                                      listBadges.BadgesList[index].challengeName
                                                          .toString(),
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 15.sp,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.w500,
                                                          fontFamily: 'Poppins'),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ),

                                          // listOfFood(index),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (listBadges.BadgesList[index].enrollementStatus ==
                                          "notEnrolled" ||
                                      listBadges.BadgesList[index].enrollementStatus ==
                                          "progressing")
                                    const Opacity(
                                      opacity: 0.4,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(Icons.lock),
                                      ),
                                    )
                                ]),
                              ),
                            ),
                          );
                        });
          },
        ));
  }
}
