import 'package:get/get.dart';
import 'package:ihl/new_design/data/model/healthJournalModel/healthJournalAllMealsWeeklyModel.dart';
import 'package:ihl/new_design/presentation/Widgets/healthjournalWidgets/healthJournalWidgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import '../../../views/dietJournal/calorieGraph/monthly_calorie_tab.dart';
import '../../presentation/Widgets/healthjournalWidgets/myInsightsWidgets.dart';
import '../../presentation/Widgets/healthjournalWidgets/normalHealthJournalWidgets.dart';
import '../../presentation/controllers/healthJournalControllers/foodLogGraphController.dart';
import '../model/healthJournalModel/healthJournalgraph.dart';

class HealthJournalFunctions {
  static List<DateTime> dateCalculator({DateTime start, DateTime end, bool forword}) {
    List<DateTime> returnValues = [];
    DateTime now = DateTime.now();
    print(HealthJournalWidget.changed.value);
    if (forword) {
      if ((HealthJournalWidget.changed.value == "Day" &&
              start.day == now.day &&
              end.month == now.month) ||
          (HealthJournalWidget.changed.value != "Day" &&
              (end.day == now.day && end.month == now.month && end.year == now.year))) {
        returnValues = [start, end];
      } else {
        if (HealthJournalWidget.changed.value == "Day") {
          returnValues.add(start.add(Duration(days: 1)));
          returnValues.add(end.add(Duration(days: 1)));
        } else if (HealthJournalWidget.changed.value == "Weekly") {
          returnValues.add(start.add(Duration(days: 7)));
          returnValues.add(end.add(Duration(days: 7)));
        } else if (HealthJournalWidget.changed.value == "Monthly") {
          returnValues.add(start.add(Duration(days: 365)));
          returnValues.add(end.add(Duration(days: 365)));
        }
      }
    } else {
      if (HealthJournalWidget.changed.value == "Day") {
        returnValues.add(start.subtract(Duration(days: 1)));
        returnValues.add(end.subtract(Duration(days: 1)));
      } else if (HealthJournalWidget.changed.value == "Weekly") {
        returnValues.add(start.subtract(Duration(days: 7)));
        returnValues.add(end.subtract(Duration(days: 7)));
      } else if (HealthJournalWidget.changed.value == "Monthly") {
        returnValues.add(start.subtract(Duration(days: 365)));
        returnValues.add(end.subtract(Duration(days: 365)));
      }
    }
    return returnValues;
  }

  static List<DateTime> dateCalculatorSingle({DateTime start, DateTime end, bool forword}) {
    List<DateTime> returnValues = [];
    DateTime now = DateTime.now();
    print(NormalHealthJournalWidgets.currentIndexValue.value);
    if (forword) {
      if ((NormalHealthJournalWidgets.currentIndexValue.value == "Day" &&
              start.day == now.day &&
              end.month == now.month) ||
          (NormalHealthJournalWidgets.currentIndexValue.value != "Day" &&
              (end.day == now.day && end.month == now.month && end.year == now.year))) {
        returnValues = [start, end];
      } else {
        if (NormalHealthJournalWidgets.currentIndexValue.value == "Day") {
          returnValues.add(start.add(Duration(days: 1)));
          returnValues.add(end.add(Duration(days: 1)));
        } else if (NormalHealthJournalWidgets.currentIndexValue.value == "Weekly") {
          returnValues.add(start.add(Duration(days: 7)));
          returnValues.add(end.add(Duration(days: 7)));
        } else if (NormalHealthJournalWidgets.currentIndexValue.value == "Monthly") {
          returnValues.add(start.add(Duration(days: 365)));
          returnValues.add(end.add(Duration(days: 365)));
        }
      }
    } else {
      if (NormalHealthJournalWidgets.currentIndexValue.value == "Day") {
        returnValues.add(start.subtract(Duration(days: 1)));
        returnValues.add(end.subtract(Duration(days: 1)));
      } else if (NormalHealthJournalWidgets.currentIndexValue.value == "Weekly") {
        returnValues.add(start.subtract(Duration(days: 7)));
        returnValues.add(end.subtract(Duration(days: 7)));
      } else if (NormalHealthJournalWidgets.currentIndexValue.value == "Monthly") {
        returnValues.add(start.subtract(Duration(days: 365)));
        returnValues.add(end.subtract(Duration(days: 365)));
      }
    }
    return returnValues;
  }

