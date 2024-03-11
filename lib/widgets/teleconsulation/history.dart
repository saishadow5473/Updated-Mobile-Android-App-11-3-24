import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/teleconsulation/DashboardTile.dart';
import 'package:ihl/widgets/teleconsulation/historyItemTile.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shimmer/shimmer.dart';

import '../../Getx/controller/ConsultationHistoryController.dart';

class PastAppointments extends StatefulWidget {
  @override
  State<PastAppointments> createState() => _PastAppointmentsState();
}

class _PastAppointmentsState extends State<PastAppointments> {
  List<String> appointmentStatus = [
    'Approved',
    'Completed',
    'Rejected',
    'Requested',
    'Canceled',
  ];
  final _getxController = Get.put(ConsultationHistoryController());

  @override
  void initState() {
    // getDocID();

    super.initState();
  }

  HistoryItem getItem(Map map, var index) {
    return HistoryItem(
      index: index,
      appointId: map['appointment_id'],
      appointmentStartTime: map['appointment_details']['appointment_start_time'],
      appointmentEndTime: map['appointment_details']['appointment_end_time'],
      consultantName: map['consultant_details']['consultant_name'] == null
          ? "N/A"
          : map['consultant_details']['consultant_name'],
      consultationFees: map['call_details']['consultation_fees'].toString(),
      appointmentStatus: map['appointment_details']['appointment_status'],
      callStatus:
          map['call_details']['call_status'] == null ? "N/A" : map['call_details']['call_status'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final consultationHistoryController = Get.put(ConsultationHistoryController());
    return WillPopScope(
      onWillPop: () {
        Get.delete<ConsultationHistoryController>();
        Get.back();
      },
      child: GetBuilder<ConsultationHistoryController>(
        id: 'consultationHistoryloading',
        builder: (_) {
          return _.isLoading
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DashboardTile(
                    icon: FontAwesomeIcons.history,
                    text: 'Loading ' + '...',
                    color: AppColors.history,
                    trailing: CircularProgressIndicator(),
                    onTap: () {},
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
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
                                          if (val.contains('Completed')) {
                                            _.updateSearchTerm("Completed");
                                            _.filterType = "Completed";

                                            _.update(['consultationHistoryloading']);
                                          } else if (val.contains('Approved')) {
                                            _.updateSearchTerm("Approved");
                                            _.filterType = "Approved";
                                            _.update(['consultationHistoryloading']);
                                          } else if (val.contains('Rejected')) {
                                            _.updateSearchTerm("Rejected");
                                            _.filterType = "Rejected";
                                            _.update(['consultationHistoryloading']);
                                          } else if (val.contains('Requested')) {
                                            _.updateSearchTerm("Requested");
                                            _.filterType = "Requested";
                                            _.update(['consultationHistoryloading']);
                                          } else if (val.contains('Canceled')) {
                                            _.updateSearchTerm("Canceled");
                                            _.filterType = "Canceled";
                                            _.update(['consultationHistoryloading']);
                                          }
                                        },
                                        choiceActiveStyle: C2ChoiceStyle(
                                            color: AppColors.primaryAccentColor,
                                            brightness: Brightness.dark),
                                        choiceStyle: C2ChoiceStyle(
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
                          width: double.infinity,
                          child: GetBuilder<ConsultationHistoryController>(
                              id: 'listupdated',
                              builder: (context) {
                                return _.filterBool
                                    ? Shimmer.fromColors(
                                        child: Container(
                                            margin: EdgeInsets.all(8),
                                            width: 100,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text('Hello')),
                                        direction: ShimmerDirection.ltr,
                                        period: Duration(seconds: 2),
                                        baseColor: Colors.white,
                                        highlightColor: Colors.grey.withOpacity(0.2))
                                    : PagedListView<int, dynamic>(
                                        pagingController: _getxController.pagingController,
                                        builderDelegate: PagedChildBuilderDelegate(
                                          itemBuilder: (ctx, item, index) => index <
                                                  _.currentList.length
                                              ? getItem(_getxController.currentList[index], index)
                                              : null,
                                          newPageProgressIndicatorBuilder: (value) {
                                            return Center(child: Text("Loading"));
                                          },
                                          noItemsFoundIndicatorBuilder: (value) {
                                            return Center(
                                                child:
                                                    Text("No consultation history is available."));
                                          },
                                          animateTransitions: true,
                                          noMoreItemsIndicatorBuilder: (value) {
                                            return Center(child: Text("Empty"));
                                          },
                                        ));
                              }),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}

class Content extends StatelessWidget {
  final String title;
  final Widget child;

  Content({
    Key key,
    @required this.title,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 2,
      margin: EdgeInsets.all(3),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            color: Colors.blueGrey[50],
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
