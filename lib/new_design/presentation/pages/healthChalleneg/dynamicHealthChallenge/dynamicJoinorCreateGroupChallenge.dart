import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:googleapis/serviceconsumermanagement/v1.dart';
import 'package:ihl/health_challenge/controllers/challenge_api.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/group_model.dart';
import 'package:ihl/health_challenge/models/list_of_users_in_group.dart';
import 'package:ihl/health_challenge/views/create_group_screen.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'dynamicCreateGroupScreen.dart';

// ignore: must_be_immutable
class DynamicJoinOrCreateGroupChallenge extends StatefulWidget {
  DynamicJoinOrCreateGroupChallenge({Key key, @required this.challengeDetail}) : super(key: key);
  ChallengeDetail challengeDetail;

  @override
  State<DynamicJoinOrCreateGroupChallenge> createState() =>
      _DynamicJoinOrCreateGroupChallengeState();
}

class _DynamicJoinOrCreateGroupChallengeState extends State<DynamicJoinOrCreateGroupChallenge> {
  @override
  void initState() {
    groupListGetter();
    super.initState();
  }

  List<GroupModel> groups = [];
  groupListGetter() async {
    groups
        .addAll(await ChallengeApi().listOfGroups(challengeId: widget.challengeDetail.challengeId));
    groups.removeWhere((element) => element.groupStatus != "active");
    if (mounted) setState(() {});
    // groupDetailsGetter();
  }

  // List<List<GroupUser>> listOfUsersGroup = [];
  // groupDetailsGetter() async {
  //   List<GroupUser> gg = [];
  //   for (int g = 0; g < groups.length; g++) {
  //     gg.addAll(
  //         await ChallengeApi().listofGroupUsers(groupId: groups[g].groupId));
  //
  //     print(listOfUsersGroup.length);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.backgroundScreenColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text("Join", style: TextStyle(color: Colors.white)),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: width / 5,
          ),
          Center(
            child: Container(
              height: width / 1.8,
              width: width / 1.8,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                // boxShadow: [BoxShadow(offset: Offset(1, 1), color: Colors.grey, blurRadius: 6)],
                image: DecorationImage(
                    fit: BoxFit.fitWidth, image: AssetImage("assets/images/Group 117.png")),
              ),
            ),
          ),
          SizedBox(
            height: width / 9,
          ),
          Container(
            width: width - 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              boxShadow: [
                BoxShadow(offset: Offset(0, 0), color: Colors.grey, blurRadius: 6),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 7.h,
                  width: 95.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                    color: AppColors.primaryColor.withOpacity(0.6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(flex: 1, child: Container()),
                      Expanded(
                        flex: 8,
                        child: Text(
                          "Group",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 20.px,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height / 4,
                  child: Scrollbar(
                    thickness: 9,
                    radius: Radius.circular(50),
                    child: ListView.builder(
                        itemCount: groups.length + 1,
                        itemBuilder: (context, int index) {
                          if (index == 0) {
                            return GestureDetector(
                              onTap: () {
                                Get.to(DynamicCreateGroupScreen(
                                  challengeDetail: widget.challengeDetail,
                                ));
                              },
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 20.px,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.plus,
                                          color: AppColors.primaryColor,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          "Create a new Group",
                                          style: TextStyle(
                                              color: AppColors.primaryColor, fontSize: 18),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.px,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      FutureBuilder(
                                          future: ChallengeApi()
                                              .listofGroupUsers(groupId: groups[index - 1].groupId),
                                          builder: (ctx, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting)
                                              return CircularProgressIndicator();
                                            List<GroupUser> gg = snapshot.data;
                                            if (gg.length.toString() ==
                                                widget.challengeDetail.maxUsersGroup.toString()) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Get.snackbar("Heads up", "This group is already full.",
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      backgroundColor: Colors.blue.shade400,
                                                      icon: Icon(Icons.warning));
                                                },
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      groups[index - 1].groupName,
                                                      style: TextStyle(
                                                          color: Colors.grey, fontSize: 18),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      "[${gg.length}/${widget.challengeDetail.maxUsersGroup.toString()} Joined]",
                                                      style: TextStyle(
                                                          color: Colors.grey, fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              return GestureDetector(
                                                onTap: () {
                                                  Get.to(DynamicCreateGroupScreen(
                                                    challengeDetail: widget.challengeDetail,
                                                    groupModel: groups[index - 1],
                                                    groupMemberslength: gg.length,
                                                  ));
                                                },
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      groups[index - 1].groupName,
                                                      style: TextStyle(
                                                          color: Colors.black87, fontSize: 18.sp),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      "[${gg.length}/${widget.challengeDetail.maxUsersGroup.toString()} Joined]",
                                                      style: TextStyle(
                                                          color: Colors.black87, fontSize: 18.sp),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          })
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20.px,
                                ),
                              ],
                            );
                          }
                        }),
                  ),
                ),
                SizedBox(
                  height: 30.px,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
