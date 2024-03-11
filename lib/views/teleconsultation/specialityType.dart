import 'dart:convert';
import 'dart:math';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/customicons_icons.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/affiliation/bookAppointmentForAffiliation.dart';
import 'package:ihl/views/affiliation/selectClassesForAffiliation.dart';
import 'package:ihl/views/affiliation/selectConsultantForAffiliation.dart';
import 'package:ihl/views/screens.dart';
import 'package:ihl/views/teleconsultation/affiliationApp/smitFit_discription.dart';
// import 'package:ihl/views/dietJournal/addFood.dart';
import 'package:ihl/views/teleconsultation/selectConsultant.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:ihl/widgets/teleconsulation/book_appointment.dart';
import 'package:ihl/widgets/teleconsulation/consultationTypeTile.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import 'consultantsFilter.dart';

// ignore: must_be_immutable
class SpecialityTypeScreen extends StatefulWidget {
  String companyName;
  Map arg;
  bool liveCall;
  SpecialityTypeScreen({this.arg, this.liveCall, this.companyName});

  @override
  _SpecialityTypeScreenState createState() => _SpecialityTypeScreenState();
}

class _SpecialityTypeScreenState extends State<SpecialityTypeScreen> {
  http.Client _client = http.Client(); //3gb
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

  Future<dynamic> updateExternalAppCount({userID, mobileNumber, emailId}) async {
    http.Client _client = http.Client();
    try {
      final response =
          await _client.post(Uri.parse(API.iHLUrl + '/consult/create_update_external_app_detail'),
              body: json.encode({
                "user_id": userID,
                "email": emailId,
                "click_count": clickCount,
                "app_name": "smitfit",
                "mobile_number": mobileNumber
              }));
      print(response.statusCode);
      if (response.statusCode == 200) {
        var openAppresult = await LaunchApp.openApp(
            androidPackageName: 'com.smitfit',
            iosUrlScheme:
                'com.googleusercontent.apps.965763577963-ptpcp98nvchov5gu6d5okbrsiju4sfs2',
            appStoreLink: 'https://apps.apple.com/in/app/smit-fit/id1525550488');
        print('openAppResult => $openAppresult ${openAppresult.runtimeType}');
        print(response.body);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Not Evalouated'),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  // for search implementation//

  ConsultationTypeTile getTile({Map mp, @required BuildContext context}) {
    // var nonAffiliatedConsultants = await ConsFilter.filterNonAffiliatedConsultants(mp,widget.arg['livecall']);
    return ConsultationTypeTile(
      // visible: mp['filter_consultant_list'].length>0?true:false,
      text: mp['specality_name'].toString().replaceAll('&amp;', '&'),
      onTap: () {
        ///course => courses
        if (mp["courses"] != null && widget.companyName == null) {
          // Navigator.of(context).pushNamed(
          //   Routes.SelectClass,
          //   arguments: mp,
          // );
          Get.to(SelectClassesScreen(
            list: widget.arg["specality"],
            arg: mp,
          ));
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
          mp['livecall'] = widget.arg['livecall'];
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SelectConsutantScreen(
                        arg: mp,
                        liveCall: widget.liveCall,
                      )));
          return;
        }
        if (mp["consultant_list"] != null && widget.companyName != null) {
          mp['livecall'] = widget.arg['livecall'];
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SelectConsultantForAffiliation(
                        companyName: widget.companyName,
                        arg: mp,
                        liveCall: widget.liveCall,
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

  List<Widget> getList({BuildContext context}) {
    return special.map((e) {
      return Padding(padding: const EdgeInsets.all(8.0), child: getTile(context: context, mp: e));
    }).toList();
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
    print(isAppInstalledResult);
    return isAppInstalledResult;
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
    getVisibilityForSpeciality();
    isAppInstalled();
    super.initState();
  }

  bool loading = true;
  var filterConsultants;
  List special = [];
  getVisibilityForSpeciality() async {
    /// #the 's'  in ['course']
    loop() async {
      for (int i = 0; i < widget.arg['specality'].length; i++) {
        var mp = widget.arg['specality'][i];
        if (mp["courses"] != null && widget.companyName == null) {
          //normal class
          var activeClass = await ConsFilter.filterNonAffiliatedCourses(mp);
          // widget.arg['specality'][i]['filter_consultant_list'] = filterConsultants??[];
          if (activeClass) {
            special.add(widget.arg['specality'][i]);
          }
          notAvailableTxt = 'No classes available';
        }
        if (mp["courses"] != null && widget.companyName != null) {
          // affiliatedclass
          var activeClass = await ConsFilter.filterCoursesForAffiliation(mp, widget.companyName);
          // widget.arg['specality'][i]['filter_consultant_list'] = filterConsultants??[];
          if (activeClass) {
            special.add(widget.arg['specality'][i]);
          }
          notAvailableTxt = 'No classes available';
        }
        if (mp["consultant_list"] != null && widget.companyName == null) {
          //normal consultation    ///SelectConsutantScreen
          filterConsultants =
              await ConsFilter.filterNonAffiliatedConsultants(mp, widget.arg['livecall']);
          widget.arg['specality'][i]['filter_consultant_list'] = filterConsultants ?? [];
          if (filterConsultants.length > 0) {
            special.add(widget.arg['specality'][i]);
          }
          notAvailableTxt = 'No Consultant available';
        }
        if (mp["consultant_list"] != null && widget.companyName != null) {
          //affiliate consultation
          mp['livecall'] = widget.arg['livecall'];
          filterConsultants = await ConsFilter.filterConsultantsForAffiliation(
              mp, widget.arg['livecall'], widget.companyName);
          widget.arg['specality'][i]['filter_consultant_list'] = filterConsultants ?? [];
          if (filterConsultants.length > 0) {
            special.add(widget.arg['specality'][i]);
          }
          notAvailableTxt = 'No Consultant available';
        }
      }
    }

    await loop();

    // special = widget.arg["specality"];
    // special.removeWhere((element) => element['filter_consultant_list'].length==0);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    IconData selectedIcon;
    double iconSize;
    if (widget.arg['consultation_type_name'].toString() == 'Doctor Consultation') {
      selectedIcon = Customicons.user_md_solid;
      iconSize = 50;
    } else if (widget.arg['consultation_type_name'].toString() == 'Fitness Class') {
      selectedIcon = Customicons.fitness_class;
      iconSize = 165;
    } else if (widget.arg['consultation_type_name'].toString() == 'Ayurvedic Consultation') {
      selectedIcon = Customicons.ayurvedic__consultation;
      iconSize = 165;
    } else if (widget.arg['consultation_type_name'].toString() == 'Diet Consultation') {
      selectedIcon = Customicons.diet_consultation;
      iconSize = 165;
    } else if (widget.arg['consultation_type_name'].toString() == 'Cardiology') {
      selectedIcon = Customicons.cardiology;
      iconSize = 50;
    } else if (widget.arg['consultation_type_name'].toString() == 'General Medical') {
      selectedIcon = Customicons.general_medical;
      iconSize = 50;
    } else if (widget.arg['consultation_type_name'].toString() == 'Pneumologist - Lungs') {
      selectedIcon = Customicons.pneumologist_lungs;
      iconSize = 45;
    } else if ((widget.arg['consultation_type_name'].toString() == 'Pediatrics') ||
        (widget.arg['consultation_type_name'].toString() == 'Pediatric - Child')) {
      selectedIcon = Customicons.pediatric_child;
      iconSize = 50;
    } else if (widget.arg['consultation_type_name'].toString() == 'Yoga') {
      selectedIcon = Customicons.pilates;
      iconSize = 187;
    } else if (widget.arg['consultation_type_name'].toString() == 'Zumba') {
      selectedIcon = Customicons.zumba;
      iconSize = 165;
    } else if (widget.arg['consultation_type_name'].toString() == 'Pilates') {
      selectedIcon = Customicons.pilates;
      iconSize = 187;
    } else if (widget.arg['consultation_type_name'].toString() == 'Boxing') {
      selectedIcon = Customicons.boxing;
      iconSize = 165;
    } else if (widget.arg['consultation_type_name'].toString() == 'Physical Therapy') {
      selectedIcon = Customicons.user_md_solid;
      iconSize = 50;
    } else if (widget.arg['consultation_type_name'].toString() == 'Transformation') {
      selectedIcon = Customicons.diet_consultation;
      iconSize = 170;
    } else if (widget.arg['consultation_type_name'].toString() == 'Diabetology') {
      selectedIcon = Customicons.diabetology;
      iconSize = 165;
    } else if (widget.arg['consultation_type_name'].toString() == 'Orthopaedics') {
      selectedIcon = Customicons.bone;
      iconSize = 45;
    } else if (widget.arg['consultation_type_name'].toString() == 'Health Consultation') {
      selectedIcon = Customicons.health_consultant;
      iconSize = 165;
    } else {
      selectedIcon = Customicons.general_medical;
      iconSize = 45;
    }
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return ConnectivityWidgetWrapper(
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
                  Navigator.pop(context);
                }, //replaces the screen to Main dashboard
                color: Colors.white,
              ),
              Flexible(
                //Health E-Market
                child: Text(
                  widget.arg['consultation_type_name'].toString() == 'Fitness Class'
                      ? 'Health E-Market'
                      : widget.arg['consultation_type_name'].toString(),
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
            visible: widget.arg['consultation_type_name'].toString() != 'Fitness Class',
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 18.0, left: 18.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      focusNode: typeAheadFocus,
                      // cursorColor:
                      // HexColor(widget.mealsListData.startColor),
                      controller: this._typeAheadController,
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
                        hintText: 'Search Consultants by Key words',
                        prefixIcon: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8, end: 8.0),
                          child: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      return await Consultants.getSuggestions(pattern,
                          companyName: widget.companyName);
                    },
                    itemBuilder: (context, suggestion) {
                      var price;
                      if (widget.companyName != null) {
                        // price = suggestion['affilation_excusive_data']['affilation_array'];
                        for (int i = 0;
                            i < suggestion['affilation_excusive_data']['affilation_array'].length;
                            i++) {
                          if (suggestion['affilation_excusive_data']['affilation_array'][i]
                                  ['affilation_unique_name'] ==
                              widget.companyName) {
                            price = suggestion['affilation_excusive_data']['affilation_array'][i]
                                ['affilation_price'];
                          }
                        }
                      } else {
                        price = suggestion['consultation_fees'];
                      }
                      return ListTile(
                        title: Text(suggestion['name']),
                        subtitle: Text("${suggestion['consultant_speciality'][0]}"),
                        trailing: Text('₹ ${price.toString()}'),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration:
                                BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: Image.memory(
                              base64Decode(AvatarImage.defaultUrl),
                            ),
                          ),
                        ),
                      );
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    onSuggestionSelected: (suggestion) async {
                      this._typeAheadController.text = '';
                      if (suggestion['vendor_id'] == 'GENIX') {
                        suggestion['livecall'] = false;
                      } else {
                        suggestion['livecall'] = widget.arg['livecall'];
                      }
                      // suggestion['livecall'] = widget.arg['livecall'];
                      suggestion['availabilityStatus'] =
                          await httpStatus(suggestion['ihl_consultant_id']);
                      if (widget.companyName == null) {
                        Get.to(
                          BookAppointment(
                            doctor: suggestion,
                            specality: suggestion['consultant_speciality'],
                          ),
                        );
                      } else {
                        var searchmp;
                        for (int i = 0; i < widget.arg["specality"].length; i++) {
                          if (widget.arg["specality"][i]['specality_name'] ==
                              suggestion['consultant_speciality'][0]) {
                            searchmp = widget.arg['specality'][i];
                            searchmp['livecall'] = widget.arg['livecall'];
                            var tempMp;
                            manipulateSearchmp(mp) {
                              for (int i = 0; i < mp['consultant_list'].length; i++) {
                                if (mp['consultant_list'][i]['name'] == suggestion['name']) {
                                  tempMp = mp['consultant_list'][i];
                                }
                              }

                              mp = tempMp;

                              ///
                              ///
                              // if (mp == null) {
                              //   return Text('error!');
                              // }
                              if (mp['availabilityStatus'] == null) {
                                mp['availabilityStatus'] = 'Online';
                                if (rndtf()) {
                                  mp['availabilityStatus'] = 'Busy';
                                }
                                if (rndtf()) {
                                  mp['availabilityStatus'] = 'Offline';
                                }
                              }
                              if (!(mp['name'] is String) || mp['name'] == null) {
                                mp['name'] = 'N/A';
                              }
                              if (!(mp['photo'] is String) || mp['photo'] == null) {
                                mp['photo'] =
                                    'https://banner2.cleanpng.com/20180330/fhq/kisspng-font-awesome-computer-icons-user-doctor-of-medicin-exam-5abeb2f7be2d97.697048921522447095779.jpg';
                              }
                              if (mp['ratings'] is num) {
                                mp['ratings'] = mp['ratings'] * 1.0;
                              }
                              if (mp['ratings'] is String) {
                                mp['ratings'] = double.tryParse(mp['ratings']);
                              }
                              if (mp['ratings'] == null) {
                                mp['ratings'] = 0.0;
                              }
                              mp['livecall'] = widget.arg['livecall'];
                              return mp;
                            }

                            searchmp = await manipulateSearchmp(searchmp);
                            print(searchmp);
                          }
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BookAppointmentForAffiliation(
                                      doctor: searchmp, //widget.consultant,
                                      companyName: widget.companyName,
                                    )));
                      }
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please type any letter to search';
                      }
                      return null;
                    },
                    noItemsFoundBuilder: (value) {
                      return (_typeAheadController.text == '' ||
                              _typeAheadController.text.length == 0 ||
                              _typeAheadController.text == null)
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'No Results Found',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.appTextColor, fontSize: 18.0),
                                  ),
                                ],
                              ),
                            );
                    },
                  ),

                  // CircleAvatar(
                  //   backgroundColor: Colors.white,
                  //   radius: 40,
                  //   child: Padding(
                  //     padding:
                  //         EdgeInsets.all(MediaQuery.of(context).size.height / 70),
                  //     child: Icon(
                  //       selectedIcon,
                  //       size: iconSize,
                  //     ),
                  //   ),
                  // ),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: getList(context: context),
                        ),
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
                                    widget.arg['consultation_type_name'].toString() ==
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

                                // updateExternalAppCount(
                                //     userID: iHLUserId,
                                //     mobileNumber: userMobile,
                                //     emailId: userEmail);
                                //print(careCredit);
                                // var openAppresult = await LaunchApp.openApp(
                                //     androidPackageName: 'com.smitfit',
                                //     iosUrlScheme:
                                //         'com.googleusercontent.apps.965763577963-ptpcp98nvchov5gu6d5okbrsiju4sfs2',
                                //     appStoreLink:
                                //         'https://apps.apple.com/in/app/smit-fit/id1525550488');
                                // print(
                                //     'openAppResult => $openAppresult ${openAppresult.runtimeType}');
                              },
                              //splashColor: color.withOpacity(0.5),
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
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Container(
                      //     margin: const EdgeInsets.only(
                      //       left: 9.0,
                      //       right: 9.0,
                      //       top: 12.0,
                      //     ),
                      //     decoration: BoxDecoration(
                      //         color: FitnessAppTheme.white,
                      //         borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(15.0),
                      //           bottomLeft: Radius.circular(15.0),
                      //           bottomRight: Radius.circular(15.0),
                      //           topRight: Radius.circular(15.0),
                      //           // topRight: Radius.circular(68.0)),
                      //         ),
                      //         boxShadow: <BoxShadow>[
                      //           BoxShadow(
                      //               color:
                      //                   FitnessAppTheme.grey.withOpacity(0.2),
                      //               offset: Offset(1.1, 1.1),
                      //               blurRadius: 10.0),
                      //         ]),
                      //     child: ListTile(
                      // onTap: () async {
                      //   isAppInstalled();
                      //   var openAppresult = await LaunchApp.openApp(
                      //       androidPackageName: 'com.smitfit',
                      //       iosUrlScheme:
                      //           'com.googleusercontent.apps.965763577963-ptpcp98nvchov5gu6d5okbrsiju4sfs2',
                      //       appStoreLink:
                      //           'com.googleusercontent.apps.965763577963-ptpcp98nvchov5gu6d5okbrsiju4sfs2');
                      //   print(
                      //       'openAppResult => $openAppresult ${openAppresult.runtimeType}');
                      // },
                      //       leading: CircleAvatar(
                      //         backgroundColor: Colors.white,
                      //         child: Padding(
                      //             padding: EdgeInsets.all(
                      //                 MediaQuery.of(context).size.height / 90),
                      //             child: SvgPicture.asset(
                      //               'assets/svgs/mobile-icon.svg',
                      //             )),
                      //       ),
                      //       title: Text(
                      //         "Connect to SmitFit",
                      //         style: TextStyle(
                      //           fontSize: 20,
                      //           color: AppColors.primaryColor,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // )
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
                            notAvailableTxt + '  Please try again later',
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
    );
  }
}

