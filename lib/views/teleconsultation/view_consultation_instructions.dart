import 'dart:convert';
import 'dart:io';
import 'dart:math';
//import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import 'package:ihl/main.dart';
import 'package:ihl/views/teleconsultation/pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/material.dart' as material;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

var consultantNameFromHistory;
var specialtyFromHistory;
String appointmentStartTimeFromHistory;
var userFirstNameFromHistory;
var userLastNameFromHistory;
var userEmailFromHistory;
var userContactFromHistory;
var reasonForVisit;
var diagnosis;
var advice;
var age;
var gender;
String dd, mm, yyyy, time, month;
String appointmentOn;
String appointmentOnForSave;

getDataFromHistorySummary() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  consultantNameFromHistory =
      prefs.getString("consultantNameFromHistorySummary");
  specialtyFromHistory = prefs.getString("specialtyFromHistorySummary");
  appointmentStartTimeFromHistory =
      prefs.getString("appointmentStartTimeFromHistorySummary");
  userFirstNameFromHistory = prefs.getString("userFirstNameFromHistorySummary");
  userLastNameFromHistory = prefs.getString("userLastNameFromHistorySummary");
  userEmailFromHistory = prefs.getString("userEmailFromHistorySummary");
  userContactFromHistory = prefs.getString("userContactFromHistorySummary");
  reasonForVisit = prefs.getString("reasonForVisitFromHistorySummary");
  diagnosis = prefs.getString("diagnosisFromHistorySummary");
  advice = prefs.getString("adviceFromHistorySummary");
  age = prefs.getString("ageFromHistorySummary");
  gender = prefs.getString("genderFromHistorySummary");
  dd = appointmentStartTimeFromHistory.substring(8, 10);
  mm = appointmentStartTimeFromHistory.substring(5, 7);
  switch (mm) {
    case "01":
      month = "Jan";
      break;
    case "02":
      month = "Feb";
      break;
    case "03":
      month = "March";
      break;
    case "04":
      month = "April";
      break;
    case "05":
      month = "May";
      break;
    case "06":
      month = "June";
      break;
    case "07":
      month = "July";
      break;
    case "08":
      month = "Aug";
      break;
    case "09":
      month = "Sept";
      break;
    case "10":
      month = "Oct";
      break;
    case "11":
      month = "Nov";
      break;
    case "12":
      month = "Dec";
      break;
  }
  yyyy = appointmentStartTimeFromHistory.substring(0, 4);
  time = appointmentStartTimeFromHistory.substring(11, 19);
  appointmentOn = mm + "/" + dd + "/" + yyyy;
  appointmentOnForSave = dd + "-" + month + "-" + yyyy;
}

