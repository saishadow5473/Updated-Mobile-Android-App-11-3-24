import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/views/affiliation/bookClassForAffiliation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';
import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';
import 'dart:math';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;

import '../../new_design/app/services/teleconsultation/teleconsultation_services.dart';

class SelectClassCardForAffiliation extends StatefulWidget {
  final int index;
  final String companyName;
  final courses;
  final Map consultant;
  SelectClassCardForAffiliation(this.index, this.courses, this.consultant, this.companyName);
  @override
  _SelectClassCardForAffiliationState createState() => _SelectClassCardForAffiliationState();
}

class _SelectClassCardForAffiliationState extends State<SelectClassCardForAffiliation> {
  http.Client _client = http.Client(); //3gb
  bool hasSubscription = false;
  bool makeCourseSubscribed = false;
  bool makeCourseRequested = false;
  List subscriptions = [];
  String title;

  bool rndtf() {
    Random rnd = Random();
    return rnd.nextBool();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      if (this.mounted) {
        super.setState(fn);
      }
    }
  }

  var courseIDAndImage = [];
  var base64Image;
  var courseImage;
  var imageCourse;

  Future getCourseImageURL() async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/courses_image_fetch"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, dynamic>{
        'classIDList': [widget.consultant['course_id']],
      }),
    );
    if (response.statusCode == 200) {
      List imageOutput = json.decode(response.body);
      courseIDAndImage = imageOutput;
      for (var i = 0; i < courseIDAndImage.length; i++) {
        if (widget.consultant['course_id'] == courseIDAndImage[i]['course_id']) {
          base64Image = courseIDAndImage[i]['base_64'].toString();
          base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
          base64Image = base64Image.replaceAll('}', '');
          base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
          if (this.mounted) {
            setState(() {
              courseImage = base64Image;
            });
          }
          if (courseImage == null || courseImage == "") {
            if (this.mounted) {
              setState(() {
                widget.consultant['course_img_url'] = AvatarImage.defaultUrl;
                imageCourse = Image.memory(base64Decode(widget.consultant['course_img_url']));
              });
            }
          } else {
            if (this.mounted) {
              setState(() {
                widget.consultant['course_img_url'] = courseImage;
                imageCourse = Image.memory(base64Decode(widget.consultant['course_img_url']));
              });
            }
          }
        }
      }
    } else {
      print(response.body);
    }
  }

  /// create  top banner 😃
  Widget banner() {
    String status = widget.consultant['course_type'];

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
    return Positioned(
      top: -25,
      left: -60,
      child: Transform.rotate(
        angle: -pi / 4,
        child: Container(
          color: color,
          child: SizedBox(
            width: 150,
            child: Column(
              children: [
                SizedBox(
                  height:50,
                ),
                Center(
                  child: Text(
                      TeleConsultationServices().processString(widget.consultant['fees_for'].toString()),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget badge() {
    return Positioned(
      right: 0,
      bottom: -5,
      child: FilterChip(
        label: Icon(Icons.close),
        backgroundColor: Colors.red,
        onSelected: (value) {},
      ),
    );
  }

  List<Widget> generateChips(List sp) {
    sp ??= [];
    return sp
        .map(
          (e) => FilterChip(
            label: Text(
              camelize(e.toString()),
              style: TextStyle(
                color: AppColors.primaryColor,
              ),
            ),
            padding: EdgeInsets.all(0),
            backgroundColor: AppColors.appItemShadowColor,
            onSelected: (bool value) {},
          ),
        )
        .toList();
  }

  Widget reviews(List list) {
    list ??= [];
    return Text('${list.length} reviews');
  }

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

      if (subscriptionID == widget.consultant["course_id"] && status == "Accepted" ||
          status == "Approved") {
        if (this.mounted) {
          setState(() {
            makeCourseSubscribed = true;
            print(status);
            print(subscriptionID);
          });
        }
      }
      if ((subscriptionID == widget.consultant["course_id"]) &&
          (status == "requested" || status == "Requested")) {
        if (this.mounted) {
          setState(() {
            makeCourseRequested = true;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getCourseImageURL();
    title = widget.consultant['title'].toString();
    if (this.mounted) {
      setState(() {
        title = title.replaceAll("amp;", "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      color: AppColors.cardColor,
      child: InkWell(
        key: Key('affiliatedCourse${widget.index}'),
        onTap: makeCourseRequested == false
            ? widget.consultant['isSubscribed'].toString() == 'true' || makeCourseSubscribed
                ? () {
                    AwesomeDialog(
                            context: context,
                            animType: AnimType.TOPSLIDE,
                            headerAnimationLoop: true,
                            dialogType: DialogType.NO_HEADER,
                            dismissOnTouchOutside: false,
                            title: 'Course already Subscribed!',
                            desc: 'You cannot subscribe for already subscribed courses',
                            btnOkOnPress: () {
                              Navigator.of(context).pop(true);
                            },
                            btnOkColor: Colors.green,
                            btnOkText: 'OK',
                            btnOkIcon: Icons.check,
                            onDismissCallback: (_) {})
                        .show();
                  }
                : () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookClassForAffiliation(
                                  notificationRoute: false,
                                  course: widget.consultant,
                                  courses: widget.courses,
                                  companyName: widget.companyName,
                                )));
                  }
            : () {
                AwesomeDialog(
                        context: context,
                        animType: AnimType.TOPSLIDE,
                        headerAnimationLoop: true,
                        dialogType: DialogType.NO_HEADER,
                        dismissOnTouchOutside: false,
                        title: 'Course already Subscribed!',
                        desc: 'You cannot subscribe for already subscribed courses',
                        btnOkOnPress: () {
                          Navigator.of(context).pop(true);
                        },
                        btnOkColor: Colors.green,
                        btnOkText: 'OK',
                        btnOkIcon: Icons.check,
                        onDismissCallback: (_) {})
                    .show();
              },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Center(
                  child: Row(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 35.0, right: 11.0, left: 30.0, bottom: 11.0),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage: imageCourse == null ? null : imageCourse.image,
                          backgroundColor: AppColors.primaryAccentColor,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                camelize(title) ?? "",
                                // camelize(widget.consultant['title'].toString()).replaceAll("&amp", ""),
                                style: TextStyle(
                                  letterSpacing: 2.0,
                                  color: AppColors.primaryAccentColor,
                                ),
                              ),
                              Text(
                                widget.consultant['consultant_name']
                                    .toString()
                                    .replaceAll('Persistant', 'My Life Persistent'),
                                style: TextStyle(
                                  color: AppColors.lightTextColor,
                                ),
                              ),
                              // Text(
                              //   widget.consultant['provider']
                              //       .toString()
                              //       .replaceAll('Persistant', 'Persistent'),
                              //   style: TextStyle(
                              //     color: AppColors.lightTextColor,
                              //   ),
                              // ),
                              // Text(
                              //   '\u{20B9} ' +
                              //       widget.consultant['course_fees']
                              //           .toString() +
                              //       ' /' +
                              //       widget.consultant['fees_for'].toString(),
                              //   style: TextStyle(
                              //     color: AppColors.lightTextColor,
                              //   ),
                              // ),
                              Text(
                                TeleConsultationServices().processString(    widget.consultant['fees_for'].toString()),
                                style: TextStyle(
                                  color: AppColors.lightTextColor,
                                ),
                              ),
                              RatingBar.builder(
                                ignoreGestures: true,
                                initialRating:
                                    double.tryParse(widget.consultant['ratings'].toString()) ?? 0.0,
                                minRating: 0,
                                itemSize: 20.0,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemCount: 5,
                                itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amberAccent,
                                ),
                                onRatingUpdate: (double value) {},
                              ),
                              reviews(widget.consultant['text_reviews_data']),
                              Wrap(
                                direction: Axis.horizontal,
                                children: generateChips(widget.consultant['course_on']),
                                runSpacing: 0,
                                spacing: 8,
                              ),
                              Visibility(
                                visible: widget.consultant['isSubscribed'].toString() == 'true' ||
                                        makeCourseRequested == true ||
                                        makeCourseSubscribed == true
                                    ? true
                                    : false,
                                child: FilterChip(
                                  label: Text(
                                    "Already Subscribed",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(0),
                                  backgroundColor: Colors.green,
                                  onSelected: (bool value) {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 2.0,
                ),
              ]),
              banner()
            ],
          ),
        ),
      ),
    );
  }
}
