import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../new_design/app/utils/appText.dart';

class About extends StatefulWidget {
  const About({Key key}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  http.Client _client = http.Client(); //3gb
  String _parseHtmlString(String htmlString) {
    var document = parse(htmlString);
    String parsedString = parse(document.body.text).documentElement.text;
    return parsedString;
  }

  // ignore: non_constant_identifier_names
  var IHLTermsResponse;
  bool isLoading = false;
  final disclaimer = new GlobalKey();
  final grievance = new GlobalKey();
  final terms = new GlobalKey();
  final privacy = new GlobalKey();
  final refund = new GlobalKey();
  final aboutUs = new GlobalKey();

  String stringify(va) {
    if (va is String) {
      if (va != null) {
        return va;
      }
    }
    return '';
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
    final getTermsURL = API.iHLUrl + '/data/getterms';
    final response = await _client.get(
      Uri.parse(getTermsURL),
    );
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("IHLTermsandPolicies", response.body);
      return response.body;
    } else {}
  }

  @override
  void initState() {
    super.initState();
    this.fetchAbout().then((value) {
      if (this.mounted) {
        setState(() {
          IHLTermsResponse = value;
          isLoading = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    String aboutIHL =
        'India Health link believes and understands how real-time health data can empower and revolutionise the health of an individual, an organization and the nation. Our unique hPod (Health Pod) allows every individual to manage and regularise their health care, learn about the risk in changing primary health vitals, and take preventive actions. This allows every organization to build its Health Score, foresee the employee health associated risk, take control and devise a strategy to improve employability, ensure wellness programs ROI, increase productivity and bottom-line growth. India Health link hPod goes beyond automated and interactive health screening and medical diagnosis, it provides an ecosystem powered by data sciences to individuals and organizations to create a safe and healthy environment at work & home, and contribute to sustainable development, which is the key to a prosperous nation';
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => HomeScreen(introDone: true)),
        //   (Route<dynamic> route) => false);
        Get.off(LandingPage());
      },
      child: BasicPageUI(
        appBar: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => HomeScreen(introDone: true)),
                  //   (Route<dynamic> route) => false);
                  Get.back();
                },
                color: Colors.white,
                tooltip: 'Back',
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: ScUtil().setHeight(20),
              ),
              child: Text(
                'About IHL',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: ScUtil().setSp(23),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: Container(
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: ScUtil().setHeight(10)),
                Center(
                  child: Image.asset(
                    'assets/images/ihl.png',
                    height: ScUtil().setHeight(80),
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: ScUtil().setHeight(15)),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'IHL',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: ScUtil().setSp(36),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: ' ',
                              style: TextStyle(
                                color: Color(0xff66688f),
                                fontSize: ScUtil().setSp(14),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text: 'Care',
                              style: TextStyle(
                                color: Color(0xff6d6e71),
                                fontSize: ScUtil().setSp(36),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: ScUtil().setWidth(180),
                        height: 2,
                        color: AppColors.myApp,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ScUtil().setHeight(30)),
                aboutCards("About India Health Link", aboutIHL),
                aboutCards(
                    "Disclaimer",
                    _parseHtmlString(isLoading
                        ? IHLTermsResponse.replaceAll("&quot", "").substring(54, 1024)
                        : '...')),
                aboutCards(
                    "Grievance Policy",
                    _parseHtmlString(isLoading
                        ? IHLTermsResponse.replaceAll("&quot", "").substring(1091, 5141)
                        : '...')),
                aboutCards(
                    "Terms and Conditions",
                    _parseHtmlString(isLoading
                        ? IHLTermsResponse.replaceAll("&quot", "").substring(5208, 22347)
                        : '...')),
                aboutCards("TeleConsultation T & C", AppTexts.tocText),
                aboutCards(
                    "Privacy Policy",
                    _parseHtmlString(isLoading
                        ? IHLTermsResponse.replaceAll("&quot", "").substring(22439, 37531)
                        : '...')),
                aboutCards(
                    "Refund Policy",
                    _parseHtmlString(isLoading
                        ? IHLTermsResponse.replaceAll("&quot", "").substring(37602, 38837)
                        : '...')),
                SizedBox(height: ScUtil().setHeight(30)),
                Center(
                  child: Text('© 2023 IHL Pvt. Ltd'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget aboutCards(String title, String content) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Image.asset(
              'assets/images/ihl.png',
              height: ScUtil().setHeight(20),
              fit: BoxFit.fill,
            ),
            title: Text(title,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: ScUtil().setSp(17),
                )),
            onTap: () => showModalBottomSheet(
                context: context,
                builder: (context) => buildPolicySheet(title, content),
                isScrollControlled: true,
                backgroundColor: Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget makeDissmissible({@required Widget child}) => GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: GestureDetector(onTap: () {}, child: child));

  Widget buildPolicySheet(String title, String content) => makeDissmissible(
        child: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.7,
          builder: (_, controller) => Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Scrollbar(
              controller: controller,
              child: ListView(
                controller: controller,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Divider(
                    indent: 10,
                    endIndent: 10,
                    thickness: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(content, textAlign: TextAlign.justify),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildInfoCard(context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 5, left: 5, right: 5),
          child: Card(
            elevation: 2.0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 5.0, left: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.facebook,
                              color: AppColors.primaryColor,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  new Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.instagram,
                              color: AppColors.primaryColor,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  new Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.twitter,
                              color: AppColors.primaryColor,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  new Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.linkedin,
                              color: AppColors.primaryColor,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
