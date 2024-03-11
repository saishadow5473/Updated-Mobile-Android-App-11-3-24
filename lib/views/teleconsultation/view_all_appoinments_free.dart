import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/invoice.dart';
import '../../new_design/presentation/pages/onlineServices/MyAppointment.dart';
import '../../repositories/api_consult.dart';
import '../../utils/app_colors.dart';
import '../../widgets/teleconsulation/appointmentTile.dart';
import '../../widgets/teleconsulation/payment/paymentUI.dart';
import '../view_past_bill/view_only_bill.dart';
import 'myAppointments.dart';

class FreeSuccessPage extends StatefulWidget {
  FreeSuccessPage(
      {Key key,
      @required this.date,
      @required this.appointment_ID,
      @required this.liveCall,
      this.materialPageRoute})
      : super(key: key);
  String date, appointment_ID;
  bool liveCall;
  VoidCallback materialPageRoute;

  @override
  State<FreeSuccessPage> createState() => _FreeSuccessPageState();
}

class _FreeSuccessPageState extends State<FreeSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Get.off(MyAppointment(
          backNav: false,
        ));
      },
      child: PaymentUI(
        color: AppColors.bookApp,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            title: Text(
              'Appointment Successful !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              key: Key('paymentSuccessBackButton'),
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Get.off(MyAppointment(
                backNav: false,
              )),
              color: Colors.white,
              tooltip: 'Back',
            )),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Lottie.network('https://assets2.lottiefiles.com/packages/lf20_pn7kzizl.json',
                  height: 300, width: 300),
              Container(
                  child:
                      // (loading == false && success == true)
                      //     ? (widget.details['livecall'])
                      //         ? Text(
                      //             'You will be redirected to Call Screen automatically within 5 seconds...',
                      //             textAlign: TextAlign.center,
                      //             style: TextStyle(
                      //               fontSize: 18,
                      //               color: Colors.green,
                      //             ),
                      //           )
                      // :
                      Text(
                widget.liveCall
                    ? "Appointment confirmed! Join in and kindly wait for the doctor to connect."
                    : 'Your appointment for ' + "\n" + widget.date + ' \n Booked successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                ),
              )
                  // : (loading == false && success == false)
                  //     ? Text('Your appointment for ' + date + ' failed!\n Try Again!',
                  //         textAlign: TextAlign.center,
                  //         style: TextStyle(
                  //           fontSize: 18,
                  //           color: Colors.red,
                  //         ))
                  //     : (widget.details['livecall'] && showMissed == false)
                  //         ? Text(
                  //             'Please Wait...\nConnecting to the consultant',
                  //             textAlign: TextAlign.center,
                  //             style: TextStyle(
                  //               fontSize: 18,
                  //               color: Colors.blue,
                  //             ),
                  //           )
                  //         : (showMissed == true)
                  //             ? Text(
                  //                 'Consultant is Busy... Please try later\n',
                  //                 textAlign: TextAlign.center,
                  //                 style: TextStyle(
                  //                   fontSize: 18,
                  //                   color: Colors.blue,
                  //                 ),
                  //               )
                  //             : Text(
                  //                 'Please wait. DO NOT LEAVE this page while your appointment is being confirmed',
                  //                 textAlign: TextAlign.center,
                  //                 style: TextStyle(
                  //                   fontSize: 18,
                  //                   color: Colors.blue,
                  //                 ),
                  //               ),
                  ),
              SizedBox(height: 30),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    // key: Key('paymentSuccessViewMyAppointment'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      primary: Colors.green,
                    ),
                    // onPressed: () {
                    onPressed: widget.materialPageRoute,
                    // Navigator.pushAndRemoveUntil(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => MyAppointments()),
                    //     (Route<dynamic> route) => false);
                    // },
                    child: Text(
                      widget.liveCall ? "Join Call" : "View My Appointments",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    // key: Key('paymentSuccessViewMyAppointment'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      primary: Colors.green,
                    ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();

                      bool permissionGrandted = false;

                      if (Platform.isAndroid) {
                        final deviceInfo = await DeviceInfoPlugin().androidInfo;
                        Map<Permission, PermissionStatus> _status;
                        if (deviceInfo.version.sdkInt <= 32) {
                          _status = await [Permission.storage].request();
                        } else {
                          _status = await [Permission.photos, Permission.videos].request();
                        }
                        _status.forEach((permission, status) {
                          if (status == PermissionStatus.granted) {
                            permissionGrandted = true;
                          }
                        });
                      } else {
                        permissionGrandted = true;
                      }
                      if (permissionGrandted) {
                        Get.snackbar(
                          '',
                          'Invoice will be saved in your mobile!',
                          backgroundColor: AppColors.primaryAccentColor,
                          colorText: Colors.white,
                          duration: Duration(seconds: 5),
                          isDismissible: false,
                        );
                        String ihlId = prefs.getString("ihlUserId");
                        await appointmentDetailsGlobal(
                            context: context, appointmentID: widget.appointment_ID);
                        Invoice invoice =
                            await ConsultApi().getInvoiceNumber(ihlId, widget.appointment_ID);
                        new Future.delayed(new Duration(seconds: 2), () {
                          billView(context, invoice.ihlInvoiceNumbers, true,
                              invoiceModel: invoice, navigation: "dont");
                        });
                      } else {
                        Get.snackbar(
                            'Storage Access Denied', 'Allow Storage permission to continue',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            duration: Duration(seconds: 5),
                            isDismissible: false,
                            mainButton: TextButton(
                                onPressed: () async {
                                  await openAppSettings();
                                },
                                child: Text('Allow')));
                      }
                    },
                    child: Text(
                      "Download Invoice",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
