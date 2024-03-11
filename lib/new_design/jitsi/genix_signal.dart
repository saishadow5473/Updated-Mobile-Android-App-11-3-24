// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../app/utils/appText.dart';
import 'package:lottie/lottie.dart';
import 'package:web_socket_channel/io.dart';

import '../../Modules/online_class/bloc/online_class_api_bloc.dart';
import '../../Modules/online_class/bloc/online_class_events.dart';
import '../../Modules/online_class/bloc/trainer_status/bloc/trainer_bloc.dart';
import '../app/utils/appColors.dart';
import '../data/providers/network/api_provider.dart';
import '../module/online_serivices/bloc/online_services_api_bloc.dart';
import '../module/online_serivices/bloc/online_services_api_event.dart';
import '../module/online_serivices/bloc/search_animation_bloc/search_animation_bloc.dart';
import '../module/online_serivices/onilne_services_main.dart';
import '../presentation/Widgets/bloc_widgets/consultant_status/consultantstatus_bloc.dart';
import '../presentation/clippath/background_painter.dart';
import 'package:web_socket_channel/status.dart';

import '../presentation/controllers/dashboardControllers/dashBoardContollers.dart';
import '../presentation/controllers/teleconsultation_onlineServices/teleconsultation_apiCalls.dart';
import '../presentation/pages/onlineServices/myAppointmentsTabs.dart';
import '../presentation/pages/onlineServices/onlineServicesTabs.dart';
import 'genix_web_view_call.dart';

class GenixSignal extends StatefulWidget {
  const GenixSignal({Key key, @required this.genixCallDetails}) : super(key: key);
  final GenixCallDetails genixCallDetails;

  @override
  State<GenixSignal> createState() => _GenixSignalState();
}

