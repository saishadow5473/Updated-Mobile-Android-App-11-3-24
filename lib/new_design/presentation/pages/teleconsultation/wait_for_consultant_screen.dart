import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../app/utils/appColors.dart';
import '../../../data/providers/network/api_provider.dart';
import '../../../firebase_utils/firebase_utils.dart' as fire_node;
import '../../../jitsi/video_call_jitsi.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_apiCalls.dart';
import '../onlineServices/myAppointmentsTabs.dart';

class WaitForConsultant extends StatefulWidget {
  const WaitForConsultant({Key key, @required this.videoCallDetails}) : super(key: key);
  final VideoCallDetail videoCallDetails;

  @override
  State<WaitForConsultant> createState() => _WaitForConsultantState();
}

class _WaitForConsultantState extends State<WaitForConsultant> {
  bool callDeclinedByDoctor = false;
  bool loading = true;
  bool showMissedCallMessage = false;
  bool success = false;
  StreamSubscription<dynamic> stream;

  @override
  void initState() {
    // widget.videoCallDetails = VideoCallDetail(
    //     appointId: "0080ef7b4a7143b6827bee4c747f1be9",
    //     docId: "docId",
    //     userID: "userID",
    //     callType: "LiveCall",
    //     ihlUserName: "ihlUserName");
    callDeclinedByDoctor = false;
    if (widget.videoCallDetails.callType == "appointmentCall") {
      appointmentDetails(widget.videoCallDetails.callType, "");
    } else if (widget.videoCallDetails.callType == "SubscriptionCall") {
      afterWidgetBuild(onComplete: () => log("afdsf"));
      //  Get.offNamedUntil(Routes.ConsultVideo, (Route route) => false, arguments: [
      //   widget.appointmentDetails[0],
      //   widget.appointmentDetails[1],
      //   widget.appointmentDetails[2],
      //   'SubscriptionCall',
      //   widget.appointmentDetails[4]
      // ]);
    } else if (widget.videoCallDetails.callType == "LiveCall") {
      asynFunction();
    }
    super.initState();
  }

  asynFunction() async {
    List<String> receiverIds = <String>[];
    receiverIds.add(widget.videoCallDetails.docId);
    startTimerFor45Seconds();
    stream = FireStoreCollections.teleconsultationServices
        .doc(widget.videoCallDetails.appointId)
        .snapshots()
        .listen((DocumentSnapshot<dynamic> event) {
      callListner(event, widget.videoCallDetails.userID);
    });
    fire_node.publishCallDetails(
        action: 'NewLiveAppointment',
        receiverIds: receiverIds,
        userId: widget.videoCallDetails.userID,
        appointmentId: widget.videoCallDetails.appointId,
        userName: widget.videoCallDetails.ihlUserName,
        transactionId: "sdf");
    // s.publishCallDetails(
    //   'NewLiveAppointment',
    //   receiverIds,
    //   widget.appointmentDetails[2],
    //   widget.appointmentDetails[0].toString().replaceAll("ihl_consultant_", ""),
    //   widget.appointmentDetails[4],
    // );
  }

