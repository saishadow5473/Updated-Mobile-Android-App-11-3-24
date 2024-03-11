import 'dart:convert';
import 'dart:io';
import 'dart:math';

// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import 'package:ihl/main.dart';
import 'package:ihl/views/teleconsultation/pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/material.dart' as material;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get_utils/get_utils.dart';

var consultantNameFromHistory;
var consultantEmailFromHistory;
var consultantMobileFromHistory;
var consultantEducationFromHistory;
var consultantDescriptionFromHistory;
var specialtyFromHistory;
String appointmentStartTimeFromHistory;
var userFirstNameFromHistory;
var userLastNameFromHistory;
var userEmailFromHistory;
var userContactFromHistory;
var reasonForVisit;
var diagnosislab;
var advice;
var age;
var gender;
var weight;
var bmi;
String address;
String pincode;
String area;
String state;
String city;

String dd, mm, yyyy, time, month;
String appointmentOn;
String appointmentOnForSave;

getGenixLabDataFromHistorySummary(bmi, weight) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  consultantNameFromHistory = prefs.getString("consultantNameFromHistorySummary");

  consultantEmailFromHistory = prefs.getString("consultantEmailFromHistorySummary");
  consultantMobileFromHistory = prefs.getString("consultantMobileFromHistorySummary");
  consultantEducationFromHistory = prefs.getString("consultantEduationFromHistorySummary");
  consultantDescriptionFromHistory = prefs.getString("consultantDescriptionFromHistorySummary");
  specialtyFromHistory = prefs.getString("specialtyFromHistorySummary");
  appointmentStartTimeFromHistory = prefs.getString("appointmentStartTimeFromHistorySummary");
  userFirstNameFromHistory = prefs.getString("userFirstNameFromHistorySummary");
  userLastNameFromHistory = prefs.getString("userLastNameFromHistorySummary");
  userEmailFromHistory = prefs.getString("userEmailFromHistorySummary");
  userContactFromHistory = prefs.getString("userContactFromHistorySummary");
  reasonForVisit = prefs.getString("reasonForVisitFromHistorySummary");
  diagnosislab = prefs.getString("diagnosisFromHistorySummary");
  advice = prefs.getString("adviceFromHistorySummary");
  age = prefs.getString("ageFromHistorySummary");
  gender = prefs.getString("genderFromHistorySummary");
  weight = weight;
  // prefs.getString('weightFromHistorySummary');
  bmi = bmi;
  // prefs.getString('bmiFromHistorySummary');
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

  //addresses
  address = prefs.getString("useraddressFromHistory");
  area = prefs.getString("userareaFromHistory");
  city = prefs.getString("usercityFromHistory");
  state = prefs.getString("userstateFromHistory");
  pincode = prefs.getString("userpincodeFromHistory");
}

