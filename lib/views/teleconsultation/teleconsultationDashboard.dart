import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:ihl/widgets/teleconsulation/dashboardCards.dart';
import 'package:ihl/widgets/teleconsulation/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/constants/routes.dart';
import 'package:flutter_icons/flutter_icons.dart';

class TeleDashboard extends StatefulWidget {
  TeleDashboard({Key key}) : super(key: key);

  @override
  _TeleDashboardState createState() => _TeleDashboardState();
}

class _TeleDashboardState extends State<TeleDashboard> {
  List<Icon> _icons = [
    Icon(FlutterIcons.user_md_faw),
  ];

  bool hide = false;
  int show = 2;
  String name = 'User';
  final List<Map> options = [
    {
      'text': AppTexts.teleConDashboardNow,
      'icon': FontAwesomeIcons.video,
      'onTap': (BuildContext context) {
        Navigator.of(context).pushNamed(Routes.ConsultationType, arguments: true);
      },
      'color': AppColors.startConsult,
    },
    {
      'text': AppTexts.teleConDashboardBook,
      'icon': FontAwesomeIcons.calendarAlt,
      'onTap': (BuildContext context) {
        Navigator.of(context).pushNamed(Routes.ConsultationType, arguments: false);
      },
      'color': AppColors.myConsultant,
    },
    {
      'text': AppTexts.teleConDashboardMySubscriptions,
      'icon': FontAwesomeIcons.bell,
      'onTap': (BuildContext context) {
        Navigator.of(context).pushNamed(Routes.MySubscriptions, arguments: false);
      },
      'color': AppColors.orangeAccent
    },
    {
      'text': AppTexts.teleConDashboardMyAppointment,
      'icon': FontAwesomeIcons.calendarCheck,
      'onTap': (BuildContext context) {
        Navigator.of(context).pushNamed(Routes.MyAppointments);
      },
      'color': AppColors.bookApp,
    },
    {
      'text': AppTexts.teleConDashboardFollowUp,
      'icon': FontAwesomeIcons.retweet,
      'onTap': (BuildContext context) {
        Navigator.of(context).pushNamed(Routes.Followup);
      },
      'color': AppColors.followUp,
    },
    {
      'text': AppTexts.teleConDashboardMyConsultant,
      'icon': FontAwesomeIcons.userMd,
      'onTap': (BuildContext context) {
        Navigator.of(context).pushNamed(Routes.MyConsultant);
      },
      'color': AppColors.myApp,
    },
    {
      'text': AppTexts.teleConDashboardHistory,
      'icon': FontAwesomeIcons.history,
      'onTap': (BuildContext context) {
        Navigator.of(context).pushNamed(Routes.MyAppointments);
      },
      'color': AppColors.history,
    },
    {
      'text': AppTexts.teleConDashboardFiles,
      'icon': FontAwesomeIcons.file,
      'onTap': (BuildContext context) {
        Navigator.of(context).pushNamed(Routes.MyMedicalFiles);
      },
      'color': AppColors.medicalFiles,
    },
  ];

  void getDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    Map res = jsonDecode(data);
    if (this.mounted) {
      setState(() {
        name = res['User']['firstName'] ?? 'User';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: BasicPageUI(
        appBar: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
              title: Text(
                AppTexts.teleConDashboardTitle,
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(Routes.Home, arguments: true),
                color: Colors.white,
                tooltip: 'Back',
              ),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.ConsultSummary);
                  },
                  child: Icon(
                    FluentSystemIcons.ic_fluent_alert_regular,
                    size: 24,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: <Widget>[
                    Text("Hi, " + name + " 😊",
                        style: TextStyle(
                            color: Color(0xff6d6e71), fontSize: 22, fontWeight: FontWeight.bold)),
                    Spacer(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: <Widget>[
                    Text("What are you looking out for ?",
                        style: TextStyle(
                            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    Spacer(),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 45.0,
                margin: EdgeInsets.symmetric(horizontal: 18.0),
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: Colors.black.withOpacity(.2)),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search, color: Colors.black),
                    hintText: "Search doctor, categories, classes . . . .",
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(.4),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 150.0,
                child: ListView.builder(
                  itemCount: consultationList.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    var item = consultationList[index];
                    return ConsultationCard(consultation: item, index: index);
                  },
                ),
              ),
              hide == false
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        children: <Widget>[
                          Text("Upcoming Consult",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                          Spacer(),
                          InkWell(
                            onTap: () async {
                              if (this.mounted) {
                                setState(() {
                                  hide = true;
                                });
                              }
                            },
                            child:
                                Text("Hide", style: TextStyle(color: Colors.black, fontSize: 14)),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              hide == false ? MyUpcomingAppointments() : Container(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  children: <Widget>[
                    Text("Our Top services",
                        style: TextStyle(
                            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewallTeleDashboard()),
                        );
                      },
                      child: Text("View all", style: TextStyle(color: Colors.black, fontSize: 14)),
                    ),
                  ],
                ),
              ),
              Container(
                height: 320,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  primary: false,
                  shrinkWrap: true,
                  itemCount: options.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          (MediaQuery.of(context).orientation == Orientation.portrait) ? 2 : 3),
                  itemBuilder: (BuildContext context, int index) {
                    return card(
                      context,
                      options[index]['text'],
                      options[index]['icon'],
                      options[index]['iconSize'],
                      options[index]['color'],
                      () {
                        options[index]['onTap'](context);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  children: <Widget>[
                    Text("Past Appointments",
                        style: TextStyle(
                            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.MyAppointments);
                      },
                      child: Text("View all", style: TextStyle(color: Colors.black, fontSize: 14)),
                    ),
                  ],
                ),
              ),
              PastAppointments(),
            ],
          ),
        ),
      ),
    );
  }
}