class _GenixSignalState extends State<GenixSignal> {
  bool declineCall = false;
  bool isLoading = false;
  bool acceptCall = false;
  bool callWaiting = true;
  bool doctorNotAvailable = false;
  bool joinedCall = true;
  InAppWebViewController webViewController;
  StreamSubscription<dynamic> stream;
  Timer timer;
  int start = 60;
  String genixURL =
      '${API.updatedIHLurl}/signalr/index.html?vendor_consultant_id=f845dfd5-2225-4ad9-a8b4-1fb2265849de&vendor_appointment_id=2d5ae469-32a3-4984-86e4-3da3fe8a138b&vendor_user_name=hassan';
  final ChromeSafariBrowser browser = IHLChromeSafariBrowser();
  @override
  void initState() {
    genixURL =
        '${API.updatedIHLurl}/signalr/index.html?vendor_consultant_id=${widget.genixCallDetails.vendorConsultantId}&vendor_appointment_id=${widget.genixCallDetails.vendorAppointmentId}&vendor_user_name=${widget.genixCallDetails.vendorUserName}';
    isLoading = true;
    if (Platform.isIOS) {
      String attributes = jsonEncode(<String, dynamic>{
        'iHLUserId_': widget.genixCallDetails.ihlUserId,
        'specality_': widget.genixCallDetails.specality,
        'vendor_consultant_id_': widget.genixCallDetails.specality,
        'genixAppointId_': widget.genixCallDetails.genixAppointId,
        'url_': "",
        'vendorConsultantId': widget.genixCallDetails.vendorConsultantId,
        'vendorAppointmentId_': widget.genixCallDetails.vendorAppointmentId,
        'vendorUserName_': widget.genixCallDetails.vendorUserName
      });
      log("URL Generated $genixURL");
      debugPrint(attributes);
      iosWebview();
    }
    subscribeLiveCallFireStore();
    timeOut();
    super.initState();
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  subscribeLiveCallFireStore() {
    log("Genix fireStore listener triggered");
    try {
      stream = FireStoreCollections.teleconsultationServices
          .doc(widget.genixCallDetails.genixAppointId)
          .snapshots()
          .listen((DocumentSnapshot<dynamic> event) async {
        Map<String, dynamic> data = event.data() as Map<String, dynamic>;
        String docStatus;
        if (data == null) {
          docStatus = "";
        } else {
          log(data.toString());
          docStatus = data['data']['cmd'];
        }

        if (docStatus == 'CallDeclinedByDoctor') {
          TeleConsultationApiCalls.cancelAppointment(
              by: 'doctor',
              appointmentId: widget.genixCallDetails.genixAppointId,
              reason: 'Rejected');
          if (Platform.isIOS) {
            browser.close();
          }
          if (mounted) declineCall = true;
          callWaiting = false;
          setState(() {});
          timer.cancel();
        } else if (docStatus == 'CallAcceptedByDoctor') {
          if (Platform.isIOS) {
            browser.close();
          }
          if (mounted) acceptCall = true;
          callWaiting = false;
          setState(() {});
          if (joinedCall) {
            joinedCall = false;
            timer?.cancel();
            Get.to(GenixWebViewCall(genixCallDetails: widget.genixCallDetails));
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
      if (Platform.isIOS) {
        browser.close();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          if (declineCall) {
            Get.offAll(MultiBlocProvider(providers: <BlocProvider<dynamic>>[
              BlocProvider<SubscrptionFilterBloc>(
                create: (BuildContext context) => SubscrptionFilterBloc()
                  ..add(FilterSubscriptionEvent(filterType: "Accepted", endIndex: 30)),
              ),
              BlocProvider<SearchAnimationBloc>(
                  create: (BuildContext context) => SearchAnimationBloc()),
              BlocProvider<ConsultantstatusBloc>(
                  create: (BuildContext context) => ConsultantstatusBloc()),
              BlocProvider<TrainerBloc>(create: (BuildContext context) => TrainerBloc()),
              BlocProvider<OnlineServicesApiBloc>(
                  create: (BuildContext context) => OnlineServicesApiBloc()
                    ..add(OnlineServicesApiEvent<dynamic>(data: "specialty"))),
              BlocProvider<StreamOnlineServicesApiBloc>(
                  create: (BuildContext context) => StreamOnlineServicesApiBloc()
                    ..add(StreamOnlineServicesApiEvent<dynamic>(data: "subscriptionDetails"))),
              BlocProvider<StreamOnlineClassApiBloc>(
                  create: (BuildContext context) => StreamOnlineClassApiBloc()
                    ..add(StreamOnlineClassApiEvent<dynamic>(data: "subscriptionDetails")))
            ], child: const OnlineServicesDashboard()));
          } else {
            _onBackPressed();
          }
        },
        child: SafeArea(
          child: Scaffold(
            body: Container(
              color: AppColors.bgColorTab,
              child: Column(
                children: <Widget>[
                  CustomPaint(
                    painter: BackgroundPainter(
                      primary: declineCall ? Colors.red : AppColors.bookApp.withOpacity(0.7),
                      secondary: declineCall ? Colors.red : AppColors.bookApp.withOpacity(0.0),
                    ),
                    child: Container(),
                  ),
                  SizedBox(
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: const Text(
                        "Live Call",
                        style: TextStyle(color: Colors.white),
                      ),
                      centerTitle: true,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: isLoading == false
                              ? SizedBox(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: const <Widget>[
                                        CircularProgressIndicator(),
                                        Text("Loading video call")
                                      ],
                                    ),
                                  ),
                                )
                              : (Platform.isIOS)
                                  ? SizedBox(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: const <Widget>[
                                            CircularProgressIndicator(),
                                            SizedBox(height: 8),
                                            Text("Please wait while the Consultant Joins...",
                                                style: TextStyle(
                                                    fontSize: 20, fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center),
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      child: Center(
                                      child: Column(children: <Widget>[
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        lottie(),
                                        text(),
                                        SizedBox(
                                          height: 10,
                                          width: 10,
                                          child: InAppWebView(
                                              initialUrlRequest: URLRequest(
                                                  url: Uri.parse(genixURL ?? 'www.google.com')),
                                              initialOptions: InAppWebViewGroupOptions(
                                                crossPlatform: InAppWebViewOptions(
                                                  mediaPlaybackRequiresUserGesture: false,
                                                ),
                                              ),
                                              onWebViewCreated:
                                                  (InAppWebViewController controller) {
                                                webViewController = controller;
                                              },
                                              androidOnPermissionRequest:
                                                  (InAppWebViewController controller, String origin,
                                                      List<String> resources) async {
                                                return PermissionRequestResponse(
                                                    resources: resources,
                                                    action: PermissionRequestResponseAction.GRANT);
                                              }),
                                        ),
                                      ]),
                                    )),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  timeOut() {
    const Duration oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (start == 0) {
          if (mounted) timer.cancel();
          doctorNotAvailable = true;
          declineCall = false;
          acceptCall = false;
          callWaiting = false;
          setState(() {});
          TeleConsultationApiCalls.callStatusUpdate(
                  widget.genixCallDetails.genixAppointId, "Missed")
              .then((dynamic value) {
            Get.off(MyAppointmentsTabs(fromCall: true));
          });
        } else {
          if (start == 30) {
            if (Platform.isIOS) {
              browser.close();
            }
          }
          start--;
          debugPrint(start.toString());
        }
      },
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: <Widget>[
                const Text(
                  'Info !\n',
                  style: TextStyle(color: AppColors.primaryColor),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Please wait while the Consultant Joins...',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text(
                      'Okay',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  lottie() {
    if (declineCall) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: Lottie.network(API.declinedLottieFileUrl, height: 280, width: 280),
      );
    } else if (acceptCall) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: Lottie.network(API.callAcceptedLottieFileUrl, height: 280, width: 280),
      );
    } else if (callWaiting) {
      return Lottie.network('https://assets5.lottiefiles.com/packages/lf20_e5fibvuv.json',
          height: 400, width: 400);
    } else if (doctorNotAvailable) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: Lottie.network(API.declinedLottieFileUrl, height: 300, width: 300),
      );
    } else {
      return Lottie.network(API.declinedLottieFileUrl, height: 200, width: 200);
    }
  }

  text() {
    if (declineCall) {
      return const Text(
        'Sorry, Consultant declined your call.\nInitiating your refund. Please wait...!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Colors.red,
        ),
      );
    } else if (callWaiting) {
      return const Text(
        'Please wait while the Consultant Joins...',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      );
    } else if (acceptCall) {
      return const Text(
        'Please wait while the Consultant Joins...',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      );
    } else if (doctorNotAvailable) {
      return const Text(
        'Doctor is Busy\nPlease try again',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      );
    } else {
      return const Text(
        'Something went wrong...',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      );
    }
  }

  void iosWebview() async {
    log("IOS Web view triggered with genix url");
    try {
      await browser.open(
          url: Uri.parse(genixURL),
          options: ChromeSafariBrowserClassOptions(
              ios: IOSSafariOptions(
                  barCollapsingEnabled: true,
                  presentationStyle: IOSUIModalPresentationStyle.FULL_SCREEN)));
    } catch (e) {
      log("IOS Web view triggered with genix url");
      log("Genix issue created $e");
    }
  }
}

class IHLChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    debugPrint("Custom Tab opened");
  }

  @override
  void onCompletedInitialLoad() {
    debugPrint("Tab load completed");
  }

  @override
  void onClosed() {
    debugPrint("Custom Tab closed");
  }
}

class GenixCallDetails {
  String ihlUserId;
  final String specality;
  final String vendorConsultantId;
  final String genixAppointId;
  final String vendorAppointmentId;
  final String vendorUserName;
  GenixCallDetails(
      {this.ihlUserId,
      this.genixAppointId,
      this.specality,
      this.vendorConsultantId,
      this.vendorAppointmentId,
      this.vendorUserName});
}
