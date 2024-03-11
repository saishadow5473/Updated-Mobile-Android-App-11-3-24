import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:timelines/timelines.dart';

class DietJournalScore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DietJournalUI(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          key: Key('todaysIntakeBackButton'),
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            //  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            //   builder: (context) => HomeScreen(introDone: true,)),
            //       (Route<dynamic> route) => false);
            Get.off(LandingPage());
          },
        ),
        title: Text(
          "Calories",
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 30.0,
          ),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Today's target: ",
                    style: TextStyle(
                        fontSize: 20.0, color: AppColors.appTextColor, fontFamily: "Poppins"),
                  ),
                  TextSpan(
                    text: "800 Cal",
                    style: TextStyle(
                        color: AppColors.dietJournalOrange,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins"),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 25.0,
          ),
          SleekCircularSlider(
            appearance: CircularSliderAppearance(
                customColors: CustomSliderColors(
                  trackColor: AppColors.dietJournalFill,
                  progressBarColors: [Color(0xfffc6111), Color(0xfffec5a8)],
                  // progressBarColors: [Color(0xffFFC84B), Color(0xff00BFD5)],
                  dotColor: Colors.black,
                  dynamicGradient: true,
                ),
                customWidths: CustomSliderWidths(
                  progressBarWidth: 10,
                  trackWidth: 10,
                ),
                infoProperties: InfoProperties(
                  bottomLabelStyle: TextStyle(color: AppColors.appTextColor),
                  mainLabelStyle: TextStyle(fontFamily: "Poppins"),
                  topLabelStyle: TextStyle(
                    fontFamily: "Poppins",
                    color: AppColors.appTextColor,
                    fontSize: 20,
                  ),
                  topLabelText: '135 Cal',
                  bottomLabelText: 'Consumed',
                ),
                startAngle: 180,
                angleRange: 340),
            min: 0,
            max: 10,
            initialValue: 2,
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Color(0xffF4F6FA),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              child: Padding(
                padding: const EdgeInsets.only(left: 50.0, right: 20.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TimelineTheme(
                      data: TimelineThemeData(
                          color: AppColors.dietJournalOrange,
                          indicatorTheme: IndicatorThemeData(color: AppColors.dietJournalOrange),
                          connectorTheme: ConnectorThemeData(color: AppColors.dietJournalOrange)),
                      child: TimelineTile(
                        nodeAlign: TimelineNodeAlign.start,
                        contents: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ListTile(
                            leading: Icon(Icons.local_fire_department_outlined),
                            title: Text(
                              "Breakfast",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: AppColors.dietJournalOrange),
                            ),
                            subtitle: Text(
                              "100 Cal",
                              style: TextStyle(color: AppColors.greenColor),
                            ),
                          ),
                        ),
                        node: TimelineNode(
                          indicator: ContainerIndicator(
                            child: Icon(
                              // onChanged: (bool value) {}, value: true,
                              Icons.check_box, color: AppColors.dietJournalOrange, size: 30.0,
                            ),
                          ),
                          endConnector: DashedLineConnector(),
                        ),
                      ),
                    ),
                    TimelineTheme(
                      data: TimelineThemeData(
                          color: AppColors.dietJournalOrange,
                          indicatorTheme: IndicatorThemeData(color: AppColors.dietJournalOrange),
                          connectorTheme: ConnectorThemeData(color: AppColors.dietJournalOrange)),
                      child: TimelineTile(
                        nodeAlign: TimelineNodeAlign.start,
                        contents: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ListTile(
                            title: Text(
                              "Lunch",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: AppColors.dietJournalOrange),
                            ),
                            subtitle: Text(
                              "100 Cal",
                              style: TextStyle(color: AppColors.greenColor),
                            ),
                            leading: Icon(
                              Icons.local_fire_department_outlined,
                            ),
                          ),
                        ),
                        node: TimelineNode(
                          indicator: ContainerIndicator(
                              child: Icon(
                            // onChanged: (bool value) {}, value: true,
                            Icons.check_box, color: AppColors.dietJournalOrange, size: 30.0,
                          )),
                          startConnector: DashedLineConnector(),
                          endConnector: DashedLineConnector(),
                        ),
                      ),
                    ),
                    TimelineTheme(
                      data: TimelineThemeData(
                          color: AppColors.dietJournalOrange,
                          indicatorTheme: IndicatorThemeData(color: AppColors.dietJournalOrange),
                          connectorTheme: ConnectorThemeData(color: AppColors.dietJournalOrange)),
                      child: TimelineTile(
                        nodeAlign: TimelineNodeAlign.start,
                        contents: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ListTile(
                            title: Text(
                              "Dinner",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            subtitle: Text("0 Cal"),
                            leading: Icon(
                              Icons.local_fire_department_outlined,
                            ),
                          ),
                        ),
                        node: TimelineNode(
                          indicator: ContainerIndicator(
                              child: Icon(
                            // onChanged: (bool value) {}, value: false,
                            Icons.check_box_outline_blank, color: Colors.grey, size: 30.0,
                          )),
                          startConnector: DashedLineConnector(),
                          endConnector: DashedLineConnector(),
                        ),
                      ),
                    ),
                    TimelineTheme(
                      data: TimelineThemeData(
                          color: AppColors.dietJournalOrange,
                          indicatorTheme: IndicatorThemeData(color: AppColors.dietJournalOrange),
                          connectorTheme: ConnectorThemeData(color: AppColors.dietJournalOrange)),
                      child: TimelineTile(
                        nodeAlign: TimelineNodeAlign.start,
                        contents: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ListTile(
                            title: Text(
                              "Snacks",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            subtitle: Text("0 Cal"),
                            leading: Icon(
                              Icons.local_fire_department_outlined,
                            ),
                          ),
                        ),
                        node: TimelineNode(
                          indicator: ContainerIndicator(
                              child: Icon(
                            // onChanged: (bool value) {}, value: false,
                            Icons.check_box_outline_blank, color: Colors.grey, size: 30.0,
                          )),
                          startConnector: DashedLineConnector(),
                          endConnector: DashedLineConnector(),
                        ),
                      ),
                    ),
                    TimelineTheme(
                      data: TimelineThemeData(
                          color: AppColors.dietJournalOrange,
                          indicatorTheme: IndicatorThemeData(color: AppColors.dietJournalOrange),
                          connectorTheme: ConnectorThemeData(color: AppColors.dietJournalOrange)),
                      child: TimelineTile(
                        nodeAlign: TimelineNodeAlign.start,
                        contents: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ListTile(
                            title: Text(
                              "Extras",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            subtitle: Text("0 Cal"),
                            leading: Icon(
                              Icons.local_fire_department_outlined,
                            ),
                          ),
                        ),
                        node: TimelineNode(
                          indicator: ContainerIndicator(
                              child: Icon(
                            // onChanged: (bool value) {}, value: false,
                            Icons.check_box_outline_blank, color: Colors.grey, size: 30.0,
                          )),
                          startConnector: DashedLineConnector(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
