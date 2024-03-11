import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:ihl/new_design/presentation/pages/manageHealthscreens/healthJournalScreens/editfoodlog.dart';
import 'package:ihl/views/dietJournal/models/get_food_log_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../app/utils/textStyle.dart';
import 'editCusFoodLog.dart';

class LogHistoryScreen extends StatelessWidget {
  final baseColor;

  final List<GetFoodLog> viewHistory;
  final mealData;
  LogHistoryScreen(
      {Key key,  @required this.mealData, @required this.baseColor, @required this.viewHistory}) : super(key: key);

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
          title: const Text("Logged Food"),
          centerTitle: true,
          backgroundColor: baseColor,
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
                          onTap: () {
                            if (viewHistory[index].food[0].foodDetails[0].foodId.length < 20) {
                              Get.to(EditFoodLog(
                                foodId: viewHistory[index].food[0].foodDetails[0].foodId,
                                mealType: viewHistory[index].foodTimeCategory,
                                mealData: mealData,
                                logedData: viewHistory[index],
                                bgcolor: baseColor, foodLogId: viewHistory[index].foodLogId,
                              ));
                            } else {
                              Get.to(CustomEditFoodLog(
                                foodId: viewHistory[index].food[0].foodDetails[0].foodId,
                                mealType: viewHistory[index].foodTimeCategory,
                                mealData: mealData,
                                logedData: viewHistory[index],
                                bgcolor: baseColor, foodLogId: viewHistory[index].foodLogId,
                              ));
                            }
                          },
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
                                      SizedBox(width:28.h,
                                        child: Text(
                                          viewHistory[index].food[0].foodDetails[0].foodName ?? " ",
                                          maxLines: 2,
                                          style: AppTextStyles.contentFont3,
                                        ),
                                      ),
                                      Text(
                                          "${viewHistory[index].food[0].foodDetails[0].foodQuantity}  ${viewHistory[index]
                                                  .food[0]
                                                  .foodDetails[0]
                                                  .quantityUnit}",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14.sp,
                                          color: Colors.grey,
                                        ),),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text("${viewHistory[index].totalCaloriesGained} Cal",
                                          style:  TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize:15.sp,
                                            color: Colors.grey,
                                          ),),
                                      Gap(20.sp),
                                      Icon(
                                        Icons.add,
                                        color: baseColor,
                                        size: 21.sp,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              // subtitle: Text(splitedTxt[0]),
                            ),
                          ),
                        );
                      })),
            ],
          ),
        ));
  }
}
