import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../utils/screenutil.dart';
import '../../../../views/teleconsultation/files/medicalFiles.dart';
import '../../../app/utils/appColors.dart';
import '../../../data/providers/network/api_provider.dart';
import '../../../jitsi/video_call_jitsi.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_apiCalls.dart';
import '../home/landingPage.dart';
import '../teleconsultation/wait_for_consultant_screen.dart';
import 'consultationSummary.dart';
import 'medFileblocs/medFileBloc.dart';
import 'medFileblocs/medFileEvent.dart';
import 'medFileblocs/medFileState.dart';
import 'myAppointmentsTabs.dart';

class StagesVariables {
  static String appointmentId;
  static bool iscallError = false;
  static String callErrorAppointmentId;
  static bool isTimer90seconds = false;
  static Timer timerCAM;
  static bool isNavigatedToNoInternetPage = false;
  static bool istimerForCAM = false;
  static String currentPage = "";
  static bool isCallTerminated = false;
  static ValueNotifier<int> counterValueConsultaionStages = ValueNotifier<int>(180);
  static Timer _timerUI90ConsultaionStages;

  //To Trigger the Counter UI under Consultation Stages screen ⚪
  static void counterUIConsultationStages() {
    print("Timer activated ");
    if (_timerUI90ConsultaionStages != null) {
      _timerUI90ConsultaionStages.cancel();
      _timerUI90ConsultaionStages = null;
    }
    _timerUI90ConsultaionStages = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (StagesVariables.counterValueConsultaionStages.value < 1) {
        timer.cancel();
        Get.to(ConsultationSummaryScreen(
            fromCall: true, appointmentId: StagesVariables.appointmentId));
      } else {
        StagesVariables.counterValueConsultaionStages.value =
            StagesVariables.counterValueConsultaionStages.value - 1;
      }
    });
  }

  static void callErrorDialog(String callDetail) {
    Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text(
              'Call Ended due to an Error.',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: callDetail.toString() != 'SubscriptionCall'
                ? const Text("Visit 'My Appointments' and select 'Join Call' to reconnect.")
                : const Text("Visit 'My Subscriptions' and select 'Join Call' to reconnect."),
            actions: <Widget>[
              ElevatedButton.icon(
                  onPressed: () {
                    if (callDetail.toString() != 'SubscriptionCall') {
                      Get.offAll(MyAppointmentsTabs(fromCall: true));
                    } else {
                      // Get.offAll(MySubscription(
                      //   afterCall: false,
                      // ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    // ignore: deprecated_member_use
                    primary: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.0),
                      side: const BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  icon: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Ok",
                    style: TextStyle(color: Colors.white),
                  )),
              const SizedBox(
                width: 100,
              ),
            ],
          ),
        ),
        barrierDismissible: false);
  }

  static void startTimer90Seconds({String callType}) {
    Timer.periodic(
      const Duration(seconds: 90),
      (Timer timer90sec) {
        if (isTimer90seconds == true && currentPage != "NoInternetPage") {
          isTimer90seconds = false;
          timer90sec.cancel();

          // StagesVariables.istimerConsultationStagesSession = false;
          if (callType != 'SubscriptionCall') {
            Get.offAll(MyAppointmentsTabs(fromCall: true));
          } else {
            // Get.offAll(MySubscription(afterCall: false));
          }
        } else {
          timer90sec.cancel();
        }
      },
    );
  }

  static ValueNotifier<bool> callStatus = ValueNotifier<bool>(false);
}

class ConsultationStagesVideoCall extends StatefulWidget {
  final VideoCallDetail videocallDetail;

  const ConsultationStagesVideoCall({Key key, this.videocallDetail}) : super(key: key);

  @override
  State<ConsultationStagesVideoCall> createState() => _ConsultationStagesVideoCallState();
}

class _ConsultationStagesVideoCallState extends State<ConsultationStagesVideoCall> {
  bool medicalfiles = false;
  ValueNotifier<int> count = ValueNotifier<int>(-1);
  ValueNotifier<String> selectedmedical = ValueNotifier<String>('');
  final PageController _pageController = PageController();
  ValueNotifier<bool> prescriptionCompleted = ValueNotifier<bool>(false);
  ValueNotifier<bool> noPrescription = ValueNotifier<bool>(false);
  ValueNotifier<bool> prescriptionStatus = ValueNotifier<bool>(null);
  bool lastStep = false;
  int currentIndex = 0;
  bool getUserDetailsUpdate = false;
  Map<String, dynamic> consultationNotes;

  ValueNotifier<bool> callCompleted = ValueNotifier<bool>(false);
  bool isRejoin = false;

