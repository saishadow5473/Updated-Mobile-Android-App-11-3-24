import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/views/images_viewer_healthChallenges.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/app_colors.dart';
import '../models/challenge_detail.dart';
import '../models/enrolled_challenge.dart';
import '../models/get_selfie_image_model.dart';
import '../persistent/PersistenGetxController/PersistentGetxController.dart';

// ignore: must_be_immutable
class CustomImageScroller extends StatelessWidget {
  CustomImageScroller({Key key, @required this.enrolledChallenge, @required this.challengeDetail})
      : super(key: key);
  EnrolledChallenge enrolledChallenge;
  ChallengeDetail challengeDetail;
  final PersistentGetXController controller = Get.put(PersistentGetXController());
  @override
  Widget build(BuildContext context) {
    int uploadCount = 0;
    try {
      return Container(
        width: Device.width - 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [const BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 6)],
        ),
        child: Column(
          children: [
            Container(
              height: 7.h,
              width: 95.w,
              padding: const EdgeInsets.only(left: 10, right: 10),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(3, 3), blurRadius: 6)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 32,
                  ),
                  Text("My Photos",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                          fontFamily: 'Poppins',
                          color: Colors.white)),
                  SizedBox(
                      width: 32,
                      child: MaterialButton(
                        onPressed: () {
                          if (DateTime.now().isAfter(enrolledChallenge.challenge_start_time) &&
                              (enrolledChallenge.userProgress != null ||
                                  enrolledChallenge.selectedFitnessApp == "other_apps") &&
                              controller.imageDatasObs.length < 10) {
                            controller.imageSelection(
                                isSelfi: true,
                                enrollChallenge: enrolledChallenge,
                                challengeDetail: challengeDetail);
                          } else if (controller.imageDatasObs.length > 9) {
                            const snackBar = SnackBar(
                              content: Text('Image upload limit reached (Max: 10)'),
                              duration: Duration(seconds: 3),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          } else {
                            const snackBar = SnackBar(
                              content: Text('Challenge has not started yet. Stay tuned!'),
                              duration: Duration(seconds: 3),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        },
                        color: Colors.white,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          Icons.photo_camera,
                          color: Colors.lightBlue,
                        ),
                      ))
                ],
              ),
            ),
            Container(
              width: 95.w,
              padding: const EdgeInsets.only(left: 10, right: 10),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 32,
                  ),
                  Obx(() => Text("Upload Left ${10 - controller.imageDatasObs.length}/10",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          // letterSpacing: 0.8,
                          fontFamily: 'Poppins',
                          color: Colors.black))),
                  SizedBox(
                    width: 32,
                    child: Obx(() => MaterialButton(
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                        color: controller.imageDatasObs.isEmpty ? Colors.grey : Colors.white,
                        child: Icon(
                          Icons.play_arrow,
                          color: controller.imageDatasObs.length == 0
                              ? Colors.white
                              : Colors.lightBlue,
                        ),
                        onPressed: controller.imageDatasObs.length == 0
                            ? () {}
                            : () {
                                Get.to(ImageViewerHealthChallenge(
                                  enrollmentId: enrolledChallenge.enrollmentId,
                                  challengeDetail: challengeDetail,
                                  enrolledChallenge: enrolledChallenge,
                                ));
                              })),
                  )
                ],
              ),
            ),
            SizedBox(
                width: Device.width - 40,
                height: Device.height / 5,
                // ignore: missing_return
                child: FutureBuilder<List<SelifeImageData>>(
                    future: controller.getImageData(enroll_id: enrolledChallenge.enrollmentId),
                    builder: (ctx, snap) {
                      if (snap.data == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snap.data.length == 0) {
                        return Center(
                            child: Text(
                          "No Uploads Available",
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              fontFamily: 'Poppins',
                              color: Colors.blueGrey),
                        ));
                      }

                      try {
                        uploadCount = snap.data.length;
                        return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snap.data.length,
                            itemBuilder: (ctx, i) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          return Dialog(
                                              backgroundColor: Colors.transparent,
                                              insetPadding: const EdgeInsets.all(10),
                                              child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(Radius.circular(8.0)),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Container(
                                                        height: 99.5.h,
                                                        width: 600,
                                                        decoration: const BoxDecoration(
                                                            // image: DecorationImage(
                                                            //     image: NetworkImage(
                                                            //         snap.data[i].userUploadedImageUrl),
                                                            //     fit: BoxFit.cover,
                                                            //     opacity: 0.6),
                                                            color: Colors.white),
                                                      ),
                                                      Container(
                                                        // color: Color.fromRGBO(
                                                        //     0, 0, 0, 0.34901960784313724),
                                                        color: Colors.white,
                                                      ),
                                                      PhotoView.customChild(
                                                        backgroundDecoration: const BoxDecoration(
                                                            color: Colors.transparent),
                                                        basePosition: Alignment.center,
                                                        child: Image.network(
                                                          snap.data[i].userUploadedImageUrl,
                                                        ),
                                                        maxScale:
                                                            PhotoViewComputedScale.covered * 2.0,
                                                        minScale:
                                                            PhotoViewComputedScale.contained * 1,
                                                        initialScale:
                                                            PhotoViewComputedScale.covered,
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.arrow_back_ios),
                                                        onPressed: () => Get.back(),
                                                        color: Colors.blue,
                                                      ),
                                                    ],
                                                  )));
                                        });
                                  },
                                  child: Container(
                                    height: Device.height / 7,
                                    width: Device.height / 7,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.shade200,
                                              offset: const Offset(1, 1),
                                              blurRadius: 6)
                                        ],
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image:
                                                NetworkImage(snap.data[i].userUploadedImageUrl))),
                                  ),
                                ),
                              );
                            });
                      } catch (e) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.white,
                            direction: ShimmerDirection.ltr,
                            period: const Duration(seconds: 2),
                            child: Container(
                              height: Device.height / 7,
                              width: Device.height / 7,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.shade200,
                                        offset: const Offset(1, 1),
                                        blurRadius: 6)
                                  ],
                                  image: const DecorationImage(
                                      fit: BoxFit.cover, image: NetworkImage(""))),
                            ),
                          ),
                        );
                      }
                    })),
          ],
        ),
      );
    } catch (e) {
      print(e);
      return const Text('');
    }
  }
}
//pushing
