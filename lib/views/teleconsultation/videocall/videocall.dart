// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, missing_return, unnecessary_statements, non_constant_identifier_names
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../constants/api.dart';
import '../../../constants/routes.dart';
import '../../../utils/CrossbarUtil.dart' as s;
import '../../../utils/CrossbarUtil.dart';
import '../../../utils/ScUtil.dart';
import '../../consultationStages.dart';
import '../../screens.dart';
import '../mySubscriptions.dart';
import 'subscription_call_background.dart';
import '../../../widgets/BasicPageUI.dart';
import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Modules/online_class/presentation/pages/view_all_class.dart';
import '../../../new_design/presentation/pages/home/landingPage.dart';
import '../../../new_design/presentation/pages/onlineServices/MyAppointment.dart';
import '../MySubscription.dart';

var CallEndedByDoctor = false;

class VideoCall extends StatefulWidget {
  final List callDetails;

  const VideoCall({Key key, this.callDetails}) : super(key: key);

  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  final serverText = 'https://meet.indiahealthlink.com';
  var isAudioOnly = false;
  var isAudioMuted = false;
  var isVideoMuted = false;

  Session videoCallSession;
  Client videoCallSessionClient;
  var consultationAppointmentId;

  void connect() async {
    videoCallSessionClient = Client(
        realm: 'crossbardemo',
        transport: WebSocketTransport(
          API.crossbarUrl,
          Serializer(),
          WebSocketSerialization.SERIALIZATION_JSON,
        ));
  }

