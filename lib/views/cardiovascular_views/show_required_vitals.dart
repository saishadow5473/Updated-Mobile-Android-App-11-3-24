import 'dart:io';
import 'dart:typed_data';
// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/main.dart';
import 'package:pdf/pdf.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:ihl/views/teleconsultation/pdf_viewer.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/material.dart' as material;
import 'package:printing/printing.dart';

// requiredVitals1(context, invoiceNo, showPdfNotification) async {
//   if (showPdfNotification == true) {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString("pathFromBillView", 'path');
//
//     var maxStep = 1;
//     for (var simulatedStep = 1; simulatedStep <= maxStep + 1; simulatedStep++) {
//       await Future.delayed(Duration(seconds: 1), () async {
//         if (simulatedStep > maxStep) {
//           await AwesomeNotifications().createNotification(
//               content: NotificationContent(
//                   id: 1,
//                   channelKey: 'required_vitals_for_emp_cardio',
//                   title: 'Download finished',
//                   body: 'fileName' + '.pdf',
//                   payload: {'file': 'fileName' + '.pdf', 'path': 'path'},
//                   locked: false));
//         } else {
//           await AwesomeNotifications().createNotification(
//             content: NotificationContent(
//               id: 1,
//               channelKey: 'required_vitals_for_emp_cardio',
//               title:
//                   'Downloading file in progress ($simulatedStep of $maxStep)',
//               body: 'fileName' + '.pdf',
//               payload: {'file': 'fileName' + '.pdf', 'path': 'path'},
//               notificationLayout: NotificationLayout.ProgressBar,
//               progress: min((simulatedStep / maxStep * 100).round(), 100),
//               locked: true,
//             ),
//           );
//         }
//       });
//     }
//
//     material.Navigator.of(context).push(
//       material.MaterialPageRoute(
//         builder: (_) => PdfViewerPage(path: 'path'),
//       ),
//     );
//   }
// }

patientInfo(
    {userFirstNameFromHistory,
    userLastNameFromHistory,
    age,
    gender,
    userEmailFromHistory,
    datetime}) {
  return Column(children: [
    //doc info heading
    //     oldDocInfo(),
    ///patient info
    // Row(mainAxisAlignment: MainAxisAlignment.start, children: [
    //   Text(
    //     "PATIENT INFORMATION",
    //     style: TextStyle(
    //       fontWeight: FontWeight.bold,
    //     ),
    //     textAlign: TextAlign.center,
    //   ),
    // ]),
    // SizedBox(height: 1.0), //10
    // Divider(thickness: 1.0, color: PdfColors.grey300, height: 0),
    // SizedBox(height: 6.0), //10
    Row(
        mainAxisAlignment: MainAxisAlignment.start, //spaceBetween
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Name :- ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: userFirstNameFromHistory +
                        " " +
                        userLastNameFromHistory,
                    style: TextStyle(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: age != '' && age != "N/A" ? 'Age :- ' : '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: age != '' && age != "N/A" ? ' $age years' : '',
                    style: TextStyle(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: gender != '' && gender != "N/A" ? 'Gender :- ' : '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: gender != '' && gender != "N/A" ? ' $gender' : '',
                    style: TextStyle(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: userEmailFromHistory != '' &&
                            userEmailFromHistory != "N/A"
                        ? 'Email :- '
                        : '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: userEmailFromHistory != '' &&
                            userEmailFromHistory != "N/A"
                        ? '$userEmailFromHistory'
                        : '',
                    style: TextStyle(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Date :- ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '$datetime',
                    style: TextStyle(),
                  ),
                ],
              ),
            ),
          ]),
        ]),
  ]);
}

getDataFromSP() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = prefs.get(SPKeys.userData);
  data = data == null || data == '' ? '{"User":{}}' : data;

  Map res = jsonDecode(data);
  var firstName = res['User']['firstName'];
  firstName ??= '';
  var lastName = res['User']['lastName'];
  lastName ??= '';
  var email = res['User']['email'];
  email ??= '';
  var dob = res['User']['dateOfBirth'].toString();
  // dob = dob == 'null' ? '' : dob;
  // dob ??= '01-01-2000';
  var gender = res['User']['gender'];
  return {
    'name': '$firstName $lastName',
    'email': '$email',
    'gender': '$gender',
    'age': '23'
  };
}

