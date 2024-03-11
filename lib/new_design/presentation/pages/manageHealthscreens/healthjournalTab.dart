import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../views/dietJournal/dietJournalNew.dart';
import '../../../app/utils/appColors.dart';
import '../../Widgets/healthjournalWidgets/normalHealthJournalWidgets.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../Widgets/dashboardWidgets/teleconsultation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../views/dietJournal/dietJournal.dart';
import '../../../app/utils/imageAssets.dart';
import '../../../data/functions/healthJounralFunctions.dart';
import '../../../data/model/healthJournalModel/healthJournalgraph.dart';
import '../../Widgets/appBar.dart';
import '../../Widgets/healthJournalCard.dart';
import '../../Widgets/healthjournalWidgets/healthJournalWidgets.dart';
import '../../controllers/healthJournalControllers/foodLogGraphController.dart';
import '../basicData/functionalities/percentage_calculations.dart';
import '../basicData/screens/ProfileCompletion.dart';
import 'healthJournalScreens/myInsightsScreen.dart';

class HealthJournalTab extends StatefulWidget {
  const HealthJournalTab({Key key}) : super(key: key);

  @override
  State<HealthJournalTab> createState() => _HealthJournalTabState();
}

class _HealthJournalTabState extends State<HealthJournalTab> {
  List<HealthJournalGraphModel> listofData = [];
  final ValueNotifier<bool> _loader = ValueNotifier<bool>(true);

  @override
  void initState() {
    asyncFunction();
    super.initState();
    graphValues();
  }

  asyncFunction() async {
    HealthJournalWidget.changed.value = "Weekly";
    DateTimeHolderFordashboard.dayFre = constantDate.dayFre;
    DateTimeHolderFordashboard.monthFre = constantDate.monthFre;
    DateTimeHolderFordashboard.weekFre = constantDate.weekFre;
    HealthJournalWidget.datas =
        await HealthJournalFunctions.graphValues(dateFreq: DateTimeHolderFordashboard.weekFre);
    HealthJournalWidget.selectedDropDownValue.addListener(() async {
      String ss = HealthJournalWidget.selectedDropDownValue.value;
      if (ss == "Breakfast") {
        HealthJournalWidget.colorForDropDownAndMap.value = const Color(0XFFF15B3A);
        HealthJournalWidget.datas = await HealthJournalFunctions.graphValues(
            dateFreq: HealthJournalWidget.changed.value == "Weekly"
                ? DateTimeHolderFordashboard.weekFre
                : HealthJournalWidget.changed.value == "Monthly"
                    ? DateTimeHolderFordashboard.monthFre
                    : DateTimeHolderFordashboard.dayFre);
      } else if (ss == "Lunch") {
        HealthJournalWidget.colorForDropDownAndMap.value = const Color(0XFF2EC6DE);
        await HealthJournalFunctions.graphValues(
            dateFreq: HealthJournalWidget.changed.value == "Weekly"
                ? DateTimeHolderFordashboard.weekFre
                : HealthJournalWidget.changed.value == "Monthly"
                    ? DateTimeHolderFordashboard.monthFre
                    : DateTimeHolderFordashboard.dayFre);
      } else if (ss == "Snacks") {
        HealthJournalWidget.colorForDropDownAndMap.value = const Color(0XFFFE6292);
        HealthJournalWidget.datas = await HealthJournalFunctions.graphValues(
            dateFreq: HealthJournalWidget.changed.value == "Weekly"
                ? DateTimeHolderFordashboard.weekFre
                : HealthJournalWidget.changed.value == "Monthly"
                    ? DateTimeHolderFordashboard.monthFre
                    : DateTimeHolderFordashboard.dayFre);
      } else if (ss == "Dinner") {
        HealthJournalWidget.colorForDropDownAndMap.value = const Color(0XFF383387);
        HealthJournalWidget.datas = await HealthJournalFunctions.graphValues(
            dateFreq: HealthJournalWidget.changed.value == "Weekly"
                ? DateTimeHolderFordashboard.weekFre
                : HealthJournalWidget.changed.value == "Monthly"
                    ? DateTimeHolderFordashboard.monthFre
                    : DateTimeHolderFordashboard.dayFre);
      } else {
        HealthJournalWidget.colorForDropDownAndMap.value = const Color(0XFFF15B3A);
        HealthJournalWidget.datas = await HealthJournalFunctions.graphValues(
            dateFreq: HealthJournalWidget.changed.value == "Weekly"
                ? DateTimeHolderFordashboard.weekFre
                : HealthJournalWidget.changed.value == "Monthly"
                    ? DateTimeHolderFordashboard.monthFre
                    : DateTimeHolderFordashboard.dayFre);
      }
      HealthJournalWidget.changed.notifyListeners();
    });
    setState(() {});
  }

