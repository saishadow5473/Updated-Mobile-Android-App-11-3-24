import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/managehealth/stepcounter/googleFitStepController.dart';

class InsightStepCounter extends StatelessWidget {
  const InsightStepCounter({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _stepController = Get.find<GoogleFitStepController>();
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          IconButton(
              onPressed: () => _stepController.previousWeekChart(),
              icon: Icon(Icons.arrow_left)),
          GetBuilder<GoogleFitStepController>(
              id: 'chartdata',
              initState: (_d) => _stepController.fetchLastSevenDaysSteps(),
              builder: (_) => _.weeklyChartLoaded
                  ? Shimmer.fromColors(
                      child: Container(
                        alignment: Alignment.center,
                        height: 12.h,
                        width: 80.w,
                        child: Text('Loading'),
                      ),
                      baseColor: Colors.white,
                      highlightColor: Colors.grey)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(8),
                        Builder(builder: (context) {
                          double heightOnePersentagee = 16.w / 100;
                          List<double> persentagess = [];
                          List<StepsData> ss = [];
                          ss = ss + _.stepsList;
                          ss.sort(((a, b) => (b.steps).compareTo(a.steps)));
                          var i = ss.first.steps;
                          List yAxisData = [
                            double.parse((i + (i / 10)).toString()).toInt(),
                            double.parse((i / 2).toString()).toInt(),
                            double.parse((i / 3).toString()).toInt(),
                            0
                          ];
                          for (var e in _.stepsList) {
                            double currentValuePercentage =
                                ((e.steps / yAxisData[0]) * 100);
                            persentagess.add(double.parse(
                                (currentValuePercentage.toInt() *
                                        heightOnePersentagee)
                                    .toString()));
                          }
                          return Container(
                            height: 25.w,
                            width: 85.w,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: yAxisData
                                        .map((e) => Text(
                                              e.toString(),
                                              style:
                                                  TextStyle(fontSize: 13.5.sp),
                                            ))
                                        .toList(),
                                  ),
                                  ..._.stepsList
                                      .map((e) => Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                AnimatedContainer(
                                                    duration: Duration(
                                                        milliseconds: 500),
                                                    height: ((e.steps /
                                                                yAxisData[0]) *
                                                            100) *
                                                        heightOnePersentagee,
                                                    width: 3.5.w,
                                                    color:
                                                        AppColors.primaryColor),
                                                SizedBox(
                                                  height: 4.w,
                                                  child: Text(
                                                    DateFormat('EEEE')
                                                        .format(e.date)
                                                        .substring(0, 1),
                                                    style: TextStyle(
                                                        fontSize: 14.sp),
                                                  ),
                                                )
                                              ])))
                                      .toList(),
                                ]),
                          );
                        })
                      ],
                    )),
        ],
      ),
    );
  }
}
