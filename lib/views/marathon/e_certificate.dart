import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' as material;
// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/main.dart';
import 'package:ihl/views/teleconsultation/pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../utils/screenutil.dart';

eCertificate(
    context,
    name_participent,
    event_status,
    event_varient,
    time_taken,
    emp_id,
    ChallengeDetail challengeDetail,
    EnrolledChallenge enrolledChallenge,
    String groupName,
    duration) async {
  var ctx = context;
  var name = name_participent == null ? "Name" : name_participent;
  var status = event_status == null ? "completed" : event_status;
  var varient = event_varient == null ? "5 KM" : event_varient;
  var time_text = time_taken == null ? "01:01:01" : time_taken;
  var employee_id = emp_id == null ? "001" : emp_id;
  final Document pdf = Document();

  // const imageProvider = const material.AssetImage('assets/images/ihl-plus.png');
  const imageProvider = const material.AssetImage('assets/the_cert1.jpg');
  const ihlImageProvider = const material.AssetImage('assets/ihltemplate.png');
  // var ihlImageProvide = material.NetworkImage(challengeDetail.challenge_completed_certficate_url);
  final ihlimage = await flutterImageProvider(ihlImageProvider);
  final image = await flutterImageProvider(imageProvider);

  // const signatureImageProvider =
  //     const material.AssetImage('assets/images/signature.PNG');
  // final signatureImage = await flutterImageProvider(signatureImageProvider);
  // var signatureImage;
  // try {
  //   signatureImage = consultantSignature != null && consultantSignature != ''
  //       ? await flutterImageProvider(consultantSignature.image)
  //       : null;
  // } catch (e) {
  //   print(e);
  //   signatureImage = null;
  // }
  const rxImageProvider = const material.AssetImage('assets/images/rx.PNG');
  final rximage = await flutterImageProvider(rxImageProvider);
  final netImage = await networkImage(challengeDetail.challengeImgUrl);

  // pdf.addPage(
  //   MultiPage(
  //     theme: ThemeData.withFont(
  //       base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
  //     ),
  //     pageFormat: PdfPageFormat.a4,
  //     build: (Context context) {
  //       return [
  //         Partitions(
  //           children: [
  //             Partition(
  //               child: Column(
  //                 // mainAxisAlignment: MainAxisAlignment.start,
  //                 // crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: <Widget>[
  //                   SizedBox(width: 20.0),
  //                   Stack(
  //                     children: <Widget>[
  //                       // Image(image, width: 40.0, height: 40.0),
  //                       Image(image),
  //                       Positioned(
  //                           top: 80,
  //                           left: 65,
  //                           child: RichText(
  //                             text: TextSpan(
  //                               text: 'Persistant ',
  //                               style: TextStyle(
  //                                   fontSize: 20,
  //                                   fontWeight: FontWeight.bold,
  //                                   color: PdfColors.grey),
  //                               children: <TextSpan>[
  //                                 TextSpan(
  //                                     text: ' Run 2021',
  //                                     style: TextStyle(fontWeight: FontWeight.normal)),
  //                               ],
  //                             ),
  //                           )),

  //                       Positioned(
  //                         top: 100,
  //                         left: 65,
  //                         child: Text(
  //                           status == "stop"
  //                               ? "Certificate of Participation"
  //                               : "Certificate of Completion",
  //                           style: TextStyle(fontSize: 20, color: PdfColors.grey),
  //                         ),
  //                       ),
  //                       Positioned(
  //                         top: 130,
  //                         left: 65,
  //                         child: Text(
  //                           employee_id,
  //                           style: TextStyle(fontSize: 15, color: PdfColors.orange),
  //                         ),
  //                       ),
  //                       Positioned(
  //                         top: 150,
  //                         left: 65,
  //                         child: Text(
  //                           name,
  //                           style: TextStyle(
  //                               fontSize: 20, fontWeight: FontWeight.bold, color: PdfColors.orange),
  //                         ),
  //                       ),
  //                       Positioned(
  //                         top: 180,
  //                         left: 65,
  //                         child: Text(
  //                           varient + " " + time_text,
  //                           style: TextStyle(
  //                               fontSize: 20,
  //                               fontWeight: FontWeight.bold,
  //                               color: PdfColors.cyanAccent700),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ];
  //     },
  //   ),
  // );
  pdf.addPage(Page(
      theme: ThemeData.withFont(
        base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
      ),
      pageFormat: PdfPageFormat.a4,
      build: (Context context) {
        return Stack(children: [
          (challengeDetail.affiliations.contains('ihl_care') ||
                  challengeDetail.affiliations.contains('dev_testing'))
              ? Image(ihlimage)
              : Image(image),
          // Positioned(
          //   top: 82,
          //   left: 35,
          //   child: ClipRRect(
          //     verticalRadius: 30,
          //     horizontalRadius: 30,
          //     child: Image(netImage, height: 90, width: 75),
          //   ),
          // ),
          Positioned(
              // top: 95,
              // left: 138,
              top: 50.sp,
              right: 75.sp,
              child: Text("BIB: ${enrolledChallenge.user_bib_no}",
                  // style: TextStyle(fontSize: 18, color: PdfColors.orange)
                  style: (challengeDetail.affiliations.contains('ihl_care') ||
                          challengeDetail.affiliations.contains('dev_testing'))
                      ? TextStyle(
                          fontSize: 10.sp,
                          // fontWeight: FontWeight.bold,
                          color: PdfColor.fromHex("#00adc6"))
                      : TextStyle(
                          fontSize: 10.sp,
                          // fontWeight: FontWeight.bold,
                          color: PdfColor.fromHex("#f5b14b")))),
          /*     Positioned(
              // top: 125,
              // left: 138,
              top: ScUtil().setHeight(115),
              left: ScUtil().setWidth(75),
              child: RichText(
                text: TextSpan(
                  // Note: Styles for TextSpans must be explicitly defined.
                  // Child text spans will inherit styles from parent
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: enrolledChallenge.selectedFitnessApp == "other_apps"
                            ? enrolledChallenge.userAchieved < enrolledChallenge.target
                                ? " "
                                : 'Congratulations  '
                            : enrolledChallenge.docStatus == "rejected"
                                ? ""
                                : 'Congratulations  ',
                        style: TextStyle(
                            fontSize: ScUtil().setSp(12),
                            fontWeight: FontWeight.normal,
                            color: PdfColor.fromHex("#f5ae45"))),
                    TextSpan(
                        text: name_participent,
                        style: TextStyle(
                            fontSize: ScUtil().setSp(15),
                            fontWeight: FontWeight.bold,
                            color: PdfColor.fromHex("#f5ae45"))),
                  ],
                ),
              )),
       */
          Positioned(
            // top: 190,
            // left: 50,
            top: 75.sp,
            left: 50.sp,
            child: SizedBox(
              width: (challengeDetail.affiliations.contains('ihl_care') ||
                      challengeDetail.affiliations.contains('dev_testing'))
                  ? 55.w
                  : 56.w,
              child: enrolledChallenge.selectedFitnessApp != "other_apps"
                  ? enrolledChallenge.userAchieved < enrolledChallenge.target ||
                          enrolledChallenge.docStatus.toLowerCase() == 'rejected'
                      ? Text(
                          challengeDetail.challengeCompletionCertificateMessage
                              .replaceAll('{{group_name}}', groupName)
                              .replaceAll("completed", "participated in")
                              // .replaceAll(
                              //     'steps', enrolledChallenge.target.toString())
                              .replaceAll('{{distance}}',
                                  "${enrolledChallenge.target} ${challengeDetail.challengeUnit} ")
                              .replaceAll('{{days}}', "${duration} ")
                              .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                              .replaceAll('{{Participant_Name}}', "${enrolledChallenge.name} "),

                          // challengeDetail.challengeCompletionCertificateMessage
                          //     .replaceAll('{{group_name}}', groupName)
                          //     .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                          //     .replaceAll('{{days}}', duration),
                          textAlign: TextAlign.justify,
                          // style:
                          //     TextStyle(color: PdfColor.fromInt(0xffD8AF49), fontSize: 15, letterSpacing: -1),
                          style: TextStyle(
                              fontSize: 13.sp,
                              // fontWeight: FontWeight.bold,
                              color: PdfColor.fromHex("#00adc6")),
                        )
                      : Text(
                          challengeDetail.challengeCompletionCertificateMessage
                              .replaceAll("\r", " ")
                              .replaceAll('{{group_name}}', groupName)
                              // .replaceAll(
                              //     '{{steps}}', enrolledChallenge.target.toString())
                              .replaceAll('{{distance}}',
                                  "${enrolledChallenge.target} ${challengeDetail.challengeUnit} ")
                              .replaceAll('{{days}}', "${duration} ")
                              .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                              .replaceAll('{{Participant_Name}}', "${enrolledChallenge.name} "),
                          // challengeDetail.challengeCompletionCertificateMessage
                          //     .replaceAll('{{group_name}}', groupName)
                          //     .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                          //     .replaceAll('{{days}}', duration),
                          textAlign: TextAlign.justify,
                          // style:
                          //     TextStyle(color: PdfColor.fromInt(0xffD8AF49), fontSize: 15, letterSpacing: -1),
                          style: TextStyle(
                              fontSize: 13.sp,
                              // fontWeight: FontWeight.bold,
                              color: PdfColor.fromHex("#00adc6")),
                        )
                  : enrolledChallenge.docStatus.toLowerCase() == 'rejected'
                      ? Text(
                          challengeDetail.challengeCompletionCertificateMessage
                              .replaceAll('{{group_name}}', groupName)
                              .replaceAll("completed", "participated in")
                              // .replaceAll(
                              //     'steps', enrolledChallenge.target.toString())
                              .replaceAll('{{distance}}',
                                  "${enrolledChallenge.target} ${challengeDetail.challengeUnit} ")
                              .replaceAll('{{days}}', "${duration} ")
                              .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                              .replaceAll('{{Participant_Name}}', "${enrolledChallenge.name} "),
                          // challengeDetail.challengeCompletionCertificateMessage
                          //     .replaceAll('{{group_name}}', groupName)
                          //     .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                          //     .replaceAll('{{days}}', duration),
                          textAlign: TextAlign.justify,
                          // style:
                          //     TextStyle(color: PdfColor.fromInt(0xffD8AF49), fontSize: 15, letterSpacing: -1),
                          style: TextStyle(
                              fontSize: 13.sp,
                              // fontWeight: FontWeight.bold,
                              color: PdfColor.fromHex("#00adc6")),
                        )
                      : Text(
                          challengeDetail.challengeCompletionCertificateMessage
                              .replaceAll('{{group_name}}', groupName)
                              // .replaceAll(
                              //     '{{steps}}', enrolledChallenge.target.toString())
                              .replaceAll('{{distance}}',
                                  "${enrolledChallenge.target} ${challengeDetail.challengeUnit} ")
                              .replaceAll('{{days}}', "${duration} ")
                              .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                              .replaceAll('{{Participant_Name}}', "${enrolledChallenge.name} "),
                          // challengeDetail.challengeCompletionCertificateMessage
                          //     .replaceAll('{{group_name}}', groupName)
                          //     .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                          //     .replaceAll('{{days}}', duration),
                          textAlign: TextAlign.justify,
                          // style:
                          //     TextStyle(color: PdfColor.fromInt(0xffD8AF49), fontSize: 15, letterSpacing: -1),
                          style: TextStyle(
                              fontSize: 13.sp,
                              // fontWeight: FontWeight.bold,
                              color: PdfColor.fromHex("#00adc6")),
                        ),
            ),
          ),
        ]);
      }));
  // String fileName = "E-Certificate" + 'for-Persistent-run';
  String fileName = "E-Certificate" + '${challengeDetail.challengeName}';
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
  //gBase64Pdf = base64Pdf;
  print(base64Pdf);
  var showPdfNotification = true;
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
    print('################## $path');
    // material.Navigator.of(context).push(
    //   material.MaterialPageRoute(
    //     builder: (_) => PdfViewerPage(path: path),
    //   ),
    // );
  } else {
    Get.to(PdfViewerPage(
      path: path,
    ));
    print(
        'dont show notification for pdf downloading , because we are calling 1mg api to send prescription');
    return base64Pdf;
  }
}
