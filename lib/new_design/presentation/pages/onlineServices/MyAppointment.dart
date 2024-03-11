import 'package:chips_choice/chips_choice.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/controllers/teleConsultationControllers/appointmentController.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../../constants/app_texts.dart';
import '../../../../views/teleconsultation/viewallneeds.dart';
import '../../../../widgets/offline_widget.dart';
import '../../../../widgets/teleconsulation/appointmentTile.dart';
import '../../../../widgets/teleconsulation/history.dart';
import '../../../app/utils/appColors.dart';

class MyAppointment extends StatelessWidget {
  MyAppointmentController _appointmentController;
  bool backNav = false;
  MyAppointment({@required this.backNav});
  List<String> appointmentStatus = [
    'Approved',
    'Requested',
  ];
  AppointmentTile getItem(Map map) {
    return AppointmentTile(
      ihlConsultantId: map["ihl_consultant_id"],
      name: map["consultant_name"],
      date: map["appointment_start_time"],
      endDateTime: map["appointment_end_time"],
      consultationFees: map['consultation_fees'],
      isApproved:
          map['appointment_status'] == "Approved" || map['appointment_status'] == "Approved",
      isRejected:
          map['appointment_status'] == "rejected" || map['appointment_status'] == "Rejected",
      isPending:
          map['appointment_status'] == "requested" || map['appointment_status'] == "Requested",
      isCancelled:
          map['appointment_status'] == "canceled" || map["appointment_status"] == "Canceled",
      isCompleted:
          map['appointment_status'] == "completed" || map['appointment_status'] == "Completed",
      appointmentId: map['appointment_id'],
      callStatus: map['call_status'] ?? "N/A",
      vendorId: map['vendor_id'],
      sharedReportAppIdList: _appointmentController.sharedReportAppIdList,
    );
  }

  Widget _appointmentLoading(int count) {
    return ListView.builder(
        itemCount: count,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
              direction: ShimmerDirection.ltr,
              period: const Duration(seconds: 2),
              baseColor: Colors.white,
              highlightColor: Colors.grey.withOpacity(0.2),
              child: Container(
                  margin: const EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Loading')));
        });
  }

  @override
  Widget build(BuildContext context) {
    _appointmentController = Get.put(MyAppointmentController());
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: WillPopScope(
        onWillPop: () {
          Get.delete<MyAppointmentController>();

          if (backNav ?? false) {
            Get.back();
          } else {
            Get.off(ViewallTeleDashboard());
          }
        },
        child: BasicPageUI(
          appBar: Column(
            children: [
              const SizedBox(
                width: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Get.delete<MyAppointmentController>();
                      if (backNav ?? false) {
                        Get.back();
                      } else {
                        Get.off(ViewallTeleDashboard());
                      }
                    },
                    color: Colors.white,
                  ),
                  const Text(
                    AppTexts.myAppoitmentsTitle,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  const SizedBox(
                    width: 40,
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              )
            ],
          ),
          body: Column(
            children: [
              GetBuilder<MyAppointmentController>(
                id: 'appointmentLoading',
                builder: (_) => _.isLoading
                    ? _appointmentLoading(6)
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Content(
                                  title: 'Filter Appointments',
                                  child: FormField<List<String>>(
                                    initialValue: [],
                                    builder: (state) {
                                      return Column(
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: ChipsChoice<String>.multiple(
                                              value: state.value,
                                              choiceItems: C2Choice.listFrom<String, String>(
                                                source: appointmentStatus,
                                                value: (i, v) => v,
                                                label: (i, v) => v,
                                              ),
                                              onChanged: (val) {
                                                if (val.contains('Approved')) {
                                                  if (!val.contains(_.filterType)) {
                                                    _.filterType = "Approved";
                                                    _.selectedList = [];
                                                    _.updateList();
                                                  }
                                                } else if (val.contains('Requested')) {
                                                  if (!val.contains(_.filterType)) {
                                                    _.filterType = "Requested";
                                                    _.selectedList = [];
                                                    _.updateList();
                                                  }
                                                }
                                              },
                                              choiceActiveStyle: const C2ChoiceStyle(
                                                  color: AppColors.primaryAccentColor,
                                                  brightness: Brightness.dark),
                                              choiceStyle: const C2ChoiceStyle(
                                                color: AppColors.primaryAccentColor,
                                                borderOpacity: .3,
                                              ),
                                              wrapped: true,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 1.7,
                                child: GetBuilder<MyAppointmentController>(
                                    id: 'listupdated',
                                    builder: (_) {
                                      return _.switchLoading
                                          ? _appointmentLoading(5)
                                          : ListView.builder(
                                              controller: _.controller,
                                              itemCount: _.selectedList.length,
                                              itemBuilder: (ctx, index) =>
                                                  getItem(_.selectedList[index]),
                                            );
                                    }),
                              )
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