instructionsView(context) async {
  getDataFromHistorySummary();
  final Document pdf = Document();

  const imageProvider = const material.AssetImage('assets/images/ihl-plus.png');
  final image = await flutterImageProvider(imageProvider);

  pdf.addPage(Page(
      theme: ThemeData.withFont(
        base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
      ),
      pageFormat: PdfPageFormat.a4,
      build: (Context context) {
        return Expanded(
            child: Column(children: <Widget>[
          Column(children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(width: 20.0),
              Image(image, width: 40.0, height: 40.0),
              Padding(
                  padding: EdgeInsets.only(left: 3.0, right: 3.0),
                  child: Container(
                    width: 0.2,
                    height: 40,
                    color: PdfColors.grey300,
                  )),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("INDIA",
                        style: TextStyle(color: PdfColor.fromInt(0xff2768a9))),
                    Text("HEALTH", style: TextStyle(color: PdfColors.grey)),
                    Text("LINK",
                        style: TextStyle(color: PdfColor.fromInt(0xff2768a9))),
                  ])
            ]),
            Center(
              child: Text(
                "Consultant/Doctor\nInstruction",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ]),
          SizedBox(
            height: 10.0,
          ),
          Divider(
              thickness: 1.0,
              color: PdfColors.grey300,
              indent: 3.0,
              endIndent: 1.0),
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Patient Name: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: userFirstNameFromHistory +
                            ' ' +
                            userLastNameFromHistory,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                Row(children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Gender: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: gender,
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: ', Age: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: age + ' Years old',
                        ),
                      ],
                    ),
                  ),
                ]),
                SizedBox(height: 5.0),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Phone Number: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: userContactFromHistory,
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Email: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: userEmailFromHistory,
                              style: TextStyle(),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Date & Time: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: appointmentOn + ", " + time,
                              style: TextStyle(),
                            ),
                          ],
                        ),
                      ),
                    ])
              ]),
          SizedBox(height: 10.0),
          Divider(thickness: 1.0, color: PdfColors.grey300),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Physician Name: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: consultantNameFromHistory,
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Specialty: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: specialtyFromHistory,
                        style: TextStyle(),
                      ),
                    ],
                  ),
                )
              ]),
          SizedBox(height: 10.0),
          Divider(thickness: 1.0, color: PdfColors.grey300),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Reason For Visit: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: reasonForVisit,
                        style: TextStyle(),
                      ),
                    ],
                  ),
                )
              ]),
          SizedBox(height: 10.0),
          Divider(thickness: 1.0, color: PdfColors.grey300),
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Consultation Advice Notes: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                SizedBox(height: 2.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: advice,
                              style: TextStyle(),
                            ),
                          ],
                        ),
                      ),
                    ]),
                SizedBox(height: 5.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Diagnosis: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                SizedBox(height: 2.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: diagnosis,
                              style: TextStyle(),
                            ),
                          ],
                        ),
                      ),
                    ]),
              ]),
        ]));
      }));

  String fileName = "IHL_Prescription_" + appointmentOnForSave + " " + time;

  Directory internalDirectory;
  String dir;
  if (Platform.isAndroid) {
    List<Directory> downloadsDirectory =
        await getExternalStorageDirectories(type: StorageDirectory.downloads);
    if (downloadsDirectory == null && downloadsDirectory.isEmpty) {
      internalDirectory = await getApplicationDocumentsDirectory();
    }
    dir = downloadsDirectory[0].path ?? internalDirectory.path;
  } else if (Platform.isIOS) {
    internalDirectory = await getApplicationDocumentsDirectory();
    dir = internalDirectory.path;
  }
  final String path = '$dir/' + fileName + ".pdf";
  final File file = File(path);
  await file.writeAsBytes(await pdf.save());

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("pathFromInstructions", path);

  var maxStep = 1;
  for (var simulatedStep = 1; simulatedStep <= maxStep + 1; simulatedStep++) {
    await Future.delayed(Duration(seconds: 1), () async {
      if (simulatedStep > maxStep) {
        // await AwesomeNotifications().createNotification(
        //     content: NotificationContent(
        //         id: 1,
        //         channelKey: 'prescription_progress',
        //         title: 'Download finished',
        //         body: fileName + '.pdf',
        //         payload: {'file': fileName + '.pdf', 'path': path},
        //         locked: false));
        await flutterLocalNotificationsPlugin.show(
          1,
          'Download finished',
          fileName + '.pdf',
          prescription_progress,
          payload: jsonEncode({
            'file': fileName + '.pdf',
            'path': path,
            'channelKey': 'prescription_progress'
          }),
        );
      } else {
        await flutterLocalNotificationsPlugin.show(
          1,
          'Downloading file in progress ($simulatedStep of $maxStep)',
          fileName + '.pdf',
          prescription_progress,
          payload: jsonEncode({
            'file': fileName + '.pdf',
            'path': path,
            'channelKey': 'prescription_progress'
          }),
        );
        // await AwesomeNotifications().createNotification(
        //     content: NotificationContent(
        //         id: 1,
        //         channelKey: 'prescription_progress',
        //         title:
        //             'Downloading file in progress ($simulatedStep of $maxStep)',
        //         body: fileName + '.pdf',
        //         payload: {'file': fileName + '.pdf', 'path': path},
        //         notificationLayout: NotificationLayout.ProgressBar,
        //         progress: min((simulatedStep / maxStep * 100).round(), 100),
        //         locked: true));
      }
    });
  }

  material.Navigator.of(context).push(
    material.MaterialPageRoute(
      builder: (_) => PdfViewerPage(path: path),
    ),
  );
}
