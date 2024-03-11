import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:ihl/widgets/teleconsulation/history_details2.dart';
import 'package:ihl/widgets/teleconsulation/instructions_and_prescriptions.dart';
import 'package:ihl/widgets/teleconsulation/reason_for_visit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_details1.dart';

class HistoryDetails extends StatefulWidget {
  final String name;
  final String type;
  final String speciality;
  final String date;
  final String time;
  final String dur;
  final String reasonForVisit;
  final String labTests;
  final String medication;

  const HistoryDetails(
      {Key key,
      this.name,
      this.type,
      this.speciality,
      this.date,
      this.time,
      this.dur,
      this.reasonForVisit,
      this.labTests,
      this.medication})
      : super(key: key);

  @override
  _HistoryDetailsState createState() => _HistoryDetailsState();
}

class _HistoryDetailsState extends State<HistoryDetails> {
  bool hashistory = false;
  List history = [];
  bool prescriptionPressed = false;
  ScrollController _controller = ScrollController();

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);
    Map teleConsulResponse = json.decode(data);

    if (teleConsulResponse['consultation_history'] == null ||
        !(teleConsulResponse['consultation_history'] is List) ||
        teleConsulResponse['consultation_history'].isEmpty) {
      if (this.mounted) {
        setState(() {
          hashistory = false;
        });
      }
      return;
    }
    history = teleConsulResponse['consultation_history'];

    if (this.mounted) {
      setState(() {
        hashistory = true;
      });
    }
  }

  Details1 get1(Map map) {
    return Details1(
        name: map['consultant_details']['consultant_name'].toString(),
        type: map['consultant_details']['consultant_type'].toString(),
        speciality: map['consultant_details']['specality'].toString());
  }

  Details2 get2(Map map) {
    return Details2(
      duration: map['appointment_details']["appointment_duration"],
      from: map['consultant_details']["ihl_consultant_id"],
      mode: map['consultant_details']["consultant_type"],
      dateTime: map['appointment_details']["appointment_start_time"],
      consultCharges: map['call_details']["consultation_fees"].toString(),
      paymentMode: map['call_details']["mode_of_payment"],
    );
  }

  ReasonForVisit get3(Map map) {
    return ReasonForVisit(
      reasonforVisit: map['consultant_notes']['advice_to_patient'].toString(),
    );
  }

  InstructionsAndPrescriptions get4(Map map) {
    return InstructionsAndPrescriptions(
      medicineName: map['consultant_notes']['advice_to_patient'],
      dosage: map['consultant_notes']["diagnosis"],
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollessBasicPageUI(
      appBar: Column(
        children: [
          SizedBox(
            width: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(
                color: Colors.white,
              ),
              Flexible(
                child: Center(
                  child: Text(
                    AppTexts.historyDetails,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
              )
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          controller: _controller,
          children: <Widget>[
            consultDetails1(),
            SizedBox(
              height: 10.0,
            ),
            reasonVisit(),
            SizedBox(
              height: 10.0,
            ),
            instructionsAndPrescriptions()
          ],
        ),
      ),
    );
  }

  Widget consultDetails1() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Color(0xfff4f6fa),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppTexts.historyDetails,
                  style: TextStyle(
                    color: AppColors.primaryAccentColor,
                    fontSize: 22.0,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(widget.name ?? ""),
              Text(widget.type ?? ""),
              Text(widget.speciality ?? ""),
              Text(widget.dur ?? ""),
              Text(widget.date ?? ""),
              Text(widget.time ?? ""),
            ],
          )
        ]),
      ),
    );
  }

  Widget consultDetails2() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Color(0xfff4f6fa),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppTexts.historyDetails,
                  style: TextStyle(
                    color: AppColors.primaryAccentColor,
                    fontSize: 22.0,
                  ),
                ),
              ),
            ],
          ),
          Column(
              children: history.map((e) {
            return get2(e);
          }).toList())
        ]),
      ),
    );
  }

  Widget reasonVisit() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Color(0xfff4f6fa),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Reason for Visit",
                  style: TextStyle(
                    color: AppColors.primaryAccentColor,
                    fontSize: 22.0,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(widget.reasonForVisit ?? ""),
            ],
          )
        ]),
      ),
    );
  }

  Widget instructionsAndPrescriptions() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Color(0xfff4f6fa),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Instructions & Prescriptions",
                  style: TextStyle(
                    color: AppColors.primaryAccentColor,
                    fontSize: 22.0,
                  ),
                ),
              ),
              IconButton(
                color: AppColors.primaryAccentColor,
                icon: Icon(FontAwesomeIcons.prescription),
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.PrescriptionDetails);
                  prescriptionPressed = true;
                },
              )
            ],
          ),
          Column(
            children: [],
          )
        ]),
      ),
    );
  }
}
