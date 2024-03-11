import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/controllers/challenge_api.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/health_challenge/models/group_details_model.dart';
import 'package:ihl/health_challenge/models/list_of_users_in_group.dart';
import 'package:ihl/health_challenge/views/on_going_challenge.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:strings/strings.dart';

import '../../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../persistent/views/persistent_onGoingScreen.dart';
import '../persistent/views/persistnet_certificateScreen.dart';
import 'certificate_detail.dart';

class AchievedChallengesListScreen extends StatefulWidget {
  AchievedChallengesListScreen({
    Key key,
    @required this.uid,
    @required this.challengeCategory,
  }) : super(key: key);
  String uid;
  String challengeCategory;
  @override
  State<AchievedChallengesListScreen> createState() => _AchievedChallengesListScreenState();
}

class _AchievedChallengesListScreenState extends State<AchievedChallengesListScreen> {
  @override
  void initState() {
    _getData();
    super.initState();
  }
  Map<String, dynamic> existingAffi;
  List<EnrolledChallenge> enroledChalenges = [];
  List<EnrolledChallenge> affiEnrolledChallenges = [];
  List<ChallengeDetail> listofchallenges = [];
  bool setEmpty = false;
  bool loading = true;

  _getData() async {
    var prefs = await SharedPreferences.getInstance();
    String ss = prefs.getString("sso_flow_affiliation");
    if (ss != null) {
      existingAffi = jsonDecode(ss);
      UpdatingColorsBasedOnAffiliations.ssoAffiliation = {
        "affiliation_unique_name": existingAffi["affiliation_unique_name"]
      };
    }
    var affiname = (UpdatingColorsBasedOnAffiliations.ssoAffiliation == null ||
            UpdatingColorsBasedOnAffiliations.ssoAffiliation['affiliation_unique_name'] == null)
        ? "Global"
        : UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"];

    enroledChalenges = await ChallengeApi().listofUserEnrolledChallenges(userId: widget.uid);
    if (enroledChalenges.isNotEmpty) {
      enroledChalenges.removeWhere((element) => element.userProgress != "completed");
    }
    for (int i = 0; i < enroledChalenges.length; i++) {
      listofchallenges
          .add(await ChallengeApi().challengeDetail(challengeId: enroledChalenges[i].challengeId));
    }

    // listofchallenges.removeWhere((element) => !element.affiliations.contains(affiname));

    /* listofchallenges.retainWhere(
          (element) => element.affiliations.contains(widget.affi.first));*/

    if (listofchallenges.isNotEmpty) {
      for (var i in enroledChalenges) {
        for (int x = 0; x < listofchallenges.length; x++) {
          print(listofchallenges[x].affiliations.toString().replaceAll("]", "").replaceAll("[", "").runtimeType);
          affiEnrolledChallenges.addIf((i.challengeId == listofchallenges[x].challengeId&&existingAffi["affiliation_unique_name"]==listofchallenges[x].affiliations.toString().replaceAll("]", "").replaceAll("[", "")), i);
        }
      }
    } else {
      setEmpty = true;
    }

    // print(affiEnrolledChallenges.first.toJson());
    loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ScrollessBasicPageUI(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text("Participated", style: TextStyle(color: Colors.white)),
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
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: loading
              ? Center(child: CircularProgressIndicator())
              : !setEmpty && affiEnrolledChallenges.length != 0
                  ? ListView.builder(
                      itemCount: affiEnrolledChallenges.length,
                      itemBuilder: (ctx, i) {
                        return FutureBuilder<ChallengeDetail>(
                            future: ChallengeApi().challengeDetail(
                                challengeId: affiEnrolledChallenges[i].challengeId),
                            builder: (ctx, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text("No challenges completed yet."),
                                );
                              }
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Shimmer.fromColors(
                                    child: Container(
                                        margin: EdgeInsets.all(8),
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.width / 5,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text('Hello')),
                                    direction: ShimmerDirection.ltr,
                                    period: Duration(seconds: 2),
                                    baseColor: Colors.white,
                                    highlightColor: Colors.grey.withOpacity(0.2));
                              }
                              return affiEnrolledChallenges[i].challengeType==widget.challengeCategory?customListTile(
                                  challengeDetail: snapshot.data,
                                  context: context,
                                  enrolledChalenges: affiEnrolledChallenges[i],
                                  groupID: affiEnrolledChallenges[i].groupId ?? ""):SizedBox();
                            });
                      })
                  : Center(child: Text("No challenges completed yet.")),
        ));
  }

  Widget customListTile({
    ChallengeDetail challengeDetail,
    BuildContext context,
    String groupID,
    EnrolledChallenge enrolledChalenges,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () async {
          bool currentUserIsAdmin = false;
          GroupDetailModel groupDetailModel;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String userid = prefs.getString("ihlUserId");
          await ChallengeApi().listofGroupUsers(groupId: enrolledChalenges.groupId).then((value) {
            for (var i in value) {
              if (i.userId == userid && i.role == "admin") {
                currentUserIsAdmin = true;
                break;
              }
            }
          });
          if (enrolledChalenges.challengeMode != "individual")
            groupDetailModel = await ChallengeApi().challengeGroupDetail(groupID: groupID);

          if (enrolledChalenges.challengeMode == "individual") {
            if (enrolledChalenges.userProgress == 'completed')
              Get.to(
                  enrolledChalenges.selectedFitnessApp != "other_apps"
                      ? CertificateDetail(
                          challengeDetail: challengeDetail,
                          enrolledChallenge: enrolledChalenges,
                          groupDetail: groupDetailModel,
                          currentUserIsAdmin: currentUserIsAdmin,
                          firstCopmlete: false,
                        )
                      : PersistentCertificateScreen(
                          challengedetail: challengeDetail,
                          enrolledChallenge: enrolledChalenges,
                          navNormal: true,
                          firstComplete: false,
                        ),
                  transition: Transition.rightToLeft);
            else
              Get.to(
                  enrolledChalenges.selectedFitnessApp != "other_apps"
                      ? OnGoingChallenge(
                          challengeDetail: challengeDetail,
                          navigatedNormal: true,
                          filteredList: enrolledChalenges,
                          groupDetail: groupDetailModel,
                        )
                      : PersistentOnGoingScreen(
                          challengeDetail: challengeDetail,
                          challengeStarted:
                              DateTime.now().isAfter(challengeDetail.challengeStartTime)
                                  ? true
                                  : false,
                          enrolledChallenge: enrolledChalenges,
                          nrmlJoin: true,
                        ),
                  transition: Transition.leftToRight);
          } else {
            List<GroupUser> liGroup = await ChallengeApi().listofGroupUsers(groupId: groupID);
            if (liGroup.length < challengeDetail.minUsersGroup) {
              Get.defaultDialog(
                  barrierDismissible: false,
                  backgroundColor: Colors.lightBlue.shade50,
                  title:
                      'The challenge will commence once at least ${challengeDetail.minUsersGroup} participants join.',
                  titlePadding: EdgeInsets.only(top: 18.sp, bottom: 0, left: 11.sp, right: 11.sp),
                  titleStyle:
                      TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 19.sp),
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
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 4,
                          decoration: BoxDecoration(
                              color: Colors.blue, borderRadius: BorderRadius.circular(20)),
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
            } else {
              bool currentUserIsAdmin = false;
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String userid = prefs.getString("ihlUserId");
              await ChallengeApi()
                  .listofGroupUsers(groupId: enrolledChalenges.groupId)
                  .then((value) {
                for (var i in value) {
                  if (i.userId == userid && i.role == "admin") {
                    currentUserIsAdmin = true;
                    break;
                  }
                }
              });
              if (enrolledChalenges.userProgress == 'completed' ||
                  enrolledChalenges.groupProgress == 'completed') {
                Get.to(
                    enrolledChalenges.selectedFitnessApp != "other_apps"
                        ? CertificateDetail(
                            challengeDetail: challengeDetail,
                            enrolledChallenge: enrolledChalenges,
                            groupDetail: groupDetailModel,
                            currentUserIsAdmin: currentUserIsAdmin,
                            firstCopmlete: false,
                          )
                        : PersistentCertificateScreen(
                            challengedetail: challengeDetail,
                            enrolledChallenge: enrolledChalenges,
                            navNormal: true,
                            firstComplete: false,
                          ),
                    transition: Transition.rightToLeft);
              } else
                Get.to(
                    enrolledChalenges.selectedFitnessApp != "other_apps"
                        ? OnGoingChallenge(
                            challengeDetail: challengeDetail,
                            navigatedNormal: true,
                            filteredList: enrolledChalenges,
                            groupDetail: groupDetailModel,
                          )
                        : PersistentOnGoingScreen(
                            challengeDetail: challengeDetail,
                            challengeStarted:
                                DateTime.now().isAfter(challengeDetail.challengeStartTime)
                                    ? true
                                    : false,
                            enrolledChallenge: enrolledChalenges,
                            nrmlJoin: true,
                          ),
                    transition: Transition.leftToRight);
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(offset: Offset(1, 1), blurRadius: 6, color: Colors.grey.shade200)
              ]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                challengeDetail.challengeImgUrlThumbnail == null
                    ? CircularProgressIndicator()
                    : Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(250),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(challengeDetail.challengeImgUrlThumbnail))),
                      ),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.6,
                  child: Text(
                    capitalize(challengeDetail.challengeName),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
