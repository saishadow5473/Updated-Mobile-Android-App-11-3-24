import 'dart:convert';
import 'dart:io';
// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihl/main.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';

class NewsLetterViewer extends StatefulWidget {
  final String document_url;
  final String document_title;
  final String document_date;
  final Uint8List pdf_bytes;
  const NewsLetterViewer(
      {Key key,
      @required this.document_url,
      @required this.document_title,
      @required this.document_date,
      @required this.pdf_bytes})
      : super(key: key);

  @override
  State<NewsLetterViewer> createState() => _NewsLetterViewerState();
}

class _NewsLetterViewerState extends State<NewsLetterViewer> {
  bool loading = true;
  File file;
  @override
  void initState() {
    print(widget.document_url);
    super.initState();
  }

  void downloadPdf() async {
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
    String doc_name = widget.document_title + widget.document_date;
    doc_name = doc_name.replaceAll(" ", "");
    final String path = '$dir/' + doc_name + ".pdf";
    final File file = File(path);
    await file.writeAsBytes(widget.pdf_bytes);
    // await AwesomeNotifications().createNotification(
    //     content: NotificationContent(
    //         id: 1,
    //         channelKey: 'news_letter',
    //         title:'News Letter Downloaded Successfully' ,
    //         body: widget.document_title,
    //         payload: {"path": file.path},
    //         locked: true));
    await flutterLocalNotificationsPlugin.show(
      1,
      'News Letter Downloaded Successfully',
      widget.document_title,
      news_letter,
      payload: jsonEncode({"path": file.path, 'channelKey': 'news_letter'}),
    );
  }

  void share() async {
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
    String doc_name = widget.document_title + widget.document_date;
    doc_name = doc_name.replaceAll(" ", "");
    final String path = '$dir/' + doc_name + ".pdf";
    final File file = File(path);
    sharePdfFile(path);
  }

  void sharePdfFile(String pdfFilePath) {
    if (File(pdfFilePath).existsSync()) {
      Share.shareFiles([pdfFilePath], text: 'Sharing PDF');
    } else {
      print('PDF file not found');
    }
  }

  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      content: SizedBox(
        height: 100.h,
        width: 100.w,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor.withOpacity(0.7),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.white,
              ),
              title: Center(
                child: Text(
                  AppTexts.newsLetterViewerHeading,
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.download_rounded),
                  onPressed: () {
                    downloadPdf();
                  },
                  color: Colors.white,
                ),
                IconButton(
                    onPressed: () {
                      share();
                    },
                    icon: Icon(Icons.share))
              ],
            ),
            body: SizedBox(
              height: 100.h,
              width: 100.w,
              child: Stack(
                children: [
                  SfPdfViewer.network(widget.document_url),
                  // Positioned(
                  //   bottom: 10.h,
                  //   right: 10.w,
                  //   child: Container(
                  //       height: 100.h,
                  //       width: 100.w,
                  //       alignment: Alignment.bottomRight,
                  //       child: Container(
                  //           height: 55,
                  //           width: 55,
                  //           decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                  //           child: Center(
                  //               child: IconButton(
                  //                   onPressed: () {
                  //                     downloadPdf();
                  //                   },
                  //                   icon: Icon(
                  //                     Icons.download,
                  //                     color: Colors.white,
                  //                   ))))),
                  // )
                ],
              ),
            )),
      ),
    );
  }
}
