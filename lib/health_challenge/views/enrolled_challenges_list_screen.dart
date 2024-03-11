import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc;
import 'package:get/get.dart';
import 'package:ihl/health_challenge/controllers/challenge_api.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/health_challenge/models/group_details_model.dart';
import 'package:ihl/health_challenge/models/list_of_users_in_group.dart';
import 'package:ihl/health_challenge/views/on_going_challenge.dart';
import 'package:ihl/new_design/presentation/pages/healthChalleneg/blocWidget/challengeBloc.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:strings/strings.dart';

import '../../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../new_design/presentation/controllers/dashboardControllers/upComingDetailsController.dart';
import '../../new_design/presentation/controllers/healthchallenge/healthChallengeController.dart';
import '../../new_design/presentation/pages/healthChalleneg/blocWidget/challengeEvents.dart';
import '../../new_design/presentation/pages/healthChalleneg/dynamicHealthChallenge/dynamicCertificateDetailScreen.dart';
import '../../new_design/presentation/pages/healthChalleneg/dynamicHealthChallenge/dynamicGroupOnGoingScreen.dart';
import '../../new_design/presentation/pages/healthChalleneg/dynamicHealthChallenge/dynamicIndividualScreen.dart';
import '../../new_design/presentation/pages/healthChalleneg/getX_widget_responsive/challange_ui_reponse.dart';
import '../persistent/views/persistent_onGoingScreen.dart';
import 'certificate_detail.dart';

String guid;
bool gglobal;
String gaffiname;

class EnrolledChallengesListScreen extends StatefulWidget {
  EnrolledChallengesListScreen({
    Key key,
    @required this.uid,
  }) : super(key: key);
  String uid;
  @override
  State<EnrolledChallengesListScreen> createState() => _EnrolledChallengesListScreenState();
}

