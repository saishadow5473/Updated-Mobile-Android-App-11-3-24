import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/healthChalleneg/dynamicHealthChallenge/dynamicChallengeDetailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../new_design/presentation/pages/healthChalleneg/dynamicHealthChallenge/dynamicIndividualScreen.dart';
import '../controllers/challenge_api.dart';
import '../models/challenge_detail.dart';
import '../models/enrolled_challenge.dart';
import '../views/challenge_details_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PlaningGrid extends StatelessWidget {
  PlaningGrid(
      {Key key,
      @required this.title,
      @required this.groupOrIndividual,
      @required this.imageUrl,
      @required this.challengeType,
      @required this.challangeID})
      : super(key: key);
  ChallengeDetail challengeDetail;
  final title, groupOrIndividual, imageUrl, challangeID, challengeType;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      child: GestureDetector(
        onTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var iHLUserId = prefs.getString("ihlUserId");
          try {
            challengeDetail = await ChallengeApi().challengeDetail(challengeId: challangeID);
            // List<EnrolledChallenge> enroledChalenges_list =
            //     await ChallengeApi().listofUserEnrolledChallenges(userId: iHLUserId);
            if (challengeType != "Step Challenge") {
              if (challengeDetail.challengeMode == "individual") {
                Get.to(DynamicIndividualScreen(
                  challengeDetail: challengeDetail,
                  enrolledchallenge: null,
                  firstTimeLog: true,
                ));
              } else {
                Get.to(DynamicChallengeDetailScreen(
                  challengeDetail: challengeDetail,
                  fromNotification: false,
                ));
              }
            } else {
              Get.to(ChallengeDetailsScreen(
                fromNotification: false,
                challengeDetail: challengeDetail,
              ));
            }
          } catch (e) {
            Get.defaultDialog(title: 'Failed', middleText: "Oops, something went wrong.");
          }
        },
        child: Container(
          // color: Colors.grey,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 5)],
              borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(imageUrl)),
                          color: Colors.blueAccent.shade200,
                          borderRadius: BorderRadius.circular(10)),
                      height: 55,
                      width: 55,
                    )
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: Adaptive.w(60),
                      child: Text(
                        title,
                        // maxLines: 1,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      groupOrIndividual,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: MediaQuery.of(context).size.width * 0.03,
                      ),
                    )
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
