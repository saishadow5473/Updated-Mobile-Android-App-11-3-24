import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../constants/api.dart';
import '../../utils/screenutil.dart';
import '../../widgets/ScrollessBasicPageUI.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../new_design/app/utils/appColors.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';

class TipsDetailScreen extends StatefulWidget {
  TipsDetailScreen(
      {Key key,
      this.title,
      this.imageUrl,
      this.date,
      this.content,
      this.random_image_number,
      this.id,
      this.thumbUrl,
      @required this.fromNotification})
      : super(key: key);
  var title, imageUrl, thumbUrl, date, content, random_image_number, id;
  final bool fromNotification;

  @override
  _TipsDetailScreenState createState() => _TipsDetailScreenState();
}

class _TipsDetailScreenState extends State<TipsDetailScreen> {
  bool loading = false;
  bool fromnotification = false;

  @override
  void initState() {
    if (widget.fromNotification) {
      checkFromNotification();

      getTipsDetail();
    }
    super.initState();
  }

  checkFromNotification() {
    fromnotification = true;
  }

  Future getTipsDetail() async {
    http.Response response = await http.get(Uri.parse(
        '${API.iHLUrl}/pushnotification/get_health_tip_detail?health_tip_id=' + widget.id));
    if (response.statusCode == 200) {
      var deCodeData = json.decode(response.body);
      if (mounted) {
        setState(() {
          widget.title = deCodeData['health_tip_title'];
          var message = deCodeData['message'];
          message = message.replaceAll('&amp;', '&');
          message = message.replaceAll('&quot;', '"');
          message = message.replaceAll("\\r\\n", '');

          widget.content = message;
          widget.imageUrl = deCodeData['health_tip_blob_thumb_nail_url'];
          loading = false;
        });
      }
    }
  }

  Widget _imageAndText() => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Text(
          //   title,
          //   style: TextStyle(
          //       fontSize: ScUtil().setSp(20), fontWeight: FontWeight.w600),
          // ),
          // SizedBox(
          //   height: ScUtil().setHeight(15),
          // ),
          SizedBox(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: widget.imageUrl != "" && widget.imageUrl != null
                    ? InteractiveViewer(
                        panEnabled: false, // Set it to false
                        // boundaryMargin: EdgeInsets.all(100),
                        minScale: 0.5,
                        maxScale: 2,
                        child: Image.network(
                          widget.imageUrl,
                          loadingBuilder:
                              (BuildContext ctx, Widget child, ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: const Color.fromARGB(255, 158, 146, 146),
                                child: Container(
                                  height: 40.h,
                                  width: 80.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.purple,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('Loading'),
                                ));
                          },
                          // height: ScUtil().setHeight(150),
                          // width: ScUtil().setWidth(250),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/tips_image_${widget.random_image_number}.png',
                        height: ScUtil().setHeight(80),
                        width: ScUtil().setWidth(80),
                        fit: BoxFit.cover,
                      )),
          ),
          SizedBox(
            height: ScUtil().setHeight(15),
          ),
          Container(
            child: Text(
              widget.content.toString().replaceAll('amp;', '').replaceAll('&quot;', '"'),
              style: TextStyle(
                fontSize: ScUtil().setSp(15),
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: ScUtil().setHeight(12),
          ),
        ],
      );

