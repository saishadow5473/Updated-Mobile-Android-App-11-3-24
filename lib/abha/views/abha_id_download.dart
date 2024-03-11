import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/profile/profile_screen.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
// import 'dart:html' as html;
// import 'dart:js' as js;
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../utils/app_colors.dart';

class AbhaIdDownloadScreen extends StatefulWidget {
  const AbhaIdDownloadScreen(
      {Key key, @required this.abhaCard, @required this.abhaNumber, @required this.abhaAddress})
      : super(key: key);
  final String abhaCard, abhaNumber, abhaAddress;
  @override
  State<AbhaIdDownloadScreen> createState() => _AbhaIdDownloadScreenState();
}

class _AbhaIdDownloadScreenState extends State<AbhaIdDownloadScreen> {
  @override
  Widget build(BuildContext context) {
    List<String> finalAbhacard = widget.abhaCard.split(',');
    Uint8List _bytes1;
    _bytes1 = Base64Decoder().convert(finalAbhacard[1].toString());
    void shareImage() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/abha_card.jpg");
      await file.writeAsBytes(await _bytes1);
      Share.shareFiles([file.path], text: 'AbhaCard');
    }

    void saveImage() async {
      await ImageGallerySaver.saveImage(_bytes1);
      Get.showSnackbar(
        GetSnackBar(
          title: "Saved Successfully!!",
          message: 'Image saved to gallery',
          backgroundColor: AppColors.greenColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text("Your Health ID", style: TextStyle(color: Colors.white)),
        leading: InkWell(
          onTap: () {
            // Get.to(ProfileTab(
            //   editing: false,
            //   showdel: false,
            // ));
            Get.off(Profile());
          },
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
                onTap: () {
                  shareImage();
                },
                child: Icon(Icons.share)),
          )
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 6.h),
              Text(
                "Your Health ID Card",
                style:
                    TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black45),
              ),
              SizedBox(height: 4.h),
              Container(
                height: 380,
                width: 350,
                child: Image.memory(
                  _bytes1,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 3.h),
              abhadetails(),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () {
                  saveImage();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                  decoration: BoxDecoration(
                      color: AppColors.primaryColor, borderRadius: BorderRadius.circular(8.sp)),
                  child: Text(
                    'DOWNLOAD',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget abhadetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "ABHA Number  : ",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black54),
            ),
            Text(
              "ABHA Address  : ",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              " " + widget.abhaNumber,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black45),
            ),
            Text(
              " " + widget.abhaAddress,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black45),
            ),
          ],
        ),
      ],
    );
  }
}