class _EnrolledChallengesListScreenState extends State<EnrolledChallengesListScreen> {
  @override
  void initState() {
    _getData();

    super.initState();
  }
  SessionSelectionController sessionSelectionController = Get.put(SessionSelectionController());
  var _fetching = false.obs;
  List<EnrolledChallenge> enroledChalenges = [];
  List<EnrolledChallenge> affiEnrolledChallenges = [];
  List<ChallengeDetail> listofchallenges = [];
  bool setEmpty = false;
  bool loading = true;
  _getData() async {
    var prefs = await SharedPreferences.getInstance();
    String ss = prefs.getString("sso_flow_affiliation");
    if (ss != null) {
      Map<String, dynamic> exsitingAffi = jsonDecode(ss);
      UpdatingColorsBasedOnAffiliations.ssoAffiliation = {
        "affiliation_unique_name": exsitingAffi["affiliation_unique_name"]
      };
    }
    var affiname = (UpdatingColorsBasedOnAffiliations.ssoAffiliation == null ||
            UpdatingColorsBasedOnAffiliations.ssoAffiliation['affiliation_unique_name'] == null)
        ? "Global"
        : UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"];
    try {
      enroledChalenges = await ChallengeApi().listofUserEnrolledChallenges(userId: widget.uid);
    } catch (e) {
      if (mounted) setState(() => setEmpty = true);
      debugPrint('Fetch Error');
    }
    if (enroledChalenges.isNotEmpty) {
      enroledChalenges.removeWhere((element) => element.userProgress == "completed");
      enroledChalenges.removeWhere((element) => element.userStatus != "active");
    }
    for (int i = 0; i < enroledChalenges.length; i++) {
      listofchallenges
          .add(await ChallengeApi().challengeDetail(challengeId: enroledChalenges[i].challengeId));
    }
    // listofchallenges.removeWhere((element) => element.affiliations.contains("global"));

    // listofchallenges.removeWhere((element) => !element.affiliations.contains(affiname));

    // listofchallenges.removeWhere((element) => element.affiliations.length < 2);

    if (listofchallenges.isNotEmpty && enroledChalenges.isNotEmpty) {
      affiEnrolledChallenges.addAll(enroledChalenges.where(
          (i) => listofchallenges.any((challenge) => i.challengeId == challenge.challengeId)));

      affiEnrolledChallenges.toSet();
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
          title: Text("Active Challenges", style: TextStyle(color: Colors.white)),
          leading: InkWell(
            onTap: () {
              Get.put(UpcomingDetailsController()).onInit();
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
                                  child: Text("Oops! There are no challenges available right now."),
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
                              return customListTile(
                                  challengeDetail: snapshot.data,
                                  context: context,
                                  enrolledChalenges: affiEnrolledChallenges[i],
                                  groupID: affiEnrolledChallenges[i].groupId ?? "");
                            });
                      })
                  : Center(child: Text("Oops! There are no challenges available right now.")),
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
      child: Obx(
        () => IgnorePointer(
          ignoring: _fetching.value,
          child: GestureDetector(
            onTap: () async {
              _fetching.value = true;
              GroupDetailModel groupDetailModel;
              bool currentUserIsAdmin = false;
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String userid = prefs.getString("ihlUserId");

              if (enrolledChalenges.challengeMode != "individual") {
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
                groupDetailModel = await ChallengeApi().challengeGroupDetail(groupID: groupID);
              }

              if (enrolledChalenges.challengeMode == "individual") {
                if (enrolledChalenges.userProgress == 'completed') {
                  Get.to(
                      CertificateDetail(
                          challengeDetail: challengeDetail,
                          enrolledChallenge: enrolledChalenges,
                          groupDetail: groupDetailModel,
                          currentUserIsAdmin: currentUserIsAdmin),
                      transition: Transition.rightToLeft);
                } else {
                  if (challengeDetail.challengeType == 'Step Challenge') {
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
                    // await sessionSelectionController.getUserDetails(enrolledChalenges);

                    Get.to(
                      () => DynamicIndividualScreen(
                        enrolledchallenge: enrolledChalenges,
                        challengeDetail: challengeDetail,
                        firstTimeLog: false,
                      ),
                    );
                  }
                }
              } else {
                List<GroupUser> liGroup = await ChallengeApi().listofGroupUsers(groupId: groupID);

                if (liGroup.length < challengeDetail.minUsersGroup) {
                  _fetching.value = false;
                  Get.defaultDialog(
                      barrierDismissible: false,
                      onWillPop: () => null,
                      backgroundColor: Colors.lightBlue.shade50,
                      title:
                          'The challenge will commence once at least ${challengeDetail.minUsersGroup} participants join.',
                      titlePadding: EdgeInsets.only(top: 20, bottom: 0, right: 10, left: 10),
                      titleStyle:
                          TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
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
                  _fetching.value = false;
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
                  if (enrolledChalenges.userProgress == 'completed') {
                    _fetching.value = false;
                    challengeDetail.challengeType == "Step Challenge"
                        ? Get.to(
                            CertificateDetail(
                                challengeDetail: challengeDetail,
                                enrolledChallenge: enrolledChalenges,
                                groupDetail: groupDetailModel,
                                currentUserIsAdmin: currentUserIsAdmin),
                            transition: Transition.rightToLeft)
                        : Get.to(DynamicCertificateScreen(
                            challengeDetail: challengeDetail,
                            enrolledChallenge: enrolledChalenges,
                            duration: 0,
                            groupName: groupDetailModel.groupName,
                          ));
                  } else {
                    if (challengeDetail.challengeType == "Step Challenge") {
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
                      Get.to(
                        () => DynamicGroupOnGoingScreen(
                            enrolledchallenge: enrolledChalenges,
                            currentUserIsAdmin: currentUserIsAdmin,
                            firstTimeLog: false,
                            challengeDetail: challengeDetail,
                            filteredList: enrolledChalenges,
                            groupModel: groupDetailModel),
                      );
                    }
                  }
                }
              }
              _fetching.value = false;
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
        ),
      ),
    );
  }
}
