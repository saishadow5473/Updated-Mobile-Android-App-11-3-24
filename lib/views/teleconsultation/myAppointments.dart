import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:ihl/widgets/teleconsulation/exports.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/teleconsulation/upcomingAppointment.dart';
import 'package:ihl/utils/CrossbarUtil.dart' as s;

/// Appointments 👀👀
class MyAppointments extends StatelessWidget {
  MyAppointments({this.isHighlight, @required this.backNav});
  final bool isHighlight;
  bool backNav = false;

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: WillPopScope(
        onWillPop: () {
          backNav ? Get.back() : Get.off(ViewallTeleDashboard());
        },
        child: BasicPageUI(
          appBar: Column(
            children: [
              SizedBox(
                width: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BackButton(
                  //   onPressed: () {
                  //     if (isHighlight == false || isHighlight == null) {
                  //       Get.off(ViewallTeleDashboard());
                  //     } else {
                  //       Get.off(ViewallTeleDashboard(
                  //         backNav: true,
                  //       ));
                  //     }
                  //   },
                  //   color: Colors.white,
                  // ),
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      if (isHighlight == false || isHighlight == null) {
                        if (backNav ?? false) {
                          Get.back();
                        } else {
                          Get.off(ViewallTeleDashboard());
                        }
                      } else {
                        Get.off(ViewallTeleDashboard(
                          backNav: true,
                        ));
                      }
                    },
                    color: Colors.white,
                  ),
                  Text(
                    AppTexts.myAppoitmentsTitle,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  SizedBox(
                    width: 40,
                  )
                ],
              ),
              Visibility(
                visible: false,
                child: GestureDetector(
                  onTap: () {
                    // [GenerateNotification, SubscriptionClass, [284162999aee4fc6910118d00b9c5521], pM7UyDhBAkih16N7beZ0Rw, null]
                    s.appointmentPublish(
                        'GenerateNotification',
                        'BookAppointment',
                        ['9b69374d68374f9cbfb68872e989632d'],
                        'M1ZDc8bNE0KpHcDysxSg3g',
                        '5271f7bf16994dd1a19d3c65ea3eb638');

                    // s.publishCallDetails(
                    //   'NewLiveAppointment',
                    //   ['9b69374d68374f9cbfb68872e989632d'],
                    //     'M1ZDc8bNE0KpHcDysxSg3g',
                    //     '5271f7bf16994dd1a19d3c65ea3eb638','s');
                    // GenerateNotification , BookAppointment , [9b69374d68374f9cbfb68872e989632d] , M1ZDc8bNE0KpHcDysxSg3g , 5271f7bf16994dd1a19d3c65ea3eb638
                  },
                  child: Text('publish appointment '),
                ),
              ),
              SizedBox(
                height: 40,
              )
            ],
          ),
          body: UpcomingAppointments(),
        ),
      ),
    );
  }
}