  static Future<List<ChartData>> graphValues({List<DateTime> dateFreq}) async {
    HealthJournalWidget.loader = true;
    List<HealthJournalGraphModel> listofData = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ihlId = prefs.getString("ihlUserId");
    print(dateFreq[0].toString());
    print(dateFreq[1].toString());
    HealthJournalGraphToJson healthJournalGraphToJson = HealthJournalGraphToJson(
        userId: ihlId,
        mealType: [HealthJournalWidget.selectedDropDownValue.value],
        startEpochDate: dateFreq.first.millisecondsSinceEpoch,
        endEpochDate: dateFreq[1].millisecondsSinceEpoch);
    listofData =
        await GraphApi().getLoggedFoodList(healthJournalGraphToJson: healthJournalGraphToJson);
    List<ChartData> ss = [];
    if (HealthJournalWidget.changed.value == "Day") {
      listofData
          .map((e) => ss.add(ChartData(DateFormat('KK:mm a').format(e.foodLogTime),
              double.parse(e.totalCaloriesGained.toString()).toInt())))
          .toList();
    }
    if (HealthJournalWidget.changed.value == "Weekly") {
      List<DayModel> dayswithvalues = [];
      List days = getMonthsInYear(DateTime.now(), 7, daycount: true);
      days.map((e) {
        dayswithvalues.add(DayModel(day: e["day"], data: []));
        // ss.add(ChartData(e.toString().substring(0, 3), 9));
      }).toList();
      for (HealthJournalGraphModel ee in listofData) {
        dayswithvalues.map((e) => e.data.addIf(ee.day == e.day, ee)).toList();
      }
      for (DayModel e in dayswithvalues) {
        List<int> intvalue = [];
        e.data
            .map((ee) => intvalue.add(double.parse(ee.totalCaloriesGained.toString()).toInt()))
            .toList();
        e.fullValue = intvalue.sum;
      }
      dayswithvalues.map((e) {
        ss.add(ChartData(e.day.substring(0, 3), e.fullValue));
      }).toList();
      List<ChartData> temp = [];
      for (int i = ss.length - 1; i >= 0; i--) {
        temp.add(ss[i]);
      }
      ss = temp;
    }
    if (HealthJournalWidget.changed.value == "Monthly") {
      List<DayModel> dayswithvalues = [];
      List days = getMonthsInYear(DateTime.now(), 12, daycount: false);
      days.map((e) {
        dayswithvalues.add(DayModel(day: e, data: []));
        // ss.add(ChartData(e.toString().substring(0, 3), 9));
      }).toList();
      for (HealthJournalGraphModel ee in listofData) {
        dayswithvalues.map((e) => e.data.addIf(ee.month == e.day, ee)).toList();
      }
      for (DayModel e in dayswithvalues) {
        List<int> intvalue = [];
        e.data
            .map((ee) => intvalue.add(double.parse(ee.totalCaloriesGained.toString()).toInt()))
            .toList();
        e.fullValue = intvalue.sum;
      }
      dayswithvalues.map((e) {
        ss.add(ChartData(e.day.substring(0, 3), e.fullValue));
      }).toList();
      List<ChartData> temp = [];
      for (int i = ss.length - 1; i >= 0; i--) {
        temp.add(ss[i]);
      }
      ss = temp;
    }
    HealthJournalWidget.loader = false;
    return ss;
  }

