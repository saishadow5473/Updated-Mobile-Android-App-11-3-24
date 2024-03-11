import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/customicons_icons.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/teleconsultation/specialityType.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MySubscription.dart';

class WellnessCart extends StatefulWidget {
  WellnessCart({this.backNav});
  final bool backNav;

  @override
  _WellnessCartState createState() => _WellnessCartState();
}

class _WellnessCartState extends State<WellnessCart> {
  http.Client _client = http.Client(); //3gb
  var platformData;
  Map res;
  Map fitnessClassSpecialties;
  bool requestError = false;
  bool loading = true;

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data1 = prefs.get('data');
    Map res1 = jsonDecode(data1);
    var iHLUserId = res1['User']['id'];
    final getPlatformData = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/GetPlatfromData"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, String>{'ihl_id': iHLUserId, 'cache': "true"}),
    );
    if (getPlatformData.statusCode == 200) {
      if (getPlatformData.body != null) {
        prefs.setString(SPKeys.platformData, getPlatformData.body);
        res = jsonDecode(getPlatformData.body);
        setState(() {
          loading = false;
        });
      }
    } else {
      setState(() {
        requestError = true;
      });
      print(getPlatformData.body);
    }

    //platformData = prefs.get(SPKeys.platformData);

    if (res['consult_type'] == null ||
        !(res['consult_type'] is List) ||
        res['consult_type'].isEmpty) {
      return;
    }

    fitnessClassSpecialties = res['consult_type'][1];
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  /// list of options in wellness cart 🚃🚃🚃
  final List<Map> options = [
    {
      'text': 'Subscription',
      'icon': FontAwesomeIcons.solidBell,
      'iconSize': 40.0,
      'onTap': (BuildContext context) {
        Navigator.of(context).pushNamed(Routes.MySubscriptions, arguments: false);
      },
      'color': AppColors.subscription
    },
    {
      'text': 'Wellness cart ',
      'icon': Customicons.fitness_class,
      'iconSize': 170.0,
      'onTap': (BuildContext context) {
        Navigator.of(context).pushNamed(Routes.ConsultationType, arguments: null);
      },
      'color': AppColors.onlineClass,
    },
  ];

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: WillPopScope(
        onWillPop: () => Get.to(LandingPage()),
        child: BasicPageUI(
          appBar: Column(
            children: [
              SizedBox(
                width: ScUtil().setWidth(20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Get.off(LandingPage());
                    }, //replaces the screen to Main dashboard
                    color: Colors.white,
                  ),
                  Text(
                    'Health E-Market',
                    style: TextStyle(color: Colors.white, fontSize: ScUtil().setSp(24.0)),
                  ),
                  SizedBox(
                    width: ScUtil().setWidth(40),
                  )
                ],
              ),
              SizedBox(
                height: ScUtil().setHeight(20),
              )
            ],
          ),
          body: loading
              ? Center(
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 70),
                child: CircularProgressIndicator()),
          )
              : requestError
              ? Column(
            children: [
              Lottie.asset('assets/error.json', height: 300, width: 300),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Connection failed ! Please try after some time...",
                      style: TextStyle(fontSize: 18.0, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            ],
          )
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height /
                          1.2, // bottom white space fot the teledashboard
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(2.5),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              // color: AppColors.cardColor,
                              color: FitnessAppTheme.white,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15.0),
                                onTap: () {
                                  Get.to(MySubscription(
                                    afterCall: false,
                                  ));
                                  // Navigator.of(context).pushNamed(Routes.MySubscriptions,
                                  //     arguments: false);
                                },
                                splashColor: AppColors.subscription.withOpacity(0.5),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: ScUtil().setHeight(3.0),
                                      ),
                                      Center(
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.all(11.0),
                                              height: ScUtil().setHeight(60.0),
                                              width: ScUtil().setWidth(50.0),
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Icon(
                                                FontAwesomeIcons.solidBell,
                                                color: AppColors.subscription,
                                                size: 40.0,
                                              ),
                                            ),
                                            SizedBox(
                                              width: ScUtil().setWidth(30.0),
                                            ),
                                            Text(
                                              'Subscription',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                //fontWeight: FontWeight.w600,
                                                fontSize: 20,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: ScUtil().setHeight(3.0),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.5),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              // color: AppColors.cardColor,
                              color: FitnessAppTheme.white,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15.0),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SpecialityTypeScreen(
                                          arg: fitnessClassSpecialties),
                                    ),
                                  );
                                },
                                splashColor: AppColors.onlineClass.withOpacity(0.5),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: ScUtil().setHeight(3.0),
                                      ),
                                      Center(
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.all(11.0),
                                              height: ScUtil().setHeight(60.0),
                                              width: ScUtil().setWidth(50.0),
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Icon(
                                                Customicons.fitness_class,
                                                color: AppColors.onlineClass,
                                                size: 170.0,
                                              ),
                                            ),
                                            SizedBox(
                                              width: ScUtil().setWidth(30.0),
                                            ),
                                            Text(
                                              'Health E-Market',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                //fontWeight: FontWeight.w600,
                                                fontSize: 20,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: ScUtil().setHeight(3.0),
                                      ),
                                    ]),
                              ),
                            ),
                          )
                        ],
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
