import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../../views/dietJournal/activity/activity_detail.dart';
import '../../../../../../views/dietJournal/models/user_bookmarked_activity_model.dart';
import '../../../../../app/utils/appColors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../../../views/dietJournal/models/get_activity_log_model.dart';
import '../../../../../../views/dietJournal/models/get_todays_food_log_model.dart';
import '../../../../../app/utils/textStyle.dart';
import '../../../dashboard/common_screen_for_navigation.dart';

class ViewAllActivity extends StatelessWidget {
  final List<dynamic> viewAllData;
  String screenType;
  DateTime selctedDate;

   ViewAllActivity({Key key, @required this.viewAllData, @required this.selctedDate,@required this.screenType}) : super(key: key);
  getActivityName(String activityName)  {
    if(activityName.contains('(')) {
      int index = activityName.indexOf('(');
      String tempName = activityName.substring(0, index);
      return tempName;
    }
    else{
      return activityName;
    }
  }
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
          title:  Text(screenType),
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
                      itemCount: viewAllData.length,
                      itemBuilder: (BuildContext cntx, int index) {
                        return InkWell(
                          onTap: (){
                            Get.to(ActivityDetailScreen(activityObj: viewAllData[index], selectedDate: selctedDate, todayLogList: viewAllData,));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
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
                                              getActivityName(viewAllData[index].activityName)
                                             ?? " ",
                                            maxLines: 2,
                                            style: AppTextStyles.contentFont3,
                                          ),
                                        ),
                                        Text(
                                          viewAllData[index].activityType == "L"
                                              ? "Light Impact"
                                              : viewAllData[index].activityType == "M"
                                                  ? "Medium Impact"
                                                  : "High Impact",
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
                                          "${viewAllData[index].activityMetValue} Cal",
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
