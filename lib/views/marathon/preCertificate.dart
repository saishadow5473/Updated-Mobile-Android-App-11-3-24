import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' as material;
// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../utils/screenutil.dart';

Future<String> preCertifiacte(context, name_participent, event_status, event_varient, time_taken,
    emp_id, ChallengeDetail challengeDetail, enrolledChallenge, String groupName, duration) async {
  var ctx = context;
  var name = name_participent == null ? "Name" : name_participent;
  var status = event_status == null ? "completed" : event_status;
  var varient = event_varient == null ? "5 KM" : event_varient;
  var time_text = time_taken == null ? "01:01:01" : time_taken;
  var employee_id = emp_id == null ? "001" : emp_id;
  final Document pdf = Document();

  // const imageProvider = const material.AssetImage('assets/images/ihl-plus.png');
  const imageProvider = const material.AssetImage('assets/the_cert1.jpg');
  final image = await flutterImageProvider(imageProvider);
  const ihlImageProvider = const material.AssetImage('assets/ihltemplate.png');
  final ihlimage = await flutterImageProvider(ihlImageProvider);

  const rxImageProvider = const material.AssetImage('assets/images/rx.PNG');
  pdf.addPage(Page(
      theme: ThemeData.withFont(
        base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
      ),
      pageFormat: PdfPageFormat.a4,
      build: (Context context) {
        ScUtil.init(ctx, width: 360, height: 640, allowFontScaling: true);

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
              top: (challengeDetail.affiliations.contains('ihl_care') ||
                      challengeDetail.affiliations.contains('dev_testing'))
                  ? ScUtil().setHeight(50)
                  : ScUtil().setHeight(62),
              right: 15.w,
              child: Text("BIB: ${enrolledChallenge.user_bib_no}",
                  // style: TextStyle(fontSize: 18, color: PdfColors.orange)
                  style: (challengeDetail.affiliations.contains('ihl_care') ||
                          challengeDetail.affiliations.contains('dev_testing'))
                      ? TextStyle(
                          fontSize: ScUtil().setSp(13),
                          // fontWeight: FontWeight.bold,
                          color: PdfColor.fromHex("#00adc6"))
                      : TextStyle(
                          fontSize: ScUtil().setSp(13),
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
            top: ScUtil().setHeight(90),
            left: ScUtil().setWidth(75),
            child: SizedBox(
              width: (challengeDetail.affiliations.contains('ihl_care') ||
                      challengeDetail.affiliations.contains('dev_testing'))
                  ? 200
                  : 240,
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
                              .replaceAll('{{Participant_Name}}',
                              enrolledChallenge.name.toString().replaceAll("&quot;", " "))
                              .replaceAll("&quot;", " "),

                          // challengeDetail.challengeCompletionCertificateMessage
                          //     .replaceAll('{{group_name}}', groupName)
                          //     .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                          //     .replaceAll('{{days}}', duration),
                          textAlign: TextAlign.justify,
                          // style:
                          //     TextStyle(color: PdfColor.fromInt(0xffD8AF49), fontSize: 15, letterSpacing: -1),
                          style: TextStyle(
                              fontSize: ScUtil().setSp(15),
                              // fontWeight: FontWeight.bold,
                              color: PdfColor.fromHex("#00adc6")),
                        )
                      : Text(
                          challengeDetail.challengeCompletionCertificateMessage
                              .replaceAll("&quot;", " ")
                              .replaceAll("\r", " ")
                              .replaceAll('{{group_name}}', groupName)
                              // .replaceAll(
                              //     '{{steps}}', enrolledChallenge.target.toString())
                              .replaceAll('{{distance}}',
                                  "${enrolledChallenge.target} ${challengeDetail.challengeUnit} ")
                              .replaceAll('{{days}}', "${duration} ")
                              .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                              .replaceAll('{{Participant_Name}}', "${enrolledChallenge.name.toString().replaceAll("&quot;", " ")} "),
                          // challengeDetail.challengeCompletionCertificateMessage
                          //     .replaceAll('{{group_name}}', groupName)
                          //     .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                          //     .replaceAll('{{days}}', duration),
                          textAlign: TextAlign.justify,
                          // style:
                          //     TextStyle(color: PdfColor.fromInt(0xffD8AF49), fontSize: 15, letterSpacing: -1),
                          style: TextStyle(
                              fontSize: ScUtil().setSp(15),
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
                              .replaceAll('{{Participant_Name}}', "${enrolledChallenge.name.toString().replaceAll("&quot;", " ")} ")
                              .replaceAll("&quot;", " "),
                          // challengeDetail.challengeCompletionCertificateMessage
                          //     .replaceAll('{{group_name}}', groupName)
                          //     .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                          //     .replaceAll('{{days}}', duration),
                          textAlign: TextAlign.justify,
                          // style:
                          //     TextStyle(color: PdfColor.fromInt(0xffD8AF49), fontSize: 15, letterSpacing: -1),
                          style: TextStyle(
                              fontSize: ScUtil().setSp(15),
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
                              .replaceAll('{{Participant_Name}}', "${enrolledChallenge.name.toString().replaceAll("&quot;", " ")} ")
            .replaceAll("&quot;", " "),
                          // challengeDetail.challengeCompletionCertificateMessage
                          //     .replaceAll('{{group_name}}', groupName)
                          //     .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                          //     .replaceAll('{{days}}', duration),
                          textAlign: TextAlign.justify,
                          // style:
                          //     TextStyle(color: PdfColor.fromInt(0xffD8AF49), fontSize: 15, letterSpacing: -1),
                          style: TextStyle(
                              fontSize: ScUtil().setSp(15),
                              // fontWeight: FontWeight.bold,
                              color: PdfColor.fromHex("#00adc6")),
                        ),
            ),
          ),
        ]);
      }));
  // String fileName = "E-Certificate" + 'for-Persistent-run';
  String fileName = "E-Certificate" + 'for-Persistent-run';
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
  String base64Pdf = base64.encode(base);

  return base64Pdf;
}