class Consultants {
  // static Future<List> getSuggestions(String query) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String iHLUserId = prefs.getString('ihlUserId');
  //   var food = [];
  //   List<Map<String, dynamic>> matches = [];
  //   final response = await http.get(
  //       Uri.parse(API.iHLUrl +
  //           '/consult/list_of_food_items_starts_with?search_string=' +
  //           query +
  //           '&ihl_user_id=$iHLUserId'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       });
  //   if (response.statusCode == 200) {
  //     food = jsonDecode(response.body);
  //   }
  //   print(food);
  //   for (int i = 0; i < food.length; i++) {
  //     matches.add(food[i]);
  //   }
  //   return matches;
  // }

  // static var mainList = [];
  static Future<List> getSuggestions(String query, {companyName}) async {
    var food = [];
    List<Map<String, dynamic>> matches = [];
    var mainList = [];
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse(API.iHLUrl + '/consult/consultant_trainer_search_filter'));
    request.body = json.encode({
      "is_affliated": companyName == null ? 'false' : "true",
      "affliation_name": companyName == null ? "ihl_care" : companyName,
      "key_word": "$query"
    });
    request.headers.addAll(
      {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final jsonString = await response.stream.bytesToString();
      final data = jsonDecode(jsonString);
      for (int i = 0; i < data.length; i++) {
        if (data['name_filter_list'].isNotEmpty) {
          mainList = data['name_filter_list'];
        }
        if (data['speciality_filter_list'].isNotEmpty) {
          mainList = data['speciality_filter_list'];
        }
        if (data['language_filter_list'].isNotEmpty) {
          mainList = data['language_filter_list'];
        }
      }
      print(mainList.toString());
      // for(int i = 0 ; i<mainList.length;i++){
      //   print(mainList[i]['ihl_consultant_id']);
      //   mainList[i]['availabilityStatus'] = httpStatus(mainList[i]['ihl_consultant_id']);
      // }
    } else {
      print(response.reasonPhrase);
    }
    print(food);
    for (int i = 0; i < food.length; i++) {
      matches.add(food[i]);
    }
    return mainList;
  }
}
