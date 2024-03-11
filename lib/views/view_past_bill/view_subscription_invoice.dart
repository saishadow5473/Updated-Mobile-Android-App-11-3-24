import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' as material;

//import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/main.dart';
import 'package:ihl/views/teleconsultation/pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/invoice.dart';

var consultantNameFromHistory;
String duration;
var classStartTime;
var consultationFeesFromHistory;
var modeOfPaymentFromHistory;
var userFirstNameFromHistory;
var userLastNameFromHistory;
var userEmailFromHistory;
var userContactFromHistory;
String dd, mm, yyyy, time;
String appointmentOn;
String appointmentOnPdfSave;
var subsId;
var startDate;
bool clickedFromPastInvoiceAppointments = false;
var baseFare;
var cGst;
var sGst;
var iGst;
var finalPrice;
bool discount;
double _totalPrice, baseFaretemp;
String address, discountPrice;
String pincode;
String area;
String state;
String city;
var invoiceNumber;

getDataFromHistory(currentSubscription) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  invoiceNumber = prefs.getString('invoice');
  // clickedFromPastInvoiceAppointments =
  //     prefs.getBool("clickedFromPastInvoiceAppointments");

  // consultantNameFromHistory = prefs.getString("consultantNameFromHistory");
  duration = currentSubscription[0]['course_duration'];
  classStartTime = currentSubscription[0]['course_time'];
  // prefs.getString("appointmentStartTimeFromHistory");
  // appointmentEndTimeFromHistory =
  //     prefs.getString("appointmentEndTimeFromHistory");
  _totalPrice = currentSubscription[0]['course_fees'].toDouble();

  consultationFeesFromHistory = currentSubscription[0]['course_fees'];
  // prefs.getString("consultationFeesFromHistory");
  // modeOfPaymentFromHistory = prefs.getString("modeOfPaymentFromHistory");

  userFirstNameFromHistory = prefs.getString("userFirstNameFromHistory");
  userLastNameFromHistory = prefs.getString("userLastNameFromHistory");
  userEmailFromHistory = prefs.getString("userEmailFromHistory");
  userContactFromHistory = prefs.getString("userContactFromHistory");
  subsId = prefs.getString("subsIdFromHistory");
  //
  // consultationFeesFromHistory = 500;//////////////////////////////////////////pl
  consultationFeesFromHistory = discount
      ? consultationFeesFromHistory - double.parse(discountPrice)
      : consultationFeesFromHistory;
  baseFaretemp = consultationFeesFromHistory / 1.18;
  double cGsttemp = baseFaretemp * 9 / 100;
  double sGsttemp = baseFaretemp * 9 / 100;
  double iGsttemp = baseFaretemp * 18 / 100;
  double finalPricetemp = baseFaretemp + iGsttemp;
  baseFare = double.parse(baseFaretemp.toString()).toStringAsFixed(2);
  sGst = double.parse(sGsttemp.toString()).toStringAsFixed(2);
  cGst = double.parse(cGsttemp.toString()).toStringAsFixed(2);
  iGst = double.parse(iGsttemp.toString()).toStringAsFixed(2);
  finalPrice = double.parse(finalPricetemp.toString()).toStringAsFixed(2);
  address = prefs.getString("useraddressFromHistory");
  area = prefs.getString("userareaFromHistory");
  city = prefs.getString("usercityFromHistory");
  state = prefs.getString("userstateFromHistory");
  pincode = prefs.getString("userpincodeFromHistory");

  startDate = duration.substring(0, 10);
  print(startDate);
  dd = duration.substring(9, 11);
  mm = duration.substring(6, 7);
  yyyy = duration.substring(0, 3);
  time = classStartTime.substring(0, 8);
  appointmentOn = dd + "/" + mm + "/" + yyyy;
  appointmentOnPdfSave = dd + "-" + mm + "-" + yyyy;
}

