import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:ihl/new_design/presentation/pages/aboutIHL/aboutIHLDetailedScreen.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:ihl/widgets/toc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants/api.dart';
import '../../../app/utils/appText.dart';

class AboutIhl extends StatefulWidget {
  const AboutIhl({Key key}) : super(key: key);

  @override
  State<AboutIhl> createState() => _AboutIhlState();
}

class _AboutIhlState extends State<AboutIhl> {
  var IHLTermsResponse;
  ValueNotifier<bool> loading = ValueNotifier(false);
  List<String> titleNames = [
    'About India Health Link',
    'Disclaimer',
    'Teleconsultation Terms & Conditions',
    'Privacy Policy',
    'Grievance Policy',
    'Refund Policy'
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<String> fetchAbout() async {
    final prefs = await SharedPreferences.getInstance();
    var aboutIHL = prefs.get('IHLTermsandPolicies');
    try {
      aboutIHL = json.decode(aboutIHL);
    } catch (e) {
      print(e.toString());
      aboutIHL = await getTerms();
    }
    return aboutIHL;
  }

  Future getTerms() async {
    final Dio dio = Dio();
    final getTermsURL = '${API.iHLUrl}/data/getterms';
    final response = await dio.get(
      getTermsURL,
    );
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("IHLTermsandPolicies", response.data);
      return response.data;
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: AppBar(
        title: const Text('About IHL'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 28.sp,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 2.h,
          ),
          Container(
            height: 14.h,
            width: 100.w,
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/images/logoWithoutBG.png'))),
          ),
          SizedBox(
            height: 1.h,
          ),
          SingleChildScrollView(
            child: Column(
                children: titleNames.map((e) {
              return FutureBuilder(
                  future: fetchAbout(),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      return Column(
                        children: [
                          titleCard(e, snap.data),
                          SizedBox(
                            height: 2.h,
                          )
                        ],
                      );
                    }
                    if (snap.hasError) {
                      return const CircularProgressIndicator();
                    }
                    return Container();
                  });
            }).toList()),
          ),
          SizedBox(
            height: 4.h,
          ),
        ],
      ),
    );
  }

  String _parseHtmlString(String htmlString) {
    var document = parse(htmlString);
    String parsedString = parse(document.body.text).documentElement.text;
    return parsedString;
  }

  GestureDetector titleCard(String name, String content) {
    String formattedContent;

    if (name == 'About India Health Link') {
      formattedContent = aboutIHL;
    } else if (name == 'Disclaimer') {
      formattedContent =
          _parseHtmlString(content.replaceAll("&quot", "").substring(54, 1024) ?? '');
    } else if (name == 'Teleconsultation Terms & Conditions') {
      formattedContent = AppTexts.tocText;
    } else if (name == 'Privacy Policy') {
      formattedContent = _parseHtmlString(content.replaceAll("&quot", "").substring(22439, 37531));
    } else if (name == 'Grievance Policy') {
      formattedContent = _parseHtmlString(content.replaceAll("&quot", "").substring(1091, 5141));
    } else if (name == 'Refund Policy') {
      formattedContent = _parseHtmlString(content.replaceAll("&quot", "").substring(37602, 38837));
    }

    return GestureDetector(
      onTap: () {
        Get.to(AboutDetailedScreeen(title: name, content: formattedContent));
      },
      child: Container(
        height: 7.h,
        width: 92.w,
        padding: EdgeInsets.only(
          top: .8.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(4, 8), // Shadow position
            ),
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(-3, 8), // Shadow position
            ),
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, -2), // Shadow position
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            Get.to(AboutDetailedScreeen(title: name, content: formattedContent));
          },
          child: Row(
            children: [
              Container(
                height: 2.5.h,
                width: 15.w,
                decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage('assets/profile_icons/$name.png'))),
              ),
              SizedBox(
                width: 72.w,
                child: name.toString().contains('Terms &')
                    ? FittedBox(
                        child: Text(name,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            )),
                      )
                    : Text(name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.5.sp,
                          fontWeight: FontWeight.w500,
                        )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String aboutIHL =
      'India Health link believes and understands how real-time health data can empower and revolutionise the health of an individual, an organization and the nation. Our unique hPod (Health Pod) allows every individual to manage and regularise their health care, learn about the risk in changing primary health vitals, and take preventive actions. This allows every organization to build its Health Score, foresee the employee health associated risk, take control and devise a strategy to improve employability, ensure wellness programs ROI, increase productivity and bottom-line growth. India Health link hPod goes beyond automated and interactive health screening and medical diagnosis, it provides an ecosystem powered by data sciences to individuals and organizations to create a safe and healthy environment at work & home, and contribute to sustainable development, which is the key to a prosperous nation';
}
