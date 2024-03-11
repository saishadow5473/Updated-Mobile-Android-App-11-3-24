import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:ihl/widgets/teleconsulation/selectClassCard.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../widgets/teleconsulation/bookClass.dart';
import 'controller/select_class_search_functionalities.dart';

/// Select Classes Screen 👀👀 always give argument for data 💣💥

// ignore: must_be_immutable
class SelectClassesScreen extends StatefulWidget {
  Map arg;
  List list;
  SelectClassesScreen({@required this.arg, this.list});

  @override
  _SelectClassesScreenState createState() => _SelectClassesScreenState();
}

class _SelectClassesScreenState extends State<SelectClassesScreen> {
  http.Client _client = http.Client(); //3gb
  var nonAffiliatedCourses = [];
  List results = [];
  List filter = [];
  static final List<String> providerNameDropdownItems = [
    '       All',
  ];
  String actualproviderNameDropdown = providerNameDropdownItems[0];

  static final List<String> courseStatusDropdownItems = ['    All', 'Active', 'upcoming'];
  String actualcourseStatusDropDown = courseStatusDropdownItems[0];

  static final List<String> sortingDropDownItems = ['Title', 'Rating'];
  String actualsortingDropDown = sortingDropDownItems[0];

  String dateformat, d, m, y;
  var startDate;
  var currentdate = DateTime.now();
  List startDateList = [];

  //Search option Variables
  final TextEditingController _typeAheadController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode typeAheadFocus = new FocusNode();
  bool showText = true;
  bool searchLoad = true;
  List allClassList = [];

  @override
  void initState() {
    super.initState();
    results = widget.arg['courses'];
    results ??= [];
    getUserDetails();
    allClassList = SelectClassSearch().allCourseList(list: widget.list);
    filterNonAffiliatedCourses();
    for (int i = 0; i < nonAffiliatedCourses.length; i++) {
      courseID.add(nonAffiliatedCourses[i]['course_id'].toString());
      if (providerNameDropdownItems.contains(nonAffiliatedCourses[i]['provider'])) {
      } else {
        providerNameDropdownItems.add(nonAffiliatedCourses[i]['provider']);
      }
    }
    // getCourseImageURL();
    apply_filter();
  }

  // ignore: non_constant_identifier_names
  void apply_filter() {
    filter = [];
    for (int i = 0; i < nonAffiliatedCourses.length; i++) {
      print(nonAffiliatedCourses[i]['course_status']);
      if (nonAffiliatedCourses[i]['provider'] == actualproviderNameDropdown &&
          nonAffiliatedCourses[i]['course_status'] == actualcourseStatusDropDown) {
        filter.add(nonAffiliatedCourses[i]);
      }
      if ('       All' == actualproviderNameDropdown && '    All' == actualcourseStatusDropDown) {
        filter.add(nonAffiliatedCourses[i]);
      }
      if ('       All' == actualproviderNameDropdown || '    All' == actualcourseStatusDropDown) {
        if ('       All' == actualproviderNameDropdown && actualcourseStatusDropDown != '    All') {
          filter = nonAffiliatedCourses
              .where((result) => result['course_status'] == actualcourseStatusDropDown)
              .toList();
        } else if ('       All' != actualproviderNameDropdown &&
            actualcourseStatusDropDown == '    All') {
          filter = nonAffiliatedCourses
              .where((result) => result['provider'] == actualproviderNameDropdown)
              .toList();
        }
      }
    }

    apply_sorting();
  }

  // ignore: non_constant_identifier_names
  apply_sorting() {
    if ('Alphabet' == actualsortingDropDown) {
      filter.sort((a, b) => a['title'].compareTo(b['title']));
    } else if (actualsortingDropDown == 'Rating') {
      filter.sort((b, a) => int.parse(a['ratings']).compareTo(int.parse(b['ratings'])));
    }
    if (this.mounted) {
      setState(() {
        // filter = filter;
      });
    }
  }

