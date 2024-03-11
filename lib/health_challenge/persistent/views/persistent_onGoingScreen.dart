import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:ihl/Getx/controller/listOfChallengeContoller.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/health_challenge/persistent/PersistenGetxController/PersistentGetxController.dart';
import 'package:ihl/health_challenge/persistent/views/persistnet_certificateScreen.dart';
import 'package:ihl/health_challenge/widgets/custom_imageScroller.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../new_design/presentation/controllers/healthchallenge/healthChallengeController.dart';

import '../../../utils/app_colors.dart';
import '../../../views/home_screen.dart';
import '../../../views/marathon/preCertificate.dart';
import '../../../widgets/offline_widget.dart';
import '../../controllers/challenge_api.dart';
import '../../models/challenge_detail.dart';
import '../../models/update_challenge_target_model.dart';

class PersistentOnGoingScreen extends StatefulWidget {
  PersistentOnGoingScreen(
      {Key key,
      @required this.challengeStarted,
      @required this.enrolledChallenge,
      @required this.nrmlJoin,
      @required this.challengeDetail})
      : super(key: key);
  bool challengeStarted;
  EnrolledChallenge enrolledChallenge;
  final ChallengeDetail challengeDetail;
  bool nrmlJoin = false;

  @override
  State<PersistentOnGoingScreen> createState() => _PersistentOnGoingScreenState();
}

class _PersistentOnGoingScreenState extends State<PersistentOnGoingScreen> {
  // EnrolledChallenge enrolledChallenge;
  final ListChallengeController _listChallengeController = Get.find();
  String b6;
  String imgB6;
  RegExp emailRegExp =
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  emailValueCheck() {
    if (_sendInviteEmailController.value.text.isEmpty) {
      return null;
    } else if (!emailRegExp.hasMatch(_sendInviteEmailController.value.text)) {
      return "Invalid Email";
    } else
      return null;
  }

