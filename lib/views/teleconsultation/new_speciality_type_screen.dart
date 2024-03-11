import 'dart:convert';
import 'dart:developer' as loo;
import 'dart:math';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:ihl/views/teleconsultation/affiliationApp/smitFit_discription.dart';
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../constants/api.dart';
import '../../constants/routes.dart';
import '../../constants/spKeys.dart';
import '../../utils/screenutil.dart';
import '../../utils/app_colors.dart';
import '../../widgets/BasicPageUI.dart';
import '../../widgets/offline_widget.dart';
import '../../widgets/teleconsulation/consultationTypeTile.dart';
import '../affiliation/selectClassesForAffiliation.dart';
import '../affiliation/selectConsultantForAffiliation.dart';
import '../screens.dart';
import 'consultantsFilter.dart';
import 'selectConsultant.dart';

bool profileUpdated = false;

// ignore: must_be_immutable
class NewSpecialtiyTypeScreen extends StatefulWidget {
  String companyName;
  // final List<Map> arg;
  // bool liveCall;
  NewSpecialtiyTypeScreen(
      {
      // @required this.arg,
      // this.liveCall,
      this.companyName});

  @override
  _NewSpecialtiyTypeScreenState createState() => _NewSpecialtiyTypeScreenState();
}

class _NewSpecialtiyTypeScreenState extends State<NewSpecialtiyTypeScreen> {
  Client _client = Client(); //3gb
  //for search implementation//
  final TextEditingController _typeAheadController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode typeAheadFocus = new FocusNode();
  var notAvailableTxt = 'No Speciality available ';
  var careCredit;
  String iHLUserId;
  String userEmail;
  String userMobile;
  bool isAppInstalledResult = false;
  var clickCount = 0;

