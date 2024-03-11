import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/providers/network/api_provider.dart';
import '../firebase_utils/firebase_utils.dart';
import '../presentation/controllers/teleconsultation_onlineServices/teleconsultation_apiCalls.dart';
import '../presentation/pages/onlineServices/consultationStagesVideoCall.dart';
import '../presentation/pages/onlineServices/myAppointmentsTabs.dart';
import '../presentation/pages/teleconsultation/wait_for_consultant_screen.dart';

class VideoCallJitsi extends StatefulWidget {
  const VideoCallJitsi({Key key, @required this.videoCallDetail}) : super(key: key);
  final VideoCallDetail videoCallDetail;

  @override
  State<VideoCallJitsi> createState() => _VideoCallJitsiState();
}

class _VideoCallJitsiState extends State<VideoCallJitsi> {
  bool callEndedByDoctor = false;
  bool iscallError = false;
  StreamSubscription<dynamic> stream;

  @override
  void initState() {
    super.initState();
    StagesVariables.appointmentId = widget.videoCallDetail.appointId;
    callEndedByDoctor = false;
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
    _joinMeeting();
    appointmentStream();
    StagesVariables.currentPage = "jitsiMeet";
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(top: true, child: Container(color: Colors.white));
  }

  void afterWidgetBuild({VoidCallback onComplete}) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => onComplete());

  final String serverText = 'https://meet.indiahealthlink.com';
  bool isAudioOnly = false;
  bool isAudioMuted = false;
  bool isVideoMuted = false;
  _joinMeeting() async {
    try {
      Map<FeatureFlagEnum, bool> featureFlags = <FeatureFlagEnum, bool>{
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        FeatureFlagEnum.INVITE_ENABLED: false,
        FeatureFlagEnum.RAISE_HAND_ENABLED: false,
        FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE: true,
        FeatureFlagEnum.MEETING_PASSWORD_ENABLED: false,
        FeatureFlagEnum.LIVE_STREAMING_ENABLED: false,
        FeatureFlagEnum.CALL_INTEGRATION_ENABLED: true,
        FeatureFlagEnum.CLOSE_CAPTIONS_ENABLED: false,
        FeatureFlagEnum.RECORDING_ENABLED: false,
        FeatureFlagEnum.IOS_RECORDING_ENABLED: false,
        FeatureFlagEnum.CALENDAR_ENABLED: false,
        FeatureFlagEnum.ADD_PEOPLE_ENABLED: false,
      };
      if (widget.videoCallDetail.callType != 'SubscriptionClassCall') {
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = true;
      } else {
        if (Platform.isIOS) {
          featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
        }
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }
      if (Platform.isAndroid) {
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      JitsiMeetingOptions options = JitsiMeetingOptions(
          room: widget.videoCallDetail.callType == 'SubscriptionCall'
              ? 'IHLTeleConsultClass${widget.videoCallDetail.appointId}'
              : 'IHLTeleConsult${widget.videoCallDetail.appointId}')
        ..serverURL = serverText
        ..subject = widget.videoCallDetail.callType == 'SubscriptionCall'
            ? 'Online Class'
            : 'Tele Consultation'
        ..userDisplayName = prefs.getString('name') ?? 'User'
        ..userEmail = prefs.getString('email')
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..featureFlags.addAll(featureFlags);

      debugPrint("JitsiMeetingOptions: ${options.toString()}");

      if (widget.videoCallDetail.callType != 'SubscriptionCall') {
        //mentioning the background Screen for Jitsi Meet⚪⚪
        afterWidgetBuild(
            onComplete: () =>
                Get.off(ConsultationStagesVideoCall(videocallDetail: widget.videoCallDetail)));
      } else {
        afterWidgetBuild(
            onComplete: () => log("Subscription call Stages Navigation Part Triggered "));
        // Get.to(SubscriptionCallBackground(
        //   callDetails: widget.callDetails,
        // ));
      }
      Future<void>.delayed(const Duration(seconds: 2), () async {
        await JitsiMeet.joinMeeting(
          options,
          listener: JitsiMeetingListener(
            onConferenceWillJoin: (dynamic message) {
              debugPrint("${options.room} will join with message: $message");
            },
            onConferenceJoined: (dynamic message) {
              debugPrint("${options.room} joined with message: $message");

              StagesVariables.isCallTerminated = false;
              //resting the error values
              StagesVariables.iscallError = false;
              StagesVariables.isTimer90seconds = false;
            },
            onConferenceTerminated: (dynamic message) {
              debugPrint("${options.room} terminated with message: $message");
              StagesVariables.isTimer90seconds = true;
              StagesVariables.currentPage = "";
              StagesVariables.isCallTerminated = true;
              if (message.keys.elementAt(0) == 'error') {
                //here we are  assigning the jitsi error actions⚪
                //while the jitsi call Ended by error
                StagesVariables.isTimer90seconds = false;
                JitsiMeet.removeAllListeners();
                StagesVariables.iscallError = true;
                StagesVariables.callErrorAppointmentId = widget.videoCallDetail.appointId;
                afterWidgetBuild(onComplete: () {
                  StagesVariables.callErrorDialog(widget.videoCallDetail.callType);
                  Get.to(ReconnectingJitsiVideoCall(videoCallDetail: widget.videoCallDetail));
                });
              }
            },
          ),
        );
      });
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  void _onError(dynamic error) {
    debugPrint("_onError broadcasted: $error");
  }

  void _onConferenceWillJoin(dynamic message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(dynamic message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
    //the below slashed code for clarifications 😁😁😁
    // calllog('user', widget.callDetails[1], 'join', widget.callDetails[4].toString(),
    //   widget.callDetails[0].toString());
    if (widget.videoCallDetail.callType == 'SubscriptionCall') {
      TeleConsultationApiCalls.calllog(
          by: 'user',
          userid: widget.videoCallDetail.docId,
          action: 'join',
          refrence: widget.videoCallDetail.callType,
          courseid: widget.videoCallDetail.appointId);
    } else {
      TeleConsultationApiCalls.calllog(
          by: 'user',
          userid: widget.videoCallDetail.userID,
          action: 'join',
          refrence: widget.videoCallDetail.appointId,
          courseid: '');
    }
    // CallConnectionState.callStatus.value = true; 😁😁 need to implement
  }

  void _onConferenceTerminated(dynamic message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");

    if (message.keys.elementAt(0) == 'error') {
      //Ended by error
      // iscallError = true;

      StagesVariables.callErrorAppointmentId = widget.videoCallDetail.appointId;
    } else {
      StagesVariables.startTimer90Seconds(callType: widget.videoCallDetail.callType);
      print("Timer called in consultation pages screen");
      List<String> receiverIds = <String>[];
      receiverIds.add(widget.videoCallDetail.docId);
      if (widget.videoCallDetail.callType == 'LiveCall') {
        StagesVariables.counterValueConsultaionStages.value = 180;
        StagesVariables.counterUIConsultationStages();
        appointmentPublish(
          'CallEndedByUser',
          "LiveAppointmentCall",
          receiverIds,
          widget.videoCallDetail.userID,
          widget.videoCallDetail.appointId,
        );
        TeleConsultationApiCalls.calllog(
            by: 'user',
            userid: widget.videoCallDetail.userID,
            action: 'end',
            refrence: widget.videoCallDetail.appointId.toString(),
            courseid: '');
      } else if (widget.videoCallDetail.callType == 'appointmentCall') {
        StagesVariables.counterValueConsultaionStages.value = 180;
        StagesVariables.counterUIConsultationStages();
        appointmentPublish(
          'CallEndedByUser',
          "BookAppointmentCall",
          receiverIds,
          widget.videoCallDetail.userID,
          widget.videoCallDetail.appointId,
        );
        TeleConsultationApiCalls.calllog(
            by: 'user',
            userid: widget.videoCallDetail.userID,
            action: 'end',
            refrence: widget.videoCallDetail.appointId.toString(),
            courseid: '');
      }
      if (callEndedByDoctor == false) {
        if (widget.videoCallDetail.callType == 'SubscriptionCall') {
          TeleConsultationApiCalls.calllog(
              by: 'user',
              userid: widget.videoCallDetail.docId,
              action: 'end',
              refrence: widget.videoCallDetail.ihlUserName.toString(),
              courseid: widget.videoCallDetail.appointId.toString());
          // Get.to(MySubscription(
          //   afterCall: true,
          //   courseId: widget.videoCallDetail.appointId,
          // ));
          StagesVariables.isTimer90seconds = false;
        } else {}
      }
    }
  }

  void appointmentStream() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ihlUserId = prefs.getString('ihlUserId');
    try {
      log("${widget.videoCallDetail.appointId}Consultation Page Appointment ID ");
      stream = FireStoreCollections.teleconsultationServices
          .doc(widget.videoCallDetail.appointId)
          .snapshots()
          .listen((DocumentSnapshot<dynamic> event) async {
        Map<String, dynamic> data = event.data() as Map<String, dynamic>;
        String status = data['data']['cmd'] ?? "";
        List<dynamic> receiverId = <dynamic>[];
        if (data['receiver_id'] != null) {
          if (data['receiver_id'] is String) {
            receiverId = <dynamic>[data['receiver_id']];
          } else if (data['receiver_id'] is List) {
            receiverId = data['receiver_id'];
          }
        } else {
          if (data['receiver_ids'] is String) {
            receiverId = <dynamic>[data['receiver_ids']];
          } else if (data['receiver_ids'] is List) {
            receiverId = data['receiver_ids'];
          }
        }
        if (data.containsKey("receiver_id")) {
          try {
            receiverId.addAll(data["receiver_id"]);
          } catch (e) {
            receiverId.add(data["receiver_id"]);
          }
        }
        if (data.containsKey("sender_id")) {
          receiverId.add(data["sender_id"]);
        }
        if (data.containsKey("receiver_ids")) {
          receiverId.add(data["receiver_ids"]);
          // try {
          //   receiverId.addAll(data["receiver_ids"]);
          // } catch (e) {
          //   receiverId.add(data["receiver_ids"]);
          // }
        }
        for (dynamic element in receiverId) {
          element.toString().replaceAll("[", "").replaceAll("]", "");
        }
        if (receiverId.contains(ihlUserId)) {
          log("cmd from jitsi screen $status");
          if (status == 'CallEndedByDoctor') {
            JitsiMeet.closeMeeting();
            if (widget.videoCallDetail.callType != 'SubscriptionCall') {
              if (iscallError == true &&
                  StagesVariables.callErrorAppointmentId == widget.videoCallDetail.appointId) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  StagesVariables.callErrorDialog(widget.videoCallDetail.callType);
                });
              } else {
                String apiResponse = await TeleConsultationApiCalls.callStatusUpdate(
                    widget.videoCallDetail.appointId, 'completed');
                if (apiResponse == 'Update Sucessfull') {
                  String appoinStatus =
                      await TeleConsultationApiCalls.currentAppointmentStatusUpdate(
                          widget.videoCallDetail.appointId, 'Completed');
                  if (appoinStatus == 'Database Updated') {
                    TeleConsultationApiCalls.calllog(
                        by: 'user',
                        userid: widget.videoCallDetail.userID,
                        action: 'end',
                        refrence: widget.videoCallDetail.appointId,
                        courseid: '');
                  }
                }
              }
            }
          }

          callEndedByDoctor = true;
          if (widget.videoCallDetail.callType == 'SubscriptionCall') {
            // calllog('user', widget.callDetails[1], 'end', widget.callDetails[4].toString(),
            //     widget.callDetails[0].toString());
            //  WidgetsBinding.instance.addPostFrameCallback((_) {
            // Get.to(MySubscription(
            //   afterCall: true,
            //   courseId: widget.callDetails[0],
            // ));
          }
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }
}

class ReconnectingJitsiVideoCall extends StatefulWidget {
  const ReconnectingJitsiVideoCall({Key key, @required this.videoCallDetail}) : super(key: key);
  final VideoCallDetail videoCallDetail;

  @override
  State<ReconnectingJitsiVideoCall> createState() => _ReconnectingJitsiVideoCallState();
}

class _ReconnectingJitsiVideoCallState extends State<ReconnectingJitsiVideoCall> {
  bool isChecking = false;
  bool hasInternet = false;
  bool isTimer90secondsreconnecting = false;
  bool istimer3sec = false;
  Timer timer3sec;
  Timer timer90secreconnecting;
  Timer _timerUI90;
  int counterValue = 90;

  @override
  void initState() {
    StagesVariables.isTimer90seconds = false;
    super.initState();
    isTimer90secondsreconnecting = true;
    istimer3sec = true;

    startTimer90SecondsReconnecting(widget.videoCallDetail.callType);
    start3secTimer();
    counterUI();
  }

  @override
  void dispose() {
    timer3sec?.cancel();
    timer90secreconnecting?.cancel();
    _timerUI90?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void start3secTimer() {
    Timer.periodic(
      const Duration(seconds: 5),
      (Timer timer3sec) {
        if (istimer3sec == true) {
          check();
        } else {
          timer3sec.cancel();
        }
      },
    );
  }

  void startTimer90SecondsReconnecting(String callDetail) {
    Timer.periodic(
      const Duration(seconds: 90),
      (Timer timer90secreconnecting) {
        if (isTimer90secondsreconnecting == true) {
          isTimer90secondsreconnecting = false;
          timer90secreconnecting.cancel();
          if (callDetail != 'SubscriptionCall') {
            timer90secreconnecting.cancel();
            Get.offAll(MyAppointmentsTabs(fromCall: true));
          } else {
            timer90secreconnecting.cancel();

            // Get.offAll(MySubscription(afterCall: false));
          }
        } else {
          timer90secreconnecting.cancel();
        }
      },
    );
  }

  check() async {
    ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
    bool result = await DataConnectionChecker().hasConnection;
    if ((connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) &&
        result == true) {
      if (mounted) {
        setState(() {
          isTimer90secondsreconnecting = false;
          istimer3sec = false;
          isChecking = false;
          hasInternet = true;
        });
        if (widget.videoCallDetail.callType != "SubscriptionCall") {
          Get.offAll(VideoCallJitsi(videoCallDetail: widget.videoCallDetail));
        } else {
          // Get.offNamedUntil(Routes.ConsultVideo, (route) => false, arguments: [
          //   widget.callDetails[0],
          //   widget.callDetails[1],
          //   widget.callDetails[2],
          //   widget.callDetails[3],
          //   widget.callDetails[4],
          // ]);
        }
      } else {
        isTimer90secondsreconnecting = false;
        istimer3sec = false;
      }
    } else {
      if (mounted) {
        setState(() {
          isChecking = false;
          hasInternet = false;
          StagesVariables.currentPage = "NoInternetPage";
        });
      } else {
        isTimer90secondsreconnecting = false;
        istimer3sec = false;
      }
    }
  }

  void counterUI() {
    if (_timerUI90 != null) {
      _timerUI90.cancel();
      _timerUI90 = null;
    } else {
      _timerUI90 = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (counterValue < 1) {
          timer.cancel();
        } else {
          counterValue = counterValue - 1;
        }
        if (mounted) {
          setState(() {});
        }
      });
    }
  }
}