  void appointmentSubscribe() async {
    if (videoCallSession != null) {
      videoCallSession.close();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ihl_user_id = prefs.getString('ihlUserId');
    connect();
    videoCallSession = await videoCallSessionClient.connect().first;
    try {
      final subscription = await videoCallSession.subscribe('ihl_send_data_to_user_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) {
        Map<String, dynamic> data = event.arguments[0];
        var status = data['data']['cmd'];
        consultationAppointmentId = data['data']['vid'];
        List receiverId = data['receiver_id'] ?? data['receiver_ids'];
        // if (receiverId.contains(prefs.get("IHL_User_ID"))) {
        if (receiverId.contains(ihl_user_id)) {
          if (status == 'CallEndedByDoctor') {
            // Future.delayed(const Duration(seconds: 10), () {
            JitsiMeet.closeMeeting();
            //JitsiMeet.removeAllListeners();
            // });
            if (widget.callDetails[3] != 'SubscriptionCall') {
              if (iscallError == true && callErrorAppointmentId == consultationAppointmentId) {
                //callErrorDialog(widget.callDetails[3]);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  callErrorDialog(widget.callDetails[3]);
                  //Get.off(ReconnectingVideoCall(callDetails: widget.callDetails));
                });
              } else {
                //callStatusUpdate(widget.callDetails[0].toString(), 'completed');
                var saveappId = widget.callDetails[0].toString().replaceAll('ihl_consultant_', '');
                callStatusUpdate(saveappId, 'completed');
              }
            }

            CallEndedByDoctor = true;
            if (widget.callDetails[3] == 'SubscriptionCall') {
              calllog('user', widget.callDetails[1], 'end', widget.callDetails[4].toString(),
                  widget.callDetails[0].toString());
              Navigator.push(
                context,
                MaterialPageRoute<dynamic>(
                    builder: (BuildContext ctx) => ViweAllClass(
                      subscribed: true,
                      subcriptionList: [],
                    )),
              );
              //  WidgetsBinding.instance.addPostFrameCallback((_) {
              // Get.to(MySubscription(
              //   afterCall: true,
              //   courseId: widget.callDetails[0],
              // ));
              //   Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => MySubscriptions(
              //                 afterCall: true,
              //                 courseId: widget.callDetails[0],
              //               )),
              //       (Route<dynamic> route) => false);
              //});
            }
          }
        }
      });
      await subscription.onRevoke
          .then((String reason) => print('The server has killed my subscription due to: $reason'));
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  @override
  void initState() {
    super.initState();
    //JitsiMeet.closeMeeting();
    log(Get.currentRoute);
    CallEndedByDoctor = false;
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        // onPictureInPictureWillEnter: _onPictureInPictureWillEnter,
        // onPictureInPictureTerminated: _onPictureInPictureTerminated,
        onError: _onError));
    _joinMeeting();
    // appointmentSubscribe();
    currentPage = "jitsiMeet";
  }

  @override
  void dispose() {
    //videoCallSession?.close();
    log('Dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return SafeArea(top: true, child: Container(color: Colors.white));
  }

  _joinMeeting() async {
    try {
      Map<FeatureFlagEnum, bool> featureFlags = {
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
      if (widget.callDetails[3] != 'SubscriptionClassCall') {
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
      /*FeatureFlag featureFlag = FeatureFlag();
      featureFlag.resolution = FeatureFlagVideoResolution.LD_RESOLUTION;
      featureFlag.welcomePageEnabled = false;
      featureFlag.toolboxAlwaysVisible = true;
      featureFlag.inviteEnabled = false;
      featureFlag.addPeopleEnabled = false;
      featureFlag.calendarEnabled = false;
      featureFlag.chatEnabled = true;
      featureFlag.closeCaptionsEnabled = false;
      featureFlag.conferenceTimerEnabled = false;
      featureFlag.iOSRecordingEnabled = false;
      featureFlag.kickOutEnabled = false;
      featureFlag.liveStreamingEnabled = false;
      //   featureFlag.meetingNameEnabled = true;
      featureFlag.meetingPasswordEnabled = false;
      if (widget.callDetails[3] != 'SubscriptionCall') {
        featureFlag.pipEnabled = true;
      } else {
        featureFlag.pipEnabled = false;
      }
      featureFlag.raiseHandEnabled = false;
      featureFlag.recordingEnabled = false;
      //   featureFlag.tileViewEnabled = true;
      featureFlag.videoShareButtonEnabled = false;
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlag.callIntegrationEnabled = false;
      }*/

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var options = JitsiMeetingOptions(
          room: widget.callDetails[3] == 'SubscriptionCall'
              ? 'IHLTeleConsultClass' + widget.callDetails[0]
              : 'IHLTeleConsult' + widget.callDetails[0])
        ..serverURL = serverText
        ..subject =
            widget.callDetails[3] == 'SubscriptionCall' ? 'Online Class' : 'Tele Consultation'
        ..userDisplayName = prefs.getString('name') ?? 'User'
        ..userEmail = prefs.getString('email')
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..featureFlags.addAll(featureFlags);
      //..featureFlag = featureFlag;

      debugPrint("JitsiMeetingOptions: $options");

      if (widget.callDetails[3] != 'SubscriptionCall') {
        //background of the jitsi meet
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => ConsultStagesPage(
          //               appointmentId: widget.callDetails[0],
          //               callModel: widget.callDetails[3],
          //               userId: widget.callDetails[2],
          //               callDetails: widget.callDetails,
          //             )),
          //     (Route<dynamic> route) => false);
          Get.off(ConsultStagesPage(
            appointmentId: widget.callDetails[0],
            callModel: widget.callDetails[3],
            userId: widget.callDetails[2],
            callDetails: widget.callDetails,
          ));
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.to(SubscriptionCallBackground(
            callDetails: widget.callDetails,
          ));
          // Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => SubscriptionCallBackground(
          //               callDetails: widget.callDetails,
          //             )),
          //     (Route<dynamic> route) => false);
        });
      }
      Future.delayed(const Duration(seconds: 2), () async {
        await JitsiMeet.joinMeeting(
          options,
          listener: JitsiMeetingListener(
            onConferenceWillJoin: (message) {
              debugPrint("${options.room} will join with message: $message");
            },
            onConferenceJoined: (message) {
              debugPrint("${options.room} joined with message: $message");

              isCallTerminated = false;
              //resting the error values
              iscallError = false;
              isTimer90seconds = false;
            },
            onConferenceTerminated: (message) {
              debugPrint("${options.room} terminated with message: $message");
              isTimer90seconds = true;
              currentPage = "";
              isCallTerminated = true;
              if (message.keys.elementAt(0) == 'error') {
                //here wew ill assign the jitsi error actions
                //Ended by error
                isTimer90seconds = false;
                JitsiMeet.removeAllListeners();
                iscallError = true;
                callErrorAppointmentId = widget.callDetails[0];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  //callErrorDialog(widget.callDetails[3]);
                  Get.to(ReconnectingVideoCall(callDetails: widget.callDetails));
                });
              }
            },
            //onPictureInPictureWillEnter: ({message}) {
            //   debugPrint("${options.room} entered PIP mode with message: $message");
            // }, onPictureInPictureTerminated: ({message}) {
            //   debugPrint("${options.room} exited PIP mode with message: $message");
            // }
          ),
        );
      });
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
    if (widget.callDetails[3] == 'SubscriptionCall') {
      calllog('user', widget.callDetails[1], 'join', widget.callDetails[4].toString(),
          widget.callDetails[0].toString());
    } else {
      calllog('user', widget.callDetails[2], 'join', widget.callDetails[0].toString(), '');
    }
    CallConnectionState.callStatus.value = true;
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");

    if (message.keys.elementAt(0) == 'error') {
      //Ended by error
      iscallError = true;

      callErrorAppointmentId = widget.callDetails[0];
    } else {
      startTimer90Seconds(widget.callDetails[3]);
      List<String> receiverIds = [];
      receiverIds.add(widget.callDetails[1]);
      if (widget.callDetails[3] == 'LiveCall') {
        counterValueConsultaionStages.value = 180;
        counterUIConsultaionStages();
        s.appointmentPublish(
          'CallEndedByUser',
          "LiveAppointmentCall",
          receiverIds,
          widget.callDetails[2],
          widget.callDetails[0],
        );
        calllog('user', widget.callDetails[2], 'end', widget.callDetails[0].toString(), '');
      } else if (widget.callDetails[3] == 'appointmentCall') {
        counterValueConsultaionStages.value = 180;
        counterUIConsultaionStages();
        s.appointmentPublish(
          'CallEndedByUser',
          "BookAppointmentCall",
          receiverIds,
          widget.callDetails[2],
          widget.callDetails[0],
        );
        calllog('user', widget.callDetails[2], 'end', widget.callDetails[0].toString(), '');
      }
      if (CallEndedByDoctor == false) {
        if (widget.callDetails[3] == 'SubscriptionCall') {
          calllog('user', widget.callDetails[1], 'end', widget.callDetails[4].toString(),
              widget.callDetails[0].toString());
          Navigator.push(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext ctx) => ViweAllClass(
                  subscribed: true,
                  subcriptionList: [],
                )),
          );
          // Get.to(MySubscription(
          //   afterCall: true,
          //   courseId: widget.callDetails[0],
          // ));
          isTimer90seconds = false;
        } else {}
      }
    }
  }

  // void _onPictureInPictureWillEnter({message}) {
  //   debugPrint(
  //       "_onPictureInPictureWillEnter broadcasted with message: $message");
  // }

  // void _onPictureInPictureTerminated({message}) {
  //   debugPrint(
  //       "_onPictureInPictureTerminated broadcasted with message: $message");
  // }

  void _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}