  // var prescriptionStatus;
  Map<String, dynamic> consultationDetails;
  final List<Map<String, dynamic>> options = <Map<String, dynamic>>[
    <String, dynamic>{
      'text': "Lab Report",
      'icon': "newAssets/medicalFiles/Lab Report.jpg",
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': Colors.white
    },
    <String, dynamic>{
      'text': 'X Ray',
      'icon': "newAssets/medicalFiles/X Ray.jpg",
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': Colors.white
    },
    <String, dynamic>{
      'text': 'CT Scan',
      'icon': "newAssets/medicalFiles/CT Scan.jpg",
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': Colors.white
    },
    <String, dynamic>{
      'text': 'MRI Scan',
      'icon': "newAssets/medicalFiles/MRI Scan.jpg",
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': Colors.white
    },
    <String, dynamic>{
      'text': "Others",
      'icon': "newAssets/medicalFiles/Others.jpg",
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': Colors.white
    },
  ];

  @override
  void initState() {
    prescriptionCompleted.value = null;
    consultationStagesFirestore();
    // timer = Timer.periodic(const Duration(seconds: 6), (Timer timer) async {
    //   count.value++;
    //   if ((count.value == 4 || count.value > 4) && (count.value == 3)) {
    //     timer.cancel();
    //     debugPrint("timer removed");
    //   }
    // });

    Future<void>.delayed(
        Duration.zero, () => StagesVariables.counterValueConsultaionStages.value = 90);
    _pageController.addListener(() {
      setState(() {
        currentIndex = _pageController.page.toInt();
      });
    });
    // counterUIConsultationStages();
    super.initState();
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> stream;

  void consultationStagesFirestore() {
    // FireStoreCollections.teleconsultationServices
    //     .doc("fab2babf669c42fca1d18b1860a99e9d")
    //     .snapshots()
    log("${widget.videocallDetail.appointId} Consultation Page Appointment ID ");
    stream = FireStoreCollections.teleconsultationServices
        .doc(widget.videocallDetail.appointId)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> event) async {
      // ignore: unnecessary_cast
      Map<String, dynamic> data = event.data() as Map<String, dynamic>;
      String command = "";
      if (data != null) {
        command = data['data']['cmd'];
      }
      List<dynamic> receiverId = <dynamic>[];
      // receiverId = data['receiver_id'] ?? data['receiver_ids'];
      if (data['receiver_id'] != null) {
        if (data['receiver_id'] is String) {
          receiverId.add(data['receiver_id']);
        } else if (data['receiver_id'] is List) {
          receiverId.addAll(data['receiver_id']);
        }
      } else {
        if (data['receiver_ids'] is String) {
          receiverId.add(data['receiver_ids']);
        } else if (data['receiver_ids'] is List) {
          receiverId.addAll(data['receiver_ids']);
        }
      }
      // if (data.containsKey("receiver_id")) {
      //   try {
      //     receiverId.addAll(data["receiver_id"]);
      //   } catch (e) {
      //     receiverId.add(data["receiver_id"]);
      //   }
      // }
      // if (data.containsKey("sender_id")) {
      //   receiverId.add(data["sender_id"]);
      // }
      // if (data.containsKey("receiver_ids")) {
      //   receiverId.addAll(data["receiver_ids"]);
      // }
      for (dynamic element in receiverId) {
        element.toString().replaceAll("[", "").replaceAll("]", "");
      }
      if (receiverId.contains(widget.videocallDetail.userID) ||
          receiverId.contains(widget.videocallDetail.docId)) {
        log(command.toString());
        if (command == 'AfterCallPrescriptionStatus' &&
            data["data"].containsKey("perscription_status")) {
          log(command.toString());
          JitsiMeet.closeMeeting();
          Map<String, dynamic> d = data["data"];
          log(d.toString());
          print(data["data"]["perscription_status"].toString());
          prescriptionStatus.value = d["perscription_status"];

          if (prescriptionStatus.value == false) {
            lastStep = false;
            getUserDetailsUpdate = true;
            noPrescription.value = true;
            prescriptionCompleted.value = false;
            if (mounted) setState(() {});
            setAppointId(widget.videocallDetail.appointId);
            StagesVariables.counterValueConsultaionStages.value = 180;
            StagesVariables.counterUIConsultationStages();
          } else {
            prescriptionCompleted.value = true;
            noPrescription.value = false;
          }
          callCompleted.value = true;
          if (mounted) setState(() {});
        } else if (command == 'CallEndedByDoctor') {
          log(command.toString());
          JitsiMeet.closeMeeting();
          // StagesVariables.counterValueConsultaionStages.value = 90;
          // StagesVariables.counterUIConsultationStages();
          isRejoin = true;
          if (widget.videocallDetail.callType != 'SubscriptionCall') {
            if (StagesVariables.iscallError == true &&
                StagesVariables.callErrorAppointmentId ==
                    widget.videocallDetail.appointId.toString()) {
              StagesVariables.callErrorDialog(widget.videocallDetail.callType);
            } else {
              isRejoin = false;
              String apiResponse = await TeleConsultationApiCalls.callStatusUpdate(
                  widget.videocallDetail.appointId, 'completed');
              if (apiResponse == 'Update Sucessfull') {
                String appoinStatus = await TeleConsultationApiCalls.currentAppointmentStatusUpdate(
                    widget.videocallDetail.appointId, 'Completed');
                if (appoinStatus == 'Database Updated') {
                  TeleConsultationApiCalls.calllog(
                      by: 'user',
                      userid: widget.videocallDetail.userID,
                      action: 'end',
                      refrence: widget.videocallDetail.appointId,
                      courseid: '');
                }
              }
              StagesVariables.startTimer90Seconds(callType: widget.videocallDetail.callType);
              print("Timer called in consultation pages screen");
            }
          }
          if (mounted) setState(() {});
        } else if (command == 'AfterCallPrescription') {
          log(command.toString());
          JitsiMeet.closeMeeting();
          StagesVariables.counterValueConsultaionStages.value = 180;
          StagesVariables.counterUIConsultationStages();
          isRejoin = true;
          dynamic teleMedicineStatus = data['data']['perscription_obj'];
          consultationNotes = <String, dynamic>{
            'diagnosis': teleMedicineStatus["diagnosis"],
            'consultation_advice_notes': teleMedicineStatus["consultation_advice_notes"],
          };
          if (teleMedicineStatus["consultation_internal_notes"] != null) {
            consultationNotes['consultation_internal_notes'] =
                teleMedicineStatus["consultation_internal_notes"];
          }
          lastStep = true;
          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
          noPrescription.notifyListeners();
          TeleConsultationApiCalls.updateServiceProvided(
              widget.videocallDetail.userID, widget.videocallDetail.userID);
          setAppointId(widget.videocallDetail.appointId);
          getUserDetailsUpdate = true;
          if (mounted) setState(() {});
        } else {
          log(data.toString());
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    stream.cancel();
    StagesVariables.isTimer90seconds = false;
    StagesVariables._timerUI90ConsultaionStages.cancel();
    super.dispose();
  }

  setAppointId(String appointId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('appointmentIdFromConsultationStages', appointId);
    appointmentDetails(appointId);
  }

  Future<void> appointmentDetails(String appointmentID) async {
    await TeleConsultationApiCalls.appointmentDetailsCalls(appointmentId: appointmentID);
    // prescriptionStatus = false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.primaryColor,
            title:
                //  InkWell(
                //   onTap: () => Get.offAll(LandingPage()),
                //   child:
                const Text('Consultation Stages'),
            // ),
          ),
          body: ValueListenableBuilder<bool>(
              valueListenable: noPrescription,
              builder: (BuildContext ctx, bool noPrescription, Widget child) {
                return noPrescription == false
                    ? SingleChildScrollView(
                        child: ValueListenableBuilder<bool>(
                            valueListenable: prescriptionCompleted,
                            builder: (BuildContext ctx, bool prescriptionComplete, Widget child) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Stack(children: <Widget>[
                                    ValueListenableBuilder<bool>(
                                        valueListenable: callCompleted,
                                        builder:
                                            (BuildContext ctx, bool callComplete, Widget child) {
                                          return ValueListenableBuilder<bool>(
                                              valueListenable: prescriptionStatus,
                                              builder: (BuildContext ctx,
                                                  bool prescriptionStatusbool, Widget child) {
                                                return TimelineTile(
                                                  alignment: TimelineAlign.manual,
                                                  lineXY: 0.1,
                                                  isFirst: true,
                                                  indicatorStyle: IndicatorStyle(
                                                    width: 30,
                                                    color: //!callComplete ?
                                                        prescriptionStatusbool == null
                                                            ? Colors.grey
                                                            : AppColors.primaryColor,
                                                    iconStyle: IconStyle(
                                                      color: Colors.white,
                                                      iconData: Icons.check,
                                                    ),
                                                  ),
                                                  beforeLineStyle: LineStyle(
                                                    color: //!callComplete ?
                                                        prescriptionStatusbool == null
                                                            ? Colors.grey
                                                            : AppColors.primaryColor,
                                                    thickness: 3,
                                                  ),
                                                  endChild: SizedBox(
                                                    height: 35.h,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.only(top: 100.sp, left: 20.sp),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(
                                                            'Consultation Initiated',
                                                            textAlign: TextAlign.start,
                                                            style: // !callComplete
                                                                prescriptionStatusbool == null
                                                                    ? TextStyle(
                                                                        color:
                                                                            AppColors.primaryColor,
                                                                        fontSize: 13.sp,
                                                                        fontWeight: FontWeight.bold)
                                                                    : TextStyle(
                                                                        color: Colors.black,
                                                                        fontSize: 13.sp,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                          ),
                                                          callComplete &&
                                                                  prescriptionComplete.toString() ==
                                                                      "true" &&
                                                                  lastStep == true
                                                              ? TextButton(
                                                                  child: const Text(
                                                                    'Share Medical Report',
                                                                    style: TextStyle(
                                                                        color: Colors.grey),
                                                                  ),
                                                                  onPressed: () {},
                                                                )
                                                              : TextButton(
                                                                  child: const Text(
                                                                    'Share Medical Report',
                                                                    style: TextStyle(
                                                                        color:
                                                                            AppColors.primaryColor),
                                                                  ),
                                                                  onPressed: () {
                                                                    setState(() {
                                                                      setButton();
                                                                    });
                                                                  },
                                                                )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                        }),
                                    Visibility(
                                      visible: lastStep == false,
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 30.sp),
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0.5,
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4)),
                                              ),
                                              onPressed: () {
                                                if (StagesVariables.currentPage != "jitsiMeet" &&
                                                    isRejoin == false &&
                                                    StagesVariables.currentPage == "") {
                                                  StagesVariables.isTimer90seconds = false;
                                                  StagesVariables._timerUI90ConsultaionStages
                                                      .cancel();
                                                  Get.off(VideoCallJitsi(
                                                      videoCallDetail: widget.videocallDetail));
                                                } else if (isRejoin == false) {
                                                  if (StagesVariables.isCallTerminated == true) {
                                                    StagesVariables.isTimer90seconds = false;
                                                    StagesVariables._timerUI90ConsultaionStages
                                                        .cancel();
                                                    Get.off(VideoCallJitsi(
                                                        videoCallDetail: widget.videocallDetail));
                                                  } else {
                                                    Get.snackbar("Info", "Already in call",
                                                        snackPosition: SnackPosition.BOTTOM);
                                                  }
                                                } else {
                                                  Get.snackbar("Info", "Call Completed",
                                                      snackPosition: SnackPosition.BOTTOM);
                                                }
                                              },
                                              child: Text('REJOIN',
                                                  style: TextStyle(
                                                      fontSize: 12.sp,
                                                      fontWeight: FontWeight.w600))),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  Visibility(
                                      visible: medicalfiles ? true : false,
                                      child: SizedBox(
                                        height: 65.h,
                                        width: 90.w,
                                        child: Scaffold(
                                            appBar: currentIndex == 0
                                                ? null
                                                : AppBar(
                                                    backgroundColor: Colors.transparent,
                                                    elevation: 0,
                                                    centerTitle: true,
                                                    leading: InkWell(
                                                      onTap: () {
                                                        if (_pageController.hasClients) {
                                                          _pageController.animateToPage(
                                                            0,
                                                            duration:
                                                                const Duration(milliseconds: 400),
                                                            curve: Curves.easeInOut,
                                                          );
                                                        }
                                                      },
                                                      child: const Icon(
                                                        Icons.arrow_back_ios_new_rounded,
                                                        color: AppColors.primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                            body: ValueListenableBuilder<String>(
                                                valueListenable: selectedmedical,
                                                builder: (BuildContext context, String val,
                                                    Widget child) {
                                                  return PageView(
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    // Disable scrolling
                                                    controller: _pageController,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        // height: 44.h,
                                                        width: double.maxFinite,
                                                        child: ListView.builder(
                                                          itemCount: options.length,
                                                          itemBuilder:
                                                              (BuildContext context, int index) {
                                                            return Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  selectedmedical.value =
                                                                      options[index]['text'];
                                                                  MedicalFiles(
                                                                      appointmentId: widget
                                                                          .videocallDetail
                                                                          .appointId,
                                                                      ihlConsultantId: widget
                                                                          .videocallDetail.docId,
                                                                      normalFlow: false,
                                                                      category: val,
                                                                      consultStages: true,
                                                                      medicalFiles: true);
                                                                  if (_pageController.hasClients) {
                                                                    _pageController.animateToPage(
                                                                      1,
                                                                      duration: const Duration(
                                                                          milliseconds: 400),
                                                                      curve: Curves.easeInOut,
                                                                    );
                                                                  }
                                                                },
                                                                child: Card(
                                                                  elevation: 2,
                                                                  child: ListTile(
                                                                    title: Text(
                                                                      options[index]['text'],
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      BlocProvider(
                                                          create: (BuildContext context) =>
                                                              MedFileBloc()..add(AddMedFileEvent()),
                                                          child: BlocBuilder<MedFileBloc,
                                                                  MedFileState>(
                                                              builder: (BuildContext ctx,
                                                                  MedFileState bState) {
                                                            return MedicalFiles(
                                                                normalFlow: false,
                                                                appointmentId: widget
                                                                    .videocallDetail.appointId,
                                                                ihlConsultantId:
                                                                    widget.videocallDetail.docId,
                                                                category: selectedmedical.value,
                                                                consultStages: true,
                                                                medicalFiles: true);
                                                          }))
                                                    ],
                                                  );
                                                })),
                                      )),
                                  ValueListenableBuilder<bool>(
                                      valueListenable: callCompleted,
                                      builder: (BuildContext ctx, bool callComplete, Widget child) {
                                        return TimelineTile(
                                          alignment: TimelineAlign.manual,
                                          lineXY: 0.1,
                                          isFirst: false,
                                          indicatorStyle: IndicatorStyle(
                                            width: 30,
                                            color: callComplete == false &&
                                                    prescriptionComplete.toString() == "null"
                                                ? Colors.grey
                                                : AppColors.primaryColor,
                                            iconStyle: IconStyle(
                                              color: Colors.white,
                                              iconData: Icons.check,
                                            ),
                                          ),
                                          beforeLineStyle: LineStyle(
                                            color: callComplete == false &&
                                                    prescriptionComplete.toString() == "null"
                                                ? Colors.grey
                                                : AppColors.primaryColor,
                                            thickness: 3,
                                          ),
                                          endChild: SizedBox(
                                            height: 30.h,
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 85.sp, left: 20.sp),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    'Preparing instructions',
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: (callComplete &&
                                                                prescriptionComplete.toString() !=
                                                                    "null" &&
                                                                prescriptionComplete.toString() ==
                                                                    "false" &&
                                                                lastStep == false)
                                                            ? AppColors.primaryColor
                                                            : (callComplete &&
                                                                    prescriptionComplete
                                                                            .toString() ==
                                                                        "true" &&
                                                                    lastStep == true)
                                                                ? Colors.black
                                                                : lastStep == false &&
                                                                        prescriptionComplete
                                                                                .toString() ==
                                                                            "true"
                                                                    ? AppColors.primaryColor
                                                                    : Colors.grey,
                                                        fontSize: 13.sp,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                  Stack(alignment: AlignmentDirectional.bottomCenter, children: <
                                      Widget>[
                                    ValueListenableBuilder<bool>(
                                        valueListenable: callCompleted,
                                        builder:
                                            (BuildContext ctx, bool callComplete, Widget child) {
                                          return ValueListenableBuilder<bool>(
                                              valueListenable: prescriptionStatus,
                                              builder: (BuildContext ctx,
                                                  bool prescriptionStatusbool, Widget child) {
                                                return TimelineTile(
                                                  alignment: TimelineAlign.manual,
                                                  lineXY: 0.1,
                                                  isFirst: false,
                                                  isLast: true,
                                                  indicatorStyle: IndicatorStyle(
                                                    width: 30,
                                                    color: prescriptionStatusbool == null
                                                        ? Colors.grey
                                                        : (callComplete &&
                                                                prescriptionComplete != null &&
                                                                lastStep == false
                                                            // prescriptionComplete == false
                                                            )
                                                            ? Colors.grey
                                                            : AppColors.primaryColor,
                                                    iconStyle: IconStyle(
                                                      color: Colors.white,
                                                      iconData: Icons.check,
                                                    ),
                                                  ),
                                                  beforeLineStyle: LineStyle(
                                                    color: prescriptionStatusbool == null
                                                        ? Colors.grey
                                                        : (callComplete &&
                                                                prescriptionComplete != null &&
                                                                // prescriptionComplete == false
                                                                lastStep == false)
                                                            ? Colors.grey
                                                            : AppColors.primaryColor,
                                                    thickness: 3,
                                                  ),
                                                  endChild: SizedBox(
                                                    height: 30.h,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.only(top: 85.sp, left: 20.sp),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          prescriptionStatusbool == null
                                                              ? Text(
                                                                  'Consultation Completed',
                                                                  textAlign: TextAlign.start,
                                                                  style: TextStyle(
                                                                      color: Colors.grey,
                                                                      fontSize: 13.sp,
                                                                      fontWeight: FontWeight.bold),
                                                                )
                                                              : (callComplete &&
                                                                      prescriptionComplete !=
                                                                          null &&
                                                                      lastStep == false
                                                                  //prescriptionComplete == false
                                                                  )
                                                                  ? Text(
                                                                      'Consultation Completed',
                                                                      textAlign: TextAlign.start,
                                                                      style: TextStyle(
                                                                          color: Colors.grey,
                                                                          fontSize: 13.sp,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    )
                                                                  : Text(
                                                                      'Consultation Completed',
                                                                      textAlign: TextAlign.start,
                                                                      style: TextStyle(
                                                                          color: Colors.black,
                                                                          fontSize: 13.sp,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                        }),
                                    getUserDetailsUpdate
                                        ? lastStep
                                            ? ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                  ),
                                                  backgroundColor: AppColors.primaryAccentColor,
                                                  textStyle: TextStyle(
                                                      fontSize: ScUtil().setSp(14),
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(12.0),
                                                  child: Text(
                                                    'TAP TO CONTINUE',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: "Poppins",
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Get.to(ConsultationSummaryScreen(
                                                      appointmentId:
                                                          widget.videocallDetail.appointId,
                                                      fromCall: true));
                                                  StagesVariables.isTimer90seconds = false;
                                                  TeleConsultationApiCalls.callStatusUpdate(
                                                      widget.videocallDetail.appointId,
                                                      "completed");
                                                },
                                              )
                                            : const SizedBox()
                                        : const SizedBox(),
                                  ]),
                                  ValueListenableBuilder<int>(
                                    valueListenable: StagesVariables.counterValueConsultaionStages,
                                    builder:
                                        (BuildContext context, int counterValue, Widget widget) {
                                      return counterValue != 90
                                          ? lastStep
                                              ? Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Will be redirect automatically in ${StagesVariables.counterValueConsultaionStages.value.toString()} secs.",
                                                    style: const TextStyle(
                                                        color: Colors.grey, fontSize: 18),
                                                  ),
                                                )
                                              : const SizedBox()
                                          : const SizedBox();
                                    },
                                  ),
                                  SizedBox(
                                    height: 2.h,
                                  )
                                ],
                              );
                            }))
                    : SingleChildScrollView(
                        child: ValueListenableBuilder<bool>(
                            valueListenable: prescriptionCompleted,
                            builder: (BuildContext ctx, bool prescriptionComplete, Widget child) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  ValueListenableBuilder<bool>(
                                      valueListenable: callCompleted,
                                      builder: (BuildContext ctx, bool callComplete, Widget child) {
                                        return TimelineTile(
                                          alignment: TimelineAlign.manual,
                                          lineXY: 0.1,
                                          isFirst: true,
                                          indicatorStyle: IndicatorStyle(
                                            width: 30,
                                            color: //!callComplete ? Colors.grey :
                                                AppColors.primaryColor,
                                            iconStyle: IconStyle(
                                              color: Colors.white,
                                              iconData: Icons.check,
                                            ),
                                          ),
                                          beforeLineStyle: const LineStyle(
                                            color: //!callComplete ? Colors.grey :
                                                AppColors.primaryColor,
                                            thickness: 3,
                                          ),
                                          endChild: SizedBox(
                                            height: 35.h,
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 100.sp, left: 20.sp),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    'Consultation Initiated',
                                                    textAlign: TextAlign.start,
                                                    style: // !callComplete
                                                        // ? TextStyle(
                                                        //     color: Colors.grey,
                                                        //     fontSize: 13.sp,
                                                        //     fontWeight: FontWeight.bold):
                                                        TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13.sp,
                                                            fontWeight: FontWeight.bold),
                                                  ),

                                                  ///commented on 310 Dec
                                                  // prescriptionComplete.toString() != "null" &&
                                                  //         prescriptionComplete.toString() != "true"
                                                  //     // prescriptionComplete.toString() == "false"
                                                  //     ?
                                                  const SizedBox()
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                  ValueListenableBuilder<bool>(
                                      valueListenable: callCompleted,
                                      builder: (BuildContext ctx, bool callComplete, Widget child) {
                                        return ValueListenableBuilder<bool>(
                                            valueListenable: prescriptionStatus,
                                            builder: (BuildContext ctx, bool prescriptionStatusbool,
                                                Widget child) {
                                              return TimelineTile(
                                                alignment: TimelineAlign.manual,
                                                lineXY: 0.1,
                                                isLast: true,
                                                isFirst: false,
                                                indicatorStyle: IndicatorStyle(
                                                  width: 30,
                                                  color: //!callComplete ? Colors.grey :
                                                      // prescriptionStatusbool == null
                                                      //     ? Colors.grey
                                                      //     : (callComplete &&
                                                      //             prescriptionComplete.toString() !=
                                                      //                 "null" &&
                                                      //             prescriptionComplete.toString() ==
                                                      //                 "true")
                                                      //         ? Colors.grey
                                                      //         :
                                                      AppColors.primaryColor,
                                                  iconStyle: IconStyle(
                                                    color: Colors.white,
                                                    iconData: Icons.check,
                                                  ),
                                                ),
                                                beforeLineStyle: const LineStyle(
                                                  color:
                                                      // prescriptionStatusbool == null
                                                      // ? Colors.grey
                                                      // : (callComplete &&
                                                      //         prescriptionComplete.toString() !=
                                                      //             "null" &&
                                                      //         prescriptionComplete.toString() ==
                                                      //             "true")
                                                      //     ? Colors.grey
                                                      //     :
                                                      AppColors.primaryColor,
                                                  thickness: 3,
                                                ),
                                                endChild: SizedBox(
                                                  height: 35.h,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.only(top: 100.sp, left: 20.sp),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Text(
                                                          'Consultation Completed',
                                                          textAlign: TextAlign.start,
                                                          style: // !callComplete
                                                              // ? TextStyle(
                                                              //     color: Colors.grey,
                                                              //     fontSize: 13.sp,
                                                              //     fontWeight: FontWeight.bold):
                                                              TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 13.sp,
                                                                  fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                      }),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      backgroundColor: AppColors.primaryAccentColor,
                                      textStyle: TextStyle(
                                          fontSize: ScUtil().setSp(14),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(
                                        'TAP TO CONTINUE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    onPressed: () {
                                      Get.to(ConsultationSummaryScreen(
                                        fromCall: true,
                                        appointmentId: widget.videocallDetail.appointId,
                                      ));
                                      StagesVariables.isTimer90seconds = false;
                                      TeleConsultationApiCalls.callStatusUpdate(
                                          widget.videocallDetail.appointId, "completed");
                                    },
                                  ),
                                  ValueListenableBuilder<int>(
                                    valueListenable: StagesVariables.counterValueConsultaionStages,
                                    builder:
                                        (BuildContext context, int counterValue, Widget widget) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Will be redirect automatically in ${StagesVariables.counterValueConsultaionStages.value.toString()} secs.",
                                          style: const TextStyle(color: Colors.grey, fontSize: 18),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            }));
              })),
    );
  }

//Counter UI for indicating 90 seconds

  void setButton() {
    setState(() {
      medicalfiles = !medicalfiles;
    });
  }

// Future<Map> appointmentDetails(String appointmentID) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   var authToken = prefs.get('auth_token');
//   var userData = prefs.get('data');
//   var decodedResponse = jsonDecode(userData);
//   String iHLUserToken = decodedResponse['Token'];
//   final response = await _client.get(
//       Uri.parse(API.iHLUrl + '/consult/get_appointment_details?appointment_id=' + appointmentID),
//       headers: {
//         'Content-Type': 'application/json',
//         'ApiToken': authToken,
//         'Token': iHLUserToken
//       });
//   if (response.statusCode == 200) {
//     if (response.body != '""') {
//       String value = response.body;
//       var lastStartIndex = 0;
//       var lastEndIndex = 0;
//       var reasonLastEndIndex = 0;
//       var alergyLastEndIndex = 0;
//       var reasonForVisit = [];
//       var notesLastEndIndex = 0;
//       for (int i = 0; i < value.length; i++) {
//         if (value.contains("reason_for_visit")) {
//           var start = ";appointment_id";
//           var end = "vendor_appointment_id";
//           var startIndex = value.indexOf(start, lastStartIndex);
//           var endIndex = value.indexOf(end, lastEndIndex);
//           lastStartIndex = value.indexOf(start, startIndex) + start.length;
//           lastEndIndex = value.indexOf(end, endIndex) + end.length;
//           String a = value.substring(startIndex + start.length, endIndex);
//           var parseda1 = a.replaceAll('&quot', '');
//           var parseda2 = parseda1.replaceAll(';:;', '');
//           var parseda3 = parseda2.replaceAll(';,;', '');
//
//           //reason
//           var reasonStart = "reason_for_visit";
//           var reasonEnd = ";notes";
//           var reasonStartIndex = value.indexOf(reasonStart);
//           var reasonEndIndex = value.indexOf(reasonEnd, reasonLastEndIndex);
//           reasonLastEndIndex = value.indexOf(reasonEnd, reasonLastEndIndex) + reasonEnd.length;
//           String b = value.substring(reasonStartIndex + reasonStart.length, reasonEndIndex);
//           var parsedb1 = b.replaceAll('&quot', '');
//           var parsedb2 = parsedb1.replaceAll(';:;', '');
//           var parsedb3 = parsedb2.replaceAll(';,', '');
//           var temp1 = value.substring(0, reasonStartIndex);
//           var temp2 = value.substring(reasonEndIndex, value.length);
//           value = temp1 + temp2;
//           //alergy
//           var alergyStart = "alergy";
//           var alergyEnd = "appointment_start_time";
//           var alergyStartIndex = value.indexOf(alergyStart);
//           var alergyEndIndex = value.indexOf(alergyEnd, alergyLastEndIndex);
//           alergyLastEndIndex = alergyEndIndex + alergyEnd.length;
//           String c = value.substring(alergyStartIndex + alergyStart.length, alergyEndIndex);
//           var parsedc1 = c.replaceAll('&quot;', '');
//           var parsedc2 = parsedc1.replaceAll(':', '');
//           var parsedc3 = parsedc2.replaceAll(',', '');
//           temp1 = value.substring(0, alergyStartIndex);
//           temp2 = value.substring(alergyEndIndex, value.length);
//           value = temp1 + temp2;
//           //notes
//           var notesStart = ";notes";
//           var notesEnd = ";kiosk_checkin_history";
//           var notesStartIndex = value.indexOf(notesStart);
//           var notesEndIndex = value.indexOf(notesEnd, notesLastEndIndex);
//           notesLastEndIndex = notesEndIndex + notesEnd.length;
//           String d = value.substring(notesStartIndex + notesStart.length, notesEndIndex);
//           var parsedd1 = d.replaceAll('&quot;', '');
//           var parsedd2 = parsedd1.replaceAll(':', '');
//           var parsedd3 = parsedd2.replaceAll(',', '');
//           var parsedd4 = parsedd3.replaceAll('&quot', '');
//           var parsedd5 = parsedd4.replaceAll('[{', '');
//           var parsedd6 = parsedd5.replaceAll('\\', '');
//           var parsedd7 = parsedd6.replaceAll('}]', '');
//           var parsedd8 = parsedd7.replaceAll('}', '');
//           var parsedd9 = parsedd8.replaceAll('{', '');
//           var parsedd10 = parsedd9.replaceAll('&#39;', '');
//           var parsedd11 = parsedd10.replaceAll('[', '');
//           var parsedd12 = parsedd11.replaceAll(']', '');
//           temp1 = value.substring(0, notesStartIndex);
//           temp2 = value.substring(notesEndIndex, value.length);
//           value = temp1 + temp2;
//
//           Map<String, String> app = {};
//           app['appointment_id'] = parseda3;
//           app['reason_for_visit'] = parsedb3;
//           app["alergy"] = parsedc3;
//           app['notes'] = parsedd12;
//           reasonForVisit.add(app);
//         } else {
//           i = value.length;
//         }
//       }
//
//       var parsedString = value.replaceAll('&quot', '"');
//       var parsedString2 = parsedString.replaceAll("\\\\\\", "");
//       var parsedString3 = parsedString2.replaceAll("\\", "");
//       var parsedString4 = parsedString3.replaceAll(";", "");
//       var parsedString5 = parsedString4.replaceAll('""', '"');
//       var parsedString6 = parsedString5.replaceAll('"[', '[');
//       var parsedString7 = parsedString6.replaceAll(']"', ']');
//       var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
//       var pasrseString9 = pasrseString8.replaceAll('"{', '{');
//       var pasrseString10 = pasrseString9.replaceAll('}"', '}');
//       var pasrseString11 = pasrseString10.replaceAll('}"', '}');
//       var pasrseString12 = pasrseString11.replaceAll(':",', ':"",');
//       var parseString13 = pasrseString12.replaceAll(':"}', ':""}');
//       var finalOutput = parseString13.replaceAll('/"', '/');
//       Map details = json.decode(finalOutput);
//       for (int i = 0; i < reasonForVisit.length; i++) {
//         details['message']['reason_for_visit'] = reasonForVisit[i]['reason_for_visit'];
//         details['message']['alergy'] = reasonForVisit[i]['alergy'];
//         details['message']['notes'] = reasonForVisit[i]['notes'];
//         //  print(details['message']['reason_for_visit']);
//         //  print(details['message']['alergy']);
//       }
//       if (this.mounted) {
//         setState(() {
//           consultationDetails = details;
//         });
//       }
//       getItem(consultationDetails);
//       if (this.mounted) {
//         setState(() {
//           consultantNameFromAPI =
//               consultationDetails["message"]["consultant_name"].toString() ?? "N/A";
//           specialityFromAPI = consultationDetails["message"]["specality"].toString() ?? "N/A";
//           appointmentStartTimeFromAPI =
//               consultationDetails["message"]["appointment_start_time"].toString() ?? "N/A";
//           appointmentEndTimeFromAPI =
//               consultationDetails["message"]["appointment_end_time"].toString() ?? "N/A";
//           appointmentStatusFromAPI =
//               consultationDetails["message"]["appointment_status"].toString() ?? "N/A";
//           callStatusFromAPI = consultationDetails["message"]["call_status"].toString() ?? "N/A";
//           consultationFeesFromAPI =
//               consultationDetails["message"]["consultation_fees"].toString() ?? "N/A";
//           modeOfPaymentFromAPI =
//               consultationDetails["message"]["mode_of_payment"].toString() ?? "N/A";
//           appointmentModelFromAPI =
//               consultationDetails["message"]["appointment_model"].toString() ?? "N/A";
//           reasonOfVisitFromAPI =
//               consultationDetails["message"]["reason_for_visit"].toString() ?? "N/A";
//           allergyFromAPI = consultationDetails["message"]["alergy"].toString() ?? "N/A";
//           userFirstNameFromAPI =
//               consultationDetails["user_details"]["user_first_name"].toString() ?? "N/A";
//           userLastNameFromAPI =
//               consultationDetails["user_details"]["user_last_name"].toString() ?? "N/A";
//           userEmailFromAPI =
//               consultationDetails["user_details"]["user_email"].toString() ?? "N/A";
//           userContactFromAPI =
//               consultationDetails["user_details"]["user_mobile_number"].toString() ?? "N/A";
//           ihlConsultantIDFromAPI =
//               consultationDetails["message"]["ihl_consultant_id"].toString() ?? "N/A";
//           vendorConsultatationIDFromAPI =
//               consultationDetails["message"]["vendor_consultant_id"].toString() ?? "N/A";
//           vendorNameFromAPI = consultationDetails["message"]["vendor_name"].toString() ?? "N/A";
//           provider = consultationDetails["consultant_details"]["provider"].toString() ?? "N/A";
//         });
//       }
//       setDataForConsultationSummaryAndBill();
//     } else {
//       consultationDetails = {};
//     }
//   }
//   return consultationDetails;
// }
}
