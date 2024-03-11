import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../new_design/app/utils/appColors.dart';
import '../../../../new_design/app/utils/textStyle.dart';
import '../../../../new_design/data/providers/network/apis/classImageApi/classImageApi.dart';
import '../../../../new_design/module/online_serivices/data/model/get_subscribtion_list.dart';
import '../../../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';


class ClassDetailAfterBook extends StatelessWidget {
  Subscription classDetail;
  ClassDetailAfterBook({Key key, @required this.classDetail}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return CommonScreenForNavigation(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text("Class Detail", style: TextStyle(color: Colors.white)),
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                future: ClassImage()
                    .getCourseImageURL([classDetail.courseId]),
                builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    List<String> image = snapshot.data[0]['base_64'].split(',');
                    Uint8List bytes1;
                    bytes1 = const Base64Decoder().convert(image[1].toString());
                    return bytes1 == null
                        ? const Placeholder()
                        : Padding(
                      padding: const EdgeInsets.only(
                          top: 15, left: 8, right: 8.0),
                      child: Column(
                        children: [
                          Container(
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(4.0)),
                              image: DecorationImage(
                                  image: Image.memory(
                                    base64Decode(image[1].toString()),
                                  ).image,
                                  fit: BoxFit.cover),
                            ),
                          ),

                        ],
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Shimmer.fromColors(
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
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Shimmer.fromColors(
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
                    );
                    // return Container(
                    //   child: Center(
                    //     child: CircularProgressIndicator(),
                    //   ),
                    // );
                  }
                  return Shimmer.fromColors(
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
                  );
                },
              ),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  height:100.h,
                    width: 96.w,
                    decoration: const BoxDecoration(
                    color: Colors.white,
                    ),
                  child: Column(
                    children: [
                      Padding(
                        padding:  EdgeInsets.symmetric(vertical: 2.h),
                        child: Text(classDetail.title,style: AppTextStyles.primaryColorText,),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 45.w,
                          child: Column(children:[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Trainer"),
                                Text(classDetail.consultantName)
                              ],
                            )
                          ]),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
