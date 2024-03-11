import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../constants/api.dart';
import '../../constants/app_texts.dart';
import '../../new_design/presentation/pages/home/home_view.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../utils/app_colors.dart';
import '../ScrollessBasicPageUI.dart';
import 'courseInfo.dart';
import 'relatedCourses.dart';
import 'reviews.dart';
import 'selectClassSlot.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../new_design/app/services/teleconsultation/teleconsultation_services.dart';

class BookClass extends StatefulWidget {
  final Map course;
  final courses;
  bool notificationRoute;
  BookClass({Key key, @required this.course, this.courses, this.notificationRoute})
      : super(key: key);
  @override
  _BookClassState createState() => _BookClassState();
}

class _BookClassState extends State<BookClass> {
  final http.Client _client = http.Client(); //3gb
  bool profilePressed = false;
  bool calendarPressed = false;
  bool _isProfileVisible = false;
  bool _isCalendarVisible = true;
  final ScrollController _controller = ScrollController();
  final GlobalKey<State<StatefulWidget>> profile = GlobalKey();
  bool _isLoading = true;

  Color avail() {
    String status = widget.course['course_status'];

    Color color = AppColors.primaryAccentColor;
    if (status == 'available') {
      color = Colors.green;
    }
    if (status == 'busy') {
      color = Colors.red;
    }
    if (status == 'offline') {
      color = Colors.grey;
    }
    return color;
  }

  void showProfile() {
    if (mounted) {
      setState(() {
        if (_isProfileVisible) {
          return;
        }
        _isCalendarVisible = false;
        _isProfileVisible = true;
        if (_isProfileVisible) {
          _controller.animateTo(_controller.offset + 100,
              duration: const Duration(milliseconds: 800), curve: Curves.ease);
        }
      });
    }
  }

  String reviews(List list) {
    list ??= [];
    return '${list.length} reviews';
  }

  void showCalendar() {
    if (_isCalendarVisible) {
      return;
    }
    if (mounted) {
      setState(() {
        _isProfileVisible = false;
        _isCalendarVisible = true;
        if (_isCalendarVisible) {
          _controller.animateTo(_controller.offset + 100,
              duration: const Duration(milliseconds: 800), curve: Curves.ease);
        }
      });
    }
  }

  List<Widget> specialities(List sp) {
    sp ??= [];
    return sp
        .map(
          (e) => FilterChip(
            label: Text(
              camelize(
                e.toString(),
              ),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            padding: const EdgeInsets.all(0),
            backgroundColor: AppColors.primaryAccentColor,
            onSelected: (bool value) {},
          ),
        )
        .toList();
  }

  getRelatedCourses() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("courseIdFromBookClass", widget.course['course_id']);
  }