genixLabOrder(context, showPdfNotification, labTestList, bmi, weight, rmpid, labNotes,
    consultantSignature) async {
  var ctx = context;
  getGenixLabDataFromHistorySummary(bmi, weight);
  final Document pdf = Document();

  const imageProvider = const material.AssetImage('assets/images/ihl-plus.png');
  final image = await flutterImageProvider(imageProvider);

  // const signatureImageProvider =
  //     const material.AssetImage('assets/images/signature.PNG');
  // final signatureImage = await flutterImageProvider(signatureImageProvider);
  var signatureImage;
  try {
    signatureImage = consultantSignature != null && consultantSignature != ''
        ? await flutterImageProvider(consultantSignature.image)
        : null;
  } catch (e) {
    print(e);
    signatureImage = null;
  }
  const rxImageProvider = const material.AssetImage('assets/images/rx.PNG');
  final rximage = await flutterImageProvider(rxImageProvider);

  pdf.addPage(MultiPage(
      theme: ThemeData.withFont(
        base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
      ),
      pageFormat: PdfPageFormat.a4,
      build: (Context context) {
        return [
          Partitions(children: [
            Partition(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
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
                            Text("INDIA", style: TextStyle(color: PdfColor.fromInt(0xff2768a9))),
                            Text("HEALTH", style: TextStyle(color: PdfColors.grey)),
                            Text("LINK", style: TextStyle(color: PdfColor.fromInt(0xff2768a9))),
                          ])
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      SizedBox(width: 120),
                      Spacer(),
                      Text(
                        "Laboratory Test", // "Consultant/Doctor\nInstruction",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      Text(appointmentOn.replaceAll('/', '-') + ' $time'),
                    ])
                  ]),
                  SizedBox(
                    height: 10.0,
                  ),

                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text(
                      "DOCTOR INFORMATION",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                  SizedBox(
                    height: 10.0,
                  ),
                  Divider(thickness: 1.0, color: PdfColors.grey300, indent: 3.0, endIndent: 1.0),
                  SizedBox(
                    height: 10.0,
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: consultantNameFromHistory,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Row(children: <Widget>[
                          Text(
                              consultantEducationFromHistory != "N/A" &&
                                      consultantEducationFromHistory != "" &&
                                      consultantEducationFromHistory != null
                                  ? consultantEducationFromHistory
                                  : '',
                              softWrap: true,
                              maxLines: 4,
                              textAlign: TextAlign.justify),
                        ]),
                        consultantEducationFromHistory != "N/A" &&
                                consultantEducationFromHistory != "" &&
                                consultantEducationFromHistory != null
                            ? SizedBox(height: 6.0)
                            : SizedBox(),
                        Row(
                          children: <Widget>[
                            Text(
                                consultantEducationFromHistory != "N/A" &&
                                        consultantEducationFromHistory != "" &&
                                        consultantEducationFromHistory != null
                                    ? consultantEducationFromHistory
                                    : '',
                                softWrap: true,
                                maxLines: 4,
                                textAlign: TextAlign.justify),
                          ],
                        ),
                        consultantEducationFromHistory != "N/A" &&
                                consultantEducationFromHistory != "" &&
                                consultantEducationFromHistory != null
                            ? SizedBox(height: 6.0)
                            : SizedBox(),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: consultantMobileFromHistory != "N/A" &&
                                        consultantMobileFromHistory != ''
                                    ? consultantMobileFromHistory
                                    : '',
                                // style: TextStyle(
                                //   fontWeight: FontWeight.bold,
                                // ),
                              ),
                              TextSpan(
                                text: consultantMobileFromHistory != "N/A" &&
                                        consultantMobileFromHistory != '' &&
                                        consultantEmailFromHistory != ''
                                    ? ' | '
                                    : '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: consultantEmailFromHistory != "N/A" &&
                                        consultantEmailFromHistory != ''
                                    ? consultantEmailFromHistory
                                    : '',
                              ),
                            ],
                          ),
                        ),
                        consultantEmailFromHistory != "N/A" &&
                                consultantEmailFromHistory != "" &&
                                consultantEmailFromHistory != null
                            ? SizedBox(height: 6.0)
                            : SizedBox(),

                        //rmp id
                        rmpid != null && rmpid != ''
                            ? Row(
                                children: <Widget>[
                                  rmpid != null && rmpid != ''
                                      ? Text('RMP ID : $rmpid',
                                          softWrap: true, maxLines: 4, textAlign: TextAlign.justify)
                                      : Container(),
                                ],
                              )
                            : Container(),
                      ]),
                  SizedBox(height: 10.0),
                  //patient info
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text(
                      "PATIENT INFORMATION",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                  SizedBox(height: 10.0),
                  Divider(thickness: 1.0, color: PdfColors.grey300),
                  SizedBox(height: 10.0),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: GetUtils.capitalizeFirst(userFirstNameFromHistory) +
                                      " " +
                                      GetUtils.capitalizeFirst(userLastNameFromHistory),
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: userContactFromHistory != '' &&
                                          userContactFromHistory != "N/A"
                                      ? 'Phone : $userContactFromHistory'
                                      : '',
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: userEmailFromHistory != '' && userEmailFromHistory != "N/A"
                                      ? 'Email: $userEmailFromHistory'
                                      : '',
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                          ),
                          //address
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Address: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: GetUtils.capitalize(address).toString() + ' ,',
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${GetUtils.capitalize(area)}" + ', ' + "${GetUtils.capitalize(city)}",
                            style: TextStyle(),
                          ),
                          Text(
                            "${GetUtils.capitalize(state)}" + ', ' + "${pincode.toString()}",
                            style: TextStyle(),
                          ),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('Age - $age years'),
                          SizedBox(height: 5),
                          Text('Gender - $gender'),
                          SizedBox(height: 5),
                          weight != null && weight != ''
                              ? Text('Weight - $weight kg')
                              : Container(),
                          weight != null && weight != '' ? SizedBox(height: 5) : Container(),
                          bmi != null && bmi != ''
                              ? Text('BMI - $bmi', textAlign: TextAlign.right)
                              : Container(),
                          bmi != null && bmi != '' ? SizedBox(height: 5) : Container(),
                        ])
                      ]),

                  SizedBox(height: 15.0),

                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'CHIEF COMPLAINTS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  SizedBox(height: 5.0),
                  Divider(thickness: 1.0, color: PdfColors.grey300),
                  SizedBox(height: 2.0),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text(reasonForVisit != null ? reasonForVisit : ''),
                  ]),
                  SizedBox(height: 10.0),
                  // Row(
                  //     // mainAxisAlignment: MainAxisAlignment.,
                  //     children: [
                  //       Image(
                  //         rximage,
                  //         width: 42.0,
                  //         height: 44.0,
                  //         alignment: Alignment.bottomCenter,
                  //         fit: BoxFit.cover,
                  //       ),
                  //     ]),

                  Divider(thickness: 1.0, color: PdfColors.grey300, height: 0),
                  SizedBox(height: 8),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Container(
                      width: material.MediaQuery.of(ctx).size.width * (.40),
                      child: Text(
                        'PRESCRIBED TESTS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Container(
                    //   width: material.MediaQuery.of(ctx).size.width * (.10),
                    //   child: Center(
                    //     child: Text(
                    //       'Frequency',
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   width:
                    //       material.MediaQuery.of(ctx).size.width * (.015),
                    // ),
                    // Container(
                    //     width: material.MediaQuery.of(ctx).size.width * (.10),
                    //     child: Center(
                    //       child: Text(
                    //         'Quantity',
                    //         style: TextStyle(
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     )),
                    // ////////@@@@@@@@@@@@@@@@@
                    //  Container(
                    //    width: material.MediaQuery.of(ctx).size.width * (.30),
                    //    child: Center(
                    //      child: Text(
                    //        '  Prescribed On',
                    //        textAlign: TextAlign.center,
                    //        style: TextStyle(
                    //          fontWeight: FontWeight.bold,
                    //        ),
                    //      ),
                    //    ),
                    //  ),
                    //  // SizedBox(width: 5),
                    //  Container(
                    //    width: material.MediaQuery.of(ctx).size.width * (.30),
                    //    child: Center(
                    //      child: Text(
                    //        'Prescribed By',
                    //        style: TextStyle(
                    //          fontWeight: FontWeight.bold,
                    //        ),
                    //      ),
                    //    ),
                    //  ),
                    //  ////////@@@@@@@@@@@@@@@@@
                  ]),

                  // SizedBox(height: 8),
                  Divider(thickness: 1.0, color: PdfColors.grey300),
                  // SizedBox(height: 8),

                  ListView.builder(
                    itemCount:
                        labTestList != "N/A" && labTestList.length > 0 ? labTestList.length : 0,
                    itemBuilder: (context, int index) {
                      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Container(
                          // color : AppColor.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 5),
                          width: material.MediaQuery.of(ctx).size.width * (.43),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "${index + 1}" +
                                        ". " +
                                        labTestList[index]['test_name'].toString(),
                                    // 'Bogli amgBogli gg Tablet 0.2mg ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left),
                              ]),
                        ),
                        // Container(
                        //   padding: EdgeInsets.symmetric(vertical: 10),
                        //   width: material.MediaQuery.of(ctx).size.width *
                        //       (.10),
                        //   child: Center(
                        //     child: Text(
                        //       prescription[index]['SIG'].toString(),
                        //       textAlign: TextAlign.center,
                        //       style: TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(
                        //   width: material.MediaQuery.of(ctx).size.width *
                        //       (.015),
                        // ),
                        //####################@@@@@@@@@@@@@@@@@@@@@@@@@@@=====================>>>>>>>>>>>>>>

                        // Container(
                        //     padding: EdgeInsets.symmetric(vertical: 5),
                        //     width:
                        //         material.MediaQuery.of(ctx).size.width * (.10),
                        //     child: Center(
                        //       child: Text(
                        //         prescription[index]['quantity'].toString(),
                        //         // '9',
                        //         style: TextStyle(
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     )),
                        // ////////@@@@@@@@@@@@@@@@@
                        // Container(
                        //   padding: EdgeInsets.symmetric(vertical: 5),
                        //   width: material.MediaQuery.of(ctx).size.width *
                        //       (.29),
                        //   child: Center(
                        //     child: Text(
                        //       labTestList[index]['test_prescribed_on'].toString(),
                        //       // '3',
                        //       style: TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // Container(
                        //   padding: EdgeInsets.symmetric(vertical: 5),
                        //   width: material.MediaQuery.of(ctx).size.width *
                        //       (.30),
                        //   child: Center(
                        //     child: Text(
                        //       labTestList[index]['prescribed_by'] !=
                        //                   null &&
                        //           labTestList[index]
                        //                       ['prescribed_by'] !=
                        //                   ''
                        //           ? labTestList[index]['prescribed_by']
                        //               .toString()
                        //           : "N/A",
                        //       // 'After Food or Before sentence character Food After  Charachter',
                        //       style: TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // ////////@@@@@@@@@@@@@@@@@
                      ]);
                    },
                  ),
                  SizedBox(height: 8),
                  Divider(thickness: 1.0, color: PdfColors.grey300),

                  SizedBox(height: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text(
                      'Instruction',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),

                  SizedBox(height: 3),

                  Divider(thickness: 1.0, color: PdfColors.grey300),
                  Column(children: [
                    // Column(
                    //     children: prescription
                    //         .map<Widget>(
                    //           (e) =>
                    Wrap(
                      children: [
                        Container(
                            padding: EdgeInsets.all(0),
                            child: Text(
                              labNotes != null && labNotes.toString() != '[]'
                                  ? labNotes.toString()
                                  : 'N/A',
                              textAlign: TextAlign.left,
                            ))
                      ],
                    ),
                    // )
                    // .toList())
                  ]),

                  SizedBox(height: 8),
                  Divider(thickness: 1.0, color: PdfColors.grey300),

                  SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text('Signature')])
                ])),
          ]),
          Partitions(children: [
            Partition(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                // Image(consultantSignature, width: 50, height: 50),
                consultantSignature != null && signatureImage != null
                    ? Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: signatureImage,
                          ),
                        ),
                      )
                    : Container(
                        child: Text('Signature Not Available'),
                      ),
              ]),
              // SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(consultantNameFromHistory != null ? consultantNameFromHistory : ''),
                ],
              ),
              SizedBox(height: 10),
              Text('Note: This prescription is generated on a teleconsultation')
            ]))
          ]),
        ];
      }));

  String fileName = "IHL_LabTest_" + appointmentOnForSave + " " + time;
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
  List<int> base = file.readAsBytesSync();
  var base64Pdf = base64.encode(base);
  print(base64Pdf);

  if (showPdfNotification == true) {
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
            payload: jsonEncode(
                {'file': fileName + '.pdf', 'path': path, 'channelKey': 'prescription_progress'}),
          );
        } else {
          await flutterLocalNotificationsPlugin.show(
            1,
            'Downloading file in progress ($simulatedStep of $maxStep)',
            fileName + '.pdf',
            prescription_progress,
            payload: jsonEncode(
                {'file': fileName + '.pdf', 'path': path, 'channelKey': 'prescription_progress'}),
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
  } else {
    print(
        'dont show notification for pdf downloading , because we are calling 1mg api to send prescription');
    return base64Pdf;
  }
}
