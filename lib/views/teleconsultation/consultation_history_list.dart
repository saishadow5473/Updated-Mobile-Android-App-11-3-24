import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/teleconsultation/consultation_history_tile.dart';
import 'package:ihl/widgets/teleconsulation/DashboardTile.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ConsultationHistoryList extends StatefulWidget {
  @override
  _ConsultationHistoryListState createState() =>
      _ConsultationHistoryListState();
}

class _ConsultationHistoryListState extends State<ConsultationHistoryList> {
  http.Client _client = http.Client(); //3gb
  String iHLUserId;
  ExpandableController _expandableController;
  bool expanded = false;
  bool hashistory = false;
  List history = [];
  bool loading = true;
  @override
  void dispose() {
    super.dispose();
  }

  Future getData() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    iHLUserId = res['User']['id'];

    if (this.mounted) {
      setState(() {
        hashistory = true;
      });
    }
  }

  ConsultationHistoryTile getItem(Map map, var index) {
    return ConsultationHistoryTile(
      index: index,
      appointmentId: map['appointment_details']["appointment_id"],
      name: map['consultant_details']["consultant_name"],
      type: map['consultant_details']["specality"],
      date: map['appointment_details']["appointment_start_time"],
      appointmentEndTime: map['appointment_details']["appointment_end_time"],
      dur: map['appointment_details']["appointment_duration"],
      modeOfPayment: map['call_details']['mode_of_payment'],
      consultationFees: map['call_details']['consultation_fees'].toString(),
      reasonForVisit: map['consultant_notes']['reason_for_visit'].toString(),
      diagnosis: map['consultant_notes']['diagnosis'].toString() ?? "N/A",
      adviceNotes:
          map['consultant_notes']['advice_to_patient'].toString() ?? "N/A",
      appointmentModel: map['call_details']['call_type'].toString(),
      speciality: map['consultant_details']["specality"],
    );
  }

  @override
  void initState() {
    super.initState();
    _expandableController = ExpandableController(
      initialExpanded: true,
    );
    _expandableController.addListener(() {
      if (this.mounted) {
        setState(() {
          expanded = _expandableController.expanded;
        });
      }
    });
    getData();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DashboardTile(
          icon: FontAwesomeIcons.history,
          text: 'Loading ' + AppTexts.teleConDashboardHistory + '...',
          color: AppColors.history,
          trailing: CircularProgressIndicator(),
          onTap: () {},
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          color: AppColors.bgColorTab,
          //ignore: missing_required_param
          child: ExpandablePanel(
            controller: _expandableController,
            theme: ExpandableThemeData(
                hasIcon: false, animationDuration: Duration(milliseconds: 100)),
            header: DashboardTile(
              icon: FontAwesomeIcons.history,
              text: "Consultation History",
              color: AppColors.history,
              trailing: expanded
                  ? Icon(Icons.keyboard_arrow_up)
                  : Icon(Icons.keyboard_arrow_down),
              onTap: () {
                _expandableController.toggle();
              },
            ),
            expanded: (history.length == 0 || hashistory == false)
                ? Center(
                    child: Container(
                    child: Text(
                      "No History!",
                      style: TextStyle(
                        fontSize: ScUtil().setSp(18),
                      ),
                    ),
                  ))
                : loading == true
                    ? CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: history.map((e) {
                            return getItem(e, history.indexOf(e));
                          }).toList(),
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