  @override
  void dispose() {
    if (stream != null) stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text((loading == false && success == true)
            ? 'Call Connected !'
            : (loading == false && success == true)
                ? 'Call Declined!'
                : (loading == false && success == false && callDeclinedByDoctor == true)
                    ? 'Call Declined!'
                    : (showMissedCallMessage == true)
                        ? 'Connecting Consultant Failed'
                        : "Wait for consultant"),
      ),
      body: SizedBox(
        height: 100.h - AppBar().preferredSize.height,
        width: 100.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (loading == false && success == true)
                ? Lottie.network(API.callAcceptedLottieFileUrl,
                    height: 50.w, width: 50.w, fit: BoxFit.cover)
                : (showMissedCallMessage == true || callDeclinedByDoctor == true)
                    ? Lottie.network(API.declinedLottieFileUrl, height: 50.w, width: 50.w)
                    : (loading == true && success == false)
                        ? Lottie.network(
                            'https://assets5.lottiefiles.com/packages/lf20_e5fibvuv.json',
                            height: 50.w,
                            width: 50.w)
                        : const SizedBox(),
            SizedBox(height: 3.h),
            Container(
              child: (loading == false && success == false && callDeclinedByDoctor == true)
                  ? const Text(
                      " Sorry. The consultant declined the call. We're initiating the refund.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                      ))
                  : (widget.videoCallDetails.callType != "LiveCall")
                      ? const Text(
                          'The consultant will join 5 minutes prior to the scheduled appointment.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        )
                      : widget.videoCallDetails.callType == "LiveCall"
                          ? (showMissedCallMessage == true || callDeclinedByDoctor == true)
                              ? const Text(
                                  "Consultant is currently busy. Please rejoin the call via 'My Appointments'.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Please wait while the Consultant Joins...',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                )
                          : null,
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

//The code above is a function that takes a VoidCallback argument named onComplete. The function adds
//a post frame callback to the WidgetsBinding instance, which triggers the onComplete callback when
//the frame is finished building. This is useful for performing an action after the
//widget tree has been built.⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪

  void afterWidgetBuild({VoidCallback onComplete}) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => onComplete());

  Future<void> appointmentDetails(String callStatus, dynamic navigation) async {
    if (callStatus != 'on_going') {
      await TeleConsultationApiCalls.callStatusUpdate(
          widget.videoCallDetails.appointId, 'on_going');
    }
    loading = false;
    success = true;
    afterWidgetBuild(onComplete: () {
      Get.off(VideoCallJitsi(videoCallDetail: widget.videoCallDetails));
      //   Get.offNamedUntil(Routes.ConsultVideo, (Route route) => false, arguments: [
      //   widget.appointmentDetails[0],
      //   widget.appointmentDetails[1],
      //   widget.appointmentDetails[2],
      //   "appointmentCall",
      // ]);
    });
    setState(() {});
  }

  startTimerFor45Seconds() async {
    showMissedCallMessage = false;
    Duration duration = const Duration(seconds: 45 ?? 0);
    return Timer(duration, missedCallMessage);
  }

  missedCallMessage() {
    if (success == false && callDeclinedByDoctor == false) {
      showMissedCallMessage = true;
      Duration duration = const Duration(seconds: 5 ?? 0);
      setState(() {});
      return Timer(duration, () {
        Get.offAll(MyAppointmentsTabs(fromCall: true));
      });
    } else {
      log("Missed Call Message Muted here !");
    }
  }

  void callListner(DocumentSnapshot<dynamic> event, String userId) async {
    log(event.data().toString());
    dynamic mapData = event.data() as Map<String, dynamic>;
    String status = mapData['data']['cmd'];
    List<dynamic> receiverId = <dynamic>[];
    if (mapData.containsKey("receiver_id")) {
      // receiverId = mapData["receiver_id"];
      try {
        receiverId.addAll(mapData["receiver_id"]);
      } catch (e) {
        receiverId.add(mapData["receiver_id"]);
      }
      log("receiverId => ${receiverId.toList()}");
    }
    if (mapData.containsKey("sender_id")) {
      // receiverId = mapData["sender_id"];
      receiverId.add(mapData["sender_id"]);
    }
    if (mapData.containsKey("receiver_ids")) {
      // receiverId = mapData["receiver_ids"];
      try {
        receiverId.addAll(mapData["receiver_ids"]);
      } catch (e) {
        receiverId.add(mapData["receiver_ids"]);
      }
      log("receiverIds => ${receiverId.toList()}");
      // receiverId.add(mapData["receiver_ids"]);
    }
    for (String element in receiverId) {
      element.replaceAll("[", "").replaceAll("]", "");
    }
    log(receiverId.toList().toString());
    if (receiverId.contains(userId)) {
      if (status == 'CallAcceptedByDoctor') {
        log("Call Accepted By Doc ");
        // if (mounted)
        loading = false;
        success = true;
        afterWidgetBuild(
            onComplete: () => Get.off(VideoCallJitsi(videoCallDetail: widget.videoCallDetails)));
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   // Get.offNamedUntil(Routes.ConsultVideo, (route) => false, arguments: [
        //   //   widget.appointmentDetails[0].toString().replaceAll("ihl_consultant_", ""),
        //   //   widget.appointmentDetails[1],
        //   //   widget.appointmentDetails[2],
        //   //   "LiveCall",
        //   // ]);
        // });
      } else if (status == 'CallDeclinedByDoctor') {
        log("Call Declined By Doc ");
        loading = false;
        success = false;
        callDeclinedByDoctor = true;
        Future<void>.delayed(const Duration(seconds: 15), () {
          Get.offAll(MyAppointmentsTabs(fromCall: true));
        });
      }
      setState(() {});
    }
  }
}

class VideoCallDetail {
  VideoCallDetail({
    @required this.appointId,
    @required this.docId,
    @required this.userID,
    @required this.callType,
    @required this.ihlUserName,
  });

  String appointId;
  String docId;
  String userID;
  String callType;
  String ihlUserName;
}
