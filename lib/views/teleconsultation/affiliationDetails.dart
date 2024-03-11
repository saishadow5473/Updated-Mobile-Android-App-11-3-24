import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/customicons_icons.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/health_challenge/views/health_challenges_types.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/affiliation/selectClassesForAffiliation.dart';
import 'package:ihl/views/affiliation/selectConsultantForAffiliation.dart';
import 'package:ihl/views/screens.dart';
import 'package:ihl/views/teleconsultation/mySubscriptions.dart';
import 'package:ihl/views/teleconsultation/new_speciality_type_screen.dart';
import 'package:ihl/views/teleconsultation/specialityType.dart';
import 'package:ihl/widgets/teleconsulation/dashboardCards.dart';
import 'package:ihl/widgets/teleconsulation/svgCards.dart';
import 'package:ihl/widgets/toc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../affiliation/class_and_consultants_screen.dart';
import 'MySubscription.dart';

class Details extends StatefulWidget {
  final String affiliationName;
  final String companyName;
  final logo;

  Details({Key key, this.companyName, this.logo, this.affiliationName}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  http.Client _client = http.Client(); //3gb
  bool wellnessCartVisible = false;
  // bool teleConVisible = false;
  bool teleConVisible = true;

  ///always visible
  bool isDiagnostic = false;
  bool isCorporateWellness = false;
  bool isPersistent = false;
  bool clickLoading = false;
  String affiliation = "";

  var platformData;
  Map res;
  Map fitnessClassSpecialties;
  Map healthConsultation;
  Map medicalConsultation;

  Future getPlatformUpdate() async {
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
        return res;
      }
    } else {
      platformData = prefs.get(SPKeys.platformData);
      var re = jsonDecode(platformData);
      return re;
      // print(getPlatformData.body);
    }
  }

  List specialty;
  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // platformData = prefs.get(SPKeys.platformData);
    //
    // res = jsonDecode(platformData);
    res = await getPlatformUpdate();
    if (this.mounted) {
      setState(() {
        platformDataLoading = false;
      });
    }
    if (res['consult_type'] == null ||
        !(res['consult_type'] is List) ||
        res['consult_type'].isEmpty) {
      return;
    }

    fitnessClassSpecialties = res['consult_type'][1];

    healthConsultation = res['consult_type'][2];
    medicalConsultation = res['consult_type'][0];

    specialty = fitnessClassSpecialties['specality'];
    var courses = []..length = specialty.length;

    var consultantListSpecialty = healthConsultation['specality'];

    var consultants = []..length = consultantListSpecialty.length;
    var medicalListSpeciality = medicalConsultation['specality'];
    var doctors = []..length = medicalListSpeciality.length;

    for (int i = 0; i < specialty.length; i++) {
      courses[i] = specialty[i]['courses'];
    }

    for (int i = 0; i < consultantListSpecialty.length; i++) {
      consultants[i] = consultantListSpecialty[i]['consultant_list'];
    }
    for (int i = 0; i < medicalListSpeciality.length; i++) {
      doctors[i] = medicalListSpeciality[i]['consultant_list'];
    }

    var affiliatedCourses = [];
    // List<List<dynamic>> affiliationArrayMap = [];
    // var affiliationArray = [];

    var flat = courses.expand((i) => i).toList();

    // for(int i = 0; i < flat.length; i++) {
    //     if (flat[i]['affilation_excusive_data'] != null) {
    //       if (flat[i]['affilation_excusive_data'].length != 0) {
    //         if (flat[i]['affilation_excusive_data']['affilation_array'].length != 0) {
    //           affiliatedCourses.add(flat[i]);
    //         }
    //       }
    //     }
    // }

    for (int i = 0; i < flat.length; i++) {
      if (flat[i]['affilation_excusive_data'] != null) {
        if (flat[i]['affilation_excusive_data'].length != 0) {
          if (flat[i]['affilation_excusive_data']['affilation_array'].length != 0) {
            affiliatedCourses.add(flat[i]);
          }
        }
      }
    }

    // print(affiliatedCourses);
    var affCourses = [];

    if (affiliatedCourses.length != 0) {
      List newList = [];
      List newList1 = [];

      for (int i = 0; i < affiliatedCourses.length; i++) {
        var affiliationArray = [];
        affiliationArray.add(affiliatedCourses[i]['affilation_excusive_data']['affilation_array']);

        var affFlatCourses = affiliationArray.expand((i) => i).toList();

        newList =
            affFlatCourses?.map((m) => m != null ? m['affilation_unique_name'] : "")?.toList() ??
                [];

        newList1 =
            affFlatCourses?.map((m) => m != null ? m['affilation_name'] : "")?.toList() ?? [];

        if (newList.contains(widget.companyName) || newList1.contains(widget.companyName)) {
          affCourses.add(affiliatedCourses[i]);
          if (mounted) {
            setState(() {
              affiliationArray.clear();
              newList.clear();
              newList1.clear();
            });
          }
        } else {
          affiliationArray.clear();
          if (mounted) {
            setState(() {
              newList.clear();
              newList1.clear();
            });
          }
        }
      }
    }

    if (affCourses.isNotEmpty) {
      if (mounted) {
        setState(() {
          wellnessCartVisible = true;
        });
      }
    }

    if (widget.companyName == "purva_highlands" ||
        widget.companyName == "chartered_beveraly_hills") {
      if (this.mounted) {
        setState(() {
          isDiagnostic = true;
        });
      }
    }
    if (widget.companyName == "ihl_care" || widget.companyName == "IHL CARE") {
      if (this.mounted) {
        setState(() {
          isCorporateWellness = true;
        });
      }
    }
    if (widget.companyName == "persistent" || widget.companyName == "Persistent") {
      if (this.mounted) {
        setState(() {
          isPersistent = true;
        });
      }
    }

    //  for(int i=0; i<affiliatedCourses.length; i++) {
    //    affiliationArray.add(affiliatedCourses[i]['affilation_excusive_data']['affilation_array']);
    //    affiliationArrayMap.add(affiliationArray[i]);
    //  }
    //
    //  var affiliationMap = affiliationArrayMap.asMap();
    //
    // print(affiliationMap);
    //
    //  for(var i=0; i<affiliatedCourses.length; i++) {
    //    if (affiliationMap[i][0]['affilation_unique_name'] == widget.companyName) {
    //      setState(() {
    //        wellnessCartVisible = true;
    //      });
    //    }
    //  }

    var affiliatedConsultants = [];

    var flatList = consultants.expand((i) => i).toList();
    print(flatList);

    // for(int i=0; i<flatList.length; i++) {
    //   if(flatList[i]['affilation_excusive_data'] != null) {
    //     if(flatList[i]['affilation_excusive_data'].length != 0) {
    //       if (flatList[i]['affilation_excusive_data']['affilation_array'].length != 0) {
    //         affiliatedConsultants.add(flatList[i]);
    //       }
    //     }
    //   }
    // }

    for (int i = 0; i < flatList.length; i++) {
      if (flatList[i]['affilation_excusive_data'] != null) {
        if (flatList[i]['affilation_excusive_data'].length != 0) {
          if (flatList[i]['affilation_excusive_data']['affilation_array'].length != 0) {
            affiliatedConsultants.add(flatList[i]);
          }
        }
      }
    }

    var affConsultants = [];
    var affiliationArray = [];

    if (affiliatedConsultants.length != 0) {
      List<dynamic> newList = [];
      List<dynamic> newList1 = [];

      for (int i = 0; i < affiliatedConsultants.length; i++) {
        affiliationArray
            .add(affiliatedConsultants[i]['affilation_excusive_data']['affilation_array']);

        var affFlatConsultants = affiliationArray.expand((i) => i).toList();

        newList = affFlatConsultants
                ?.map((m) => m != null ? m['affilation_unique_name'] : "")
                ?.toList() ??
            [];

        newList1 =
            affFlatConsultants?.map((m) => m != null ? m['affilation_name'] : "")?.toList() ?? [];

        if (newList.contains(widget.companyName) || newList1.contains(widget.companyName)) {
          affConsultants.add(affiliatedConsultants[i]);
          if (mounted)
            setState(() {
              affiliationArray.clear();
              newList.clear();
              newList1.clear();
            });
        } else {
          affiliationArray.clear();
          setState(() {
            newList.clear();
            newList1.clear();
          });
        }
      }
    }

    if (affConsultants.isNotEmpty) {
      setState(() {
        teleConVisible = true;
      });
    }

    var affiliatedDoctors = [];

    var flatDocList = doctors.expand((i) => i).toList();
    print(flatDocList);

    // for(int i=0; i<flatList.length; i++) {
    //   if(flatList[i]['affilation_excusive_data'] != null) {
    //     if(flatList[i]['affilation_excusive_data'].length != 0) {
    //       if (flatList[i]['affilation_excusive_data']['affilation_array'].length != 0) {
    //         affiliatedConsultants.add(flatList[i]);
    //       }
    //     }
    //   }
    // }

    for (int i = 0; i < flatDocList.length; i++) {
      if (flatDocList[i]['affilation_excusive_data'] != null) {
        if (flatDocList[i]['affilation_excusive_data'].length != 0) {
          if (flatDocList[i]['affilation_excusive_data']['affilation_array'].length != 0) {
            affiliatedDoctors.add(flatDocList[i]);
          }
        }
      }
    }

    var affdoctors = [];
    var affiliationMedicalArray = [];

    if (affiliatedDoctors.length != 0) {
      List<dynamic> newList = [];
      List<dynamic> newList1 = [];

      for (int i = 0; i < affiliatedDoctors.length; i++) {
        affiliationMedicalArray
            .add(affiliatedDoctors[i]['affilation_excusive_data']['affilation_array']);

        var affFlatDoctors = affiliationMedicalArray.expand((i) => i).toList();

        newList =
            affFlatDoctors?.map((m) => m != null ? m['affilation_unique_name'] : "")?.toList() ??
                [];

        newList1 =
            affFlatDoctors?.map((m) => m != null ? m['affilation_name'] : "")?.toList() ?? [];

        if (newList.contains(widget.companyName) || newList1.contains(widget.companyName)) {
          affdoctors.add(affiliatedDoctors[i]);
          setState(() {
            affiliationMedicalArray.clear();
            newList.clear();
            newList1.clear();
          });
        } else {
          affiliationMedicalArray.clear();
          setState(() {
            newList.clear();
            newList1.clear();
          });
        }
      }
    }

    if (affdoctors.isNotEmpty) {
      setState(() {
        teleConVisible = true;
      });
    }

    // for(int i=0; i<affiliatedConsultants.length; i++) {
    //   affiliationArrayConsultants.add(affiliatedConsultants[i]['affilation_excusive_data']['affilation_array']);
    //   affiliationArrayMapConsultants.add(affiliationArrayConsultants[i]);
    // }
    //
    // var affiliationMapConsultants = affiliationArrayMapConsultants.asMap();
    //
    // for(var i=0; i<affiliatedConsultants.length; i++) {
    //   if (affiliationMapConsultants[i][0]['affilation_unique_name'] == widget.companyName) {
    //     setState(() {
    //       teleConVisible = true;
    //     });
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
    getData();
    if (widget.affiliationName == null) {
      setState(() {
        affiliation = "Affiliation";
      });
    } else {
      setState(() {
        affiliation = widget.affiliationName;
      });
    }
  }

  var platformDataLoading = true;
  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: <Widget>[
            CustomPaint(
              painter: BackgroundPainter(
                primary: AppColors.primaryColor.withOpacity(0.7),
                secondary: AppColors.primaryColor.withOpacity(0.0),
              ),
              child: Container(),
            ),
            SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BackButton(
                //   key: Key('affiliationServicesBackButton'),
                //   color: Colors.white,
                // ),
                IconButton(
                  key: Key('affiliationServicesBackButton'),
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context);
                  }, //replaces the screen to Main dashboard
                  color: Colors.white,
                ),
                Flexible(
                  child: Center(
                    child: Text(
                      affiliation.replaceAll('Persistent', 'My Life At Persistent'),
                      style: TextStyle(color: Colors.white, fontSize: ScUtil().setSp(24)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                )
              ],
            ),
            CircleAvatar(
              backgroundColor: Colors.transparent,
              // AppColors.primaryColor.withOpacity(0.2),
              radius: 50.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image(image: NetworkImage(widget.logo ?? "")),
              ),
            ),
            platformDataLoading == false
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: platformDataLoading == false
                                  ? ListView(
                                      children: <Widget>[
                                        ...specialty.map<Widget>((e) {
                                          if ((e['specality_name'] == "Physical Wellbeing" ||
                                              e['specality_name'] == "Emotional Wellbeing" ||
                                              e['specality_name'] == "Financial Wellbeing" ||
                                              e['specality_name'] == "Social Wellbeing"))
                                            return Visibility(
                                              visible: false,
                                              child: svgCard(
                                                context,
                                                e['specality_name'],
                                                e['specality_name'] == "Physical Wellbeing"
                                                    ? 'assets/svgs/Physical Wellbeing.svg'
                                                    : e['specality_name'] == "Emotional Wellbeing"
                                                        ? 'assets/svgs/Emotional Wellbeing.svg'
                                                        : e['specality_name'] ==
                                                                "Financial Wellbeing"
                                                            ? 'assets/svgs/Financial Wellbeing.svg'
                                                            : e['specality_name'] ==
                                                                    "Social Wellbeing"
                                                                ? 'assets/svgs/Social Wellbeing.svg'
                                                                : 'assets/svgs/Social Wellbeing.svg',
                                                16.0,

                                                // FontAwesomeIcons.building,
                                                // 40.0,
                                                e['specality_name'] == "Physical Wellbeing"
                                                    ? AppColors.onlineClass
                                                    : e['specality_name'] == "Emotional Wellbeing"
                                                        ? AppColors.startConsult.withOpacity(0.8)
                                                        : e['specality_name'] ==
                                                                "Financial Wellbeing"
                                                            ? AppColors.myApp
                                                            : e['specality_name'] ==
                                                                    "Social Wellbeing"
                                                                ? AppColors.bookApp
                                                                : AppColors.primaryAccentColor
                                                                    .withOpacity(0.7),
                                                () {
                                                  getDataDiagnostic(widget.companyName,
                                                      e['specality_name'], "Fitness Class");
                                                },
                                                lessWidth: true,
                                              ),
                                            );
                                          else
                                            return SizedBox(
                                              width: 0,
                                              height: 0,
                                            );
                                        }).toList(),
                                        Visibility(
                                            child: Container(
                                          child: Column(
                                            children: [
                                              svgCard(
                                                  context,
                                                  "Physical Wellbeing",
                                                  "assets/svgs/Physical Wellbeing.svg",
                                                  16.0,
                                                  AppColors.onlineClass,
                                                  () => Get.to(ClassAndConsultantScreen(
                                                        companyName: widget.companyName,
                                                        category: "Physical Wellbeing",
                                                      ))),
                                              svgCard(
                                                  context,
                                                  "Emotional Wellbeing",
                                                  "assets/svgs/Emotional Wellbeing.svg",
                                                  16.0,
                                                  AppColors.startConsult.withOpacity(0.8),
                                                  () => Get.to(ClassAndConsultantScreen(
                                                        companyName: widget.companyName,
                                                        category: "Emotional Wellbeing",
                                                      ))),
                                              svgCard(
                                                  context,
                                                  "Financial Wellbeing",
                                                  "assets/svgs/Financial Wellbeing.svg",
                                                  16.0,
                                                  AppColors.myApp,
                                                  () => Get.to(ClassAndConsultantScreen(
                                                        companyName: widget.companyName,
                                                        category: "Financial Wellbeing",
                                                      ))),
                                              svgCard(
                                                  context,
                                                  "Social Wellbeing",
                                                  "assets/svgs/Social Wellbeing.svg",
                                                  16.0,
                                                  AppColors.bookApp,
                                                  () => Get.to(ClassAndConsultantScreen(
                                                        companyName: widget.companyName,
                                                        category: "Social Wellbeing",
                                                      )))
                                            ],
                                          ),
                                        )),
                                        Visibility(
                                          visible: isDiagnostic || isCorporateWellness,
                                          child: card(
                                            context,
                                            isCorporateWellness
                                                // ? "Corporate Wellness"
                                                ? "Events & Programs"
                                                : 'Home Health Care Needs',
                                            isCorporateWellness
                                                ? FontAwesomeIcons.building
                                                : FontAwesomeIcons.diagnoses,
                                            40.0,
                                            isCorporateWellness
                                                ? AppColors.primaryAccentColor.withOpacity(0.7)
                                                : AppColors.history,
                                            () {
                                              getDataDiagnostic(
                                                  widget.companyName,
                                                  isCorporateWellness
                                                      ? "Events & Programs"
                                                      : "Home Health Care Needs",
                                                  isCorporateWellness
                                                      ? "Fitness Class"
                                                      : "Health Consultation");
                                            },
                                            lessWidth: true,
                                          ),
                                        ),
                                        Visibility(
                                            visible: isDiagnostic || isCorporateWellness,
                                            child: SizedBox(
                                              height: 10,
                                            )),
                                        // isDiagnostic || isCorporateWellness
                                        //     ? Card(
                                        //         shape: RoundedRectangleBorder(
                                        //           borderRadius:a
                                        //               BorderRadius.circular(15.0),
                                        //         ),
                                        //         color: AppColors.cardColor,
                                        //         child: Row(
                                        //           crossAxisAlignment:
                                        //               CrossAxisAlignment.start,
                                        //           children: <Widget>[
                                        //             Flexible(
                                        //               child: Padding(
                                        //                 padding: const EdgeInsets.only(
                                        //                     bottom: 16.0,
                                        //                     left: 16.0,
                                        //                     right: 16.0,
                                        //                     top: 16.0),
                                        //                 child: Column(
                                        //                   mainAxisAlignment:
                                        //                       MainAxisAlignment
                                        //                           .spaceEvenly,
                                        //                   crossAxisAlignment:
                                        //                       CrossAxisAlignment.start,
                                        //                   children: <Widget>[
                                        //                     SizedBox(height: 10.0),
                                        //                     Padding(
                                        //                       padding:
                                        //                           const EdgeInsets.only(
                                        //                               left: 8.0),
                                        //                       child: Text(
                                        //                         isCorporateWellness
                                        //                             ? 'Corporate Wellness'
                                        //                             : 'Home Health Care Needs',
                                        //                         style: TextStyle(
                                        //                             fontWeight:
                                        //                                 FontWeight.w600,
                                        //                             color: AppColors
                                        //                                 .primaryAccentColor,
                                        //                             fontSize: 18.0),
                                        //                       ),
                                        //                     ),
                                        //                     Padding(
                                        //                       padding:
                                        //                           const EdgeInsets.all(
                                        //                               2.5),
                                        //                       child: Card(
                                        //                         shape:
                                        //                             RoundedRectangleBorder(
                                        //                           borderRadius:
                                        //                               BorderRadius
                                        //                                   .circular(15),
                                        //                         ),
                                        //                         elevation: 4,
                                        //                         color:
                                        //                             AppColors.cardColor,
                                        //                         child: InkWell(
                                        //                           key: Key(
                                        //                               'affiliationHomeHealthCareNeeds'),
                                        //                           onTap: () {
                                        //                             getDataDiagnostic(
                                        //                                 widget
                                        //                                     .companyName,
                                        //                                 isCorporateWellness
                                        //                                     ? "Corporate Wellness"
                                        //                                     : "Home Health Care Needs",
                                        //                                 isCorporateWellness
                                        //                                     ? "Fitness Class"
                                        //                                     : "Health Consultation");
                                        //                           },
                                        //                           borderRadius:
                                        //                               BorderRadius
                                        //                                   .circular(15.0),
                                        //                           splashColor: AppColors
                                        //                               .onlineClass
                                        //                               .withOpacity(0.5),
                                        //                           child: Column(
                                        //                               mainAxisAlignment:
                                        //                                   MainAxisAlignment
                                        //                                       .center,
                                        //                               children: [
                                        //                                 SizedBox(
                                        //                                   height: ScUtil()
                                        //                                       .setHeight(
                                        //                                           3.0),
                                        //                                 ),
                                        //                                 Center(
                                        //                                   child: Row(
                                        //                                     children: [
                                        //                                       Container(
                                        //                                         margin: const EdgeInsets
                                        //                                                 .all(
                                        //                                             11.0),
                                        //                                         height: ScUtil()
                                        //                                             .setHeight(
                                        //                                                 60.0),
                                        //                                         width: ScUtil()
                                        //                                             .setWidth(
                                        //                                                 50.0),
                                        //                                         decoration:
                                        //                                             BoxDecoration(
                                        //                                           color: Colors
                                        //                                               .transparent,
                                        //                                           borderRadius:
                                        //                                               BorderRadius.circular(20),
                                        //                                         ),
                                        //                                         child:
                                        //                                             Icon(
                                        //                                           // FontAwesomeIcons.ello,
                                        //                                           // FontAwesomeIcons.peopleCarry,
                                        //                                           // FontAwesomeIcons.handsHelping,
                                        //                                           isCorporateWellness
                                        //                                               ? FontAwesomeIcons.ello
                                        //                                               : FontAwesomeIcons.diagnoses,
                                        //                                           color: isCorporateWellness
                                        //                                               ? AppColors.primaryAccentColor.withOpacity(0.7)
                                        //                                               : AppColors.history,
                                        //                                           size:
                                        //                                               40.0,
                                        //                                         ),
                                        //                                       ),
                                        //                                       SizedBox(
                                        //                                         width: ScUtil().setWidth(
                                        //                                             isCorporateWellness
                                        //                                                 ? 1
                                        //                                                 : 10.0),
                                        //                                       ),
                                        //                                       Flexible(
                                        //                                         child:
                                        //                                             Text(
                                        //                                           isCorporateWellness
                                        //                                               ? "Corporate Wellness"
                                        //                                               : 'Home Health Care Needs',
                                        //                                           overflow:
                                        //                                               TextOverflow.ellipsis,
                                        //                                           textAlign: isCorporateWellness
                                        //                                               ? TextAlign.left
                                        //                                               : TextAlign.center,
                                        //                                           style:
                                        //                                               TextStyle(
                                        //                                             //fontWeight: FontWeight.w600,
                                        //                                             fontSize:
                                        //                                                 20,
                                        //                                             color:
                                        //                                                 AppColors.primaryColor,
                                        //                                           ),
                                        //                                         ),
                                        //                                       ),
                                        //                                     ],
                                        //                                   ),
                                        //                                 ),
                                        //                                 SizedBox(
                                        //                                   height: ScUtil()
                                        //                                       .setHeight(
                                        //                                           3.0),
                                        //                                 ),
                                        //                               ]),
                                        //                         ),
                                        //                       ),
                                        //                     )
                                        //                   ],
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       )
                                        //     : Container(),
                                        // isDiagnostic || isCorporateWellness
                                        //     ? SizedBox(
                                        //         height: 10,
                                        //       )
                                        //     : SizedBox(),

                                        Visibility(
                                          // visible: teleConVisible,
                                          visible: false,
                                          child: card(
                                            context,
                                            'Consultation',
                                            Icons.medical_services_rounded,
                                            40.0,
                                            AppColors.bookApp,
                                            () {
                                              // openTocDialogForAffiliation(
                                              //     context, true, widget.companyName);
                                              // openTocDialog(context,
                                              //     on_Tap: Get.to(NewSpecialtiyTypeScreen(
                                              //       companyName: widget.companyName,
                                              //     )),
                                              //     ontap_Available: true);
                                              // true;
                                              Get.to(ClassAndConsultantScreen(
                                                  companyName: widget.companyName));
                                            },
                                            lessWidth: true,
                                          ),
                                        ),

                                        Visibility(
                                            visible: teleConVisible,
                                            child: SizedBox(
                                              height: 10,
                                            )),

                                        // teleConVisible
                                        //     ? Card(
                                        //         shape: RoundedRectangleBorder(
                                        //           borderRadius:
                                        //               BorderRadius.circular(15.0),
                                        //         ),
                                        //         color: AppColors.cardColor,
                                        //         child: Row(
                                        //           crossAxisAlignment:
                                        //               CrossAxisAlignment.start,
                                        //           children: <Widget>[
                                        //             Flexible(
                                        //               child: Padding(
                                        //                 padding: const EdgeInsets.only(
                                        //                     bottom: 16.0,
                                        //                     left: 16.0,
                                        //                     right: 16.0,
                                        //                     top: 16.0),
                                        //                 child: Column(
                                        //                   mainAxisAlignment:
                                        //                       MainAxisAlignment
                                        //                           .spaceEvenly,
                                        //                   crossAxisAlignment:
                                        //                       CrossAxisAlignment.start,
                                        //                   children: <Widget>[
                                        //                     SizedBox(height: 10.0),
                                        //                     Padding(
                                        //                       padding:
                                        //                           const EdgeInsets.only(
                                        //                               left: 8.0),
                                        //                       child: Text(
                                        //                         'TeleConsultation',
                                        //                         style: TextStyle(
                                        //                             fontWeight:
                                        //                                 FontWeight.w600,
                                        //                             color: AppColors
                                        //                                 .primaryAccentColor,
                                        //                             fontSize: 18.0),
                                        //                       ),
                                        //                     ),
                                        //                     Padding(
                                        //                       padding:
                                        //                           const EdgeInsets.all(
                                        //                               2.5),
                                        //                       child: Card(
                                        //                         shape:
                                        //                             RoundedRectangleBorder(
                                        //                           borderRadius:
                                        //                               BorderRadius
                                        //                                   .circular(15),
                                        //                         ),
                                        //                         elevation: 4,
                                        //                         color:
                                        //                             AppColors.cardColor,
                                        //                         child: InkWell(
                                        //                           key: Key(
                                        //                               'affiliationStartConsultNow'),
                                        //                           onTap: () {
                                        //                             openTocDialogForAffiliation(
                                        //                                 context,
                                        //                                 true,
                                        //                                 widget
                                        //                                     .companyName);
                                        //                           },
                                        //                           splashColor: AppColors
                                        //                               .startConsult
                                        //                               .withOpacity(0.5),
                                        //                           borderRadius:
                                        //                               BorderRadius
                                        //                                   .circular(15.0),
                                        //                           child: Column(
                                        //                               mainAxisAlignment:
                                        //                                   MainAxisAlignment
                                        //                                       .center,
                                        //                               children: [
                                        //                                 SizedBox(
                                        //                                   height: ScUtil()
                                        //                                       .setHeight(
                                        //                                           3.0),
                                        //                                 ),
                                        //                                 Center(
                                        //                                   child: Row(
                                        //                                     children: [
                                        //                                       Container(
                                        //                                         margin: const EdgeInsets
                                        //                                                 .all(
                                        //                                             11.0),
                                        //                                         height: ScUtil()
                                        //                                             .setHeight(
                                        //                                                 60.0),
                                        //                                         width: ScUtil()
                                        //                                             .setWidth(
                                        //                                                 50.0),
                                        //                                         decoration:
                                        //                                             BoxDecoration(
                                        //                                           color: Colors
                                        //                                               .transparent,
                                        //                                           borderRadius:
                                        //                                               BorderRadius.circular(20),
                                        //                                         ),
                                        //                                         child:
                                        //                                             Icon(
                                        //                                           FontAwesomeIcons
                                        //                                               .video,
                                        //                                           color: AppColors
                                        //                                               .startConsult,
                                        //                                           size:
                                        //                                               40.0,
                                        //                                         ),
                                        //                                       ),
                                        //                                       SizedBox(
                                        //                                         width: ScUtil()
                                        //                                             .setWidth(
                                        //                                                 30.0),
                                        //                                       ),
                                        //                                       Flexible(
                                        //                                         child:
                                        //                                             Text(
                                        //                                           'Consult Now',
                                        //                                           overflow:
                                        //                                               TextOverflow.ellipsis,
                                        //                                           textAlign:
                                        //                                               TextAlign.center,
                                        //                                           style:
                                        //                                               TextStyle(
                                        //                                             //fontWeight: FontWeight.w600,
                                        //                                             fontSize:
                                        //                                                 20,
                                        //                                             color:
                                        //                                                 AppColors.primaryColor,
                                        //                                           ),
                                        //                                         ),
                                        //                                       ),
                                        //                                     ],
                                        //                                   ),
                                        //                                 ),
                                        //                                 SizedBox(
                                        //                                   height: ScUtil()
                                        //                                       .setHeight(
                                        //                                           3.0),
                                        //                                 ),
                                        //                               ]),
                                        //                         ),
                                        //                       ),
                                        //                     ),
                                        //                     Padding(
                                        //                       padding:
                                        //                           const EdgeInsets.all(
                                        //                               2.5),
                                        //                       child: Card(
                                        //                         shape:
                                        //                             RoundedRectangleBorder(
                                        //                           borderRadius:
                                        //                               BorderRadius
                                        //                                   .circular(15),
                                        //                         ),
                                        //                         elevation: 4,
                                        //                         color:
                                        //                             AppColors.cardColor,
                                        //                         child: InkWell(
                                        //                           key: Key(
                                        //                               'affiliationBookAppointment'),
                                        //                           onTap: () {
                                        //                             openTocDialogForAffiliation(
                                        //                                 context,
                                        //                                 false,
                                        //                                 widget
                                        //                                     .companyName);
                                        //                           },
                                        //                           borderRadius:
                                        //                               BorderRadius
                                        //                                   .circular(15.0),
                                        //                           splashColor: AppColors
                                        //                               .bookApp
                                        //                               .withOpacity(0.5),
                                        //                           child: Column(
                                        //                               mainAxisAlignment:
                                        //                                   MainAxisAlignment
                                        //                                       .center,
                                        //                               children: [
                                        //                                 SizedBox(
                                        //                                   height: ScUtil()
                                        //                                       .setHeight(
                                        //                                           3.0),
                                        //                                 ),
                                        //                                 Center(
                                        //                                   child: Row(
                                        //                                     children: [
                                        //                                       Container(
                                        //                                         margin: const EdgeInsets
                                        //                                                 .all(
                                        //                                             11.0),
                                        //                                         height: ScUtil()
                                        //                                             .setHeight(
                                        //                                                 60.0),
                                        //                                         width: ScUtil()
                                        //                                             .setWidth(
                                        //                                                 50.0),
                                        //                                         decoration:
                                        //                                             BoxDecoration(
                                        //                                           color: Colors
                                        //                                               .transparent,
                                        //                                           borderRadius:
                                        //                                               BorderRadius.circular(20),
                                        //                                         ),
                                        //                                         child:
                                        //                                             Icon(
                                        //                                           FontAwesomeIcons
                                        //                                               .calendarAlt,
                                        //                                           color: AppColors
                                        //                                               .bookApp,
                                        //                                           size:
                                        //                                               40.0,
                                        //                                         ),
                                        //                                       ),
                                        //                                       Flexible(
                                        //                                         child:
                                        //                                             Text(
                                        //                                           'Book Appointment',
                                        //                                           textAlign:
                                        //                                               TextAlign.center,
                                        //                                           overflow:
                                        //                                               TextOverflow.ellipsis,
                                        //                                           style:
                                        //                                               TextStyle(
                                        //                                             //fontWeight: FontWeight.w600,
                                        //                                             fontSize:
                                        //                                                 20,
                                        //                                             color:
                                        //                                                 AppColors.primaryColor,
                                        //                                           ),
                                        //                                         ),
                                        //                                       ),
                                        //                                     ],
                                        //                                   ),
                                        //                                 ),
                                        //                                 SizedBox(
                                        //                                   height: ScUtil()
                                        //                                       .setHeight(
                                        //                                           3.0),
                                        //                                 ),
                                        //                               ]),
                                        //                         ),
                                        //                       ),
                                        //                     ),
                                        //                   ],
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       )
                                        //     : SizedBox(),
                                        // SizedBox(height: 10.0),
                                        Visibility(
                                          // visible: wellnessCartVisible,
                                          visible: true,
                                          child: card(
                                            context,
                                            'Health E-Market',
                                            Customicons.fitness_class,
                                            160.0,
                                            AppColors.onlineClass,
                                            () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) => SpecialityTypeScreen(
                                              //         arg: fitnessClassSpecialties,
                                              //         companyName: widget.companyName),
                                              //   ),
                                              // );
                                              Get.to(ClassAndConsultantScreen(
                                                  companyName: widget.companyName));
                                            },
                                            lessWidth: true,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(0.5),
                                          child: card(
                                              context,
                                              'Subscription',
                                              FontAwesomeIcons.solidBell,
                                              40.0,
                                              AppColors.subscription,
                                              () => Get.to(
                                                    MySubscription(
                                                      afterCall: false,
                                                      onlineCourse: true,
                                                    ),
                                                  ),
                                              lessWidth: true
                                              //      () {
                                              //   Navigator.of(context).pushNamed(
                                              //       Routes.MySubscriptions,
                                              //       arguments: false);
                                              // }
                                              ),
                                        ),
                                        //make it true for health challenges showing in affiliations
                                        Visibility(
                                          visible: true,
                                          child: Padding(
                                            padding: const EdgeInsets.all(0.5),
                                            child: card(
                                                context,
                                                'Health Challenges',
                                                FontAwesomeIcons.solidThumbsUp,
                                                40.0,
                                                Colors.blue, () async {
                                              /*SharedPreferences prefs1 =
                                                  await SharedPreferences.getInstance();
                                              String userid = prefs1.getString("ihlUserId");
                                              if (mounted) setState(() {});
                                              List<EnrolledChallenge> currentERchallenge =
                                                  await ChallengeApi()
                                                      .listofUserEnrolledChallenges(userId: userid);

                                              ListChallenge _listChallenge = ListChallenge(
                                                  challenge_mode: '',
                                                  email: Get.find<ListChallengeController>().email,
                                                  pagination_start: 0,
                                                  pagination_end: 1000,
                                                  affiliation_list: [widget.affiliationName]);
                                              List<Challenge> _listofChallenges =
                                                  await ChallengeApi()
                                                      .listOfChallenges(challenge: _listChallenge);
                                              _listofChallenges.removeWhere((element) =>
                                                  element.challengeStatus == "deactive");
                                              // if (currentERchallenge.isNotEmpty && _listofChallenges.isNotEmpty) {
                                              //   Get.to(HealthChallengesComponents(
                                              //     list: [widget.affiliationName],
                                              //   ));
                                              // } else
                                              // List<GroupModel> allGroups = [];
                                              // for (var e
                                              //     in currentERchallenge) {
                                              //   allGroups.addAll(
                                              //       await ChallengeApi()
                                              //           .listOfGroups(
                                              //               challengeId:
                                              //                   e.challengeId));
                                              // }
                                              // allGroups.removeWhere((element) =>
                                              //     element.groupStatus ==
                                              //     "deactive");
                                              // if (currentERchallenge.isNotEmpty) {
                                              List<ChallengeDetail> forTypesFilter = [];
                                              for (int i = 0; i < currentERchallenge.length; i++) {
                                                forTypesFilter.add(await ChallengeApi()
                                                    .challengeDetail(
                                                        challengeId:
                                                            currentERchallenge[i].challengeId));
                                              }
                                              List types = [];
                                              List affi = [];

                                              for (int i = 0; i < forTypesFilter.length; i++) {
                                                for (int j = 0;
                                                    j < forTypesFilter[i].affiliations.length;
                                                    j++) {
                                                  affi.add(forTypesFilter[i].affiliations[j]);
                                                }
                                                //Step Challenge
                                                //Weight Loss Challenge
                                              }
                                              if (_listofChallenges.isNotEmpty)
                                                for (var i in _listofChallenges) {
                                                  types.add(i.challengeType);
                                                }
                                              types = types.toSet().toList();
                                              List<Challenge> c = [];
                                              for (var i in currentERchallenge)
                                                c.addAll(_listofChallenges.where((element) =>
                                                    element.challengeId == i.challengeId));
                                              c.removeWhere((element) => !element.affiliations
                                                  .contains(widget.affiliationName));
                                              if (c.isNotEmpty) {
                                                Get.to(HealthChallengesComponents(
                                                  list: [capitalize(widget.affiliationName)],
                                                ));
                                              } else {
                                                if (types.length == 1) {
                                                  Get.to(ListofChallenges(
                                                    list: [capitalize(widget.affiliationName)],
                                                    challengeType: types[0],
                                                  ));
                                                } else if (types.length > 1) {
                                                  Get.to(HealthChallengeTypes(
                                                    list: [capitalize(widget.affiliationName)],
                                                  ));
                                                } else {
                                                  Get.to(ListofChallenges(
                                                      list: [capitalize(widget.affiliationName)]));
                                                }
                                              }
                                              // }
                                              // Get.to(ListofChallenges());*/
                                              Get.to(HealthChallengesComponents(
                                                list: widget.companyName == "persistent"
                                                    ? ["persistent", "Persistent"]
                                                    : [widget.companyName],
                                              ));
                                            }, lessWidth: true
                                                //      () {
                                                //   Navigator.of(context).pushNamed(
                                                //       Routes.MySubscriptions,
                                                //       arguments: false);
                                                // }
                                                ),
                                          ),
                                        ),

                                        Visibility(
                                            visible: wellnessCartVisible,
                                            child: SizedBox(
                                              height: 10,
                                            )),
                                        // wellnessCartVisible
                                        //     ? Card(
                                        //         shape: RoundedRectangleBorder(
                                        //           borderRadius:
                                        //               BorderRadius.circular(15.0),
                                        //         ),
                                        //         color: AppColors.cardColor,
                                        //         child: Row(
                                        //           crossAxisAlignment:
                                        //               CrossAxisAlignment.start,
                                        //           children: <Widget>[
                                        //             Flexible(
                                        //               child: Padding(
                                        //                 padding: const EdgeInsets.only(
                                        //                     bottom: 16.0,
                                        //                     left: 16.0,
                                        //                     right: 16.0,
                                        //                     top: 16.0),
                                        //                 child: Column(
                                        //                   mainAxisAlignment:
                                        //                       MainAxisAlignment
                                        //                           .spaceEvenly,
                                        //                   crossAxisAlignment:
                                        //                       CrossAxisAlignment.start,
                                        //                   children: <Widget>[
                                        //                     SizedBox(height: 10.0),
                                        //                     Padding(
                                        //                       padding:
                                        //                           const EdgeInsets.only(
                                        //                               left: 8.0),
                                        //                       child: Text(
                                        //                         'Health E-Market',
                                        //                         style: TextStyle(
                                        //                             fontWeight:
                                        //                                 FontWeight.w600,
                                        //                             color: AppColors
                                        //                                 .primaryAccentColor,
                                        //                             fontSize: 18.0),
                                        //                       ),
                                        //                     ),
                                        //                     Padding(
                                        //                       padding:
                                        //                           const EdgeInsets.all(
                                        //                               2.5),
                                        //                       child: Card(
                                        //                         shape:
                                        //                             RoundedRectangleBorder(
                                        //                           borderRadius:
                                        //                               BorderRadius
                                        //                                   .circular(15),
                                        //                         ),
                                        //                         elevation: 4,
                                        //                         color:
                                        //                             AppColors.cardColor,
                                        //                         child: InkWell(
                                        //                           key: Key(
                                        //                               'affiliationFitnessClasses'),
                                        //                           onTap: () {
                                        //                             Navigator.push(
                                        //                                 context,
                                        //                                 MaterialPageRoute(
                                        //                                     builder: (context) => SpecialityTypeScreen(
                                        //                                         arg:
                                        //                                             fitnessClassSpecialties,
                                        //                                         companyName:
                                        //                                             widget
                                        //                                                 .companyName)));
                                        //                           },
                                        //                           borderRadius:
                                        //                               BorderRadius
                                        //                                   .circular(15.0),
                                        //                           splashColor: AppColors
                                        //                               .onlineClass
                                        //                               .withOpacity(0.5),
                                        //                           child: Column(
                                        //                               mainAxisAlignment:
                                        //                                   MainAxisAlignment
                                        //                                       .center,
                                        //                               children: [
                                        //                                 SizedBox(
                                        //                                   height: ScUtil()
                                        //                                       .setHeight(
                                        //                                           3.0),
                                        //                                 ),
                                        //                                 Center(
                                        //                                   child: Row(
                                        //                                     children: [
                                        //                                       Container(
                                        //                                         margin: const EdgeInsets
                                        //                                                 .all(
                                        //                                             11.0),
                                        //                                         height: ScUtil()
                                        //                                             .setHeight(
                                        //                                                 60.0),
                                        //                                         width: ScUtil()
                                        //                                             .setWidth(
                                        //                                                 50.0),
                                        //                                         decoration:
                                        //                                             BoxDecoration(
                                        //                                           color: Colors
                                        //                                               .transparent,
                                        //                                           borderRadius:
                                        //                                               BorderRadius.circular(20),
                                        //                                         ),
                                        //                                         child:
                                        //                                             Icon(
                                        //                                           Customicons
                                        //                                               .fitness_class,
                                        //                                           color: AppColors
                                        //                                               .onlineClass,
                                        //                                           size:
                                        //                                               170.0,
                                        //                                         ),
                                        //                                       ),
                                        //                                       SizedBox(
                                        //                                         width: ScUtil()
                                        //                                             .setWidth(
                                        //                                                 30.0),
                                        //                                       ),
                                        //                                       Flexible(
                                        //                                         child:
                                        //                                             Text(
                                        //                                           'Health E-Market',
                                        //                                           overflow:
                                        //                                               TextOverflow.ellipsis,
                                        //                                           textAlign:
                                        //                                               TextAlign.center,
                                        //                                           style:
                                        //                                               TextStyle(
                                        //                                             //fontWeight: FontWeight.w600,
                                        //                                             fontSize:
                                        //                                                 20,
                                        //                                             color:
                                        //                                                 AppColors.primaryColor,
                                        //                                           ),
                                        //                                         ),
                                        //                                       ),
                                        //                                     ],
                                        //                                   ),
                                        //                                 ),
                                        //                                 SizedBox(
                                        //                                   height: ScUtil()
                                        //                                       .setHeight(
                                        //                                           3.0),
                                        //                                 ),
                                        //                               ]),
                                        //                         ),
                                        //                       ),
                                        //                     )
                                        //                   ],
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       )
                                        //     : Container(),
                                        teleConVisible == false && wellnessCartVisible == false
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 50.0, left: 8.0, right: 8.0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        child: Text(
                                                            "Currently not providing any services...",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                fontSize: 22.0,
                                                                color:
                                                                    AppColors.primaryAccentColor))),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    )
                                  : Padding(
                                      padding:
                                          const EdgeInsets.only(top: 50.0, left: 8.0, right: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Text("Loading...",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 22.0,
                                                      color: AppColors.primaryAccentColor))),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                          Visibility(
                            visible: clickLoading,
                            child: Container(
                              decoration: BoxDecoration(
                                color: FitnessAppTheme.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                              child: Center(
                                  child: SizedBox(
                                width: ScUtil().setWidth(50),
                                height: ScUtil().setHeight(50),
                                child: CircularProgressIndicator(
                                  strokeWidth: 5,
                                  color: AppColors.progressBarIndicatorColor,
                                  backgroundColor:
                                      AppColors.progressBarIndicatorColor.withOpacity(0.1),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50.0, left: 8.0, right: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text("Loading...",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 22.0, color: AppColors.primaryAccentColor))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Future getDataDiagnostic(var companyName, var specalityType, var consultation_type_name) async {
    ///"specality_name" -> "Corporate Wellness"
    if (mounted) {
      setState(() {
        clickLoading = true;
      });
    }
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res1 = jsonDecode(data1);
    var iHLUserId = res1['User']['id'];

    final getPlatformData = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/GetPlatfromData"),
      body: jsonEncode(<String, String>{'ihl_id': iHLUserId, 'cache': "true"}),
    );
    if (getPlatformData.statusCode == 200) {
      if (getPlatformData.body != null) {
        Map res = jsonDecode(getPlatformData.body);
        final platformData = await SharedPreferences.getInstance();
        platformData.setString(SPKeys.platformData, getPlatformData.body);
        if (res['consult_type'] == null ||
            !(res['consult_type'] is List) ||
            res['consult_type'].isEmpty) {
          return;
        }
        var consultationType = res['consult_type'];

        for (int i = 0; i < consultationType.length; i++) {
          if (consultationType[i]["consultation_type_name"] == "$consultation_type_name") {
            // "Health Consultation") {
            for (int j = 0; j < consultationType[i]["specality"].length; j++) {
              // "Fitness Class":"Health Consultation")
              if (consultationType[i]["specality"][j]["specality_name"].replaceAll('amp;', '') ==
                  "$specalityType") {
                if (mounted) {
                  setState(() {
                    clickLoading = false;
                  });
                }
                if (consultation_type_name == "Health Consultation") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SelectConsultantForAffiliation(
                              companyName: companyName,
                              arg: consultationType[i]["specality"][j],
                              liveCall: true)));
                } else if (consultation_type_name == "Fitness Class") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectClassesForAffiliation(
                        companyName: companyName,
                        arg: consultationType[i]["specality"][j],
                      ),
                    ),
                  );
                }
                break;
              }
            }
          }
        }
        if (mounted) {
          setState(() {
            clickLoading = false;
            print('after loop end , no result found');
          });
        }
      }
    }
  }
}