  static Future<List<ChartData>> singleGraphValue({List<DateTime> dateFreq}) async {
    NormalHealthJournalWidgets.myInsightLoader = true;
    List<HealthJournalGraphModel> listofData = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ihlId = prefs.getString("ihlUserId");
    print(dateFreq[1].millisecondsSinceEpoch.toString());
    HealthJournalGraphToJson healthJournalGraphToJson = HealthJournalGraphToJson(
        userId: ihlId,
        mealType: [NormalHealthJournalWidgets.selectedCategory.value],
        startEpochDate: dateFreq.first.millisecondsSinceEpoch,
        endEpochDate: dateFreq[1].millisecondsSinceEpoch);
    listofData =
        await GraphApi().getLoggedFoodList(healthJournalGraphToJson: healthJournalGraphToJson);
    List<ChartData> ss = [];
    if (NormalHealthJournalWidgets.currentIndexValue.value == "Day") {
      listofData
          .map((e) => ss.add(ChartData(DateFormat('KK:mm a').format(e.foodLogTime),
              double.parse(e.totalCaloriesGained.toString()).toInt(),
              category: DateFormat('KK:mm a').format(e.foodLogTime))))
          .toList();
    }
    if (NormalHealthJournalWidgets.currentIndexValue.value == "Weekly") {
      List<DayModel> dayswithvalues = [];
      List days = getMonthsInYear(dateFreq[1], 7, daycount: true);
      days.map((e) {
        dayswithvalues.add(DayModel(day: e["day"], data: [], name: e["dayformat"]));
        // ss.add(ChartData(e.toString().substring(0, 3), 9));
      }).toList();
      for (HealthJournalGraphModel ee in listofData) {
        dayswithvalues.map((e) => e.data.addIf(ee.day == e.day, ee)).toList();
      }
      for (DayModel e in dayswithvalues) {
        List<int> intvalue = [];
        e.data
            .map((ee) => intvalue.add(double.parse(ee.totalCaloriesGained.toString()).toInt()))
            .toList();
        e.fullValue = intvalue.sum;
      }
      dayswithvalues.map((e) {
        ss.add(ChartData(e.day.substring(0, 3), e.fullValue, category: e.name));
      }).toList();
      List<ChartData> temp = [];
      for (int i = ss.length - 1; i >= 0; i--) {
        temp.add(ss[i]);
      }
      ss = temp;
    }
    if (NormalHealthJournalWidgets.currentIndexValue.value == "Monthly") {
      List<DayModel> dayswithvalues = [];
      List days = getMonthsInYear(DateTime.now(), 12, daycount: false);
      days.map((e) {
        dayswithvalues.add(DayModel(day: e, data: [], name: e));
        // ss.add(ChartData(e.toString().substring(0, 3), 9));
      }).toList();
      for (HealthJournalGraphModel ee in listofData) {
        dayswithvalues.map((e) => e.data.addIf(ee.month == e.day, ee)).toList();
      }
      for (DayModel e in dayswithvalues) {
        List<int> intvalue = [];
        e.data
            .map((ee) => intvalue.add(double.parse(ee.totalCaloriesGained.toString()).toInt()))
            .toList();
        e.fullValue = intvalue.sum;
      }
      dayswithvalues.map((e) {
        ss.add(ChartData(e.day.substring(0, 3), e.fullValue, category: e.name));
      }).toList();
      List<ChartData> temp = [];
      for (int i = ss.length - 1; i >= 0; i--) {
        temp.add(ss[i]);
      }
      ss = temp;
    }
    NormalHealthJournalWidgets.myInsightLoader = false;
    return ss;
  }