  filterNonAffiliatedCourses() {
    if (allClassList.isNotEmpty == true) {
      allClassList.map((e) async {
        e = await SelectClassSearch().subscriptionChecker(map: e);
      }).toList();
    }
    var courses = widget.arg['courses'];
    for (int i = 0; i < courses.length; i++) {
      if (courses[i]['affilation_excusive_data'] == null || courses[i]['exclusive_only'] == false) {
        nonAffiliatedCourses.add(courses[i]);
      }
      // else if(courses[i]['affilation_excusive_data'] != null) {
      //   if(courses[i]['affilation_excusive_data'].length == 0) {
      //     nonAffiliatedCourses.add(courses[i]);
      //   }
      // }
      else if (courses[i]['affilation_excusive_data'] != null) {
        if (courses[i]['affilation_excusive_data'].length != 0) {
          if (courses[i]['affilation_excusive_data']['affilation_array'].length == 0) {
            nonAffiliatedCourses.add(courses[i]);
          }
        }
      }
    }
    // for(int i=0; i<courses.length; i++) {
    //   if(courses[i]['affilation_excusive_data'] == null) {
    //     nonAffiliatedCourses.add(courses[i]);
    //   }
    //   else if(courses[i]['affilation_excusive_data'].length == 0) {
    //     nonAffiliatedCourses.add(courses[i]);
    //   }
    //   else if(courses[i]['affilation_excusive_data']['affilation_array'].length == 0) {
    //     nonAffiliatedCourses.add(courses[i]);
    //   }
    // }
    //print(nonAffiliatedCourses);
  }

  var courseID = [];
  var courseIDAndImage = [];
  var base64Image;
  var courseImage;
  bool hasSubscription = false;
  bool makeCourseSubscribed = false;
  List subscriptions = [];

