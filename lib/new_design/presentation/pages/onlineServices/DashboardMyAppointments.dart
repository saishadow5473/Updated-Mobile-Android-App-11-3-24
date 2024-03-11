import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:connectanum/connectanum.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:strings/strings.dart';
import '../../../../constants/api.dart';
import '../../../../utils/app_colors.dart';
import '../../../jitsi/genix_signal.dart';
import '../../../jitsi/genix_web_view_call.dart';
import '../../Widgets/bloc_widgets/consultant_status/firebaseCall.dart';
import '../../clippath/subscriptionTagClipPath.dart';
import '../../../../repositories/api_repository.dart';

import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../teleconsultation/wait_for_consultant_screen.dart';

//
// // class MyAppointmentsNew extends StatefulWidget {
// //   BuildContext context;
// //
// //   MyAppointmentsNew({Key key, this.context}) : super(key: key);
// //
// //   @override
// //   State<MyAppointmentsNew> createState() => _MyAppointmentsNewState();
// // }
// //
// // class _MyAppointmentsNewState extends State<MyAppointmentsNew> {
// //   String status = 'Offline';
// //   http.Client _client = http.Client();
// //
// //   String NxtAvailableTxt = '';
// //   Stream _stream;
// //
// //   @override
// //   void initState() {
// //     update();
// //     httpStatus();
// //     // TODO: implement initState
// //     super.initState();
// //   }
// //
// //   update() async {
// //     var doctorId = '335aad6f96454425b25df675d9786b0a';
// //     try {
// //       _stream = FireStoreCollections.consultantOnlineStatus.doc(doctorId).snapshots();
// //       // .listen((event) {
// //       //   if (event.exists) {
// //       //     var _data = event.data();
// //       //     if (mounted)
// //       //       setState(() {
// //       //         status = _data['status'];
// //       //         // widget.consultant['availabilityStatus'] = 'status';
// //       //       });
// //       //   } else {
// //       //     FireStoreCollections.consultantOnlineStatus
// //       //         .doc(doctorId)
// //       //         .set({'consultantId': doctorId, 'status': status});
// //       //     // subscription.eventStream.listen((event) {
// //       //     //   Map data = event.arguments[0];
// //       //     //   var docStatus = data['data']['status'];
// //       //     //   if (data['sender_id'] == doctorId) {
// //       //     //     if (this.mounted) {
// //       //     //       setState(() {
// //       //     //         status = docStatus;
// //       //     //         widget.consultant['availabilityStatus'] = docStatus;
// //       //     //       });
// //       //     //     }
// //       //     //   }
// //       //     // });
// //       //   }
// //       // }).onError((error) {
// //       //   if (mounted)
// //       //     setState(() {
// //       //       status = 'Offline';
// //       //       // widget.consultant['availabilityStatus'] = status;
// //       //     });
// //       // });
// //       // subscription.eventStream.listen((event) {
// //       //   Map data = event.arguments[0];
// //       //   var docStatus = data['data']['status'];
// //       //   if (data['sender_id'] == doctorId) {
// //       //     if (this.mounted) {
// //       //       setState(() {
// //       //         status = docStatus;
// //       //         widget.consultant['availabilityStatus'] = docStatus;
// //       //       });
// //       //     }
// //       //   }
// //       // });
// //     } on Abort catch (abort) {
// //       print(abort.message.message);
// //     }
// //   }
// //
// //   void httpStatus() async {
// //     final response = await _client.post(
// //       Uri.parse(API.iHLUrl + '/consult/getConsultantLiveStatus'),
// //       body: jsonEncode(<String, dynamic>{
// //         "consultant_id": [
// //           "335aad6f96454425b25df675d9786b0a",
// //
// //         ]
// //       }),
// //     );
// //     if (response.statusCode == 200) {
// //       if (response.body != '"[]"') {
// //         var parsedString = response.body.replaceAll('&quot', '"');
// //         var parsedString1 = parsedString.replaceAll(";", "");
// //         var parsedString2 = parsedString1.replaceAll('"[', '[');
// //         var parsedString3 = parsedString2.replaceAll(']"', ']');
// //         var finalOutput = json.decode(parsedString3);
// //         var doctorId = "335aad6f96454425b25df675d9786b0a";
// //         for (int i = 0; i < finalOutput.length; i++) {
// //           if (doctorId == finalOutput[i]['consultant_id']) {
// //             NxtAvailableTxt =
// //             await getAvailableTime(finalOutput[i]['status'].toString().toLowerCase());
// //             if (this.mounted) {
// //               setState(() {
// //                 status = camelize(finalOutput[i]['status'].toString());
// //                 if (status == null || status == "" || status == "null" || status == "Null") {
// //                   status = "Offline";
// //                 }
// //                 // widget.consultant['availabilityStatus'] = status;
// //               });
// //             }
// //           }
// //         }
// //       } else {}
// //     }
// //   }
// //
// //   getAvailableTime(status) async {
// //     if (status != 'offline' && status != 'busy') status = 'offline';
// //     try {
// //       var availableSlot = await Apirepository().yetToArrive(
// //           consultId: '335aad6f96454425b25df675d9786b0a', venderName: 'GENIX', status: status);
// //       if (availableSlot[0] != 'NA') {
// //         // currentAvailable = availableSlot[0];
// //       }
// //       return availableSlot[1];
// //     } catch (e) {
// //       print(e.toString());
// //       return 'no Slots Found';
// //     }
// //   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         height: 37.h,
//         width: 60.h,
//         child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: EdgeInsets.only(top: 8.0, bottom: 9.0),
//             itemCount: 4,
//             itemBuilder: (BuildContext context, int index) {
//               return
//
//             }));
//   }
// }

