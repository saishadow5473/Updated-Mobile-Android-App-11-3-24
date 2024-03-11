import 'package:flutter/material.dart';
import 'package:ihl/Getx/controller/BannerChallengeController.dart';
import 'package:sizer/sizer.dart';

import '../../../health_challenge/models/challenge_detail.dart';
import '../../app/utils/appColors.dart';
import '../../data/providers/network/apis/socialApiCalls/challengeInviteApiandFunctionalities.dart';

class BannerInviteBottomSheet {
  Widget bottomSheetContentInvite(
      {BuildContext context,
      index,
      String challengeName,
      challengeId,
      BannerChallengeController bannerChallengeController}) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        height: 40.h,
        width: 100.w,
        // color: Colors.amber,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 8.h,
              width: 100.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                color: AppColors.primaryAccentColor,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x3d000000),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text("Send Invite",
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, letterSpacing: 0.6)),
            ),
            SizedBox(height: 2.h),
            Text("Invite up-to 5 friends / family members",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12.sp,
                  letterSpacing: 0.6,
                ),
                textAlign: TextAlign.center),
            SizedBox(height: 1.h),
            Text("(${bannerChallengeController.invited.value}/5 invite left)",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                  letterSpacing: 0.6,
                ),
                textAlign: TextAlign.center),
            SizedBox(height: 2.h),
            SizedBox(
              width: 90.w,
              child: TextField(
                controller: bannerChallengeController.sendInviteEmailController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    // labelText: 'Someone@gmail.com',
                    hintText: "Someone@gmail.com"),
              ),
            ),
            SizedBox(height: 3.h),
            InkWell(
              onTap: () {
                if (!bannerChallengeController.sendInviteEmailController.value.text.isEmpty &&
                    bannerChallengeController.emailRegExp
                        .hasMatch(bannerChallengeController.sendInviteEmailController.value.text)) {
                  FocusScope.of(context).unfocus();
                  bannerChallengeController.inviteThroughEmailApiCall(
                    challengeID: challengeId,
                    referredbyname: challengeName,
                    refferredtoemail:
                        bannerChallengeController.sendInviteEmailController.value.text,
                  );
                } else {
                  print("Not a valid Email or the invite count expired ");
                }
              },
              child: Container(
                height: 30,
                // width: 40.w,
                constraints: BoxConstraints(maxWidth: 25.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: bannerChallengeController.invited.value != 0
                        // ? AppColors.primaryAccentColor
                        // : (!ChallengeInviteAndFunctions.sendInviteEmailController.value
                        //             .toString()
                        //             .isEmpty &&
                        //         ChallengeInviteAndFunctions.emailRegExp.hasMatch(
                        //             ChallengeInviteAndFunctions.sendInviteEmailController.value.text))
                        ? AppColors.primaryAccentColor
                        : Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                child: Text("INVITE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      letterSpacing: 0.6,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
