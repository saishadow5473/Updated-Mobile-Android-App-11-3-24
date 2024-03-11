import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../views/teleconsultation/genix_livecall_signal.dart';
import '../../../app/utils/appColors.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../../data/model/TeleconsultationModels/doctorModel.dart';
import '../../../jitsi/genix_signal.dart';
import '../../controllers/dashboardControllers/upComingDetailsController.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../teleconsultation/wait_for_consultant_screen.dart';
import 'MyAppointment.dart';
import 'couponPage.dart';
import 'myAppointmentsTabs.dart';

class AppointmentAndLiveCallSuccess extends StatelessWidget {
  AppointmentAndLiveCallSuccess(
      {Key key,
      this.appointmentTiming,
      this.liveCall,
      this.doctorDetails,
      this.appointId,
      this.vendorAppointmentId})
      : super(key: key);
  String appointmentTiming;
  String appointId;
  bool liveCall;
  String vendorAppointmentId;
  DoctorModel doctorDetails;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return null;
      },
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.primaryColor,
            leading: const SizedBox(),
            // leading: IconButton(
            //     onPressed: () {
            //       Get.back();
            //     },
            //     icon: const Icon(
            //       Icons.arrow_back_ios,
            //       color: Colors.white,
            //     )),
            title: const Text("Appointment Successful"),
            centerTitle: true,
          ),
          body: SizedBox(
            height: 100.h,
            width: 100.w,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 7.h),
                  Container(
                    height: 70.w,
                    width: 70.w,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("newAssets/Icons/success_payment.png"),
                            fit: BoxFit.contain)),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: 80.w,
                    child: Text(
                      liveCall
                          ? "Appointment confirmed! Join in and kindly wait for the doctor to connect."
                          : "Your Appointment for \n $appointmentTiming \n Booked Successfully!!",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, letterSpacing: 0.3, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 7.h),
                  GestureDetector(
                    onTap: () async {
                      // if (liveCall == true) {
                      //   if (widget['vendor_id'].toString() == 'GENIX') {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => GenixLiveSignal(
                      //           // genixAppointId: appointId.toString().replaceAll('ihl_consultant_', ''),
                      //           genixAppointId: appointmentId,
                      //           iHLUserId: iHLUserId.toString(),
                      //           specality: selectedSpecality.toString().trim(),
                      //           vendor_consultant_id:
                      //           widget.visitDetails['doctor']['vendor_consultant_id'].toString(),
                      //           vendorConsultantId:
                      //           widget.visitDetails['doctor']['vendor_consultant_id'].toString(),
                      //           vendorAppointmentId: vendorAppointId,
                      //           vendorUserName: widget.visitDetails['doctor']['user_name'],
                      //         ),
                      //       ), //user_name
                      //     );
                      //   } else {
                      //     Get.offNamedUntil(Routes.CallWaitingScreen, (route) => false, arguments: [
                      //       appointId.toString(),
                      //       widget.visitDetails['doctor']['ihl_consultant_id'].toString(),
                      //       iHLUserId.toString(),
                      //       "LiveCall",
                      //       ihlUserName
                      //     ]);
                      //   }
                      // }
                      // {Key key, this.appointmentTiming, this.liveCall, this.doctorDetails, this.appointId})
                      if (liveCall == false) {
                        Get.put(UpcomingDetailsController().upComingDetails);
                        Get.to(MyAppointmentsTabs(fromCall: true));
                      } else {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String uid = prefs.getString("ihlUserId");
                        String userName = prefs.getString(LSKeys.userName);
                        if (doctorDetails.vendorId.toString() == 'GENIX') {
                          log("Genix Signal Navigated successfully ");
                          Get.to(GenixSignal(
                              genixCallDetails: GenixCallDetails(
                                  genixAppointId: appointId.replaceAll("ihl_consultant_", ''),
                                  ihlUserId: uid,
                                  specality: doctorDetails.consultantSpeciality.first,
                                  vendorAppointmentId: vendorAppointmentId,
                                  vendorConsultantId: doctorDetails.vendorConsultantId,
                                  vendorUserName: doctorDetails.userName)));
                        } else {
                          TeleConsultationFunctionsAndVariables().permissionCheckerForCall(nav: () {
                            Get.offAll(WaitForConsultant(
                              videoCallDetails: VideoCallDetail(
                                  appointId: appointId,
                                  docId: doctorDetails.ihlConsultantId.toString(),
                                  userID: uid,
                                  callType: "LiveCall",
                                  ihlUserName: userName),
                            ));
                          });
                        }
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 70.w,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.primaryColor, width: 2),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 3,
                                spreadRadius: 3,
                                offset: const Offset(0, 0))
                          ]),
                      child: Text(
                        liveCall ?? false ? "JOIN CALL" : "VIEW ALL APPOINTMENTS",
                        style: TextStyle(
                            letterSpacing: 0.3,
                            color: Colors.black.withOpacity(0.5),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Container(
                  //   alignment: Alignment.center,
                  //   width: 70.w,
                  //   padding: const EdgeInsets.symmetric(vertical: 10),
                  //   decoration: BoxDecoration(color: AppColors.primaryColor, boxShadow: <BoxShadow>[
                  //     BoxShadow(
                  //         color: Colors.grey.withOpacity(0.3),
                  //         blurRadius: 3,
                  //         spreadRadius: 3,
                  //         offset: const Offset(0, 0))
                  //   ]),
                  //   child: const Text(
                  //     "DOWNLOAD INVOICE",
                  //     style: TextStyle(
                  //         letterSpacing: 0.3, color: Colors.white, fontWeight: FontWeight.bold),
                  //   ),
                  // ),
                ],
              ),
            ),
          )),
    );
  }
}
