import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import '../../Widgets/appBar.dart';
import 'newsLetterViewer.dart';
import 'package:sizer/sizer.dart';

import '../../../data/model/newsLetterModel/newsLetterModel.dart';
import '../../Widgets/healthTipWidgets/healthTipShimmer.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../controllers/newsLetterControllers/newsLetterController.dart';
import '../home/home_view.dart';

class NewsLetter extends StatefulWidget {
  const NewsLetter({Key key}) : super(key: key);

  @override
  State<NewsLetter> createState() => _NewsLetterState();
}

class _NewsLetterState extends State<NewsLetter> {
  @override
  Widget build(BuildContext context) {
    Future<Uint8List> convertNetworkPdfToBytes(String pdfUrl) async {
      try {
        Dio dio = Dio();
        dynamic response =
            await dio.get(pdfUrl, options: Options(responseType: ResponseType.bytes));
        if (response.statusCode == 200) {
          Uint8List bytes = response.data;
          return bytes;
        }
      } catch (error) {
        print('Error fetching PDF from URL: $error');
      }
      return null; // Handle network request errors
    }

    Get.put(NewsLetterController());
    bool aff = false;
    ScrollController controller = ScrollController();
    final TabBarController tabController = Get.put(TabBarController());
    if (!Tabss.featureSettings.newsLetter) {
      return Center(child: const Text("No News Letter Available"));
    } else {
      return WillPopScope(
        onWillPop: () async {
          await Get.to(LandingPage());
          return false;
        },
        child: SizedBox(
          height: 100.h,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // controller: controller,
              children: [
                // const OfferedPrograms(
                //   screenTitle: 'Social',
                //   screen: ProgramLists.commonList,
                // ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Our Newsletters',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Color(0xff19a9e5),
                        fontWeight: FontWeight.w500,
                      )),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Discover updates on nutrition, physical activity, and mental well-being.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xff585859),
                    ),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                GetBuilder<NewsLetterController>(
                    init: NewsLetterController(),
                    builder: (NewsLetterController newsLetter) {
                      return newsLetter.newsLetters != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GridView(
                                controller: controller,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                    mainAxisExtent: 25.h),
                                shrinkWrap: true,
                                children: newsLetter.newsLetters.map((NewsLetterModel e) {
                                  print(e.imageThumbUrl);
                                  if (e.imageThumbUrl == null || e.imageThumbUrl == "") {
                                    return GestureDetector(
                                      onTap: () async {
                                        Uint8List pdfBytes =
                                            await convertNetworkPdfToBytes(e.documentBlobUrl);
                                        Get.to(NewsLetterViewer(
                                          document_url: e.documentBlobUrl,
                                          document_title: parseFragment(e.documentTitle).text,
                                          document_date: e.documentPublishDate,
                                          pdf_bytes: pdfBytes,
                                        ));
                                      },
                                      child: newsLetterCard(
                                          'https://d2slcw3kip6qmk.cloudfront.net/marketing/blogs/press/13-best-newsletter-design-ideas/image07.jpg'),
                                    );
                                  } else {
                                    return GestureDetector(
                                        onTap: () async {
                                          Uint8List pdfBytes =
                                              await convertNetworkPdfToBytes(e.documentBlobUrl);
                                          Get.to(NewsLetterViewer(
                                            document_url: e.documentBlobUrl,
                                            document_title: parseFragment(e.documentTitle).text,
                                            document_date: e.documentPublishDate,
                                            pdf_bytes: pdfBytes,
                                          ));
                                        },
                                        child: newsLetterCard(e.imageThumbUrl));
                                  }
                                }).toList(),
                              ),
                            )
                          : Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: const [
                                        HealthTipShimmer(),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        HealthTipShimmer(),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: const [
                                        HealthTipShimmer(),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        HealthTipShimmer(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                    }),
                SizedBox(
                  height: 10.h,
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  Container newsLetterCard(String path) {
    return Container(
      height: 10.h,
      width: 40.w,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          path,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
