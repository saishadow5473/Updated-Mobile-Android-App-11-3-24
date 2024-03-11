import 'dart:convert';
import 'dart:developer' as log;
import 'dart:math';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:ihl/views/affiliation/bookAppointmentForAffiliation.dart';
import 'package:ihl/views/affiliation/selectConsultantCardForAffiliation.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:strings/strings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

import '../../constants/api.dart';
import '../../constants/spKeys.dart';
import '../../utils/app_colors.dart';
import '../../widgets/teleconsulation/bookClass.dart';
import '../teleconsultation/affiliationApp/smitFit_discription.dart';
import '../teleconsultation/consultantsFilter.dart';
import '../teleconsultation/controller/select_class_search_functionalities.dart';
import 'selectClassCardForAffiliation.dart';

class ClassAndConsultantScreen extends StatefulWidget {
  ClassAndConsultantScreen({this.companyName, this.category, this.categorySmit});

  String companyName;
  String category;
  String categorySmit;

  @override
  State<ClassAndConsultantScreen> createState() => _ClassAndConsultantScreenState();
}

class _ClassAndConsultantScreenState extends State<ClassAndConsultantScreen> {
  String iHLUserId;
  String userEmail;
  String userMobile;
  bool isAppInstalledResult = false;

  @override
  void initState() {
    getData();
    super.initState();
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

  List specalityTypes = [];
  List special = [];
  List classSpecialityType = [];
  List classList = [];
  List consultantList = [];
  List bothTwo = [];
  bool isLoading = false;

  //consultant properties
  var affConsultants = [];
  List languageFilters = [];

  //Search option Variables
  final TextEditingController _typeAheadController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Uint8List image = base64Decode(AvatarImage.classUrl);
  Uint8List image1 = base64Decode(AvatarImage.defaultUrl);
  FocusNode typeAheadFocus = new FocusNode();
  bool showText = true;
  bool searchLoad = true;
  List allList = [];
  var searchResults = [];
  ValueNotifier<dynamic> updatedSearchList = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    return ScrollessBasicPageUI(
      appBar: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.white,
              ),
              Flexible(
                child: widget.category == 'Health E-Market'
                    ? Text(
                        "Services",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      )
                    : widget.category == null
                        ? Text(
                            "Classes",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          )
                        : Text(
                            "Consultants And Classes",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
              ),
              SizedBox(
                width: 40,
              )
            ],
          ),
          Visibility(
              visible: false,
              child: Container(
                  margin: EdgeInsets.fromLTRB(10, 7, 10, 10),
                  //     top: 20, left: 20, right: 20),
                  alignment: Alignment.topLeft,
                  child: Form(
                      key: _formKey,
                      child: Theme(
                        data: ThemeData(
                          primaryColor: Colors.white,
                        ),
                        child: Autocomplete(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<Map<String, dynamic>>.empty();
                            }
                            return updatedSearchList.value.where((option) {
                              final String name = option['title'].toString().toLowerCase();
                              return name.contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) {
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                focusColor: Colors.white,
                                labelStyle: typeAheadFocus.hasPrimaryFocus
                                    ? TextStyle(
                                        color: Colors.white,
                                      )
                                    : TextStyle(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
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
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.white,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(30.0),
                                  ),
                                ),
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                hintText: 'Search ',
                                hintStyle: TextStyle(color: Colors.white, fontSize: 18.px),
                                prefixIcon: Padding(
                                  padding: const EdgeInsetsDirectional.only(start: 8, end: 8.0),
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onChanged: (value) async {
                                var _list = [];
                                _list = await SelectClassSearch.getSuggestion(
                                    pattern: value, classes: allList);
                                searchResults.clear();
                                //searchResults = _list;
                                print(_list.runtimeType);

                                updatedSearchList.value.clear();
                                updatedSearchList.value = _list;
                                textEditingController.notifyListeners();
                                setState(() {});
                              },
                              onSubmitted: (value) {},
                            );
                          },
                          // displayStringForOption: (option) => option['title'].toString(),
                          optionsViewBuilder: (contx, onSelected, option) {
                            return ValueListenableBuilder(
                                valueListenable: updatedSearchList,
                                builder: (con, value, _) {
                                  return ListView.builder(
                                      padding: EdgeInsets.all(0),
                                      itemCount: value.length,
                                      itemBuilder: (ctx, i) {
                                        var option = value.elementAt(i);
                                        return option != null
                                            ? Material(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    this._typeAheadController.text =
                                                        option['title'];
                                                    bool isClass = false;
                                                    if (option.containsKey("course_id")) {
                                                      isClass = true;
                                                    } else {
                                                      isClass = false;
                                                    }
                                                    try {
                                                      if (isClass) {
                                                        Map map = allList
                                                            .where((element) =>
                                                                element["course_id"] ==
                                                                option["course_id"])
                                                            .toList()
                                                            .first;
                                                        // map.remove("amount");
                                                        // map.remove("img");
                                                        // map.remove("title");
                                                        if (map["subscribed"] == "true" ||
                                                            map["subscribed"] == "process") {
                                                          AwesomeDialog(
                                                                  context: context,
                                                                  animType: AnimType.TOPSLIDE,
                                                                  headerAnimationLoop: true,
                                                                  dialogType: DialogType.NO_HEADER,
                                                                  title:
                                                                      'Course already Subscribed!',
                                                                  desc:
                                                                      'You cannot subscribe for already subscribed courses',
                                                                  btnOkOnPress: () {
                                                                    _typeAheadController.clear();
                                                                    updatedSearchList.value.clear();
                                                                  },
                                                                  btnOkColor: Colors.green,
                                                                  btnOkText: 'OK',
                                                                  btnOkIcon: Icons.check,
                                                                  onDismissCallback: (_) {})
                                                              .show();
                                                        } else
                                                          Get.to(BookClass(
                                                            course: map,
                                                            courses: allList,
                                                            notificationRoute: false,
                                                          ));
                                                      } else {
                                                        Map map = allList
                                                            .where((e) {
                                                              if (e["vendor_id"] == "GENIX") {
                                                                return e['vendor_consultant_id'] ==
                                                                    option["vendor_consultant_id"];
                                                              } else {
                                                                return e['ihl_consultant_id'] ==
                                                                    option["ihl_consultant_id"];
                                                              }
                                                            })
                                                            .toList()
                                                            .first;
                                                        // map.remove("amount");
                                                        // map.remove("img");
                                                        // map.remove("title");
                                                        Get.to(BookAppointmentForAffiliation(
                                                          doctor: map,
                                                          companyName: widget.companyName,
                                                        ));
                                                        // Navigator.push(
                                                        //     context,
                                                        //     MaterialPageRoute(
                                                        //         builder: (context) => BookAppointmentForAffiliation(
                                                        //               doctor: widget.consultant,
                                                        //               companyName: widget.companyName,
                                                        //             )));
                                                      }
                                                    } catch (e) {
                                                      print(e.toString());
                                                    }
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors.grey, width: 0.3))),
                                                    child: ListTile(
                                                      tileColor: Colors.grey.shade50,
                                                      contentPadding:
                                                          EdgeInsets.only(top: 5, bottom: 5),
                                                      leading: Container(
                                                        height: 20.w,
                                                        width: 20.w,
                                                        child: option.containsKey('course_id')
                                                            ? Image.memory(image)
                                                            : Image.memory(image1),
                                                      ),
                                                      title: Text(option['title'] != "" ||
                                                              option['title'] != null
                                                          ? option['title']
                                                          : "Title"),
                                                      subtitle: option.containsKey('course_id')
                                                          ? Text(option['speciality'] != "" ||
                                                                  option['speciality'] != null
                                                              ? option['speciality']
                                                              : "speciality")
                                                          : Text(option['title'] != "" ||
                                                                  option['title'] != null
                                                              ? option['title']
                                                              : "title"),
                                                      trailing: Padding(
                                                        padding: const EdgeInsets.only(right: 30),
                                                        child: Text(option.containsKey('course_id')
                                                            ? (option['course_fees'].toString() +
                                                                " ₹")
                                                            : (option['amount'].toString() + " ₹")),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : ListTile();
                                      });
                                });
                          },
                        ),
                      )))),
          Visibility(
            visible: false,
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 7, 10, 10),
              //     top: 20, left: 20, right: 20),
              alignment: Alignment.topLeft,
              child: Form(
                key: _formKey,
                child: Theme(
                  data: ThemeData(
                    primaryColor: Colors.white,
                  ),
                  child: TypeAheadFormField(
                    getImmediateSuggestions: false,
                    hideSuggestionsOnKeyboardHide: false,
                    textFieldConfiguration: TextFieldConfiguration(
                        style: TextStyle(color: Colors.white),
                        focusNode: typeAheadFocus,
                        controller: this._typeAheadController,
                        onTap: () {
                          showText = false;
                          Future.delayed(Duration(seconds: 1), () {
                            if (mounted) setState(() {});
                          });
                        },
                        onSubmitted: (val) {
                          showText = true;
                          Future.delayed(Duration(seconds: 1), () {
                            if (mounted) setState(() {});
                          });
                        },
                        decoration: InputDecoration(
                          focusColor: Colors.white,
                          labelStyle: typeAheadFocus.hasPrimaryFocus
                              ? TextStyle(
                                  color: Colors.white,
                                )
                              : TextStyle(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
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
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.white,
                            ),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(30.0),
                            ),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          hintText: 'Search ',
                          hintStyle: TextStyle(color: Colors.white, fontSize: 18.px),
                          prefixIcon: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 8, end: 8.0),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                          ),
                        )),
                    suggestionsCallback: (pattern) async {
                      if (pattern == '') {
                        showText = true;
                        Future.delayed(Duration(seconds: 1), () {
                          if (mounted) setState(() {});
                        });
                        return [];
                      } else {
                        showText = false;
                        Future.delayed(Duration(seconds: 1), () {
                          if (mounted) setState(() {});
                        });
                        searchLoad = true;
                        var _list = [];
                        _list = await SelectClassSearch.getSuggestion(
                            pattern: pattern, classes: allList);
                        //     .then((value) {
                        searchLoad = false;
                        //   if (value.length > 0) {
                        //     _list = value;
                        //   }
                        if (mounted) setState(() {});
                        // });

                        return _list;
                      }
                    },
                    itemBuilder: (context, suggestion) {
                      bool isClass = false;
                      if (suggestion.containsKey("course_id")) {
                        isClass = true;
                      } else {
                        isClass = false;
                      }
                      return searchLoad
                          ? Shimmer.fromColors(
                              child: Container(
                                  margin: EdgeInsets.all(8),
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width / 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('Hello')),
                              direction: ShimmerDirection.ltr,
                              period: Duration(seconds: 2),
                              baseColor: Colors.white,
                              highlightColor: Colors.grey.withOpacity(0.2))
                          : suggestion != null
                              ? Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(color: Colors.grey, width: 0.3))),
                                  child: ListTile(
                                    tileColor: Colors.grey.shade50,
                                    contentPadding: EdgeInsets.only(top: 5, bottom: 5),
                                    leading: Container(
                                      height: 20.w,
                                      width: 20.w,
                                      decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: isClass
                                                  ? MemoryImage(base64Decode(AvatarImage.classUrl))
                                                  : MemoryImage(
                                                      base64Decode(AvatarImage.defaultUrl)))),
                                    ),
                                    title: Text(
                                        suggestion['title'] != "" || suggestion['title'] != null
                                            ? suggestion['title']
                                            : "Title"),
                                    subtitle: isClass
                                        ? Text(suggestion['speciality'] != "" ||
                                                suggestion['speciality'] != null
                                            ? suggestion['speciality']
                                            : "speciality")
                                        : Text(
                                            suggestion['title'] != "" || suggestion['title'] != null
                                                ? suggestion['title']
                                                : "title"),
                                    trailing: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(isClass
                                          ? (suggestion['course_fees'].toString() + " ₹")
                                          : (suggestion['amount'].toString() + " ₹")),
                                    ),
                                  ),
                                )
                              : ListTile();
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    onSuggestionSelected: (suggestion) async {
                      this._typeAheadController.text = suggestion['title'];
                      bool isClass = false;
                      if (suggestion.containsKey("course_id")) {
                        isClass = true;
                      } else {
                        isClass = false;
                      }
                      try {
                        if (isClass) {
                          Map map = allList
                              .where((element) => element["course_id"] == suggestion["course_id"])
                              .toList()
                              .first;
                          // map.remove("amount");
                          // map.remove("img");
                          // map.remove("title");
                          if (map["subscribed"] == "true" || map["subscribed"] == "process") {
                            AwesomeDialog(
                                    context: context,
                                    animType: AnimType.TOPSLIDE,
                                    headerAnimationLoop: true,
                                    dialogType: DialogType.NO_HEADER,
                                    dismissOnTouchOutside: false,
                                    title: 'Course already Subscribed!',
                                    desc: 'You cannot subscribe for already subscribed courses',
                                    btnOkOnPress: () {
                                      _typeAheadController.text = "";
                                    },
                                    btnOkColor: Colors.green,
                                    btnOkText: 'OK',
                                    btnOkIcon: Icons.check,
                                    onDismissCallback: (_) {})
                                .show();
                          } else
                            Get.to(BookClass(
                              course: map,
                              courses: allList,
                              notificationRoute: false,
                            ));
                        } else {
                          Map map = allList
                              .where((e) {
                                if (e["vendor_id"] == "GENIX") {
                                  return e['vendor_consultant_id'] ==
                                      suggestion["vendor_consultant_id"];
                                } else {
                                  return e['ihl_consultant_id'] == suggestion["ihl_consultant_id"];
                                }
                              })
                              .toList()
                              .first;
                          // map.remove("amount");
                          // map.remove("img");
                          // map.remove("title");
                          Get.to(BookAppointmentForAffiliation(
                            doctor: map,
                            companyName: widget.companyName,
                          ));
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => BookAppointmentForAffiliation(
                          //               doctor: widget.consultant,
                          //               companyName: widget.companyName,
                          //             )));
                        }
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please type any letter to search';
                      }
                      return null;
                    },
                    noItemsFoundBuilder: (value) {
                      return searchLoad
                          ? Shimmer.fromColors(
                              child: Container(
                                  margin: EdgeInsets.all(8),
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width / 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('Hello')),
                              direction: ShimmerDirection.ltr,
                              period: Duration(seconds: 2),
                              baseColor: Colors.white,
                              highlightColor: Colors.grey.withOpacity(0.2))
                          : (_typeAheadController.text == '' ||
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
                                        style: TextStyle(
                                            color: AppColors.appTextColor, fontSize: 18.0),
                                      ),
                                    ],
                                  ),
                                );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SizedBox(
          height: Device.height,
          width: Device.width,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : (!isLoading) && bothTwo.isEmpty && widget.categorySmit == null
                  ? widget.category == "Health E-Market"
                      ? const Center(
                          child: Text("No Services Found"),
                        )
                      : const Center(
                          child: Text("No Consultant or Sessions Found"),
                        )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          if (widget.categorySmit != null && widget.companyName == "persistent")
                            GestureDetector(
                                onTap: () async {
                                  if (Platform.isIOS) {
                                    bool a = await launchUrl(Uri.parse('com.smit.fit://'),
                                        mode: LaunchMode.externalApplication);
                                    print(a);
                                    if (a == false) {
                                      Get.to(AffilicationAppDescription(
                                        iHLUserId: iHLUserId,
                                        userMobile: userMobile,
                                        userEmail: userEmail,
                                      ));
                                    }
                                  } else {
                                    var isAppInstalledResult = await LaunchApp.isAppInstalled(
                                        androidPackageName: 'com.smitfit',
                                        iosUrlScheme: 'com.smit.fit://'
                                        // openStore: false
                                        );
                                    isAppInstalledResult
                                        ? LaunchApp.openApp(
                                            androidPackageName: 'com.smitfit',
                                            iosUrlScheme: 'com.smit.fit://',
                                            appStoreLink:
                                                'https://apps.apple.com/in/app/smit-fit/id1525550488')
                                        : Get.to(AffilicationAppDescription(
                                            iHLUserId: iHLUserId,
                                            userMobile: userMobile,
                                            userEmail: userEmail,
                                          ));
                                  }
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 4,
                                  child: Row(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(
                                            right: 11.0,
                                            left: 30.0,
                                          ),
                                          child: Image.asset(
                                            'assets/images/Smitfit_playstore.png',
                                            height: 16.h,
                                            width: 25.w,
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Connect to SmitFit',
                                          style: TextStyle(
                                            letterSpacing: 1.0,
                                            fontSize: 17.sp,
                                            color: AppColors.primaryAccentColor,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                          SizedBox(
                            height: 1.h,
                          ),
                          ...bothTwo.map((e) {
                            // var data = bothTwo[index];
                            if (e.containsKey("course_id")) {
                              return getCard(e, 0);
                            } else {
                              return createCard(mp: e, index: 0);
                            }
                          }).toList()
                          // ListView.builder(
                          //     itemCount: bothTwo.length,
                          //     itemBuilder: (ctx, index) {
                          //       var data = bothTwo[index];
                          //       if (data.containsKey("course_id")) {
                          //         return getCard(data, index);
                          //       } else {
                          //         return createCard(mp: data, index: index);
                          //       }
                          //     }),
                        ],
                      ),
                    )
          // SingleChildScrollView(
          //             child: Padding(
          //               padding: const EdgeInsets.all(8.0),
          //               child: Column(
          //                 children: bothTwo.map((e) {
          //                   if (e.containsKey("course_id")) {
          //                     return getCard(e, bothTwo.indexOf(e));
          //                   }
          //                   // else {
          //                   //   return InkWell(onTap: () => log(jsonEncode(e)), child: Text(e["name"]));
          //                   // }
          //
          //                   else {
          //                     return createCard(mp: e, index: bothTwo.indexOf(e));
          //                   }
          //                 }).toList(),
          //               ),
          //             ),
          //           ),
          ),
    );
  }

  Widget getCard(Map map, int index) {
    // log(jsonEncode(map));
    var currentDateTime = new DateTime.now();
    var courseDuration = map["course_duration"];
    String courseEndDuration = courseDuration.substring(13, 23);
    int lastIndexValue = map["course_time"].length - 1;
    String courseEndTimeFullValue = map["course_time"][lastIndexValue]; //02:00 PM - 07:00 PM
    String courseEndTime = courseEndTimeFullValue.substring(
        courseEndTimeFullValue.indexOf("-") + 1, courseEndTimeFullValue.length); //07:00 PM
    courseEndDuration = courseEndDuration + courseEndTime; //20-04-2022 07:00 PM
    DateTime endDate;
    if (courseEndTime != " Invalid DateTime") {
      try {
        endDate = new DateFormat("dd-MM-yyyy hh:mm a").parse(courseEndDuration);
      } catch (e) {
        endDate = new DateFormat("MM-dd-yyyy hh:mm a").parse(courseEndDuration);
      }
    } else {
      endDate = DateTime.now().subtract(Duration(days: 365));
    }

    if (endDate.isBefore(currentDateTime) ||
        map["affilation_excusive_data"] == {} ||
        map["affilation_excusive_data"] == null) {
      // bothTwo.removeWhere((element) => element["course_id"] == map["course_id"]);
      setState(() {});
      return Container();
    } else {
      // noClassIsActive = false;
      // if (map["affilation_excusive_data"] == {} ||
      //     map["affilation_excusive_data"]["affilation_array"] == null ||
      //     map["affilation_excusive_data"]["affilation_array"].length == 0 ||
      //     map["affilation_excusive_data"]["affilation_array"][0]["affilation_unique_name"] !=
      //         widget.companyName) {
      //   return Container();
      // } else {
      // map.remove("amount");
      // map.remove("img");
      // map.remove("title");
      // return widget.companyName == "persistent" && widget.categorySmit == "Health E-Market"
      //     ? Column(children: [
      //         SizedBox(
      //           height: 1.h,
      //         ),
      //         GestureDetector(
      //             onTap: () async {
      //               if (Platform.isIOS) {
      //                 bool a = await launchUrl(Uri.parse('com.smit.fit://'),
      //                     mode: LaunchMode.externalApplication);
      //                 print(a);
      //                 if (a == false) {
      //                   Get.to(AffilicationAppDescription(
      //                     iHLUserId: iHLUserId,
      //                     userMobile: userMobile,
      //                     userEmail: userEmail,
      //                   ));
      //                 }
      //               } else {
      //                 var isAppInstalledResult = await LaunchApp.isAppInstalled(
      //                     androidPackageName: 'com.smitfit', iosUrlScheme: 'com.smit.fit://'
      //                     // openStore: false
      //                     );
      //                 isAppInstalledResult
      //                     ? LaunchApp.openApp(
      //                         androidPackageName: 'com.smitfit',
      //                         iosUrlScheme: 'com.smit.fit://',
      //                         appStoreLink: 'https://apps.apple.com/in/app/smit-fit/id1525550488')
      //                     : Get.to(AffilicationAppDescription(
      //                         iHLUserId: iHLUserId,
      //                         userMobile: userMobile,
      //                         userEmail: userEmail,
      //                       ));
      //               }
      //             },
      //             child: Card(
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(15),
      //               ),
      //               elevation: 4,
      //               child: Row(
      //                 children: [
      //                   Padding(
      //                       padding: const EdgeInsets.only(
      //                         right: 11.0,
      //                         left: 30.0,
      //                       ),
      //                       child: Image.asset(
      //                         'assets/images/Smitfit_playstore.png',
      //                         height: 16.h,
      //                         width: 25.w,
      //                       )),
      //                   Padding(
      //                     padding: const EdgeInsets.all(8.0),
      //                     child: Text(
      //                       'Connect to SmitFit',
      //                       style: TextStyle(
      //                         letterSpacing: 1.0,
      //                         fontSize: 17.sp,
      //                         color: AppColors.primaryAccentColor,
      //                       ),
      //                     ),
      //                   )
      //                 ],
      //               ),
      //             )),
      //         SizedBox(
      //           height: 1.h,
      //         ),
      //         SelectClassCardForAffiliation(index, map, map, widget.companyName),
      //       ])
      //     :
      return SelectClassCardForAffiliation(index, map, map, widget.companyName);
    }
    // }
  }

  Future getData() async {
    isLoading = true;
    setState(() {});
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res1 = jsonDecode(data1);
    String iHLUserId = res1['User']['id'];

    final getPlatformData = await http.post(
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
      // loading = false;
      if (res['consult_type'] == null ||
          !(res['consult_type'] is List) ||
          res['consult_type'].isEmpty) {
        return;
      }
      var consultationType = res['consult_type'];

      for (int i = 0; i < consultationType.length; i++) {
        if (consultationType[i]["consultation_type_name"] == "Medical Consultation") {
          consultationType[i]["consultation_type_name"] = "Doctor Consultation";
        }
        if (consultationType[i]["consultation_type_name"] == "Fitness Class") {
          classSpecialityType.add(consultationType[i]["specality"]);
          consultationType.removeAt(i);
        }
        consultationType[i]["specality"].removeWhere((e) => e["consultant_list"].length == 0);
      }
      for (var e in consultationType) {
        for (var i in e["specality"]) {
          // log(i["specality_name"]);
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

  getVisibilityForSpeciality() async {
    List filterConsultants = [];
    loop() async {
      for (int i = 0; i < specalityTypes.length; i++) {
        var mp = specalityTypes[i];
        if (mp["courses"] != null && widget.companyName == null) {
          //normal class
          var activeClass = await ConsFilter.filterNonAffiliatedCourses(mp);
          if (activeClass) {
            special.add(specalityTypes[i]);
          }
        }

        if (mp["consultant_list"] != null && widget.companyName == null) {
          //normal consultation    ///SelectConsutantScreen
          filterConsultants = await ConsFilter.filterNonAffiliatedConsultants(mp, true);
          specalityTypes[i]['filter_consultant_list'] = filterConsultants ?? [];
          if (filterConsultants.length > 0) {
            special.add(specalityTypes[i]);
          }
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
        }
      }
      consultantAndClassGetter();
    }

    await loop();
    setState(() {});
  }

  consultantAndClassGetter() async {
    print(special.toList().toString());

    for (int i = 0; i < special.length; i++) {
      for (var e in special[i]["consultant_list"]) {
        consultantList.add(e);
      }
    }
    classSpecialityType = classSpecialityType[0];
    List ss = [];
    for (var e in classSpecialityType) {
      bool active = await ConsFilter.filterCoursesForAffiliation(e, widget.companyName);
      if (active) {
        ss.add(e);
      }
    }
    for (int i = 0; i < ss.length; i++) {
      for (var e in ss[i]["courses"]) {
        classList.add(e);
      }
    }
    classList.map((e) => e["name"] = e["title"]).toList();
    consultantList.map((e) => e["title"] = e["name"]).toList();
    consultantList.removeWhere((map) {
      // map["affilation_excusive_data"] == {} ||
      // map["affilation_excusive_data"]["affilation_array"] == null ||
      // map["affilation_excusive_data"]["affilation_array"].length == 0 ||
      try {
        List affii = [];
        affii.clear();
        if (map["affilation_excusive_data"] != {} ||
            map["affilation_excusive_data"]["affilation_array"] != null) {
          for (int i = 0; i < map["affilation_excusive_data"]["affilation_array"].length; i++) {
            map["affilation_excusive_data"]["affilation_array"][i]["affilation_unique_name"] !=
                    widget.companyName
                ? affii.add(true)
                : affii.add(false);
          }
          return !affii.contains(false);
        } else {
          return true;
        }
      } catch (e) {
        return true;
      }
    });
    // consultantList.map((e) => log.log(e["name"])).toList();

    filterConsultantsForAffiliation();
    // print(consultantList.toList().toString() + classList.toList().toString());
    if (classList.isNotEmpty) {
      classList.removeWhere((element) => currentClass(map: element));
    }
    if (classList.isNotEmpty == true) {
      classList.map((e) async {
        e = await SelectClassSearch().subscriptionChecker(map: e);
      }).toList();
    }
    if (widget.category != null) {
      bothTwo = consultantList + classList;
    } else {
      bothTwo = classList;
      bothTwo.removeWhere((element) => element["category"] != "" && element["category"] != null);
    }
    if (widget.category != null) {
      bothTwo.map((e) => log.log(e["category"].toString())).toList();
      bothTwo.removeWhere((element) =>
          element["category"] == "" ||
          element["category"] == null ||
          element["category"].toLowerCase() != widget.category.toLowerCase());
    }
    bothTwo.removeWhere((map) {
      try {
        List affii = [];
        affii.clear();
        if (map["affilation_excusive_data"] != {} ||
            map["affilation_excusive_data"]["affilation_array"] != null) {
          for (int i = 0; i < map["affilation_excusive_data"]["affilation_array"].length; i++) {
            map["affilation_excusive_data"]["affilation_array"][i]["affilation_unique_name"] !=
                    widget.companyName
                ? affii.add(true)
                : affii.add(false);
          }
          return !affii.contains(false);
        } else {
          return true;
        }
      } catch (e) {
        return true;
      }
    });
    for (var e in bothTwo) {
      String amount = e["affilation_excusive_data"]["affilation_array"]
          .where((ee) => ee["affilation_unique_name"] == widget.companyName)
          .first["affilation_price"];
      e["amount"] = amount;
    }
    // if (classList.isNotEmpty == true) {
    //   classList.map((e) async {
    //     e = await SelectClassSearch().subscriptionChecker(map: e);
    //   }).toList();
    // }
    allList = bothTwo;
    isLoading = false;
    setState(() {});
  }

  filterConsultantsForAffiliation() async {
    var flatConsultants = consultantList;

    var affiliatedConsultants = [];

    for (int i = 0; i < flatConsultants.length; i++) {
      if (true) {
        var imageValue = await getConsultantImageURL(flatConsultants[i]['vendor_id'] == "GENIX"
            ? [flatConsultants[i]['vendor_consultant_id'], flatConsultants[i]['vendor_id']]
            : [flatConsultants[i]['ihl_consultant_id'], flatConsultants[i]['vendor_id']]);
        // flatConsultants[i]['ihl_consultant_id']);
        flatConsultants[i]['profile_picture'] = imageValue;
      }
      if (flatConsultants[i]['affilation_excusive_data'] != null) {
        if (flatConsultants[i]['affilation_excusive_data'].length != 0) {
          if (flatConsultants[i]['affilation_excusive_data']['affilation_array'].length != 0) {
            if (flatConsultants[i]["ihl_consultant_id"] != "b82fd0384bba473086aaae70a7222a55") {
              affiliatedConsultants.add(flatConsultants[i]);
            }
          }
        }
      }
    }

    var affiliationArray = [];

    List<dynamic> newList = [];
    List<dynamic> newList1 = [];

    if (affiliatedConsultants.length != 0) {
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
          affConsultants.removeWhere((element) => element['provider'] == 'APOLLO');
          if (this.mounted) {
            setState(() {
              //_isLoading = false;
              affiliationArray.clear();
              newList.clear();
              newList1.clear();
            });
          }
        } else {
          affiliationArray.clear();
          if (this.mounted) {
            setState(() {
              //_isLoading = false;
              newList.clear();
              newList1.clear();
            });
          }
        }
      }
    }
    consultantList = affConsultants;
    onlineFilter();
    if (mounted) setState(() {});
    print(affConsultants);
  }

  Future<String> getConsultantImageURL(
    var map,
  ) async {
    try {
      var bodyGenix = jsonEncode(<String, dynamic>{
        'vendorIdList': [map[0]],
        "consultantIdList": [""],
      });
      var bodyIhl = jsonEncode(<String, dynamic>{
        'consultantIdList': [map[0]],
        "vendorIdList": [""],
      });
      final response = await http.post(
        Uri.parse(API.iHLUrl + "/consult/profile_image_fetch"),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: map[1] == "GENIX" ? bodyGenix : bodyIhl,
      );
      if (response.statusCode == 200) {
        var imageOutput = json.decode(response.body);
        var consultantIDAndImage =
            map[1] == 'GENIX' ? imageOutput["genixbase64list"] : imageOutput["ihlbase64list"];
        for (var i = 0; i < consultantIDAndImage.length; i++) {
          if (map[0] == consultantIDAndImage[i]['consultant_ihl_id']) {
            var base64Image = consultantIDAndImage[i]['base_64'].toString();
            base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
            base64Image = base64Image.replaceAll('}', '');
            base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
            var image;
            var consultantImage;
            if (this.mounted) {
              setState(() {
                consultantImage = base64Image;
              });
            }
            if (consultantImage == null || consultantImage == "") {
              return AvatarImage.defaultUrl;
            } else {
              image = Image.memory(base64Decode(consultantImage));
              return consultantImage;
            }
          }
        }
      } else {
        return AvatarImage.defaultUrl;
      }
    } catch (e) {
      print(e.toString());
      return AvatarImage.defaultUrl;
    }
  }

  void onlineFilter() async {
    var docStatus;
    List filteredResults = [];
    for (int i = 0; i <= affConsultants.length - 1; i++) {
      docStatus = await httpStatus(affConsultants[i]['ihl_consultant_id']);
      var imageValue = await getConsultantImageURL(affConsultants[i]['vendor_id'] == "GENIX"
          ? [affConsultants[i]['vendor_consultant_id'], affConsultants[i]['vendor_id']]
          : [affConsultants[i]['ihl_consultant_id'], affConsultants[i]['vendor_id']]);
      affConsultants[i]['profile_picture'] = imageValue;
      if (docStatus == 'Online' || docStatus == 'online' || docStatus == 'M' || docStatus == 'F') {
        // Uncomment this commented func if need of online consultant on top and offline consultant next to that in same list
        filteredResults.insert(0, affConsultants[i]);
      } else {
        // Uncomment this commented func if need of online consultant on top and offline consultant next to that in same list
        // filteredResults.add(results[i]);
        filteredResults.add(affConsultants[i]);
      }
    }
    if (this.mounted) {
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          affConsultants = filteredResults;
          //affConsultants.length != 0 ??
          //    affConsultants.sort((a, b) => a["name"].compareTo(b["name"]));
        });
      });
    }
  }

  Future<String> httpStatus(var consultantId) async {
    var status;
    final response = await http.post(
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
          if (this.mounted) {
            setState(() {
              status = camelize(finalOutput[0]['status'].toString());
            });
          }
        }
      } else {}
    } else {
      print('response failure');
    }

    return status;
  }

  void reset() {
    if (this.mounted) {
      setState(() {
        onlineFilter();
      });
    }
  }

  void updateLanguageFilter() {
    reset();
    if (languageFilters.length == 0) {
      return;
    }
    List filtered = [];
    for (var k in languageFilters) {
      for (int i = 0; i < affConsultants.length; i++) {
        if (affConsultants[i]['languages_Spoken'].contains(k)) {
          filtered.add(affConsultants[i]);
        }
      }
    }
    if (this.mounted) {
      setState(() {
        affConsultants = filtered;
      });
    }
  }

  void removeLanguageFilter(String lang) {
    languageFilters.remove(lang);
    updateLanguageFilter();
  }

  void filterByLanguage(String lang) {
    if (languageFilters.contains(lang)) {
      return;
    }
    languageFilters.add(lang);
    updateLanguageFilter();
  }

  bool rndtf() {
    Random rnd = Random();
    return rnd.nextBool();
  }

  Widget createCard({Map mp, int index}) {
    if (mp == null) {
      return Text('error!');
    }
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
    mp['livecall'] = true;
    // if (mp["affilation_excusive_data"] == {} ||
    //     mp["affilation_excusive_data"]["affilation_array"] == null ||
    //     mp["affilation_excusive_data"]["affilation_array"].length == 0 ||
    //     mp["affilation_excusive_data"]["affilation_array"][0]["affilation_unique_name"] !=
    //         widget.companyName) {
    //   return Container();
    // } else {
    // return SelectClassCardForAffiliation(index, map, map, widget.companyName);
    // mp.remove("amount");
    // mp.remove("img");
    // mp.remove("title");
    return SelectConsultantCardForAffiliation(
      index,
      widget.companyName,
      mp,
      mp["consultant_speciality"][0],
      true,
      languageFilter: filterByLanguage,
      isDirectCall: true,
    );
    // }
    // try {
    // } catch (e) {
    //   return Container();
    // }
  }

  checkIfAffi(List affiList) {
    List sett = [];
    for (int i = 0; i < affiList.length; i++) {
      sett.add(affiList[i]["affilation_unique_name"] == widget.companyName);
    }
    (sett.toList());
  }

  currentClass({Map map}) {
    var currentDateTime = new DateTime.now();
    var courseDuration = map["course_duration"];
    String courseEndDuration = courseDuration.substring(13, 23);
    int lastIndexValue = map["course_time"].length - 1;
    String courseEndTimeFullValue = map["course_time"][lastIndexValue]; //02:00 PM - 07:00 PM
    String courseEndTime = courseEndTimeFullValue.substring(
        courseEndTimeFullValue.indexOf("-") + 1, courseEndTimeFullValue.length); //07:00 PM
    courseEndDuration = courseEndDuration + courseEndTime; //20-04-2022 07:00 PM
    DateTime endDate;
    if (courseEndTime != " Invalid DateTime") {
      endDate = new DateFormat("dd-MM-yyyy hh:mm a").parse(courseEndDuration);
    } else {
      endDate = DateTime.now().subtract(Duration(days: 365));
    }

    if (endDate.isBefore(currentDateTime) ||
        map["affilation_excusive_data"] == {} ||
        map["affilation_excusive_data"] == null) {
      // bothTwo.removeWhere((element) => element["course_id"] == map["course_id"]);
      setState(() {});
      return true;
    } else {
      // noClassIsActive = false;
      if (map["affilation_excusive_data"] == {} ||
          map["affilation_excusive_data"]["affilation_array"] == null ||
          map["affilation_excusive_data"]["affilation_array"].length == 0 ||
          map["affilation_excusive_data"]["affilation_array"][0]["affilation_unique_name"] !=
              widget.companyName) {
        if (map["affilation_excusive_data"]["affilation_array"] == null ||
            map["affilation_excusive_data"]["affilation_array"].length < 1) {
          return false;
        } else {
          List<dynamic> afi = map["affilation_excusive_data"]["affilation_array"];
          bool val = true;
          afi.map((e) {
            if (e["affilation_unique_name"] == widget.companyName) {
              val = false;
            }
          }).toList();
          return val;
        }
      } else {
        return false;
      }
    }
  }
}
