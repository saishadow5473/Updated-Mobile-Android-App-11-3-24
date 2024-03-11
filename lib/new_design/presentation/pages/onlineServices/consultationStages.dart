// ignore: file_names
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../models/freeconsultant_model.dart';
import '../../../app/utils/appColors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../data/model/TeleconsultationModels/doctorModel.dart';
import '../../../firebase_utils/firestore_instructions.dart';
import '../../../jitsi/genix_signal.dart';
import '../../controllers/dashboardControllers/upComingDetailsController.dart';
import '../teleconsultation/wait_for_consultant_screen.dart';
import 'appointmentAndLiveCallSuccess.dart';

// import 'package:timelines/timelines.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../../../../constants/api.dart';
import 'myAppointmentsTabs.dart';

class TeleConsultationStagesScreen extends StatefulWidget {
  String startDate, endDate;
  bool JoinCall;
  FreeConsultation freeConsultation;
  bool loading;
  DoctorModel doctorDetails;

  TeleConsultationStagesScreen(
      {Key key,
      this.startDate,
      this.endDate,
      this.JoinCall,
      this.freeConsultation,
      this.loading,
      this.doctorDetails})
      : super(key: key);

  @override
  State<TeleConsultationStagesScreen> createState() => _TeleConsultationStagesScreenState();
}