  ConsultationTypeTile getTile({Map mp, @required BuildContext context}) {
    // var nonAffiliatedConsultants = await ConsFilter.filterNonAffiliatedConsultants(mp,widget.arg[0]['livecall']);
    return ConsultationTypeTile(
      // visible: mp['filter_consultant_list'].length>0?true:false,
      text: mp['specality_name'].toString().replaceAll('&amp;', '&'),
      onTap: () {
        ///course => courses
        if (mp["courses"] != null && widget.companyName == null) {
          Navigator.of(context).pushNamed(
            Routes.SelectClass,
            arguments: mp,
          );
          return;
        }

        ///s
        if (mp["courses"] != null && widget.companyName != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SelectClassesForAffiliation(arg: mp, companyName: widget.companyName)));
          return;
        }
        if (mp["consultant_list"] != null && widget.companyName == null) {
          // mp['livecall'] = widget.arg[0]['livecall'];
          mp['livecall'] = true;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SelectConsutantScreen(
                        arg: mp,
                        liveCall: true,
                      )));
          return;
        }
        if (mp["consultant_list"] != null && widget.companyName != null) {
          mp['livecall'] = true;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SelectConsultantForAffiliation(
                        companyName: widget.companyName,
                        arg: mp,
                        liveCall: true,
                      )));
          return;
        }
        widget.companyName == null
            ? Navigator.of(context).pushNamed(Routes.SelectClass, arguments: mp)
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SelectClassesForAffiliation(arg: mp, companyName: widget.companyName)));
      },
      color: AppColors.primaryAccentColor,
    );
  }

  List<Widget> getList({BuildContext context, e}) {
    return e.map((ell) {
      if (ell["consultant_list"].length < 0) {
        return Container();
      } else
        return Padding(
            padding: const EdgeInsets.all(8.0), child: getTile(context: context, mp: ell));
    }).toList();
  }

  Widget getList2({BuildContext context, e}) {
    return Padding(padding: const EdgeInsets.all(8.0), child: getTile(context: context, mp: e));
  }

  Future<bool> isAppInstalled() async {
    final prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   iHLUserId = prefs.getString('ihlUserId');
    // });
    var data = prefs.get('data');
    var userData = jsonDecode(data);
    iHLUserId = userData['User']['id'];
    userEmail = userData['User']['email'];
    userMobile = userData['User']['mobileNumber'];
    isAppInstalledResult = await LaunchApp.isAppInstalled(
        androidPackageName: 'com.smitfit',
        iosUrlScheme: 'com.googleusercontent.apps.965763577963-ptpcp98nvchov5gu6d5okbrsiju4sfs2');
    return isAppInstalledResult;
  }

  getVisibilityForSpeciality() async {
    /// #the 's'  in ['course']
    loop() async {
      for (int i = 0; i < specalityTypes.length; i++) {
        var mp = specalityTypes[i];
        if (mp["courses"] != null && widget.companyName == null) {
          //normal class
          var activeClass = await ConsFilter.filterNonAffiliatedCourses(mp);
          // specalityTypes[i]['filter_consultant_list'] = filterConsultants??[];
          if (activeClass) {
            special.add(specalityTypes[i]);
          }
          notAvailableTxt = 'No classes available';
        }
        if (mp["courses"] != null && widget.companyName != null) {
          // affiliatedclass
          var activeClass = await ConsFilter.filterCoursesForAffiliation(mp, widget.companyName);
          // specalityTypes[i]['filter_consultant_list'] = filterConsultants??[];
          if (activeClass) {
            special.add(specalityTypes[i]);
          }
          notAvailableTxt = 'No classes available';
        }
        if (mp["consultant_list"] != null && widget.companyName == null) {
          //normal consultation    ///SelectConsutantScreen
          filterConsultants = await ConsFilter.filterNonAffiliatedConsultants(mp, true);
          specalityTypes[i]['filter_consultant_list'] = filterConsultants ?? [];
          if (filterConsultants.length > 0) {
            special.add(specalityTypes[i]);
          }
          notAvailableTxt = 'No Consultant available';
        }
        if (mp["consultant_list"] != null && widget.companyName != null) {
          //affiliate consultation
          mp['livecall'] = true;
          filterConsultants =
              await ConsFilter.filterConsultantsForAffiliation(mp, true, widget.companyName);
          specalityTypes[i]['filter_consultant_list'] = filterConsultants ?? [];
          if (filterConsultants.length > 0) {
            special.add(specalityTypes[i]);
          }
          notAvailableTxt = 'No Consultant available';
        }
      }
      filtterList = special;
    }

    await loop();

    // special = widget.arg["specality"];
    // special.removeWhere((element) => element['filter_consultant_list'].length==0);
    setState(() {
      loading = false;
    });
  }

  bool rndtf() {
    Random rnd = Random();
    return rnd.nextBool();
  }

  Future<String> httpStatus(var consultantId) async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/getConsultantLiveStatus'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, dynamic>{
        "consultant_id": [consultantId]
      }),
    );
    if (response.statusCode == 200) {
      if (response.body != '"[]"') {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString1 = parsedString.replaceAll(";", "");
        var parsedString2 = parsedString1.replaceAll('"[', '[');
        var parsedString3 = parsedString2.replaceAll(']"', ']');
        var finalOutput = json.decode(parsedString3);
        var doctorId = consultantId;

        if (doctorId == finalOutput[0]['consultant_id']) {
          if (finalOutput[0]['status'] == null || finalOutput[0]['status'] == 'null') {
            finalOutput[0]['status'] = 'Offline';
          }
          return camelize(finalOutput[0]['status'].toString());
        }
      } else {
        return 'Offline';
      }
    } else {
      print('responce failure');
      return 'Offline';
    }
    return 'Offline';
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    // getVisibilityForSpeciality();
    isAppInstalled();
    super.initState();
  }

  bool loading = true;
  var filterConsultants;
  List special = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (profileUpdated) {
          Get.to(ViewallTeleDashboard());
        } else {
          Navigator.pop(context);
        }
      },
      child: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: BasicPageUI(
          appBar: Column(children: [
            SizedBox(
              width: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // BackButton(
                //   color: Colors.white,
                // ),
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    if (profileUpdated) {
                      Get.to(ViewallTeleDashboard());
                    } else {
                      Navigator.pop(context);
                    }
                  }, //replaces the screen to Main dashboard
                  color: Colors.white,
                ),
                Flexible(
                  //Health E-Market
                  child: Text(
                    "Specialities",
                    // widget.arg[0]['consultation_type_name'].toString() ==
                    //         'Fitness Class'
                    //     ? 'Health E-Market'
                    //     : widget.arg[0]['consultation_type_name'].toString(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
                SizedBox(
                  width: 40,
                )
              ],
            ),
            Visibility(
              visible: true,
              // visible: widget.arg[0]['consultation_type_name'].toString() !=
              // 'Fitness Class',
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 18.0, left: 18.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: TextFormField(
                        controller: _typeAheadController,
                        cursorColor: Colors.white,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(30.0),
                            ),
                            borderSide: const BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          labelStyle: //typeAheadFocus.hasPrimaryFocus
                              TextStyle(
                            color: Colors.white,
                          ),
                          //: TextStyle(),
                          hintStyle: TextStyle(
                            color: Colors.white,
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              //     widget.mealsListData.startColor),
                            ),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(30.0),
                            ),
                          ),
                          border: new OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(30.0),
                            ),
                          ),

                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          hintText: 'Search Specialities',
                          prefixIcon: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 8, end: 8.0),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onChanged: (str) {
                          List<Map> currentSug = [];
                          currentSug.clear();
                          special = filtterList;
                          // for (var e in consultationType) {
                          for (var i in special) {
                            if (i["specality_name"]
                                .substring(0, str.length)
                                .contains(str.capitalizeFirst)) {
                              loo.log(i["specality_name"].toString());
                              currentSug.add(i);
                            } else {
                              null;
                            }
                          }
                          // }
                          if (str == "") {
                            special = filtterList;
                          } else {
                            special = currentSug;
                          }
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
          body: loading
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 70),
                      child: CircularProgressIndicator()),
                )
              : special.length > 0
                  ? Column(
                      children: [
                        // Container(
                        //   height: 77.h,
                        //   width: Device.width,
                        //   child: ListView.builder(
                        //       shrinkWrap: true,
                        //       itemCount: consultationType.length,
                        //       itemBuilder: (ctx, i) {
                        //         return Column(
                        //             children: getList(
                        //                 context: ctx,
                        //                 e: consultationType[i]["specality"]));
                        //       }),
                        // ),

                        Column(
                          children: special.map((e) => getList2(e: e, context: context)).toList(),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(11.0),
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 9.0,
                              right: 9.0,
                              top: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: FitnessAppTheme.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                bottomLeft: Radius.circular(15.0),
                                bottomRight: Radius.circular(15.0),
                                topRight: Radius.circular(15.0),
                                // topRight: Radius.circular(68.0)),
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: FitnessAppTheme.grey.withOpacity(0.2),
                                    offset: Offset(1.1, 1.1),
                                    blurRadius: 10.0),
                              ],
                            ),
                            child: Visibility(
                              visible: (widget.companyName == 'persistent' ||
                                          widget.companyName == 'persistent'.capitalizeFirst) &&
                                      consultationType[0]['consultation_type_name'].toString() ==
                                          'Fitness Class'
                                  ? true
                                  : false,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20.0),
                                onTap: () async {
                                  // setState(() {
                                  //   clickCount += 1;
                                  // });
                                  // // if (!isAppInstalledResult) {
                                  //   careCredit = iHLUserId;
                                  // }
                                  Get.to(AffilicationAppDescription(
                                    iHLUserId: iHLUserId,
                                    userMobile: userMobile,
                                    userEmail: userEmail,
                                  ));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  child: ListTile(
                                    title: Text(
                                      "Connect to SmitFit",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    leading: Stack(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                MediaQuery.of(context).size.height / 90),
                                            child: SvgPicture.asset(
                                              'assets/svgs/mobile-icon.svg',
                                              color: Colors.red,
                                              fit: BoxFit.contain,
                                              //height: 60,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : Center(
                      child: Column(
                        children: [
                          Lottie.asset(
                              // 'assets/lottieFiles/no_cons_available.json',
                              'assets/lottieFiles/no_cons_found_color.json',
                              // 'assets/lottieFiles/c2.json',
                              height: ScUtil().setHeight(300),
                              width: ScUtil().setWidth(300)),
                          SizedBox(
                            height: ScUtil().setHeight(20),
                          ),
                          Container(
                            // color: Colors.red,
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              // notAvailableTxt + '  Please try again later',
                              'No Speciality available Please try again later',
                              textAlign: TextAlign.center,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: ScUtil().setSp(22),
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryAccentColor,
                                fontFamily: 'Poppins',
                                // letterSpacing: 0.5
                              ),
                            ),
                          )
                        ],
                      ),
                    )
          // : SizedBox(
          //     height: MediaQuery.of(context).size.height*0.8,
          //   child: Center(child: Text(notAvailableTxt),),
          // )
          ,
        ),
      ),
    );
  }

  List<dynamic> consultationType = [];
  List<dynamic> specalityTypes = [];
  List<dynamic> filtterList = [];
  Future getData() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res1 = jsonDecode(data1);
    iHLUserId = res1['User']['id'];

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
    } else {}
    if (getPlatformData.body != null) {
      Map res = jsonDecode(getPlatformData.body);
      final platformData = await SharedPreferences.getInstance();
      platformData.setString(SPKeys.platformData, getPlatformData.body);
      loading = false;
      if (res['consult_type'] == null ||
          !(res['consult_type'] is List) ||
          res['consult_type'].isEmpty) {
        return;
      }
      consultationType = res['consult_type'];

      for (int i = 0; i < consultationType.length; i++) {
        if (consultationType[i]["consultation_type_name"] == "Medical Consultation") {
          consultationType[i]["consultation_type_name"] = "Doctor Consultation";
        }
        if (consultationType[i]["consultation_type_name"] == "Fitness Class") {
          consultationType.removeAt(i);
        }
        consultationType[i]["specality"].removeWhere((e) => e["consultant_list"].length == 0);
      }
      for (var e in consultationType) {
        for (var i in e["specality"]) {
          loo.log(i["specality_name"]);
        }
      }
      for (var e in consultationType) {
        // ignore: unused_local_variable
        for (var i in e["specality"]) {
          specalityTypes.add(i);
        }
      }
      getVisibilityForSpeciality();
      if (mounted) setState(() {});
    }
  }
}
