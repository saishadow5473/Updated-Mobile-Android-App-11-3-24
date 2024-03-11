import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health/health.dart';
import 'package:ihl/Getx/controller/listOfChallengeContoller.dart';
import 'package:ihl/health_challenge/controllers/challenge_api.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/create_group_challenge_model.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/health_challenge/models/group_details_model.dart';
import 'package:ihl/health_challenge/models/group_model.dart';
import 'package:ihl/health_challenge/models/join_group_model.dart';
import 'package:ihl/health_challenge/views/on_going_challenge.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:jiffy/jiffy.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../new_design/presentation/pages/home/home_view.dart';
import '../../utils/app_colors.dart';
import '../models/join_individual.dart';

// ignore: must_be_immutable
class CreateGroupScreen extends StatefulWidget {
  CreateGroupScreen(
      {Key key, @required this.challengeDetail, this.groupModel, this.groupMemberslength})
      : super(key: key);
  ChallengeDetail challengeDetail;
  GroupModel groupModel;
  int groupMemberslength;

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  @override
  void initState() {
    if (widget.groupModel != null) {
      _groupName.text = widget.groupModel.groupName;
      grpLength = widget.groupMemberslength ?? 0;
    }
    super.initState();
  }

  bool fitImplemented = false;
  bool fitInstalled = false;
  bool joinButtonLoader = false;
  final HealthFactory health = HealthFactory();
  int grpLength;
  TextEditingController _groupName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return ScrollessBasicPageUI(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.groupModel != null ? "Join" : "Create a New Group",
            style: TextStyle(color: Colors.white)),
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
      body: Form(
        key: _formKey,
        child: SizedBox(
            height: height,
            width: width,
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: width / 5,
                  ),
                  Container(
                    height: width / 1.8,
                    width: width / 1.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      // boxShadow: [BoxShadow(offset: Offset(1, 1), color: Colors.grey, blurRadius: 6)],
                      image: DecorationImage(
                          fit: BoxFit.fitWidth, image: AssetImage("assets/images/Group 117.png")),
                    ),
                  ),
                  SizedBox(
                    height: width / 5,
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black, fontSize: 18),
                              children: [
                                TextSpan(
                                    text: 'Note : ',
                                    style:
                                        TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: 'This group creation is valid only for ',
                                    style: TextStyle(
                                      color: Colors.black54,
                                    )),
                                TextSpan(
                                    text: '${widget.challengeDetail.challengeName} Challenge',
                                    style: TextStyle(
                                      color: Colors.black54,
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Group Name",
                                style: TextStyle(
                                    color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 18)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Material(
                            elevation: 2,
                            child: TextFormField(
                              enabled: widget.groupModel == null,
                              controller: _groupName,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please Enter Your Group Name";
                                } else {
                                  return null;
                                }
                              },
                              keyboardType: TextInputType.name,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z -]"))
                              ],
                              decoration: InputDecoration(
                                hintText: 'Ex: IT Team',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(3)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                            onPressed: joinButtonLoader
                                ? () {}
                                : () async {
                                    if (mounted) {
                                      setState(() {
                                        joinButtonLoader = true;
                                      });
                                    }
                                    final box = GetStorage();
                                    fitImplemented = box.read("fit") ?? false;
                                    if (Platform.isAndroid) {
                                      fitInstalled = await LaunchApp.isAppInstalled(
                                          androidPackageName: "com.google.android.apps.fitness");
                                    } else {
                                      fitInstalled = true;
                                    }

                                    if (_formKey.currentState.validate()) {
                                      // if (Get.find<ListChallengeController>()
                                      //         .affiliateCmpnyList
                                      //         .contains("Persistent") &&
                                      //     widget.challengeDetail.affiliations.contains("Persistent")) {
                                      //   CustomDialog().googleFitDia();
                                      // } else {
                                      if (!fitImplemented &&
                                          widget.challengeDetail.challengeType ==
                                              "Step Challenge") {
                                        if (mounted) {
                                          setState(() {
                                            joinButtonLoader = false;
                                          });
                                        }
                                        dialogBox().then((value) async {
                                          if (fitImplemented) {
                                            //for create a group
                                            if (widget.groupModel == null) {
                                              SharedPreferences prefs =
                                                  await SharedPreferences.getInstance();
                                              // String nickName = prefs.getString("nickName");
                                              var jobDetails = UserDetails.fromJson(
                                                  jsonDecode(prefs.getString("jobDetails")));
                                              CreateGroupChallenge createGroupChallenge =
                                                  CreateGroupChallenge(
                                                      challengeId:
                                                          widget.challengeDetail.challengeId,
                                                      groupName: _groupName.text,
                                                      groupDetail:
                                                          widget.challengeDetail.challengeName,
                                                      creatorDetails: CreatorDetails(
                                                          user_start_location:
                                                              jobDetails.userStartLocation,
                                                          email: jobDetails.email,
                                                          name: jobDetails.name,
                                                          userId: jobDetails.userId,
                                                          gender: jobDetails.gender,
                                                          city: jobDetails.city,
                                                          department: jobDetails.department,
                                                          designation: jobDetails.designation,
                                                          isGloble: widget
                                                                  .challengeDetail.affiliations
                                                                  .contains("global") ||
                                                              widget.challengeDetail.affiliations
                                                                  .contains("Global")));
                                              // try {
                                              var created = await ChallengeApi()
                                                  .createGroupChallenge(
                                                      createGroupChallenge: createGroupChallenge);
                                              if (created != "success") {
                                                return Get.defaultDialog(
                                                    backgroundColor: Colors.lightBlue.shade50,
                                                    title: capitalize(created.toString()),
                                                    titleStyle:
                                                        TextStyle(color: Colors.blue.shade300),
                                                    titlePadding:
                                                        EdgeInsets.only(bottom: 0, top: 10),
                                                    contentPadding: EdgeInsets.only(top: 0),
                                                    content: Column(
                                                      children: [
                                                        Divider(
                                                          thickness: 2,
                                                        ),
                                                        Text(
                                                          "Something went wrong. Please try again.",
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                              color: Colors.blue.shade400),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Icon(
                                                          Icons.error_outline,
                                                          size: 50,
                                                          color: Colors.blue.shade300,
                                                        ),
                                                      ],
                                                    ));
                                              } else if (created == "success") {
                                                try {
                                                  var _groupUser = await ChallengeApi()
                                                      .listofGroupUsers(
                                                          groupId: widget.groupModel.groupId);
                                                  grpLength = _groupUser.length;
                                                } catch (e) {
                                                  print(e);
                                                }
                                                if (DateTime.now().isAfter(
                                                    widget.challengeDetail.challengeStartTime)) {
                                                  if (grpLength == null ||
                                                      grpLength <
                                                          widget.challengeDetail.minUsersGroup) {
                                                    if (mounted) {
                                                      setState(() {
                                                        joinButtonLoader = false;
                                                      });
                                                    }
                                                    return Get.defaultDialog(
                                                        barrierDismissible: false,
                                                        onWillPop: () => null,
                                                        backgroundColor: Colors.lightBlue.shade50,
                                                        title:
                                                            'The challenge will commence once at least ${widget.challengeDetail.minUsersGroup} participants join.',
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
                                                            Divider(
                                                              thickness: 2,
                                                            ),
                                                            Icon(
                                                              Icons.task_alt,
                                                              size: 40,
                                                              color: Colors.blue.shade300,
                                                            ),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                // Get.offAll(HomeScreen(introDone: true),
                                                                //     transition: Transition.size);
                                                                Get.off(LandingPage());
                                                              },
                                                              child: Container(
                                                                width: MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                decoration: BoxDecoration(
                                                                    color: Colors.blue,
                                                                    borderRadius:
                                                                        BorderRadius.circular(20)),
                                                                child: Center(
                                                                  child: Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                      'Ok',
                                                                      style: TextStyle(
                                                                          color: Colors.white),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ));
                                                  } else {
                                                    if (mounted) {
                                                      setState(() {
                                                        joinButtonLoader = false;
                                                      });
                                                    }
                                                    return Get.defaultDialog(
                                                        barrierDismissible: false,
                                                        backgroundColor: Colors.lightBlue.shade50,
                                                        title: 'Created Successfully',
                                                        titlePadding:
                                                            EdgeInsets.only(top: 20, bottom: 0),
                                                        titleStyle: TextStyle(
                                                            letterSpacing: 1,
                                                            color: Colors.blue.shade400,
                                                            fontSize: 23),
                                                        contentPadding: EdgeInsets.only(top: 0),
                                                        content: Column(
                                                          children: [
                                                            Divider(
                                                              thickness: 2,
                                                            ),
                                                            Icon(
                                                              Icons.task_alt,
                                                              size: 40,
                                                              color: Colors.blue.shade300,
                                                            ),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                List<EnrolledChallenge>
                                                                    enroledChalenges_list =
                                                                    await ChallengeApi()
                                                                        .listofUserEnrolledChallenges(
                                                                            userId:
                                                                                jobDetails.userId);
                                                                EnrolledChallenge
                                                                    currentERchallenge;
                                                                GroupDetailModel groupDetailModel;
                                                                for (var i
                                                                    in enroledChalenges_list) {
                                                                  if (i.challengeId ==
                                                                      widget.challengeDetail
                                                                          .challengeId) {
                                                                    currentERchallenge = i;
                                                                    groupDetailModel =
                                                                        await ChallengeApi()
                                                                            .challengeGroupDetail(
                                                                                groupID: i.groupId);
                                                                  }
                                                                }
                                                                Get.to(OnGoingChallenge(
                                                                    filteredList:
                                                                        currentERchallenge,
                                                                    groupDetail: groupDetailModel,
                                                                    challengeDetail:
                                                                        widget.challengeDetail,
                                                                    navigatedNormal: false));
                                                              },
                                                              child: Container(
                                                                width: MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                decoration: BoxDecoration(
                                                                    color: Colors.blue,
                                                                    borderRadius:
                                                                        BorderRadius.circular(20)),
                                                                child: Center(
                                                                  child: Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                      'Ok',
                                                                      style: TextStyle(
                                                                          color: Colors.white),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ));
                                                  }
                                                } else {
                                                  getdef();
                                                }
                                              }
                                              // } catch (e) {
                                              //   print(e);
                                              // }
                                            }
                                            //for join a group
                                            else if (widget.groupModel != null) {
                                              SharedPreferences prefs =
                                                  await SharedPreferences.getInstance();
                                              var jobDetails = UserDetails.fromJson(
                                                  jsonDecode(prefs.getString("jobDetails")));
                                              JoinGroup joinGroup = JoinGroup(
                                                  challengeId: widget.challengeDetail.challengeId,
                                                  userDetails: jobDetails,
                                                  groupId: widget.groupModel.groupId);
                                              // try {
                                              bool created = await ChallengeApi()
                                                  .userJoinGroup(joinGroup: joinGroup);
                                              if (created == false) {
                                                if (mounted) {
                                                  setState(() {
                                                    joinButtonLoader = false;
                                                  });
                                                }
                                                return Get.defaultDialog(
                                                    backgroundColor: Colors.lightBlue.shade50,
                                                    title: capitalize("Oops!"),
                                                    titleStyle:
                                                        TextStyle(color: Colors.blue.shade300),
                                                    titlePadding:
                                                        EdgeInsets.only(bottom: 0, top: 10),
                                                    contentPadding: EdgeInsets.only(top: 0),
                                                    content: Column(
                                                      children: [
                                                        Divider(
                                                          thickness: 2,
                                                        ),
                                                        Text(
                                                          "Something went wrong. Please try again.",
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                              color: Colors.blue.shade400),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Icon(
                                                          Icons.error_outline,
                                                          size: 50,
                                                          color: Colors.blue.shade300,
                                                        ),
                                                      ],
                                                    ));
                                              } else {
                                                setState(() {});
                                                var _groupUser = [];
                                                try {
                                                  _groupUser = await ChallengeApi()
                                                      .listofGroupUsers(
                                                          groupId: widget.groupModel.groupId);
                                                } catch (e) {
                                                  debugPrint(e);
                                                }
                                                grpLength = _groupUser.length;
                                                if (DateTime.now().isAfter(
                                                    widget.challengeDetail.challengeStartTime)) {
                                                  if (grpLength == null ||
                                                      grpLength <
                                                          widget.challengeDetail.minUsersGroup) {
                                                    if (mounted) {
                                                      setState(() {
                                                        joinButtonLoader = false;
                                                      });
                                                    }
                                                    return Get.defaultDialog(
                                                        barrierDismissible: false,
                                                        onWillPop: () => null,
                                                        backgroundColor: Colors.lightBlue.shade50,
                                                        title:
                                                            'The challenge will commence once at least ${widget.challengeDetail.minUsersGroup} participants join.',
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
                                                            Divider(
                                                              thickness: 2,
                                                            ),
                                                            Icon(
                                                              Icons.task_alt,
                                                              size: 40,
                                                              color: Colors.blue.shade300,
                                                            ),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                // Get.offAll(HomeScreen(introDone: true),
                                                                //     transition: Transition.size);
                                                                Get.off(LandingPage());
                                                              },
                                                              child: Container(
                                                                width: MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                decoration: BoxDecoration(
                                                                    color: Colors.blue,
                                                                    borderRadius:
                                                                        BorderRadius.circular(20)),
                                                                child: Center(
                                                                  child: Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                      'Ok',
                                                                      style: TextStyle(
                                                                          color: Colors.white),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ));
                                                  } else {
                                                    if (mounted) {
                                                      setState(() {
                                                        joinButtonLoader = false;
                                                      });
                                                    }
                                                    return Get.defaultDialog(
                                                        barrierDismissible: false,
                                                        backgroundColor: Colors.lightBlue.shade50,
                                                        title: "Great! You're all set.",
                                                        titlePadding:
                                                            EdgeInsets.only(top: 20, bottom: 0),
                                                        titleStyle: TextStyle(
                                                            letterSpacing: 1,
                                                            color: Colors.blue.shade400,
                                                            fontSize: 23),
                                                        contentPadding: EdgeInsets.only(top: 0),
                                                        content: Column(
                                                          children: [
                                                            Divider(
                                                              thickness: 2,
                                                            ),
                                                            Icon(
                                                              Icons.task_alt,
                                                              size: 40,
                                                              color: Colors.blue.shade300,
                                                            ),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                List<EnrolledChallenge>
                                                                    enroledChalenges_list =
                                                                    await ChallengeApi()
                                                                        .listofUserEnrolledChallenges(
                                                                            userId:
                                                                                jobDetails.userId);
                                                                EnrolledChallenge
                                                                    currentERchallenge;
                                                                GroupDetailModel groupDetailModel;
                                                                for (var i
                                                                    in enroledChalenges_list) {
                                                                  if (i.challengeId ==
                                                                      widget.challengeDetail
                                                                          .challengeId) {
                                                                    currentERchallenge = i;
                                                                    groupDetailModel =
                                                                        await ChallengeApi()
                                                                            .challengeGroupDetail(
                                                                                groupID: i.groupId);
                                                                  }
                                                                }
                                                                Get.to(OnGoingChallenge(
                                                                    filteredList:
                                                                        currentERchallenge,
                                                                    groupDetail: groupDetailModel,
                                                                    challengeDetail:
                                                                        widget.challengeDetail,
                                                                    navigatedNormal: false));
                                                              },
                                                              child: Container(
                                                                width: MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                decoration: BoxDecoration(
                                                                    color: Colors.blue,
                                                                    borderRadius:
                                                                        BorderRadius.circular(20)),
                                                                child: Center(
                                                                  child: Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                      'Ok',
                                                                      style: TextStyle(
                                                                          color: Colors.white),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ));
                                                  }
                                                } else {
                                                  getdef();
                                                }
                                              }
                                              // } catch (e) {}
                                            }
                                          }
                                        });
                                      } else {
                                        // dialogBox();
                                        //for create a group
                                        if (widget.groupModel == null) {
                                          SharedPreferences prefs =
                                              await SharedPreferences.getInstance();
                                          // String nickName = prefs.getString("nickName");
                                          var jobDetails = UserDetails.fromJson(
                                              jsonDecode(prefs.getString("jobDetails")));
                                          CreateGroupChallenge createGroupChallenge =
                                              CreateGroupChallenge(
                                                  challengeId: widget.challengeDetail.challengeId,
                                                  groupName: _groupName.text,
                                                  groupDetail: widget.challengeDetail.challengeName,
                                                  creatorDetails: CreatorDetails(
                                                      user_start_location:
                                                          jobDetails.userStartLocation,
                                                      email: jobDetails.email,
                                                      name: jobDetails.name,
                                                      userId: jobDetails.userId,
                                                      gender: jobDetails.gender,
                                                      city: jobDetails.city,
                                                      department: jobDetails.department,
                                                      designation: jobDetails.designation,
                                                      isGloble: widget.challengeDetail.affiliations
                                                              .contains("global") ||
                                                          widget.challengeDetail.affiliations
                                                              .contains("Global")));
                                          // try {
                                          var created = await ChallengeApi().createGroupChallenge(
                                              createGroupChallenge: createGroupChallenge);
                                          if (created != "success") {
                                            if (mounted) {
                                              setState(() {
                                                joinButtonLoader = false;
                                              });
                                            }
                                            return Get.defaultDialog(
                                                backgroundColor: Colors.lightBlue.shade50,
                                                title: capitalize(created.toString()),
                                                titleStyle: TextStyle(color: Colors.blue.shade300),
                                                titlePadding: EdgeInsets.only(bottom: 0, top: 10),
                                                contentPadding: EdgeInsets.only(top: 0),
                                                content: Column(
                                                  children: [
                                                    Divider(
                                                      thickness: 2,
                                                    ),
                                                    Text(
                                                      "Something went wrong. Please try again.",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Colors.blue.shade400),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Icon(
                                                      Icons.error_outline,
                                                      size: 50,
                                                      color: Colors.blue.shade300,
                                                    ),
                                                  ],
                                                ));
                                          } else {
                                            if (mounted) {
                                              setState(() {
                                                joinButtonLoader = false;
                                              });
                                            }
                                            if (DateTime.now().isAfter(
                                                widget.challengeDetail.challengeStartTime)) {
                                              if (grpLength == null ||
                                                  grpLength <
                                                      widget.challengeDetail.minUsersGroup) {
                                                return Get.defaultDialog(
                                                    barrierDismissible: false,
                                                    onWillPop: () => null,
                                                    backgroundColor: Colors.lightBlue.shade50,
                                                    title:
                                                        'The challenge will commence once at least ${widget.challengeDetail.minUsersGroup} participants join.',
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
                                                        Divider(
                                                          thickness: 2,
                                                        ),
                                                        Icon(
                                                          Icons.task_alt,
                                                          size: 40,
                                                          color: Colors.blue.shade300,
                                                        ),
                                                        SizedBox(
                                                          height: 15,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            // Get.offAll(HomeScreen(introDone: true),
                                                            //     transition: Transition.size);
                                                            Get.off(LandingPage());
                                                          },
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(context).size.width /
                                                                    4,
                                                            decoration: BoxDecoration(
                                                                color: Colors.blue,
                                                                borderRadius:
                                                                    BorderRadius.circular(20)),
                                                            child: Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text(
                                                                  'Ok',
                                                                  style: TextStyle(
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ));
                                              } else {
                                                if (mounted) {
                                                  setState(() {
                                                    joinButtonLoader = false;
                                                  });
                                                }
                                                return Get.defaultDialog(
                                                    barrierDismissible: false,
                                                    backgroundColor: Colors.lightBlue.shade50,
                                                    title: 'Created Successfully',
                                                    titlePadding:
                                                        EdgeInsets.only(top: 20, bottom: 0),
                                                    titleStyle: TextStyle(
                                                        letterSpacing: 1,
                                                        color: Colors.blue.shade400,
                                                        fontSize: 23),
                                                    contentPadding: EdgeInsets.only(top: 0),
                                                    content: Column(
                                                      children: [
                                                        Divider(
                                                          thickness: 2,
                                                        ),
                                                        Icon(
                                                          Icons.task_alt,
                                                          size: 40,
                                                          color: Colors.blue.shade300,
                                                        ),
                                                        SizedBox(
                                                          height: 15,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            List<EnrolledChallenge>
                                                                enroledChalenges_list =
                                                                await ChallengeApi()
                                                                    .listofUserEnrolledChallenges(
                                                                        userId: jobDetails.userId);
                                                            EnrolledChallenge currentERchallenge;
                                                            GroupDetailModel groupDetailModel;
                                                            for (var i in enroledChalenges_list) {
                                                              if (i.challengeId ==
                                                                  widget.challengeDetail
                                                                      .challengeId) {
                                                                currentERchallenge = i;
                                                                groupDetailModel =
                                                                    await ChallengeApi()
                                                                        .challengeGroupDetail(
                                                                            groupID: i.groupId);
                                                              }
                                                            }
                                                            Get.to(OnGoingChallenge(
                                                                filteredList: currentERchallenge,
                                                                groupDetail: groupDetailModel,
                                                                challengeDetail:
                                                                    widget.challengeDetail,
                                                                navigatedNormal: false));
                                                          },
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(context).size.width /
                                                                    4,
                                                            decoration: BoxDecoration(
                                                                color: Colors.blue,
                                                                borderRadius:
                                                                    BorderRadius.circular(20)),
                                                            child: Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text(
                                                                  'Ok',
                                                                  style: TextStyle(
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ));
                                              }
                                            } else {
                                              getdef();
                                            }
                                          }
                                          // } catch (e) {
                                          //   print(e);
                                          // }
                                        }
                                        //for join a group
                                        else if (widget.groupModel != null) {
                                          SharedPreferences prefs =
                                              await SharedPreferences.getInstance();
                                          var jobDetails = UserDetails.fromJson(
                                              jsonDecode(prefs.getString("jobDetails")));
                                          JoinGroup joinGroup = JoinGroup(
                                              challengeId: widget.challengeDetail.challengeId,
                                              userDetails: jobDetails,
                                              groupId: widget.groupModel.groupId); // try {
                                          bool created = await ChallengeApi()
                                              .userJoinGroup(joinGroup: joinGroup);
                                          if (created == false) {
                                            if (mounted) {
                                              setState(() {
                                                joinButtonLoader = false;
                                              });
                                            }
                                            return Get.defaultDialog(
                                                backgroundColor: Colors.lightBlue.shade50,
                                                title: capitalize("Sorry !"),
                                                titleStyle: TextStyle(color: Colors.blue.shade300),
                                                titlePadding: EdgeInsets.only(bottom: 0, top: 10),
                                                contentPadding: EdgeInsets.only(top: 0),
                                                content: Column(
                                                  children: [
                                                    Divider(
                                                      thickness: 2,
                                                    ),
                                                    Text(
                                                      "Something went wrong. Please try again.",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Colors.blue.shade400),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Icon(
                                                      Icons.error_outline,
                                                      size: 50,
                                                      color: Colors.blue.shade300,
                                                    ),
                                                  ],
                                                ));
                                          } else {
                                            var _groupUser = await ChallengeApi().listofGroupUsers(
                                                groupId: widget.groupModel.groupId);
                                            grpLength = _groupUser.length;
                                            setState(() {});
                                            if (DateTime.now().isAfter(
                                                widget.challengeDetail.challengeStartTime)) {
                                              if (grpLength == null ||
                                                  grpLength <
                                                      widget.challengeDetail.minUsersGroup) {
                                                if (mounted) {
                                                  setState(() {
                                                    joinButtonLoader = false;
                                                  });
                                                }
                                                return Get.defaultDialog(
                                                    barrierDismissible: false,
                                                    onWillPop: () => null,
                                                    backgroundColor: Colors.lightBlue.shade50,
                                                    title:
                                                        'The challenge will commence once at least ${widget.challengeDetail.minUsersGroup} participants join.',
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
                                                        Divider(
                                                          thickness: 2,
                                                        ),
                                                        Icon(
                                                          Icons.task_alt,
                                                          size: 40,
                                                          color: Colors.blue.shade300,
                                                        ),
                                                        SizedBox(
                                                          height: 15,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            // Get.offAll(HomeScreen(introDone: true),
                                                            //     transition: Transition.size);
                                                            Get.off(LandingPage());
                                                          },
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(context).size.width /
                                                                    4,
                                                            decoration: BoxDecoration(
                                                                color: Colors.blue,
                                                                borderRadius:
                                                                    BorderRadius.circular(20)),
                                                            child: Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text(
                                                                  'Ok',
                                                                  style: TextStyle(
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ));
                                              } else {
                                                if (mounted) {
                                                  setState(() {
                                                    joinButtonLoader = false;
                                                  });
                                                }
                                                return Get.defaultDialog(
                                                    barrierDismissible: false,
                                                    backgroundColor: Colors.lightBlue.shade50,
                                                    title: "Great! You're all set.",
                                                    titlePadding:
                                                        EdgeInsets.only(top: 20, bottom: 0),
                                                    titleStyle: TextStyle(
                                                        letterSpacing: 1,
                                                        color: Colors.blue.shade400,
                                                        fontSize: 23),
                                                    contentPadding: EdgeInsets.only(top: 0),
                                                    content: Column(
                                                      children: [
                                                        Divider(
                                                          thickness: 2,
                                                        ),
                                                        Icon(
                                                          Icons.task_alt,
                                                          size: 40,
                                                          color: Colors.blue.shade300,
                                                        ),
                                                        SizedBox(
                                                          height: 15,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            List<EnrolledChallenge>
                                                                enroledChalenges_list =
                                                                await ChallengeApi()
                                                                    .listofUserEnrolledChallenges(
                                                                        userId: jobDetails.userId);
                                                            EnrolledChallenge currentERchallenge;
                                                            GroupDetailModel groupDetailModel;
                                                            for (var i in enroledChalenges_list) {
                                                              if (i.challengeId ==
                                                                  widget.challengeDetail
                                                                      .challengeId) {
                                                                currentERchallenge = i;
                                                                groupDetailModel =
                                                                    await ChallengeApi()
                                                                        .challengeGroupDetail(
                                                                            groupID: i.groupId);
                                                              }
                                                            }
                                                            Get.to(OnGoingChallenge(
                                                                filteredList: currentERchallenge,
                                                                groupDetail: groupDetailModel,
                                                                challengeDetail:
                                                                    widget.challengeDetail,
                                                                navigatedNormal: false));
                                                          },
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(context).size.width /
                                                                    4,
                                                            decoration: BoxDecoration(
                                                                color: Colors.blue,
                                                                borderRadius:
                                                                    BorderRadius.circular(20)),
                                                            child: Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text(
                                                                  'Ok',
                                                                  style: TextStyle(
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ));
                                              }
                                            } else {
                                              getdef();
                                            }
                                          }
                                          // } catch (e) {}
                                        }
                                      }
                                      // }
                                    } else {
                                      if (mounted) {
                                        setState(() {
                                          joinButtonLoader = false;
                                        });
                                      }
                                    }
                                    // }
                                  },
                            style: ElevatedButton.styleFrom(
                                shape:
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                // ignore: deprecated_member_use
                                primary: Colors.lightBlue,
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                                textStyle: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                            child: joinButtonLoader
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(widget.groupModel != null ? "Join" : "Create"),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ))),
      ),
    );
  }

  Future<Widget> dialogBox() {
    return fitImplemented && fitInstalled
        ? Container()
        : Get.defaultDialog(
            title: "",
            titlePadding: EdgeInsets.only(),
            // barrierDismissible: false,
            onWillPop: () {
              if (mounted) {
                setState(() {
                  joinButtonLoader = false;
                });
              }
              Get.back();
              return Future.value(false);
            },
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: Platform.isAndroid ? 20.sp : 25.sp,
                        child: Platform.isAndroid
                            ? Image.asset("assets/icons/googlefit.png")
                            : Image.asset(
                                "assets/icons/health_icon.png",
                                height: 25.sp,
                              ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        Platform.isAndroid ? "Google Fit" : "Health",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      var prefs = await SharedPreferences.getInstance();
                      final box = GetStorage();
                      bool t;
                      if (Platform.isAndroid) {
                        t = await LaunchApp.isAppInstalled(
                            androidPackageName: "com.google.android.apps.fitness");
                      } else {
                        t = true;
                      }
                      // t
                      //     ? Container()
                      //     : await LaunchApp.openApp(
                      //         openStore: true, androidPackageName: "com.google.android.apps.fitness");

                      final types = [
                        HealthDataType.STEPS,
                        HealthDataType.ACTIVE_ENERGY_BURNED,
                        HealthDataType.DISTANCE_DELTA,
                        HealthDataType.MOVE_MINUTES,
                      ];

                      final permissions = [
                        HealthDataAccess.READ,
                        HealthDataAccess.READ,
                        HealthDataAccess.READ,
                        HealthDataAccess.READ,
                      ];

                      if (t) {
                        try {
                          GoogleSignIn _googleSignIn = GoogleSignIn(
                            scopes: [
                              'email',
                              'https://www.googleapis.com/auth/contacts.readonly',
                            ],
                          );
                          await _googleSignIn.signOut();
                          bool _authenticate =
                              await health.requestAuthorization(types, permissions: permissions);
                          if (_authenticate) {
                            final box = GetStorage();
                            SharedPreferences _prefs = await SharedPreferences.getInstance();
                            _prefs.setBool('fit', _authenticate);
                            box.write("fit", _authenticate);
                            fitImplemented = _authenticate;
                            Get.back();
                            Get.snackbar('Success', 'Connected Successfully',
                                margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                backgroundColor: AppColors.primaryAccentColor,
                                colorText: Colors.white,
                                duration: Duration(seconds: 5),
                                snackPosition: SnackPosition.BOTTOM);
                          } else {
                            setState(() => joinButtonLoader = false);

                            prefs.setBool("fit", _authenticate);
                            box.write("fit", _authenticate);
                            fitImplemented = _authenticate;
                            Get.back();
                            Get.snackbar('Connection Error', 'Unable to connect to Google Fit.',
                                margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                backgroundColor: AppColors.failure,
                                colorText: Colors.white,
                                duration: Duration(seconds: 5),
                                snackPosition: SnackPosition.BOTTOM);
                          }
                        } catch (e) {}
                      } else {
                        await LaunchApp.openApp(
                            openStore: true, androidPackageName: "com.google.android.apps.fitness");
                      }
                    },
                    child: Text('Connect to  ${Platform.isAndroid ? "Google Fit" : "Health"}'),
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  ),
                )
              ],
            ),
          );
  }

  getdef() {
    Get.defaultDialog(
        barrierDismissible: false,
        backgroundColor: Colors.lightBlue.shade50,
        title: 'Welcome aboard!',
        titlePadding: EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
        titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
        contentPadding: EdgeInsets.only(top: 0),
        content: Column(
          children: [
            Divider(
              thickness: 2,
            ),
            Icon(
              Icons.task_alt,
              size: 50,
              color: Colors.blue.shade300,
            ),
            SizedBox(
              height: 15,
            ),
            Get.find<ListChallengeController>().affiliateCmpnyList.contains("persistent") &&
                    widget.challengeDetail.affiliations.contains("persistent") &&
                    widget.challengeDetail.challengeMode == "individual"
                ? Text(
                    "Run will be active from ${Jiffy(widget.challengeDetail.challengeStartTime).format("do MMM yyyy")}",
                    textAlign: TextAlign.center,
                    style: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                  )
                : Text(
                    "Challenge will be active from ${Jiffy(widget.challengeDetail.challengeStartTime).format("do MMM yyyy")}",
                    textAlign: TextAlign.center,
                    style: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                  ),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                // Get.offAll(HomeScreen(introDone: true), transition: Transition.size);
                Get.off(LandingPage());
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 4,
                decoration:
                    BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Ok',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