Future<String> imgPreCertifiacte(context, name_participent, event_status, event_varient, time_taken,
    emp_id, ChallengeDetail challengeDetail, enrolledChallenge, String groupName, duration) async {
  var ctx = context;
  var name = name_participent == null ? "Name" : name_participent;
  var status = event_status == null ? "completed" : event_status;
  var varient = event_varient == null ? "5 KM" : event_varient;
  var time_text = time_taken == null ? "01:01:01" : time_taken;
  var employee_id = emp_id == null ? "001" : emp_id;
  final Document pdf = Document();

  // const imageProvider = const material.AssetImage('assets/images/ihl-plus.png');
  const imageProvider = const material.AssetImage('assets/the_cert1.jpg');
  final image = await flutterImageProvider(imageProvider);
  const ihlImageProvider = const material.AssetImage('assets/ihltemplate.png');
  final ihlimage = await flutterImageProvider(ihlImageProvider);
  const rxImageProvider = const material.AssetImage('assets/images/rx.PNG');

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
              top: (challengeDetail.affiliations.contains('ihl_care') ||
                      challengeDetail.affiliations.contains('dev_testing'))
                  ? ScUtil().setHeight(50)
                  : ScUtil().setHeight(62),
              right: ScUtil().setWidth(75),
              child: Text("BIB: ${enrolledChallenge.user_bib_no}",
                  // style: TextStyle(fontSize: 18, color: PdfColors.orange)
                  style: (challengeDetail.affiliations.contains('ihl_care') ||
                          challengeDetail.affiliations.contains('dev_testing'))
                      ? TextStyle(
                          fontSize: ScUtil().setSp(13),
                          // fontWeight: FontWeight.bold,
                          color: PdfColor.fromHex("#00adc6"))
                      : TextStyle(
                          fontSize: ScUtil().setSp(13),
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
            top: ScUtil().setHeight(100),
            // left: ScUtil().setWidth(75),
            left: 12.w,
            child: SizedBox(
              width: (challengeDetail.affiliations.contains('ihl_care') ||
                      challengeDetail.affiliations.contains('dev_testing'))
                  ? 200
                  : 240,
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
                              .replaceAll('{{Participant_Name}}', "${enrolledChallenge.name.toString().replaceAll("&quot;", " ")} ")
                              .replaceAll("&quot;", " "),

                          // challengeDetail.challengeCompletionCertificateMessage
                          //     .replaceAll('{{group_name}}', groupName)
                          //     .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                          //     .replaceAll('{{days}}', duration),
                          textAlign: TextAlign.justify,
                          // style:
                          //     TextStyle(color: PdfColor.fromInt(0xffD8AF49), fontSize: 15, letterSpacing: -1),
                          style: TextStyle(
                              fontSize: ScUtil().setSp(15),
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
                              .replaceAll('{{Participant_Name}}', "${enrolledChallenge.name.toString().replaceAll("&quot;", " ")} ")
                              .replaceAll("&quot;", " "),
                          // challengeDetail.challengeCompletionCertificateMessage
                          //     .replaceAll('{{group_name}}', groupName)
                          //     .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                          //     .replaceAll('{{days}}', duration),
                          textAlign: TextAlign.justify,
                          // style:
                          //     TextStyle(color: PdfColor.fromInt(0xffD8AF49), fontSize: 15, letterSpacing: -1),
                          style: TextStyle(
                              fontSize: ScUtil().setSp(15),
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
                              .replaceAll('{{Participant_Name}}', "${enrolledChallenge.name.toString().replaceAll("&quot;", " ")} ")
                              .replaceAll("&quot;", " "),
                          // challengeDetail.challengeCompletionCertificateMessage
                          //     .replaceAll('{{group_name}}', groupName)
                          //     .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                          //     .replaceAll('{{days}}', duration),
                          textAlign: TextAlign.justify,
                          // style:
                          //     TextStyle(color: PdfColor.fromInt(0xffD8AF49), fontSize: 15, letterSpacing: -1),
                          style: TextStyle(
                              fontSize: ScUtil().setSp(15),
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
                              .replaceAll('{{Participant_Name}}', "${enrolledChallenge.name.toString().replaceAll("&quot;", " ")} ")
                              .replaceAll("&quot;", " "),
                          // challengeDetail.challengeCompletionCertificateMessage
                          //     .replaceAll('{{group_name}}', groupName)
                          //     .replaceAll('{{steps}}', enrolledChallenge.target.toString())
                          //     .replaceAll('{{days}}', duration),
                          textAlign: TextAlign.justify,
                          // style:
                          //     TextStyle(color: PdfColor.fromInt(0xffD8AF49), fontSize: 15, letterSpacing: -1),
                          style: TextStyle(
                              fontSize: ScUtil().setSp(15),
                              // fontWeight: FontWeight.bold,
                              color: PdfColor.fromHex("#00adc6")),
                        ),
            ),
          ),
        ]);
      }));

  // String fileName = "E-Certificate" + 'for-Persistent-run';
  String fileName = "E-Certificate" + 'for-Persistent-run';
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
  final String path = '$dir/' + fileName + ".png";
  final File file = File(path);
  await file.writeAsBytes(await pdf.save());

  List<int> base = file.readAsBytesSync();
  String base64IMG = base64.encode(base);

  return base64IMG;
}