//Timer to direct from consultationstages to myappointments when there is no action from consultant side for 90 secs
void startTimer90Seconds(var callDetail) {
  var timer90Seconds = Timer.periodic(
    const Duration(seconds: 90),
    (Timer timer90sec) {
      if (isTimer90seconds == true && currentPage != "NoInternetPage") {
        isTimer90seconds = false;
        timer90sec.cancel();

        istimerConsultationStagesSession = false;
        if (callDetail != 'SubscriptionCall') {
          timer90sec.cancel();
          Get.offAll(MyAppointment(
            backNav: false,
          ));
        } else {
          Get.to(LandingPage());
          // Get.offAll(MySubscription(afterCall: false));
        }
      } else {
        timer90sec.cancel();
      }
    },
  );
}

//Only to update call status completed when cros bar recieves callEndedBy Doctor
currentAppointmentStatusUpdate(String appointmentID, String appStatus) async {
  var appointmentApikey =
      'IWkzkviYuwJqJ2S/F858AdtNyyP3iIDEwJVW4lnn4itl9MOJ9rgTGN2uCRr2ymWQ4qC8ufGtabVjJxZr1o+t1ji4Qk7kFnO4HLtabbdPPFsBAA==';
  var appointmentApiToken =
      'GKsshZNXO3CzNge63IrpY0W8YNBUMzpbYlvxZ3whkPEUKbk4Oy3KewiOmD3ehOjOi/4hvCSVy8Yuhr31pG76R28OA5j3/Sh6W7JymgFvNN63wY9NaTsFYi2yYtTvelpbxEmIV27w51tT97kizP0C1Ey76NK6BKZy+y7DML12Qv4o1/DqpHx5iqVlXsAcCg50AQA=';
  http.Client _client = http.Client(); //3gb
  final response = await _client.get(
    Uri.parse('${API.iHLUrl}/consult/update_appointment_status?appointment_id=$appointmentID&appointment_status=$appStatus'),
    headers: {
      'Content-Type': 'application/json',
      'ApiToken': '${API.headerr['ApiToken']}',
      'Token': '${API.headerr['Token']}',
    },
    // headers: {'ApiToken': appointmentApikey, 'Token': appointmentApiToken},
  );
  if (response.statusCode == 200) {
    var parsedString = response.body.replaceAll('&quot', '"');
    var parsedString1 = parsedString.replaceAll(";", "");
    var parsedString2 = parsedString1.replaceAll('"{', '{');
    var parsedString3 = parsedString2.replaceAll('}"', '}');
    var currentAppointmentStatusUpdate = json.decode(parsedString3);
    if (currentAppointmentStatusUpdate == 'Database Updated') {
      if (appStatus == "Completed" || appStatus == "completed") {
        print('Appointment status updating sucessfull');
        //Get.offAll(MyAppointments());
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var data = prefs.get('data');
        Map res = jsonDecode(data);
        var userId = res['User']['id'];
        calllog('user', userId, 'end', appointmentID, '');
      }
    }
  } else {
    print('Appointment status updating failed');
  }
}

