// ignore_for_file: missing_return

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/Getx/controller/ConsultationHistoryController.dart';
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:ihl/widgets/teleconsulation/history.dart';

class ConsultHistory extends StatelessWidget {
  const ConsultHistory({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(ConsultationHistoryController());
    return WillPopScope(
      onWillPop: () {
        Get.delete<ConsultationHistoryController>();
        Get.to(ViewallTeleDashboard());
      },
      child: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: BasicPageUI(
          appBar: Column(
            children: [
              SizedBox(
                width: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Get.delete<ConsultationHistoryController>();

                      // ViewallTeleDashboard();
                      Get.to(ViewallTeleDashboard());
                      // Get.delete<ConsultationHistoryController>();
                      // Navigator.pop(context);
                    },
                    color: Colors.white,
                  ),
                  Text(
                    "Consultation History",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  SizedBox(
                    width: 40,
                  )
                ],
              ),
              SizedBox(
                height: 40,
              )
            ],
          ),
          body: Column(
            children: [
              PastAppointments(),
              //ConsultationHistoryList()
            ],
          ),
        ),
      ),
    );
  }
}
