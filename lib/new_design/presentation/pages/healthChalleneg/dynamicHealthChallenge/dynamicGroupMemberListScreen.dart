import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../../health_challenge/controllers/challenge_api.dart';
import '../../../../../health_challenge/models/challenge_detail.dart';
import '../../../../../health_challenge/models/enrolled_challenge.dart';
import '../../../../../health_challenge/models/exit_group_challenge_model.dart';
import '../../../../../health_challenge/models/group_details_model.dart';
import '../../../../../health_challenge/models/list_of_users_in_group.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/imageutils.dart';
import '../../dashboard/common_screen_for_navigation.dart';

class DynamicGroupMemberList extends StatefulWidget {
  const DynamicGroupMemberList(
      {Key key, @required this.challengeDetail, this.filteredData, this.groupDetailModel})
      : super(key: key);
  final ChallengeDetail challengeDetail;
  final EnrolledChallenge filteredData;
  final GroupDetailModel groupDetailModel;

  @override
  State<DynamicGroupMemberList> createState() => _DynamicGroupMemberListState();
}

class _DynamicGroupMemberListState extends State<DynamicGroupMemberList> {
  List<GroupUser> groupMembers = [];
  bool isLoading = true;
  void initState() {
    getGroupMembers();
    super.initState();
  }

  getGroupMembers() async {
    groupMembers.clear();
    groupMembers
        .addAll(await ChallengeApi().listofGroupUsers(groupId: widget.filteredData.groupId));
    List<GroupUser> gu = [];
    gu.addAll(groupMembers.where((GroupUser element) => element.role == "admin"));
    if (gu.isNotEmpty) {
      groupMembers.insert(0, gu[0]);
    }
    groupMembers = groupMembers.toSet().toList();
    groupMembers.removeWhere(((GroupUser element) => element.userStatus == "deactive"));

    setState(() {
      isLoading = false;
    });

    // print(groupMembers);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return CommonScreenForNavigation(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Group Member List",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      content: Column(
        children: [
          Container(
            height: 27.h,
            width: 95.w,
            margin: EdgeInsets.symmetric(vertical: 5.sp),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.sp),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.challengeDetail.challengeImgUrl))),
          ),
          Container(
            height: 12.h,
            width: 95.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.sp),
              color: AppColors.backgroundScreenColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    offset: Offset(0, 2),
                    blurRadius: 6,
                    spreadRadius: 0.5),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  widget.challengeDetail.challengeName,
                  style: TextStyle(color: AppColors.appItemTitleTextColor, fontSize: 16.sp),
                ),
                Text(
                  widget.groupDetailModel.groupName,
                  style: TextStyle(color: AppColors.primaryColor, fontSize: 16.sp),
                ),
              ],
            ),
          ),
          isLoading
              ? SizedBox(child: CircularProgressIndicator())
              : Expanded(
                  // width: width - 20,
                  // height: height / 2.5,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView.builder(
                        itemCount: groupMembers.length,
                        itemBuilder: (BuildContext context, int index) {
                          // return customListTileForMembers(
                          //     context, groupMembers[index]);
                          return customListTileForMembers(
                            context: context,
                            index: index,
                            groupUser: groupMembers[index],
                          );
                        }),
                  ),
                ),
          // SizedBox(
          //   height: 20,
          // ),
        ],
      ),
    );
  }

  Widget customListTileForMembers(
      {BuildContext context, GroupUser groupUser, String userImageUrl, int index}) {
    // double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: index == 0 ? AppColors.backgroundScreenColor : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), offset: Offset(0, 1), blurRadius: 6)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: width / 2,
                  child: Row(
                    children: [
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: FutureBuilder(
                            future: ChallengeApi().userPhotoDataRetrive(userUid: groupUser.userId),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              // print(imageFromBase64String(snapshot.data).image);
                              if (snapshot.connectionState == ConnectionState.waiting)
                                return CircleAvatar(
                                  radius: 25,
                                  child: Icon(Icons.person),
                                );
                              return CircleAvatar(
                                radius: 25,
                                child:Icon(Icons.person)
                                  // imageFromBase64String(snapshot.data).image??'',
                              );

                            }),
                      ),
                      Spacer(),
                      SizedBox(
                          width: width / 3.2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                groupUser.name,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.7,
                                    color: Colors.blueGrey.shade800),
                              ),
                              Row(
                                children: [
                                  Text('BIB - '),
                                  Text(
                                    groupUser.bibNo,
                                    style: TextStyle(color: AppColors.primaryColor),
                                  ),
                                ],
                              )
                            ],
                          ))
                    ],
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () async {
                    bool exited = false;
                    if (groupUser.role != "admin") {
                      ExitGroupChallenge exitGroupChallenge = ExitGroupChallenge(
                        challengeId: widget.challengeDetail.challengeId,
                        groupId: groupUser.groupId,
                        userId: groupUser.userId,
                      );
                      exited = await ChallengeApi()
                          .userExitGroup(exitGroupChallenge: exitGroupChallenge);
                      getGroupMembers();
                      setState(() {});
                    }

                    exited
                        ? Get.snackbar("Deleted ", "The member was removed",
                            snackPosition: SnackPosition.BOTTOM)
                        : null;
                  },
                  child: Icon(
                    groupUser.role.toLowerCase() == "admin"
                        ? Icons.admin_panel_settings
                        : Icons.delete,
                    color: Colors.black54,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                componentForCustomList(
                    contentText: groupUser.city,
                    iconPath: "assets/icons/Group 133.png",
                    width: width),
                Spacer(),
                componentForCustomList(
                    contentText: groupUser.gender,
                    iconPath: "assets/icons/Group 129.png",
                    width: width),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                componentForCustomList(
                    contentText: groupUser.department == "" ? "Not Mentiond" : groupUser.department,
                    iconPath: "assets/icons/Group 122.png",
                    width: width),
                Spacer(),
                componentForCustomList(
                    contentText:
                        groupUser.designation == "" ? "Not Mentiond" : groupUser.designation,
                    iconPath: "assets/icons/Group 135.png",
                    width: width),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget componentForCustomList({String contentText, iconPath, double width}) {
    return Container(
      // height: 80,
      width: width / 2.8,
      child: Row(
        children: [
          SizedBox(height: 30, width: 30, child: Image.asset(iconPath)),
          SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 85,
            child: Text(
              contentText,
              style: TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 15.sp,
                  color: AppColors.appItemTitleTextColor),
            ),
          ),
        ],
      ),
    );
  }
}
