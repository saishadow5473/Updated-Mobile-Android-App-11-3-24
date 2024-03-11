import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ihl/models/recommended_food._model.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';

class RecommendedDietMenu extends StatefulWidget {
  dynamic value;
  var index;
  dynamic color;
  RecommendedDietMenu({
    this.value,
    this.index,
    this.color,
  });

  @override
  State<RecommendedDietMenu> createState() => _RecommendedDietMenuState();
}

class _RecommendedDietMenuState extends State<RecommendedDietMenu> {
  Color startColor;
  Color endColor;
  List mealType = [
    "BreakFast",
    "Lunch",
    "Snacks",
    "Dinner",
    "Early Meal",
    "Mid Meal"
  ];
  List breakFast = [];
  List lunchMeal = [];
  List dinner = [];
  List snacks = [];
  List midMeal = [];
  List earlyMeal = [];

  List imageAssets = [
    'assets/images/diet/breakfast.png',
    'assets/images/diet/lunch.png',
    'assets/images/diet/snack.png',
    'assets/images/diet/dinner.png',
    'assets/images/diet/snack.png',
    'assets/images/diet/snack.png',
  ];
  double getFontSize(double px) {
    var height = getVerticalSize(px);
    var width = getHorizontalSize(px);
    if (height < width) {
      return height.toInt().toDouble();
    } else {
      return width.toInt().toDouble();
    }
  }

  void initState() {
    sortingMeal();
    super.initState();
  }

  // colorSet() {
  //   if (widget.index == 0) {
  //     setState(() {
  //       startColor:
  //       Color(0xffed3f18);
  //       endColor:
  //       Color(0xfff57f64);
  //     });
  //   }
  //   if (widget.index == 1) {
  //     setState(() {
  //       startColor:
  //       Color(0xff23b6e6);
  //       endColor:
  //       Color(0xff40E0D0);
  //     });
  //   }
  //   if (widget.index == 2) {
  //     setState(() {
  //       startColor:
  //       Color(0xffFE95B6);
  //       endColor:
  //       Color(0xffFF5287);
  //     });
  //   }
  //   if (widget.index == 3) {
  //     setState(() {
  //       startColor:
  //       Color(0xff6F72CA);
  //       endColor:
  //       Color(0xff1E1466);
  //     });
  //   }
  //   if (widget.index == 4) {
  //     setState(() {
  //       startColor:
  //       Color(0xffb4ce4f);
  //       endColor:
  //       Color(0xffaace24);
  //     });
  //   }
  //   if (widget.index == 5) {
  //     setState(() {
  //       startColor:
  //       Color(0xffe763b9);
  //       endColor:
  //       Color(0xffbf4f97);
  //     });
  //   }
  //   // return startColor;
  // }

  sortingMeal() {
    dynamic foodList = widget.value;
    if (foodList != null) {
      for (var i = 0; i <= foodList.length; i++) {
        var listEntities = foodList[i];
        var foodValue = recommendedFoodFromJson(listEntities);
        // var foodEntryList = listEntities.entries.toList();
        if (foodValue.mealType == "breakfast") {
          //print(foodEntryList[7]);
          breakFast.add(foodValue.dishName);
        } else if (foodValue.mealType == "lunch") {
          //print(foodEntryList[7]);
          lunchMeal.add(foodValue.dishName);
        } else if (foodValue.mealType == "dinner") {
          //print(foodEntryList[7]);
          dinner.add(foodValue.dishName);
        } else {
          //print(foodEntryList[7]);
          snacks.add(foodValue.dishName);
        }
      }
    }
    setState(() {});
    //print((breakFast));
  }

  Size size = WidgetsBinding.instance.window.physicalSize /
      WidgetsBinding.instance.window.devicePixelRatio;
  double getHorizontalSize(double px) {
    return px * (size.width / 375);
  }

  double getVerticalSize(double px) {
    num statusBar = MediaQuery.of(context).viewPadding.top;
    num screenHeight = size.height - statusBar;
    return screenHeight * (px / 812);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Container(
              width: getHorizontalSize(125),
              height: getVerticalSize(200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(40.0),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: HexColor(widget.color[1]).withOpacity(0.6),
                      offset: const Offset(1.1, 4.0),
                      blurRadius: 8.0),
                ],
                gradient: LinearGradient(
                  colors: <HexColor>[
                    HexColor(widget.color[0]),
                    HexColor(widget.color[1]),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                color: Colors.white,
              ),
              margin: EdgeInsets.only(
                top: 20,
                right: 10,
                left: 10,
              ),
              alignment: Alignment.center,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Gap(40),
                  AutoSizeText(
                    mealType[widget.index],
                    // foodLogList[0].food[0].foodDetails.foodName
                    // foodLogList!=null?(foodLogList.foodTimeCategory.toString()).capitalize():'',
                    textAlign: TextAlign.center,
                    // maxFontSize: ScUtil().setSp(16),
                    minFontSize: ScUtil().setSp(12),
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.bold,
                      fontSize: ScUtil().setSp(16),
                      letterSpacing: 0.2,
                      color: FitnessAppTheme.white,
                    ),
                  ),
                  //for (var i=0; i>=widget.value.length;)
                  // widget.value != null
                  //     ? Text(
                  //         widget.value['dish_name'],
                  //         textAlign: TextAlign.center,
                  //         style: TextStyle(
                  //             color: FitnessAppTheme.white,
                  //             fontWeight: FontWeight.w600,
                  //             fontFamily: 'Poppins',
                  //             fontSize: getFontSize(16)),
                  //       )
                  //     : Text("food to be shown"),
                ],
              ),
            ),
            Positioned(
              top: ScUtil().setHeight(0),
              left: ScUtil().setWidth(0),
              child: Container(
                  width: ScUtil().setWidth(65),
                  height: ScUtil().setHeight(65),
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.nearlyWhite.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(imageAssets[widget.index],
                      height: 55, width: 55)
                  // child: Image.asset(
                  //   'assets/images/diet/breakfast.png',
                  //   height: 55,
                  //   width: 55,
                  // ),
                  ),
            ),
            // Positioned(
            //   top: ScUtil().setHeight(-7),
            //   left: ScUtil().setWidth(-10),
            //   child: Image.asset(
            //     'assets/images/diet/breakfast.png',
            //     height: 55,
            //     width: 55,
            //   ),
            // )
          ],
        ),
        TextButton(
          //onPressed: onTap,
          onPressed: () {
            print(widget.index);
          },
          child: Text(
            'Log ${mealType[widget.index]}',
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              color: AppColors.primaryAccentColor,
              fontSize: getFontSize(
                14,
              ),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }
}
