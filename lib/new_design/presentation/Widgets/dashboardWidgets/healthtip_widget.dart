import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/appColors.dart';
import '../../../app/utils/textStyle.dart';
import 'teleconsultation_widget.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../controllers/healthTipsController/healthTipsController.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../constants/api.dart';
import '../../../../utils/SpUtil.dart';
import '../../../../views/tips/tips_screen.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../../data/model/healthTipModel/healthTipModel.dart';
import '../../../data/providers/network/networks.dart';
import '../../pages/basicData/functionalities/percentage_calculations.dart';
import '../../pages/basicData/screens/ProfileCompletion.dart';
import '../../pages/healthTips/tipsDetailedScreen.dart';
import '../../pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';

ScrollController healthTipsScrollController = new ScrollController();
int start = 0, end = 2;

class HealthTipCard extends StatefulWidget {
  HealthTipCard({Key key, this.color, this.affiList}) : super(key: key);
  Color color;
  var affiList;

  @override
  State<HealthTipCard> createState() => _HealthTipCardState();
}

class _HealthTipCardState extends State<HealthTipCard> {
  ScrollController healthTipsScrollController = ScrollController();

  //final _healthtip = Get.put(HealthTipsController());
  // var healthTips = [];

  @override
  void initState() {
    // ChangeHealthTips.healthtipslist.value.clear();
    // ChangeHealthTips.getTips();
    healthTipsScrollController.addListener(() {
      if (healthTipsScrollController.position.maxScrollExtent ==
          healthTipsScrollController.position.pixels) {
        start = end + 1;
        end = end + 2;

        // if (ChangeHealthTips.healthtipslist.value.length > end) {
        //   start = 0;
        //   end = 2;
        // }
        ChangeHealthTips.getTips();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(HealthTipsController());
    final _favoriteController = Get.put(TabBarController());
    bool _addFavorite = false;
    return
        //  GetBuilder<HealthTipsController>(
        //     init: HealthTipsController(),
        //     builder: (_healthTips) {
        //       return _healthTips.healthTips.length != 0
        //           ?
        ChangeHealthTips.healthtipslist.value != null
            ? ValueListenableBuilder<List<HealthTipsModel>>(
                valueListenable: ChangeHealthTips.healthtipslist,
                builder: (_, val, __) {
                  return Visibility(
                    visible: ChangeHealthTips.healthtipslist.value.isNotEmpty,
                    child: GestureDetector(
                      onTap: () {},
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 1.w),
                                  child: Text("Exclusive Tips For You",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16.sp,
                                        color: widget.color ?? AppColors.primaryColor,
                                        fontWeight: FontWeight.w800,
                                      )),
                                ),
                                const Spacer(),
                                TeleConsultationWidgets().viewAll(
                                    onTap: () {
                                      PercentageCalculations().calculatePercentageFilled() != 100
                                          ? Get.to(ProfileCompletionScreen())
                                          : Get.to(TipsScreen(affi: widget.affiList));
                                    },
                                    color: widget.color)
                              ],
                            ),
                            SizedBox(
                              height: 1.5.h,
                            ),
                            Container(
                              height: 100.h > 700 ? 48.5.h : 55.h,
                              padding: const EdgeInsets.only(),
                              decoration: BoxDecoration(
                                  color: AppColors.backgroundScreenColor,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: AppColors.backgroundScreenColor,
                                    borderRadius: BorderRadius.circular(5)),
                                child: ListView(
                                    controller: healthTipsScrollController,
                                    scrollDirection: Axis.horizontal,
                                    children: val.map((e) {
                                      return GestureDetector(
                                        onTap: () {
                                          print('check health tip name${e.healthTipTitle}');
                                          PercentageCalculations().calculatePercentageFilled() !=
                                                  100
                                              ? Get.to(ProfileCompletionScreen())
                                              : Get.to(TipsDetailedScreen(
                                                  imagepath: e.healthTipBlobUrl,
                                                  message: e.message,
                                                  fromNotification: false,
                                                  title: e.healthTipTitle,
                                                ));
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(top: 1.h, right: 1.w),
                                              decoration: BoxDecoration(
                                                  color: AppColors.plainColor,
                                                  borderRadius: BorderRadius.circular(4)),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Center(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.only(left: 4.w, bottom: 1.h),
                                                      height: 36.h,
                                                      width: 70.w,
                                                      child: Image.network(
                                                        e.healthTipBlobUrl,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 3.w,
                                                    ),
                                                    child: Container(
                                                      child: Text(e.healthTipTitle,
                                                          style: TextStyle(
                                                            fontFamily: 'Poppins',
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          textAlign: TextAlign.left),
                                                    ),
                                                  ),
                                                  // SizedBox(
                                                  //   width: 20.w,
                                                  //   child:
                                                  //       Text(e.message, textAlign: TextAlign.start),
                                                  // ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 3.w,
                                                    ),
                                                    child: SizedBox(
                                                      // height: 8.2.h,
                                                      width: 70.w,
                                                      child: Text(
                                                        e.message
                                                            .replaceAll("&#39", "")
                                                            .replaceAll('&amp;', '&')
                                                            .replaceAll('&quot;', '"'),
                                                        maxLines: 3,
                                                        style: AppTextStyles.unSelectedText,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: AppColors.backgroundScreenColor,
                                                  borderRadius: BorderRadius.circular(5)),
                                              width: 2.w,
                                            )
                                          ],
                                        ),
                                      );
                                    }).toList()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // )
                      // : Container();
                      // }
                    ),
                  );
                })
            : Container();
  }
}

