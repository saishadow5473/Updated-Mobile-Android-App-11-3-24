import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../new_design/presentation/pages/healthTips/tipsDetailedScreen.dart';

class CustomAtricleTile extends StatelessWidget {
  const CustomAtricleTile(
      {Key key,
      @required this.title,
      @required this.text,
      @required this.imageUrl,
      @required this.date,
      @required this.thumbnailUrl})
      : super(key: key);
  final title, text, imageUrl, date, thumbnailUrl;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    String t = text;
    var random = new Random();
    var imageNumber = random.nextInt(4);
    createPdf() async {
      try {
        final netImage = await networkImage(imageUrl);
        final pdf = pw.Document();

        pdf.addPage(pw.MultiPage(
            theme: pw.ThemeData.withFont(
              base: pw.Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
            ),
            build: (pw.Context context) {
              return [
                pw.Partitions(children: [
                  pw.Partition(
                      child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                        pw.Image(
                          netImage,
                          height: 300,
                        ),
                        pw.SizedBox(height: 20),
                        pw.RichText(
                          text: pw.TextSpan(children: [
                            pw.WidgetSpan(child: pw.Text(text, textAlign: pw.TextAlign.justify))
                          ]),
                        )
                      ])),
                ])
              ];
              // Center
            }));
        final directory = await getApplicationDocumentsDirectory();

        final file = File("${directory.path}/${title}.pdf");
        await file.writeAsBytes(await pdf.save());
        Share.shareFiles([file.path], text: title);
        // print(file.path);
        // Get.to(PdfViewerPage(path: file.path));
      } catch (e) {
        print(e);
      }
      // Share.shareFiles([file.path]);
    }

    try {
      return GestureDetector(
        // onTap: () => Get.to(
        //     () => TipsDetailScreen(
        //           fromNotification: false,
        //           thumbUrl: thumbnailUrl,
        //           title: title,
        //           imageUrl: imageUrl,
        //           date: date,
        //           content: text,
        //           random_image_number: imageNumber,
        //         ),
        //     transition: Transition.rightToLeft),
        // onTap: () {
        onTap: () {
          Get.to(TipsDetailedScreen(
            imagepath: imageUrl,
            message: text,
            fromNotification: false,
            title: title,
          ));
        },

        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 60.w,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(offset: Offset(1, 1), color: Colors.grey.shade400, blurRadius: 16),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: size.width < 350 ? 29.h : 35.h,
                  width: 55.w,
                  child: thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: thumbnailUrl,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                                height: 28.h,
                                width: 45.w,
                                child: Shimmer.fromColors(
                                    child: Container(
                                        margin: EdgeInsets.all(8),
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.width / 5,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text('Hello')),
                                    direction: ShimmerDirection.ltr,
                                    period: Duration(seconds: 2),
                                    baseColor: Color.fromARGB(255, 240, 240, 240),
                                    highlightColor: Colors.grey.withOpacity(0.2))),
                          ),
                          errorWidget: (context, url, error) =>
                              Image.asset('assets/images/user.jpg'),
                        )
                      : Container(),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Text(title),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: t.length < 70 ? t : (t.substring(0, 45) + ".."),
                          style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 15.sp, color: Colors.grey.shade600),
                        ),
                        WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                                // onTap: () => Get.to(
                                //     () => TipsDetailScreen(
                                //           fromNotification: false,
                                //           thumbUrl: thumbnailUrl,
                                //           title: title,
                                //           imageUrl: imageUrl,
                                //           date: date,
                                //           content: text,
                                //           random_image_number: imageNumber,
                                //         ),
                                //     transition: Transition.rightToLeft),
                                onTap: () {
                                  Get.to(TipsDetailedScreen(
                                    imagepath: imageUrl,
                                    message: text,
                                    fromNotification: false,
                                    title: title,
                                  ));
                                },
                                child: Text(
                                  "more",
                                  style: TextStyle(fontSize: 15.sp, color: Colors.blue),
                                )))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return CircularProgressIndicator();
    }
  }
}
