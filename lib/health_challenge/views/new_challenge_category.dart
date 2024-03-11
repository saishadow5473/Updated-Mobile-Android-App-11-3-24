import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ihl/health_challenge/views/dynamic_enrolled_health_challenge.dart';
import 'package:ihl/health_challenge/views/dynamic_health_challenge_types.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Getx/controller/listOfChallengeContoller.dart';
import '../../new_design/app/utils/appColors.dart';
import '../../new_design/presentation/controllers/healthchallenge/dynamicHealthChallengeController.dart';
import '../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../controllers/challenge_api.dart';
import '../models/GetChallengeCategory.dart';
import '../widgets/custom_card.dart';
import 'achived_challenge.dart';

class NewChallengeCategory extends StatefulWidget {
  const NewChallengeCategory({Key key}) : super(key: key);

  @override
  State<NewChallengeCategory> createState() => _NewChallengeCategoryState();
}

class _NewChallengeCategoryState extends State<NewChallengeCategory> {
List challengeComponents=[];
  @override
  void initState() {
    challengeComponents = [
      {
        'imagePath': 'assets/icons/steps.png',
        "voidcallback": () async {

        }
      },
      {
        'imagePath': 'assets/icons/exercise.png',
        "voidcallback": () async {
        }
      },

    ];
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return CommonScreenForNavigation(
      appBar:AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("Health Challenges", style: TextStyle(color: Colors.white)),
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
      content: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
        child: GetBuilder<ListChallengeController>(
    builder: (ListChallengeController controller) {
    return SizedBox(height: 100.h,
      child: SingleChildScrollView(

      child: controller.getChallengeCategoryList==null?SizedBox():Column(
      children: [
    GetBuilder<DynamicHealthChallengeController>(
    init: DynamicHealthChallengeController(),
    // id: _dynhealthChallengeController.fetchId,
    builder: (_) {
    return
    Column(
      children: controller.getChallengeCategoryList.status.toSet().toList()
          .map((e) => GestureDetector(
        onTap: ()async{
          SharedPreferences prefs1 = await SharedPreferences.getInstance();
          String userid = prefs1.getString("ihlUserId");
          if(_.sortedEnrolledCompleted==null||_.listofChallenges==null){
            Get.to(DynamicHealthChallengesComponents(challengeCategory: e,));
          }
          else {
            _.sortedEnrolledCompleted == null && _.sortedEnrolledCompleted.started.isEmpty &&
                _.sortedEnrolledCompleted.notStarted.isEmpty &&
                _.sortedEnrolledCompleted.completed.isEmpty ? Get.to(DynamicHealthChallengeTypes(
              challengeCategory: e,
            )) : _.listofChallenges.isEmpty && _.sortedEnrolledCompleted.completed.isEmpty ? Get.to(
                DynamicEnrolledChallengesListScreen(
                  challengeCategory: e,
                  uid: userid,
                )) : _.listofChallenges.isEmpty && _.sortedEnrolledCompleted.started.isEmpty &&
                _.sortedEnrolledCompleted.notStarted.isEmpty ?
            Get.to(AchievedChallengesListScreen(
                uid: userid,
                challengeCategory: e
            )) : Get.to(DynamicHealthChallengesComponents(challengeCategory: e,));
          }},
            child: Card(
      elevation: 4,
      child: Row(
      children: [
      Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
      height: width / 5,
      width: width / 5,
      child: Image.asset(e.contains('Step')?'assets/icons/steps.png':'assets/icons/exercise.png'),
      // decoration: BoxDecoration(
      // borderRadius: BorderRadius.circular(10),
      //     // image: DecorationImage(
      //     //     fit: BoxFit.cover,
      //     //     image: NetworkImage(challengeDetail.challengeImgUrlThumbnail))
      // ),
      ),
      ),
      SizedBox(
      width: width / 60,
      ),
      SizedBox(
      width: width / 1.7,
      child: Text(e,
      style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
      color: Colors.blueGrey)),
      ),
      ],
      ),
      ),
          ),).toSet()
          .toList());
    }),
      SizedBox(height: 5.h,)
      ],
      ),
      ),
    );
    }
      ) ,
    ));
  }


}
