import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/teleconsulation/DashboardTile.dart';
import 'package:ihl/widgets/teleconsulation/dashboard_Consult_historyItemTile.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:http/http.dart' as http;

class DashBoardPastAppointments extends StatefulWidget {
  @override
  _DashBoardPastAppointmentsState createState() =>
      _DashBoardPastAppointmentsState();
}

class _DashBoardPastAppointmentsState extends State<DashBoardPastAppointments> {
  http.Client _client = http.Client(); //3gb
  bool hashistory = false;
  List appointments = [];
  List history = [];
  List completedHistory = [];
  var list = [];
  bool completedSelected = false;
  bool approvedSelected = false;
  bool canceledSelected = false;
  bool requestedSelected = false;
  bool rejectedSelected = false;
  bool loading = true;
  var apps = [];

  List<String> appointmentStatus = [
    'Approved',
    'Completed',
    'Rejected',
    'Requested',
    'Canceled',
  ];

  Future getData() async {
    /*SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);
    Map teleConsulResponse;*/
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    var iHLUserId = res['User']['id'];


      if (this.mounted) {
        setState(() {
          loading = false;
          hashistory = false;
        });

    }
  }

  DashBoardHistoryItem getItem(Map map, var index) {
    return DashBoardHistoryItem(
      index: index,
      appointId: map['appointment_id'],
      appointmentStartTime: map['appointment_start_time'],
      appointmentEndTime: map['appointment_end_time'],
      consultantName:
          map['consultant_name'] == null ? "N/A" : map['consultant_name'],
      consultationFees: map['consultation_fees'],
      appointmentStatus: map['appointment_status'],
      callStatus: map['call_status'] == null ? "N/A" : map['call_status'],
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DashboardTile(
          icon: FontAwesomeIcons.history,
          text: 'Loading ' + '...',
          color: AppColors.history,
          trailing: CircularProgressIndicator(),
          onTap: () {},
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DashBoardContent(
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
                              state.didChange(val);
                              if (val.isEmpty) {
                                if (this.mounted) {
                                  setState(() {
                                    list = apps
                                        .where((i) =>
                                            // i['appointment_status'] == "Approved" ||
                                            // i['appointment_status'] ==
                                            //     "approved" ||
                                            i['appointment_status'] ==
                                                "completed" ||
                                            i['appointment_status'] ==
                                                "Completed")
                                        // i['appointment_status'] ==
                                        //     "Rejected" ||
                                        // i['appointment_status'] ==
                                        //     "rejected" ||
                                        // i['appointment_status'] ==
                                        //     "Requested" ||
                                        // i['appointment_status'] ==
                                        //     "requested" ||
                                        // i['appointment_status'] ==
                                        //     "canceled" ||
                                        // i['appointment_status'] ==
                                        //     "Canceled")
                                        .toList();
                                  });
                                }
                                print(list.length);
                              } else {
                                if (this.mounted) {
                                  setState(() {
                                    list = apps
                                        .where((i) => val
                                            .contains(i['appointment_status']))
                                        .toList();
                                  });
                                }
                                print(list.length);
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
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: list.map((e) {
                return getItem(e, list.indexOf(e));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class DashBoardContent extends StatelessWidget {
  final Widget child;

  DashBoardContent({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;

    // Card(
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(15.0),
    //     ),
    //     elevation: 2,
    //     // margin: EdgeInsets.all(3),
    //     clipBehavior: Clip.antiAliasWithSaveLayer,
    //     child: child);
  }
}