  static List getMonthsInYear(DateTime createdDate, int length, {bool daycount}) {
    List data = [];
    if (daycount) {
      DateFormat dateFormat = DateFormat("EEEE");
      DateFormat dateFormat2 = DateFormat("EEEE, d MMMM");
      int currentYear = createdDate.year;
      int currentMonth = createdDate.month;
      int currenDay = createdDate.day;
      for (int i = 0; i < length; i++) {
        createdDate = DateTime(currentYear, currentMonth, currenDay--);
        data.add(
            {"day": dateFormat.format(createdDate), "dayformat": dateFormat2.format(createdDate)});

        // if (currentMonth + i == 1) {
        //   currentYear += 1;
        // }
      }
    } else {
      DateFormat dateFormat = DateFormat("MMMM");
      int currentYear = createdDate.year;
      int currentMonth = createdDate.month;
      for (int i = 0; i < length; i++) {
        createdDate = DateTime(currentYear, currentMonth + i);
        data.add(dateFormat.format(createdDate));

        if (currentMonth + i == 1) {
          currentYear += 1;
        }
      }
    }
    return data;
  }

  static Future allDataGraphValue({List<DateTime> dateFreq, List<String> selectedCate}) async {
    List<HealthJournalGraphModel> listofData = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ihlId = prefs.getString("ihlUserId");
    print(dateFreq[1].millisecondsSinceEpoch.toString());
    HealthJournalGraphToJson healthJournalGraphToJson = HealthJournalGraphToJson(
        userId: ihlId,
        mealType: selectedCate,
        startEpochDate: dateFreq.first.millisecondsSinceEpoch,
        endEpochDate: dateFreq[1].millisecondsSinceEpoch);
    listofData =
        await GraphApi().getLoggedFoodList(healthJournalGraphToJson: healthJournalGraphToJson);
    List ss = [];
    if (MyInsightsWidgets.myInsigtschanged.value == "Day") {
      ss = allMealsDay(list: listofData);
    }
    if (MyInsightsWidgets.myInsigtschanged.value == "Weekly") {
      ss = allMealsWeekly(list: listofData, dayss: dateFreq);
      List temp = [];
      for (int i = ss.length - 1; i >= 0; i--) {
        temp.add(ss[i]);
      }
      ss = temp;
    }
    if (MyInsightsWidgets.myInsigtschanged.value == "Monthly") {
      List<DayModel> dayswithvalues = [];
      List days = getMonthsInYear(DateTime.now(), 12, daycount: false);
      days.map((e) {
        dayswithvalues.add(DayModel(day: e, data: []));
        // ss.add(ChartData(e.toString().substring(0, 3), 9));
      }).toList();
      for (HealthJournalGraphModel ee in listofData) {
        dayswithvalues.map((e) => e.data.addIf(ee.month == e.day, ee)).toList();
      }
      for (DayModel e in dayswithvalues) {
        List<int> intvalue = [];
        e.data
            .map((ee) => intvalue.add(double.parse(ee.totalCaloriesGained.toString()).toInt()))
            .toList();
        e.fullValue = intvalue.sum;
      }
      dayswithvalues.map((e) {
        ss.add(ChartData(e.day, e.fullValue));
      }).toList();
      List<ChartData> temp = [];
      for (int i = ss.length - 1; i >= 0; i--) {
        temp.add(ss[i]);
      }
      ss = temp;
    }
    return ss;
  }

  static List<ChartData> allMealsDay({List<HealthJournalGraphModel> list}) {
    List<DayModel> sortedData = [];
    MyInsightsWidgets.keys.map((e) {
      sortedData.add(DayModel(day: e, data: []));
      // ss.add(ChartData(e.toString().substring(0, 3), 9));
    }).toList();
    sortedData.removeWhere((element) => element.day == "All Meals");
    for (HealthJournalGraphModel ee in list) {
      sortedData.map((e) => e.data.addIf(ee.foodTimeCategory == e.day, ee)).toList();
    }
    for (DayModel e in sortedData) {
      List<int> intvalue = [];
      e.data
          .map((ee) => intvalue.add(double.parse(ee.totalCaloriesGained.toString()).toInt()))
          .toList();
      e.fullValue = intvalue.sum;
    }
    List<ChartData> ss = [];
    sortedData.map((e) {
      ss.add(ChartData(e.day, e.fullValue));
    }).toList();
    return ss;
  }

