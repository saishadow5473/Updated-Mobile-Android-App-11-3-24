import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:jiffy/jiffy.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../../../../health_challenge/models/join_individual.dart';
import '../../../../../utils/app_colors.dart';
import '../blocWidget/challengeBloc.dart';
import '../blocWidget/challengeEvents.dart';
import 'dynamicGroupOnGoingScreen.dart';

// ignore: must_be_immutable
class DynamicCreateGroupScreen extends StatefulWidget {
  DynamicCreateGroupScreen(
      {Key key, @required this.challengeDetail, this.groupModel, this.groupMemberslength})
      : super(key: key);
  ChallengeDetail challengeDetail;
  GroupModel groupModel;
  int groupMemberslength;

  @override
  State<DynamicCreateGroupScreen> createState() => Dynamic_CreateGroupScreenState();
}

class Dynamic_CreateGroupScreenState extends State<DynamicCreateGroupScreen> {
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
    return Scaffold(
      backgroundColor: AppColors.backgroundScreenColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.groupModel != null ? "Join" : "Create a New Group",
            style: const TextStyle(color: Colors.white)),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: width / 5,
              ),
              Container(
                height: width / 1.8,
                width: width / 1.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  // boxShadow: [BoxShadow(offset: Offset(1, 1), color: Colors.grey, blurRadius: 6)],
                  image: const DecorationImage(
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
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black, fontSize: 18),
                          children: [
                            TextSpan(
                                text: 'Note : ',
                                style: TextStyle(color: AppColors.primaryColor, fontSize: 17.sp)),
                            TextSpan(
                                text: 'This group creation is valid only for ',
                                style: TextStyle(color: Colors.black54, fontSize: 17.sp)),
                            TextSpan(
                                text: '${widget.challengeDetail.challengeName} Challenge',
                                style: const TextStyle(
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Group Name",
                            style: TextStyle(color: AppColors.primaryColor, fontSize: 17.sp)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Material(
                        elevation: 0.2,
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            enabled: widget.groupModel == null,
                            controller: _groupName,
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
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.5),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: joinButtonLoader
                            ? () {}
                            : () async {
                                if (_formKey.currentState.validate()) {
                                  if (mounted) {
                                    setState(() {
                                      joinButtonLoader = true;
                                    });
                                  }
                                  // if (Get.find<ListChallengeController>()
                                  //         .affiliateCmpnyList
                                  //         .contains("Persistent") &&
                                  //     widget.challengeDetail.affiliations.contains("Persistent")) {
                                  //   CustomDialog().googleFitDia();
                                  // } else {

                                  // dialogBox();
                                  //for create a group
                                  if (widget.groupModel == null) {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    // String nickName = prefs.getString("nickName");
                                    var jobDetails = UserDetails.fromJson(
                                        jsonDecode(prefs.getString("jobDetails")));
                                    CreateGroupChallenge createGroupChallenge =
                                        CreateGroupChallenge(
                                            challengeId: widget.challengeDetail.challengeId,
                                            groupName: _groupName.text,
                                            groupDetail: widget.challengeDetail.challengeName,
                                            creatorDetails: CreatorDetails(
                                                user_start_location: jobDetails.userStartLocation,
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
                                    log(createGroupChallenge.toJson().toString());
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
                                          titlePadding: const EdgeInsets.only(bottom: 0, top: 10),
                                          contentPadding: const EdgeInsets.only(top: 0),
                                          content: Column(
                                            children: [
                                              const Divider(
                                                thickness: 2,
                                              ),
                                              Text(
                                                "Try Again",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Colors.blue.shade400),
                                              ),
                                              const SizedBox(
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
                                      if (DateTime.now()
                                          .isAfter(widget.challengeDetail.challengeStartTime)) {
                                        if (grpLength == null ||
                                            grpLength < widget.challengeDetail.minUsersGroup) {
                                          if (mounted) {
                                            setState(() {
                                              joinButtonLoader = false;
                                            });
                                          }
                                          return Get.defaultDialog(
                                              barrierDismissible: false,
                                              backgroundColor: Colors.lightBlue.shade50,
                                              title:
                                                  'The challenge will commence once at least ${widget.challengeDetail.minUsersGroup} participants join.',
                                              titlePadding: EdgeInsets.only(
                                                  top: 18.sp, bottom: 0, left: 11.sp, right: 11.sp),
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
                                                      // Get.offAll(HomeScreen(introDone: true),
                                                      //     transition: Transition.size);
                                                      Get.off(LandingPage());
                                                    },
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width / 4,
                                                      decoration: BoxDecoration(
                                                          color: Colors.blue,
                                                          borderRadius: BorderRadius.circular(20)),
                                                      child: const Center(
                                                        child: Padding(
                                                          padding: EdgeInsets.all(8.0),
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
                                                  const EdgeInsets.only(top: 20, bottom: 0),
                                              titleStyle: TextStyle(
                                                  letterSpacing: 1,
                                                  color: Colors.blue.shade400,
                                                  fontSize: 23),
                                              contentPadding: const EdgeInsets.only(top: 0),
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
                                                    onTap: () async {
                                                      bool currentUserIsAdmin = false;

                                                      List<EnrolledChallenge>
                                                          enroledChalenges_list =
                                                          await ChallengeApi()
                                                              .listofUserEnrolledChallenges(
                                                                  userId: jobDetails.userId);
                                                      EnrolledChallenge currentERchallenge;
                                                      GroupDetailModel groupDetailModel;
                                                      for (var i in enroledChalenges_list) {
                                                        if (i.challengeId ==
                                                            widget.challengeDetail.challengeId) {
                                                          currentERchallenge = i;
                                                          groupDetailModel = await ChallengeApi()
                                                              .challengeGroupDetail(
                                                                  groupID: i.groupId);
                                                        }
                                                      }
                                                      SharedPreferences prefs =
                                                          await SharedPreferences.getInstance();
                                                      String userid = prefs.getString("ihlUserId");
                                                      await ChallengeApi()
                                                          .listofGroupUsers(
                                                              groupId: currentERchallenge.groupId)
                                                          .then((value) {
                                                        for (var i in value) {
                                                          if (i.userId == userid &&
                                                              i.role == "admin") {
                                                            currentUserIsAdmin = true;
                                                            break;
                                                          }
                                                        }
                                                      });
                                                      Get.to(
                                                        () => DynamicGroupOnGoingScreen(
                                                            currentUserIsAdmin: currentUserIsAdmin,
                                                            challengeDetail: widget.challengeDetail,
                                                            groupModel: groupDetailModel,
                                                            firstTimeLog: false,
                                                            filteredList: currentERchallenge),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width / 4,
                                                      decoration: BoxDecoration(
                                                          color: Colors.blue,
                                                          borderRadius: BorderRadius.circular(20)),
                                                      child: const Center(
                                                        child: Padding(
                                                          padding: EdgeInsets.all(8.0),
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
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    var jobDetails = UserDetails.fromJson(
                                        jsonDecode(prefs.getString("jobDetails")));
                                    JoinGroup joinGroup = JoinGroup(
                                        challengeId: widget.challengeDetail.challengeId,
                                        userDetails: jobDetails,
                                        groupId: widget.groupModel.groupId); // try {
                                    bool created =
                                        await ChallengeApi().userJoinGroup(joinGroup: joinGroup);
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
                                          titlePadding: const EdgeInsets.only(bottom: 0, top: 10),
                                          contentPadding: const EdgeInsets.only(top: 0),
                                          content: Column(
                                            children: [
                                              const Divider(
                                                thickness: 2,
                                              ),
                                              Text(
                                                "Try Again",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Colors.blue.shade400),
                                              ),
                                              const SizedBox(
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
                                      if (DateTime.now()
                                          .isAfter(widget.challengeDetail.challengeStartTime)) {
                                        if (grpLength == null ||
                                            grpLength < widget.challengeDetail.minUsersGroup) {
                                          if (mounted) {
                                            setState(() {
                                              joinButtonLoader = false;
                                            });
                                          }
                                          return Get.defaultDialog(
                                              barrierDismissible: false,
                                              backgroundColor: Colors.lightBlue.shade50,
                                              title:
                                                  'The challenge will commence once at least ${widget.challengeDetail.minUsersGroup} participants join.',
                                              titlePadding: EdgeInsets.only(
                                                  top: 18.sp, bottom: 0, left: 11.sp, right: 11.sp),
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
                                                      // Get.offAll(HomeScreen(introDone: true),
                                                      //     transition: Transition.size);
                                                      Get.off(LandingPage());
                                                    },
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width / 4,
                                                      decoration: BoxDecoration(
                                                          color: Colors.blue,
                                                          borderRadius: BorderRadius.circular(20)),
                                                      child: const Center(
                                                        child: Padding(
                                                          padding: EdgeInsets.all(8.0),
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
                                        } else {
                                          if (mounted) {
                                            setState(() {
                                              joinButtonLoader = false;
                                            });
                                          }
                                          return Get.defaultDialog(
                                              barrierDismissible: false,
                                              backgroundColor: Colors.lightBlue.shade50,
                                              title: 'Success',
                                              titlePadding:
                                                  const EdgeInsets.only(top: 20, bottom: 0),
                                              titleStyle: TextStyle(
                                                  letterSpacing: 1,
                                                  color: Colors.blue.shade400,
                                                  fontSize: 23),
                                              contentPadding: const EdgeInsets.only(top: 0),
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
                                                    onTap: () async {
                                                      bool currentUserIsAdmin = false;

                                                      List<EnrolledChallenge>
                                                          enroledChalenges_list =
                                                          await ChallengeApi()
                                                              .listofUserEnrolledChallenges(
                                                                  userId: jobDetails.userId);
                                                      EnrolledChallenge currentERchallenge;
                                                      GroupDetailModel groupDetailModel;
                                                      for (var i in enroledChalenges_list) {
                                                        if (i.challengeId ==
                                                            widget.challengeDetail.challengeId) {
                                                          currentERchallenge = i;
                                                          groupDetailModel = await ChallengeApi()
                                                              .challengeGroupDetail(
                                                                  groupID: i.groupId);
                                                        }
                                                      }
                                                      SharedPreferences prefs =
                                                          await SharedPreferences.getInstance();
                                                      String userid = prefs.getString("ihlUserId");
                                                      await ChallengeApi()
                                                          .listofGroupUsers(
                                                              groupId: currentERchallenge.groupId)
                                                          .then((value) {
                                                        for (var i in value) {
                                                          if (i.userId == userid &&
                                                              i.role == "admin") {
                                                            currentUserIsAdmin = true;
                                                            break;
                                                          }
                                                        }
                                                      });
                                                      Get.to(
                                                        () => DynamicGroupOnGoingScreen(
                                                            challengeDetail: widget.challengeDetail,
                                                            groupModel: groupDetailModel,
                                                            firstTimeLog: false,
                                                            currentUserIsAdmin: false,
                                                            filteredList: currentERchallenge),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width / 4,
                                                      decoration: BoxDecoration(
                                                          color: Colors.blue,
                                                          borderRadius: BorderRadius.circular(20)),
                                                      child: const Center(
                                                        child: Padding(
                                                          padding: EdgeInsets.all(8.0),
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
                                      } else {
                                        getdef();
                                      }
                                    }
                                    // } catch (e) {}
                                  }

                                  // }

                                  // }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                            shape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sp)),
                            // ignore: deprecated_member_use
                            primary: Colors.lightBlue,
                            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 12.sp),
                            textStyle: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                        child: joinButtonLoader
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                widget.groupModel != null ? "JOIN" : "CREATE",
                                style: TextStyle(fontSize: 16.sp),
                              ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget> dialogBox() {
    return fitImplemented && fitInstalled
        ? Container()
        : Get.defaultDialog(
            title: "",
            titlePadding: const EdgeInsets.only(),
            // barrierDismissible: false,
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
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        Platform.isAndroid ? "Google Fit" : "Health",
                        style: const TextStyle(
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
                          await health
                              .requestAuthorization(types, permissions: permissions)
                              .then((value) async {
                            final box = GetStorage();
                            SharedPreferences _prefs = await SharedPreferences.getInstance();
                            _prefs.setBool('fit', true);
                            box.write("fit", value);
                            fitImplemented = value;
                            Get.back();
                            Get.snackbar('Success', 'Connected Successfully',
                                margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                backgroundColor: AppColors.primaryAccentColor,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 5),
                                snackPosition: SnackPosition.BOTTOM);
                          });
                        } catch (e) {}
                      } else {
                        await LaunchApp.openApp(
                            openStore: true, androidPackageName: "com.google.android.apps.fitness");
                      }
                    },
                    child: Text('Connect to  ${Platform.isAndroid ? "Google Fit" : "Health"}'),
                    style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
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
        titlePadding: const EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
        titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
        contentPadding: const EdgeInsets.only(top: 0),
        content: Column(
          children: [
            const Divider(
              thickness: 2,
            ),
            Icon(
              Icons.task_alt,
              size: 50,
              color: Colors.blue.shade300,
            ),
            const SizedBox(
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
            const SizedBox(
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
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
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
