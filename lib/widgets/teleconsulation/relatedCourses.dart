import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/imageutils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:strings/strings.dart';

class RelatedCourses extends StatefulWidget {
  final courseId;
  var courseImgUrl;
  final title;
  final fees;
  final duration;
  final ratings;
  final feesFor;
  final courseOn;

  RelatedCourses(
      {this.courseId,
      this.courseImgUrl,
      this.title,
      this.fees,
      this.duration,
      this.ratings,
      this.feesFor,
      this.courseOn});
  @override
  _RelatedCoursesState createState() => _RelatedCoursesState();
}

class _RelatedCoursesState extends State<RelatedCourses> {
  http.Client _client = http.Client(); //3gb
  var courseID = [];
  var courseIDAndImage = [];
  var courseImage;
  var courseIdFromBookClass;

  Future getCourseID() async {
    courseID.add(widget.courseId.toString());

    SharedPreferences pref = await SharedPreferences.getInstance();
    courseIdFromBookClass = pref.getString("courseIdFromBookClass");
  }

  Future getCourseImageURL() async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/courses_image_fetch"),
      body: jsonEncode(<String, dynamic>{
        'classIDList': courseID,
      }),
    );
    if (response.statusCode == 200) {
      List imageOutput = json.decode(response.body);
      courseIDAndImage = imageOutput;
      for (var i = 0; i < courseIDAndImage.length; i++) {
        if (widget.courseId == courseIDAndImage[i]['course_id']) {
          widget.courseImgUrl = courseIDAndImage[i]['base_64'].toString();
          widget.courseImgUrl =
              widget.courseImgUrl.replaceAll('data:image/jpeg;base64,', '');
          widget.courseImgUrl = widget.courseImgUrl.replaceAll('}', '');
          widget.courseImgUrl =
              widget.courseImgUrl.replaceAll('data:image/jpegbase64,', '');
          if (this.mounted) {
            setState(() {
              courseImage = imageFromBase64String(
                  widget.courseImgUrl ?? AvatarImage.defaultUrl);
            });
          }
        }
      }
    } else {
      print(response.body);
    }
  }

  List<Widget> courseOn(List on) {
    on ??= [];
    return on
        .map(
          (e) => FilterChip(
            label: Text(
              camelize(
                e.toString(),
              ),
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            padding: EdgeInsets.all(0),
            backgroundColor: AppColors.primaryAccentColor,
            onSelected: (bool value) {},
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    getCourseID();
    getCourseImageURL();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.courseId == courseIdFromBookClass ? false : true,
      child: Container(
        width: 300.0,
        height: 400.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 50.0,
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundImage:
                                courseImage == null ? null : courseImage.image,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          camelize(widget.title.toString()),
                          style: TextStyle(
                            letterSpacing: 2.0,
                            color: AppColors.primaryColor,
                            fontSize: 20.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          "Course Fees: " +
                              '\u{20B9} ' +
                              widget.fees.toString(),
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Color(0xff6D6E71),
                          ),
                        ),
                        Text("Duration: ",
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Color(0xff6D6E71),
                            )),
                        Center(
                          child: Text(widget.duration.toString(),
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Color(0xff6D6E71),
                              )),
                        ),
                        // Expanded(
                        //   child: Wrap(
                        //     direction: Axis.horizontal,
                        //     children: courseOn(widget.courseOn),
                        //     runSpacing: 0,
                        //     spacing: 8,
                        //   ),
                        // ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text("Ratings: ",
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Color(0xff6D6E71),
                            )),
                        SmoothStarRating(
                            allowHalfRating: false,
                            onRated: (v) {},
                            starCount: 5,
                            rating:
                                double.tryParse(widget.ratings.toString()) ??
                                    0.0,
                            size: 30.0,
                            isReadOnly: true,
                            color: Colors.amberAccent,
                            borderColor: Colors.grey,
                            spacing: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -20,
                left: -60,
                child: Transform.rotate(
                  angle: -pi / 4,
                  child: Container(
                    color: AppColors.primaryAccentColor,
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Center(
                            child: Text(
                              camelize(widget.feesFor.toString()),
                              style: TextStyle(color: Colors.white),
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
        ),
      ),
    );
  }
}
