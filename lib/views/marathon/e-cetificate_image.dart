import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/main.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../health_challenge/widgets/certificate_widget.dart';
import 'e_certificate.dart';

class EcertificateImage extends StatefulWidget {
  @override
  EcertificateImage({
    this.name_participent,
    this.event_status,
    this.duration,
    this.event_varient,
    this.time_taken,
    this.emp_id,
    this.challengeDetail,
    this.enrolledChallenge,
    this.groupName,
  });
  var time_taken;
  final ChallengeDetail challengeDetail;
  final EnrolledChallenge enrolledChallenge;
  final String groupName, duration;
  var event_status;

  var event_varient;

  var emp_id;

  var name_participent;
  _EcertificateImageState createState() => new _EcertificateImageState();
}

class _EcertificateImageState extends State<EcertificateImage> {
  GlobalKey _globalKey = new GlobalKey();
  bool buttonLoading = false;
  Future<Uint8List> _capturePng() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary = _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      print(pngBytes);
      print(bs64);
      String fileName = "E-Certificate";
      // String fileName = "E-Certificate" + 'for-Persistent-run';
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
      await file.writeAsBytes(pngBytes);
      List<int> base = file.readAsBytesSync();
      var base64Pdf = base64.encode(base);
      print(base64Pdf);
      var showPdfNotification = true;
      if (showPdfNotification == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("pathFromInstructions", path);

        var maxStep = 1;
        for (var simulatedStep = 1; simulatedStep <= maxStep + 1; simulatedStep++) {
          await Future.delayed(const Duration(seconds: 1), () async {
            if (simulatedStep > maxStep) {
              // await AwesomeNotifications().createNotification(
              //     content: NotificationContent(
              //         id: 1,
              //         channelKey: 'prescription_progress',
              //         title: 'Download finished',
              //         body: fileName + '.png',
              //         payload: {'file': fileName + '.png', 'path': path},
              //         locked: false));
              await flutterLocalNotificationsPlugin.show(
                1,
                'Download complete',
                fileName + '.png',
                prescription_progress,
                payload: jsonEncode({
                  'file': fileName + '.png',
                  'path': path,
                  'channelKey': 'prescription_progress'
                }),
              );
            } else {
              await flutterLocalNotificationsPlugin.show(
                1,
                'Download in progress... ($simulatedStep of $maxStep)',
                fileName + '.png',
                prescription_progress,
                payload: jsonEncode({
                  'file': fileName + '.png',
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
              //         body: fileName + '.png',
              //         payload: {'file': fileName + '.png', 'path': path},
              //         notificationLayout: NotificationLayout.ProgressBar,
              //         progress:
              //             min((simulatedStep / maxStep * 100).round(), 100),
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
        print(
            'dont show notification for pdf downloading , because we are calling 1mg api to send prescription');
        //return base64Pdf;
      }
    } catch (e) {
      print(e);
    }
  }

  final String _videoUrl =
      'https://dashboard.indiahealthlink.com/challenge_video/enr_75d30b11c84d4d2eaf3e080662de80cb/out_merged.mp4';

  shareCer() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      print(pngBytes);
      print(bs64);
      String fileName = "E-Certificate";
      // String fileName = "E-Certificate" + 'for-Persistent-run';
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
      await file.writeAsBytes(pngBytes);
      await Share.shareXFiles(
        [XFile(file.path)],
      );
    } catch (e) {
      print(e);
    }
  }

  //TODO download certificate pdf
  downloadCertificatePdf() async {
    bool permissionGrandted = false;
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      Map<Permission, PermissionStatus> _status;
      if (deviceInfo.version.sdkInt <= 32) {
        _status = await [Permission.storage].request();
      } else {
        _status = await [Permission.photos, Permission.videos].request();
      }
      _status.forEach((permission, status) {
        if (status == PermissionStatus.granted) {
          permissionGrandted = true;
        }
      });
    } else {
      permissionGrandted = true;
    }
    if (permissionGrandted) {
      Get.snackbar(
        '',
        'Your digital certificate will be stored on your device.',
        backgroundColor: AppColors.primaryAccentColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        isDismissible: false,
      );
      new Future.delayed(new Duration(seconds: 2), () {
        eCertificate(
            context,
            widget.name_participent,
            widget.event_status,
            widget.event_varient,
            widget.time_taken,
            widget.emp_id,
            widget.challengeDetail,
            widget.enrolledChallenge,
            widget.groupName,
            widget.duration);
      });
    } else {
      Get.snackbar(
        'Storage Permission Required',
        'Please grant storage access to download your certificate.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        isDismissible: false,
        mainButton: TextButton(
          onPressed: () async {
            await openAppSettings();
          },
          child: const Text('Allow'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: false);
    return BasicPageUI(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'E-certificate',
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w500, color: Colors.white),
          maxLines: 1,
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'image',
                  child: Text('Download Image'),
                ),
                const PopupMenuItem<String>(
                  value: 'share',
                  child: Text('Share Image'),
                ),
                const PopupMenuItem<String>(
                  value: 'pdf',
                  child: Text('Download PDF'),
                ),
              ];
            },
            onSelected: (v) {
              switch (v) {
                case 'image':
                  Get.snackbar(
                    '',
                    'Your digital certificate will be stored on your device.',
                    backgroundColor: AppColors.primaryAccentColor,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 5),
                    isDismissible: false,
                  );
                  _capturePng();
                  break;
                case 'share':
                  shareCer();
                  break;
                case 'pdf':
                  downloadCertificatePdf();
                  break;
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: ScUtil().setHeight(30),
          ),

          RepaintBoundary(
            key: _globalKey,
            child: Container(
              height: 65.h,
              width: 95.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  widget.enrolledChallenge.selectedFitnessApp != "other_apps"
                      ? widget.enrolledChallenge.userAchieved < widget.enrolledChallenge.target
                          ? Container()
                          : Text(
                              'CONGRATULATIONS',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22.sp, letterSpacing: -1),
                            )
                      : widget.enrolledChallenge.docStatus.toLowerCase() == 'rejected'
                          ? Container()
                          : Text(
                              'CONGRATULATIONS',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22.sp, letterSpacing: -1),
                            ),
                  Text(
                    'You Won a Badge!!!',
                    style: TextStyle(color: Colors.white, fontSize: 19.sp, letterSpacing: -1),
                  ),
                  certificateBadgeWidget(widget.challengeDetail.challengeBadge),
                  SizedBox(
                    height: 15.h,
                    width: 85.w,
                    child: widget.enrolledChallenge.selectedFitnessApp != "other_apps"
                        ? widget.enrolledChallenge.userAchieved < widget.enrolledChallenge.target ||
                                widget.enrolledChallenge.docStatus.toLowerCase() == 'rejected'
                            ? Text(
                                widget.challengeDetail.challengeCompletionCertificateMessage
                                    .replaceAll('{{group_name}}', widget.groupName)
                                    .replaceAll("completed", "participated in")
                                    .replaceAll(
                                        '{{steps}}', widget.enrolledChallenge.target.toString())
                                    .replaceAll(
                                        '{{distance}}',
                                        widget.enrolledChallenge.target.toString() +
                                            ' ' +
                                            widget.challengeDetail.challengeUnit +
                                            ' ')
                                    .replaceAll('{{days}}', widget.duration)
                                    .replaceAll('{{Participant_Name}}',
                                        widget.enrolledChallenge.name + " "),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    letterSpacing: 1,
                                    height: 4.5.sp),
                                textAlign: TextAlign.center,
                              )
                            : Text(
                                widget.challengeDetail.challengeCompletionCertificateMessage
                                    .replaceAll('{{group_name}}', widget.groupName)
                                    .replaceAll(
                                        '{{steps}}', widget.enrolledChallenge.target.toString())
                                    .replaceAll(
                                        '{{distance}}',
                                        widget.enrolledChallenge.target.toString() +
                                            ' ' +
                                            widget.challengeDetail.challengeUnit +
                                            ' ')
                                    .replaceAll('{{days}}', widget.duration)
                                    .replaceAll('{{Participant_Name}}',
                                        widget.enrolledChallenge.name + " "),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    letterSpacing: 1,
                                    height: 4.5.sp),
                                textAlign: TextAlign.center,
                              )
                        : widget.enrolledChallenge.docStatus.toLowerCase() == 'rejected'
                            ? Text(
                                widget.challengeDetail.challengeCompletionCertificateMessage
                                    .replaceAll('{{group_name}}', widget.groupName)
                                    .replaceAll("completed", "participated in")
                                    .replaceAll(
                                        '{{steps}}', widget.enrolledChallenge.target.toString())
                                    .replaceAll(
                                        '{{distance}}',
                                        widget.enrolledChallenge.target.toString() +
                                            ' ' +
                                            widget.challengeDetail.challengeUnit +
                                            ' ')
                                    .replaceAll('{{days}}', widget.duration)
                                    .replaceAll('{{Participant_Name}}',
                                        widget.enrolledChallenge.name + " "),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    letterSpacing: 1,
                                    height: 4.5.sp),
                                textAlign: TextAlign.center,
                              )
                            : Text(
                                widget.challengeDetail.challengeCompletionCertificateMessage
                                    .replaceAll('{{group_name}}', widget.groupName)
                                    .replaceAll(
                                        '{{steps}}', widget.enrolledChallenge.target.toString())
                                    .replaceAll(
                                        '{{distance}}',
                                        widget.enrolledChallenge.target.toString() +
                                            ' ' +
                                            widget.challengeDetail.challengeUnit +
                                            ' ')
                                    .replaceAll('{{days}}', widget.duration)
                                    .replaceAll('{{Participant_Name}}',
                                        widget.enrolledChallenge.name + " "),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    letterSpacing: 1,
                                    height: 4.5.sp),
                                textAlign: TextAlign.center,
                              ),
                  ),
                ],
              ),
              margin: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xff2498A8),
                        Color(0xff1C6290),
                      ]),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      23.sp,
                    ),
                    topRight: Radius.circular(
                      23.sp,
                    ),
                  ),
                  color: Colors.blue),
            ),
          ),

          SizedBox(
            height: ScUtil().setHeight(20),
          ),
          Visibility(
            visible: false,
            child: SizedBox(
              width: ScUtil().setWidth(188),
              child: ElevatedButton(
                onPressed: () async {
                  bool permissionGrandted = false;
                  if (Platform.isAndroid) {
                    final deviceInfo = await DeviceInfoPlugin().androidInfo;
                    Map<Permission, PermissionStatus> _status;
                    if (deviceInfo.version.sdkInt <= 32) {
                      _status = await [Permission.storage].request();
                    } else {
                      _status = await [Permission.photos, Permission.videos].request();
                    }
                    _status.forEach((permission, status) {
                      if (status == PermissionStatus.granted) {
                        permissionGrandted = true;
                      }
                    });
                  } else {
                    permissionGrandted = true;
                  }
                  if (permissionGrandted) {
                    Get.snackbar(
                      '',
                      'Your digital certificate will be stored on your device.',
                      backgroundColor: AppColors.primaryAccentColor,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 5),
                      isDismissible: false,
                    );
                    new Future.delayed(new Duration(seconds: 2), () {
                      _capturePng();
                    });
                  } else {
                    Get.snackbar(
                      'Storage Permission Required',
                      'Please grant storage access to download your certificate.',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 5),
                      isDismissible: false,
                      mainButton: TextButton(
                        onPressed: () async {
                          await openAppSettings();
                        },
                        child: const Text('Allow'),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.image),
                    const Text("  Download as image"),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  primary: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          // SizedBox(
          //   height: ScUtil().setHeight(25),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(right: 30.0),
          //   child: IconButton(
          //       onPressed: () async => shareCer(),
          //       icon: Icon(
          //         Icons.share,
          //         color: AppColors.primaryColor,
          //       )),
          // ),
        ],
      ),
    );
  }
}