callStatusUpdate(String appointmentID, String appStatus) async {
  http.Client _client = http.Client(); //3gb
  final response = await _client.get(
    Uri.parse('${API.iHLUrl}/consult/update_call_status?appointment_id=$appointmentID&call_status=$appStatus'),
    headers: {
      'Content-Type': 'application/json',
      'ApiToken': '${API.headerr['ApiToken']}',
      'Token': '${API.headerr['Token']}',
    },
  );
  if (response.statusCode == 200) {
    var parsedString = response.body.replaceAll('&quot', '"');
    var parsedString1 = parsedString.replaceAll(";", "");
    var parsedString2 = parsedString1.replaceAll('"{', '{');
    var parsedString3 = parsedString2.replaceAll('}"', '}');
    var callStatusUpdate = json.decode(parsedString3);
    String apiResponse = callStatusUpdate['status'].toString();
    if (apiResponse == 'Update Sucessfull') {
      if (appStatus == "completed" || appStatus == "Completed") {
        currentAppointmentStatusUpdate(appointmentID, 'Completed');
      }
    } else {
      print("Call status is update is failed");
    }
  }
}

class ReconnectingVideoCall extends StatefulWidget {
  final List callDetails;

  ReconnectingVideoCall({Key key, this.callDetails}) : super(key: key);