class ChangeHealthTips {
  static ValueNotifier<List<HealthTipsModel>> healthtipslist =
      ValueNotifier<List<HealthTipsModel>>([]);

  static getTips() async {
    var apiToken = SpUtil.getString(LSKeys.apiToken);

    //var ihlUserToken = localSotrage.read(LSKeys.iHLUserToken);
    var ihlUserToken = SpUtil.getString(LSKeys.iHLUserToken);
    var endpoint = 'retrieve_affiliated_healthtip';
    var url = '${API.iHLUrl}' + '/pushnotification/' + endpoint;
    try {
      final response = await dio.post(
        url,
        data: json.encode({
          // "affiliation_list": "dm_c", // TODO Testing purpose hardcoded
          "affiliation_list": selectedAffiliationfromuniquenameDashboard == ""
              ? "global_services"
              : selectedAffiliationfromuniquenameDashboard,
          "start_index": start,
          "end_index": end,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': apiToken,
            'Token': ihlUserToken
          },
        ),
      );

      List<HealthTipsModel> healthTipsList = [];
      if (response.statusCode == 200) {
        for (var element in response.data) {
          healthTipsList.add(HealthTipsModel.fromJson(element));
        }

        healthtipslist.value.addAll(healthTipsList);

        // if (healthtipslist.value.isEmpty) {
        //   var a = Get.find<ListChallengeController>().affiliateCmpnyList;
        //   String finalstring = a.toString();
        //   finalstring = finalstring.replaceAll('[', '');
        //   finalstring = finalstring.replaceAll(']', '');
        //   finalstring = finalstring.replaceAll(' ', '');
        //   // for (var element in a) {
        //   //   a.forEach((element) {
        //   //     if (a.indexOf(element) == 0) {
        //   //       finalstring = element;
        //   //     } else {
        //   //       finalstring = finalstring + ',' + element;
        //   //     }
        //   //   });
        //   // }

        //   HealthTipsApi.ihlUniqueName = finalstring;
        //   start = 0;
        //   start = 2;
        //   getTips();
        // }
        healthtipslist.value.toSet();
        healthtipslist.notifyListeners();
        // healthtipslist = healthtipslist;
      }
    } catch (e) {
      print(e);
    }
    // return response.data;
  }
}
