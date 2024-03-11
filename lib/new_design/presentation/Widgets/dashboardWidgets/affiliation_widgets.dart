import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:ihl/new_design/presentation/Widgets/dashboardWidgets/healthtip_widget.dart';
import 'package:ihl/new_design/presentation/controllers/dashboardControllers/upComingDetailsController.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import 'package:sizer/sizer.dart';

import '../../../data/model/loginModel/userDataModel.dart';
import '../../../data/providers/network/apis/dashboardApi/retriveUpcommingDetails.dart';
import '../../../data/providers/network/apis/healthTipsApi/healthTipsApi.dart';
import '../../controllers/healthTipsController/healthTipsController.dart';

class AffiliationWidgets {
  List<Widget> affiliationCard({List<AfNo> userAffiliateDatas}) {
    final upcomingDetailsController = Get.put(UpcomingDetailsController());
    //  userAffiliateDatas = [];
    // if (userAffiliate.afNo1.affilateUniqueName != null) {
    //   userAffiliateDatas.add(userAffiliate.afNo1);
    // }
    // if (userAffiliate.afNo2.affilateUniqueName != null) {
    //   userAffiliateDatas.add(userAffiliate.afNo2);
    // }
    // if (userAffiliate.afNo3.affilateUniqueName != null) {
    //   userAffiliateDatas.add(userAffiliate.afNo3);
    // }
    // if (userAffiliate.afNo4.affilateUniqueName != null) {
    //   userAffiliateDatas.add(userAffiliate.afNo4);
    // }
    // if (userAffiliate.afNo5.affilateUniqueName != null) {
    //   userAffiliateDatas.add(userAffiliate.afNo5);
    // }
    // if (userAffiliate.afNo6.affilateUniqueName != null) {
    //   userAffiliateDatas.add(userAffiliate.afNo6);
    // }
    // if (userAffiliate.afNo7.affilateUniqueName != null) {
    //   userAffiliateDatas.add(userAffiliate.afNo7);
    // }
    // if (userAffiliate.afNo8.affilateUniqueName != null) {
    //   userAffiliateDatas.add(userAffiliate.afNo8);
    // }
    // if (userAffiliate.afNo9.affilateUniqueName != null) {
    //   userAffiliateDatas.add(userAffiliate.afNo9);
    // }

    return userAffiliateDatas.map((e) {
      if (selectedAffiliationfromuniquenameDashboard == '' &&
          userAffiliateDatas.any((element) => element.affilateUniqueName == "ihl_care")) {
        selectedAffiliationfromuniquenameDashboard = e.affilateUniqueName;
        selectedAffiliationcompanyNamefromDashboard = "IHL Care";
      }
      return Padding(
        padding: EdgeInsets.fromLTRB(5.sp, 15.sp, 10.sp, 15.sp),
        child: InkWell(
          onTap: () async {
            log("Tapped Affilaiation ${e.affilateName}");
            selectedAffiliationfromuniquenameDashboard = e.affilateUniqueName;
            selectedAffiliationcompanyNamefromDashboard = e.affilateName;
            gAfNo = e;
            selectedAffiliationIndex = userAffiliateDatas.indexOf(e);
            // UpcomingDetailsController().updatingColors(e.affilateUniqueName);
            UpdatingColorsBasedOnAffiliations.updateColor(
                colorCode: int.parse("0XFF" + e.affiliate_theme_color));
            UpdatingColorsBasedOnAffiliations.selectedAffiliation.value =
                selectedAffiliationfromuniquenameDashboard;
            UpdatingColorsBasedOnAffiliations.selectedAffiliation.notifyListeners();

            affiColor = Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value);
            log("Selected Affilaiation $selectedAffiliationfromuniquenameDashboard");

            HealthTipsApi.ihlUniqueName = selectedAffiliationfromuniquenameDashboard;
            Get.put(HealthTipsController());
            var healthtipcontroller = Get.put(HealthTipsController());
            ChangeHealthTips.healthtipslist.value.clear();
            start = 0;
            end = 2;
            ChangeHealthTips.getTips();
            Get.find<UpcomingDetailsController>().onInit();
            CheckUpcomingDataIsLoaded.showShimmer.value = true;
            upcomingDetailsController.updateUpcomingDetails(fromChallenge: false);
            await RetriveDetials().upcomingDetails(
                affilist: [selectedAffiliationfromuniquenameDashboard], fromChallenge: false);
            UpdatingColorsBasedOnAffiliations.selectedAffiliation.value =
                selectedAffiliationfromuniquenameDashboard;
            UpdatingColorsBasedOnAffiliations.selectedAffiliation.notifyListeners();
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => Details(
            //             companyName: widget.afUnique1,
            //             logo: logoAf1,
            //             affiliationName: widget.afNo1)));
            // Get.to(Details(
            //   logo: e.imgUrl,
            //   affiliationName: e.affilateName,
            //   companyName: e.affilateUniqueName,
            // ));
            //use this navigation for new Manage Health.
            // Get.to(Details(
            //   logo: e.imgUrl,
            //   affiliationName: e.affilateName,
            //   companyName: e.affilateUniqueName,
            // ));
          },
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: 7.5.h,
                width: 15.w,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
                  BoxShadow(
                      blurRadius: 2,
                      color: Colors.grey.withOpacity(0.09),
                      offset: Offset(1, 1),
                      spreadRadius: 4)
                ]),
                child: Container(
                  height: 4.h,
                  width: 20.w,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                          fit: BoxFit.contain, image: NetworkImage(e.imgUrl.toString()))),
                ),
              ),
              SizedBox(height: 0.4.h),
              SizedBox(
                width: 16.w,
                child: Text(
                  e.affilateName.toString() == "India Health Link Pvt Ltd"
                      ? "IHL"
                      : e.affilateName.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: selectedAffiliationfromuniquenameDashboard == e.affilateUniqueName
                          ? AppColors.primaryColor
                          : Colors.black,
                      fontSize: 8.sp),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 16.w,
                height: 2,
                color: selectedAffiliationfromuniquenameDashboard == e.affilateUniqueName
                    ? AppColors.primaryColor
                    : Colors.transparent,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  static affiBoardChanges({AfNo affi, List<AfNo> userAffiliateDatas}) async {
    final upcomingDetailsController = Get.put(UpcomingDetailsController());
    log("Tapped Affilaiation ${affi.affilateName}");
    selectedAffiliationfromuniquenameDashboard = affi.affilateUniqueName;
    selectedAffiliationcompanyNamefromDashboard = affi.affilateName;
    gAfNo = affi;
    selectedAffiliationIndex = userAffiliateDatas.indexOf(affi);

    UpdatingColorsBasedOnAffiliations.updateColor(
        colorCode: int.parse("0XFF${affi.affiliate_theme_color}"));
    UpdatingColorsBasedOnAffiliations.selectedAffiliation.value =
        selectedAffiliationfromuniquenameDashboard;
    UpdatingColorsBasedOnAffiliations.selectedAffiliation.notifyListeners();

    affiColor = Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value);
    log("Selected Affilaiation $selectedAffiliationfromuniquenameDashboard");

    HealthTipsApi.ihlUniqueName = selectedAffiliationfromuniquenameDashboard;
    Get.put(HealthTipsController());
    // var healthtipcontroller = Get.put(HealthTipsController());
    ChangeHealthTips.healthtipslist.value.clear();
    start = 0;
    end = 2;
    ChangeHealthTips.getTips();
    Get.find<UpcomingDetailsController>().onInit();
    CheckUpcomingDataIsLoaded.showShimmer.value = true;
    upcomingDetailsController.updateUpcomingDetails(fromChallenge: false);
    await RetriveDetials().upcomingDetails(
        affilist: <String>[selectedAffiliationfromuniquenameDashboard], fromChallenge: false);
    UpdatingColorsBasedOnAffiliations.selectedAffiliation.value =
        selectedAffiliationfromuniquenameDashboard;
    UpdatingColorsBasedOnAffiliations.selectedAffiliation.notifyListeners();
  }
}

class UpdatingColorsBasedOnAffiliations {
  static bool sso = false;
  static Map<String, dynamic> ssoAffiliation = <String, dynamic>{};
  static Map<String, dynamic> companyName = <String, dynamic>{};
  static ValueNotifier<Map<String, dynamic>> affiMap =
      ValueNotifier<Map<String, dynamic>>(<String, dynamic>{});
  static ValueNotifier<int> affiColorCode = ValueNotifier<int>(000000);
  static ValueNotifier<String> selectedAffiliation = ValueNotifier<String>("");
  static updateColor({int colorCode}) {
    ChangeHealthTips.getTips();
    affiColorCode.value = colorCode;
  }
}