  static List allMealsWeekly({List<HealthJournalGraphModel> list, List<DateTime> dayss}) {
    List<WeeklyModel> sortedData = [];
    List<dynamic> days = getMonthsInYear(dayss[1], 7, daycount: true);
    days
        .map((e) => sortedData.add(WeeklyModel(
              xValue: e["day"],
              fullValue: 0,
              name: e["dayformat"],
              categoryWiseData: [
                CategoryWiseDatum(categoryName: "Breakfast", data: [], catFullValue: 0),
                CategoryWiseDatum(categoryName: "Lunch", data: [], catFullValue: 0),
                CategoryWiseDatum(categoryName: "Dinner", data: [], catFullValue: 0),
                CategoryWiseDatum(categoryName: "Snacks", data: [], catFullValue: 0),
              ],
            )))
        .toList();
    sortedData.map((week) {
      list.map((food) {
        int dayInde = sortedData.indexWhere((element) => element.xValue == week.xValue);
        if (week.xValue == food.day) {
          for (CategoryWiseDatum categoryWiseDatum in week.categoryWiseData) {
            if (categoryWiseDatum.categoryName == food.foodTimeCategory) {
              int cateInde = sortedData[dayInde].categoryWiseData.indexWhere((element) {
                return element.categoryName == food.foodTimeCategory;
              });
              sortedData[dayInde].categoryWiseData[cateInde].data.add(food);
            }
          }
        }
      }).toList();

      for (CategoryWiseDatum es in week.categoryWiseData) {
        List<int> intvalue = [];
        es.data.map(
          (ee) {
            intvalue.add(double.parse(ee.totalCaloriesGained.toString()).toInt());
          },
        ).toList();
        es.catFullValue = intvalue.sum;
      }
    }).toList();
    for (WeeklyModel se in sortedData) {
      List<int> intvalue = [];
      se.categoryWiseData.map((e) => intvalue.add(int.parse(e.catFullValue.toString()))).toList();
      // se.data.map((ee) => intvalue.add(int.parse(ee.totalCaloriesGained.toString()))).toList();
      se.fullValue = intvalue.sum;
    }
    return sortedData;
  }

  static List<DateTime> myInsigtsdateCalculator({DateTime start, DateTime end, bool forword}) {
    List<DateTime> returnValues = [];
    DateTime now = DateTime.now();
    print(MyInsightsWidgets.myInsigtschanged.value);
    if (forword) {
      if ((MyInsightsWidgets.myInsigtschanged.value == "Day" &&
              start.day == now.day &&
              end.month == now.month) ||
          (MyInsightsWidgets.myInsigtschanged.value != "Day" &&
              (end.day == now.day && end.month == now.month && end.year == now.year))) {
        returnValues = [start, end];
      } else {
        if (MyInsightsWidgets.myInsigtschanged.value == "Day") {
          returnValues.add(start.add(Duration(days: 1)));
          returnValues.add(end.add(Duration(days: 1)));
        } else if (MyInsightsWidgets.myInsigtschanged.value == "Weekly") {
          returnValues.add(start.add(Duration(days: 7)));
          returnValues.add(end.add(Duration(days: 7)));
        } else if (MyInsightsWidgets.myInsigtschanged.value == "Monthly") {
          returnValues.add(start.add(Duration(days: 365)));
          returnValues.add(end.add(Duration(days: 365)));
        }
      }
    } else {
      if (MyInsightsWidgets.myInsigtschanged.value == "Day") {
        returnValues.add(start.subtract(Duration(days: 1)));
        returnValues.add(end.subtract(Duration(days: 1)));
      } else if (MyInsightsWidgets.myInsigtschanged.value == "Weekly") {
        returnValues.add(start.subtract(Duration(days: 7)));
        returnValues.add(end.subtract(Duration(days: 7)));
      } else if (MyInsightsWidgets.myInsigtschanged.value == "Monthly") {
        returnValues.add(start.subtract(Duration(days: 365)));
        returnValues.add(end.subtract(Duration(days: 365)));
      }
    }
    return returnValues;
  }
}
