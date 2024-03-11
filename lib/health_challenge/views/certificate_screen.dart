import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/marathon/e-cetificate_image.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../widgets/certificate_widget.dart';

class CertificateScreen extends StatelessWidget {
  final ChallengeDetail challengeDetail;
  final EnrolledChallenge enrolledChallenge;
  final String groupName;
  final int duration;
  const CertificateScreen(
      {@required this.groupName,
      @required this.challengeDetail,
      @required this.enrolledChallenge,
      @required this.duration});

  @override
  Widget build(BuildContext context) {
    int _duration = duration ~/ 1440;
    return BasicPageUI(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Certificate", style: TextStyle(color: Colors.white)),
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 60.h,
            width: 100.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                enrolledChallenge.userAchieved < enrolledChallenge.target
                    ? Container()
                    : Text(
                        'CONGRATULATIONS',
                        style: TextStyle(color: Colors.white, fontSize: 22.sp, letterSpacing: -1),
                      ),
                Text(
                  'You Won a Badge!!!',
                  style: TextStyle(color: Colors.white, fontSize: 19.sp, letterSpacing: -1),
                ),
                certificateBadgeWidget(challengeDetail.challengeBadge),
                RichText(
                  text: TextSpan(
                    // Note: Styles for TextSpans must be explicitly defined.
                    // Child text spans will inherit styles from parent
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'BIB ',
                          style: TextStyle(
                            color: AppColors.primaryAccentColor,
                            fontSize: 17.sp,
                          )),
                      TextSpan(
                          text: '- ${enrolledChallenge.user_bib_no}',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            fontSize: 17.sp,
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15.h,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: enrolledChallenge.selectedFitnessApp != "other_apps"
                        ? enrolledChallenge.userAchieved < enrolledChallenge.target ||
                                enrolledChallenge.docStatus.toLowerCase() == 'rejected'
                            ? Text(
                                // 'This ${challengeDetail.challengeName}, that walking ${challengeDetail.targetToAchieve} steps is Completed by Hari at the duration of ${_duration.toInt()}',
                                challengeDetail.challengeCompletionCertificateMessage
                                    .replaceAll('{{group_name}}', groupName)
                                    .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                                    .replaceAll(
                                        '{{distance}}',
                                        enrolledChallenge.target.toString() +
                                            ' ' +
                                            challengeDetail.challengeUnit +
                                            ' ')
                                    .replaceAll("completed", "participated in")
                                    .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                                    .replaceAll('{{days}}',
                                        _duration < 1 ? '1' : _duration.toInt().toString())
                                    .replaceAll(
                                        '{{Participant_Name}}', enrolledChallenge.name + " "),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    letterSpacing: 1,
                                    height: 1.2),
                                textAlign: TextAlign.center,
                              )
                            : Text(
                                // 'This ${challengeDetail.challengeName}, that walking ${challengeDetail.targetToAchieve} steps is Completed by Hari at the duration of ${_duration.toInt()}',
                                challengeDetail.challengeCompletionCertificateMessage
                                    .replaceAll('{{group_name}}', groupName)
                                    .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                                    .replaceAll(
                                        '{{distance}}',
                                        enrolledChallenge.target.toString() +
                                            ' ' +
                                            challengeDetail.challengeUnit +
                                            ' ')
                                    .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                                    .replaceAll('{{days}}',
                                        _duration < 1 ? '1' : _duration.toInt().toString())
                                    .replaceAll(
                                        '{{Participant_Name}}', enrolledChallenge.name + " "),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    letterSpacing: 1,
                                    height: 1.2),
                                textAlign: TextAlign.center,
                              )
                        : enrolledChallenge.docStatus.toLowerCase() == 'rejected'
                            ? Text(
                                // 'This ${challengeDetail.challengeName}, that walking ${challengeDetail.targetToAchieve} steps is Completed by Hari at the duration of ${_duration.toInt()}',
                                challengeDetail.challengeCompletionCertificateMessage
                                    .replaceAll('{{group_name}}', groupName)
                                    .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                                    .replaceAll(
                                        '{{distance}}',
                                        enrolledChallenge.target.toString() +
                                            ' ' +
                                            challengeDetail.challengeUnit +
                                            ' ')
                                    .replaceAll("completed", "participated in")
                                    .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                                    .replaceAll('{{days}}',
                                        _duration < 1 ? '1' : _duration.toInt().toString())
                                    .replaceAll(
                                        '{{Participant_Name}}', enrolledChallenge.name + " "),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    letterSpacing: 1,
                                    height: 1.2),
                                textAlign: TextAlign.center,
                              )
                            : Text(
                                // 'This ${challengeDetail.challengeName}, that walking ${challengeDetail.targetToAchieve} steps is Completed by Hari at the duration of ${_duration.toInt()}',
                                challengeDetail.challengeCompletionCertificateMessage
                                    .replaceAll('{{group_name}}', groupName)
                                    .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                                    .replaceAll(
                                        '{{distance}}',
                                        enrolledChallenge.target.toString() +
                                            ' ' +
                                            challengeDetail.challengeUnit +
                                            ' ')
                                    .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                                    .replaceAll('{{days}}',
                                        _duration < 1 ? '1' : _duration.toInt().toString())
                                    .replaceAll(
                                        '{{Participant_Name}}', enrolledChallenge.name + " "),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    letterSpacing: 1,
                                    height: 1.2),
                                textAlign: TextAlign.center,
                              ),
                  ),
                ),
              ],
            ),
            margin: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
                gradient:
                    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                  Color(0xff259BA9),
                  Color(0xff1B5E8E),
                ]),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    23.sp,
                  ),
                  topRight: Radius.circular(
                    23.sp,
                  ),
                ),
                color: Colors.blue),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20.sp),
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              'Are you sure you want to download certificate?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  wordSpacing: 5.sp,
                  fontSize: 18.sp,
                  color: AppColors.appItemTitleTextColor,
                  fontFamily: FitnessAppTheme.fontName),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Get.to(
                    EcertificateImage(
                        name_participent: enrolledChallenge.name,
                        event_status: 'Completed',
                        event_varient: 'Hello',
                        time_taken: 'Time',
                        challengeDetail: challengeDetail,
                        enrolledChallenge: enrolledChallenge,
                        groupName: groupName,
                        duration: _duration < 1 ? '1' : _duration.toInt().toString(),
                        emp_id: 'IHL'),
                    transition: Transition.rightToLeft),
                style: ElevatedButton.styleFrom(
                    primary: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.sp),
                    )),
                child: Text('Yes'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                    primary: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.sp),
                    )),
                child: Text('No'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
