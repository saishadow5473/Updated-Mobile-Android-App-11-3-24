import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Course Info Tab pass course data 👀👀
class CourseInfo extends StatelessWidget {
  final Map course;
  CourseInfo({Key key, @required this.course}) : super(key: key);

  var links = [];
  var courseDesBeforeHttp = [];
  getHyperLink() async {
    courseDesBeforeHttp = course['course_description'].split(' ');
    var links = [];
    for (int i = 0; i < courseDesBeforeHttp.length; i++) {
      if (courseDesBeforeHttp[i].contain('http')) {
        links.add(courseDesBeforeHttp[i]);
      }
    }
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        /*Row(
          children: [
            Text('Subscribers: '),
            Text(
              '${course['subscriber_count']}',
              style: TextStyle(color: AppColors.primaryAccentColor),
            ),
          ],
        ),
        Divider(),*/
        Row(
          children: [
            Text('Course Duration: '),
            Text(
              '${course['course_duration']}',
              style: TextStyle(color: AppColors.primaryAccentColor),
            ),
          ],
        ),
        Divider(),
        Row(
          children: [
            Text('Course Status: '),
            Text(
              '${course['course_status']}'.replaceAll('_', ' '),
              style: TextStyle(color: AppColors.primaryAccentColor),
            ),
          ],
        ),
        Divider(),
        Wrap(
          children: [
            Text('Course Description: '),
            Linkify(
              onOpen: (link) async {
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                } else {
                  throw 'Could not launch $link';
                }
              },
              text: course['course_description'],
              linkStyle: TextStyle(color: AppColors.primaryAccentColor),
            ),
            // Expanded(
            //   child: Text(
            //     course['course_description'] ?? "N/A",
            //     style: TextStyle(color: AppColors.primaryAccentColor),
            //   ),
            // ),
            ...courseDesBeforeHttp.map<Widget>((e) {
              return RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: e,
                      style: TextStyle(
                          color: e.toString().contains('http')
                              ? AppColors.primaryAccentColor
                              : AppColors.appTextColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          if (e.toString().contains('http')) {
                            if (await canLaunch(e.toString())) {
                              await launch(e.toString());
                            } else {
                              throw 'Could not launch $e';
                            }
                          }
                        },
                    ),
                    TextSpan(
                      text: " ",
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
}
