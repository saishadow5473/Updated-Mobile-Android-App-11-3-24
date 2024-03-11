import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' as material;
// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import 'package:ihl/main.dart';
import 'package:ihl/views/teleconsultation/pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
var diagnosis;
var advice;
var age, mobilenummber;
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

getGenixDataFromHistorySummary(bmi, weight) async {
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
  diagnosis = prefs.getString("diagnosisFromHistorySummary");
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

genixPrescription(
    {context,
    showPdfNotification,
    allergies,
    appointmentId,
    mobilenummber,
    prescriptionNotes,
    prescription,
    bmi,
    weight,
    rmpid,
    notes,
    consultantSignature,
    genixDaignosis,
    genixRadiology,
    kisokCheckinHistory,
    genixLabTest,
    genixLabNotes,
    footer,
    consultantAddress,
    logoUrl,
    specality,
    allergy}) async {
  var ctx = context;
  getGenixDataFromHistorySummary(bmi, weight);
  final Document pdf = Document();

  // var imgprovdr =  material.NetworkImage(logoUrl.toString());
  // print('===========>>>>>>>>>>>>...'+logoUrl);
  var image;
  // try {
  //   if (logoUrl
  //       .toString()
  //       .contains('https://indiahealthlink.com/affiliate_logo/ihl-plus.png')) {
  //     logoUrl = logoUrl.toString().replaceAll(
  //         'https://indiahealthlink.com/affiliate_logo/ihl-plus.png',
  //         'https://dashboard.indiahealthlink.com/affiliate_logo/ihl-plus.png');
  //   }
  //   imageProvider = logoUrl != null && logoUrl != ''
  //       ? material.NetworkImage(logoUrl.toString())
  //       : material.AssetImage('assets/images/ihl-plus.png');
  // } catch (e) {
  //   print(e.toString());
  //   imageProvider = material.AssetImage('assets/images/ihl-plus.png');
  // }
  // final image = await flutterImageProvider(imageProvider);
  if (logoUrl != null) {
    try {
      image = await flutterImageProvider(logoUrl.image);
    } catch (e) {
      image = material.AssetImage('assets/images/ihl-plus.png');
    }
  } else {
    image = material.AssetImage('assets/images/ihl-plus.png');
  }

  // const signatureImageProvider =
  //     const material.AssetImage('assets/images/signature.PNG');
  // final signatureImage = await flutterImageProvider(signatureImageProvider);

  var signatureImage;

  try {
    signatureImage = consultantSignature != null && consultantSignature != ''
        ? await flutterImageProvider(consultantSignature.image)
        : null;
  } catch (e) {
    signatureImage = null;
    print(e);
  }
  // var signatureImage;
  // if(consultantSignature != null && consultantSignature != ''){
  //    signatureImage = flutterImageProvider(consultantSignature.image);
  // }
  const rxImageProvider = const material.AssetImage('assets/images/rx.PNG');
  final rximage = await flutterImageProvider(rxImageProvider);

  ihlText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("INDIA", style: TextStyle(color: PdfColor.fromInt(0xff2768a9))),
        Text("HEALTH", style: TextStyle(color: PdfColors.grey)),
        Text("LINK", style: TextStyle(color: PdfColor.fromInt(0xff2768a9))),
      ],
    );
  }

  verticalDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 3.0, right: 3.0),
      child: Container(
        width: 0.2,
        height: 40,
        color: PdfColors.grey300,
      ),
    );
  }

  logoWidget() {
    if (logoUrl != null && logoUrl != '') {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Image(image, width: 80.0, height: 70.0),
        SizedBox(width: 30),
        // verticalDivider(),
        // ihlText(),
      ]);
    } else {
      return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Image(image, width: 40.0, height: 40.0),
        verticalDivider(),
        ihlText(),
      ]);
    }
  }

  precriptionTextWithDT() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(width: 120),
      Spacer(),
      Text(
        "Prescription", // "Consultant/Doctor\nInstruction",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        textAlign: TextAlign.center,
      ),
      Spacer(),
      Text('$appointmentOn  $time'),
    ]);
  }

  vitalTable({value, type, unit, status, k, index}) {
    if (value != null && value != 'N/A') {
      return TableRow(children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            unit != null && unit != 'N/A'
                ? '$type :' + '   $value' + ' $unit'
                : '$type :' + '   $value',
            // '$index' + '. Bmi} :',
          ),
        )
        // Text(
        //   unit != null && unit != 'N/A'
        //       ? '   $value' + '$unit'
        //       : '   $value', //?? "N/A",
        //   // style: TextStyle(color: CardColors.textColor, height: 0),
        // ),
        // Text('Cell 3'),
      ]);
    }
  }

  diagnosisTestTable({name, notes, index}) {
    if (name != null && name != 'N/A' && index == 2) {
      return TableRow(children: [
        Padding(
            padding: EdgeInsets.all(8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('name'), Text('notes')])),
      ]);
    }
    if (name != null && name != 'N/A') {
      return TableRow(children: [
        Padding(
            padding: EdgeInsets.all(8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: name.length > 13 ? 130 : 100,
                    child: Center(
                      child: Text('$name'),
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: name.length > 13 ? 150 : 180,
                    child: Center(
                      child: Text(notes != null && notes != 'N/A' ? '$notes' : 'N/A'),
                    ),
                  ),
                ])

            // Text(
            //   notes != null && notes != 'N/A' ? '$name :'+' ' + ' $name':' $notes',
            //   // '$index' + '. Bmi} :',
            //
            // ),
            )
        // Text(
        //   unit != null && unit != 'N/A'
        //       ? '   $value' + '$unit'
        //       : '   $value', //?? "N/A",
        //   // style: TextStyle(color: CardColors.textColor, height: 0),
        // ),
        // Text('Cell 3'),
      ]);
    }
  }

  medicineTable({name, frequency, days, direction, index}) {
    if (name != null && name != 'N/A') {
      return TableRow(children: [
        Padding(
            padding: EdgeInsets.all(8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    child: Center(
                      child: Text('$name'),
                    ),
                  ),
                  Container(
                    width: 60,
                    child: Center(
                      child: Text('$frequency'),
                    ),
                  ),
                  Container(
                    width: 40,
                    child: Center(
                      child: Text('$days'),
                    ),
                  ),
                  Container(
                    width: 80,
                    child: Center(
                      child: Text('$direction'),
                    ),
                  ),
                ])

            // Text(
            //   notes != null && notes != 'N/A' ? '$name :'+' ' + ' $name':' $notes',
            //   // '$index' + '. Bmi} :',
            //
            // ),
            )
        // Text(
        //   unit != null && unit != 'N/A'
        //       ? '   $value' + '$unit'
        //       : '   $value', //?? "N/A",
        //   // style: TextStyle(color: CardColors.textColor, height: 0),
        // ),
        // Text('Cell 3'),
      ]);
    }
  }

  oldDocInfo() {
    return Column(children: [
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
        height: 1.0, //10
      ),
      Divider(thickness: 1.0, color: PdfColors.grey300, height: 0, indent: 3.0, endIndent: 1.0),
      SizedBox(
        height: 6.0, //10
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
                    text: consultantMobileFromHistory != "N/A" && consultantMobileFromHistory != ''
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
                    text: consultantEmailFromHistory != "N/A" && consultantEmailFromHistory != ''
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

            // consultantAddress!=''&&consultantAddress!=null?Container(
            //     width: 160,
            //     child: RichText(
            //   text: TextSpan(
            //     children: [
            //       TextSpan(
            //         text: 'Address : ',
            //         style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       TextSpan(
            //         text: consultantAddress,
            //         style: TextStyle(
            //           // fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ],
            //   ),
            // )):Container(height: 0,width: 0),
          ]),
      SizedBox(height: 8.0),
    ]);
  }

  newDocInfo() {
    return Column(children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.start, //spaceBetween
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(consultantNameFromHistory, style: TextStyle(fontWeight: FontWeight.bold)),

              ///mobile no commented for now.... bcz we dont' wanna show doc personal mobile on prescription
              // SizedBox(height: 4),
              // RichText(
              //   text: TextSpan(
              //     children: [
              //       TextSpan(
              //         text: consultantMobileFromHistory != "N/A" &&
              //                 consultantMobileFromHistory != ''
              //             ? 'Mobile Number :- '
              //             : '',
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       TextSpan(
              //         text: consultantMobileFromHistory != "N/A" &&
              //                 consultantMobileFromHistory != ''
              //             ? '$consultantMobileFromHistory'
              //             : '',
              //         style: TextStyle(),
              //       ),
              //     ],
              //   ),
              // ),
              ///email commented for now.... bcz we dont' wanna show doc personal email on prescription
              // SizedBox(height: 4),
              // RichText(
              //   text: TextSpan(
              //     children: [
              //       TextSpan(
              //         text: consultantEmailFromHistory != '' &&
              //                 consultantEmailFromHistory != "N/A"
              //             ? 'Email :- '
              //             : '',
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       TextSpan(
              //         text: consultantEmailFromHistory != '' &&
              //                 consultantEmailFromHistory != "N/A"
              //             ? '$consultantEmailFromHistory'
              //             : '',
              //         style: TextStyle(),
              //       ),
              //     ],
              //   ),
              // ),

              Text(
                specality,
              ),
            ]),
          ]),
    ]);
  }

  TableRow _patientTableRow({String first, second, third, fourth, bool semi}) {
    return TableRow(children: [
      Text(first, style: TextStyle(fontWeight: FontWeight.bold)),
      Text(' : ' + second),
      Text(third, style: TextStyle(fontWeight: FontWeight.bold)),
      semi ? Text(' : ' + fourth) : SizedBox.shrink(),
    ]);
  }

  _newPatientInfo() {
    return Table(defaultVerticalAlignment: TableCellVerticalAlignment.middle, columnWidths: {
      0: FlexColumnWidth(2.5),
      1: FlexColumnWidth(5),
      2: FlexColumnWidth(2),
      3: FlexColumnWidth(5),
    }, children: [
      _patientTableRow(
          first: 'Patient Name',
          second: userFirstNameFromHistory + " " + userLastNameFromHistory,
          third: 'Mobile No',
          fourth: mobilenummber,
          semi: true),
      _patientTableRow(
          first: 'Age & Sex',
          second: '$age years & $gender',
          third: 'Date/Time',
          fourth: '$appointmentOn  $time',
          semi: true),
    ]);
  }

  Widget _newVitalTable(ctx) {
    var size = material.MediaQuery.of(context).size;
    final double itemHeight = size.height / 0.7;
    final double itemWidth = size.width / 2;
    return GridView(
        crossAxisCount: 4,
        childAspectRatio: (itemWidth / itemHeight),
        children: kisokCheckinHistory.map<Widget>((e) {
          String vi;
          if (e['value'].toString().contains('.0/')) {
            vi = e['value'].replaceAll('.0', '');
          } else if (e['type'] == 'Test Time') {
            vi = e['value'];
          } else {
            double v = double.parse(e['value']);
            vi = v.round().toString();
          }

          return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              height: 15,
              width: 50,
              child: Text(
                  e['type']
                      .toString()
                      .replaceAll('Temperature', 'Temp')
                      .replaceAll('Blood Pressure', 'BP')
                      .replaceAll('Test Time', 'Date'),
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 15,
              width: 90,
              child: Text(
                  " : $vi ${e['unit'].toString().replaceAll('N/A', '').replaceAll('mmHg', '')}"),
            ),
          ]);
        }).toList());
  }

  Widget _headingContainer(String title) => Container(
      color: PdfColors.grey300,
      height: 20,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      child: Text('$title : ', style: TextStyle(fontWeight: FontWeight.bold)));
  patientInfo() {
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
                      text: 'Patient Name :- ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: userFirstNameFromHistory + " " + userLastNameFromHistory,
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
                      text: age != '' && age != "N/A" ? ' $age years & ' : '',
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
                      text: userEmailFromHistory != '' && userEmailFromHistory != "N/A"
                          ? 'Email :- '
                          : '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: userEmailFromHistory != '' && userEmailFromHistory != "N/A"
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
                      text: 'Consultation Date & Time :- ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '$appointmentOn  $time',
                      style: TextStyle(),
                    ),
                  ],
                ),
              ),
            ]),
          ]),
    ]);
  }

  rmpAndId() {
    return Column(children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.start, //spaceBetween
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rmpid != null && rmpid != '' ? 'Rmp Id :- ' : "Rmp Id :- ",
            ),
            Text(
              rmpid != null && rmpid != '' ? '$rmpid' : 'rm61-8b6b3-4bba36c8bf37',
            ),
            SizedBox(height: 4),
          ])
    ]);
  }

  oldtestandNotes() {
    return Column(children: [
      ///heading of Daignosis Test(Radiology+lab)
      //     genixRadiology != "N/A" && genixRadiology.length > 0? Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      genixLabTest.length > 0 || genixRadiology.length > 0
          ? Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Diagnosis Tests ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ])
          : Container(),
      SizedBox(height: 1.0),
      genixRadiology != "N/A" && genixRadiology.length > 0
          ? Divider(thickness: 1.0, color: PdfColors.grey300, height: 0)
          : Container(),

      // SizedBox(height: 3),
      // Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Container(
      //         width: material.MediaQuery.of(ctx).size.width * (.45),
      //         child: Text(
      //           'Prescribed Test',
      //           style: TextStyle(
      //             fontWeight: FontWeight.bold,
      //           ),
      //         ),
      //       ),
      //       // Container(
      //       //   width: material.MediaQuery.of(ctx).size.width * (.30),
      //       //   child: Center(
      //       //     child: Text(
      //       //       'Prescribed Date',
      //       //       textAlign: TextAlign.center,
      //       //       style: TextStyle(
      //       //         fontWeight: FontWeight.bold,
      //       //       ),
      //       //     ),
      //       //   ),
      //       // ),
      //       Container(
      //         width: material.MediaQuery.of(ctx).size.width * (.55),
      //         child: Center(
      //           child: Text(
      //             'Prescribed Test Notes',
      //             textAlign: TextAlign.center,
      //             style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //         ),
      //       ),
      //     ]),
      // SizedBox(height: 3),
      // Divider(thickness: 1.0, color: PdfColors.grey300,height: 0),
      SizedBox(height: 6),
      //details of radiology test and lab test
      ListView.builder(
        itemCount: genixRadiology != "N/A" && genixRadiology.length > 0 ? genixRadiology.length : 0,
        itemBuilder: (context, int index) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // color : AppColor.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 1),
                  // width: material.MediaQuery.of(ctx).size.width *
                  //     (.45),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. Name : ' + genixRadiology[index]['test_name'].toString(),
                          // textAlign: TextAlign.left
                        ),
                      ]),
                ),
                // Container(
                //   padding: EdgeInsets.symmetric(vertical: 10),
                //   width: material.MediaQuery.of(ctx).size.width *
                //       (.30),
                //   child: Center(
                //     child: Text(
                //       genixRadiology[index]['test_prescribed_on'].toString(),
                //       textAlign: TextAlign.center,
                //       style: TextStyle(
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 1),
                  // width: material.MediaQuery.of(ctx).size.width *
                  //     (.55),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // 'Notes : ' +
                        '    ' + genixRadiology[index]['radiology_note'].toString(),
                        // textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                Divider(thickness: 1.0, color: PdfColors.grey50, height: 2),
              ]);
        },
      ),
      ListView.builder(
          //itemCount: genixLabTest.length,
          itemCount: genixLabTest != "N/A" && genixLabTest.length > 0 ? genixLabTest.length : 0,
          itemBuilder: (context, index) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    // color : AppColor.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 1),
                    // width: material.MediaQuery.of(ctx).size.width *
                    //     (.45),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${genixRadiology.length + index + 1}. Name : ' +
                                genixLabTest[index]['test_name'].toString(),
                            // 'Bogli amgBogli gg Tablet 0.2mg ',
                            // style: TextStyle(
                            // style: TextStyle(
                            //   fontWeight: FontWeight.bold,
                            // ),
                            // textAlign: TextAlign.left
                          ),
                        ]),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    // width: material.MediaQuery.of(ctx).size.width *
                    //     (.55),
                    child: Text(
                      genixLabNotes != null && genixLabNotes.toString() != '[]'
                          ? // 'Notes : '+
                          '    ' + genixLabNotes.toString()
                          : 'N/A',
                    ),
                  ),
                  Divider(thickness: 1.0, color: PdfColors.grey50, height: 2),
                ]);
          }),
    ]);
  }

  oldMed() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          width: material.MediaQuery.of(ctx).size.width * (.40),
          child: Text(
            'Medicine',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: material.MediaQuery.of(ctx).size.width * (.20),
          child: Center(
            child: Text(
              'Frequency',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(
          width: material.MediaQuery.of(ctx).size.width * (.015),
        ),
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
        Container(
          width: material.MediaQuery.of(ctx).size.width * (.10),
          child: Center(
            child: Text(
              ' Days',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // SizedBox(width: 5),
        Container(
          width: material.MediaQuery.of(ctx).size.width * (.29),
          child: Center(
            child: Text(
              'Direction of use',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ]),
      SizedBox(height: 3),
      Divider(thickness: 1.0, color: PdfColors.grey300, height: 0),
      SizedBox(height: 6),
      ListView.builder(
        itemCount: prescription != "N/A" && prescription.length > 0 ? prescription.length : 0,
        itemBuilder: (context, int index) {
          return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              // color : AppColor.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 4),
              width: material.MediaQuery.of(ctx).size.width * (.43),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prescription[index]['drug_name'].toString(),
                        // 'Bogli amgBogli gg Tablet 0.2mg ',
                        // style: TextStyle(
                        //   fontWeight: FontWeight.bold,
                        // ),
                        textAlign: TextAlign.left),
                  ]),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 4),
              width: material.MediaQuery.of(ctx).size.width * (.20),
              child: Center(
                child: Text(
                  prescription[index]['SIG'].toString(),
                  textAlign: TextAlign.center,
                  // style: TextStyle(
                  //   fontWeight: FontWeight.bold,
                  // ),
                ),
              ),
            ),
            SizedBox(
              width: material.MediaQuery.of(ctx).size.width * (.015),
            ),
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
            Container(
              padding: EdgeInsets.symmetric(vertical: 4),
              width: material.MediaQuery.of(ctx).size.width * (.10),
              child: Center(
                child: Text(
                  prescription[index]['days'].toString(),
                  // '3',
                  // style: TextStyle(
                  //   fontWeight: FontWeight.bold,
                  // ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 4),
              width: material.MediaQuery.of(ctx).size.width * (.26),
              child: Center(
                child: Text(
                  prescription[index]['direction_of_use'] != null &&
                          prescription[index]['direction_of_use'] != ''
                      ? prescription[index]['direction_of_use'].toString()
                      : "N/A",
                  // 'After Food or Before sentence character Food After  Charachter',
                  // style: TextStyle(
                  //   fontWeight: FontWeight.bold,
                  // ),
                ),
              ),
            ),
          ]);
        },
      ),
      SizedBox(height: 8),
    ]);
  }

  pdf.addPage(MultiPage(
      theme: ThemeData.withFont(
        base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
      ),
      pageFormat: PdfPageFormat.a4,
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      footer: (ctx) => footer != null
          ? Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Divider(thickness: 1.0, borderStyle: BorderStyle(pattern: [5, 7])),
              Center(
                child: Text(footer['Description'], style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Center(child: Text(footer['line1'])),
              Center(child: Text(footer['line2']))
            ])
          : SizedBox.shrink(),
      build: (Context context) {
        return [
          Partitions(children: [
            Partition(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                    logoWidget(),
                    // precriptionTextWithDT(),
                  ]),
                  SizedBox(height: 10.0),
                  newDocInfo(),
                  rmpAndId(),
                  SizedBox(height: 12.0, child: Divider(color: PdfColors.black)),
                  Table(defaultVerticalAlignment: TableCellVerticalAlignment.middle, columnWidths: {
                    0: FlexColumnWidth(2.5),
                    1: FlexColumnWidth(7),
                    2: FlexColumnWidth(2.9),
                    3: FlexColumnWidth(2),
                  }, children: [
                    _patientTableRow(
                        first: 'Appointment ID',
                        second: appointmentId,
                        third: '',
                        fourth: '',
                        semi: false),
                  ]),
                  // patientInfo(),
                  _newPatientInfo(),
                  SizedBox(
                    height: 5,
                  ),
                  kisokCheckinHistory != null &&
                          kisokCheckinHistory.length > 0 &&
                          kisokCheckinHistory != 'N/A'
                      ? _headingContainer('Vitals ')
                      : SizedBox.shrink(),
                  SizedBox(height: 3),

                  kisokCheckinHistory != null &&
                          kisokCheckinHistory.length > 0 &&
                          kisokCheckinHistory != 'N/A'
                      ? _newVitalTable(context)
                      : SizedBox.shrink(),
                  SizedBox(height: 5),
                  _headingContainer('CHIEF COMPLAINTS'),
                  SizedBox(height: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text(reasonForVisit != null ? reasonForVisit : ''),
                  ]),
                  SizedBox(height: 5),
                  genixLabTest != null && genixLabTest.length > 0
                      ? _headingContainer('Diagnostic Lab Test')
                      : SizedBox.shrink(),
                  SizedBox(height: 5),

                  genixLabTest != null && genixLabTest != "[]" && genixLabTest.length > 0
                      ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Table(
                              children: genixLabTest.map<TableRow>((e) {
                                return TableRow(
                                  children: [
                                    e['test_name'] == null
                                        ? Text("")
                                        : Text(
                                            e['test_name'].toString().replaceAll('N/A', ''),
                                          ),
                                  ],
                                );
                              }).toList(),
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              columnWidths: {
                                0: FlexColumnWidth(4),
                              },
                              tableWidth: TableWidth.max),
                          SizedBox(height: 5),
                          RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              text: 'Remarks :- ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: genixLabTest[0]['lab_note'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ])
                      : SizedBox.shrink(),
                  SizedBox(height: 5),
                  genixRadiology != "[]" && genixRadiology.length > 0
                      ? _headingContainer('Radiology')
                      : SizedBox.shrink(),
                  SizedBox(height: 5),
                  genixRadiology != "[]" && genixRadiology.length > 0
                      ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Table(
                              children: genixRadiology.map<TableRow>((e) {
                                return TableRow(
                                  children: [
                                    e['test_name'] == null
                                        ? Text("")
                                        : Text(
                                            e['test_name'].toString().replaceAll('N/A', ''),
                                          ),
                                  ],
                                );
                              }).toList(),
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              columnWidths: {
                                0: FlexColumnWidth(4),
                              },
                              tableWidth: TableWidth.max),
                          SizedBox(height: 5),
                          RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              text: 'Remarks :- ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: genixRadiology[0]['radiology_note'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ])
                      : SizedBox.shrink(),
                  SizedBox(height: 5),
                  // prescription.length > 0
                  //     ? Row(
                  //         mainAxisAlignment: MainAxisAlignment.start,
                  //         children: [
                  //             Image(
                  //               rximage,
                  //               width: 42.0,
                  //               height: 44.0,
                  //               alignment: Alignment.bottomCenter,
                  //               fit: BoxFit.cover,
                  //             ),
                  //             SizedBox(width: 15),
                  //             Text('Medicines Prescribed',
                  //                 style:
                  //                     TextStyle(fontWeight: FontWeight.bold)),
                  //           ])
                  //     : SizedBox.shrink(),dia
                  prescription.length > 0
                      ? Column(children: [
                          Row(children: [
                            Image(
                              rximage,
                              width: 42.0,
                              height: 44.0,
                              alignment: Alignment.bottomCenter,
                              fit: BoxFit.cover,
                            )
                          ]),
                          SizedBox(height: 5),
                          _headingContainer('Medicine Advised')
                        ])
                      : SizedBox.shrink(),
                  SizedBox(height: 3),
                  Table(
                    columnWidths: {
                      0: FixedColumnWidth(0.5),
                      1: FixedColumnWidth(4),
                      2: FixedColumnWidth(2),
                      3: FixedColumnWidth(2),
                      4: FixedColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        children: [
                          SizedBox(width: 2),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                            child: Text('Medicine Name ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                            child:
                                Text('Frequency ', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                            child: Text('Direction of Use ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                            child: Text('Days ', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Table(
                      border: TableBorder.all(color: PdfColors.black),
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      columnWidths: {
                        0: FixedColumnWidth(0.5),
                        1: FixedColumnWidth(4),
                        2: FixedColumnWidth(2),
                        3: FixedColumnWidth(2),
                        4: FixedColumnWidth(1),
                      },
                      children: prescription.map<TableRow>((e) {
                        if (e['direction_of_use'].toString() == "") {
                          e['direction_of_use'] = "N/A";
                        }
                        return TableRow(children: [
                          Center(child: Text('${prescription.indexOf(e) + 1}')),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                              child: Text(
                                e['drug_name'].toString(),
                              )),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                              child: Text(
                                e['SIG'].toString().replaceAll('N/A', ''),
                              )),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                              child: Text(
                                e['direction_of_use'].toString(),
                              )),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                              child: Text(
                                e['days'].toString().replaceAll('N/A', ''),
                              )),
                        ]);
                      }).toList()),
                  SizedBox(height: 5),
                  RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      text: 'Remarks :- ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: prescriptionNotes,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  allergies != null && allergies.length > 0
                      ? _headingContainer('Allergy')
                      : SizedBox.shrink(),
                  SizedBox(height: 5),
                  allergies != null && allergies.length > 0
                      ? Table(
                          children: allergies.map<TableRow>((e) {
                            return TableRow(
                              children: [
                                Text(
                                  e['alergy'].toString().replaceAll('N/A', ''),
                                ),
                              ],
                            );
                          }).toList(),
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          columnWidths: {
                            0: FlexColumnWidth(4),
                          },
                          tableWidth: TableWidth.max)
                      : SizedBox.shrink(),
                  SizedBox(height: 5),

                  notes != null && notes.length > 0
                      ? _headingContainer('Advise')
                      : SizedBox.shrink(),

                  SizedBox(height: 3),
                  if (notes != null && notes.length > 0)
                    Column(children: [
                      Column(
                          children: notes
                              .map<Widget>(
                                (e) => Wrap(children: [
                                  Container(
                                      padding: EdgeInsets.all(0),
                                      child: Text(
                                        notes != null && notes.length > 0 ? e.toString() : '',
                                        textAlign: TextAlign.left,
                                      ))
                                ]),
                              )
                              .toList())
                    ]),
                  SizedBox(height: 10),
                  SizedBox(
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        // Image(consultantSignature, width: 50, height: 50),
                        consultantSignature != null && signatureImage != null
                            ? Container(
                                width: 80,
                                height: 50,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fitWidth,
                                    image: signatureImage,
                                  ),
                                ),
                              )
                            : Container(
                                // child: Text('Signature Not Available'),//empty container if signature not available
                                ),
                        SizedBox(width: 40)
                      ]),
                      consultantSignature != null && signatureImage != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [Text('Signature'), SizedBox(width: 60)])
                          : Container(),
                      SizedBox(height: 8),
                      consultantNameFromHistory != '' && consultantNameFromHistory != null
                          ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                              Container(
                                  width: 160,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: consultantNameFromHistory ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                            ])
                          : SizedBox(height: 0, width: 0),
                    ]),
                  ),
                  SizedBox(height: 10),
                  // genixLabTest.length > 0
                  //     ? Container(
                  //         margin: EdgeInsets.all(10),
                  //         padding: EdgeInsets.all(7),
                  //         decoration: BoxDecoration(
                  //           color: PdfColors.white,
                  //           border:
                  //               Border.all(width: 0.5, color: PdfColors.black),
                  //         ),
                  //         child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Table(
                  //                   children: [
                  //                     TableRow(
                  //                       children: [
                  //                         Text('Lab Test Name',
                  //                             style: TextStyle(
                  //                                 fontWeight: FontWeight.bold)),
                  //                       ],
                  //                     )
                  //                   ],
                  //                   defaultVerticalAlignment:
                  //                       TableCellVerticalAlignment.full,
                  //                   columnWidths: {
                  //                     0: FlexColumnWidth(4),
                  //                   },
                  //                   tableWidth: TableWidth.min),
                  //               SizedBox(height: 8, child: Divider()),
                  //               Table(
                  //                   children: genixLabTest.map<TableRow>((e) {
                  //                     return TableRow(
                  //                       children: [
                  //                         Text(
                  //                           e['test_name']
                  //                               .toString()
                  //                               .replaceAll('N/A', ''),
                  //                         ),
                  //                       ],
                  //                     );
                  //                   }).toList(),
                  //                   defaultVerticalAlignment:
                  //                       TableCellVerticalAlignment.middle,
                  //                   columnWidths: {
                  //                     0: FlexColumnWidth(4),
                  //                   },
                  //                   tableWidth: TableWidth.max),
                  //               Divider(color: PdfColors.grey500),
                  //               RichText(
                  //                 textAlign: TextAlign.left,
                  //                 text: TextSpan(
                  //                   text: 'Notes :- ',
                  //                   style: TextStyle(
                  //                     fontWeight: FontWeight.bold,
                  //                   ),
                  //                   children: [
                  //                     TextSpan(
                  //                       text: genixLabTest[0]['lab_note'],
                  //                       style: TextStyle(
                  //                         fontWeight: FontWeight.normal,
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               )
                  //             ]),
                  //       )
                  //     : SizedBox.shrink()
                  // Container(
                  //   width: 320,
                  //   color: PdfColors.white,
                  //   // padding: EdgeInsets.all(20.0),
                  //   child: Column(children: [
                  //     genixDaignosis.length > 0
                  //         ? Table(
                  //             border: TableBorder.all(color: PdfColors.black),
                  //             children: [
                  //                 TableRow(children: [
                  //                   Padding(
                  //                       padding: EdgeInsets.all(8),
                  //                       child: Row(
                  //                           mainAxisAlignment:
                  //                               MainAxisAlignment.start,
                  //                           children: [
                  //                             Container(
                  //                               width: 100,
                  //                               child: Center(
                  //                                 child: Text('Diagnosis Name'),
                  //                               ),
                  //                             ),
                  //                             SizedBox(width: 20),
                  //                             Container(
                  //                               width: 180,
                  //                               child: Center(
                  //                                 child:
                  //                                     Text('Diagnosis Notes'),
                  //                               ),
                  //                             ),
                  //                           ]))
                  //                 ])
                  //               ])
                  //         : Container(),
                  //     Table(
                  //       border: TableBorder.all(color: PdfColors.black),
                  //       children: genixDaignosis
                  //           .map<TableRow>(
                  //             (e) => diagnosisTestTable(
                  //               name: e['diagnosis_name'].toString(),
                  //               notes: e['diagnosis_note'].toString(),
                  //               index: 1, // genixDaignosis.indexOf(e),
                  //             ),
                  //           )
                  //           .toList(),
                  //     ),
                  //   ]),
                  // ),
