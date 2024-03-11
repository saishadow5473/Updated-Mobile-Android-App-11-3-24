import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../new_design/app/utils/appColors.dart';
import '../../new_design/data/providers/network/apis/classImageApi/classImageApi.dart';
import '../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';

class AboutClass extends StatelessWidget {
  String courseId, desc, title;
  AboutClass({Key key, this.courseId, this.desc, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          centerTitle: true,
          title: const Text("About Class", style: TextStyle(color: Colors.white)),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            height: 100.h,
            child: Column(
              children: [

                // About class data Loaded Widget
                FutureBuilder(
                  future: ClassImage().getCourseImageURL([courseId]),
                  builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      List<String> image = snapshot.data[0]['base_64'].split(',');
                      Uint8List bytes1;
                      bytes1 = const Base64Decoder().convert(image[1].toString());
                      return bytes1 == null
                          ? const Placeholder()
                          : Padding(
                              padding: const EdgeInsets.only(top: 15, left: 8, right: 8.0),
                              child: Column(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        height: 24.h,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              const BorderRadius.all(Radius.circular(4.0)),
                                          image: DecorationImage(
                                              image: Image.memory(
                                                base64Decode(image[1].toString()),
                                              ).image,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 15, left: 8, right: 8.0),
                        child: Shimmer.fromColors(
                          direction: ShimmerDirection.ltr,
                          enabled: true,
                          baseColor: Colors.white,
                          highlightColor: Colors.grey.shade300,
                          child: Container(
                            height: 40.5.w,
                            width: 90.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 15, left: 8, right: 8.0),
                        child: Shimmer.fromColors(
                          direction: ShimmerDirection.ltr,
                          enabled: true,
                          baseColor: Colors.white,
                          highlightColor: Colors.grey.shade400,
                          child: Container(
                            height: 40.5.w,
                            width: 90.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      );
                      // return Container(
                      //   child: Center(
                      //     child: CircularProgressIndicator(),
                      //   ),
                      // );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 15, left: 8, right: 8.0),
                      child: Shimmer.fromColors(
                        baseColor: Colors.white,
                        direction: ShimmerDirection.ltr,
                        highlightColor: Colors.grey.withOpacity(0.2),
                        child: Container(
                          height: 47.5.w,
                          width: 95.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.sp, right: 15.sp, top: 15.sp, bottom: 12.sp),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.5.sp,
                      color: const Color(0XFF19A9E5),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.sp, right: 15.sp, top: 15.sp, bottom: 20.sp),
                  child: Text(
                    desc,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