class _TeleConsultationStagesScreenState extends State<TeleConsultationStagesScreen> {
  List<String> steps = <String>[
    "Verifying status",
    "Checking Availability",
    "Booking the Service",
    "Completing the Process"
  ];
  ValueNotifier<int> count = ValueNotifier<int>(-1);
  Timer timer;
  bool freeRes = false;
  var appointmentId;
  String vendorAppointmentId;
  @override
  void initState() {
    getResponse();
    timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) async {
      count.value++;
      if ((count.value == 4 || count.value > 4) && (count.value == 3 || freeRes == true)) {
        timer.cancel();
        debugPrint("timer removed");
        if (appointmentId != null) {
          Get.to(AppointmentAndLiveCallSuccess(
              vendorAppointmentId: vendorAppointmentId,
              appointId: appointmentId,
              appointmentTiming: "${widget.startDate} - ${widget.endDate}",
              liveCall: widget.JoinCall,
              doctorDetails: widget.doctorDetails));
        } else {}
      }
    });
    super.initState();
  }

  getResponse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _token = API.headerr['Token'];
    http.Response _freeRes = await http.post(
      // Uri.parse('https://6915-103-182-121-26.ngrok-free.app' + '/consult/free_consultation'),
      Uri.parse('${API.iHLUrl}/consult/free_consultation'),
      body: json.encode(widget.freeConsultation.toJson()),
      headers: {
        'ApiToken':
            '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==',
        'Token': '$_token',
      },
    );

    log(DateTime.now().toString());

    // widget.visitDetails['doctor']['vendor_id'].toString() == "GENIX" && widget.visitDetails['livecall'] == true ? true:false,

    if (_freeRes.statusCode == 200) {
      log(json.encode(widget.freeConsultation.toJson()));
      print(_freeRes.body);
      var _data = json.decode(_freeRes.body);

      var appointmentStatus = _data['BookApointment_status'];
      var paymentStatus = _data['PaymentTransaction_status'];
      setState(() {
        freeRes = true;
      });
      var appointmentStatus1 = appointmentStatus.replaceAll('&quot;', '"');
      var appointmentStatus2 = json.decode(appointmentStatus1);
      if (appointmentStatus2['status'] == 'success') {
        var appointId = appointmentStatus2[
            'appointment_id']; //'ihl_consultant_' + finalResponse['appointment_id'];
        var vendorAppointId = appointmentStatus2['vendor_appointment_id'];
        appointmentId = appointmentStatus2['appointment_id'];
        if (paymentStatus['status'] == 'inserted') {
          Object data = prefs.get('data');
          Map res = jsonDecode(data);
          String userFirstName, userLastName, ihlUserName, userID;
          userFirstName = res['User']['firstName'];
          userLastName = res['User']['lastName'];
          userID = res['User']['id'];
          userFirstName ??= "";
          userLastName ??= "";
          ihlUserName = "$userFirstName $userLastName";
          vendorAppointmentId = vendorAppointId;
          if (!widget.JoinCall) {
            FireStoreServices.appointmentStatusUpdate(
                attributes: AppointmentStatusModel(
                    docID: widget.doctorDetails.ihlConsultantId.toString(),
                    userID: userID,
                    status: "Requested",
                    appointmentID: appointmentId));
          }
          // ignore: use_build_context_synchronously
          // AwesomeDialog(
          //   context: context,
          //   animType: AnimType.TOPSLIDE,
          //   headerAnimationLoop: true,
          //   dialogType: DialogType.success,
          //   dismissOnTouchOutside: false,
          //   title: 'Success!',
          //   desc: widget.JoinCall
          //       ? 'Appointment confirmed! Join in and kindly wait for the doctor to connect.'
          //       : 'Appointment Booked Successfully ',
          //   btnOkOnPress: () {
          //     if (widget.JoinCall == true) {
          //       if (widget.doctorDetails.vendorId.toString() == 'GENIX') {
          //         Get.to(GenixSignal(
          //             genixCallDetails: GenixCallDetails(
          //                 genixAppointId: appointmentId.replaceAll("ihl_consultant_", ''),
          //                 ihlUserId: userID,
          //                 specality: widget.doctorDetails.consultantSpeciality.first,
          //                 vendorAppointmentId: vendorAppointId,
          //                 vendorConsultantId: widget.doctorDetails.vendorConsultantId,
          //                 vendorUserName: widget.doctorDetails.userName)));
          //       } else {
          //         Get.offAll(WaitForConsultant(
          //           videoCallDetails: VideoCallDetail(
          //               appointId: appointId,
          //               docId: widget.doctorDetails.ihlConsultantId.toString(),
          //               userID: userID,
          //               callType: "LiveCall",
          //               ihlUserName: ihlUserName),
          //         ));
          //       }
          //     } else {
          //       Get.find<UpcomingDetailsController>().updateUpcomingDetails(fromChallenge: false);
          //       Get.to(MyAppointmentsTabs(fromCall: true));
          //     }
          //   },
          //   onDismissCallback: (_) {
          //     debugPrint('Dialog Dissmiss from callback');
          //   },
          //   btnOkText: widget.JoinCall == true ? 'Join Call' : 'View My Appointments',
          // );
        } else {
          widget.loading = false;

          // ignore: use_build_context_synchronously
          AwesomeDialog(
                  context: context,
                  animType: AnimType.topSlide,
                  headerAnimationLoop: true,
                  dialogType: DialogType.INFO,
                  dismissOnTouchOutside: false,
                  title: 'Failed!',
                  desc: 'Appointment not Booked. Please try again later',
                  btnOkOnPress: () {
                    Navigator.of(context).pop();
                  },
                  btnOkColor: AppColors.primaryAccentColor,
                  btnOkText: 'Try Later',
                  btnOkIcon: Icons.refresh,
                  onDismissCallback: (_) {})
              .show();
        }
      } else if (appointmentStatus2['status'] == 'consultant_busy_failure') {
        widget.loading = false;
        // ignore: use_build_context_synchronously
        AwesomeDialog(
                context: context,
                animType: AnimType.topSlide,
                headerAnimationLoop: true,
                dialogType: DialogType.info,
                dismissOnTouchOutside: false,
                title: 'Busy!',
                desc: 'Consultant have appointment!',
                btnOkOnPress: () {
                  Navigator.of(context).pop();
                },
                btnOkColor: AppColors.primaryAccentColor,
                btnOkText: 'Try Later',
                btnOkIcon: Icons.refresh,
                onDismissCallback: (_) {})
            .show();
        // Get.defaultDialog(title: 'Busy', middleText: 'Consultant have appointment');
      } else {
        widget.loading = false;

        // ignore: use_build_context_synchronously
        AwesomeDialog(
                context: context,
                animType: AnimType.topSlide,
                headerAnimationLoop: true,
                dialogType: DialogType.info,
                dismissOnTouchOutside: false,
                title: 'Failed!',
                desc: 'Appointment not Booked. Please try again later',
                btnOkOnPress: () {
                  Get.to(MyAppointmentsTabs(fromCall: true));
                },
                btnOkColor: AppColors.primaryAccentColor,
                btnOkText: 'Try Later',
                btnOkIcon: Icons.refresh,
                onDismissCallback: (_) {})
            .show();
      }
    } else {
      widget.loading = false;

      // ignore: use_build_context_synchronously
      AwesomeDialog(
              context: context,
              animType: AnimType.topSlide,
              headerAnimationLoop: true,
              dialogType: DialogType.info,
              dismissOnTouchOutside: false,
              title: 'Failed!',
              desc: 'Appointment not booked!\nPlease try again later!',
              btnOkOnPress: () {
                Get.to(MyAppointmentsTabs(fromCall: true));
              },
              btnOkColor: AppColors.primaryAccentColor,
              btnOkText: 'Try Later',
              btnOkIcon: Icons.refresh,
              onDismissCallback: (_) {})
          .show();
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primaryColor,
          title: const Text("Consultation Stages"),
          centerTitle: true,
        ),
        body: Container(
          alignment: Alignment.center,
          width: 100.w,
          height: 100.h,
          margin: EdgeInsets.only(left: 15.w),
          child: SingleChildScrollView(
              child: ValueListenableBuilder<int>(
                  valueListenable: count,
                  builder: (BuildContext ctx, int value, Widget child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ...steps.map((String e) {
                          int index = steps.indexWhere((String element) => element == e);
                          return TimelineTile(
                              lineXY: 0,
                              beforeLineStyle: LineStyle(
                                  color:
                                      count.value < index ? Colors.grey : AppColors.primaryColor),
                              alignment: TimelineAlign.start,
                              isFirst: index == 0 ? true : false,
                              isLast: index == steps.length - 1 ? true : false,
                              indicatorStyle: IndicatorStyle(
                                width: 3.h,
                                color: count.value < index ? Colors.grey : AppColors.primaryColor,
                                iconStyle: IconStyle(
                                    color: Colors.white,
                                    iconData: Icons.done_rounded,
                                    fontSize: 20),
                              ),
                              endChild: Container(
                                alignment: Alignment.centerLeft,
                                height: 20.h,
                                width: 60.w,
                                child: Padding(
                                    padding: EdgeInsets.only(left: 5.w),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          e,
                                          style: TextStyle(
                                            color: index <= value
                                                ? AppColors.primaryColor
                                                : Colors.black,
                                            letterSpacing: index <= value ? 0.8 : 0,
                                            fontWeight: index <= value
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        AnimatedContainer(
                                          // height: 3.w,
                                          // width: 3.w,
                                          padding: EdgeInsets.all(0.5.w),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                index <= value ? Colors.green : Colors.transparent,
                                          ),
                                          curve: Curves.easeIn,
                                          duration: const Duration(milliseconds: 1000),
                                          child: Icon(
                                            Icons.done_rounded,
                                            color:
                                                index <= value ? Colors.white : Colors.transparent,
                                          ),
                                        )
                                      ],
                                    )),
                              ));
                        }).toList(),
                      ],
                    );
                  })),
        ),
      ),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<String> steps = <String>[
    "Initializing Payment...",
    "Checking Status...",
    "Connecting to Payment screen...",
  ];
  ValueNotifier<int> count = ValueNotifier<int>(-1);
  Timer timer;
  bool freeRes = false;
  var appointmentId;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) async {
      count.value++;
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          automaticallyImplyLeading: false,
          title: const Text("Payment Stages"),
          centerTitle: true,
        ),
        body: Container(
          alignment: Alignment.center,
          width: 100.w,
          height: 100.h,
          margin: EdgeInsets.only(left: 10.w),
          child: SingleChildScrollView(
              child: ValueListenableBuilder<int>(
                  valueListenable: count,
                  builder: (BuildContext ctx, int value, Widget child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ...steps.map((String e) {
                          int index = steps.indexWhere((String element) => element == e);
                          return TimelineTile(
                              lineXY: 0,
                              beforeLineStyle: LineStyle(
                                  color:
                                      count.value < index ? Colors.grey : AppColors.primaryColor),
                              alignment: TimelineAlign.start,
                              isFirst: index == 0 ? true : false,
                              isLast: index == steps.length - 1 ? true : false,
                              indicatorStyle: IndicatorStyle(
                                width: 3.h,
                                color: count.value < index ? Colors.grey : AppColors.primaryColor,
                                iconStyle: IconStyle(
                                    color: Colors.white,
                                    iconData: Icons.done_rounded,
                                    fontSize: 20),
                              ),
                              endChild: Container(
                                alignment: Alignment.centerLeft,
                                height: 32.h,
                                width: 60.w,
                                child: Padding(
                                    padding: EdgeInsets.only(left: 5.w),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          e,
                                          style: TextStyle(
                                            color: index <= value
                                                ? AppColors.primaryColor
                                                : Colors.black,
                                            letterSpacing: index <= value ? 0.8 : 0,
                                            fontWeight: index <= value
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        AnimatedContainer(
                                          // height: 3.w,
                                          // width: 3.w,
                                          padding: EdgeInsets.all(0.5.w),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                index <= value ? Colors.green : Colors.transparent,
                                          ),
                                          curve: Curves.easeIn,
                                          duration: const Duration(milliseconds: 1000),
                                          child: Icon(
                                            Icons.done_rounded,
                                            color:
                                                index <= value ? Colors.white : Colors.transparent,
                                          ),
                                        )
                                      ],
                                    )),
                              ));
                        }).toList(),
                      ],
                    );
                  })),
        ),
      ),
    );
  }
}
