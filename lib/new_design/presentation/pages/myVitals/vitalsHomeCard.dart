import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/routes.dart';
import '../../../app/utils/appColors.dart';
import '../manageHealthscreens/manageHealthScreentabs.dart';
import '../../../../utils/screenutil.dart';
import '../../../../utils/SpUtil.dart';
import '../../../../views/otherVitalController/otherVitalController.dart';
import 'package:sizer/sizer.dart';

import '../../../app/utils/appText.dart';
import '../../../app/utils/imageAssets.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../../app/utils/textStyle.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';

class VitalsCard {
  Widget vitalsCardWithScore(BuildContext context) {
    //var userName = localSotrage.read(LSKeys.userName);
    String userName = SpUtil.getString(LSKeys.userName);
    //var vitals = localSotrage.read(LSKeys.lastCheckin);
    // var vitals = jsonDecode(SpUtil.getString(LSKeys.lastCheckin));
    int ihlScore = SpUtil.getInt(LSKeys.ihlScore);
    final TabBarController tabController = Get.find();

    String scoreStatus = "Good";
    AssetImage imagefile;
    Color cardColor;
    if (ihlScore < 200) {
      scoreStatus = "Bad";
    } else if (ihlScore >= 200 && ihlScore < 400) {
      scoreStatus = "Moderate";
    } else if (ihlScore >= 400 && ihlScore < 600) {
      scoreStatus = "Good";
    } else {
      scoreStatus = "Perfect";
    }
    switch (scoreStatus) {
      case "Good":
        imagefile = ImageAssets.goodScore;
        cardColor = const Color(0xfff7e0c4);
        break;
      case "Moderate":
        imagefile = ImageAssets.moderateScore;
        cardColor = const Color(0xffffc8d7);
        break;
      case "Bad":
        imagefile = ImageAssets.badScore;
        cardColor = const Color(0xffFFB7c7);
        break;
      case "Perfect":
        imagefile = ImageAssets.perfectScore;
        cardColor = const Color.fromRGBO(184, 247, 157, .5);
    }
    Get.put(VitalsContoller());
    // var ihlScore = 00;
    // var status;
    // switch(ihlScore){
    //   case ihlScore
    // }
    return GestureDetector(
      onTap: () {
        Get.find<VitalsContoller>().vitalData();
        // vitalsOnHome = [
        //   'bmi',
        //   'weightKG',
        //   // 'heightMeters',
        //   'temperature',
        //   'pulseBpm',
        //   'fatRatio',
        //   'ECGBpm',
        //   'bp',
        //   'spo2',
        //   'protien',
        //   'extra_cellular_water',
        //   'intra_cellular_water',
        //   'mineral',
        //   'skeletal_muscle_mass',
        //   'body_fat_mass',
        //   'body_cell_mass',
        //   'waist_hip_ratio',
        //   'percent_body_fat',
        //   'waist_height_ratio',
        //   'visceral_fat',
        //   'basal_metabolic_rate',
        //   'bone_mineral_content',
        // ];
        // Get.to(VitalTab(
        //   isShowAsMainScreen: false,
        // ));
        // Get.to(SafeArea(child: MyvitalsDetails()));
        tabController.updateSelectedIconValue(value: AppTexts.manageHealth);
        Get.to( ManageHealthScreenTabs());
      },
      child: Container(
        // color: ihlScore == null || ihlScore < 200
        //     ? AppColors.lowCardColor
        //     : ihlScore > 200 && ihlScore < 400
        //         ? AppColors.goodCardColor
        //         : ihlScore > 400 && ihlScore < 600
        //             ? AppColors.vgCardColor
        //             : AppColors.homeCardColor,
        color: cardColor,
        height: 13.h,
        width: 97.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
                height: 7.h,
                child: Image(
                  image: imagefile,
                )
                // child: Image(
                //     image: ihlScore == null || ihlScore < 200
                //         ? ImageAssets.lowScore
                //         : ihlScore > 200 && ihlScore < 400
                //             ? ImageAssets.goodScore
                //             : ihlScore > 400
                //                 ? ImageAssets.vGoodScore
                //                 : ImageAssets.excellentScore)
                ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 1.w, bottom: .5.h),
                  child: Text("${AppTexts.welcomeUser}$userName" ?? "",
                      // style: ihlScore == null || ihlScore < 200
                      //     ? AppTextStyles.lowcontentHeading
                      //     : ihlScore > 200 && ihlScore < 400
                      //         ? AppTextStyles.vgcontentHeading
                      //         : ihlScore > 400 && ihlScore < 600
                      //             ? AppTextStyles.vgcontentHeading
                      //             : AppTextStyles.contentHeading
                      style: AppTextStyles.vgcontentHeading),
                ),
                Padding(
                  padding: EdgeInsets.only(top: .5.h, left: 2.w),
                  child: Text(
                    "${AppTexts.scoreText}$ihlScore",
                    // style: ihlScore == null || ihlScore < 200
                    //     ? AppTextStyles.lowcontentHeading
                    //     : ihlScore > 200 && ihlScore < 400
                    //         ? AppTextStyles.contentFont
                    //         : ihlScore > 400 && ihlScore < 600
                    //             ? AppTextStyles.contentFont
                    //             : AppTextStyles.contentFont,
                    style: AppTextStyles.contentFont,
                  ),
                )
              ],
            ),
            Icon(
              Icons.info,
              // color: ihlScore == null || ihlScore < 200
              //     ? AppColors.lowTextColor
              //     : ihlScore > 200 && ihlScore < 400
              //         ? AppColors.textColor
              //         : ihlScore > 400 && ihlScore < 600
              //             ? AppColors.contentTitleColor
              //             : AppColors.plainColor
              color: const Color(0xff585859),
              size: 6.w,
            )
          ],
        ),
      ),
    );
  }

  Widget vitalsCardWithoutScore(BuildContext context, {Color color}) {
    print(MediaQuery.of(context).size.height);
    final TabBarController tabController = Get.find();
    return GestureDetector(
      onTap: () {
        _survey(context);
        // if (Platform.isAndroid) {
        //   Get.put(HpodControllers());
        //   _tabController.updateProgramsTab(val: 4);
        //   _tabController.updateSelectedIconValue(value: AppTexts.Social);
        //   Get.to(HpodLocations());
        // }
      },
      child: Container(
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(-1, 1.0), //(x,y)
              blurRadius: 2.0,
            ),
          ], color: AppColors.plainColor, borderRadius: BorderRadius.circular(5)),
          height: MediaQuery.of(context).size.height < 800 ? 17.2.h : 15.6.h,
          width: 99.w,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 1.5.w),
                child: Image(height: 7.h, image: ImageAssets.scoreGauge),
              ),
              Column(
                  // mainAxisAlignment: MainAxisAlignment,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 1.h),
                      child: Text(
                        'Welcome to hCare !',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.3.sp,
                          color: color ?? AppColors.primaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(
                      height: .7.h,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check Your Health Score !',
                          style: AppTextStyles.contentFont,
                        ),
                        Padding(
                          padding:  EdgeInsets.only(bottom: 4.sp),
                          child: SizedBox(
                            width: 65.w,
                            child: Text(
                              'Ready to know where you stand? Locate an hPod near you and take our health test.',
                              style: AppTextStyles.hintText,
                              textAlign: TextAlign.start,
                              maxLines: 3,
                            ),
                          ),
                        )
                      ],
                    ),
                  ])
            ],
          )),
    );
  }
}

Future<bool> _survey(BuildContext context) {
  return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Column(
                children: [
                  const Text(
                    'Finish Health Assessment\nto get IHL Score',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: const Text(
                        'Proceed Now',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(Routes.Survey, arguments: false);
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Try later',
                      style: TextStyle(
                          fontSize: ScUtil().setSp(14),
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }) ??
      false;
}
