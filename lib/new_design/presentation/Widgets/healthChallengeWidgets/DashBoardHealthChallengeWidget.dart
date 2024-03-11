import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/views/new_challenge_category.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../health_challenge/views/enrolled_challenges_list_screen.dart';
import '../../../../health_challenge/views/health_challenges_types.dart';
import '../../../../utils/SpUtil.dart';
import '../../../../utils/app_colors.dart';
import '../../../app/utils/appText.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../controllers/dashboardControllers/upComingDetailsController.dart';
import '../../pages/basicData/functionalities/percentage_calculations.dart';
import '../../pages/basicData/screens/ProfileCompletion.dart';
import '../../pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../dashboardWidgets/affiliation_widgets.dart';
import '../dashboardWidgets/teleconsultation_widget.dart';
import '../healthChallengeCard.dart';

class DashBoardHealthChallengeWidget {
  final upcomingDetailController = Get.put(UpcomingDetailsController());

  Widget upcomingChallengeWidget(BuildContext context, {bool top = false}) {
    return GetBuilder<UpcomingDetailsController>(
      id: upcomingDetailController.challengeWidgetUpdateId,
      builder: (_) {
        try {
          return (_.loading)
              ? Shimmer.fromColors(
                  direction: ShimmerDirection.ltr,
                  period: const Duration(seconds: 2),
                  baseColor: const Color.fromARGB(255, 240, 240, 240),
                  highlightColor: Colors.grey.withOpacity(0.2),
                  child: Container(
                      height: 25.h,
                      width: 95.w,
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Hello')))
              : _.upComingDetails.enrolChallengeList.length > 0 && top
                  ? Padding(
                      padding: EdgeInsets.only(right: 1.w, left: 1.5.w, bottom: 1.h),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(10.sp, 14, 14, 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Ongoing Challenge",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16.sp,
                                    color: UpdatingColorsBasedOnAffiliations.affiColorCode.value ==
                                            0
                                        ? AppColors.primaryAccentColor
                                        : Color(
                                            UpdatingColorsBasedOnAffiliations.affiColorCode.value,
                                          ),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                TeleConsultationWidgets().viewAll(
                                  onTap: () =>
                                      // Get.to(NewChallengeCategory())
                                      Get.to(EnrolledChallengesListScreen(
                                    uid: SpUtil.getString(LSKeys.ihlUserId),
                                  )),
                                  // color: affiColor
                                )
                              ],
                            ),
                          ),
                          Card(
                            child: ChallengeCard().enrolledChallenge(context, color: affiColor),
                          ),
                        ],
                      ),
                    )
                  : top == false && _.upComingDetails.enrolChallengeList.isEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 1.h, left: 1.w, bottom: 1.5.h),
                              child: Text(
                                AppTexts.newChallenge,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15.3.sp,
                                  color: UpdatingColorsBasedOnAffiliations.affiColorCode.value ==
                                              null ||
                                          UpdatingColorsBasedOnAffiliations
                                                  .ssoAffiliation["affiliation_unique_name"] ==
                                              null
                                      ? AppColors.primaryColor
                                      : Color(
                                          UpdatingColorsBasedOnAffiliations.affiColorCode.value,
                                        ),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  PercentageCalculations().calculatePercentageFilled() != 100
                                      ? Get.to(ProfileCompletionScreen())
                                      : Get.to(HealthChallengesComponents(
                                          list: UpdatingColorsBasedOnAffiliations
                                                      .selectedAffiliation.value ==
                                                  ""
                                              ? ["global", "Global"]
                                              : [
                                                  UpdatingColorsBasedOnAffiliations
                                                      .selectedAffiliation.value
                                                ],
                                        )),
                              // Get.to(HealthChallengesComponents(
                              // // list: ["global", "Global"],
                              // list: [UpdatingColorsBasedOnAffiliations.selectedAffiliation.value])),
                              child: ChallengeCard().noChallenegs(context),
                            ),
                          ],
                        )
                      : const SizedBox();
        } catch (e) {
          debugPrint('Challenge shimmer');
          return Shimmer.fromColors(
              direction: ShimmerDirection.ltr,
              period: const Duration(seconds: 2),
              baseColor: const Color.fromARGB(255, 240, 240, 240),
              highlightColor: Colors.grey.withOpacity(0.2),
              child: Container(
                  height: 25.h,
                  width: 95.w,
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                  decoration:
                      BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Hello')));
        }
      },
    );
  }
}
