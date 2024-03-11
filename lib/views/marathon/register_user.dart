import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/repositories/marathon_event_api.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/marathon/marathon_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRegister extends StatefulWidget {
  UserRegister({this.eventDetailList});
  final eventDetailList;
  @override
  _UserRegisterState createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  // final marathonPlaces = ['Adayar', 'Chetpet', 'Indira Nagar', 'Tiruvanmiyur'];
  // = widget.eventDetailList[0]['event_location'];
  var marathonPlaces = [];
  var eventVariants = [];
  bool mPlaceSelected;
  var eventList = [];
  var varientValue;
  bool affWithPersistance = false;
  var persistentEmployeeId = '';
  @override
  void initState() {
    super.initState();
    getAffiliationDetail();
    marathonPlaces = widget.eventDetailList[0]['event_locations'];
    eventVariants = widget.eventDetailList[0]['event_varients'];
    eventList.add('');
    // eventList.add(varientValue);
    // for (var i = 0; i < eventVariants.length; i++) {
    //   eventList.add(eventVariants[i]['varient_name'] +
    //       ' starts at ' +
    //       eventVariants[i]['variant_start_location'] +
    //       ' Ends at ' +
    //       eventVariants[i]['variant_end_location']);
    //   print(eventList[i]);

    //   // print(eventVariants[i]);
    // }

    print(marathonPlaces);

    //print(eventVariants[0]['varient_name'].toString() +
    //  eventVariants[0]['variant_start_location'].toString());
    // print(eventVariants[1]['varient_name'].toString());
  }

  getAffiliationDetail() async {
    final prefs = await SharedPreferences.getInstance();
    var data = prefs.getString(SPKeys.userData);
    var decodedData = jsonDecode(data);
    Map enrolledAffiliationMap = decodedData['User']['user_affiliate'];

    if (enrolledAffiliationMap != null) {
      if (enrolledAffiliationMap.length > 0) {
        enrolledAffiliationMap.forEach((key, value) {
          if (value['affilate_name'] == 'Persistent Systems Limited') {
            setState(() {
              affWithPersistance = true;
            });
            if (affWithPersistance) {
              persistentEmployeeId = value['affliate_identifier_id'];
              _employeeIDController.text = value['affliate_identifier_id'];
            }
          }
        });
      } else {
        affWithPersistance = false;
      }
    } else {
      affWithPersistance = false;
    }
  }

  // final marathonTypes = [

  // ];
  final appTypes = [
    'hCare',
    'Others',
  ];
  final orgTypes = [
    'Persistent',
    'IHL',
    'Others',
  ];
  final eventSourcerTypes = [
    'Google',
    'Refered through friend',
    'Facebook',
    'Twitter',
    'LinkedIn',
    'WhatsApp',
    'Others'
  ];
  final deptTypes = ['Marketing', 'Sales', 'Development', 'Testing'];
  String kmValue;
  String orgValue = 'IHL';
  String deptValue = 'Marketing';
  String eventSourceValue;
  String placeValue;
  String appValue;
  String variantId;
  bool isMarathonTypeActive = true;
  TextEditingController _employeeIDController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  String event_type_hint = "Marathon type";
  String location_hint = "Start location";
  String empoloyee_hint = "Enter employee id";
  String app_hint = "To track the run";

  Color location_hint_color = Colors.black;
  var event_type_hint_color = Colors.black;
  var empoloyee_hint_color = Colors.black;
  var app_hint_color = Colors.black;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      // height: MediaQuery.of(context).size.height / 4,
      // width: MediaQuery.of(context).size.width / 2,
      // height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.primaryAccentColor,
      ),

      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryAccentColor,
          title: Text(
            'Registration Form',
            style: TextStyle(fontSize: ScUtil().setSp(16), fontWeight: FontWeight.w600),
          ),
          elevation: 0.0,
          centerTitle: true,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  height: ScUtil().setHeight(605),
                  // height: MediaQuery.of(context).size.height / 1.2,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: ScUtil().setHeight(5.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
                        child: Text(
                          'Location',
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: ScUtil().setSp(16)),
                        ),
                      ),
                      Container(
                        width: ScUtil().setWidth(450),
                        height: ScUtil().setHeight(58),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          child: TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                                labelText: location_hint,
                                labelStyle: TextStyle(
                                    color: location_hint_color, fontSize: ScUtil().setSp(16)),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2, color: Colors.blue),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2, color: Colors.blueAccent),
                                  borderRadius: BorderRadius.circular(15),
                                )),
                          ),
                        ),
                      ),

                      /*Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Container(
                            // width: MediaQuery.of(context).size.width / 1,
                            width: ScUtil().setWidth(450),
                            height: ScUtil().setHeight(40),
                            margin: EdgeInsets.all(1),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    width: 2, color: Colors.blueAccent)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<dynamic>(
                                hint: Text("Event location"),
                                isExpanded: true,
                                value: placeValue,
                                iconSize: 36,
                                items: marathonPlaces
                                    .map<DropdownMenuItem<dynamic>>(
                                        (placeValue) {
                                  return DropdownMenuItem<dynamic>(
                                    value: placeValue,
                                    child: Text(placeValue),
                                  );
                                }).toList(),
                                // ..map(
                                //   (buildPlacesItem),
                                // ),
                                onChanged: (placeValue) {
                                  SpUtil.putString(
                                      SPKeys.mPlaceSelected, placeValue);
                                  setState(() {
                                    eventList = [];
                                  });
                                  for (var i = 0;
                                      i < eventVariants.length;
                                      i++) {
                                    var startLoc = eventVariants[i]
                                            ['start_location']
                                        .toString();
                                    var varientValue = eventVariants[i]
                                            ['varient_name']
                                        .toString();
                                    if (placeValue == startLoc) {
                                      // eventList.add(
                                      //     eventVariants[i]['varient_name']);
                                      eventList.add(varientValue);
                                    }
                                    //print(eventList[i]);
                                    //print(eventVariants[i]);
                                  }
                                  if (this.mounted) {
                                    setState(() {
                                      variantId = variantId;
                                      eventList = eventList;
                                      this.placeValue = placeValue;
                                      isMarathonTypeActive = false;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),*/
                      // Marathon type starts
                      SizedBox(
                        height: ScUtil().setHeight(0.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
                        child: Text(
                          'Event Type',
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: ScUtil().setSp(16)),
                        ),
                      ),

                      Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Container(
                            // width: MediaQuery.of(context).size.width / 1,
                            width: ScUtil().setWidth(450),
                            height: ScUtil().setHeight(40),
                            margin: EdgeInsets.all(1),
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(width: 2, color: Colors.blueAccent)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<dynamic>(
                                hint: Text(
                                  event_type_hint,
                                  style: TextStyle(color: event_type_hint_color),
                                ),
                                isExpanded: true,
                                value: kmValue,
                                iconSize: 36,
                                items: eventVariants.map<DropdownMenuItem<dynamic>>((kmValue) {
                                  return DropdownMenuItem<dynamic>(
                                    value: kmValue,
                                    child: Text(kmValue.toString()),
                                  );
                                }).toList(),
                                // .map(
                                //   (buildMenuItem),
                                // )
                                // .toList(),
                                onChanged: (kmValue) {
                                  SpUtil.putString(SPKeys.mMarathonTypeSelected, kmValue);
                                  //setState(() => this.kmValue = kmValue);
                                  // for (var i = 0;
                                  //     i < eventVariants.length;
                                  //     i++) {
                                  //   var startLoc = eventVariants[i]
                                  //           ['start_location']
                                  //       .toString();
                                  //   var varientValue = eventVariants[i]
                                  //           ['varient_name']
                                  //       .toString();
                                  //   if (placeValue == startLoc &&
                                  //       varientValue == kmValue) {
                                  //     variantId =
                                  //         eventVariants[i]['variant_id'];
                                  //   }
                                  // }
                                  setState(() {
                                    variantId = variantId;
                                    this.kmValue = kmValue;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      // // Marathon type ends
                      // user IHL app or others starts
                      SizedBox(
                        height: ScUtil().setHeight(0.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
                        child: Text(
                          'App',
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: ScUtil().setSp(16)),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Container(
                            // width: MediaQuery.of(context).size.width / 1,
                            width: ScUtil().setWidth(450),
                            height: ScUtil().setHeight(40),
                            margin: EdgeInsets.all(1),
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(width: 2, color: Colors.blueAccent)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: Text(
                                  app_hint,
                                  style: TextStyle(color: app_hint_color),
                                ),
                                isExpanded: true,
                                value: appValue,
                                iconSize: 36,
                                items: appTypes
                                    .map(
                                      (buildAppItem),
                                    )
                                    .toList(),
                                onChanged: (appValue) {
                                  SpUtil.putString(SPKeys.mAppTypeSelected, appValue);
                                  setState(() => this.appValue = appValue);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      // user IHL app or others end
                      // Organization starts
                      SizedBox(
                        height: ScUtil().setHeight(0.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
                        child: Text(
                          'Organization',
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: ScUtil().setSp(16)),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Container(
                            // width: MediaQuery.of(context).size.width / 1,
                            width: ScUtil().setWidth(450),
                            height: ScUtil().setHeight(40),
                            margin: EdgeInsets.all(1),
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(width: 2, color: Colors.blueAccent)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: orgValue,
                                  iconSize: 36,
                                  items: orgTypes
                                      .map(
                                        (buildOrgItem),
                                      )
                                      .toList(),
                                  onChanged: !affWithPersistance
                                      ? (orgValue) {
                                          if (affWithPersistance) {
                                            setState(() {
                                              this.orgValue = 'Persistent';
                                            });
                                          } else {
                                            SpUtil.putString(SPKeys.mOrgTypeSelected, orgValue);
                                            setState(() {
                                              this.orgValue = orgValue;
                                              if (orgValue == "Others") {
                                                eventSourceValue = "Google";
                                              } else {
                                                eventSourceValue = null;
                                              }
                                            });
                                          }
                                        }
                                      : null),
                            ),
                          ),
                        ),
                      ),
                      // Organization starts
                      // Department starts
                      SizedBox(
                        height: ScUtil().setHeight(0.5),
                      ),
                      orgValue != "Others"
                          ? Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18.0, vertical: 10.0),
                                    child: Text(
                                      'Department',
                                      style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScUtil().setSp(16)),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 10),
                                          child: Container(
                                            // width: MediaQuery.of(context).size.width / 1,
                                            width: ScUtil().setWidth(450),
                                            height: ScUtil().setHeight(40),
                                            margin: EdgeInsets.all(1),
                                            padding:
                                                EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                border:
                                                    Border.all(width: 2, color: Colors.blueAccent)),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: deptValue,
                                                iconSize: 36,
                                                items: deptTypes
                                                    .map(
                                                      (buildDeptItem),
                                                    )
                                                    .toList(),
                                                onChanged: (deptValue) => setState(() {
                                                  SpUtil.putString(
                                                      SPKeys.mDeptTypeSelected, deptValue);
                                                  return this.deptValue = deptValue;
                                                }),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: ScUtil().setWidth(450),
                                        height: ScUtil().setHeight(58),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 10.0),
                                          child: TextFormField(
                                            controller: _employeeIDController,
                                            decoration: InputDecoration(
                                                labelText: empoloyee_hint,
                                                labelStyle: TextStyle(
                                                    color: empoloyee_hint_color,
                                                    fontSize: ScUtil().setSp(16)),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide:
                                                      BorderSide(width: 2, color: Colors.blue),
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 2, color: Colors.blueAccent),
                                                  borderRadius: BorderRadius.circular(15),
                                                )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Department ends
                                ],
                              ),
                            )
                          :

                          // other starts
                          SizedBox(
                              height: ScUtil().setHeight(0.5),
                            ),
                      orgValue == 'Others'
                          ? Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18.0, vertical: 10.0),
                                    child: Text(
                                      // 'Event source you come to know',
                                      'How you came to know about the Event?',
                                      style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScUtil().setSp(16)),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 10),
                                          child: Container(
                                            // width: MediaQuery.of(context).size.width / 1,
                                            width: ScUtil().setWidth(450),
                                            height: ScUtil().setHeight(40),
                                            margin: EdgeInsets.all(1),
                                            padding:
                                                EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                border:
                                                    Border.all(width: 2, color: Colors.blueAccent)),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: eventSourceValue,
                                                iconSize: 36,
                                                items: eventSourcerTypes
                                                    .map(
                                                      (buildOtherItem),
                                                    )
                                                    .toList(),
                                                onChanged: (eventSourceValue) => setState(() {
                                                  SpUtil.putString(SPKeys.mEventSourceSelected,
                                                      eventSourceValue);
                                                  return this.eventSourceValue = eventSourceValue;
                                                }),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // other ends
                                      SizedBox(
                                        height: 50,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Container(),

                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            // primary: Colors.green.withOpacity(1),
                            // primary: AppColors.primaryColor,
                            primary: AppColors.primaryAccentColor,
                            textStyle: TextStyle(
                                fontSize: ScUtil().setSp(14), fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            var temp_bool = false;
                            if (orgValue == "Persistent" || orgValue == "IHL") {
                              if (_employeeIDController.text == null ||
                                  _employeeIDController.text == "") {
                                temp_bool = true;
                              }
                            }
                            if (_locationController.text != null &&
                                _locationController.text != "" &&
                                kmValue != null &&
                                kmValue != "" &&
                                appValue != null &&
                                appValue != "" &&
                                temp_bool == false) {
                              SharedPreferences prefs = await SharedPreferences.getInstance();

                              var data = prefs.get(SPKeys.userData);
                              Map res = jsonDecode(data);
                              var gender = res['User']['gender'];
                              if (gender == "m" ||
                                  gender == "M" ||
                                  gender == "male" ||
                                  gender == "Male") {
                                gender = "male";
                              }
                              if (gender == "f" ||
                                  gender == "F" ||
                                  gender == "female" ||
                                  gender == "Female") {
                                gender = "female";
                              }
                              var name = prefs.getString('name');
                              var responce = await marathonRegisterUser(
                                  varientSelected: kmValue,
                                  employeeId: _employeeIDController.text,
                                  // locationSelected: placeValue,
                                  locationSelected: _locationController.text,
                                  organization: orgValue,
                                  otherSource: eventSourceValue,
                                  usingIhlapp: appValue,
                                  // eventName: 'Persisitent',
                                  eventName:
                                      '${widget.eventDetailList[0]['event_name'].toString()}',
                                  age: '38',
                                  eventId: '${widget.eventDetailList[0]['event_id'].toString()}',
                                  eventStatus: 'enrolled',
                                  gender: gender,
                                  pathCount: '0',
                                  userName: name,
                                  varientId: variantId);
                              if (responce == '"user successfully enrolled"') {
                                var prefs = await SharedPreferences.getInstance();
                                prefs.setString('event_seconds', '0');
                                prefs.setString('event_distance', '0');
                                prefs.setString('event_steps', '0');
                                prefs.setString('event_status', '');
                                hoursStr = ValueNotifier<int>(0);
// String minutesStr = '00';
                                minutesStr = ValueNotifier<int>(0);
// String secondsStr = '00';
                                secondsStr = ValueNotifier<int>(0);
// String onPauseHoursStr = '00';
                                onPauseHoursStr = ValueNotifier<int>(0);
// String onPauseMinutesStr = '00';
                                onPauseMinutesStr = ValueNotifier<int>(0);
// String onPauseSecondsStr = '00';
                                onPauseSecondsStr = ValueNotifier<int>(0);
                                todaySteps = ValueNotifier<int>(0);
                                isCalled = false;
                                // pauseDur;
                                // storedDur;
                                pauseValue = true;
                                stopValue = false;
                                flag = true;
                                onPauseAvailable = false;

                                AwesomeDialog(
                                    context: context,
                                    animType: AnimType.TOPSLIDE,
                                    headerAnimationLoop: true,
                                    dialogType: DialogType.SUCCES,
                                    dismissOnTouchOutside: true,
                                    title: 'Success!',
                                    desc: 'Registration Successful!',
                                    dismissOnBackKeyPress: false,

                                    //                               String kmValue = '10 KM Mini Marathon at 7 AM';
                                    // String orgValue = 'Persistent';
                                    // String deptValue = 'Marketing';
                                    // String eventSourceValue = 'Google';
                                    // String placeValue = 'Adayar';
                                    // String appValue = 'IHL Care';

                                    btnOkOnPress: () async {
                                      // Get.offAll(HomeScreen(introDone: true));
                                      await MyvitalsApi().vitalDatas({});
                                      Get.offAll(LandingPage());
                                    },
                                    btnOkText: 'Proceed',
                                    btnOkIcon: Icons.check_circle,
                                    onDismissCallback: (_) {
                                      debugPrint('Dialog Dissmiss from callback');
                                    }).show();
                              }
                            } else {}
                            if (_locationController.text == null ||
                                _locationController.text == "") {
                              setState(() {
                                location_hint = "location is empty";
                                location_hint_color = Colors.red;
                              });
                            } else {
                              setState(() {
                                location_hint = "Start location";
                                location_hint_color = Colors.black;
                              });
                            }
                            if (kmValue == null || kmValue == "") {
                              setState(() {
                                event_type_hint = "select type";
                                event_type_hint_color = Colors.red;
                              });
                            } else {
                              setState(() {
                                event_type_hint = "Marathon type";
                                event_type_hint_color = Colors.black;
                              });
                            }
                            if (appValue == null || appValue == "") {
                              setState(() {
                                app_hint = "select an app";
                                app_hint_color = Colors.red;
                              });
                            } else {
                              setState(() {
                                app_hint = "to Track the run";
                                app_hint_color = Colors.black;
                              });
                            }
                            if (_employeeIDController.text == null ||
                                _employeeIDController.text == "") {
                              setState(() {
                                empoloyee_hint = "employee id is empty";
                                empoloyee_hint_color = Colors.red;
                              });
                            } else {
                              setState(() {
                                empoloyee_hint = "Enter employee id";
                                empoloyee_hint_color = Colors.black;
                              });
                            }
                          },
                          child: Text(
                            '  Submit  ',
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 1.5,
                                fontSize: ScUtil().setSp(16)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(
              // fontWeight: FontWeight.bold,
              fontSize: ScUtil().setSp(16),
              color: Colors.blueAccent),
        ),
      );

  DropdownMenuItem<String> buildOrgItem(String orgItem) => DropdownMenuItem(
        value: orgItem,
        child: Text(
          orgItem,
          style: TextStyle(
              // fontWeight: FontWeight.bold,
              fontSize: ScUtil().setSp(16),
              color: Colors.blueAccent),
        ),
      );

  DropdownMenuItem<String> buildAppItem(String appItem) => DropdownMenuItem(
        value: appItem,
        child: Text(
          appItem,
          style: TextStyle(
              // fontWeight: FontWeight.bold,
              fontSize: ScUtil().setSp(16),
              color: Colors.blueAccent),
        ),
      );

  DropdownMenuItem<String> buildDeptItem(String deptItem) => DropdownMenuItem(
        value: deptItem,
        child: Text(
          deptItem,
          style: TextStyle(
              // fontWeight: FontWeight.bold,
              fontSize: ScUtil().setSp(16),
              color: Colors.blueAccent),
        ),
      );
  DropdownMenuItem<String> buildOtherItem(String otherItem) => DropdownMenuItem(
        value: otherItem,
        child: Text(
          otherItem,
          style: TextStyle(
              // fontWeight: FontWeight.bold,
              fontSize: ScUtil().setSp(16),
              color: Colors.blueAccent),
        ),
      );

  DropdownMenuItem<String> buildPlacesItem(String placeItem) => DropdownMenuItem(
        value: placeItem,
        child: Text(
          placeItem,
          style: TextStyle(
              // fontWeight: FontWeight.bold,
              fontSize: ScUtil().setSp(16),
              color: Colors.blueAccent),
        ),
      );
}
