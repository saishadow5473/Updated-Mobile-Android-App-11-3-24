import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../app/utils/textStyle.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import 'foodDetailScreen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'customeFoodDetailScreen.dart';

class MyFavouriteScreen extends StatelessWidget {
  final myFavour;
  final baseColor;
  final mealType;
  final logDate;
  final mealData;
  final range;
  MyFavouriteScreen(
      {Key key,
      @required this.range,
      @required this.myFavour,
      @required this.baseColor,
      @required this.mealType,
      @required this.logDate,
      @required this.mealData})
      : super(key: key);

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
          title: const Text("My Favourites"),
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
                      itemCount: myFavour.length,
                      itemBuilder: (BuildContext cntx, int index) {
                        var splitedTxt = myFavour[index].subtitle.split("|");

                        return InkWell(
                          onTap: () {
                            if (range) {
                              if (myFavour[index].foodItemID.length < 20) {
                                Get.to(FoodDetailScreen(
                                    title: myFavour[index].title ?? '',
                                    baseColor: baseColor,
                                    foodId: myFavour[index].foodItemID,
                                    mealType: mealType,
                                    logDate: logDate,
                                    mealData: mealData));
                              } else {
                                Get.to(CustomeFoodDetailScreen(
                                  foodName: myFavour[index].title ?? '',
                                  foodId: myFavour[index].foodItemID,
                                  mealType: mealType,
                                  mealData: mealData,
                                  baseColor: baseColor,
                                  logDate: logDate,
                                ));
                              }
                            } else {}
                          },
                          child: Card(
                            elevation: 2,
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
                                      SizedBox(width:27.2.h,
                                        child: Text(
                                          myFavour[index].title ?? " ",
                                          style: AppTextStyles.contentFont3,
                                          maxLines: 2,
                                        ),
                                      ),
                                      Text(splitedTxt[0],style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14.sp,
                                        color: Colors.grey,
                                      ),),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(splitedTxt[1],style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize:15.sp,
                                        color: Colors.grey,
                                      ),),
                                      Gap(20.sp),
                                      Icon(
                                        Icons.add,
                                        color: range ? baseColor : Colors.grey,
                                        size: 21.sp,
                                      )
                                      // Obx(() => _iconShow.value
                                      //     ? Row(
                                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      //   children: [
                                      //     Icon(Icons.edit),
                                      //     Gap(10.sp),
                                      //     Icon(
                                      //       Icons.close,
                                      //       color: Colors.red,
                                      //     )
                                      //   ],
                                      // )
                                      //     : IconButton(onPressed: () {}, icon: Icon(Icons.add)))
                                    ],
                                  ),
                                ],
                              ),
                              // subtitle: Text(splitedTxt[0]),
                            ),
                          ),
                        );
                      })),
              SizedBox(
                height: 9.2.h,
              )
            ],
          ),
        ));
  }
}