subscriptionBillView(context, title, provider, currentSubscription, invoiceNo,
    {Invoice invoiceModel}) async {
  var ctx = context;
  invoiceNumber = invoiceNo;
  if (invoiceModel != null && invoiceModel.discount != '') {
    discount = true;
    discountPrice = invoiceModel.discount;
  } else {
    discount = false;
  }
  // appointmentStartTimeFromHistory = duration;
  getDataFromHistory(currentSubscription);

  final Document pdf = Document();
  final DateTime now = DateTime.now();
  String date = now.day.toString() + "/" + now.month.toString() + "/" + now.year.toString();
  const imageProvider = const material.AssetImage('assets/images/ihl-plus.png');
  final image = await flutterImageProvider(imageProvider);

  pdf.addPage(Page(
      theme: ThemeData.withFont(
        base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
      ),
      pageFormat: PdfPageFormat.a4,
      build: (Context context) {
        return Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Align(
              alignment: Alignment.topLeft,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
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
                                Text("LINK", style: TextStyle(color: PdfColor.fromInt(0xff2768a9))),
                              ])
                        ])),
                    Padding(
                      padding: EdgeInsets.only(left: 70.0),
                      child: Center(
                          child: Row(children: [
                        Text("India Health Link", style: TextStyle(fontSize: 6.0)),
                        Padding(
                          padding: EdgeInsets.only(left: 160),
                          child: Text(date, style: TextStyle(fontSize: 12.0)),
                        ),
                      ])),
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
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              Text("Email : info@indiahealthlink.com"),
            ]),
          ),
          Padding(
            padding: EdgeInsets.only(left: 265.0, bottom: 5.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              Text("Web : ${API.updatedIHLurl}"),
            ]),
          ),
          Padding(
            padding: EdgeInsets.only(left: 265.0, bottom: 5.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              Text("Address : SCO #394, New Gain Market"),
            ]),
          ),
          Padding(
            padding: EdgeInsets.only(left: 265.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
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
          Divider(thickness: 0.5, color: PdfColors.grey300, indent: 3.0, endIndent: 1.0),
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
                // Padding(
                //   padding: EdgeInsets.only(left: 50.0),
                //   child: RichText(
                //     text: TextSpan(
                //       children: [
                //         TextSpan(
                //           text: 'Date: ',
                //           style: TextStyle(
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         TextSpan(
                //           text: appointmentOn,
                //           style: TextStyle(),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
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
                invoiceNumber != null && invoiceNumber != ''
                    ? Padding(
                        padding: EdgeInsets.only(left: 50.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Invoice Number: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: invoiceNumber.toString(),
                                style: TextStyle(),
                              ),
                            ],
                          ),
                        ),
                      )
                    :
                    //     : Container(),
                    invoiceNumber == null || invoiceNumber == ''
                        ? Padding(
                            padding: EdgeInsets.only(left: 50.0),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Invoice Number: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'N/A',
                                    style: TextStyle(),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
              ]),
              TableRow(children: [
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
                        text: address.toString() + ' ,',
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
                          text: 'Orgnization: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: provider.toString(),
                          style: TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              TableRow(children: [
                Text(
                  "${area.toString()}" + ', ' + "${city.toString()}",
                  style: TextStyle(),
                ),
              ]),
              // TableRow(children: [
              //   Text(
              //     "${city.toString()}",
              //     style: TextStyle(),
              //   ),
              // ]),
              TableRow(children: [
                Text(
                  "${state.toString()}" + ', ' + "${pincode.toString()}",
                  style: TextStyle(),
                ),
              ]),
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
                  SizedBox(width: 25.0),
                  Padding(
                    padding: EdgeInsets.only(left: 155.0),
                    child: Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
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

//new
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              width: material.MediaQuery.of(ctx).size.width * (0.59),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$title "),
                  SizedBox(height: 4),
                  Text("Date : " '$date'),
                ],
              ),
            ),
            // Spacer(),
            Container(
              margin: EdgeInsets.only(left: 30),
              width: material.MediaQuery.of(ctx).size.width * (0.4),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    discount
                        ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('Subscription fee'),
                            Text(' ₹ ${_totalPrice.toStringAsFixed(2)}')
                          ])
                        : Container(),
                    discount ? SizedBox(height: 4.0) : Container(),
                    discount
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text('Coupon'), Text('- ₹ $discountPrice')])
                        : Container(),
                    discount ? SizedBox(height: 4.0) : Container(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Net Amount '),
                      Text(' ₹ ${baseFaretemp.toStringAsFixed(2)}')
                    ]),
                    SizedBox(height: 4.0),
                    state == "Haryana" || state == "haryana"
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Tax: CGST  9% "),
                              // SizedBox(width: 10.0),
                              Text(" ₹ " + cGst.toString()),
                              // SizedBox(width: 15.0),
                            ],
                          )
                        : SizedBox(height: 0, width: 0),
                    state == "Haryana" || state == "haryana"
                        ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                            Text("Tax: SGST  9%"),
                            // SizedBox(width: 10.0),
                            Text(" ₹ " + sGst.toString()),
                            // SizedBox(width: 15.0),
                          ])
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Tax: IGST  18%"),
                              // SizedBox(width: 10.0),
                              Text(" ₹ " + iGst.toString()),
                              // SizedBox(width: 15.0),
                            ],
                          ),
                    SizedBox(height: 4),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Total '), Text(' ₹ ' + finalPrice.toString())]),
                    SizedBox(height: 4.0),
                  ]),
            ),
            SizedBox(
                width: material.MediaQuery.of(ctx).size.width *
                    (0.00000000000000000000000000000000000000000000000000000000001))
          ]),

          Divider(thickness: 0.5, color: PdfColors.grey300),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[Text("Note- This is an electronic receipt")]),
          SizedBox(height: 340.0),
          Align(
              alignment: Alignment.bottomLeft,
              child: Row(children: <Widget>[
                Text("${API.updatedIHLurl}/myappointment", style: TextStyle(fontSize: 6)),
              ]))
        ]));
      }));

  String fileName = subsId + "_" + appointmentOnPdfSave + " " + time;

  Directory internalDirectory;
  String dir;
  if (Platform.isAndroid) {
    List<Directory> downloadsDirectory =
        await getExternalStorageDirectories(type: StorageDirectory.downloads); //docments
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
  prefs.setString("pathFromSubscriptionBillView", path);

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
          payload:
              jsonEncode({'file': fileName + '.pdf', 'path': path, 'channelKey': 'bill_progress'}),
        );
      } else {
        await flutterLocalNotificationsPlugin.show(
          1,
          'Downloading file in progress ($simulatedStep of $maxStep)',
          fileName + '.pdf',
          bill_progress,
          payload:
              jsonEncode({'file': fileName + '.pdf', 'path': path, 'channelKey': 'bill_progress'}),
        );
        // await AwesomeNotifications().createNotification(
        //   content: NotificationContent(
        //       id: 1,
        //       channelKey: 'bill_progress',
        //       title:
        //           'Downloading file in progress ($simulatedStep of $maxStep)',
        //       body: fileName + '.pdf',
        //       payload: {'file': fileName + '.pdf', 'path': path},
        //       notificationLayout: NotificationLayout.ProgressBar,
        //       progress: min((simulatedStep / maxStep * 100).round(), 100),
        //       locked: true),
        // );
      }
    });
  }

  material.Navigator.of(context).push(
    material.MaterialPageRoute(
      builder: (_) => PdfViewerPage(path: path),
    ),
  );
}
