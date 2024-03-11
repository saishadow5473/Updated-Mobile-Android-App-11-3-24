import 'dart:convert';
import 'dart:developer';

// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import '../../constants/api.dart';
import '../../main.dart';
import 'pdf_viewer.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart';
import 'package:flutter/material.dart' as material;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../models/invoice.dart';

var consultantNameFromStages;
String appointmentStartTimeFromStages;
var appointmentEndTimeFromStages;
var consultationFeesFromStages;
var modeOfPaymentFromStages;
var userFirstNameFromStages;
var userLastNameFromStages;
var userEmailFromStages;
var userContactFromStages;
var consultationFeesFromHistory;
String dd, mm, yyyy, time;
String ddinvoice, mminvoice, yyyyinvoice, timeinvoice;
String appointmentOn;
String appointmentOnPdfSave, discountPrice;
bool discount;
double _totalPrice, baseFaretemp;

var appointId;
var invoiceNumber;
//addressss
var baseFare;
var cGst;
var sGst;
var iGst;
var finalPrice;
String address;
String pincode;
String area;
String state;
String city;

getDataFromConsultationStages() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  invoiceNumber = prefs.getString('invoice');
  consultantNameFromStages = prefs.getString("consultantNameFromStages");
  appointmentStartTimeFromStages = prefs.getString("appointmentStartTimeFromStages");
  appointmentEndTimeFromStages = prefs.getString("appointmentEndTimeFromStages");
  consultationFeesFromStages = prefs.getString("consultationFeesFromStages");
  modeOfPaymentFromStages = prefs.getString("modeOfPaymentFromStages");
  userFirstNameFromStages = prefs.getString("userFirstNameFromStages");
  userLastNameFromStages = prefs.getString("userLastNameFromStages");
  userEmailFromStages = prefs.getString("userEmailFromStages");
  userContactFromStages = prefs.getString("userContactFromStages");
  _totalPrice = double.parse(prefs.getString("consultationFeesFromStages"));

  consultationFeesFromHistory = double.parse(prefs.getString("consultationFeesFromStages"));
  DateTime comingDate;
  try {
    comingDate = DateFormat('yyyy-MM-dd hh:mm aa').parse(appointmentStartTimeFromStages);
  } catch (e) {
    //01/08/2024 08:00 AM
    comingDate = DateFormat('MM/dd/yyyy hh:mm aa').parse(appointmentStartTimeFromStages);
  } //02-23-2023 05:30 PM"
  String convertedDate = DateFormat('dd/MM/yyyy').format(comingDate);
  ddinvoice = appointmentStartTimeFromStages.substring(8, 10);
  mminvoice = appointmentStartTimeFromStages.substring(5, 7);
  yyyyinvoice = appointmentStartTimeFromStages.substring(0, 4);
  timeinvoice = appointmentStartTimeFromStages.substring(11, 19);

  // DateTime dateTimeD = DateFormat("MM/dd/yyyy hh:mm a").parse(appointmentStartTimeFromStages);
  // String comingDate = DateFormat('yyyy-MM-dd hh:mm aa').format(dateTimeD); //02-23-2023 05:30 PM"
  // String convertedDate = DateFormat('dd/MM/yyyy').format(dateTimeD);
  // dd = dateTimeD.day.toString();
  // mm = dateTimeD.month.toString();
  // yyyy = dateTimeD.year.toString();
  // time = appointmentStartTimeFromStages.substring(11, 19);
  appointmentOn = convertedDate;
  // appointmentOnPdfSave = "$ddinvoice-$mminvoice-$yyyyinvoice";
  appointmentOnPdfSave = "${comingDate.day}-${comingDate.month}-${comingDate.year}";
  // comingDate
  consultationFeesFromHistory = discount
      ? consultationFeesFromHistory - double.parse(discountPrice)
      : consultationFeesFromHistory;
  //addresss
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
}

