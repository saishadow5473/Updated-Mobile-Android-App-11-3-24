import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../main.dart';
import '../../data/model/TeleconsultationModels/consultation_summary_model.dart';
import '../../../views/teleconsultation/pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/material.dart' as material;
import 'package:printing/printing.dart';

instructionsView({material.BuildContext context, ConsultationSummaryModel summary}) async {
  // getDataFromHistorySummary();
  final Document pdf = Document();

  String appointmentTime;
  //"1999-12-22 06:30 AM" comming format to => "2023 December 22, 06:30 AM"⚪⚪
  DateTime dateTime = DateFormat("yyyy-mm-dd HH:mm aa").parse(summary.message.appointmentStartTime);
  appointmentTime = DateFormat("yyyy MMMM dd, hh:mm aa").format(dateTime);
  const material.AssetImage imageProvider = material.AssetImage('assets/images/ihl-plus.png');
  final ImageProvider image = await flutterImageProvider(imageProvider);

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
                    Text("INDIA", style: const TextStyle(color: PdfColor.fromInt(0xff2768a9))),
                    Text("HEALTH", style: const TextStyle(color: PdfColors.grey)),
                    Text("LINK", style: const TextStyle(color: PdfColor.fromInt(0xff2768a9))),
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
          Divider(thickness: 1.0, color: PdfColors.grey300, indent: 3.0, endIndent: 1.0),
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Patient Name: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text:
                            '${summary.userDetails.userFirstName.toString()} ${summary.userDetails.userLastName.toString()}',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                Row(children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Gender: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: summary.userDetails.gender,
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: ', Age: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '${summary.userDetails.age.toString()} Years old',
                        ),
                      ],
                    ),
                  ),
                ]),
                SizedBox(height: 5.0),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Phone Number: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: summary.userDetails.userMobileNumber.toString(),
                        style: const TextStyle(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Email: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: summary.userDetails.userEmail.toString(),
                          style: const TextStyle(),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Date & Time: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: appointmentTime,
                          style: const TextStyle(),
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
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Physician Name: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: summary.consultantDetails.consultantName,
                        style: const TextStyle(),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Specialty: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: summary.message.specality,
                        style: const TextStyle(),
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
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Reason For Visit: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: summary.message.reasonForVisit.toString(),
                        style: const TextStyle(),
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
                Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
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
                Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: summary.message.consultationAdviceNotes ?? "N/A",
                          style: const TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ]),
                SizedBox(height: 5.0),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
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
                Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: summary.message.diagnosis ?? "N/A",
                          style: const TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ]),
              ]),
        ]));
      }));

  String fileName = "IHL_Prescription_$appointmentTime";

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
  final String path = '$dir/' "$fileName.pdf";
  final File file = File(path);
  await file.writeAsBytes(await pdf.save());
  int maxStep = 1;
  for (int simulatedStep = 1; simulatedStep <= maxStep + 1; simulatedStep++) {
    await Future<void>.delayed(const Duration(seconds: 1), () async {
      if (simulatedStep > maxStep) {
        await flutterLocalNotificationsPlugin.show(
          1,
          'Download finished',
          '$fileName.pdf',
          prescription_progress,
          payload: jsonEncode(<String, dynamic>{
            'file': '$fileName.pdf',
            'path': path,
            'channelKey': 'prescription_progress'
          }),
        );
      } else {
        await flutterLocalNotificationsPlugin.show(
          1,
          'Downloading file in progress ($simulatedStep of $maxStep)',
          '$fileName.pdf',
          prescription_progress,
          payload: jsonEncode(<String, dynamic>{
            'file': '$fileName.pdf',
            'path': path,
            'channelKey': 'prescription_progress'
          }),
        );
      }
    });
  }
  Get.to(PdfViewerPage(path: path));
}
