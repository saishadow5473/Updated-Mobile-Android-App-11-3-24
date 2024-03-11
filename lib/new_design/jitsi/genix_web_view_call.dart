import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/api.dart';
import '../app/utils/appColors.dart';
import '../presentation/controllers/teleconsultation_onlineServices/teleconsultation_apiCalls.dart';
import '../presentation/pages/home/landingPage.dart';
import '../presentation/pages/onlineServices/consultationSummary.dart';
import 'genix_signal.dart';

class GenixVariables {
  static String currentPage;
}

class GenixWebViewCall extends StatefulWidget {
  GenixWebViewCall({Key key, @required this.genixCallDetails}) : super(key: key);
  final GenixCallDetails genixCallDetails;
  final ChromeSafariBrowser browser = IHLChromeSafariBrowser();

  @override
  State<GenixWebViewCall> createState() => _GenixWebViewCallState();
}

class _GenixWebViewCallState extends State<GenixWebViewCall> {
  StreamSubscription<dynamic> stream;
  bool isLoading = false;
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  String genixUrl;

  @override
  void initState() {
    asyncFunction();
    GenixVariables.currentPage = "GenixCall";
    super.initState();
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  asyncFunction() async {
    genixUrl = await TeleConsultationApiCalls.generateURl(widget.genixCallDetails.genixAppointId);
    if (genixUrl != "failed" && Platform.isIOS) iosOpenWebview();
    genixFireStorelistener();
    TeleConsultationApiCalls.callStatusUpdate(widget.genixCallDetails.genixAppointId, "on_going");
    if (genixUrl != "failed") {
      isLoading = true;
      _isLoading.value = true;
      _isLoading.notifyListeners();
    }
  }

  void iosOpenWebview() async {
    await widget.browser.open(
      url: Uri.parse(genixUrl),
      options: ChromeSafariBrowserClassOptions(
        ios: IOSSafariOptions(
            barCollapsingEnabled: true, presentationStyle: IOSUIModalPresentationStyle.FULL_SCREEN),
      ),
    );
  }

  void genixFireStorelistener() {
    try {
      log("Genix fireStore listener triggered in web_biew_call");
      stream = FireStoreCollections.teleconsultationServices
          .doc(widget.genixCallDetails.genixAppointId)
          .snapshots()
          .listen((dynamic event) async {
        Map<String, dynamic> data = event.data() as Map<String, dynamic>;
        log("Genix fireStore listener started web_view_call ${data.toString()}");
        String command = data != null ? data['cmd'] ?? data["data"]["cmd"] : "";
        if (command == null && data != null) {
          Map s = data["data"];
          command = s["cmd"];
        }
        String receiverIds =
            data != null ? data["receiver_ids"] ?? data['data']['receiver_ids'] : "null";
        log("Genix fireStore listener throws =>  command $command");
        if (receiverIds == widget.genixCallDetails.ihlUserId) {
          log("Genix fireStore listener => inside the condition one ");
          if (command == "AfterCallPrescritptionStatus" ||
              command == "AfterCallPrescriptionStatus") {
            if (widget.genixCallDetails.genixAppointId != "" ||
                widget.genixCallDetails.genixAppointId != null) {
              log("Genix fireStore listener => inside the condition two ");
              if (Platform.isIOS) {
                await widget.browser.close();
              }
              Get.off(ConsultationSummaryScreen(
                  fromCall: true, appointmentId: widget.genixCallDetails.genixAppointId));
            }
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  InAppWebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => alertDialogBox(),
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text("Video Call"),
              centerTitle: true,
              actions: <Widget>[
                TextButton(
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => alertDialogBox(),
                ),
              ],
            ),
            body: ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (_, c, __) {
                  if (c == false) {
                    return SizedBox(
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
                    );
                  }
                  return Platform.isIOS
                      ? SizedBox(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const <Widget>[
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text("Ongoing Consultation",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          child: Column(children: <Widget>[
                          Expanded(
                            child: SizedBox(
                              child: InAppWebView(
                                  initialUrlRequest: URLRequest(url: Uri.parse(genixUrl)),
                                  initialOptions: InAppWebViewGroupOptions(
                                    crossPlatform: InAppWebViewOptions(
                                      mediaPlaybackRequiresUserGesture: false,
                                    ),
                                  ),
                                  onWebViewCreated: (InAppWebViewController controller) {
                                    webViewController = controller;
                                  },
                                  androidOnPermissionRequest: (InAppWebViewController controller,
                                      String origin, List<String> resources) async {
                                    return PermissionRequestResponse(
                                        resources: resources,
                                        action: PermissionRequestResponseAction.GRANT);
                                  }),
                            ),
                          ),
                        ]));
                })));
  }

  alertDialogBox() {
    buildChild(BuildContext context) => Container(
          height: 350,
          decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: const <Widget>[
                        Icon(
                          FontAwesomeIcons.circleQuestion,
                          size: 80,
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    )),
              ),
              const SizedBox(
                height: 24,
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16, left: 16),
                child: Text(
                  'Are you sure want to \n End the call ?',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 10,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.5,
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 13.0, bottom: 13.0, right: 15, left: 15),
                      child: Text(
                        'Yes',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                    onPressed: () async {
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString('genixAppoinmentID', "");
                      prefs.setBool('isGenixCallAlive', false);
                      Get.offAll(LandingPage());
                    },
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 8,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 13.0, bottom: 13.0, right: 15, left: 15),
                      child: Text(
                        'No',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: buildChild(context),
            ),
          );
        });
  }
}