reportView(context, invoiceNo, showPdfNotification, {Invoice invoiceModel}) async {
  var ctx = context;
  invoiceNumber = invoiceNo;
  if (invoiceModel != null && invoiceModel.discount != '') {
    discount = true;
    discountPrice = invoiceModel.discount;
  } else {
    discount = false;
  }
  getDataFromConsultationStages();
  final Document pdf = Document();
  final DateTime now = DateTime.now();
  String date = "${now.day}/${now.month}/${now.year}";
  const material.AssetImage imageProvider = material.AssetImage('assets/images/ihl-plus.png');
  final ImageProvider image = await flutterImageProvider(imageProvider);
  pdf.addPage(Page(
      theme: ThemeData.withFont(
        base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
      ),
      pageFormat: PdfPageFormat.a4,
      build: (Context context) {
        return Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 265,
                  height: 60,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Image(image, width: 40.0, height: 40.0),
                        Padding(
                            padding: const EdgeInsets.only(left: 3.0, right: 3.0),
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
                                  style: const TextStyle(color: PdfColor.fromInt(0xff2768a9))),
                              Text("HEALTH", style: const TextStyle(color: PdfColors.grey)),
                              Text("LINK",
                                  style: const TextStyle(color: PdfColor.fromInt(0xff2768a9))),
                            ])
                      ]),
                ),
                // Center(child: Text("India Health Link", style: const TextStyle(fontSize: 6.0))),
                Text(date,
                    style: const TextStyle(
                      fontSize: 9.0,
                    )),
              ]),
          SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            SizedBox(
              width: 265,
              // height: 60,
              // child: Row(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: <Widget>[
              //       Image(image, width: 40.0, height: 40.0),
              //       Padding(
              //           padding: const EdgeInsets.only(left: 3.0, right: 3.0),
              //           child: Container(
              //             width: 0.2,
              //             height: 40,
              //             color: PdfColors.grey300,
              //           )),
              //       Column(
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: <Widget>[
              //             Text("INDIA",
              //                 style: const TextStyle(color: PdfColor.fromInt(0xff2768a9))),
              //             Text("HEALTH", style: const TextStyle(color: PdfColors.grey)),
              //             Text("LINK", style: const TextStyle(color: PdfColor.fromInt(0xff2768a9))),
              //           ])
              //     ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[Text("Contact : +91 80-47485152")]),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                  Text("Email : info@indiahealthlink.com"),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                  Text("Web : ${API.updatedIHLurl}"),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                  Text("Address : SCO #394, New Gain Market"),
                ]),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                Text("Haryana, India."),
              ]),
            ]),
          ]),
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
                        text: "$userFirstNameFromStages $userLastNameFromStages",
                        style: const TextStyle(),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0),
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
                          style: const TextStyle(),
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
                        text: userContactFromStages.toString(),
                        style: const TextStyle(),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'GST Number: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: '06AADCI2816A1Z7',
                          style: TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              TableRow(
                children: [
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
                          text: userEmailFromStages.toString(),
                          style: const TextStyle(),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  invoiceNumber != null && invoiceNumber != ''
                      ? Padding(
                          padding: const EdgeInsets.only(left: 50.0),
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
                                  style: const TextStyle(),
                                ),
                              ],
                            ),
                          ),
                        )
                      :
                      //     : Container(),
                      invoiceNumber == null || invoiceNumber == ''
                          ? Padding(
                              padding: const EdgeInsets.only(left: 50.0),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Invoice Number: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: 'N/A',
                                      style: TextStyle(),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                ],
              ),
              //addressss
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
                        text: '$address ,',
                        style: const TextStyle(),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0),
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
                          text: consultantNameFromStages.toString(),
                          style: const TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),

              TableRow(children: [
                Text(
                  "${area.toString()}" ', ' "${city.toString()}",
                  style: const TextStyle(),
                ),
              ]),
              TableRow(children: [
                Text(
                  "${state.toString()}" ', ' "${pincode.toString()}",
                  style: const TextStyle(),
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
                    padding: const EdgeInsets.only(left: 155.0),
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
              width: material.MediaQuery.of(ctx).size.width * (0.599999),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Video Consultation Fees"),
                  SizedBox(height: 4),
                  Text("Appointment on $appointmentOn, $timeinvoice"),
                ],
              ),
            ),
            // Spacer(),
            Container(
              margin: const EdgeInsets.only(left: 30),
              width: material.MediaQuery.of(ctx).size.width * (0.4),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    discount
                        ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            // Text(capitalize(modeOfPaymentFromStages)),
                            Text(capitalize('Consultation fee')),
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
                              Text(" ₹ $cGst"),
                              // SizedBox(width: 15.0),
                            ],
                          )
                        : SizedBox(height: 0, width: 0),
                    state == "Haryana" || state == "haryana"
                        ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                            Text("Tax: SGST  9%"),
                            // SizedBox(width: 10.0),
                            Text(" ₹ $sGst"),
                            // SizedBox(width: 15.0),
                          ])
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Tax: IGST  18%"),
                              // SizedBox(width: 10.0),
                              Text(" ₹ $iGst"),
                              // SizedBox(width: 15.0),
                            ],
                          ),
                    SizedBox(height: 4),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Total '), Text(' ₹ $finalPrice')]),
                    SizedBox(height: 4.0),
                    // Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [Text(modeOfPaymentFromHistory), Text(baseFare.toString())]),
                    // SizedBox(height: 4.0),
                    // discount
                    //     ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                    //         Text("Discount"),
                    //         // SizedBox(width: 60.0),
                    //         Text(" ₹ -" + invoiceModel.discount.toString()),
                    //         // SizedBox(width: 15.0),
                    //       ])
                    //     : Container(),
                    // SizedBox(height: 4),
                    // state == "Haryana" || state == "haryana"
                    //     ? Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: <Widget>[
                    //           Text("Tax: CGST  9% "),
                    //           // SizedBox(width: 10.0),
                    //           Text(" ₹ " + cGst.toString()),
                    //           // SizedBox(width: 15.0),
                    //         ],
                    //       )
                    //     : SizedBox(height: 0, width: 0),
                    // state == "Haryana" || state == "haryana"
                    //     ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                    //         Text("Tax: SGST  9%"),
                    //         // SizedBox(width: 10.0),
                    //         Text(" ₹ " + sGst.toString()),
                    //         // SizedBox(width: 15.0),
                    //       ])
                    //     : Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: <Widget>[
                    //           Text("Tax: IGST  18%"),
                    //           // SizedBox(width: 10.0),
                    //           Text(" ₹ " + iGst.toString()),
                    //           // SizedBox(width: 15.0),
                    //         ],
                    //       ),
                    // SizedBox(height: 4),
                    // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                    //   Text("Total"),
                    //   // SizedBox(width: 60.0),
                    //   Text(" ₹ " + finalPrice.toString()),
                    //   // SizedBox(width: 15.0),
                    // ])
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
                Text("${API.updatedIHLurl}/myappointment", style: const TextStyle(fontSize: 6)),
              ]))
        ]));
      }));

  String fileName = "$appointmentOnPdfSave $timeinvoice";
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
  final String path = '$dir/$fileName.pdf';
  String base64Pdf;
  try {
    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    ///converting to base 64
    print(file.path);
    List<int> base = file.readAsBytesSync();
    base64Pdf = base64.encode(base);
    print(base64Pdf);
  } catch (e) {
    print(e);
  }

  if (showPdfNotification == true) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("pathFromBillViewConsultationSummary", path);

    int maxStep = 1;
    for (int simulatedStep = 1; simulatedStep <= maxStep + 1; simulatedStep++) {
      await Future.delayed(const Duration(seconds: 1), () async {
        if (simulatedStep > maxStep) {
          // await AwesomeNotifications().createNotification(
          //     content: NotificationContent(
          //         id: 1,
          //         channelKey: 'bill_progress_consultation_summary',
          //         title: 'Download finished',
          //         body: fileName + '.pdf',
          //         payload: {'file': fileName + '.pdf', 'path': path},
          //         locked: false));
          await flutterLocalNotificationsPlugin.show(
            1,
            'Download finished',
            '$fileName.pdf',
            bill_progress_consultation_summary,
            payload: jsonEncode({
              'file': '$fileName.pdf',
              'path': path,
              'channelKey': 'bill_progress_consultation_summary'
            }),
          );
        } else {
          await flutterLocalNotificationsPlugin.show(
            1,
            'Downloading file in progress ($simulatedStep of $maxStep)',
            '$fileName.pdf',
            bill_progress_consultation_summary,
            payload: jsonEncode({
              'file': '$fileName.pdf',
              'path': path,
              'channelKey': 'bill_progress_consultation_summary'
            }),
          );
          // await AwesomeNotifications().createNotification(
          //     content: NotificationContent(
          //         id: 1,
          //         channelKey: 'bill_progress_consultation_summary',
          //         title:
          //         'Downloading file in progress ($simulatedStep of $maxStep)',
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
    print('do not show any notification');
    return base64Pdf;
  }
}