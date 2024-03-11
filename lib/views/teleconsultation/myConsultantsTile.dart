import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/teleconsultation/consultantsTile.dart';
import 'package:ihl/widgets/teleconsulation/DashboardTile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyConsultants extends StatefulWidget {
  @override
  _MyConsultantsState createState() => _MyConsultantsState();
}

class _MyConsultantsState extends State<MyConsultants> {
  bool expanded = true;
  bool hasappointment = false;
  List appointment = [];
  bool loading = true;

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

  ConsultantTile getItems(Map map) {
    return ConsultantTile(
      name: map["consultant_name"],
      appointmentStartTime: map["appointment_start_time"],
      appointmentStatus: map["appointment_status"],
      isCompleted: map['appointment_status'] == "completed" ||
          map['appointment_status'] == "Completed",
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
          icon: FontAwesomeIcons.outdent,
          text: 'Loading' + "My Consultants" + '...',
          color: AppColors.history,
          trailing: CircularProgressIndicator(),
          onTap: () {},
        ),
      );
    }
    if (hasappointment == false || appointment.length == 0) {
      return Container(
        child: Column(
          children: [
            Text(
              "You have not consulted anyone yet!",
              style: TextStyle(
                fontSize: ScUtil().setSp(20),
              ),
            ),
            InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(Routes.ConsultationType, arguments: false);
                },
                child: Text("Book your first appointment here",
                    style: TextStyle(
                        fontSize: ScUtil().setSp(18),
                        color: AppColors.bookApp)))
          ],
        ),
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: appointment.map((e) {
                return getItems(e);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
