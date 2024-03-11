import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import '../../cardio_dashboard/views/cardio_dashboard_new.dart';
import '../../constants/api.dart';
import '../../constants/app_texts.dart';
import '../../models/DailyTipsDataModel.dart';
import '../../new_design/presentation/pages/healthTips/tipsDetailedScreen.dart';
import '../../utils/screenutil.dart';
import '../../widgets/ScrollessBasicPageUI.dart';
import 'package:lottie/lottie.dart';

import '../../new_design/presentation/controllers/dashboardControllers/upComingDetailsController.dart';
import 'tips_detail_screen.dart';

class TipsScreen extends StatefulWidget {
  var hmmNavigation;
  var affi;

  TipsScreen({Key key, this.hmmNavigation, this.affi});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  http.Client _client = http.Client(); //3gb
  bool loading = true;
  List<TipsModel> tipsList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTipsData();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        // Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(builder: (context) => HomeScreen(introDone: true)),
        //     (Route<dynamic> route) => false);
        if (widget.hmmNavigation != null) {
          Get.to(CardioDashboardNew(
            tabView: false,
          ));
        } else {
          Get.put(UpcomingDetailsController()).onInit();
          Get.back();
        }
      },
      child: Scaffold(
        body: ScrollessBasicPageUI(
          appBar: Column(
            children: [
              SizedBox(
                width: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      // Navigator.pushAndRemoveUntil(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => HomeScreen(introDone: true)),
                      //     (Route<dynamic> route) => false);
                      if (widget.hmmNavigation != null) {
                        Get.to(CardioDashboardNew(
                          tabView: false,
                        ));
                      } else {
                        Get.put(UpcomingDetailsController()).onInit();
                        Get.back();
                      }
                    },
                    color: Colors.white,
                  ),
                  Text(
                    AppTexts.dailyTipsHeading,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  SizedBox(
                    width: 40,
                  )
                ],
              ),
            ],
          ),
          body: loading
              ? Center(child: CircularProgressIndicator())
              : tipsList.length <= 0
                  ? Center(
                      child: Lottie.asset('assets/lottieFiles/no_data_found_lottie.json',
                          height: ScUtil().setHeight(300), width: ScUtil().setWidth(300)),
                    ) //Text("No Tips Available")
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                // height: MediaQuery.of(context).size.height /
                                //     1.2, // bottom white space fot the teledashboard
                                child: ListView.separated(
                                  physics: const ScrollPhysics(),
                                  primary: false,
                                  shrinkWrap: true,
                                  itemCount: tipsList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    // return ListTile(
                                    //   title: Text(tipsList[index]
                                    //       .health_tip_title
                                    //       .toString()),
                                    //   // leading: CircleAvatar(backgroundImage: NetworkImage(tipsList[index].health_tip_blob_url),),
                                    //   onTap: () async {
                                    //     try {
                                    //       final netImage = await networkImage(
                                    //           tipsList[index]
                                    //               .health_tip_blob_url);
                                    //       final pdf = pw.Document();
                                    //
                                    //       pdf.addPage(pw.MultiPage(
                                    //           theme: pw.ThemeData.withFont(
                                    //             base: pw.Font.ttf(
                                    //                 await rootBundle.load(
                                    //                     "assets/fonts/arial.ttf")),
                                    //           ),
                                    //           build: (pw.Context context) {
                                    //             return [
                                    //               pw.Partitions(children: [
                                    //                 pw.Partition(
                                    //                     child: pw.Column(
                                    //                         mainAxisAlignment: pw
                                    //                             .MainAxisAlignment
                                    //                             .start,
                                    //                         crossAxisAlignment: pw
                                    //                             .CrossAxisAlignment
                                    //                             .center,
                                    //                         children: [
                                    //                       pw.Image(
                                    //                         netImage,
                                    //                         height: 300,
                                    //                       ),
                                    //                       pw.SizedBox(
                                    //                           height: 20),
                                    //                       pw.RichText(
                                    //                         text: pw.TextSpan(
                                    //                             children: [
                                    //                               pw.TextSpan(
                                    //                                 text: tipsList[
                                    //                                         index]
                                    //                                     .message,
                                    //                               )
                                    //                             ]),
                                    //                       )
                                    //                     ])),
                                    //               ])
                                    //             ];
                                    //             // Center
                                    //           }));
                                    //       final directory =
                                    //           await getApplicationDocumentsDirectory();
                                    //
                                    //       final file = File(
                                    //           "${directory.path}/${tipsList[index].health_tip_title}.pdf");
                                    //       await file
                                    //           .writeAsBytes(await pdf.save());
                                    //       print(file.path);
                                    //       Get.to(
                                    //           PdfViewerPage(path: file.path));
                                    //     } catch (e) {
                                    //       print(e);
                                    //     }
                                    //   },
                                    // );
                                    return tipsTile(
                                        title: parseFragment(tipsList[index].health_tip_title).text,
                                        imageUrl: tipsList[index].health_tip_blob_url,
                                        thumUrl: tipsList[index].health_tip_blog_thum_url,
                                        //image needs to be added if it is requiered in future
                                        date: tipsList[index].health_tip_log,
                                        content: parseFragment(tipsList[index].message).text);
                                    // imageUrl: tipsList[index]
                                    //     .health_tip_blog_thum_url);
                                  },
                                  separatorBuilder: (context, index) {
                                    return Divider();
                                  },
                                ),
                              ),
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

  Widget tipsTile({title, thumUrl, date, content, imageUrl}) {
    var random = new Random();
    var imageNumber = random.nextInt(4);
    return ListTile(
      onTap: () => Get.to(TipsDetailedScreen(
        imagepath: imageUrl,
        message: content,
        fromNotification: false,
        title: title,
      )),
      // Get.to(
      //   () => TipsDetailScreen(
      //         fromNotification: false,
      //         title: parseFragment(title).text,
      //         imageUrl: imageUrl,
      //         thumbUrl: thumUrl,
      //         date: date,
      //         content: parseFragment(content).text,
      //         random_image_number: imageNumber,
      //       ),
      //   transition: Transition.rightToLeft),
      // showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return tipsDialogBox(parseFragment(title).text, imageUrl, date, parseFragment(content).text, imageNumber);
      //     });

      leading: SizedBox(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: thumUrl != "" && thumUrl != null
                ? Image.network(
                    thumUrl,
                    loadingBuilder:
                        (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                    height: ScUtil().setHeight(80),
                    width: ScUtil().setWidth(80),
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/tips_image_' + imageNumber.toString() + '.png',
                    height: ScUtil().setHeight(80),
                    width: ScUtil().setWidth(80),
                    fit: BoxFit.cover,
                  )),
      ),
      title: Text(
        parseFragment(title).text,
        maxLines: 2,
        style: TextStyle(
            color: Colors.black87, fontSize: ScUtil().setSp(15), fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        parseFragment(content).text,
        maxLines: 2,
        style: TextStyle(color: Colors.black54, fontSize: ScUtil().setSp(12)),
      ),
    );
  }

  Widget tipsDialogBox(title, imageUrl, date, content, random_image_number) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 5,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(ScUtil().setSp(5)),
        //margin: EdgeInsets.only(top: 55),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
            ]),
        child: Padding(
          padding: EdgeInsets.all(ScUtil().setSp(8)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: ScUtil().setHeight(15),
              ),
              SizedBox(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: imageUrl != "" && imageUrl != null
                        ? Image.network(
                            imageUrl,
                            height: ScUtil().setHeight(150),
                            width: ScUtil().setWidth(250),
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/tips_image_' + random_image_number.toString() + '.png',
                            height: ScUtil().setHeight(80),
                            width: ScUtil().setWidth(80),
                            fit: BoxFit.cover,
                          )),
              ),
              SizedBox(
                height: ScUtil().setHeight(15),
              ),
              Container(
                child: new ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: ScUtil().setHeight(450),
                  ),
                  child: SingleChildScrollView(
                      child: Text(
                    content,
                    style: TextStyle(
                      fontSize: ScUtil().setSp(15),
                    ),
                    textAlign: TextAlign.center,
                  )),
                ),
              ),
              SizedBox(
                height: ScUtil().setHeight(12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getTipsData() async {
    print(widget.affi);
    // 'ApiToken': '${API.headerr['ApiToken']}',
    // 'Token': '${API.headerr['Token']}',
    final resultTips = await _client.post(
      Uri.parse("${API.iHLUrl}/pushnotification/retrieve_affiliated_healthtip"),
      body: jsonEncode({
        "affiliation_list": widget.affi == null ? 'global_services' : '${widget.affi}',
        "start_index": 0,
        "end_index": 100,
      }),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    // dio.post(
    //   '${API.iHLUrl}/pushnotification/retrieve_affiliated_healthtip',
    //   data: jsonEncode({
    //     "affiliation_list": widget.affi == null ? 'global_services' : '${widget.affi}',
    //     "start_index": 0,
    //     "end_index": 100,
    //   }),
    //   options: Options(
    //     headers: <String, String>{
    //       'Content-Type': 'application/json',
    //       'ApiToken': '${API.headerr['ApiToken']}',
    //       'Token': '${API.headerr['Token']}',
    //     },
    //   ),
    // );
    List<TipsModel> result = [];
    try {
      if (resultTips.statusCode == 200) {
        if (resultTips.body != "" && resultTips.body != null) {
          var decValue = json.decode(resultTips.body);
          for (Map i in decValue) {
            String message = i["message"];
            message = message.replaceAll('&amp;', '&');
            message = message.replaceAll('&quot;', '"');
            message = message.replaceAll("\\r\\n", '');

            var value = TipsModel(
                health_tip_id: i["health_tip_id"],
                health_tip_title: i["health_tip_title"],
                message: message,
                health_tip_log: i["health_tip_log"],
                health_tip_blob_url: i["health_tip_blob_url"],
                health_tip_blog_thum_url: i['health_tip_blob_thumb_nail_url']);
            result.add(value);
          }
          setState(() {
            tipsList = result;
            loading = false;
          });
        }
      }
      if (mounted) {
        setState(() {
          tipsList = result;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          tipsList = result;
          loading = false;
        });
      }
    }
  }
}
//
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:html/parser.dart';
// import 'package:http/http.dart' as http;
// import 'package:ihl/Getx/HealthTipsController.dart';
// import 'package:ihl/constants/api.dart';
// import 'package:ihl/constants/app_texts.dart';
// import 'package:ihl/utils/ScUtil.dart';
// import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
//
// import '../home_screen.dart';
//
// class TipsScreen extends StatelessWidget {
//   http.Client _client = http.Client();
//   final HealthTipsController _healthTipsController = Get.find();
//   getTipsData() async {
//     final resultTips = await _client.get(
//       Uri.parse(API.iHLUrl + "/pushnotification/retrieve_healthtip_data"),
//       headers: {
//         'Content-Type': 'application/json',
//         'ApiToken': '${API.headerr['ApiToken']}',
//         'Token': '${API.headerr['Token']}',
//       },
//     );
//
//     try {
//       if (resultTips.statusCode == 200) {
//         if (resultTips.body != "" && resultTips.body != null) {
//           var decValue = json.decode(resultTips.body);
//           return decValue;
//         }
//       }
//     } catch (e) {
//       print(e);
//     }
//   }
//
//
//
//   static String getFilesizeString({@required int bytes, int decimals = 0}) {
//     const suffixes = ["b", "kb", "mb", "gb", "tb"];
//     var i = (log(bytes) / log(1024)).floor();
//     return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () {
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => HomeScreen(introDone: true)),
//             (Route<dynamic> route) => false);
//       },
//       child: Scaffold(
//         body: ScrollessBasicPageUI(
//           appBar: Column(
//             children: [
//               SizedBox(
//                 width: 20,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.arrow_back_ios),
//                     onPressed: () {
//                       Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                                   HomeScreen(introDone: true)),
//                           (Route<dynamic> route) => false);
//                     },
//                     color: Colors.white,
//                   ),
//                   Text(
//                     AppTexts.dailyTipsHeading,
//                     style: TextStyle(color: Colors.white, fontSize: 25),
//                   ),
//                   SizedBox(
//                     width: 40,
//                   )
//                 ],
//               ),
//             ],
//           ),
//           body: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//               child: GetBuilder<HealthTipsController>(builder: (_) {
//                 Random _ran = Random();
//                 return ListView.builder(
//                     itemCount: _healthTipsController.tipsList.length,
//                     itemBuilder: (c, index) {
//                       File _file = File(_healthTipsController
//                           .tipsList[index].health_tip_blob_url);
//                       print(getFilesizeString(bytes: _file.lengthSync()));
//                       //
//                       // TipsModel _tipsModel = TipsModel(
//                       //     health_tip_blob_url: _data['health_tip_blob_url'],
//                       //     health_tip_id: _data['health_tip_id'],
//                       //     health_tip_log: _data['health_tip_log'],
//                       //     health_tip_title: _data['health_tip_title'],
//                       //     message: _data['message']);
//                       return ListTile(
//                         leading: ClipRRect(
//                             borderRadius: BorderRadius.circular(6),
//                             child: Image.file(
//                               File(
//                                 _healthTipsController
//                                     .tipsList[index].health_tip_blob_url,
//                               ),
//                               height: ScUtil().setHeight(80),
//                               width: ScUtil().setWidth(80),
//                               fit: BoxFit.cover,
//                             )),
//                         title: Text(
//                           _healthTipsController
//                               .tipsList[index].health_tip_title,
//                           maxLines: 2,
//                           style: TextStyle(
//                               color: Colors.black87,
//                               fontSize: ScUtil().setSp(15),
//                               fontWeight: FontWeight.w500),
//                         ),
//                         subtitle: Text(
//                           _healthTipsController.tipsList[index].message,
//                           maxLines: 2,
//                           style: TextStyle(
//                               color: Colors.black54,
//                               fontSize: ScUtil().setSp(12)),
//                         ),
//                       );
//                     });
//               })),
//         ),
//       ),
//     );
//   }
// }
