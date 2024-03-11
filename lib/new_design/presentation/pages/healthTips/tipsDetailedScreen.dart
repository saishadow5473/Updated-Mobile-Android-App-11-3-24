import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/utils/textStyle.dart';
import '../dashboard/common_screen_for_navigation.dart';
import 'package:open_file_plus/open_file_plus.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../utils/screenutil.dart';

import 'package:http/http.dart' as http;

import '../../../app/utils/appColors.dart';
import '../home/landingPage.dart';

class TipsDetailedScreen extends StatefulWidget {
  const TipsDetailedScreen(
      {Key key,
      @required this.imagepath,
      @required this.message,
      @required this.title,
      @required this.fromNotification})
      : super(key: key);
  final String imagepath;
  final String message;
  final String title;
  final bool fromNotification;

  @override
  State<TipsDetailedScreen> createState() => _TipsDetailedScreenState();
}

Future<Uint8List> getPngBlobData(String blobUrl) async {
  final http.Response response = await http.get(Uri.parse(blobUrl));

  if (response.statusCode == 200) {
    return Uint8List.fromList(response.bodyBytes);
  } else {
    throw Exception('Failed to load PNG blob data');
  }
}

Widget shimmerPlaceholder() {
  return Shimmer.fromColors(
    baseColor: Color.fromARGB(255, 240, 240, 240),
    highlightColor: Colors.blue.withOpacity(0.2), // Color of the shimmering effect when active
    child: Center(
      child: Container(
          height: 60.h,
          width: 85.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.grey[300],
          )), // Background color of the container
    ),
  );
}

class _TipsDetailedScreenState extends State<TipsDetailedScreen> {
  int imageNumber = Random().nextInt(4);

  @override
  void initState() {
    if (widget.fromNotification) {
      checkFromNotification();
    }
    super.initState();
  }

  checkFromNotification() {
    fromnotification = true;
  }

  bool loading = false;
  bool fromnotification = false;
  makePdf(bool isDownloads, Size size) async {
    pw.Font font = await PdfGoogleFonts.aBeeZeeItalic();
    final pw.Document pdf = pw.Document();
    // final ByteData bytes = await rootBundle.load("assets/fonts/arial.ttf");
    // final Uint8List byteList = bytes.buffer.asUint8List();
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(widget.imagepath)).load(widget.imagepath))
        .buffer
        .asUint8List();
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
                child: pw.Image(pw.MemoryImage(bytes),
                    fit: pw.BoxFit.fitHeight, height: 100.w, width: 100.w)),
            pw.Divider(borderStyle: pw.BorderStyle.dashed),
            pw.Center(
              child: pw.Text(widget.message.replaceAll("\r", "")),
            )
          ]);
        }));

    if (isDownloads) {
      Directory internalDirectory;
      Object dir;
      final Directory directory = await getApplicationDocumentsDirectory();
      List<Directory> downloadsDirectory;
      try {
        downloadsDirectory = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      } catch (e) {
        print(e);
      }
      if (downloadsDirectory == null
          //  &&
          //  downloadsDirectory.isEmpty
          ) {
        internalDirectory = await getApplicationDocumentsDirectory();
        // if (Platform.isAndroid) {
        //   internalDirectory = await getApplicationDocumentsDirectory();
        // } else {
        //   try {
        //     internalDirectory = await getApplicationSupportDirectory();
        //     print(internalDirectory);
        //   } catch (e) {
        //     print(e);
        //   }
        // }
        print(internalDirectory);
      }
      if (downloadsDirectory != null) {
        dir = downloadsDirectory[0].path ?? internalDirectory;
      } else {
        dir = internalDirectory.path;
      }

      print(dir);
      final String path = '$dir/' + widget.title + ".pdf";
      final File file = File(path);
      //String dir = directory.toString().replaceAll('Directory: ', '');
      try {
        File r = await file.writeAsBytes(await pdf.save());
        OpenFile.open(r.path);
        print(r);
      } catch (e) {
        print(e);
      }

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
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        if (fromnotification) {
          Get.off(LandingPage());
        } else {
          Get.back(canPop: true);
        }
      },
      child: CommonScreenForNavigation(
          // contentColor: "True",
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            leading: GestureDetector(
                onTap: () {
                  if (fromnotification) {
                    Get.offAll(LandingPage());
                  } else {
                    Get.back(canPop: true);
                  }
                },
                child: const Icon(Icons.arrow_back_ios)),
            automaticallyImplyLeading: false,
            title: const Text('My Health Tips'),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                    onTap: () {
                      makePdf(true, size);
                    },
                    child: const Icon(Icons.download)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                    onTap: () {
                      makePdf(false, size);
                    },
                    child: const Icon(Icons.share)),
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 1.5.h, left: 2.w, right: 2.w, bottom: 8.h),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 3.h),
                        child: FutureBuilder<Uint8List>(
                          future: getPngBlobData(widget.imagepath), // Replace with your image URL
                          builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return shimmerPlaceholder();

                              /// Display the shimmer placeholder while loading.
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');

                              ///Display Error image when image failed to load.
                            } else {
                              final Uint8List pngData = snapshot.data;
                              return Container(
                                height: 60.h,
                                width: 85.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image: MemoryImage(pngData),
                                    )),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                        child: Text(
                          widget.message
                              .toString()
                              .replaceAll('amp;', '')
                              .replaceAll('&quot;', '"')
                              .replaceAll('&#160;', '')
                              .replaceAll('&#39;', ''),
                          style: TextStyle(
                            fontSize: ScUtil().setSp(15),
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                    ]),
              ),
            ),
          )),
    );
  }

  Widget _imageAndText() => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: widget.imagepath != "" && widget.imagepath != null
                    ? InteractiveViewer(
                        panEnabled: false, // Set it to false
                        // boundaryMargin: EdgeInsets.all(100),
                        minScale: 0.5,
                        maxScale: 2,
                        child: Image.network(
                          widget.imagepath,
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
                        'assets/images/tips_image_$imageNumber.png',
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
              widget.message
                  .toString()
                  .replaceAll('amp;', '')
                  .replaceAll('&quot;', '"')
                  .replaceAll('&#160;', '')
                  .replaceAll('&#39;', ''),
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
}
