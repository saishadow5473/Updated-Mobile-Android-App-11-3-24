import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/marathon/e-cetificate_image.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../../health_challenge/widgets/certificate_widget.dart';
import '../../dashboard/common_screen_for_navigation.dart';

class DynamicCertificateScreen extends StatelessWidget {
  final ChallengeDetail challengeDetail;
  final EnrolledChallenge enrolledChallenge;
  final String groupName;
  final int duration;

  const DynamicCertificateScreen({
    @required this.groupName,
    @required this.challengeDetail,
    @required this.enrolledChallenge,
    @required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: buildAppBar(),
      content: buildContent(),
    );
  }

  Widget buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      centerTitle: true,
      title: const Text("Certificate", style: TextStyle(color: Colors.white)),
      leading: InkWell(
        onTap: () => Get.back(),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildContent() {
    int _duration = duration ~/ 1440;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildCertificateContainer(_duration),
        buildDownloadConfirmation(),
      ],
    );
  }

  Widget buildCertificateContainer(int duration) {
    return Container(
      height: 60.h,
      width: 100.w,
      margin: EdgeInsets.all(13.sp),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff259BA9), Color(0xff1B5E8E)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'CONGRATULATIONS',
            style: TextStyle(color: Colors.white, fontSize: 20.sp, letterSpacing: -1),
          ),
          Text(
            'You Won a Badge!!!',
            style: TextStyle(color: Colors.white, fontSize: 17.sp, letterSpacing: -1),
          ),
          certificateBadgeWidget(challengeDetail.challengeBadge),
          Gap(2.h),
          buildCertificateText(duration),
        ],
      ),
    );
  }

  Widget buildCircleAvatar() {
    return CircleAvatar(
      radius: 40.sp,
      backgroundImage: NetworkImage(challengeDetail.challengeImgUrl),
    );
  }

  Widget buildCertificateText(int duration) {
    String certificateMessage = challengeDetail.challengeCompletionCertificateMessage
        .replaceAll('{{group_name}}', groupName)
        .replaceAll('{{steps}}', enrolledChallenge.target.toString())
        .replaceAll('{{distance}}', '${enrolledChallenge.target} ${challengeDetail.challengeUnit} ')
        .replaceAll('{{steps}}', enrolledChallenge.target.toString())
        .replaceAll('{{days}}', duration < 1 ? '1' : duration.toInt().toString())
        .replaceAll('{{Participant_Name}}', "${enrolledChallenge.name} ");

    if (enrolledChallenge.selectedFitnessApp != "other_apps" ||
        enrolledChallenge.docStatus.toLowerCase() == 'rejected') {
      certificateMessage = certificateMessage.replaceAll("completed", "participated in");
    }

    return SizedBox(
      height: 15.h,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          certificateMessage,
          style: TextStyle(color: Colors.white, fontSize: 16.sp, letterSpacing: 1, height: 1.2),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildDownloadConfirmation() {
    return Column(
      children: [
        buildConfirmationText(),
        buildActionButtons(),
      ],
    );
  }

  Widget buildConfirmationText() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.sp),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        'Are you sure you want to download certificate?',
        textAlign: TextAlign.center,
        style: TextStyle(
          wordSpacing: 5.sp,
          fontSize: 17.sp,
          color: Colors.black87,
          fontFamily: FitnessAppTheme.fontName,
        ),
      ),
    );
  }

  Widget buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildActionButton('Yes', () => navigateToEcertificateImage()),
        buildActionButton('No', () => Get.back()),
      ],
    );
  }

  Widget buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: AppColors.primaryColor,
        fixedSize: Size(22.w, 4.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.sp),
        ),
      ),
      child: Text(label),
    );
  }

  void navigateToEcertificateImage() {
    Get.to(
      EcertificateImage(
        name_participent: enrolledChallenge.name,
        event_status: 'Completed',
        event_varient: 'Hello',
        time_taken: 'Time',
        challengeDetail: challengeDetail,
        enrolledChallenge: enrolledChallenge,
        groupName: groupName,
        duration: duration < 1 ? '1' : duration.toInt().toString(),
        emp_id: 'IHL',
      ),
      transition: Transition.rightToLeft,
    );
  }
}
