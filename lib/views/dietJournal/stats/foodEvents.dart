import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/apis/log_apis.dart';
import 'package:ihl/views/dietJournal/dietJournal.dart';
import 'package:ihl/views/dietJournal/models/get_food_log_model.dart';
import 'package:ihl/views/dietJournal/models/log_user_food_intake_model.dart';
import 'package:ihl/views/dietJournal/stats/caloriesHiestory.dart';
import 'package:ihl/views/dietJournal/stats/food_events_details.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class FoodLogDetails extends StatefulWidget {
  var onDaySelectedfun;
  var foodDetailsLen;
  List<MealsListData> mealsData;

  FoodLogDetails(this.mealsData, this.onDaySelectedfun, this.foodDetailsLen,
      {Key key})
      : super(key: key);

  @override
  State<FoodLogDetails> createState() => _FoodLogDetailsState();
}

class _FoodLogDetailsState extends State<FoodLogDetails> {
  GetFoodLog foodLog = GetFoodLog();
  bool deleted = false;
  bool submitted = false;
  int nullList = 0;

  Widget emptyList() {
    //nullCountInc();
    return Container(
      height: 1,
    );
  }

  // void nullCountInc() {
  //   nullList += 1;
  //   print("$nullList+");
  // }

  Widget noData() {
    return Container(
      height: ScUtil().setHeight(350),
      width: double.infinity,
      margin: const EdgeInsets.all(10.0),
      child: Card(
          elevation: 2,
          shadowColor: FitnessAppTheme.nearlyWhite,
          borderOnForeground: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(4),
              ),
              side: BorderSide(
                width: 1,
                color: FitnessAppTheme.nearlyWhite,
              )),
          color: FitnessAppTheme.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                'https://i.postimg.cc/Bb0jC1Js/diet-1.png',
                height: 5.h,
                width: 20.w,
              ),
              SizedBox(height: ScUtil().setHeight(10)),
              Text(
                'No Food Logged on the day!',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 18.sp,
                  letterSpacing: 0.5,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: ScUtil().setHeight(20)),
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (BuildContext context) => DietJournal()),
                      (Route<dynamic> route) => false);
                },
                label: Text(
                  "Log Food",
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 18.sp,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          )),
    );
  }

  foodName(indexNum) {
    return widget.onDaySelectedfun[indexNum].food[0].foodDetails[0].foodName;
  }

  Color listTileColor(String catagory) {
    switch (catagory) {
      case 'Breakfast':
        return const Color(0xFFee6143);
      case 'Lunch':
        return const Color(0xFF23b6e6);
      case 'Snacks':
        return const Color(0xFFFE95B6);
      case 'Dinner':
        return const Color(0xFF6F72CA);
    }
    return AppColors.primaryAccentColor;
  }

  foodCatagories(indexNum) {
    var catagory = widget.onDaySelectedfun[indexNum].foodTimeCategory;

    return catagory;
  }

  foodLogDate(indexNum) {
    String time =
        widget.onDaySelectedfun[indexNum].foodLogTime.substring(11, 16);
    String date =
        widget.onDaySelectedfun[indexNum].foodLogTime.substring(0, 10);
    TimeOfDay timeOnly = TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]));
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    String formattedTime = localizations.formatTimeOfDay(timeOnly);
    return "$date $formattedTime";
  }

  @override
  Widget build(BuildContext context) {
    return widget.onDaySelectedfun.length != 0 && widget.foodDetailsLen != 0
        ? ListView.builder(
            itemCount: widget.onDaySelectedfun.length,
            itemBuilder: (BuildContext context, int index) {
              return widget.onDaySelectedfun[index].food.length != 0
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: listTileColor(foodCatagories(index)),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                foodName(index),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    //fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5),
                              ),
                              leading: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(foodCatagories(index),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5)),
                              ),
                              subtitle: Text(foodLogDate(index),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      //fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5)),
                              // trailing: Container(
                              //   child: IconButton(
                              //     onPressed: () {
                              //       deleteMeal();
                              //     },
                              //     icon: Icon(
                              //       Icons.delete,
                              //     ),
                              //     color: Colors.white,
                              //   ),
                              // ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => FoodEventsDetails(
                                            foodName: widget
                                                .onDaySelectedfun[index]
                                                .food[0]
                                                .foodDetails[0]
                                                .foodName,
                                            foodId: widget
                                                .onDaySelectedfun[index]
                                                .food[0]
                                                .foodDetails[0]
                                                .foodId,
                                            itemCount: double.parse(widget
                                                .onDaySelectedfun[index]
                                                .food[0]
                                                .foodDetails[0]
                                                .foodQuantity),
                                            foodCatogry: widget
                                                .onDaySelectedfun[index]
                                                .foodTimeCategory,
                                            screenColor: listTileColor(
                                                foodCatagories(index)),
                                            foodLogTime: widget
                                                .onDaySelectedfun[index]
                                                .foodLogTime,
                                            foodEpchoid: widget
                                                .onDaySelectedfun[index]
                                                .epochLogTime,
                                            mealsData: widget.mealsData,
                                          )),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : emptyList();
            })
        : noData();
  }

  void deleteMeal() async {
    if (mounted) {
      setState(() {
        deleted = true;
      });
    }
    EditLogUserFood logFood = await deleteLog();

    LogApis.editUserFoodLogApi(data: logFood).then((LogUserFoodIntakeResponse value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            deleted = false;
          });
        }
        ListApis.getUserFoodLogHistoryApi().then((value) {
          Get.to(TableEventsExample(widget.mealsData));
        });
        // Get.snackbar(
        //     'Log Deleted', '${camelize(foodDetail.item)} deleted successfully.',
        //     icon: Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: Icon(Icons.check_circle, color: Colors.white)),
        //     margin: EdgeInsets.all(20).copyWith(bottom: 40),
        //     backgroundColor: AppColors.primaryAccentColor,
        //     colorText: Colors.white,
        //     duration: Duration(seconds: 5),
        //     snackPosition: SnackPosition.BOTTOM);
      } else {
        if (mounted) {
          setState(() {
            submitted = false;
          });
        }
        //Get.close(1);
        Get.snackbar('Log not Deleted',
            'Encountered some error while deleted. Please try later',
            icon: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.cancel_rounded, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  Future<EditLogUserFood> deleteLog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    return EditLogUserFood(
        userIhlId: iHLUserId,
        foodLogTime: "29-08-2022 00:10:00",
        epochLogTime: 1661712000000,
        foodTimeCategory: "Breakfast",
        caloriesGained: '420',
        food: [widget.onDaySelectedfun[0].food]);
  }
}
