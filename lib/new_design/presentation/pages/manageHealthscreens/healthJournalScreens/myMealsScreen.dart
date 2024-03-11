import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:ihl/new_design/app/utils/textStyle.dart';
import 'package:ihl/new_design/presentation/controllers/healthJournalControllers/foodDetailController.dart';
import 'package:ihl/new_design/presentation/pages/manageHealthscreens/healthJournalScreens/customeFoodDetailScreen.dart';
import 'package:ihl/new_design/presentation/pages/manageHealthscreens/healthJournalScreens/editCustomeFood.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/views/dietJournal/apis/log_apis.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:strings/strings.dart';

import '../../../../../views/dietJournal/models/food_list_tab_model.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import 'foodLog1.dart';

class MyMealScreen extends StatefulWidget {
  final myMeal;
  final baseColor;
  final mealData;
  final mealType;
  final logDate;
  MyMealScreen(
      {Key key,
      @required this.mealType,
      @required this.mealData,
      @required this.myMeal,
      @required this.logDate,
      @required this.baseColor})
      : super(key: key);

  @override
  State<MyMealScreen> createState() => _MyMealScreenState();
}

class _MyMealScreenState extends State<MyMealScreen> {
  var _iconShow = false.obs;

  void deleteRecents(foodId, foodName) async {
    await SpUtil.getInstance();
    List<FoodListTileModel> recentList = SpUtil.getRecentObjectList('recent_food') ?? [];
    bool exists = recentList.any((fav) => fav.foodItemID == foodId);
    if (exists) {
      recentList.removeWhere((element) => element.foodItemID == foodId);
    }
    SpUtil.putRecentObjectList('recent_food', recentList);
  }

  void deleteFood(dishName, dishId, foodDetailModel) async {
    final foodDetailController = Get.find<FoodDetailController>();
    foodDetailController.customFoodlist.remove(foodDetailModel);
    foodDetailController.update();
    foodDetailController.update(['Custome food widget']);
    Get.back();
    Get.snackbar('Deleted!', '${camelize(dishName ?? 'Name Unknown')} deleted successfully.',
        icon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.delete_forever, color: Colors.white)),
        margin: EdgeInsets.all(20).copyWith(bottom: 40),
        backgroundColor: AppColors.primaryAccentColor,
        colorText: Colors.white,
        duration: Duration(seconds: 6),
        snackPosition: SnackPosition.BOTTOM);
    await LogApis.deleteCustomUserFoodApi(foodItemID: dishId).then((data) async {
      if (data != null) {
        deleteRecents(dishId, dishName);
      } else {
        Get.back();
        Get.snackbar('Error!', 'Food not deleted',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.favorite, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      contentColor: "True",
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () async {
            Get.back();
          }, //replaces the screen to Main dashboard
          color: Colors.white,
        ),
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'My Meals',
                style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: '\n(Custom food)',
                style: TextStyle(
                    fontSize: 12.sp, color: Colors.grey[100], fontWeight: FontWeight.w300),
              )
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: widget.baseColor,
        actions: [
          IconButton(
              onPressed: () => _iconShow.value = !_iconShow.value,
              icon: Obx(() => Icon(
                    Icons.edit,
                    color: _iconShow.value ? Colors.grey[400] : Colors.white,
                  ))),
          Gap(10.sp)
        ],
      ),
      content: GetBuilder<FoodDetailController>(
        builder: (cusFood) {
          return Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0, top: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cusFood.customFoodlist.length == 0
                    ? Container(
                        height: 12.h,
                        child: Center(
                            child: Text(
                          "No Recipes Created",
                          style: AppTextStyles.ShadowFonts,
                        )),
                      )
                    : Expanded(
                        child: ListView.builder(
                            itemCount: cusFood.customFoodlist.length,
                            itemBuilder: (cntx, index) {
                              var splitedTxt = cusFood.customFoodlist[index].subtitle.split("|");
                              return InkWell(
                                onTap: () {
                                  if (gNavigate.value) {
                                    Get.to(CustomeFoodDetailScreen(
                                      foodName: cusFood.customFoodlist[index].title,
                                      foodId: cusFood.customFoodlist[index].foodItemID,
                                      mealType: widget.mealType,
                                      mealData: widget.mealData,
                                      baseColor: widget.baseColor,
                                      logDate: widget.logDate,
                                    ));
                                  }
                                },
                                child: Card(
                                  elevation: 2,

                                  // decoration: BoxDecoration(
                                  //     color: Colors.white, borderRadius: BorderRadius.circular(5)),
                                  child: Container(
                                    margin: EdgeInsets.only(top: 15.sp, bottom: 15.sp, left: 15.sp),
                                    // padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 5.sp),
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 50.w,
                                              child: Text(
                                                cusFood.customFoodlist[index].title.capitalize ??
                                                    " ",
                                                style: AppTextStyles.contentFont3,
                                                maxLines: 2,
                                              ),
                                            ),
                                            Text(
                                              splitedTxt[0],
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
                                            Text(splitedTxt[1],
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 15.sp,
                                                  color: Colors.grey,
                                                )),
                                            Obx(() => _iconShow.value
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      InkWell(
                                                        child: Icon(Icons.edit),
                                                        onTap: () {
                                                          print(cusFood.customFoodlist[index]);
                                                          Get.to(EditCustomFood(
                                                            mealType: widget.mealType,
                                                            baseColor: widget.baseColor,
                                                            recipeDetails: cusFood
                                                                .customFoodlist[index].extras,
                                                            mealData: widget.mealData,
                                                          ));
                                                        },
                                                      ),
                                                      Gap(5.sp),
                                                      IconButton(
                                                        onPressed: () async {
                                                          AwesomeDialog(
                                                            context: context,
                                                            animType: AnimType.TOPSLIDE,
                                                            dialogType: DialogType.WARNING,
                                                            title: "Confirm!",
                                                            desc: "Are you sure to delete this log",
                                                            btnOkOnPress: () async {
                                                              deleteFood(
                                                                  cusFood.customFoodlist[index]
                                                                      .title.capitalize,
                                                                  cusFood.customFoodlist[index]
                                                                      .foodItemID,
                                                                  cusFood.customFoodlist[index]);
                                                            },
                                                            btnCancelOnPress: () {},
                                                            btnCancelText: "Cancel",
                                                            btnOkText: "Delete",
                                                            btnCancelColor:
                                                                AppColors.primaryAccentColor,
                                                            // btnOkColor: widget.screenColor,
                                                          ).show();
                                                        },
                                                        icon: Icon(
                                                          Icons.close,
                                                        ),
                                                        color: Colors.red,
                                                      )
                                                    ],
                                                  )
                                                : IconButton(
                                                    onPressed: () {
                                                      if (gNavigate.value) {
                                                        Get.to(CustomeFoodDetailScreen(
                                                          foodName:
                                                              cusFood.customFoodlist[index].title,
                                                          foodId: cusFood
                                                              .customFoodlist[index].foodItemID,
                                                          mealType: widget.mealType,
                                                          mealData: widget.mealData,
                                                          baseColor: widget.baseColor,
                                                          logDate: widget.logDate,
                                                        ));
                                                      }
                                                    },
                                                    icon: Icon(Icons.add,
                                                        color: gNavigate.value
                                                            ? widget.baseColor
                                                            : Colors.grey)))
                                          ],
                                        ),
                                      ],
                                    ),
                                    // subtitle: Text(splitedTxt[0]),
                                  ),
                                ),
                              );
                            })),
                SizedBox(height: 8.h,)
              ],
            ),
          );
        },
      ),
    );
  }
}
