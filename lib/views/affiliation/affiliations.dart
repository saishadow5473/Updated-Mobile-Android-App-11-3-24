import 'dart:convert';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/affiliation/affiliationTile.dart';
import 'package:ihl/views/teleconsultation/affiliationDetails.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:ihl/views/home_screen.dart';
import 'package:ihl/widgets/offline_widget.dart';

import '../../new_design/presentation/pages/home/home_view.dart';

// ignore: must_be_immutable
class AffiliationsDashboard extends StatefulWidget {
  final String afNo1;
  final String afNo2;
  final String afNo3;
  final String afNo4;
  final String afNo5;
  final String afNo6;
  final String afNo7;
  final String afNo8;
  final String afNo9;
  final bool afNo1bool,
      afNo2bool,
      afNo3bool,
      afNo4bool,
      afNo5bool,
      afNo6bool,
      afNo7bool,
      afNo8bool,
      afNo9bool;
  final String afUnique1;
  final String afUnique2;
  final String afUnique3;
  final String afUnique4;
  final String afUnique5;
  final String afUnique6;
  final String afUnique7;
  final String afUnique8;
  final String afUnique9;

  AffiliationsDashboard(
      {Key key,
      this.afNo1,
      this.afNo2,
      this.afNo3,
      this.afNo4,
      this.afNo5,
      this.afNo6,
      this.afNo7,
      this.afNo8,
      this.afNo9,
      this.afNo1bool,
      this.afNo2bool,
      this.afNo3bool,
      this.afNo4bool,
      this.afNo5bool,
      this.afNo6bool,
      this.afNo7bool,
      this.afNo8bool,
      this.afNo9bool,
      this.afUnique1,
      this.afUnique2,
      this.afUnique3,
      this.afUnique4,
      this.afUnique5,
      this.afUnique6,
      this.afUnique7,
      this.afUnique8,
      this.afUnique9})
      : super(key: key);
  @override
  _AffiliationsDashboardState createState() => _AffiliationsDashboardState();
}

