import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Widgets/appBar.dart';
import '../home/landingPage.dart';
import '../../../app/utils/textStyle.dart';
import '../../../data/providers/network/apis/healthTipsApi/healthTipsData.dart';
import 'tipsDetailedScreen.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../../../data/model/healthTipModel/healthTipModel.dart';
import '../../Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../Widgets/healthTipWidgets/healthTipShimmer.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';

class HealthTips extends StatelessWidget {
  HealthTips({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();
    final TabBarController tabController = Get.put(TabBarController());
    bool aff = false;
    String affiUni = UpdatingColorsBasedOnAffiliations.ssoAffiliation == null
        ? "global_services"
        : UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"];
    return WillPopScope(
      onWillPop: () async {
        await Get.to(LandingPage());
        return false;
      },
      child: Container(
        alignment: Alignment.center,
        height: 100.h,
        child: !Tabss.featureSettings.healthTips
            ? const Text("No Health Tips Available")
            : SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // const OfferedPrograms(
                    //   screenTitle: 'Social',
                    //   screen: ProgramLists.commonList,
                    // ),
                    FutureBuilder<List<HealthTipsModel>>(
                        future: HealthTipsData().healthTipsData(affiUnqiueName: affiUni),
                        builder: (BuildContext ctx, AsyncSnapshot<List<HealthTipsModel>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  '${snapshot.error} occurred',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              );
                            } else if (snapshot.hasData) {
                              if (snapshot.data.isEmpty) {
                                return Container(
                                  alignment: Alignment.center,
                                  height: 70.h,
                                  child: const Text("No Health Tips Found !"),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'My Health Tips',
                                      style: AppTextStyles.healthTipsBigFont,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 6, left: 8, right: 8, bottom: 14),
                                    child: Text(
                                      'Discover updates on nutrition, physical activity, and mental well-being.',
                                      style: AppTextStyles.healthTipsNotes,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GridView(
                                      controller: controller,
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 7.5,
                                          mainAxisSpacing: 7.5,
                                          mainAxisExtent: 32.8.h),
                                      shrinkWrap: true,
                                      children: snapshot.data.map<Widget>((HealthTipsModel e) {
                                        return tipsCard(
                                            e.healthTipBlobThumbNailUrl.toString(),
                                            e.healthTipTitle.toString(),
                                            e.message.toString(),
                                            e); // Preview Tips Widgets
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              );
                            }
                          }
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: const <Widget>[
                                    HealthTipShimmer(),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    HealthTipShimmer(),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: const <Widget>[
                                    HealthTipShimmer(),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    HealthTipShimmer(),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                    SizedBox(
                      height: 10.h,
                    )
                  ],
                ),
              ),
      ),
    );
  }

  final bool _addFavorite = false;

  final TabBarController _favoriteController = Get.put(TabBarController());

  Future<Uint8List> getPngBlobData(String blobUrl) async {
    final http.Response response = await http.get(Uri.parse(blobUrl));

    if (response.statusCode == 200) {
      return Uint8List.fromList(response.bodyBytes);
    } else {
      throw Exception('Failed to load PNG blob data');
    }
  }

  Widget tipsCard(String thumbImage, String title, String message, var tipsData) {
    return GestureDetector(
      onTap: () {
        // Get.toNamed(Routes.tipsDetailedScreen,
        //     arguments: {'imagePath': thumbImage, 'title': title, 'message': message});  ///old Tips details screen navigation
        Get.to(TipsDetailedScreen(
          imagepath: tipsData.healthTipBlobUrl,
          message: message,
          fromNotification: false,
          title: title,
        ));

        ///New Tips details screen navigation
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.only(left: 1.w, right: 1.w, top: .8.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  height: 25.h,
                  width: 35.w,
                  decoration: BoxDecoration(

                      ///Preview or thumbnail Image bound here.
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(image: NetworkImage(thumbImage), fit: BoxFit.cover)),
                ),
              ),
              SizedBox(
                height: 1.h,
              ),
              SizedBox(
                height: 5.h,
                width: 40.w,
                child: Text(
                  title,
                  maxLines: 2,
                  style: AppTextStyles.peopleCounts,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
