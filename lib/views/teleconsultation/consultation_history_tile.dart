import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/teleconsultation/consultation_history_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';
import 'package:http/http.dart' as http;

class ConsultationHistoryTile extends StatefulWidget {
  final int index;
  final String appointmentId;
  final String name;
  final String type;
  final String speciality;
  final String date;
  final String appointmentEndTime;
  final String time;
  final String dur;
  final String reasonForVisit;
  final String consultationFees;
  final String modeOfPayment;
  final String diagnosis;
  final String adviceNotes;
  final String appointmentModel;

  final allergy;

  ConsultationHistoryTile(
      {this.index,
      this.appointmentId,
      this.speciality,
      this.reasonForVisit,
      this.date,
      this.appointmentEndTime,
      this.dur,
      this.time,
      this.name,
      this.type,
      this.diagnosis,
      this.adviceNotes,
      this.modeOfPayment,
      this.appointmentModel,
      this.consultationFees,
      this.allergy});
  @override
  _ConsultationHistoryTileState createState() =>
      _ConsultationHistoryTileState();
}

class _ConsultationHistoryTileState extends State<ConsultationHistoryTile> {
  http.Client _client = http.Client(); //3gb
  bool loading = true;
  String firstName, lastName, email, mobileNumber;
  var appointmentStatus, callStatus, appointmentDuration;
  Map consultationDetails;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userData);
    data = data == null || data == '' ? '{"User":{}}' : data;

    Map res = jsonDecode(data);
    firstName = res['User']['firstName'];
    lastName = res['User']['lastName'];
    email = res['User']['email'];
    mobileNumber = res['User']['mobileNumber'];
    appointmentDetails(widget.appointmentId);
  }

  Future appointmentDetails(String appointmentID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var authToken = prefs.get('auth_token');
    var userData = prefs.get('data');
    var decodedResponse = jsonDecode(userData);
    String iHLUserToken = decodedResponse['Token'];
    final response = await _client.get(
        Uri.parse(API.iHLUrl +
            '/consult/get_appointment_details?appointment_id=' +
            appointmentID),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': authToken,
          'Token': iHLUserToken
        });
    if (response.statusCode == 200) {
      if (response.body != '""') {
        String value = response.body;
        var lastStartIndex = 0;
        var lastEndIndex = 0;
        var reasonLastEndIndex = 0;
        var alergyLastEndIndex = 0;
        var notesLastEndIndex = 0;
        var reasonForVisit = [];
        for (int i = 0; i < value.length; i++) {
          if (value.contains("reason_for_visit")) {
            var start = ";appointment_id";
            var end = "vendor_appointment_id";
            var startIndex = value.indexOf(start, lastStartIndex);
            var endIndex = value.indexOf(end, lastEndIndex);
            lastStartIndex = value.indexOf(start, startIndex) + start.length;
            lastEndIndex = value.indexOf(end, endIndex) + end.length;
            String a = value.substring(startIndex + start.length, endIndex);
            var parseda1 = a.replaceAll('&quot', '');
            var parseda2 = parseda1.replaceAll(';:;', '');
            var parseda3 = parseda2.replaceAll(';,;', '');

            //reason
            var reasonStart = "reason_for_visit";
            var reasonEnd = ";notes";
            var reasonStartIndex = value.indexOf(
              reasonStart,
            );
            var reasonEndIndex = value.indexOf(reasonEnd, reasonLastEndIndex);
            reasonLastEndIndex =
                value.indexOf(reasonEnd, reasonLastEndIndex) + reasonEnd.length;
            String b = value.substring(
                reasonStartIndex + reasonStart.length, reasonEndIndex);
            var parsedb1 = b.replaceAll('&quot', '');
            var parsedb2 = parsedb1.replaceAll(';:;', '');
            var parsedb3 = parsedb2.replaceAll(';,', '');
            var temp1 = value.substring(0, reasonStartIndex);
            var temp2 = value.substring(reasonEndIndex, value.length);
            value = temp1 + temp2;
//alergy
            var alergyStart = "alergy";
            var alergyEnd = "appointment_start_time";
            var alergyStartIndex = value.indexOf(alergyStart);
            var alergyEndIndex = value.indexOf(alergyEnd, alergyLastEndIndex);
            alergyLastEndIndex = alergyEndIndex + alergyEnd.length;
            String c = value.substring(
                alergyStartIndex + alergyStart.length, alergyEndIndex);
            var parsedc1 = c.replaceAll('&quot;', '');
            var parsedc2 = parsedc1.replaceAll(':', '');
            var parsedc3 = parsedc2.replaceAll(',', '');
            temp1 = value.substring(0, alergyStartIndex);
            temp2 = value.substring(alergyEndIndex, value.length);
            value = temp1 + temp2;

//notes
            var notesStart = ";notes";
            var notesEnd = ";kiosk_checkin_history";
            var notesStartIndex = value.indexOf(notesStart);
            var notesEndIndex = value.indexOf(notesEnd, notesLastEndIndex);
            notesLastEndIndex = notesEndIndex + notesEnd.length;
            String d = value.substring(
                notesStartIndex + notesStart.length, notesEndIndex);
            var parsedd1 = d.replaceAll('&quot;', '');
            var parsedd2 = parsedd1.replaceAll(':', '');
            var parsedd3 = parsedd2.replaceAll(',', '');
            var parsedd4 = parsedd3.replaceAll('&quot', '');
            var parsedd5 = parsedd4.replaceAll('[{', '');
            var parsedd6 = parsedd5.replaceAll('\\', '');
            var parsedd7 = parsedd6.replaceAll('}]', '');
            var parsedd8 = parsedd7.replaceAll('}', '');
            var parsedd9 = parsedd8.replaceAll('{', '');
            var parsedd10 = parsedd9.replaceAll('&#39;', '');
            var parsedd11 = parsedd10.replaceAll('[', '');
            var parsedd12 = parsedd11.replaceAll(']', '');
            temp1 = value.substring(0, notesStartIndex);
            temp2 = value.substring(notesEndIndex, value.length);
            value = temp1 + temp2;

            Map<String, String> app = {};
            app['appointment_id'] = parseda3;
            app['reason_for_visit'] = parsedb3;
            app["alergy"] = parsedc3;
            app["notes"] = parsedd12;
            reasonForVisit.add(app);
          } else {
            i = value.length;
          }
        }

        var parsedString = value.replaceAll('&quot', '"');
        var parsedString2 = parsedString.replaceAll("\\\\\\", "");
        var parsedString3 = parsedString2.replaceAll("\\", "");
        var parsedString4 = parsedString3.replaceAll(";", "");
        var parsedString5 = parsedString4.replaceAll('""', '"');
        var parsedString6 = parsedString5.replaceAll('"[', '[');
        var parsedString7 = parsedString6.replaceAll(']"', ']');
        var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
        var pasrseString9 = pasrseString8.replaceAll('"{', '{');
        var pasrseString10 = pasrseString9.replaceAll('}"', '}');
        var pasrseString11 = pasrseString10.replaceAll('}"', '}');
        var pasrseString12 = pasrseString11.replaceAll(':",', ':"",');
        var parseString13 = pasrseString12.replaceAll(':"}', ':""}');
        var finalOutput = parseString13.replaceAll('/"', '/');
        Map details = json.decode(finalOutput);
        for (int i = 0; i < reasonForVisit.length; i++) {
          details['message']['reason_for_visit'] =
              reasonForVisit[i]['reason_for_visit'];
          details['message']['alergy'] = reasonForVisit[i]['alergy'];
          details['message']['notes'] = reasonForVisit[i]['notes'];
          //  print(details['message']['reason_for_visit']);
          //  print(details['message']['alergy']);
        }
        if (this.mounted) {
          setState(() {
            loading = false;
            consultationDetails = details;
            appointmentStatus = consultationDetails["message"]
                        ["appointment_status"]
                    .toString() ??
                "N/A";
            appointmentDuration = consultationDetails["message"]
                        ["appointment_duration"]
                    .toString() ??
                "N/A";
            callStatus = consultationDetails["message"]["call_status"] != null
                ? consultationDetails["message"]["call_status"].toString()
                : "N/A" ?? "N/A";
          });
        }
      } else {
        consultationDetails = {};
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      if (widget.index == 0) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return Container();
    }
    return Card(
      color: AppColors.cardColor,
      elevation: 1,
      child: InkWell(
        splashColor: AppColors.history.withOpacity(0.5),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ConsultationHistorySummary(
                        appointmentId: widget.appointmentId,
                        // consultantName: widget.name,
                        // speciality: widget.speciality,
                        // appointmentStartTime: widget.date,
                        // appointmentEndTime: widget.appointmentEndTime,
                        // consultationFees: widget.consultationFees,
                        // modeOfPayment: widget.modeOfPayment,
                        // appointmentModel: widget.appointmentModel,
                        // diagnosis: widget.diagnosis,
                        // reasonOfVisit: widget.reasonForVisit,
                        // adviceNotes: widget.adviceNotes,
                        // allergy: widget.allergy,
                      )));
        },
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                FontAwesomeIcons.video,
                color: AppColors.startConsult,
              ),
              title: Text(
                camelize(widget.name ?? 'Consultant'),
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 3.0,
                  ),
                  Text("Specialty: " + widget.type),
                  SizedBox(
                    height: 3.0,
                  ),
                  Text("Timing: " + widget.date ?? 'N/A'),
                  SizedBox(
                    height: 3.0,
                  ),
                  Text("Appointment: " + camelize(appointmentStatus)),
                  SizedBox(
                    height: 3.0,
                  ),
                  Text("Call Status: " + camelize(callStatus))
                ],
              ),
              trailing: Icon(
                Icons.info,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
