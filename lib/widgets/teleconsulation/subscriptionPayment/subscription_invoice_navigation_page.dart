import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/invoice.dart';
import '../../../repositories/api_consult.dart';
import '../../../utils/app_colors.dart';
import '../../../views/teleconsultation/MySubscription.dart';
import '../../../views/teleconsultation/mySubscriptions.dart';
import '../../../views/view_past_bill/view_subscription_invoice.dart';
import '../payment/paymentUI.dart';

class SubscriptionInvoiceNavigation extends StatefulWidget {
  SubscriptionInvoiceNavigation({
    Key key,
    @required this.title,
    @required this.currentSubscription,
    this.materialPageRoute,
    @required this.provider,
    @required this.subscription_id,
  }) : super(key: key);
  String subscription_id, title, provider;
  var currentSubscription;
  VoidCallback materialPageRoute;
  @override
  State<SubscriptionInvoiceNavigation> createState() => _SubscriptionInvoiceNavigationState();
}

class _SubscriptionInvoiceNavigationState extends State<SubscriptionInvoiceNavigation> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => MySubscription(
                      afterCall: false,
                    )),
            (Route<dynamic> route) => false);
      },
      child: PaymentUI(
        color: AppColors.bookApp,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            title: Text(
              'Subscription Successful !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              key: Key('paymentSuccessBackButton'),
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                // Get.off(MyAppointments());
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MySubscription(
                              afterCall: false,
                            )),
                    (Route<dynamic> route) => false);
              },
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
                  child: Text(
                "${widget.title} Subscribed !!!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.green),
              )),
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
                    onPressed: widget.materialPageRoute,
                    child: Text(
                      "View All Subscribtion",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      primary: Colors.green,
                    ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String ihlId = prefs.getString("ihlUserId");
                      String apiToken = prefs.get('auth_token');
                      var email = prefs.get('email');
                      var data = prefs.get('data');
                      Map res = jsonDecode(data);
                      var firstName = res['User']['firstName'];
                      var lastName = res['User']['lastName'];
                      var mobile = res['User']['mobileNumber'];

                      // AwesomeNotifications().cancelAll();
                      bool permissionGrandted = false;
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
                      if (permissionGrandted) {
                        prefs.setString("userFirstNameFromHistory", firstName);
                        prefs.setString("userLastNameFromHistory", lastName);
                        prefs.setString("userEmailFromHistory", email);
                        prefs.setString("userContactFromHistory", mobile);
                        prefs.setString("subsIdFromHistory", widget.subscription_id);
                        prefs.setString("useraddressFromHistory", address);
                        prefs.setString("userareaFromHistory", area);
                        prefs.setString("usercityFromHistory", city);
                        prefs.setString("userstateFromHistory", state);
                        prefs.setString("userpincodeFromHistory", pincode);
                        Get.snackbar(
                          '',
                          'Invoice will be saved in your mobile!',
                          backgroundColor: AppColors.primaryAccentColor,
                          colorText: Colors.white,
                          duration: Duration(seconds: 5),
                          isDismissible: false,
                        );
                        Invoice invoiceModel =
                            await ConsultApi().getInvoiceNumber(ihlId, widget.subscription_id);
                        invoiceModel.ihlInvoiceNumbers = prefs.getString('invoice');
                        print(invoiceModel.ihlInvoiceNumbers);
                        print(invoiceNumber.toString());
                        new Future.delayed(new Duration(seconds: 3), () {
                          subscriptionBillView(context, widget.title, widget.provider,
                              widget.currentSubscription, invoiceModel.ihlInvoiceNumbers,
                              invoiceModel: invoiceModel);
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