  @override
  _ReconnectingVideoCallState createState() => _ReconnectingVideoCallState();
}

class _ReconnectingVideoCallState extends State<ReconnectingVideoCall> {
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
    isTimer90seconds = false;
    super.initState();
    isTimer90secondsreconnecting = true;
    istimer3sec = true;

    startTimer90SecondsReconnecting(widget.callDetails[3]);
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
    return WillPopScope(
      onWillPop: () {},
      child: BasicPageUI(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text('Telecom Support'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            child: Container(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Trying to reconnect',
                    style: TextStyle(color: Colors.grey[600], fontSize: 20),
                  ),
                  Lottie.asset('assets/reconnecting.json', height: 300, width: 350),
                  Text(
                    "You will be redirected automatically in ${counterValue.toString()} minutes.",
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.5,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 13.0, bottom: 13.0, right: 15, left: 15),
                      child: Text(
                        'RETRY',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                    onPressed: () async {
                      var connectivityResult = await Connectivity().checkConnectivity();
                      bool result = await DataConnectionChecker().hasConnection;
                      if ((connectivityResult != ConnectivityResult.mobile ||
                              connectivityResult != ConnectivityResult.wifi) &&
                          result != true) {
                        Flushbar(
                          title: "Offline",
                          message: "No Internet",
                          duration: const Duration(seconds: 3),
                          backgroundColor: Colors.red,
                          backgroundGradient: const LinearGradient(colors: [Colors.red, Colors.grey]),
                        )..show(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void counterUI() {
    if (_timerUI90 != null) {
      _timerUI90.cancel();
      _timerUI90 = null;
    } else {
      _timerUI90 = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (this.mounted) {
          setState(
            () {
              if (counterValue < 1) {
                timer.cancel();
              } else {
                counterValue = counterValue - 1;
              }
            },
          );
        }
      });
    }
  }

  check() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool result = await DataConnectionChecker().hasConnection;
    if ((connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) &&
        result == true) {
      if (this.mounted) {
        setState(() {
          isTimer90secondsreconnecting = false;
          istimer3sec = false;
          isChecking = false;
          hasInternet = true;
        });
        if (widget.callDetails[3] != "SubscriptionCall") {
          Get.offNamedUntil(Routes.ConsultVideo, (route) => false, arguments: [
            widget.callDetails[0],
            widget.callDetails[1],
            widget.callDetails[2],
            widget.callDetails[3],
          ]);
        } else {
          Get.offNamedUntil(Routes.ConsultVideo, (route) => false, arguments: [
            widget.callDetails[0],
            widget.callDetails[1],
            widget.callDetails[2],
            widget.callDetails[3],
            widget.callDetails[4],
          ]);
        }
      } else {
        isTimer90secondsreconnecting = false;
        istimer3sec = false;
      }
    } else {
      if (this.mounted) {
        setState(() {
          isChecking = false;
          hasInternet = false;
        });
      } else {
        isTimer90secondsreconnecting = false;
        istimer3sec = false;
      }
    }
  }

  void start3secTimer() {
    var _timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer3sec) {
        if (istimer3sec == true) {
          check();
        } else {
          timer3sec.cancel();
        }
      },
    );
  }

  void startTimer90SecondsReconnecting(var callDetail) {
    var _timer = Timer.periodic(
      const Duration(seconds: 90),
      (Timer timer90secreconnecting) {
        if (isTimer90secondsreconnecting == true) {
          isTimer90secondsreconnecting = false;
          timer90secreconnecting.cancel();
          if (callDetail != 'SubscriptionCall') {
            timer90secreconnecting.cancel();
            Get.offAll(MyAppointment(
              backNav: false,
            ));
          } else {
            timer90secreconnecting.cancel();
            Get.to(LandingPage());
            // Get.offAll(MySubscription(afterCall: false));
          }
        } else {
          timer90secreconnecting.cancel();
        }
      },
    );
  }
}
