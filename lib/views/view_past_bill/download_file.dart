import 'dart:io';
import 'package:flutter/services.dart';
import 'package:ihl/constants/api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart' as material;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

var consultantNameFromHistory;
String appointmentStartTimeFromHistory;
var appointmentEndTimeFromHistory;
var consultationFeesFromHistory;
var modeOfPaymentFromHistory;
var userFirstNameFromHistory;
var userLastNameFromHistory;
var userEmailFromHistory;
var userContactFromHistory;
String dd, mm, yyyy, time;
String appointmentOn;
String appointmentOnPdfSave;
var appointId;

getDataFromHistory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  consultantNameFromHistory = prefs.getString("consultantNameFromHistory");
  appointmentStartTimeFromHistory =
      prefs.getString("appointmentStartTimeFromHistory");
  appointmentEndTimeFromHistory =
      prefs.getString("appointmentEndTimeFromHistory");
  consultationFeesFromHistory = prefs.getString("consultationFeesFromHistory");
  modeOfPaymentFromHistory = prefs.getString("modeOfPaymentFromHistory");
  userFirstNameFromHistory = prefs.getString("userFirstNameFromHistory");
  userLastNameFromHistory = prefs.getString("userLastNameFromHistory");
  userEmailFromHistory = prefs.getString("userEmailFromHistory");
  userContactFromHistory = prefs.getString("userContactFromHistory");
  appointId = prefs.getString("appointIdFromHistory");

  dd = appointmentStartTimeFromHistory.substring(8, 10);
  mm = appointmentStartTimeFromHistory.substring(5, 7);
  yyyy = appointmentStartTimeFromHistory.substring(0, 4);
  time = appointmentStartTimeFromHistory.substring(11, 19);
  appointmentOn = dd + "/" + mm + "/" + yyyy;
  appointmentOnPdfSave = dd + "-" + mm + "-" + yyyy;
}

billDownload(context) async {
  getDataFromHistory();
  final Document pdf = Document();
  final DateTime now = DateTime.now();
  String date = now.day.toString() +
      "/" +
      now.month.toString() +
      "/" +
      now.year.toString();
  const imageProvider = const material.AssetImage('assets/images/ihl-plus.png');
  final image = await flutterImageProvider(imageProvider);
  pdf.addPage(Page(
      theme: ThemeData.withFont(
        base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
      ),
      pageFormat: PdfPageFormat.a4,
      build: (Context context) {
        return Expanded(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: <
                    Widget>[
          Align(
              alignment: Alignment.topLeft,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(date, style: TextStyle(fontSize: 6.0)),
                    Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Image(image, width: 40.0, height: 40.0),
                              Padding(
                                  padding:
                                      EdgeInsets.only(left: 3.0, right: 3.0),
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
                                        style: TextStyle(
                                            color:
                                                PdfColor.fromInt(0xff2768a9))),
                                    Text("HEALTH",
                                        style:
                                            TextStyle(color: PdfColors.grey)),
                                    Text("LINK",
                                        style: TextStyle(
                                            color:
                                                PdfColor.fromInt(0xff2768a9))),
                                  ])
                            ])),
                    Padding(
                      padding: EdgeInsets.only(left: 70.0),
                      child: Center(
                          child: Text("India Health Link",
                              style: TextStyle(fontSize: 6.0))),
                    )
                  ])),
          Padding(
            padding: EdgeInsets.only(left: 265.0, bottom: 5.0, top: 0.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[Text("Contact : +91 80-47485152")]),
          ),
          Padding(
            padding: EdgeInsets.only(left: 265.0, bottom: 5.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text("Email : info@indiahealthlink.com"),
                ]),
          ),
          Padding(
            padding: EdgeInsets.only(left: 265.0, bottom: 5.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text("Web : ${API.updatedIHLurl}"),
                ]),
          ),
          Padding(
            padding: EdgeInsets.only(left: 265.0, bottom: 5.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text("Address : SCO #394, New Gain Market"),
                ]),
          ),
          Padding(
            padding: EdgeInsets.only(left: 265.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text("Haryana, India."),
                ]),
          ),
          SizedBox(
            height: 20.0,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text("Payment Receipt",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ))
          ]),
          Divider(
              thickness: 0.5,
              color: PdfColors.grey300,
              indent: 3.0,
              endIndent: 1.0),
          Table(
            children: [
              TableRow(children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Name: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: userFirstNameFromHistory.toString() +
                            " " +
                            userLastNameFromHistory.toString(),
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(left: 50.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Date: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: appointmentOn,
                          style: TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              TableRow(children: [
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
                        text: userContactFromHistory.toString(),
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(left: 50.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'GST Number: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '06AADCI2816A1Z7',
                          style: TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              TableRow(children: [
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
                        text: userEmailFromHistory.toString(),
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(left: 50.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Doctor Name: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: consultantNameFromHistory.toString(),
                          style: TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ])
            ],
          ),
          Divider(thickness: 0.5, color: PdfColors.grey300),
          Table(
            children: [
              TableRow(children: [
                Text('Item Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                Row(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 148.0),
                    child: Text('Payment Method',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 30.0),
                  Text("Amount",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ]),
              ]),
            ],
          ),
          Divider(thickness: 0.5, color: PdfColors.grey300),
          Expanded(
            child: Table(children: [
              TableRow(children: [
                Text("Video Consultation Fees" +
                    "\n" +
                    "Appointment on " +
                    appointmentOn +
                    ", " +
                    time +
                    "\t \t \t \t \t \t \t \t " +
                    modeOfPaymentFromHistory +
                    "\t \t \t \t \t \t \t \t \t \t\t \t \t\t \t" +
                    consultationFeesFromHistory.toString()),
              ]),
            ]),
          ),
          Divider(thickness: 0.5, color: PdfColors.grey300),
          Table(children: [
            TableRow(children: [
              Text(""),
              Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 260.0),
                      child: Text("Total "),
                    ),
                    SizedBox(width: 90.0),
                    Text(" ₹ " +
                        consultationFeesFromHistory.toString() +
                        "(includes\nall tax)")
                  ]))
            ])
          ]),
          Divider(thickness: 0.5, color: PdfColors.grey300),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[Text("Note- This is an electronic receipt")]),
          SizedBox(height: 340.0),
          Align(
              alignment: Alignment.bottomLeft,
              child: Row(children: <Widget>[
                Text("${API.updatedIHLurl}/myappointment",
                    style: TextStyle(fontSize: 6)),
              ]))
        ]));
      }));

  String fileName = appointmentOnPdfSave + " " + time;
  final String dir = (await getExternalStorageDirectory()).path;
  final String path = '$dir/' + fileName + ".pdf";
  final File file = File(path);
  await file.writeAsBytes(await pdf.save());
}
