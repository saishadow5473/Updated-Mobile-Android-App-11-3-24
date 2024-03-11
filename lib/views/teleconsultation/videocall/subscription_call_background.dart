import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/utils/CrossbarUtil.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../MySubscription.dart';
import '../mySubscriptions.dart';

class SubscriptionCallBackground extends StatefulWidget {
  final List callDetails;

  const SubscriptionCallBackground({Key key, this.callDetails}) : super(key: key);
  @override
  _SubscriptionCallBackgroundState createState() => _SubscriptionCallBackgroundState();
}

class _SubscriptionCallBackgroundState extends State<SubscriptionCallBackground> {
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
    // var userId = prefs.get("ihlUserId");
    String ihl_user_id = prefs.getString('ihlUserId');
    connect();
    videoCallSession = await videoCallSessionClient.connect().first;
    try {
      subscription = await videoCallSession.subscribe('ihl_send_data_to_user_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) {
        Map<String, dynamic> data = event.arguments[0];
        var status = data['data']['cmd'];
        consultationAppointmentId = data['data']['vid'];
        List receiverId = data['receiver_id'] ?? data['receiver_ids'];
        // if (receiverId.contains(prefs.get("IHL_User_ID"))) {
        if (receiverId.contains(ihl_user_id)) {
          if (widget.callDetails[3] == 'SubscriptionCall') {
            if (status == 'CallEndedByDoctor') {
              //CallEndedByDoctor = true;
              // Future.delayed(const Duration(seconds: 10), () {

              // });
              JitsiMeet.closeMeeting();
              if (widget.callDetails[3] == 'SubscriptionCall') {
                Get.to(MySubscription(
                  afterCall: true,
                  courseId: widget.callDetails[0],
                ));
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
        }
      });
      await subscription.onRevoke
          .then((reason) => print('The server has killed my subscription due to: ' + reason));
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  @override
  void initState() {
    appointmentSubscribe();
    super.initState();
  }

  @override
  void dispose() {
    videoCallSession.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: null,
      child: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: WillPopScope(
          onWillPop: null,
          child: BasicPageUI(
            appBar: Column(children: [
              Text(
                "Video Call",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ]),
            body: Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Lottie.network('https://assets9.lottiefiles.com/packages/lf20_7sobowqa.json',
                          height: 300, width: 300),
                      Text(
                        "        Minimising video screen \nCould affect the video quality",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