  List<String> list = <String>['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

  @override
  Widget build(BuildContext context) {
    print(Tabss.featureSettings.healthJornal);
    return ValueListenableBuilder(
        valueListenable: _loader,
        builder: (_, v, __) {
          if (v) {
            return SizedBox(
              height: 13.5.h,
              width: 100.w,
              child: Shimmer.fromColors(
                  direction: ShimmerDirection.ltr,
                  period: const Duration(seconds: 2),
                  baseColor: const Color.fromARGB(255, 240, 240, 240),
                  highlightColor: Colors.grey.withOpacity(0.2),
                  child: Container(
                      height: 13.5.h,
                      width: 100.w,
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Data Loading'))),
            );
          } else {
            if (!Tabss.featureSettings.healthJornal) {
              if (listofData.isNotEmpty) {
                return Container(
                  color: AppColors.backgroundScreenColor,
                  padding: EdgeInsets.all(6.sp),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                            key: const ValueKey('HJ_PTM05063'),
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Calorie Tracker',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                        Align(
                            key: const ValueKey('HJ_PTM05063_2'),
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Monitor your diet and calories burned by entering details into the app.',
                                style: TextStyle(fontSize: 14.5.sp),
                              ),
                            )),
                        GestureDetector(
                          onTap: () {
                            // Get.to(DietJournal());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Card(
                              key: const ValueKey('HJFJ_PCM05063'),
                              child: Column(
                                children: [
                                  Image(
                                      height: 21.4.h,
                                      width: 100.w,
                                      image: ImageAssets.healthLogImage,
                                      fit: BoxFit.fill),
                                ],
                              ),
                            ),
                          ),
                        ),
                        graphUi(),
                        SizedBox(
                          height: 12.h,
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(child: Text("Calorie Tracker Not Available"));
              }
            } else {
              return Container(
                height: 100.h,
                color: AppColors.backgroundScreenColor,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                          key: const ValueKey('HJ_PTM05063'),
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Calorie Tracker',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                      Align(
                          key: const ValueKey('HJ_PTM05063_2'),
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Keep track of your food intake and calories burnt by logging details into the app.',
                              style: TextStyle(fontSize: 14.5.sp),
                            ),
                          )),
                      GestureDetector(
                        onTap: () {
                          if (PercentageCalculations().calculatePercentageFilled() != 100) {
                            Get.to(ProfileCompletionScreen());
                          } else {
                            Get.to(DietJournalNew(
                              Screen: "home",
                            ));
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Card(
                            key: const ValueKey('HJFJ_PCM05063'),
                            child: Column(
                              children: [
                                Image(
                                    height: 21.4.h,
                                    width: 100.w,
                                    image: ImageAssets.healthLogImage,
                                    fit: BoxFit.fill),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 1.h, left: 1.w, right: 1.w),
                        child: HealthJournalCard().caloriesCard(context, fromHome: 'managehealth'),
                      ),
                      graphUi(),
                      SizedBox(height: 15.h)
                    ],
                  ),
                ),
              );
            }
          }
        });
  }

  Column graphUi() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 18, 8, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Insights",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              ValueListenableBuilder(
                  valueListenable: HealthJournalWidget.changed,
                  builder: (BuildContext context, int, Widget child) {
                    if (listofData.isNotEmpty) {
                      return TeleConsultationWidgets().viewAll(
                          onTap: () {
                            Get.to(const MyInsightsHealthJournal(), transition: Transition.fadeIn);
                          },
                          color: HealthJournalWidget.colorForDropDownAndMap.value);
                    } else {
                      return Container();
                    }
                  })
            ],
          ),
        ),
        ValueListenableBuilder(
            key: const Key("HJMI_PCS05063"),
            valueListenable: HealthJournalWidget.changed,
            builder: (BuildContext ctx, index, Widget child) {
              return Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: DropdownButton<String>(
                        value: HealthJournalWidget.selectedDropDownValue.value,
                        icon: Icon(Icons.arrow_drop_down,
                            color: HealthJournalWidget.colorForDropDownAndMap.value),
                        elevation: 16,
                        style:
                            TextStyle(fontSize: 13.px, color: Colors.black, fontFamily: "Poppins"),
                        underline: Container(
                          height: 2,
                          color: Colors.grey,
                        ),
                        onChanged: (String value) async {
                          HealthJournalWidget.selectedDropDownValue.value = value;
                          HealthJournalWidget.datas = await HealthJournalFunctions.graphValues(
                              dateFreq: HealthJournalWidget.freqs);
                          HealthJournalWidget.changed.notifyListeners();
                        },
                        items: list.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  HealthJournalWidget.graphHealthJournal(
                      datatoDisplay: HealthJournalWidget.datas,
                      color: HealthJournalWidget.colorForDropDownAndMap.value),
                ],
              );
            }),
      ],
    );
  }

  Future graphValues() async {
    _loader.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ihlId = prefs.getString("ihlUserId");
    HealthJournalGraphToJson healthJournalGraphToJson = HealthJournalGraphToJson(
        userId: ihlId,
        mealType: ['Breakfast', 'Lunch', 'Snacks', 'Dinner'],
        startEpochDate: DateTime.now().subtract(const Duration(days: 1000)).millisecondsSinceEpoch,
        endEpochDate: DateTime.now().millisecondsSinceEpoch);
    listofData =
        await GraphApi().getLoggedFoodList(healthJournalGraphToJson: healthJournalGraphToJson);
    // print(listofData);
    HealthJournalWidget.changed.notifyListeners();
    _loader.value = false;
  }
}