  createPdf(bool isDownloads) async {
    pw.Font font = await PdfGoogleFonts.aBeeZeeItalic();
    try {
      final pw.ImageProvider netImage = await networkImage(widget.imageUrl);
      final pw.Document pdf = pw.Document();
      final ByteData data = await rootBundle.load('newAssets/IHL_Logo.png');
      final pw.MemoryImage image = pw.MemoryImage(data.buffer.asUint8List());
      pdf.addPage(pw.Page(
          theme: pw.ThemeData.withFont(
            base: pw.Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
          ),
          margin: const pw.EdgeInsets.all(10),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.SizedBox(width: 25.w, height: 25.w),
                // pw.Header(
                //     text: "dfghjklkjhgfddfghjklkjhgfdfghjklkjhgfdsdfghjklkjhgfdsdfghj",
                //     level: 1,
                //     textStyle:
                //         pw.TextStyle(color: PdfColor.fromHex('010101'), fontSize: 25, font: font)),
                pw.Expanded(
                    child: pw.Container(
                        alignment: pw.Alignment.center,
                        child: pw.Text(widget.title,
                            style: pw.TextStyle(
                                color: PdfColor.fromHex('010101'),
                                fontSize: 25,
                                font: font,
                                fontWeight: pw.FontWeight.bold,
                                decoration: pw.TextDecoration.underline)))),
                pw.SizedBox(width: 35.w, height: 25.w, child: pw.Image(image))
              ]),
              pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Image(netImage, fit: pw.BoxFit.fitHeight, height: 100.w, width: 100.w)),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.Text(
                  // text:
                  widget.content.replaceAll("\r", ""),
                  style: pw.TextStyle(color: PdfColor.fromHex('010101'), font: font)),
            ]);
          }));
      //Remove the slashed code to show old PDF UI 🥥🚩
      // pdf.addPage(pw.MultiPage(
      //     theme: pw.ThemeData.withFont(
      //       base: pw.Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
      //     ),
      //     build: (pw.Context context) {
      //       return [
      //         pw.Partitions(children: [
      //           pw.Partition(
      //               child: pw.Column(
      //                   mainAxisAlignment: pw.MainAxisAlignment.start,
      //                   crossAxisAlignment: pw.CrossAxisAlignment.center,
      //                   children: [
      //                 pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      //                   // pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      //                   //   pw.Header(
      //                   //       text: widget.title,
      //                   //       level: 1,
      //                   //       textStyle:
      //                   //           pw.TextStyle(color: PdfColor.fromHex('010101'), font: font)),
      //                   //   pw.Image(
      //                   //     netImage,
      //                   //     height: 300,
      //                   //   ),
      //                   // ]),
      //                   pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
      //                     pw.SizedBox(width: 35.w, height: 25.w),
      //                     pw.Spacer(),
      //                     pw.Header(
      //                         text: widget.title,
      //                         level: 1,
      //                         textStyle: pw.TextStyle(
      //                             color: PdfColor.fromHex('010101'), fontSize: 25, font: font)),
      //                     pw.Spacer(),
      //                     pw.SizedBox(width: 35.w, height: 25.w, child: pw.Image(image))
      //                   ]),
      //                   pw.Align(
      //                       alignment: pw.Alignment.center,
      //                       child: pw.Image(netImage,
      //                           fit: pw.BoxFit.fitHeight, height: 100.w, width: 100.w)),
      //                   pw.Divider(borderStyle: pw.BorderStyle.dashed),
      //                   pw.Paragraph(
      //                       text: widget.content,
      //                       style: pw.TextStyle(color: PdfColor.fromHex('010101'), font: font)),
      //                 ])
      //               ])),
      //         ])
      //       ];
      //       // Center
      //     }));

      // if (isDownloads) {
      //   final directory = await getApplicationDocumentsDirectory();
      //   String documentsPath = '/storage/emulated/0/Documents/';
      //   final file = File("$documentsPath/${widget.title}.pdf");
      //   try {
      //     await file.writeAsBytes(await pdf.save());
      //   } catch (e) {
      //     print(e);
      //   }
      //
      //   // print(file.path);
      //   // var ressult = await OpenFile.open(file.path);
      //   // ImageGallerySaver.saveFile(file.path, name: widget.title);
      //   Get.showSnackbar(
      //     const GetSnackBar(
      //       title: "Saved Successfully!!",
      //       message: 'pdf file downloaded',
      //       backgroundColor: AppColors.greenColor,
      //       duration: Duration(seconds: 2),
      //     ),
      //   );
      //   // print(ressult.message);
      // }
      // if (!isDownloads) {
      //   final directory = await getApplicationDocumentsDirectory();
      //
      //   final file = File("${directory.path}/${widget.title}.pdf");
      //   await file.writeAsBytes(await pdf.save());
      //   Share.shareFiles([file.path], text: widget.title);
      // }
      if (isDownloads) {
        Directory internalDirectory;
        String dir;
        final Directory directory = await getApplicationDocumentsDirectory();
        List<Directory> downloadsDirectory =
            await getExternalStorageDirectories(type: StorageDirectory.downloads);
        if (downloadsDirectory == null && downloadsDirectory.isEmpty) {
          internalDirectory = await getApplicationDocumentsDirectory();
        }
        dir = downloadsDirectory[0].path ?? internalDirectory.path;
        final String path = '$dir/' '${widget.title}' ".pdf";
        final File file = File(path);
        //String dir = directory.toString().replaceAll('Directory: ', '');
        try {
          File r = await file.writeAsBytes(await pdf.save());
          OpenFile.open(r.path);
          print(r);
        } catch (e) {
          print(e);
        }
        // String documentsPath = '/storage/emulated/0/Documents/';
        // final file = File("$documentsPath/${widget.title}.pdf");
        // try {
        //   await file.writeAsBytes(await pdf.save());
        // } catch (e) {
        //   print(e);
        // }

        // print(file.path);
        // var ressult = await OpenFile.open(file.path);
        // ImageGallerySaver.saveFile(file.path, name: widget.title);
        Get.showSnackbar(
          const GetSnackBar(
            title: "Saved Successfully!!",
            message: 'pdf file downloaded',
            backgroundColor: AppColors.greenColor,
            duration: Duration(seconds: 2),
          ),
        );
        // print(ressult.message);
      }
      if (!isDownloads) {
        final Directory directory = await getApplicationDocumentsDirectory();

        final File file = File("${directory.path}/${widget.title}.pdf");
        await file.writeAsBytes(await pdf.save());
        Share.shareFiles([file.path], text: widget.title);
      }
    } catch (e) {
      print(e);
    }
    // Share.shareFiles([file.path]);
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        if (fromnotification) {
          Get.off(LandingPage());
        } else {
          Get.back(canPop: true);
        }
      },
      child: Scaffold(
        body: ScrollessBasicPageUI(
          appBar: Column(
            children: [
              const SizedBox(
                width: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      if (fromnotification) {
                        Get.off(LandingPage());
                      } else {
                        Get.back(canPop: true);
                      }
                    },
                    color: Colors.white,
                  ),
                  Flexible(
                    child: Text(
                      // AppTexts.dailyTipsHeading,
                      widget.title ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                  IconButton(
                    onPressed: () async => createPdf(true),
                    icon: const Icon(
                      Icons.download,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 30.0),
                    child: IconButton(
                        onPressed: () async => createPdf(false),
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                        )),
                  )
                ],
              ),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator()) //Text("No Tips Available")
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(ScUtil().setSp(5)),
                            //margin: EdgeInsets.only(top: 55),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                                padding: EdgeInsets.all(ScUtil().setSp(8)), child: _imageAndText()),
                          )
                          //ConsultationHistory(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
