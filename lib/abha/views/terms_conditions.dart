import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TermsAndConditions extends StatefulWidget {
  TermsAndConditions({
    Key key,
  }) : super(key: key);

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  http.Client _client = http.Client();
  var IHLTermsResponse;
  bool isLoading = false;
  String content;
  @override
  void initState() {
    this.fetchAbout().then((value) {
      if (this.mounted) {
        setState(() {
          IHLTermsResponse = value;
          content = IHLTermsResponse.replaceAll("&quot", "").substring(5208, 22347);
          content = content.replaceAll("&lt;br&gt;&lt;br&gt;", "");
          content = content.replaceAll('&lt;br&gt;', "");
          content = content.replaceAll(';', " ");
          isLoading = true;
        });
      }
    });
    super.initState();
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

  ScrollController controller = new ScrollController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Scrollbar(
                controller: controller,
                child: ListView(
                  controller: controller,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: Icon(Icons.arrow_back_ios)),
                        Text(
                          'Terms And Conditions',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      thickness: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(content.toString(), textAlign: TextAlign.justify),
                    ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor: Colors.blue,
      //   label: Text("  Confirm  "),
      //   onPressed: () {
      //     setState(() {
      //       termsAndConditions = true;
      //     });
      //     Get.back();
      //   },
      // ),
    );
  }
}
