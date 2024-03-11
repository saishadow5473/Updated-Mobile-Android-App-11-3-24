import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/imageutils.dart';
import 'package:ihl/views/screens.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:ihl/widgets/teleconsulation/consultationTypeTile.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'new_speciality_type_screen.dart';

class ConsultationType extends StatefulWidget {
  final bool liveCall;
  final String companyName;
  // optionSelected
  //1 = Consult now
  //2 = book appointment
  //3 = online class
  ConsultationType({Key key, @required this.liveCall, this.companyName})
      : super(key: key);

  @override
  _ConsultationTypeState createState() => _ConsultationTypeState();
}

class _ConsultationTypeState extends State<ConsultationType> {
  http.Client _client = http.Client(); //3gb
  String iHLUserId;
  bool loading = true;
  List consultationType = [];
  bool requestError = false;
  bool hasconsultationType = false;
  final globalKey = GlobalKey<ScaffoldState>();

  Future getData() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res1 = jsonDecode(data1);
    iHLUserId = res1['User']['id'];

    final getPlatformData = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/GetPlatfromData"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, String>{'ihl_id': iHLUserId, 'cache': "true"}),
    );
    if (getPlatformData.statusCode == 200) {
    } else {
      setState(() {
        requestError = true;
      });
      print(getPlatformData.body);
    }
    if (getPlatformData.body != null) {
      Map res = jsonDecode(getPlatformData.body);
      final platformData = await SharedPreferences.getInstance();
      platformData.setString(SPKeys.platformData, getPlatformData.body);
      loading = false;
      if (res['consult_type'] == null ||
          !(res['consult_type'] is List) ||
          res['consult_type'].isEmpty) {
        if (this.mounted) {
          setState(() {
            hasconsultationType = false;
          });
        }
        return;
      }
      consultationType = res['consult_type'];

      for (int i = 0; i < consultationType.length; i++) {
        if (consultationType[i]["consultation_type_name"] ==
            "Medical Consultation") {
          consultationType[i]["consultation_type_name"] = "Doctor Consultation";
        }
        if (consultationType[i]["consultation_type_name"] == "Fitness Class") {
          consultationType.removeAt(i);
        }
      }

      // widget.liveCall
      //     ? consultationType = consultationType
      //         .where(
      //             (i) => i["consultation_type_name"] != "Doctor Consultation")
      //         .toList()
      //     // ignore: unnecessary_statements
      //     : null;

      if (this.mounted) {
        setState(() {
          hasconsultationType = true;
        });
      }
    }
  }

  void goToPage(Map toSend, {@required BuildContext context}) {
    if (widget.companyName != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SpecialityTypeScreen(
                  arg: toSend,
                  liveCall: widget.liveCall,
                  companyName: widget.companyName)));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NewSpecialtiyTypeScreen(
                  // arg: [toSend],
                  // liveCall: widget.liveCall,
                  companyName: widget.companyName)));
    }
  }

  // ignore: missing_return
  ConsultationTypeTile getTile({Map mp, @required BuildContext context}) {
    mp['livecall'] = widget.liveCall;
    // condition to check which options to show in consult now
    /*
    if (mp['consultation_type_name'] == 'Medical Consultation') {
      return ConsultationTypeTile(
        leading: createImage(mp['consultation_type_image_url'].toString()),
        text: mp['consultation_type_name'],
        onTap: () {
          //goToPage(mp, context: context);
          showDialog(
            context: context,
            child: AlertDialog(
              title: Column(
                children: [
                  Text(
                    'This Feature is Coming soon!!\n',
                    style: TextStyle(color: AppColors.primaryColor),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Try Health Consultation \n',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      color: AppColors.primaryColor,
                      child: Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        color: AppColors.primaryAccentColor,
      );
    }
    */
    if (widget.liveCall == false || widget.liveCall == true) {
      if (mp['consultation_type_name'] != 'Fitness Class' &&
          mp['consultation_type_name'] != 'Alternative Therapy') {
        return ConsultationTypeTile(
          leading: createImage(mp['consultation_type_image_url'].toString()),
          text: mp['consultation_type_name'],
          onTap: () {
            goToPage(mp, context: context);
          },
          color: AppColors.primaryAccentColor,
          //trailing: mp['consultation_type_name'] == 'Health Consultation'?SizedBox(height: 20,):SizedBox(height: 0,),
        );
      } else if (mp['consultation_type_name'] == 'Alternative Therapy' &&
          (widget.companyName == "persistent" ||
              widget.companyName == "dev_testing")) {
        return ConsultationTypeTile(
          leading: createImage(mp['consultation_type_image_url'].toString()),
          text: mp['consultation_type_name'],
          onTap: () {
            goToPage(mp, context: context);
          },
          color: AppColors.primaryAccentColor,
        );
      }
    } else {
      if (mp['consultation_type_name'] == 'Fitness Class') {
        return ConsultationTypeTile(
          leading: createImage(mp['consultation_type_image_url'].toString()),
          text: mp['consultation_type_name'],
          onTap: () {
            goToPage(mp, context: context);
          },
          color: AppColors.primaryAccentColor,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: Scaffold(
        key: globalKey,
        body: BasicPageUI(
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
                      Navigator.pop(context);
                    }, //replaces the screen to Main dashboard
                    color: Colors.white,
                  ),
                  Text(
                    AppTexts.consultationTypeDashboardTitle,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  SizedBox(
                    width: 40,
                  )
                ],
              ),
              SizedBox(
                height: 40,
              ),
            ],
          ),
          body: loading
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 70),
                      child: CircularProgressIndicator()),
                )
              : requestError
                  ? Column(
                      children: [
                        Lottie.asset('assets/error.json',
                            height: 300, width: 300),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                "Connection failed ! Please try after some time...",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: consultationType
                            .map((e) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: getTile(context: context, mp: e),
                                ))
                            .toList(),
                      ),
                    ),
        ),
      ),
    );
  }
}
