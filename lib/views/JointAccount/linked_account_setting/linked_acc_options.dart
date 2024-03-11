import 'dart:math';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/teleconsulation/DashboardTile.dart';
import 'package:ihl/widgets/teleconsulation/appointmentTile.dart';
import 'package:ihl/widgets/teleconsulation/exports.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LinkedAccountOptions extends StatefulWidget {
  @override
  _LinkedAccountOptionsState createState() => _LinkedAccountOptionsState();
}

class _LinkedAccountOptionsState extends State<LinkedAccountOptions> {
  http.Client _client = http.Client(); //3gb
  String iHLUserId;
  ExpandableController _expandableController;
  bool expanded = true;
  bool hasappointment = false;
  List appointment = [];
  List approvedAppointments;
  var list = [];
  bool loading = true;
  List<String> sharedReportAppIdList = [];

  Future getData() async {
    /* SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);

    Map teleConsulResponse = json.decode(data);*/

    // Commented getUserDetails API and instead getting data from SharedPreference

    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    iHLUserId = res['User']['id'];

  }

  getSharedAppIdList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sharedReportAppIdList = prefs.getStringList('sharedReportAppIdList') ?? [];
  }

//Changed to check genix in isapproved and ispending
  AppointmentTile getItem(Map map) {
    return AppointmentTile(
      ihlConsultantId: map["ihl_consultant_id"],
      name: map["consultant_name"],
      date: map["appointment_start_time"],
      endDateTime: map["appointment_end_time"],
      consultationFees: map['consultation_fees'],
      isApproved: map['appointment_status'] == "Approved" ||
          map['appointment_status'] == "Approved",
      isRejected: map['appointment_status'] == "rejected" ||
          map['appointment_status'] == "Rejected",
      isPending: map['appointment_status'] == "requested" ||
          map['appointment_status'] == "Requested",
      isCancelled: map['appointment_status'] == "canceled" ||
          map["appointment_status"] == "Canceled",
      isCompleted: map['appointment_status'] == "completed" ||
          map['appointment_status'] == "Completed",
      appointmentId: map['appointment_id'],
      callStatus: map['call_status'] ?? "N/A",
      vendorId: map['vendor_id'],
      sharedReportAppIdList: sharedReportAppIdList,
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
    getSharedAppIdList();
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
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DashboardTile(
          icon: FontAwesomeIcons.outdent,
          text: 'Loading...',
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
        child: Container(
          color: AppColors.bgColorTab,
          // child: ExpandablePanel(
          //   controller: _expandableController,
          //   theme: ExpandableThemeData(
          //       hasIcon: false, animationDuration: Duration(milliseconds: 100)),
          //   header: DashboardTile(
          //     icon: FontAwesomeIcons.outdent,
          //     text: AppTexts.myAppointmentUpcoming.toString(),
          //     color: AppColors.primaryAccentColor,
          //     trailing: expanded
          //         ? Icon(Icons.keyboard_arrow_up)
          //         : Icon(Icons.keyboard_arrow_down),
          //     onTap: () {
          //       _expandableController.toggle();
          //     },
          //   ),
          //expanded:

          child: (list.length == 0 || hasappointment == false)
              ? Column(
                  children: [
                    SizedBox(
                      height: 50.0,
                    ),
                    Center(
                      child: Text("No Upcoming Appointments!",
                          style: TextStyle(fontSize: 18.0)),
                    ),
                    SizedBox(
                      height: 50.0,
                    ),

                    /*GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushNamed(Routes.ConsultationType, arguments: false),
                        child: Center(
                          child: Text(
                              "Book an appointment, here",
                              style: TextStyle(fontSize: 18.0, color: Colors.green)),
                        ))*/
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: list.map((e) {
                      return getItem(e);
                    }).toList(),
                  ),
                ),
        ),
      ),
    );
  }
}

class MyUpcomingAppointments extends StatefulWidget {
  @override
  _MyUpcomingAppointmentsState createState() => _MyUpcomingAppointmentsState();
}

class _MyUpcomingAppointmentsState extends State<MyUpcomingAppointments> {
  ExpandableController _expandableController;
  bool expanded = true;
  bool hasappointment = false;
  List appointment = [];
  bool loading = true;
  bool randomTF() {
    Random rnd = Random();
    return rnd.nextBool();
  }

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);
    Map teleConsulResponse = json.decode(data);
    loading = false;
    if (teleConsulResponse['appointments'] == null ||
        !(teleConsulResponse['appointments'] is List) ||
        teleConsulResponse['appointments'].isEmpty) {
      if (this.mounted) {
        setState(() {
          hasappointment = false;
        });
      }
      return;
    }
    appointment = teleConsulResponse['appointments'];

    if (this.mounted) {
      setState(() {
        hasappointment = true;
      });
    }
  }

  AppointmentList getItem(Map map) {
    return AppointmentList(
      name: map["consultant_name"],
      date: map["appointment_start_time"],
      isApproved: map["appointment_status"] == "approved",
      isPending: map['appointment_status'] == "requested",
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
  }

  Widget tile() {
    return getItem(appointment[0]);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DashboardTile(
          icon: FontAwesomeIcons.outdent,
          text: 'Loading' + AppTexts.myAppointmentUpcoming + '...',
          color: AppColors.history,
          trailing: CircularProgressIndicator(),
          onTap: () {},
        ),
      );
    }
    if (hasappointment == false || appointment.length == 0) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tile(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Appointment {
  String ihlConsultantId;
  String name;
  String date;
  String endDateTime;
  String appointmentId;
  String callStatus;

  Appointment(this.ihlConsultantId, this.name, this.date, this.endDateTime,
      this.appointmentId, this.callStatus);

  @override
  String toString() {
    return '{ ${this.ihlConsultantId}, ${this.name}, ${this.date}, ${this.endDateTime}, ${this.appointmentId}, ${this.callStatus} }';
  }
}
