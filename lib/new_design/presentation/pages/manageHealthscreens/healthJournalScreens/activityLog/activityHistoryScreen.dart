import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../app/utils/appColors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../../../views/dietJournal/models/get_activity_log_model.dart';
import '../../../../../../views/dietJournal/models/get_todays_food_log_model.dart';
import '../../../../../app/utils/textStyle.dart';
import '../../../dashboard/common_screen_for_navigation.dart';

class ActivityLogHistoryScreen extends StatelessWidget {
  final List<GetActivityLog> viewHistory;

  const ActivityLogHistoryScreen({Key key, @required this.viewHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
        contentColor: "True",
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              Get.back();
            }, //replaces the screen to Main dashboard
            color: Colors.white,
          ),
          title: const Text("Logged Activities"),
          centerTitle: true,
          backgroundColor: HexColor('#6F72CA'),
        ),
        content: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0, top: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: ListView.builder(
                      itemCount: viewHistory.length,
                      itemBuilder: (BuildContext cntx, int index) {
                        return InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(top:8.0),
                            child: Card(
                              elevation: 3,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 15.sp),
                                // padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 10.sp),
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 28.h,
                                          child: Text(
                                            viewHistory[index]
                                                    .activityDetails[0]
                                                    .activityDetails[0]
                                                    .activityName ??
                                                " ",
                                            maxLines: 2,
                                            style: AppTextStyles.contentFont3,
                                          ),
                                        ),
                                        Text(
                                         "${viewHistory[index]
                                             .activityDetails[0]
                                             .activityDetails[0]
                                             .activityDuration} Minutes" ,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "${viewHistory[index].totalCaloriesBurned} Cal",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 15.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Gap(20.sp),
                                        Icon(
                                          Icons.add,
                                          color: HexColor('#6F72CA'),
                                          size: 21.sp,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                // subtitle: Text(splitedTxt[0]),
                              ),
                            ),
                          ),
                        );
                      })),
            ],
          ),
        ));
  }
}