  Future getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);
    Map teleConsulResponse = json.decode(data);
    if (teleConsulResponse['my_subscriptions'] == null ||
        !(teleConsulResponse['my_subscriptions'] is List) ||
        teleConsulResponse['my_subscriptions'].isEmpty) {
      if (this.mounted) {
        setState(() {
          hasSubscription = false;
        });
      }
      return;
    }
    if (this.mounted) {
      setState(() {
        subscriptions = teleConsulResponse['my_subscriptions'];
        hasSubscription = true;
      });
    }

    for (int i = 0; i < subscriptions.length; i++) {
      var subscriptionID = subscriptions[i]["course_id"];
      var status = subscriptions[i]["approval_status"];
      for (var i = 0; i < nonAffiliatedCourses.length; i++) {
        if ((nonAffiliatedCourses[i]['course_id'] == subscriptionID) && status == "Accepted" ||
            status == "Approved") {
          if (this.mounted) {
            setState(() {
              nonAffiliatedCourses[i]['isSubscribed'] = 'true';
              makeCourseSubscribed = true;
            });
          }
        } else {
          if (this.mounted) {
            setState(() {
              nonAffiliatedCourses[i]['isSubscribed'] = 'false';
            });
          }
        }
      }
    }
  }

  Future getCourseImageURL() async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/courses_image_fetch"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, dynamic>{
        'classIDList': courseID,
      }),
    );
    if (response.statusCode == 200) {
      List imageOutput = json.decode(response.body);
      courseIDAndImage = imageOutput;
      for (var i = 0; i < courseIDAndImage.length; i++) {
        if (nonAffiliatedCourses[i]['course_id'] == courseIDAndImage[i]['course_id']) {
          base64Image = courseIDAndImage[i]['base_64'].toString();
          base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
          base64Image = base64Image.replaceAll('}', '');
          base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
          if (this.mounted) {
            setState(() {
              // courseImage = imageFromBase64String(base64Image);
              courseImage = base64Image;
            });
          }

          nonAffiliatedCourses[i]['course_img_url'] = courseImage;
        }
      }
    } else {
      print(response.body);
    }
  }

  /// get card widget
  Widget getCard(Map map) {
    var currentDateTime = new DateTime.now();
    var courseDuration = map["course_duration"];
    String courseEndDuration = courseDuration.substring(13, 23);
    int lastIndexValue = map["course_time"].length - 1;
    String courseEndTimeFullValue = map["course_time"][lastIndexValue]; //02:00 PM - 07:00 PM
    String courseEndTime = courseEndTimeFullValue.substring(
        courseEndTimeFullValue.indexOf("-") + 1, courseEndTimeFullValue.length); //07:00 PM
    courseEndDuration = courseEndDuration + courseEndTime; //20-04-2022 07:00 PM
    DateTime endDate = new DateFormat("dd-MM-yyyy hh:mm aa").parse(courseEndDuration);
    String courseStartDuration = courseDuration.substring(0, 10);
    DateTime startDate = new DateFormat("dd-MM-yyyy").parse(courseStartDuration);
    if (startDate.day == currentdate.day &&
        endDate.day == currentdate.day &&
        endDate.isAfter(currentDateTime)) {
      return SelectClassCard(widget.arg['courses'], map);
    } else if (endDate.isBefore(currentDateTime)) {
      return Container();
    } else {
      return SelectClassCard(widget.arg['courses'], map);
    }
  }

  var currentDateTim = new DateTime.now();
  var activeClassAvailable = false;
  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < filter.length; i++) {
      var courseDuration = filter[i]["course_duration"];
      String courseEndDuration = courseDuration.substring(13, 23);
      int lastIndexValue = filter[i]["course_time"].length - 1;
      String courseEndTimeFullValue =
          filter[i]["course_time"][lastIndexValue]; //02:00 PM - 07:00 PM
      String courseEndTime = courseEndTimeFullValue.substring(
          courseEndTimeFullValue.indexOf("-") + 1, courseEndTimeFullValue.length); //07:00 PM
      courseEndDuration = courseEndDuration + courseEndTime; //20-04-2022 07:00 PM
      DateTime endDat = new DateFormat("dd-MM-yyyy").parse(courseEndDuration);
      if (endDat.isAfter(currentDateTim) ||
          (endDat.day == currentdate.day && endDat.month == currentdate.month)) {
        activeClassAvailable = true;
        break;
      }
    }
    return ScrollessBasicPageUI(
        appBar: Column(
          children: [
            SizedBox(
              width: 30.w,
            ),
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
                  child: Text(
                    widget.arg['specality_name'].toString(),
                    style: TextStyle(color: Colors.white, fontSize: 20.sp),
                  ),
                ),
                SizedBox(
                  width: 10.w,
                  height: 7.h,
                ),
                //hide filteration need more finetuning
                // GestureDetector(
                //   child: Icon(Icons.filter_list, color: Colors.white),
                //   onTap: () {
                //     filterScreen(context);
                //   },
                // ),
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
                      fixTextFieldOutlineLabel: true,
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
                                width: 1.w,
                                color: Colors.white,
                              ),
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(30.0),
                              ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: 'Search Class',
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
                              pattern: pattern, classes: allClassList);
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
                                            bottom: BorderSide(color: Colors.grey, width: 0.3.w))),
                                    child: ListTile(
                                      tileColor: Colors.grey.shade50,
                                      contentPadding: EdgeInsets.only(top: 5, bottom: 5),
                                      leading: Container(
                                        height: 20.w,
                                        width: 20.w,
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: MemoryImage(
                                                    base64Decode(AvatarImage.classUrl)))),
                                      ),
                                      title: Text(
                                          suggestion['title'] != "" || suggestion['title'] != null
                                              ? suggestion['title']
                                              : "Title"),
                                      subtitle: Text(suggestion['speciality'] != "" ||
                                              suggestion['speciality'] != null
                                          ? suggestion['speciality']
                                          : "speciality"),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Text(suggestion['course_fees'].toString() + " ₹"),
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
                        Map map = allClassList
                            .where((element) => element["course_id"] == suggestion["course_id"])
                            .toList()
                            .first;
                        try {
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
                              courses: widget.arg['courses'],
                              notificationRoute: false,
                            ));
                        } catch (e) {
                          print(e.toString());
                        }
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please type any letter to search ';
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
        body: nonAffiliatedCourses.length == 0
            ? Center(
                child: Text('No classes available for ' + widget.arg['specality_name'].toString()),
              )
            : filter.length == 0
                ? Center(
                    child:
                        Text('No classes available for ' + widget.arg['specality_name'].toString()),
                  )
                : activeClassAvailable == false
                    ? Center(
                        child: Text(
                            'No classes available for ' + widget.arg['specality_name'].toString()),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ...filter.map((e) => getCard(e)).toList(),
                              // ListView.builder(
                              //   itemBuilder: (context, index) {
                              //     return getCard(filter[index]);
                              //   },
                              //   itemCount: filter.length,
                              // ),
                            ],
                          ),
                        ),
                      ));
  }

  Future<dynamic> filterScreen(BuildContext context) async {
    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                  scrollable: true,
                  title: Text(
                    'Search filter',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.myApp),
                  ),
                  content: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '  Provider\n  Name',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        SizedBox(
                          width: ScUtil().setWidth(35),
                        ),
                        DropdownButton(
                            icon: Icon(Icons.arrow_drop_down),
                            iconEnabledColor: Colors.grey,
                            iconDisabledColor: Colors.grey,
                            dropdownColor: Colors.white,
                            isDense: true,
                            underline: SizedBox(),
                            value: actualproviderNameDropdown,
                            onChanged: (String value) {
                              if (this.mounted) {
                                setState(() {
                                  actualproviderNameDropdown = value;
                                });
                              }
                            },
                            items: providerNameDropdownItems.map((String title) {
                              return DropdownMenuItem(
                                value: title,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(title,
                                      style: TextStyle(
                                          color: AppColors.myApp,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14.0)),
                                ),
                              );
                            }).toList()),
                      ],
                    ),
                    SizedBox(
                      height: ScUtil().setHeight(5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '  Course\n  Status',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        SizedBox(
                          width: ScUtil().setWidth(60),
                        ),
                        DropdownButton(
                            icon: Icon(Icons.arrow_drop_down),
                            iconEnabledColor: Colors.grey,
                            iconDisabledColor: Colors.grey,
                            dropdownColor: Colors.white,
                            isDense: true,
                            underline: SizedBox(),
                            value: actualcourseStatusDropDown,
                            onChanged: (value) {
                              if (this.mounted) {
                                setState(() {
                                  actualcourseStatusDropDown = value;
                                });
                              }
                            },
                            items: courseStatusDropdownItems.map((title) {
                              return DropdownMenuItem(
                                value: title,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(title,
                                      style: TextStyle(
                                          color: AppColors.myApp,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14.0)),
                                ),
                              );
                            }).toList()),
                      ],
                    ),
                    SizedBox(
                      height: ScUtil().setHeight(15),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '  Sort by',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        SizedBox(
                          width: ScUtil().setWidth(65),
                        ),
                        DropdownButton(
                            icon: Icon(Icons.arrow_drop_down),
                            iconEnabledColor: Colors.grey,
                            iconDisabledColor: Colors.grey,
                            dropdownColor: Colors.white,
                            isDense: true,
                            underline: SizedBox(),
                            value: actualsortingDropDown,
                            onChanged: (value) {
                              if (this.mounted) {
                                setState(() {
                                  actualsortingDropDown = value;
                                });
                              }
                            },
                            items: sortingDropDownItems.map((title) {
                              return DropdownMenuItem(
                                value: title,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(title,
                                      style: TextStyle(
                                          color: AppColors.myApp,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14.0)),
                                ),
                              );
                            }).toList()),
                      ],
                    ),
                    SizedBox(
                      height: ScUtil().setHeight(13),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: AppColors.primaryColor)),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: AppColors.primaryColor)),
                              primary: AppColors.primaryColor,
                            ),
                            child: Text(
                              'Apply',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              if (this.mounted) {
                                setState(() {
                                  apply_filter();
                                });
                              }

                              Navigator.pop(context);
                            }),
                      ],
                    ),
                  ]));
            },
          );
        });
  }
}