class CardMyAppointments extends StatefulWidget {
  String ConsultationId,
      consultant_name,
      vendor_id,
      appointment_start_time,
      appointment_end_time,
      booked_date_time,
      appointment_id,
      call_status;
  var valConsult;

  CardMyAppointments(
      {Key key,
      this.ConsultationId,
      this.consultant_name,
      this.vendor_id,
      this.appointment_start_time,
      this.appointment_end_time,
      this.booked_date_time,
      this.appointment_id,
      this.call_status,
      this.valConsult})
      : super(key: key);

  @override
  State<CardMyAppointments> createState() => _CardMyAppointmentsState();
}

class _CardMyAppointmentsState extends State<CardMyAppointments> {
  String status = 'Offline';
  final http.Client _client = http.Client();
  bool enableJoinCall = false;
  String NxtAvailableTxt = '';
  Stream _stream;
  var appointmentStartingTime;

  @override
  void initState() {
    update();
    httpStatus();
    // TODO: implement initState
    super.initState();
  }

  String ihlUserId;
  String userName;
  update() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    Object data1 = prefs1.get('data');
    Map<String, dynamic> res = jsonDecode(data1);
    ihlUserId = res['User']['id'];
    userName = res['User']['firstName'] + res["User"]["lastName"];
    try {
      _stream = FireStoreCollections.consultantOnlineStatus.doc(widget.ConsultationId).snapshots();
      String appointmentStartstringTime = widget.appointment_start_time.substring(11, 19);
      String appointmentStartTime = widget.appointment_start_time.substring(0, 10);
      DateTime startTimeformattime = DateFormat.jm().parse(appointmentStartstringTime);
      String starttime = DateFormat("HH:mm:ss").format(startTimeformattime);
      String appointmentStartdateToFormat = "$appointmentStartTime $starttime";
      appointmentStartingTime = DateTime.parse(appointmentStartdateToFormat);
      DateTime fiveMinutesBeforeStartAppointment =
          appointmentStartingTime.subtract(const Duration(minutes: 0));
      DateTime thirtyMinutesAfterStartAppointment =
          appointmentStartingTime.add(const Duration(minutes: 30));
      print(fiveMinutesBeforeStartAppointment);
      print(thirtyMinutesAfterStartAppointment);
      print(DateTime.now());
      if (DateTime.now().isAfter(fiveMinutesBeforeStartAppointment) &&
          DateTime.now().isBefore(thirtyMinutesAfterStartAppointment) &&
          widget.call_status != "completed") {
        docStatusLisner();
        await httpStatus();
        if (status.toString().toLowerCase() == "online") {
          if (mounted) {
            setState(() {
              enableJoinCall = true;
            });
          }
        }
      }
      // if (status != 'Offline' || status == 'offline') {
      //   if (mounted) {
      //     setState(() {
      //       enableJoinCall = true;
      //     });
      //   }
      // }
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  StreamSubscription stream;
  void docStatusLisner() {
    log("Listner started for this account => ${"${widget.consultant_name}, time => ${widget.appointment_start_time}"}");
    String appointmentStatus = widget.valConsult.appointmentStatus.toString().toLowerCase();
    stream = FireStoreCollections.consultantOnlineStatus
        .doc(widget.ConsultationId)
        .snapshots()
        .listen((dynamic event) {
      if (event.exists) {
        Map<String, dynamic> temp = event.data() as Map<String, dynamic>;
        status = temp["status"];
        if ((status.toString().toLowerCase() == "online" ||
                status.toString().toLowerCase() == "busy") &&
            appointmentStatus.toLowerCase() != "requested") {
          enableJoinCall = true;
        } else {
          enableJoinCall = false;
        }
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    if (stream != null) stream.cancel();
    super.dispose();
  }

  void httpStatus() async {
    final http.Response response = await _client.post(
      Uri.parse('${API.iHLUrl}/consult/getConsultantLiveStatus'),
      body: jsonEncode(<String, dynamic>{
        "consultant_id": [
          widget.ConsultationId.toString(),
        ]
      }),
    );
    if (response.statusCode == 200) {
      if (response.body != '"[]"') {
        String parsedString = response.body.replaceAll('&quot', '"');
        String parsedString1 = parsedString.replaceAll(";", "");
        String parsedString2 = parsedString1.replaceAll('"[', '[');
        String parsedString3 = parsedString2.replaceAll(']"', ']');
        var finalOutput = json.decode(parsedString3);
        String doctorId = widget.ConsultationId;
        if (doctorId == finalOutput[0]['consultant_id']) {
          NxtAvailableTxt =
              await getAvailableTime(finalOutput[0]['status'].toString().toLowerCase());
          if (mounted) {
            setState(() {
              status = camelize(finalOutput[0]['status'].toString());
              if (status == null || status == "" || status == "null" || status == "Null") {
                status = "Offline";
              }
              // widget.consultant['availabilityStatus'] = status;
            });
          }
        }
      }
    }
  }

  getAvailableTime(status) async {
    if (status != 'Offline' && status != 'busy') status = 'Offline';
    try {
      List availableSlot = await Apirepository().yetToArrive(
          consultId: widget.ConsultationId, venderName: widget.vendor_id, status: status);
      if (availableSlot[0] != 'NA') {
        // currentAvailable = availableSlot[0];
      }
      return availableSlot[1];
    } catch (e) {
      print(e.toString());
      return 'no Slots Found';
    }
  }

  @override
  Widget build(BuildContext context) {
    // final DateFormat format = DateFormat("hh:mm a");
    // DateTime tempDate = Intl.withLocale('en', () => format.parse(dateTimeString));
    GetConsultantStatus()
        .consultantStatusFromFirebase(context.read, widget.ConsultationId.toString());
    return SizedBox(
      width: 46.w,
      height: 58.w,
      child: Card(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
        elevation: 4,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {},
          child: Stack(children: <Widget>[
            Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                height: 4.w,
                width: 13.w,
                child: RotationTransition(
                  turns: const AlwaysStoppedAnimation(180 / 360),
                  child: ClipPath(
                    clipper: SubscriptionClipPath(),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: _stream,
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: Colors.grey.withOpacity(0.3),
                            child: Container(
                                height: 4.w,
                                width: 13.w,
                                color: Colors.white,
                                child: const RotationTransition(
                                    turns: AlwaysStoppedAnimation(180 / 360),
                                    child: Text(
                                      "Offline",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.transparent, fontSize: 10),
                                    ))),
                          );
                        }
                        Map data;
                        if (snapshot.data != null) {
                          data = snapshot.data.data() as Map;
                        }

                        if (data != null) {
                          status = data['status'];
                        }

                        return Container(
                            height: 4.w,
                            width: 13.w,
                            color: status == 'Online'
                                ? Colors.green
                                : status == 'Busy'
                                    ? Colors.red
                                    : Colors.grey,
                            child: RotationTransition(
                                turns: const AlwaysStoppedAnimation(180 / 360),
                                child: Text(
                                  status,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                )));
                        // return InkWell(
                        //   onTap: () {
                        //     // FireStoreCollections.consultantOnlineStatus
                        //     //     .doc(widget.ConsultationId)
                        //     //     .set({
                        //     //   'consultantId': widget.ConsultationId,
                        //     //   'status': status == 'Online' ? "Offline" : "Online"
                        //     // });
                        //   },
                        //   child: BlocBuilder<ConsultantstatusBloc, ConsultantstatusState>(
                        //     builder: (BuildContext context, ConsultantstatusState state) {
                        //       if (state is InitialConsultantsState) {
                        //         return const Text('Loading');
                        //       }
                        //       if (state is UpdatedConsultantsState) {
                        //         if (state.id == widget.ConsultationId) {
                        //           // String statusT;
                        //           // if (state.isOnline && status.toLowerCase() == "Online") {
                        //           //   statusT = 'Online';
                        //           // } else {
                        //           //   statusT = status;
                        //           // }
                        //           return Container(
                        //               height: 4.w,
                        //               width: 13.w,
                        //               color: status == 'Online'
                        //                   ? Colors.green
                        //                   : status == 'Busy'
                        //                       ? Colors.red
                        //                       : Colors.grey,
                        //               child: RotationTransition(
                        //                   turns: const AlwaysStoppedAnimation(180 / 360),
                        //                   child: Text(
                        //                     status,
                        //                     textAlign: TextAlign.center,
                        //                     style:
                        //                         const TextStyle(color: Colors.white, fontSize: 10),
                        //                   )));
                        //         }
                        //       }
                        //       return Container(
                        //           height: 4.w,
                        //           width: 13.w,
                        //           color: Colors.grey,
                        //           child: const RotationTransition(
                        //               turns: AlwaysStoppedAnimation(180 / 360),
                        //               child: Text(
                        //                 'Offline',
                        //                 textAlign: TextAlign.center,
                        //                 style: TextStyle(color: Colors.white, fontSize: 10),
                        //               )));
                        //     },
                        //   ),
                        // );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 2.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.sp,
                      top: 10.sp,
                    ),
                    child: SizedBox(
                      width: 32.w,
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: FutureBuilder(
                              future: TabBarController()
                                  .getConsultantImageUrl(doctor: widget.valConsult.toJson()),
                              builder: (BuildContext context, AsyncSnapshot<String> i) {
                                if (i.connectionState == ConnectionState.done) {
                                  return CircleAvatar(
                                    radius: 10.w,
                                    backgroundImage: Image.memory(
                                      base64Decode(i.data.toString()),
                                    ).image,
                                    backgroundColor: Colors.transparent,
                                  );
                                } else if (i.connectionState == ConnectionState.waiting) {
                                  return Shimmer.fromColors(
                                      baseColor: Colors.white,
                                      highlightColor: Colors.grey.withOpacity(0.3),
                                      direction: ShimmerDirection.ltr,
                                      child: CircleAvatar(
                                        radius: 10.w,
                                        backgroundColor: Colors.white,
                                      )
                                      // Container(
                                      //   width: 10.w,
                                      //   height: 10.w,
                                      //   decoration: const BoxDecoration(
                                      //     shape: BoxShape.circle,
                                      //     color: Colors.red,
                                      //   ),
                                      // ),
                                      );
                                } else {
                                  return Container();
                                }
                              })),
                    ),
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 18.sp, bottom: 3.0, top: 6.0),
                            child: SizedBox(
                              width: 45.w,
                              child: Text(
                                widget.consultant_name,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: widget.consultant_name.length < 23 ? 14.sp : 13.5.sp,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 18.sp, bottom: 3.0, top: 6.0),
                            child: SizedBox(
                              width: 45.w,
                              child: Text(
                                '${widget.appointment_start_time.replaceRange(0, 11, '')} - ${widget.appointment_end_time.replaceRange(0, 11, '')}',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp),
                                maxLines: 2,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 18.sp, bottom: 8.0, top: 6.0),
                            child: SizedBox(
                              width: 45.w,
                              child: Text(
                                widget.appointment_start_time.replaceRange(11, 19, ''),
                                textAlign: TextAlign.start,
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      callButton(
                          isgenix: widget.vendor_id.toLowerCase() == "genix",
                          videoCallDetail: VideoCallDetail(
                              appointId: widget.appointment_id,
                              docId: widget.ConsultationId,
                              userID: ihlUserId,
                              callType: "appointmentCall",
                              ihlUserName: userName))
                    ],
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget callButton({VideoCallDetail videoCallDetail, bool isgenix}) {
    return InkWell(
      onTap: enableJoinCall
          ? () {
              if (isgenix) {
                Get.offAll(GenixWebViewCall(
                    genixCallDetails: GenixCallDetails(genixAppointId: widget.appointment_id)));
              } else {
                TeleConsultationFunctionsAndVariables().permissionCheckerForCall(nav: () {
                  Get.offAll(WaitForConsultant(videoCallDetails: videoCallDetail));
                });
              }
            }
          : () => log("Disabled Button"),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: enableJoinCall ? AppColors.primaryColor : AppColors.primaryColor),
                color: Colors.white),
            child: enableJoinCall
                ? const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.call,
                      color: AppColors.primaryColor,
                      size: 15,
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Opacity(
                      opacity: 0.5,
                      child: Icon(
                        Icons.call,
                        color: AppColors.primaryColor,
                        size: 15,
                      ),
                    ),
                  ),
          ),
          SizedBox(width: 2.w),
          Text(
            'Join Call',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: enableJoinCall ? Colors.black : Colors.grey,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// .listen((event) {
//   if (event.exists) {
//     var _data = event.data();
//     if (mounted)
//       setState(() {
//         status = _data['status'];
//         // widget.consultant['availabilityStatus'] = 'status';
//       });
//   } else {
//     FireStoreCollections.consultantOnlineStatus
//         .doc(doctorId)
//         .set({'consultantId': doctorId, 'status': status});
//     // subscription.eventStream.listen((event) {
//     //   Map data = event.arguments[0];
//     //   var docStatus = data['data']['status'];
//     //   if (data['sender_id'] == doctorId) {
//     //     if (this.mounted) {
//     //       setState(() {
//     //         status = docStatus;
//     //         widget.consultant['availabilityStatus'] = docStatus;
//     //       });
//     //     }
//     //   }
//     // });
//   }
// }).onError((error) {
//   if (mounted)
//     setState(() {
//       status = 'Offline';
//       // widget.consultant['availabilityStatus'] = status;
//     });
// });
// subscription.eventStream.listen((event) {
//   Map data = event.arguments[0];
//   var docStatus = data['data']['status'];
//   if (data['sender_id'] == doctorId) {
//     if (this.mounted) {
//       setState(() {
//         status = docStatus;
//         widget.consultant['availabilityStatus'] = docStatus;
//       });
//     }
//   }
// });