class _AffiliationsDashboardState extends State<AffiliationsDashboard> {
  http.Client _client = http.Client(); //3gb
  List companies = [];
  var logoAf1, logoAf2, logoAf3, logoAf4, logoAf5, logoAf6, logoAf7, logoAf8, logoAf9;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getAffiliateListAPI();
  }

  Future getAffiliateListAPI() async {
    final response = await _client.get(
      Uri.parse(API.iHLUrl + '/consult/get_list_of_affiliation'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    if (response.statusCode == 200) {
      companies = json.decode(response.body);
      for (int i = 0; i < companies.length; i++) {
        if (companies[i]['affiliation_unique_name'] == widget.afUnique1) {
          if (this.mounted) {
            setState(() {
              logoAf1 = companies[i]['brand_image_url'];
              loading = false;
            });
          }
        }
        if (companies[i]['affiliation_unique_name'] == widget.afUnique2) {
          if (this.mounted) {
            setState(() {
              logoAf2 = companies[i]['brand_image_url'];
              loading = false;
            });
          }
        }
        if (companies[i]['affiliation_unique_name'] == widget.afUnique3) {
          if (this.mounted) {
            setState(() {
              logoAf3 = companies[i]['brand_image_url'];
              loading = false;
            });
          }
        }
        if (companies[i]['affiliation_unique_name'] == widget.afUnique4) {
          if (this.mounted) {
            setState(() {
              logoAf4 = companies[i]['brand_image_url'];
              loading = false;
            });
          }
        }
        if (companies[i]['affiliation_unique_name'] == widget.afUnique5) {
          if (this.mounted) {
            setState(() {
              logoAf5 = companies[i]['brand_image_url'];
              loading = false;
            });
          }
        }
        if (companies[i]['affiliation_unique_name'] == widget.afUnique6) {
          if (this.mounted) {
            setState(() {
              logoAf6 = companies[i]['brand_image_url'];
              loading = false;
            });
          }
        }
        if (companies[i]['affiliation_unique_name'] == widget.afUnique7) {
          if (this.mounted) {
            setState(() {
              logoAf7 = companies[i]['brand_image_url'];
              loading = false;
            });
          }
        }
        if (companies[i]['affiliation_unique_name'] == widget.afUnique8) {
          if (this.mounted) {
            setState(() {
              logoAf8 = companies[i]['brand_image_url'];
              loading = false;
            });
          }
        }
        if (companies[i]['affiliation_unique_name'] == widget.afUnique9) {
          if (this.mounted) {
            setState(() {
              logoAf9 = companies[i]['brand_image_url'];
              loading = false;
            });
          }
        }
      }
    } else {
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: WillPopScope(
        onWillPop: () {
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => HomeScreen(introDone: true)),
          //   (Route<dynamic> route) => false);
          Get.off(LandingPage());
        },
        child: ScrollessBasicPageUI(
          appBar: Column(
            children: [
              SizedBox(
                width: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    key: Key('affiliationsDashboardBackButton'),
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        // MaterialPageRoute(builder: (context) => HomeScreen(introDone: true)),
                        MaterialPageRoute(builder: (context) => LandingPage()),
                        (Route<dynamic> route) => false),
                    color: Colors.white,
                    tooltip: 'Back',
                  ),
                  Flexible(
                    child: Center(
                      child: Text(
                        'Select Your \nAssociation',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                  )
                ],
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView(
                        children: <Widget>[
                          SizedBox(height: 10),
                          Visibility(
                            visible: widget.afNo1bool
                                ? widget.afNo1 == "empty"
                                    ? false
                                    : true
                                : false,
                            child: AffiliationTile(
                              key: Key('afNo1'),
                              leading: loading
                                  ? SpinKitFadingCircle(
                                      color: Colors.white,
                                    )
                                  : CircleAvatar(
                                      backgroundColor: AppColors.cardColor,
                                      radius: 50.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: Image(
                                            image: NetworkImage(logoAf1 ??
                                                "https://previews.123rf.com/images/mariiasimakova/mariiasimakova2004/mariiasimakova200400248/144147077-affiliate-icon-from-streaming-collection-simple-line-affiliate-icon-for-templates-web-design-and-inf.jpg")),
                                      ),
                                    ),
                              companyName: widget.afNo1 ?? "Affiliate",
                              onTap: () {
                                SpUtil.putString(SPKeys.affiliateUniqueName, widget.afUnique1);
                                // SpUtil.getString(SPKeys.affiliateUniqueName);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Details(
                                            companyName: widget.afUnique1,
                                            logo: logoAf1,
                                            affiliationName: widget.afNo1)));
                              },
                            ),
                          ),
                          SizedBox(height: 5),
                          Visibility(
                            visible: widget.afNo2bool
                                ? widget.afNo2 == "empty"
                                    ? false
                                    : true
                                : false,
                            child: AffiliationTile(
                              key: Key('afNo2'),
                              leading: loading
                                  ? SpinKitFadingCircle(
                                      color: Colors.white,
                                    )
                                  : CircleAvatar(
                                      backgroundColor: AppColors.cardColor,
                                      radius: 50.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: Image(
                                            image: NetworkImage(logoAf2 ??
                                                "https://previews.123rf.com/images/mariiasimakova/mariiasimakova2004/mariiasimakova200400248/144147077-affiliate-icon-from-streaming-collection-simple-line-affiliate-icon-for-templates-web-design-and-inf.jpg")),
                                      ),
                                    ),
                              companyName: widget.afNo2 ?? "Affiliate",
                              onTap: () {
                                SpUtil.putString(SPKeys.affiliateUniqueName, widget.afUnique2);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Details(
                                            companyName: widget.afUnique2,
                                            logo: logoAf2,
                                            affiliationName: widget.afNo2)));
                              },
                            ),
                          ),
                          SizedBox(height: 5),
                          Visibility(
                            visible: widget.afNo3bool
                                ? widget.afNo3 == "empty"
                                    ? false
                                    : true
                                : false,
                            child: AffiliationTile(
                              key: Key('afNo3'),
                              leading: loading
                                  ? SpinKitFadingCircle(
                                      color: Colors.white,
                                    )
                                  : CircleAvatar(
                                      backgroundColor: AppColors.cardColor,
                                      radius: 50.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: Image(
                                            image: NetworkImage(logoAf3 ??
                                                "https://previews.123rf.com/images/mariiasimakova/mariiasimakova2004/mariiasimakova200400248/144147077-affiliate-icon-from-streaming-collection-simple-line-affiliate-icon-for-templates-web-design-and-inf.jpg")),
                                      ),
                                    ),
                              companyName: widget.afNo3 ?? "Affiliate",
                              onTap: () {
                                SpUtil.putString(SPKeys.affiliateUniqueName, widget.afUnique3);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Details(
                                            companyName: widget.afUnique3,
                                            logo: logoAf3,
                                            affiliationName: widget.afNo3)));
                              },
                            ),
                          ),
                          SizedBox(height: 5),
                          Visibility(
                            visible: widget.afNo4bool
                                ? widget.afNo4 == "empty"
                                    ? false
                                    : true
                                : false,
                            child: AffiliationTile(
                              key: Key('afNo4'),
                              leading: loading
                                  ? SpinKitFadingCircle(color: Colors.white)
                                  : CircleAvatar(
                                      backgroundColor: AppColors.cardColor,
                                      radius: 50.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: Image(
                                            image: NetworkImage(logoAf4 ??
                                                "https://previews.123rf.com/images/mariiasimakova/mariiasimakova2004/mariiasimakova200400248/144147077-affiliate-icon-from-streaming-collection-simple-line-affiliate-icon-for-templates-web-design-and-inf.jpg")),
                                      ),
                                    ),
                              companyName: widget.afNo4 ?? "Affiliate",
                              onTap: () {
                                SpUtil.putString(SPKeys.affiliateUniqueName, widget.afUnique4);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Details(
                                            companyName: widget.afUnique4,
                                            logo: logoAf4,
                                            affiliationName: widget.afNo4)));
                              },
                            ),
                          ),
                          SizedBox(height: 5),
                          Visibility(
                            visible: widget.afNo5bool
                                ? widget.afNo5 == "empty"
                                    ? false
                                    : true
                                : false,
                            child: AffiliationTile(
                              key: Key('afNo5'),
                              leading: loading
                                  ? SpinKitFadingCircle(color: Colors.white)
                                  : CircleAvatar(
                                      backgroundColor: AppColors.cardColor,
                                      radius: 50.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: Image(
                                            image: NetworkImage(logoAf5 ??
                                                "https://previews.123rf.com/images/mariiasimakova/mariiasimakova2004/mariiasimakova200400248/144147077-affiliate-icon-from-streaming-collection-simple-line-affiliate-icon-for-templates-web-design-and-inf.jpg")),
                                      ),
                                    ),
                              companyName: widget.afNo5 ?? "Affiliate",
                              onTap: () {
                                SpUtil.putString(SPKeys.affiliateUniqueName, widget.afUnique5);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Details(
                                            companyName: widget.afUnique5,
                                            logo: logoAf5,
                                            affiliationName: widget.afNo5)));
                              },
                            ),
                          ),
                          SizedBox(height: 5),
                          Visibility(
                            visible: widget.afNo6bool
                                ? widget.afNo6 == "empty"
                                    ? false
                                    : true
                                : false,
                            child: AffiliationTile(
                              key: Key('afNo6'),
                              leading: loading
                                  ? SpinKitFadingCircle(color: Colors.white)
                                  : CircleAvatar(
                                      backgroundColor: AppColors.cardColor,
                                      radius: 50.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: Image(
                                            image: NetworkImage(logoAf6 ??
                                                "https://previews.123rf.com/images/mariiasimakova/mariiasimakova2004/mariiasimakova200400248/144147077-affiliate-icon-from-streaming-collection-simple-line-affiliate-icon-for-templates-web-design-and-inf.jpg")),
                                      ),
                                    ),
                              companyName: widget.afNo6 ?? "Affiliate",
                              onTap: () {
                                SpUtil.putString(SPKeys.affiliateUniqueName, widget.afUnique6);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Details(
                                            companyName: widget.afUnique6,
                                            logo: logoAf6,
                                            affiliationName: widget.afNo6)));
                              },
                            ),
                          ),
                          SizedBox(height: 5),
                          Visibility(
                            visible: widget.afNo7bool
                                ? widget.afNo7 == "empty"
                                    ? false
                                    : true
                                : false,
                            child: AffiliationTile(
                              key: Key('afNo7'),
                              leading: loading
                                  ? SpinKitFadingCircle(color: Colors.white)
                                  : CircleAvatar(
                                      backgroundColor: AppColors.cardColor,
                                      radius: 50.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: Image(
                                            image: NetworkImage(logoAf7 ??
                                                "https://previews.123rf.com/images/mariiasimakova/mariiasimakova2004/mariiasimakova200400248/144147077-affiliate-icon-from-streaming-collection-simple-line-affiliate-icon-for-templates-web-design-and-inf.jpg")),
                                      ),
                                    ),
                              companyName: widget.afNo7 ?? "Affiliate",
                              onTap: () {
                                SpUtil.putString(SPKeys.affiliateUniqueName, widget.afUnique7);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Details(
                                            companyName: widget.afUnique7,
                                            logo: logoAf7,
                                            affiliationName: widget.afNo7)));
                              },
                            ),
                          ),
                          SizedBox(height: 5),
                          Visibility(
                            visible: widget.afNo8bool
                                ? widget.afNo8 == "empty"
                                    ? false
                                    : true
                                : false,
                            child: AffiliationTile(
                              key: Key('afNo8'),
                              leading: loading
                                  ? SpinKitFadingCircle(color: Colors.white)
                                  : CircleAvatar(
                                      backgroundColor: AppColors.cardColor,
                                      radius: 50.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: Image(
                                            image: NetworkImage(logoAf8 ??
                                                "https://previews.123rf.com/images/mariiasimakova/mariiasimakova2004/mariiasimakova200400248/144147077-affiliate-icon-from-streaming-collection-simple-line-affiliate-icon-for-templates-web-design-and-inf.jpg")),
                                      ),
                                    ),
                              companyName: widget.afNo8 ?? "Affiliate",
                              onTap: () {
                                SpUtil.putString(SPKeys.affiliateUniqueName, widget.afUnique8);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Details(
                                            companyName: widget.afUnique8,
                                            logo: logoAf8,
                                            affiliationName: widget.afNo8)));
                              },
                            ),
                          ),
                          SizedBox(height: 5),
                          Visibility(
                            visible: widget.afNo9bool
                                ? widget.afNo9 == "empty"
                                    ? false
                                    : true
                                : false,
                            child: AffiliationTile(
                              key: Key('afNo9'),
                              leading: loading
                                  ? SpinKitFadingCircle(
                                      color: Colors.white,
                                    )
                                  : CircleAvatar(
                                      backgroundColor: AppColors.cardColor,
                                      radius: 50.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: Image(
                                            image: NetworkImage(logoAf9 ??
                                                "https://previews.123rf.com/images/mariiasimakova/mariiasimakova2004/mariiasimakova200400248/144147077-affiliate-icon-from-streaming-collection-simple-line-affiliate-icon-for-templates-web-design-and-inf.jpg")),
                                      ),
                                    ),
                              companyName: widget.afNo9 ?? "Affiliate",
                              onTap: () {
                                SpUtil.putString(SPKeys.affiliateUniqueName, widget.afUnique9);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Details(
                                              companyName: widget.afUnique9,
                                              logo: logoAf9,
                                              affiliationName: widget.afNo9,
                                            )));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
