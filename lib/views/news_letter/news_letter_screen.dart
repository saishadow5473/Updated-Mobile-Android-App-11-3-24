import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/models/NewsLetterDataModel.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/news_letter/news_letter_pdf_viewer.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:html/parser.dart';

class NewsLetterScreen extends StatefulWidget {
  const NewsLetterScreen({Key key}) : super(key: key);

  @override
  State<NewsLetterScreen> createState() => _NewsLetterScreenState();
}

class _NewsLetterScreenState extends State<NewsLetterScreen> {
  bool loading = true;
  List<NewsModel> newsList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNewsData();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        // Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => HomeScreen(introDone: true)),
        //     (Route<dynamic> route) => false);
        Get.back();
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
                      //     MaterialPageRoute(
                      //         builder: (context) =>
                      //             HomeScreen(introDone: true)),
                      //     (Route<dynamic> route) => false);
                      Get.back();
                    },
                    color: Colors.white,
                  ),
                  Text(
                    AppTexts.newsLetterHeading,
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
              : newsList.length <= 0
                  ? Center(
                      child: Lottie.asset('assets/lottieFiles/no_data_found_lottie.json',
                          height: ScUtil().setHeight(300), width: ScUtil().setWidth(300)),
                    )
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
                                  itemCount: newsList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return newsTile(
                                        parseFragment(newsList[index].document_title).text,
                                        newsList[index].document_publish_date,
                                        newsList[index].document_blob_url);
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

  Widget newsTile(title, date, document_url) {
    var random = new Random();
    var imageNumber = random.nextInt(4);
    return ListTile(
      onTap: () async {
        setState(() {
          loading = true;
        });
        String pathPDF = "";
        var filePath = await createFileOfPdfUrl(parseFragment(title).text, date, document_url);
        setState(() {
          pathPDF = filePath.path;
          print(pathPDF);
          loading = false;
        });
        var pdfBytes = await filePath.readAsBytes(); //used for download on next screen
        Get.to(NewsLetterPdfViewer(
          document_url: document_url,
          document_title: parseFragment(title).text,
          document_date: date,
          pdf_bytes: pdfBytes,
        ));
      },
      leading: Icon(
        FontAwesomeIcons.filePdf,
        color: Colors.redAccent,
      ),
      title: Text(
        parseFragment(title).text,
        maxLines: 2,
        style: TextStyle(
            color: Colors.black87, fontSize: ScUtil().setSp(15), fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        date,
        maxLines: 2,
        style: TextStyle(
            color: Colors.grey, fontSize: ScUtil().setSp(12), fontWeight: FontWeight.w500),
      ),
    );
  }

  getNewsData() async {
    http.Client _client = http.Client(); //3gb
    final resultTips = await _client.get(
      Uri.parse(API.iHLUrl + "/pushnotification/retrieve_newsletter_detail"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    List<NewsModel> result = [];
    try {
      if (resultTips.statusCode == 200) {
        if (resultTips.body != "" && resultTips.body != null) {
          var decValue = json.decode(resultTips.body);
          for (Map i in decValue) {
            String message = i["document_title"];
            message = message.replaceAll('&amp;', '&');
            message = message.replaceAll('&quot;', '"');
            var value = NewsModel(
                i["document_id"], message, i["document_publish_date"], i["document_blob_url"]);
            result.add(value);
          }
          setState(() {
            newsList = result;
            loading = false;
          });
        }
      }
      setState(() {
        newsList = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        newsList = result;
        loading = false;
      });
    }
  }

  Future<File> createFileOfPdfUrl(document_title, document_date, document_url) async {
    final filename = document_title + document_date;
    http.Client _client = http.Client(); //3gb
    var request = await _client.get(
      Uri.parse(document_url),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    //var bytes = await consolidateHttpClientResponseBytes(request.bodyBytes);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(request.bodyBytes);
    return file;
  }
}
