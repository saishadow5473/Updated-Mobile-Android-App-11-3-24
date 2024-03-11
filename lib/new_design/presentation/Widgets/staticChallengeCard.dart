import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../health_challenge/views/health_challenges_types.dart';
import '../../app/utils/textStyle.dart';
import '../pages/basicData/functionalities/percentage_calculations.dart';
import '../pages/basicData/screens/ProfileCompletion.dart';
import 'dashboardWidgets/affiliation_widgets.dart';

class StaticChallengeCard extends StatelessWidget {
  const StaticChallengeCard(
      {key, @required this.imagePath, @required this.title, @required this.enable});
  final String imagePath;
  final String title;
  final bool enable;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () async {
            var prefs = await SharedPreferences.getInstance();
            String ss = prefs.getString("sso_flow_affiliation");
            if (ss != null) {
              Map<String, dynamic> exsitingAffi = jsonDecode(ss);
              UpdatingColorsBasedOnAffiliations.ssoAffiliation = {
                "affiliation_unique_name": exsitingAffi["affiliation_unique_name"]
              };
            }
            var affi = (UpdatingColorsBasedOnAffiliations.ssoAffiliation == null ||
                    UpdatingColorsBasedOnAffiliations.ssoAffiliation['affiliation_unique_name'] ==
                        null)
                ? "Global"
                : UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"];
            PercentageCalculations().calculatePercentageFilled() != 100
                ? Get.to(ProfileCompletionScreen())
                : Get.to(HealthChallengesComponents(
                    list: [affi],
                  ));
          },
          child: Container(
            height: 100.h < 800 ? 28.h : 22.h,
            width: 46.w,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: EdgeInsets.only(top: 14.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(imagePath),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Text(
                    title,
                    style: AppTextStyles.HealthChallengeDescription,
                  )
                ],
              ),
            ),
          ),
        ),
        if (enable == false)
          InkWell(
            onTap: () => Get.showSnackbar(
              const GetSnackBar(
                title: "Coming Soon!",
                message: 'This feature is not available right now',
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 3),
              ),
            ),
            child: Container(
              height: 22.h,
              width: 46.w,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
            ),
          ),
      ],
    );
  }
}