  toastMessageAlert(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  final controller = Get.put(PersistentGetXController());
  @override
  void initState() {
    Get.delete<HealthChallengeController>();
    _listChallengeController.enrolledChallenge();
    funPhoto();

    // enrolledChallenge = _listChallengeController.currentUserEnrolledChallenges
    //     .where((element) => element.enrollmentId == widget.enrolledChallenge.enrollmentId)
    //     .first;

    // for (var i in _listChallengeController.currentUserEnrolledChallenges) {
    //   if (i.enrollmentId == widget.enrolledChallenge.enrollmentId) {
    //     enrolledChallenge = i;
    //   }
    // }
    // if (enrolledChallenge.docStatus != '') {
    //   if (enrolledChallenge.docStatus.toLowerCase() == 'accepted') {
    //     genCer();
    //   }
    // }

    super.initState();
  }

  funPhoto() async {
    widget.enrolledChallenge =
        await ChallengeApi().getEnrollDetail(widget.enrolledChallenge.enrollmentId);
    if (widget.enrolledChallenge.userProgress != "completed" ||
        widget.enrolledChallenge.userProgress == null) {
      if (widget.enrolledChallenge.docStatus.toLowerCase() == 'accepted') {
        genCer();
      } else if ((widget.enrolledChallenge.docStatus.toLowerCase() == 'rejected' ||
              widget.challengeDetail.challengeEndTime.isBefore(DateTime.now()) &&
                  (DateFormat('MM-dd-yyyy')
                          .format(widget.challengeDetail.challengeEndTime)
                          .toString() !=
                      "01-01-2000")) &&
          widget.enrolledChallenge.userProgress != "completed") {
        genCer();
      } else {
        await ChallengeApi().updateChallengeTarget(
          updateChallengeTarget: UpdateChallengeTarget(
              firstTime: true,
              achieved: "0",
              challengeEndTime: widget.challengeDetail.challengeEndTime,
              enrollmentId: widget.enrolledChallenge.enrollmentId,
              duration: '0',
              certificateBase64: " ",
              certificatePngBase64: " ",
              email: _listChallengeController.email,
              progressStatus: 'progressing'),
        );
        PersistentOnGoingScreen(
          challengeDetail: widget.challengeDetail,
          challengeStarted:
              DateTime.now().isAfter(widget.challengeDetail.challengeStartTime) ? true : false,
          enrolledChallenge: widget.enrolledChallenge,
          nrmlJoin: true,
        );
      }
    } else {
      widget.enrolledChallenge.userProgress = 'completed';
      Get.to(PersistentCertificateScreen(
        challengedetail: widget.challengeDetail,
        enrolledChallenge: widget.enrolledChallenge,
        navNormal: false,
        firstComplete: false,
      ));
    }
    widget.challengeStarted =
        DateFormat('MM-dd-yyyy').format(widget.challengeDetail.challengeStartTime).toString() ==
                "01-01-2000" ||
            DateTime.now().isAfter(widget.challengeDetail.challengeStartTime);
    if (widget.enrolledChallenge.docStatus == "requested" ||
        widget.enrolledChallenge.docStatus == "") {
      controller.photoUploaded = false;
      controller.update();
    }
  }

  Future genCer() async {
    b6 = await preCertifiacte(
        Get.context,
        widget.enrolledChallenge.name,
        "widget.event_status",
        "widget.event_varient",
        "widget.time_taken",
        "widget.emp_id",
        widget.challengeDetail,
        widget.enrolledChallenge,
        " ",
        widget.enrolledChallenge.userduration);
    imgB6 = await imgPreCertifiacte(
        Get.context,
        widget.enrolledChallenge.name,
        "widget.event_status",
        "widget.event_varient",
        "widget.time_taken",
        "widget.emp_id",
        widget.challengeDetail,
        widget.enrolledChallenge,
        " ",
        widget.enrolledChallenge.userduration);
    var _enroll = await ChallengeApi().getEnrollDetail(widget.enrolledChallenge.enrollmentId);
    if (_enroll.userProgress != "completed") {
      await ChallengeApi().updateChallengeTarget(
        updateChallengeTarget: UpdateChallengeTarget(
            firstTime: false,
            achieved: "0",
            progressStatus: 'completed',
            challengeEndTime: widget.challengeDetail.challengeEndTime,
            enrollmentId: widget.enrolledChallenge.enrollmentId,
            duration: "0",
            email: _listChallengeController.email,
            certificatePngBase64: imgB6,
            certificateBase64: b6),
      );
    }
    // Vibration.vibrate(pattern: [500, 1000, 500]);
    // AudioPlayer().play(AssetSource('audio/challenge_completed.mp3'));
    // Get.defaultDialog(
    //     barrierDismissible: true,
    //     backgroundColor: Colors.lightBlue.shade50,
    //     title: 'Congratulations',
    //     titlePadding: EdgeInsets.only(top: 20, bottom: 5, right: 10, left: 10),
    //     titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
    //     contentPadding: EdgeInsets.all(20),
    //     content: Column(
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         SizedBox(
    //           width: Device.width / 1.5,
    //           child: Text(
    //             "You have Successfully Completed the Run",
    //             textAlign: TextAlign.center,
    //             style: TextStyle(
    //               fontSize: 16,
    //               color: Colors.blueGrey,
    //               fontFamily: 'Poppins',
    //               fontWeight: FontWeight.w600,
    //             ),
    //           ),
    //         ),
    //         SizedBox(
    //           width: 10,
    //         ),
    //         Icon(
    //           Icons.task_alt,
    //           size: 40,
    //           color: Colors.blue.shade300,
    //         ),
    //         SizedBox(
    //           height: 15,
    //         ),
    //         GestureDetector(
    //           onTap: () {
    //             Get.back();
    //             //if (mounted) setState(() {});
    //           },
    //           child: Container(
    //             width: MediaQuery.of(context).size.width / 4,
    //             decoration:
    //                 BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
    //             child: Center(
    //               child: Padding(
    //                 padding: const EdgeInsets.all(8.0),
    //                 child: Text(
    //                   'Ok',
    //                   style: TextStyle(color: Colors.white),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         )
    //       ],
    //     ));
    //
    // Get.back();
    widget.enrolledChallenge.userProgress = 'completed';

    Get.to(PersistentCertificateScreen(
      challengedetail: widget.challengeDetail,
      enrolledChallenge: widget.enrolledChallenge,
      navNormal: false,
      firstComplete: true,
    ));
  }

  final _sendInviteEmailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _listChallengeController.currentSelectedChallenge = widget.enrolledChallenge;
    _listChallengeController.checkReferInviteCount(widget.challengeDetail.challengeId);
    print(widget.enrolledChallenge.toJson().toString());
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          if (widget.nrmlJoin) {
            _listChallengeController.allChallengeList();
            Navigator.pop(context);
          } else {
            _listChallengeController.affiliateCmpnyList;
            // Get.offAll(HomeScreen(introDone: true),
            //     transition: Transition.size);
            Get.off(LandingPage());
          }
        },
        child: ConnectivityWidgetWrapper(
          disableInteraction: true,
          offlineWidget: OfflineWidget(),
          child: GetBuilder(
              id: 'currentchallengeupdate',
              init: ListChallengeController(),
              builder: (_cu) {
                if (_listChallengeController.currentSelectedChallenge.docStatus.toLowerCase() ==
                    'accepted') {
                  _listChallengeController.currentSelectedChallenge = null;
                  widget.enrolledChallenge.userProgress = 'completed';

                  return PersistentCertificateScreen(
                    challengedetail: widget.challengeDetail,
                    enrolledChallenge: widget.enrolledChallenge,
                    navNormal: false,
                    firstComplete: false,
                  );
                } else {
                  return ScrollessBasicPageUI(
                      appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        centerTitle: true,
                        title: Text(widget.challengeDetail.challengeName,
                            style: TextStyle(color: Colors.white)),
                        leading: InkWell(
                          onTap: () {
                            if (widget.nrmlJoin) {
                              _listChallengeController.enrolledChallenge();
                              Navigator.pop(context);
                            } else {
                              // Get.offAll(HomeScreen(introDone: true),
                              //     transition: Transition.size);
                              Get.off(LandingPage());
                            }
                          },
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      body: widget.enrolledChallenge.docStatus.toLowerCase() == "accepted"
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      width: 95.w,
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(1, 1),
                                              blurRadius: 6)
                                        ],
                                      ),
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              // Align(
                                              //   alignment: Alignment.centerRight,
                                              //   child: MaterialButton(
                                              //     padding: EdgeInsets.only(right: 0),
                                              //     color: Colors.lightBlue,
                                              //     shape: CircleBorder(),
                                              //     onPressed: DateTime.now().isAfter(
                                              //             widget.challengeDetail.challengeStartTime)
                                              //         ? () {
                                              //             controller.imageSelection(
                                              //                 isSelfi: true,
                                              //                 enrollChallenge:
                                              //                     widget.enrolledChallenge);
                                              //           }
                                              //         : null,
                                              //     child: Icon(
                                              //       Icons.photo_camera,
                                              //       color: Colors.white,
                                              //     ),
                                              //   ),
                                              // ),
                                              CircleAvatar(
                                                radius: 35.sp, // Image radius
                                                backgroundImage: NetworkImage(
                                                    widget.challengeDetail.challengeImgUrl),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(14.sp),
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.grey),
                                                    borderRadius: BorderRadius.circular(16.sp)),
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      color: Colors.black,
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: 'BIB ',
                                                          style: TextStyle(
                                                            color: AppColors.appItemTitleTextColor,
                                                            fontSize: 17.sp,
                                                          )),
                                                      widget.enrolledChallenge.user_bib_no != null
                                                          ? TextSpan(
                                                              text:
                                                                  '- ${widget.enrolledChallenge.user_bib_no ?? ''}',
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.normal,
                                                                color: AppColors.primaryColor,
                                                                fontSize: 17.sp,
                                                              ))
                                                          : TextSpan(
                                                              text: '- 1234',
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.normal,
                                                                color: AppColors.primaryColor,
                                                                fontSize: 17.sp,
                                                              )),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 10,
                                                ),
                                                child: Text(
                                                  widget.challengeDetail.challengeName,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 20.sp,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 1,
                                                      color: Colors.blueGrey),
                                                ),
                                              ),
                                            ],
                                          )),
                                    ),
                                  ),
                                  GetBuilder<PersistentGetXController>(
                                      id: 'photoUpload',
                                      init: PersistentGetXController(),
                                      builder: (context) {
                                        return CustomImageScroller(
                                            enrolledChallenge: widget.enrolledChallenge,
                                            challengeDetail: widget.challengeDetail);
                                      }),
                                  GetBuilder(
                                      init: PersistentGetXController(),
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                          child: Container(
                                            height: height < 400 ? 80.h : 48.h,

                                            // constraints: BoxConstraints(
                                            //   maxHeight: double.infinity,
                                            // ),
                                            width: 95.w,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(1, 1),
                                                    blurRadius: 6)
                                              ],
                                            ),
                                            child: GetBuilder(
                                                init: PersistentGetXController(),
                                                builder: (_) {
                                                  return Stack(
                                                    children: [
                                                      Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Container(
                                                            height: 7.h,
                                                            width: 95.w,
                                                            decoration: BoxDecoration(
                                                              color: AppColors.primaryColor,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors.grey,
                                                                    offset: Offset(3, 3),
                                                                    blurRadius: 6)
                                                              ],
                                                            ),
                                                            child: Center(
                                                              child: Text("Upload",
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      fontSize: 19.sp,
                                                                      fontWeight: FontWeight.w500,
                                                                      letterSpacing: 0.8,
                                                                      fontFamily: 'Popins',
                                                                      color: Colors.white)),
                                                            ),
                                                          )),
                                                      SizedBox(
                                                        height: 1.h,
                                                      ),
                                                      Positioned(
                                                        top: 10.h,
                                                        right: 3.w,
                                                        left: 3.w,
                                                        child: Column(
                                                          children: [
                                                            DottedBorder(
                                                              borderType: BorderType.RRect,
                                                              dashPattern: [8],
                                                              color: Colors.lightBlue.shade200,
                                                              strokeWidth: 1.5,
                                                              child: Container(
                                                                  // height: 30.h,
                                                                  width: 85.w,
                                                                  child: Column(
                                                                    children: [
                                                                      widget.enrolledChallenge
                                                                                      .docStatus ==
                                                                                  '' &&
                                                                              (controller
                                                                                      .photoUploaded ==
                                                                                  false)
                                                                          ? Column(
                                                                              mainAxisSize:
                                                                                  MainAxisSize.min,
                                                                              children: [
                                                                                SizedBox(
                                                                                  height: 20,
                                                                                ),
                                                                                widget.challengeStarted
                                                                                    ? Container()
                                                                                    : Text(
                                                                                        "Upload Option will be enable on\n ${Jiffy(widget.challengeDetail.challengeStartTime).format("do MMM yyyy")}",
                                                                                        textAlign:
                                                                                            TextAlign
                                                                                                .center,
                                                                                        style: TextStyle(
                                                                                            height:
                                                                                                1.4,
                                                                                            fontSize: 17
                                                                                                .sp,
                                                                                            fontFamily:
                                                                                                'Popins',
                                                                                            color: Colors
                                                                                                .blueGrey)),
                                                                                SizedBox(
                                                                                  height: 15,
                                                                                ),
                                                                                ElevatedButton(
                                                                                  child: Text(
                                                                                      'Upload Photo',
                                                                                      style: TextStyle(
                                                                                          fontSize:
                                                                                              17.sp,
                                                                                          fontWeight:
                                                                                              FontWeight
                                                                                                  .bold,
                                                                                          letterSpacing:
                                                                                              1,
                                                                                          fontFamily:
                                                                                              'Popins',
                                                                                          color: Colors
                                                                                              .white)),
                                                                                  style:
                                                                                      ElevatedButton
                                                                                          .styleFrom(
                                                                                    shape:
                                                                                        RoundedRectangleBorder(
                                                                                      borderRadius:
                                                                                          BorderRadius
                                                                                              .circular(
                                                                                                  15),
                                                                                    ),
                                                                                    primary: widget.challengeStarted
                                                                                        ? AppColors
                                                                                            .primaryAccentColor
                                                                                        : Colors
                                                                                            .lightBlue
                                                                                            .shade200,
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    if (widget
                                                                                        .challengeStarted) {
                                                                                      controller.imageSelection(
                                                                                          isSelfi:
                                                                                              false,
                                                                                          challengeDetail:
                                                                                              widget
                                                                                                  .challengeDetail,
                                                                                          enrollChallenge:
                                                                                              widget
                                                                                                  .enrolledChallenge);
                                                                                    } else {
                                                                                      print(
                                                                                          "Challenge is not started");
                                                                                    }
                                                                                  },
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 25,
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : Container(),
                                                                      widget.enrolledChallenge
                                                                                      .docStatus
                                                                                      .toLowerCase() ==
                                                                                  "requested" ||
                                                                              controller
                                                                                  .photoUploaded
                                                                          ? Center(
                                                                              child: Padding(
                                                                                padding:
                                                                                    const EdgeInsets
                                                                                            .fromLTRB(
                                                                                        10,
                                                                                        20,
                                                                                        10,
                                                                                        20),
                                                                                child: Text(
                                                                                    "Photo Uploaded Successfully!",
                                                                                    textAlign:
                                                                                        TextAlign
                                                                                            .center,
                                                                                    style: TextStyle(
                                                                                        height: 1.4,
                                                                                        fontSize:
                                                                                            17.sp,
                                                                                        fontFamily:
                                                                                            'Popins',
                                                                                        color: Colors
                                                                                            .blueGrey)),
                                                                              ),
                                                                            )
                                                                          : Container(),
                                                                    ],
                                                                  )),
                                                            ),
                                                            widget.enrolledChallenge.docStatus ==
                                                                        '' &&
                                                                    (controller.photoUploaded ==
                                                                        false)
                                                                ? Column(
                                                                    children: [
                                                                      //SizedBox(height: 30),
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child: SizedBox(
                                                                          width: 60.sp,
                                                                          child: Text(
                                                                            "Run using your Favourite GPS Enabled App, Complete your Run and then take a screenshot of completion and Upload here.",
                                                                            style: TextStyle(
                                                                                color:
                                                                                    Colors.blueGrey,
                                                                                height: 5.2.sp,
                                                                                fontSize: 15.sp),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  )
                                                                : Container(),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        bottom: 6.h,
                                                        child: Visibility(
                                                          visible: (widget
                                                                      .enrolledChallenge.docStatus
                                                                      .toLowerCase() ==
                                                                  "requested") ||
                                                              controller.photoUploaded,
                                                          child: Padding(
                                                            padding: const EdgeInsets.fromLTRB(
                                                                8, 8, 8, 0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.end,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment.center,
                                                              children: [
                                                                SizedBox(
                                                                    height: Device.width / 2.5,
                                                                    width: Device.width / 2.5,
                                                                    child: Image.asset(
                                                                        "assets/images/Group 151.png")),
                                                                SizedBox(
                                                                    width: Device.width / 2.5,
                                                                    child: Text(
                                                                        "Approval \n Pending!!",
                                                                        textAlign: TextAlign.center,
                                                                        style: TextStyle(
                                                                            height: 1.4,
                                                                            letterSpacing: 0.5,
                                                                            fontSize: 17.sp,
                                                                            // fontFamily: 'Popins',
                                                                            color:
                                                                                Colors.blueGrey)))
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible:
                                                            widget.enrolledChallenge.docStatus ==
                                                                    '' &&
                                                                (controller.photoUploaded == false),
                                                        child: Positioned(
                                                          right: 10.sp,
                                                          bottom: 10.sp,
                                                          child: Image.asset(
                                                            "assets/images/Group 150.png",
                                                            height: 22.h,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }),
                                          ),
                                        );
                                      }),
                                  // _listChallengeController.affiliateCmpnyList
                                  //         .where((element) =>
                                  //             widget.challengeDetail.affiliations.contains(element))
                                  //         .isNotEmpty
                                  Visibility(
                                    visible: (Get.find<ListChallengeController>()
                                            .affiliateCmpnyList
                                            .any((element) => widget.challengeDetail.affiliations
                                                .contains(element)) &&
                                        !Get.find<ListChallengeController>()
                                            .affiliateCmpnyList
                                            .contains('Global')),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(1, 1),
                                              blurRadius: 6)
                                        ],
                                      ),
                                      margin: EdgeInsets.all(10.0.sp),
                                      padding: EdgeInsets.all(12.0.sp),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 7.h,
                                            width: 95.w,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(3, 3),
                                                    blurRadius: 6)
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: 1,
                                                ),
                                                Text(
                                                    widget.challengeDetail.challengeMode ==
                                                            "individual"
                                                        ? "Send invite"
                                                        : "Send invite",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.white)),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Icon(
                                                //     Icons.play_arrow,
                                                //     color: Colors.white,
                                                //   ),
                                                // )
                                                SizedBox(
                                                  width: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            // height: 15.h,
                                            width: 95.w,
                                            decoration: BoxDecoration(
                                              color: AppColors.appBackgroundColor,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(1, 1),
                                                    blurRadius: 6)
                                              ],
                                            ),
                                            child: GetBuilder(
                                                id: 'inviteupdate',
                                                init: ListChallengeController(),
                                                builder: (_) {
                                                  return Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      Text(
                                                        "Invite up-to 5 family members\n (${_listChallengeController.invitedEmailCount}/5 invite left)",
                                                        style: TextStyle(
                                                            fontSize: height > 568 ? 14.sp : 16.sp,
                                                            fontWeight: FontWeight.w600,
                                                            letterSpacing: 1,
                                                            color: Colors.blueGrey),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      Padding(
                                                        // padding:  EdgeInsets.only(left: 3.w,right: 3.w),
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: 18, vertical: 15),

                                                        child: Material(
                                                          borderRadius:
                                                              BorderRadius.all(Radius.circular(15)),
                                                          elevation: 2,
                                                          child: TextField(
                                                            controller: _sendInviteEmailController,
                                                            keyboardType:
                                                                TextInputType.emailAddress,
                                                            // inputFormatters: [
                                                            //   FilteringTextInputFormatter.allow(
                                                            //       RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))
                                                            // ],
                                                            decoration: InputDecoration(
                                                              // suffixIcon: Icon(
                                                              //   Icons.edit,
                                                              //   color: Colors.black45,
                                                              // ),
                                                              errorText: emailValueCheck(),

                                                              contentPadding: EdgeInsets.symmetric(
                                                                  horizontal: 18, vertical: 7),
                                                              hintText:
                                                                  "Email of friends/family member",
                                                              hintStyle: TextStyle(
                                                                  color: Colors.black26,
                                                                  fontSize: 16.sp),
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(
                                                                    Radius.circular(15)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 0.5.h,
                                                      ),
                                                      SizedBox(
                                                        height: 5.h,
                                                        width: 30.w,
                                                        child: ElevatedButton(
                                                          child: Text('Invite',
                                                              style: TextStyle(
                                                                  fontSize: 17.sp,
                                                                  fontWeight: FontWeight.bold,
                                                                  letterSpacing: 1,
                                                                  fontFamily: 'Popins',
                                                                  color: Colors.white)),
                                                          style: ElevatedButton.styleFrom(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(15),
                                                            ),
                                                            primary:
                                                                _listChallengeController
                                                                            .invitedEmailCount ==
                                                                        5
                                                                    ? AppColors.primaryAccentColor
                                                                    : (!_sendInviteEmailController
                                                                                .value.text.isEmpty &&
                                                                            !_sendInviteEmailController
                                                                                .value
                                                                                .text
                                                                                .isEmpty &&
                                                                            emailRegExp.hasMatch(
                                                                                _sendInviteEmailController
                                                                                    .value.text))
                                                                        ? AppColors
                                                                            .primaryAccentColor
                                                                        : Colors.grey,
                                                          ),
                                                          onPressed: () {
                                                            if (!_sendInviteEmailController
                                                                    .value.text.isEmpty &&
                                                                emailRegExp.hasMatch(
                                                                    _sendInviteEmailController
                                                                        .value.text)) {
                                                              _listChallengeController
                                                                  .inviteThroughEmailApiCall(
                                                                      widget.challengeDetail
                                                                          .challengeId,
                                                                      widget.enrolledChallenge.name,
                                                                      _sendInviteEmailController
                                                                          .value.text)
                                                                  .then((response) {
                                                                print(response);
                                                                if (response == "invite success") {
                                                                  _listChallengeController
                                                                          .invitedEmailCount =
                                                                      _listChallengeController
                                                                              .invitedEmailCount -
                                                                          1;
                                                                  _listChallengeController
                                                                      .update(['inviteupdate']);
                                                                  _sendInviteEmailController
                                                                      .clear();
                                                                  toastMessageAlert(
                                                                      "Invited Successfully!!");
                                                                } else if (response ==
                                                                    "already invited") {
                                                                  toastMessageAlert(
                                                                      "Email already invited");
                                                                } else {
                                                                  toastMessageAlert(
                                                                      "Already invited 5 members!!");
                                                                }
                                                              });
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 2.h,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                            left: 10, right: 10),
                                                        child: Text(
                                                          " By inviting your friends / family members will receive an welcome Email to download hCare APP subsequently, when they register with same Email Id they get access to this challenge.",
                                                          style: TextStyle(
                                                              fontSize: 12.5.sp,
                                                              fontWeight: FontWeight.w600,
                                                              letterSpacing: 1,
                                                              color: Colors.blueGrey),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 25,
                                                      ),
                                                    ],
                                                  );
                                                }),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ));
                }
              }),
        ));
  }
}