  Future<bool> willPopFunction() {
    if (widget.notificationRoute.toString() == 'null') {
      widget.notificationRoute = false;
    }
    if (widget.notificationRoute == true) {
      // Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => HomeScreen(
      //         introDone: true,
      //       ),
      //     ),
      //     (Route<dynamic> route) => false);
      Get.off(LandingPage());
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPopFunction,
      child: ScrollessBasicPageUI(
        appBar: _isLoading
            ? const SizedBox.shrink()
            : Column(
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: willPopFunction,
                      ),
                      const Flexible(
                        child: Center(
                          child: Text(
                            AppTexts.bookClass,
                            style: TextStyle(color: Colors.white, fontSize: 25),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 40,
                      )
                    ],
                  ),
                ],
              ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  controller: _controller,
                  children: <Widget>[
                    courseInfo(),
                    // SizedBox(
                    //   height: 10.0,
                    // ),
                    // courseProfile(),
                    courseAppointment(),
                    // relatedCourses()
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _AsyncInitState();
  }

  _AsyncInitState() async {
    await fcmN();
    await getCourseID();
    await getCourseImageURL();
    await getRelatedCourses();
    await updateCourseStatus(widget.course);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  fcmN() async {
    String a = widget.course.toString();
    String b = widget.courses.toString();
    String c = jsonEncode(widget.course);
    String d = jsonEncode(widget.courses);

    print(a);
    print(b);
    print(c);
    print(d);
    SharedPreferences prr = await SharedPreferences.getInstance();
    prr.setString('fcmN_c', c);
    prr.setString('fcmN_d', d);
  }

  List courseID = [];
  List courseIDAndImage = [];
  var courseImage;

  getCourseID() {
    courseID.add(widget.course['course_id'].toString());
  }

  Future getCourseImageURL() async {
    final http.Response response = await _client.post(
      Uri.parse("${API.iHLUrl}/consult/courses_image_fetch"),
      body: jsonEncode(<String, dynamic>{
        'classIDList': courseID,
      }),
    );
    if (response.statusCode == 200) {
      List imageOutput = json.decode(response.body);
      courseIDAndImage = imageOutput;
      for (int i = 0; i < courseIDAndImage.length; i++) {
        if (widget.course['course_id'] == courseIDAndImage[i]['course_id']) {
          widget.course['course_img_url'] = courseIDAndImage[i]['base_64'].toString();
          widget.course['course_img_url'] =
              widget.course['course_img_url'].replaceAll('data:image/jpeg;base64,', '');
          widget.course['course_img_url'] = widget.course['course_img_url'].replaceAll('}', '');
          widget.course['course_img_url'] =
              widget.course['course_img_url'].replaceAll('data:image/jpegbase64,', '');
          if (mounted) {
            setState(() {
              courseImage = imageFromBase64String(widget.course['course_img_url']);
            });
          }
        }
      }
    } else {
      print(response.body);
    }
  }

  updateCourseStatus(Map courseDetails) async {
    getCourseImageURL();
    String duration = courseDetails['course_duration'].substring(0, 10);
    DateTime classTime = DateFormat("dd-MM-yyyy").parse(duration);
    DateTime now = DateTime.now();
    if (classTime.isAfter(now)) {
      print('upcoming');
    } else {
      if (courseDetails['course_status'] == 'upcoming' ||
          courseDetails['course_status'] == 'Upcoming') {
        final http.Response response = await _client.post(
          Uri.parse('${API.iHLUrl}//consult/edit_class'),
          body: jsonEncode(<String, dynamic>{
            "course_img_url": courseDetails['course_img_url'],
            "course_id": courseDetails['course_id'].toString(),
            "title": courseDetails['title'],
            "course_time": courseDetails['course_time'],
            "course_on": courseDetails['course_on'],
            "course_type": courseDetails['course_type'],
            "provider": courseDetails['provider'],
            "consultant_id": courseDetails['consultant_id'].toString(),
            "consultant_name": courseDetails["consultant_name"],
            "consultant_gender": courseDetails['consultant_gender'],
            "course_fees": courseDetails['course_fees'],
            "fees_for": courseDetails['fees_for'],
            "subscriber_count": courseDetails['subscriber_count'],
            "available_slot_count": courseDetails['available_slot_count'],
            "available_slot": courseDetails['available_slot'],
            "course_duration": courseDetails['course_duration'],
            //changed from upcoming to active
            "course_status": 'Active',
            "speciality": courseDetails['speciality'].toString(),
            "course_description": courseDetails['course_description'].toString(),
            //auto approval key added
            "auto_approve": courseDetails['auto_approve']
          }),
        );
        if (response.statusCode == 200) {
          String parsedString = response.body.replaceAll('&quot;', '"');
          String parsedString1 = parsedString.replaceAll('"{', '{');
          String parsedString2 = parsedString1.replaceAll('}"', '}');
          Map<String, dynamic> editedClassDetails = json.decode(parsedString2);
          String status = editedClassDetails["status"].toString();
          if (status == "Updated") {
            print('update course status');
          }
        } else {
          print('failed ${response.body}');
        }
      }
    }
  }

  Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }

  Widget courseInfo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        children: [
          Card(
            elevation: 2,
            shadowColor: FitnessAppTheme.grey,
            borderOnForeground: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(color: FitnessAppTheme.nearlyWhite, width: 2)),
            margin: const EdgeInsets.all(0),
            // color: Color(0xfff4f6fa),
            color: FitnessAppTheme.white,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Center(
                child: CircleAvatar(
                  backgroundColor: FitnessAppTheme.nearlyWhite,
                  radius: 100.0,
                  child: CircleAvatar(
                    radius: 90.0,
                    backgroundImage: courseImage == null ? null : courseImage.image,
                    backgroundColor: FitnessAppTheme.nearlyWhite,
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                camelize(widget.course['title'].toString()),
                style: const TextStyle(
                  letterSpacing: 2.0,
                  color: AppColors.primaryColor,
                  fontSize: 22.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 5.0,
              ),
              Text(
                widget.course['consultant_name'].toString(),
                style: const TextStyle(
                  color: Color(0xff6D6E71),
                  fontSize: 22.0,
                ),
              ),
              // Text(
              //   widget.course['provider'].toString(),
              //   style: TextStyle(
              //     color: Color(0xff6D6E71),
              //     fontSize: 22.0,
              //   ),
              // ),
              Visibility(
                visible: widget.course['course_on'].length > 0,
                child: Wrap(
                  direction: Axis.horizontal,
                  runSpacing: 0,
                  spacing: 8,
                  children: specialities(widget.course['course_on']),
                ),
              ),
              Visibility(
                visible: widget.course['course_on'].length > 0,
                child: const SizedBox(
                  height: 5.0,
                ),
              ),
              // Center(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text(
              //         'M.R.P.: ',
              //         style: TextStyle(
              //           fontSize: 22.0,
              //           color: Color(0xff6D6E71),
              //         ),
              //       ),
              //       Text(
              //         '\u{20B9} ' + widget.course['course_fees_mrp'].toString(),
              //         style: TextStyle(
              //           decoration: TextDecoration.lineThrough,
              //           fontSize: 22.0,
              //           color: Color(0xff6D6E71),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Course Fees: ' '\u{20B9} ' + widget.course['course_fees'].toString(),
                      style: const TextStyle(
                        fontSize: 22.0,
                        color: Color(0xff6D6E71),
                      ),
                    ),
                    Text(
                      TeleConsultationServices()
                          .processString(widget.course['fees_for'].toString()),
                      style: const TextStyle(
                        fontSize: 22.0,
                        color: Color(0xff6D6E71),
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(
              //   height: 5.0,
              // ),
              // SmoothStarRating(
              //     allowHalfRating: false,
              //     onRated: (v) {},
              //     starCount: 5,
              //     rating:
              //         double.tryParse(widget.course['ratings'].toString()) ??
              //             0.0,
              //     size: 30.0,
              //     isReadOnly: true,
              //     color: Colors.amberAccent,
              //     borderColor: Colors.grey,
              //     spacing: 0.0),
              // SizedBox(
              //   height: 5.0,
              // ),
              // Center(
              //   child: Text(
              //     reviews(widget.course['text_reviews_data'] ?? []),
              //     style: TextStyle(
              //       fontSize: 18.0,
              //       color: Color(0xff6D6E71),
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   height: 10.0,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     ClipOval(
              //       child: Material(
              //         color: !_isCalendarVisible
              //             ? AppColors.primaryAccentColor
              //             : Colors.green, // button color
              //         child: InkWell(
              //           splashColor: Colors.red, // inkwell color
              //           child: SizedBox(
              //             width: 56,
              //             height: 56,
              //             child: Icon(
              //               Icons.calendar_today,
              //               color: Colors.white,
              //             ),
              //           ),
              //           onTap: () {
              //             showCalendar();
              //           },
              //         ),
              //       ),
              //     ),
              //     ClipOval(
              //       child: Material(
              //         color: !_isProfileVisible
              //             ? AppColors.primaryAccentColor
              //             : Colors.green, // button color
              //         child: InkWell(
              //           splashColor: Colors.red, // inkwell color
              //           child: SizedBox(
              //             width: 56,
              //             height: 56,
              //             child: Icon(
              //               Icons.info_outline,
              //               color: Colors.white,
              //             ),
              //           ),
              //           onTap: () {
              //             showProfile();
              //             if (this.mounted) {
              //               setState(() {
              //                 profilePressed = true;
              //               });
              //             }
              //           },
              //         ),
              //       ),
              //     )
              //   ],
              // ),
            ]),
          ),
          Positioned(
            top: -25,
            left: -55,
            child: Transform.rotate(
              angle: -pi / 4,
              child: Container(
                color: avail(),
                child: SizedBox(
                  width: 150,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 70,
                      ),
                      Center(
                        child: Text(
                          camelize(widget.course['course_type'].toString().replaceAll('s', '')),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget courseProfile() {
    return _isProfileVisible
        ? Visibility(
            visible: _isProfileVisible,
            child: Card(
              key: profile,
              elevation: 2,
              shadowColor: FitnessAppTheme.grey,
              borderOnForeground: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: const BorderSide(color: FitnessAppTheme.nearlyWhite, width: 2)),
              color: FitnessAppTheme.white,
              // color: Color(0xfff4f6fa),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.info,
                        size: 30.0,
                        color: AppColors.primaryAccentColor,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Course info",
                          style: TextStyle(
                            color: AppColors.primaryAccentColor,
                            fontSize: 22.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  CourseInfo(
                    course: widget.course,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: const [
                      Icon(
                        Icons.star,
                        size: 30.0,
                        color: AppColors.primaryAccentColor,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Reviews",
                          style: TextStyle(
                            color: AppColors.primaryAccentColor,
                            fontSize: 22.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  widget.course['text_reviews_data'] != null
                      ? widget.course['text_reviews_data'].length == 0
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("No Reviews yet"),
                            )
                          : SizedBox(
                              height: 205.0,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Reviews(
                                  reviews: widget.course['text_reviews_data'] ?? [],
                                ),
                              ),
                            )
                      : const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("No Reviews yet"),
                        )
                ]),
              ),
            ),
          )
        : const SizedBox();
  }

  Widget relatedCourses() {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: AppColors.cardColor,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Related Courses",
                    style: TextStyle(color: AppColors.appTextColor, fontSize: 22.0),
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.courses.map<Widget>((e) {
                  return getItem(e);
                }).toList(),
              ),
            )
          ],
        ));
  }

  RelatedCourses getItem(Map map) {
    return RelatedCourses(
      title: map['title'],
      fees: map['course_fees'],
      duration: map['course_duration'],
      ratings: map['ratings'],
      courseId: map['course_id'],
      courseImgUrl: map['course_img_url'],
      feesFor: map['fees_for'],
      courseOn: map['course_on'],
    );
  }

  Widget courseAppointment() {
    return _isCalendarVisible
        ? Visibility(
            visible: _isCalendarVisible,
            child: SelectClassSlot(
              slots: widget.course['course_time'] ?? [],
              course: widget.course,
              companyName: "none",
              affiliationPrice: "empty",
            ),
          )
        : const SizedBox();
  }
}