requiredVitals(context, invoiceNo, showPdfNotification,
    {age, gender, email, fName, lName}) async {
  List keys = [
    'Height',
    'Weight',
    'Bmi',
    "Cholesterol",
    "Blood Pressure Systolic",
    "Blood Pressure Diastolic"
  ];
  var ctx = context;
  var invoiceNumber = invoiceNo;

  ///TODO EMPCPDF: now demo data is used , this functon will get the datA and from this we have to used in the patient info
  // var info =  await getDataFromSP();
  final Document pdf = Document();
  final DateTime now = DateTime.now();
  String date = now.day.toString() +
      "/" +
      now.month.toString() +
      "/" +
      now.year.toString();
  String forFileName = '${now.hour}' + '${now.minute}' + '${now.second}';
  const imageProvider = const material.AssetImage('assets/images/ihl-plus.png');
  final image = await flutterImageProvider(imageProvider);

  pdf.addPage(Page(
      theme: ThemeData.withFont(
        base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
      ),
      pageFormat: PdfPageFormat.a4,
      build: (Context context) {
        return Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Text(date, style: TextStyle(fontSize: 6.0)),
                        Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image(image, width: 40.0, height: 40.0),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 3.0, right: 3.0),
                                      child: Container(
                                        width: 0.2,
                                        height: 40,
                                        color: PdfColors.grey300,
                                      )),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("INDIA",
                                            style: TextStyle(
                                                color: PdfColor.fromInt(
                                                    0xff2768a9))),
                                        Text("HEALTH",
                                            style: TextStyle(
                                                color: PdfColors.grey)),
                                        Text("LINK",
                                            style: TextStyle(
                                                color: PdfColor.fromInt(
                                                    0xff2768a9))),
                                      ])
                                ])),
                        Padding(
                          padding: EdgeInsets.only(left: 70.0),
                          child: Center(
                              child: Text("India Health Link",
                                  style: TextStyle(fontSize: 6.0))),
                        )
                      ])),
              // Padding(
              //   padding: EdgeInsets.only(left: 265.0, bottom: 5.0, top: 0.0),
              //   child: Row(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: <Widget>[Text("Contact : +91 80-47485152")]),
              // ),
              // Padding(
              //   padding: EdgeInsets.only(left: 265.0, bottom: 5.0),
              //   child: Row(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: <Widget>[
              //         Text("Email : info@indiahealthlink.com"),
              //       ]),
              // ),
              // Padding(
              //   padding: EdgeInsets.only(left: 265.0, bottom: 5.0),
              //   child: Row(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: <Widget>[
              //         Text("Web : ${API.updatedIHLurl}"),
              //       ]),
              // ),
              // Padding(
              //   padding: EdgeInsets.only(left: 265.0, bottom: 5.0),
              //   child: Row(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: <Widget>[
              //         Text("Address : SCO #394, New Gain Market"),
              //       ]),
              // ),
              // Padding(
              //   padding: EdgeInsets.only(left: 265.0),
              //   child: Row(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: <Widget>[
              //         Text("Haryana, India."),
              //       ]),
              // ),
              // SizedBox(
              //   height: 20.0,
              // ),
              // Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              //   Text("Payment Receipt",
              //       style: TextStyle(
              //         fontWeight: FontWeight.bold,
              //       ))
              // ]),
              Divider(
                  thickness: 0.5,
                  color: PdfColors.grey300,
                  indent: 3.0,
                  endIndent: 1.0),
              patientInfo(
                  age: age,
                  datetime: date,
                  gender: gender,
                  userEmailFromHistory: email,
                  userFirstNameFromHistory: fName,
                  userLastNameFromHistory: lName),
              Divider(
                  thickness: 0.5,
                  color: PdfColors.grey300,
                  indent: 3.0,
                  endIndent: 1.0),
              SizedBox(height: 5),
              // Divider(thickness: 0.5, color: PdfColors.grey300),
              Table(
                children: [
                  TableRow(children: [
                    Text('Required Vitals For Test',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                  ]),
                ],
              ),
              SizedBox(height: 10.0),
              // Divider(
              //     thickness: 0.5,
              //     color: PdfColors.grey300,
              //     indent: 3.0,
              //     endIndent: 1.0),
              Container(
                width: 320,
                color: PdfColors.white,
                // padding: EdgeInsets.all(20.0),
                child: Column(children: [
                  Table(
                      border: TableBorder.all(color: PdfColors.black),
                      children: [
                        sd('Vital Name', 'Sno'),
                        // TableRow(children: [
                        //   Padding(
                        //       padding: EdgeInsets.all(8),
                        //       child: Row(
                        //           mainAxisAlignment:
                        //           MainAxisAlignment.start,
                        //           children: [
                        //             sd('Vital Name','Sno.'),
                        //             // Container(
                        //             //   color: PdfColors.redAccent,
                        //             //   width: 40,
                        //             //   child: Center(
                        //             //     child: Text('Sno.'),
                        //             //   ),
                        //             // ),
                        //             // SizedBox(width: 3),
                        //             // Container(
                        //             //   color: PdfColors.redAccent,
                        //             //   width: 180,
                        //             //   child: Center(
                        //             //     child:
                        //             //     Text('Vital Name'),
                        //             //   ),
                        //             // ),
                        //           ]))
                        // ])
                      ]),
                  Table(
                    border: TableBorder.all(color: PdfColors.black),
                    children: keys
                        .map<TableRow>(
                            (e) => sd('     $e', ' ${keys.indexOf(e) + 1}'
                                // genixDaignosis.indexOf(e),
                                ))
                        .toList(),
                  ),
                ]),
              ),

              // ListView.builder(
              //     itemCount: keys.length,
              //     itemBuilder: (context, index) {
              //       return Padding(
              //         padding: EdgeInsets.symmetric(vertical: 1),
              //         child: Row(
              //             mainAxisAlignment: MainAxisAlignment.start,
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text(
              //                 '${keys[index]}',
              //                 textAlign: TextAlign.left,
              //                 style: TextStyle(
              //                     fontSize: 14,
              //                     letterSpacing: 0.4,
              //                     fontWeight: FontWeight.normal,
              //                     color: PdfColors.black),
              //               ),
              //             ]),
              //       );
              //     }),

              Divider(thickness: 0.5, color: PdfColors.grey300),
              // Row(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: <Widget>[Text("Note- This is an electronic receipt")]),
              // SizedBox(height: 240.0),
              SizedBox(height: 4.0),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(children: <Widget>[
                    Text("${API.updatedIHLurl}/",
                        style: TextStyle(fontSize: 6)),
                  ]))
            ]));
      }));
  print(forFileName);
  String fileName = 'required' + "_" + 'vitals' + " " + 'info $forFileName';

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

  ///converting to base 64
  List<int> base = file.readAsBytesSync();
  var base64Pdf = base64.encode(base);
  print(base64Pdf);

  if (showPdfNotification == true) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("pathFromBillView", path);

    var maxStep = 1;
    for (var simulatedStep = 1; simulatedStep <= maxStep + 1; simulatedStep++) {
      await Future.delayed(Duration(seconds: 1), () async {
        if (simulatedStep > maxStep) {
          // await AwesomeNotifications().createNotification(
          //     content: NotificationContent(
          //         id: 1,
          //         channelKey: 'bill_progress',
          //         title: 'Download finished',
          //         body: fileName + '.pdf',
          //         payload: {'file': fileName + '.pdf', 'path': path},
          //         locked: false));
          await flutterLocalNotificationsPlugin.show(
            1,
            'Download finished',
            fileName + '.pdf',
            bill_progress,
            payload: jsonEncode({
              'file': fileName + '.pdf',
              'path': path,
              'channelKey': 'bill_progress'
            }),
          );
        } else {
          await flutterLocalNotificationsPlugin.show(
            1,
            'Downloading file in progress ($simulatedStep of $maxStep)',
            fileName + '.pdf',
            bill_progress,
            payload: jsonEncode({
              'file': fileName + '.pdf',
              'path': path,
              'channelKey': 'bill_progress'
            }),
          );
          // await AwesomeNotifications().createNotification(
          //   content: NotificationContent(
          //     id: 1,
          //     channelKey: 'bill_progress',
          //     title:
          //         'Downloading file in progress ($simulatedStep of $maxStep)',
          //     body: fileName + '.pdf',
          //     payload: {'file': fileName + '.pdf', 'path': path},
          //     notificationLayout: NotificationLayout.ProgressBar,
          //     progress: min((simulatedStep / maxStep * 100).round(), 100),
          //     locked: true,
          //   ),
          // );
        }
      });
    }

    // material.Navigator.of(context).push(
    //   material.MaterialPageRoute(
    //     builder: (_) => PdfViewerPage(path: path),
    //   ),
    // );
  } else {
    print(
        'dont show notification for pdf downloading , because we are calling 1mg api to send prescription');
    return base64Pdf;
  }
}

sd(name, sno) {
  return TableRow(children: [
    Padding(
        padding: EdgeInsets.all(8),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text('$sno' + '.'), SizedBox(width: 5), Text('$name')])),
  ]);
}
