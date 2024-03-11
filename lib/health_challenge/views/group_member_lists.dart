import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/controllers/challenge_api.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/health_challenge/models/exit_group_challenge_model.dart';
import 'package:ihl/health_challenge/models/list_of_users_in_group.dart';
import 'package:ihl/utils/imageutils.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/app_colors.dart';

class GroupMemberList extends StatefulWidget {
  const GroupMemberList({Key key, @required this.challengeDetail, this.filteredData})
      : super(key: key);
  final ChallengeDetail challengeDetail;
  final EnrolledChallenge filteredData;

  @override
  State<GroupMemberList> createState() => _GroupMemberListState();
}

class _GroupMemberListState extends State<GroupMemberList> {
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
    gu.addAll(groupMembers.where((element) => element.role == "admin"));
    if (gu.isNotEmpty) {
      groupMembers.insert(0, gu[0]);
    }
    groupMembers = groupMembers.toSet().toList();
    groupMembers.removeWhere(((element) => element.userStatus == "deactive"));

    setState(() {
      isLoading = false;
    });

    // print(groupMembers);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return BasicPageUI(
      appBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.white,
              onPressed: () => {Navigator.of(context).pop()}
              // Get.offAll(DietJournal(),
              //     predicate: (route) =>
              //         Get.currentRoute == Routes.Home),
              ),
          // SizedBox(
          //   width: ScUtil().setHeight(110),
          // ),
          Flexible(
            child: Center(
              child: Text(
                "Group Member List",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: SizedBox(
        height: height / 1.1,
        width: width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
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
                          backgroundImage: NetworkImage(widget.challengeDetail.challengeImgUrl),
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
                                    text: '- ${widget.filteredData.user_bib_no}',
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
                            widget.challengeDetail.challengeName,
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
      ),
    );
  }

  Widget customListTileForMembers(
      {BuildContext context, GroupUser groupUser, String userImageUrl}) {
    // double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 15, left: 10, right: 10),
      child: Container(
        width: width - 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.grey.shade400, offset: Offset(1, 1), blurRadius: 6)],
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
                              future:
                                  ChallengeApi().userPhotoDataRetrive(userUid: groupUser.userId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting)
                                  return CircleAvatar(
                                    radius: 25,
                                    child: Icon(Icons.person),
                                  );
                                return CircleAvatar(
                                  radius: 25,
                                  backgroundImage: imageFromBase64String(snapshot.data).image,
                                );
                              }),
                        ),
                        Spacer(),
                        SizedBox(
                            width: width / 3.2,
                            child: Text(
                              groupUser.name,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.7,
                                  color: Colors.blueGrey.shade800),
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
                      contentText:
                          groupUser.department == "" ? "Not Mentiond" : groupUser.department,
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
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