//20

                  // Container(
                  //   width: 320,
                  //   color: PdfColors.white,
                  //   // padding: EdgeInsets.all(20.0),
                  //   child: Column(children: [
                  //     Table(
                  //         border: TableBorder.all(color: PdfColors.black),
                  //         children: [
                  //           genixRadiology.length > 0 || genixLabTest.length > 0
                  //               ? TableRow(children: [
                  //                   Padding(
                  //                       padding: EdgeInsets.all(8),
                  //                       child: Row(
                  //                           mainAxisAlignment:
                  //                               MainAxisAlignment.start,
                  //                           children: [
                  //                             Container(
                  //                               width: 100,
                  //                               child: Center(
                  //                                 child: Text('Test Name'),
                  //                               ),
                  //                             ),
                  //                             SizedBox(width: 20),
                  //                             Container(
                  //                               width: 180,
                  //                               child: Center(
                  //                                 child: Text('Lab Notes'),
                  //                               ),
                  //                             ),
                  //                           ]))
                  //                 ])
                  //               : TableRow(children: [SizedBox(height: 0)]),
                  //         ]),
                  //     Table(
                  //       border: TableBorder.all(color: PdfColors.black),
                  //       children: genixRadiology
                  //           .map<TableRow>(
                  //             (e) => diagnosisTestTable(
                  //               name: e['test_name'].toString(),
                  //               notes: e['radiology_note'].toString(),
                  //               index: 1, // genixDaignosis.indexOf(e),
                  //             ),
                  //           )
                  //           .toList(),
                  //     ),
                  //     Table(
                  //       border: TableBorder.all(color: PdfColors.black),
                  //       children: genixLabTest
                  //           .map<TableRow>(
                  //             (e) => diagnosisTestTable(
                  //               name: e['test_name'].toString(),
                  //               notes: genixLabNotes != null &&
                  //                       genixLabNotes.toString() != '[]'
                  //                   ? // 'Notes : '+
                  //                   '    ' + genixLabNotes.toString()
                  //                   : 'N/A',
                  //               index: 1, // genixDaignosis.indexOf(e),
                  //             ),
                  //           )
                  //           .toList(),
                  //     ),
                  //   ]),
                  // ),

                  ///medicine

                  //row if rx image

                  // genixRadiology.length > 0
                  //     ? Container(
                  //         margin: EdgeInsets.all(10),
                  //         padding: EdgeInsets.all(7),
                  //         decoration: BoxDecoration(
                  //           color: PdfColors.white,
                  //           border:
                  //               Border.all(width: 0.5, color: PdfColors.black),
                  //         ),
                  //         child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Table(
                  //                   children: [
                  //                     TableRow(
                  //                       children: [
                  //                         Text('Radiology Test Name',
                  //                             style: TextStyle(
                  //                                 fontWeight: FontWeight.bold)),
                  //                       ],
                  //                     )
                  //                   ],
                  //                   defaultVerticalAlignment:
                  //                       TableCellVerticalAlignment.full,
                  //                   columnWidths: {
                  //                     0: FlexColumnWidth(4),
                  //                   },
                  //                   tableWidth: TableWidth.min),
                  //               SizedBox(height: 8, child: Divider()),
                  //               Table(
                  //                   children: genixRadiology.map<TableRow>((e) {
                  //                     return TableRow(
                  //                       children: [
                  //                         Text(
                  //                           e['test_name']
                  //                               .toString()
                  //                               .replaceAll('N/A', ''),
                  //                         ),
                  //                       ],
                  //                     );
                  //                   }).toList(),
                  //                   defaultVerticalAlignment:
                  //                       TableCellVerticalAlignment.middle,
                  //                   columnWidths: {
                  //                     0: FlexColumnWidth(4),
                  //                   },
                  //                   tableWidth: TableWidth.max),
                  //               Divider(color: PdfColors.grey500),
                  //               RichText(
                  //                 textAlign: TextAlign.left,
                  //                 text: TextSpan(
                  //                   text: 'Notes :- ',
                  //                   style: TextStyle(
                  //                     fontWeight: FontWeight.bold,
                  //                   ),
                  //                   children: [
                  //                     TextSpan(
                  //                       text: genixRadiology[0]
                  //                           ['radiology_note'],
                  //                       style: TextStyle(
                  //                         fontWeight: FontWeight.normal,
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               )
                  //             ]),
                  //       )
                  //     : SizedBox.shrink(),
                  // SizedBox(height: 15),

                  // prescription.length > 0
                  //     ? Row(
                  //         mainAxisAlignment: MainAxisAlignment.start,
                  //         children: [
                  //             Image(
                  //               rximage,
                  //               width: 42.0,
                  //               height: 44.0,
                  //               alignment: Alignment.bottomCenter,
                  //               fit: BoxFit.cover,
                  //             ),
                  //             SizedBox(width: 15),
                  //             Text('Medicines Prescribed',
                  //                 style:
                  //                     TextStyle(fontWeight: FontWeight.bold)),
                  //           ])
                  //     : SizedBox.shrink(),

                  // prescription.length > 0
                  //     ? Container(
                  //         margin: EdgeInsets.all(10),
                  //         padding: EdgeInsets.all(7),
                  //         decoration: BoxDecoration(
                  //           color: PdfColors.white,
                  //           border:
                  //               Border.all(width: 0.5, color: PdfColors.black),
                  //         ),
                  //         child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Table(
                  //                   children: [
                  //                     TableRow(
                  //                       children: [
                  //                         Text('Medicine Name',
                  //                             style: TextStyle(
                  //                                 fontWeight: FontWeight.bold)),
                  //                         Text('Frequency',
                  //                             style: TextStyle(
                  //                                 fontWeight: FontWeight.bold)),
                  //                         Text('Direction of Use',
                  //                             style: TextStyle(
                  //                                 fontWeight: FontWeight.bold)),
                  //                         Text('Days',
                  //                             style: TextStyle(
                  //                                 fontWeight: FontWeight.bold)),
                  //                       ],
                  //                     )
                  //                   ],
                  //                   defaultVerticalAlignment:
                  //                       TableCellVerticalAlignment.full,
                  //                   columnWidths: {
                  //                     0: FlexColumnWidth(5),
                  //                     1: FlexColumnWidth(2),
                  //                     2: FlexColumnWidth(2),
                  //                     3: FlexColumnWidth(1),
                  //                   },
                  //                   tableWidth: TableWidth.min),
                  //               SizedBox(height: 8, child: Divider()),
                  //               Table(
                  //                   children: prescription.map<TableRow>((e) {
                  //                     return TableRow(
                  //                       verticalAlignment:
                  //                           TableCellVerticalAlignment.middle,
                  //                       children: [
                  //                         Text(
                  //                           e['drug_name']
                  //                               .toString()
                  //                               .replaceAll('N/A', ''),
                  //                         ),
                  //                         Text(
                  //                           e['SIG']
                  //                               .toString()
                  //                               .replaceAll('N/A', ''),
                  //                         ),
                  //                         Text(
                  //                           e['direction_of_use']
                  //                               .toString()
                  //                               .replaceAll('N/A', ''),
                  //                         ),
                  //                         Text(
                  //                           e['days']
                  //                               .toString()
                  //                               .replaceAll('N/A', ''),
                  //                         ),
                  //                       ],
                  //                     );
                  //                   }).toList(),
                  //                   defaultVerticalAlignment:
                  //                       TableCellVerticalAlignment.middle,
                  //                   columnWidths: {
                  //                     0: FlexColumnWidth(5),
                  //                     1: FlexColumnWidth(2),
                  //                     2: FlexColumnWidth(2),
                  //                     3: FlexColumnWidth(1),
                  //                   },
                  //                   tableWidth: TableWidth.max),
                  //               Divider(color: PdfColors.grey500),
                  //               prescriptionNotes == null ||
                  //                       prescriptionNotes == 'N/A'
                  //                   ? SizedBox.shrink()
                  //                   : RichText(
                  //                       textAlign: TextAlign.left,
                  //                       text: TextSpan(
                  //                         text: 'Notes :- ',
                  //                         style: TextStyle(
                  //                           fontWeight: FontWeight.bold,
                  //                         ),
                  //                         children: [
                  //                           TextSpan(
                  //                             text: prescriptionNotes,
                  //                             style: TextStyle(
                  //                               fontWeight: FontWeight.normal,
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     )
                  //             ]),
                  //       )
                  //     : SizedBox.shrink(),

                  // Divider(thickness: 1.0, color: PdfColors.grey300, height: 0),

                  // Container(
                  //
                  //   color: PdfColors.white,
                  //   // padding: EdgeInsets.all(20.0),
                  //   child: Column(children: [
                  //     Table(
                  //         border: TableBorder.all(color: PdfColors.black),
                  //         children: [
                  //           TableRow(children: [
                  //             Padding(
                  //                 padding: EdgeInsets.all(8),
                  //                 child: Row(
                  //                     mainAxisAlignment:
                  //                         MainAxisAlignment.start,
                  //                     crossAxisAlignment:
                  //                         CrossAxisAlignment.start,
                  //                     children: [
                  //                       Container(
                  //                         width: 120,
                  //                         child: Center(
                  //                           child: Text('Medicine Name    '),
                  //                         ),
                  //                       ),
                  //                       Container(
                  //                         width: 60,
                  //                         child: Center(
                  //                           child: Text('Frequency'),
                  //                         ),
                  //                       ),
                  //                       Container(
                  //                         width: 40,
                  //                         child: Center(
                  //                           child: Text('Days'),
                  //                         ),
                  //                       ),
                  //                       Container(
                  //                         width: 80,
                  //                         child: Center(
                  //                           child: Text('Direction of use'),
                  //                         ),
                  //                       ),
                  //                     ]))
                  //           ])
                  //         ]),
                  //     Table(
                  //       border: TableBorder.all(color: PdfColors.black),
                  //       children: prescription
                  //           .map<TableRow>(
                  //             (e) => medicineTable(
                  //               name: e['drug_name'].toString(),
                  //               frequency: e['SIG'].toString(),
                  //               days: e['days'].toString(),
                  //               direction: e['direction_of_use'].toString(),
                  //               index: 1, // genixDaignosis.indexOf(e),
                  //             ),
                  //           )
                  //           .toList(),
                  //     ),
                  //   ]),
                  // ),

                  // Divider(thickness: 1.0, color: PdfColors.grey300,height: 0),
                  // SizedBox(height: 8),
                ])),
          ]),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Note: This prescription is generated on a teleconsultation')]),
        ];
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
          await flutterLocalNotificationsPlugin.show(
            1,
            'Download finished',
            fileName + '.pdf',
            prescription_progress,
            payload: jsonEncode(
                {'file': fileName + '.pdf', 'path': path, 'channelKey': 'prescription_progress'}),
          );
          // await AwesomeNotifications().createNotification(
          //     content: NotificationContent(
          //         id: 1,
          //         channelKey: 'prescription_progress',
          //         title: 'Download finished',
          //         body: fileName + '.pdf',
          //         payload: {'file': fileName + '.pdf', 'path': path},
          //         locked: false));
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
