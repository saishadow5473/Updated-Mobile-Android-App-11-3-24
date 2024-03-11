import 'dart:async';
import 'dart:convert';
// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/views/cardiovascular_views/cardio_age.dart';
import 'package:ihl/views/cardiovascular_views/cardio_cholestrol.dart';
import 'package:ihl/views/cardiovascular_views/cardio_cvd.dart';
import 'package:ihl/views/cardiovascular_views/cardio_diabetes.dart';
import 'package:ihl/views/cardiovascular_views/cardio_file_.dart';
import 'package:ihl/views/cardiovascular_views/cardio_gender.dart';
import 'package:ihl/views/cardiovascular_views/cardio_hdl.dart';
import 'package:ihl/views/cardiovascular_views/cardio_ht.dart';
import 'package:ihl/views/cardiovascular_views/cardio_hypertension.dart';
import 'package:ihl/views/cardiovascular_views/cardio_isSmoker.dart';
import 'package:ihl/views/cardiovascular_views/cardio_wt.dart';
import 'package:ihl/views/cardiovascular_views/directio_repo.dart';
import 'package:ihl/views/cardiovascular_views/direction_model.dart';
import 'package:ihl/views/cardiovascular_views/show_required_vitals.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/re_designed_home_screen.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:ihl/widgets/cardiovascular/cardiovascular_card_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'cardio_ldl.dart';

// var currentIndexOfCardio = ValueNotifier<int>(0);

class ShowingKisokValues extends StatefulWidget {
  const ShowingKisokValues();

  @override
  State<ShowingKisokValues> createState() => _ShowingKisokValuesState();
}

class _ShowingKisokValuesState extends State<ShowingKisokValues> {
  http.Client _client = http.Client(); //3gb
  @override
  void initState() {
    getKioskData();
    super.initState();
  }

  Map vitals;
  getKioskData() async {
    await _determinePosition();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    var res = jsonDecode(data);
    vitals = res["LastCheckin"];
    if (vitals != null) {
      vitals.removeWhere((key, value) =>
          // key != "dateTimeFormatted" &&
          key != "dateTime" &&
          //pulsebpm
          key != "diastolic" &&
          key != "systolic" &&
          key != "pulseBpm" &&
          key != "bpClass" &&
          //BMC
          key != "fatRatio" &&
          key != "fatClass" &&
          key != "percent_body_fat" &&
          key != "percent_body_fat_status" &&

          //ECG
          key != "leadTwoStatus" &&
          key != "ecgBpm" &&
          //BMI
          key != "weightKG" &&
          key != "heightMeters" &&
          key != "bmi" &&
          key != "bmiClass" &&
          //spo2
          key != "spo2" &&
          key != "spo2Class" &&
          //temprature
          key != "temperature" &&
          key != "temperatureClass" &&
          //waist_to_hip_ratio
          key != "waist_hip_ratio" &&
          key != "waist_hip_ratio_status" &&
          //visceral_fat
          key != "visceral_fat" &&
          key != "visceral_fat_status" &&
          //body_fat_mass
          key != "body_fat_mass" &&
          key != "body_fat_mass_status");
      vitals.forEach((key, value) {
        if (key == "weightKG") {
          vitals["weightKG"] = double.parse((value).toStringAsFixed(2));
        }
        if (key == "heightMeters") {
          vitals["heightMeters"] = double.parse((value).toStringAsFixed(2));
        }
      });
      vitals.removeWhere((key, value) => value == "");
    }
    print(vitals);
    if (vitals.toString() != "null" &&
        vitals.toString() != "[]" &&
        vitals.toString() != "") {
      age = res['User']['dateOfBirth'];
      gender = res['User']['gender'];
      // height = vitals['heightMeters'] ?? '';
      weight = vitals['weightKG'];
      if (weight == null) {
        weight = res['User']['userInputWeightInKG'];
      }
      bmi = vitals['bmi'];
      bmi_status = vitals['bmiClass'];
      systolic_blood_pressure =
          vitals['systolic'].toString() + '/' + vitals['diastolic'].toString();
      systolic_blood_pressure_status = vitals['bpClass'];
      percentage_body_fat = vitals['percent_body_fat'];
      percentage_body_fat_status = vitals['percent_body_fat_status'];
      body_fat_mass = vitals['body_fat_mass'];
      body_fat_mass_status = vitals['body_fat_mass_status'];
      visceral_fat = vitals['visceral_fat'];
      visceral_fat_status = vitals['visceral_fat_status'];
      waist_to_hip_ratio = vitals['waist_hip_ratio'];
      waist_to_hip_ratio_status = vitals['waist_hip_ratio_status'];
      checkAvailabilityOfVitals();
    } else {
      vitalsExpired = true;
      await createMarker();
    }
  }

  bool vitalsExpired = false;
  var vitalsExpiredTxt =
      'Last checkup should be under 7 days. \nVisit your Nearby H-pod for Vital Checkup. \n H - Pod Nearby your location : \n';
  var someVitalsNotAvailable =
      'Some Vital are Not available for Cardiovascular Checkup. \nVisit your Nearby H-Pod for Vital Checkup. \n H - Pod Nearby your location : \n';
  List notAvailableKeys = [];
  checkAvailabilityOfVitals() async {
    ///1.)  if vital are older than a week , Than show map
    var lastCheckinDateString = int.parse(vitals['dateTime']
        .toString()
        .replaceAll('/Date(', '')
        .replaceAll(')/', ''));
    DateTime lastCheckinDate =
        DateTime.fromMillisecondsSinceEpoch(lastCheckinDateString);
    if (lastCheckinDate.isBefore(DateTime.now().subtract(Duration(days: 7)))) {
      // if (false) {
      vitalsExpired = true;
      await createMarker();
    }

    /// 2.) vitals are latest -> than check all the vital are available or not
    else {
      List keys = [
        'heightMeters',
        'weightKG',
        'bmi',
        'bmiClass',
        'systolic',
        // 'percent_body_fat',
        // 'percent_body_fat_status',
        // 'body_fat_mass',
        // 'body_fat_mass_status',
        // 'visceral_fat',
        // 'visceral_fat_status',
        // 'waist_hip_ratio',
        // 'waist_hip_ratio_status'
      ];

      for (int i = 0; i < keys.length; i++) {
        if (vitals.containsKey(keys[i].toString())) {
          //nothing
        } else {
          // notAvailableKeys.add(keys[i].toString());
        }
      }

      if (notAvailableKeys.length > 0) {
        await createMarker();
        // if(mounted){
        //   setState(() {
        //     someVitalsNotAvailable =
        //     'Some Vitals(${notAvailableKeys.toString().replaceAll('[', '').replaceAll(']', '')}) are Not available for Cardiovascular Checkup. \nVisit your Nearby Kiosk for Vital Checkup. \n Nearby Kiosk : \n';
        //   });
        // }
      }

      ///all the vitals are available then naavigate to questionnn.
      else {
        ///navigation to questonarrie
        Navigator.of(context).pushReplacementNamed(Routes.CardiovascularSurvey);
      }
    }
  }

  var age;
  var gender;
  var height;
  var weight;
  var bmi;
  var bmi_status;
  var systolic_blood_pressure;
  var systolic_blood_pressure_status;
  var percentage_body_fat;
  var percentage_body_fat_status;
  var body_fat_mass;
  var body_fat_mass_status;
  var visceral_fat;
  var visceral_fat_status;
  var waist_to_hip_ratio;
  var waist_to_hip_ratio_status;
  bool loading = true;

  // Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _googleMapController;
  Marker _origin;
  Marker _destination;
  Directions _info;
  List<Marker> markers = [];

  static CameraPosition _initialCordinate = CameraPosition(
    target: LatLng(13.0135125, 80.200097),
    tilt: 59.440717697143555,
    zoom: 19.4746,
  );

  @override
  void dispose() {
    _googleMapController?.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  getKioskLocations() async {
    try {
      final response = await _client
          .get(Uri.parse(API.iHLUrl + '/empcardiohealth/fetch_kiosk_details'));
      if (response.statusCode == 200) {
        if (response.body != 'null' && response.body != '') {
          List data = jsonDecode(response.body);
          var markersDetails = [];
          data.forEach((element) {
            markersDetails.add(
              {
                'pos': LatLng(double.tryParse(element['Latitude']),
                    double.tryParse(element['Longitude'])),
                'id': 'kiosk_${data.indexOf(element).toString()}',
                'title': element['OrgAddress'].toString() +
                    ' ' +
                    element['OrgAddressLine2'].toString()
              },
            );
          });
          return markersDetails;
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // var markersDetails = [
  // {
  //   'pos': LatLng(13.013660760152224, 80.20033176988365),
  //   'id': 'kiosk1',
  //   'title': 'kiosk hpod'
  // },
  // {
  //   'pos': LatLng(13.013614047048542, 80.20006891340017),
  //   'id': 'kiosk2',
  //   'title': 'kiosk hpod 2'
  // },
  // ];
  createMarker() async {
    List markersDetails = await getKioskLocations() ?? [];
    for (int i = 0; i < markersDetails.length; i++) {
      _addMarker(markersDetails[i]['pos'], markersDetails[i]['id'],
          markersDetails[i]['title']);
    }
    // await Future.delayed(Duration(seconds: 1));
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ScUtil.init(context,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        allowFontScaling: true);
    return Scaffold(
      backgroundColor: FitnessAppTheme.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: Icon(
      //       Icons.arrow_back_ios,
      //       color: Colors.white,
      //     ),
      //     onPressed: () => Navigator.pushAndRemoveUntil(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => HomeScreen(
      //             introDone: true,
      //           ),
      //         ),
      //         (Route<dynamic> route) => false),
      //   ),
      //   title: Text(
      //     "Vital Details",
      //     style: TextStyle(
      //         fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.white),
      //   ),
      //   centerTitle: true,
      // ),
      floatingActionButton: Visibility(
        visible: !loading,
        child: FloatingActionButton(
          child: Icon(Icons.my_location),
          onPressed: () {
            _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(_initialCordinate));
          },
        ),
      ),
      body: !loading
          ? SafeArea(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: ScUtil().setWidth(15),
                        right: ScUtil().setWidth(15),
                        top: ScUtil().setHeight(15),
                        bottom: ScUtil().setHeight(15)),
                    padding: EdgeInsets.only(
                      left: ScUtil().setWidth(14),
                      right: ScUtil().setWidth(17),
                      top: ScUtil().setHeight(15),
                      bottom: ScUtil().setHeight(15),
                    ),
                    decoration: BoxDecoration(
                      color: FitnessAppTheme.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topRight: Radius.circular(68.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: FitnessAppTheme.grey.withOpacity(0.2),
                            offset: Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Text('Some Vital are Not available for Cardiovascular Checkup. \nVisit your Nearby Kiosk for Vital Checkup. \n Nearby Kiosk : \n-> Kiosk 1 Address ->\n-> Kiosk 2 Address ->\n-> Kiosk 3 Address ->\n'),
                        Text(vitalsExpired
                            ? vitalsExpiredTxt
                            : someVitalsNotAvailable),

                        ///
                        // Row(
                        //   children: [
                        //     SizedBox(
                        //       width: 150,
                        //       child: Card(
                        //         margin: EdgeInsets.all(7),
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(10.0),
                        //         ),
                        //         elevation: 2,
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(5.0),
                        //           child: Column(
                        //             children: [
                        //               // Text('Kiosk 1'),
                        //               Padding(
                        //                 padding: const EdgeInsets.all(15.0),
                        //                 child: Column(
                        //                   crossAxisAlignment: CrossAxisAlignment.start,
                        //                   children: <Widget>[
                        //                     Center(
                        //                       child: Image.asset(
                        //                         'assets/images/ihl.png',
                        //                         // uiData['icon'],
                        //                         // height: theme['icon']['size'] * width / 500,
                        //                         fit: BoxFit.contain,
                        //                         // width: theme['icon']['size'] * width / 500,
                        //                         // color: color,
                        //                       ),
                        //                     ),
                        //                     SizedBox(height: ScUtil().setHeight(8)),
                        //                     Row(
                        //                       mainAxisAlignment:
                        //                           MainAxisAlignment.center,
                        //                       children: <Widget>[
                        //                         Flexible(
                        //                           child: Text(
                        //                             'Kiosk 1 Address',
                        //                             style: TextStyle(
                        //                               // color: color,
                        //                               fontSize: ScUtil().setSp(16),
                        //                               // fontSize: 14 * width / 500
                        //                             ),
                        //                             // overflow: TextOverflow.ellipsis,
                        //                           ),
                        //                         ),
                        //                       ],
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     SizedBox(
                        //       width: 150,
                        //       child: Card(
                        //         margin: EdgeInsets.all(7),
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(10.0),
                        //         ),
                        //         elevation: 2,
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(5.0),
                        //           child: Column(
                        //             children: [
                        //               // Text('Kiosk 1'),
                        //               Padding(
                        //                 padding: const EdgeInsets.all(15.0),
                        //                 child: Column(
                        //                   crossAxisAlignment: CrossAxisAlignment.start,
                        //                   children: <Widget>[
                        //                     Center(
                        //                       child: Image.asset(
                        //                         'assets/images/ihl.png',
                        //                         // uiData['icon'],
                        //                         // height: theme['icon']['size'] * width / 500,
                        //                         fit: BoxFit.contain,
                        //                         // width: theme['icon']['size'] * width / 500,
                        //                         // color: color,
                        //                       ),
                        //                     ),
                        //                     SizedBox(height: ScUtil().setHeight(8)),
                        //                     Row(
                        //                       mainAxisAlignment:
                        //                           MainAxisAlignment.center,
                        //                       children: <Widget>[
                        //                         Flexible(
                        //                           child: Text(
                        //                             'Kiosk 2 Address',
                        //                             style: TextStyle(
                        //                               // color: color,
                        //                               fontSize: ScUtil().setSp(16),
                        //                               // fontSize: 14 * width / 500
                        //                             ),
                        //                             // overflow: TextOverflow.ellipsis,
                        //                           ),
                        //                         ),
                        //                       ],
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        ///end card
                        ///From here we will Start the map
                        Stack(
                          children: [
                            Container(
                              height: vitalsExpired
                                  ? MediaQuery.of(context).size.height / 1.4
                                  : MediaQuery.of(context).size.height / 2.3,
                              width: vitalsExpired
                                  ? MediaQuery.of(context).size.width
                                  : MediaQuery.of(context).size.width - 30,
                              child: GoogleMap(
                                mapToolbarEnabled: false,
                                mapType: MapType.terrain,
                                myLocationEnabled: true,
                                zoomControlsEnabled: false,
                                onMapCreated: (GoogleMapController controller) {
                                  _googleMapController = controller;
                                  // createMarker();
                                },
                                initialCameraPosition: _initialCordinate,
                                scrollGesturesEnabled: true,
                                rotateGesturesEnabled: true,
                                zoomGesturesEnabled: true,
                                markers: markers.map((e) => e).toSet(),
                                polylines: {
                                  if (_info != null)
                                    Polyline(
                                      polylineId:
                                          const PolylineId('overview_polyline'),
                                      color: Colors.red,
                                      width: 5,
                                      points: _info.polylinePoints
                                          .map((e) =>
                                              LatLng(e.latitude, e.longitude))
                                          .toList(),
                                    ),
                                },

                                onLongPress: (p) {
                                  print(p.longitude);
                                  print(p.latitude);
                                },
                                // options: GoogleMapOptions(
                                //   mapType: MapType.satellite,
                                // ),
                              ),
                            ),
                            if (_info != null)
                              Positioned(
                                top: 20.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6.0,
                                    horizontal: 12.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.yellowAccent,
                                    borderRadius: BorderRadius.circular(20.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                        blurRadius: 6.0,
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    '${_info.totalDistance}, ${_info.totalDuration}',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: !vitalsExpired,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3.5,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // FileListButton(
                            //   notAvailableKeyLength: 0,
                            //   vitalName: 'dob',
                            //   vitalValue: age,
                            //   vitalStatus: '',
                            // ),
                            // FileListButton(
                            //   notAvailableKeyLength: 0,
                            //   vitalName: 'gender',
                            //   vitalValue: gender == 'm'
                            //       ? 'Male'
                            //       : gender == 'f'
                            //           ? 'Female'
                            //           : '',
                            //   vitalStatus: '',
                            // ),
                            //height
                            FileListButton(
                              notAvailableKeyLength: notAvailableKeys.length,
                              vitalName: 'height',
                              vitalValue: height.toString() != null
                                  ? height.toString()
                                  : 'null',
                              vitalStatus: '',
                              unit: height.toString() != null ? ' M' : '',
                            ),
                            //wt
                            FileListButton(
                              notAvailableKeyLength: notAvailableKeys.length,
                              vitalName: 'weight',
                              vitalValue: weight.toString(),
                              vitalStatus: '',
                              unit: weight.toString() != null ? ' Kg' : '',
                            ),
                            FileListButton(
                              notAvailableKeyLength: notAvailableKeys.length,
                              vitalName: 'BMI',
                              vitalValue: bmi.toString(),
                              vitalStatus: bmi_status != null ? bmi_status : '',
                              unit: '',
                            ),
                            // var percentage_body_fat;
                            // var percentage_body_fat_status;
                            // FileListButton(
                            //   notAvailableKeyLength: notAvailableKeys.length,
                            //   vitalName: 'Percentage body fat',
                            //   vitalValue: percentage_body_fat.toString(),
                            //   vitalStatus:
                            //       percentage_body_fat_status.toString(),
                            // ),
                            // var body_fat_mass;
                            // var body_fat_mass_status;

                            // FileListButton(
                            //   notAvailableKeyLength: notAvailableKeys.length,
                            //   vitalName: 'body fat mass',
                            //   vitalValue: body_fat_mass.toString(),
                            //   vitalStatus: body_fat_mass_status.toString(),
                            // ),
                            // var visceral_fat;
                            // var visceral_fat_status;
                            // FileListButton(
                            //   notAvailableKeyLength: notAvailableKeys.length,
                            //   vitalName: 'visceral fat',
                            //   vitalValue: visceral_fat.toString(),
                            //   vitalStatus: visceral_fat_status.toString(),
                            // ),
                            // var systolic_blood_pressure;
                            FileListButton(
                              notAvailableKeyLength: notAvailableKeys.length,
                              // vitalName: 'blood pressure',
                              vitalName: 'Systolic',
                              vitalValue:
                                  systolic_blood_pressure.toString() != 'null'
                                      ? systolic_blood_pressure.toString()
                                      : 'null',
                              vitalStatus:
                                  systolic_blood_pressure_status.toString(),
                              unit: systolic_blood_pressure.toString() != 'null'
                                  ? ' mmHg'
                                  : 'null',
                            ),
                            // var waist_to_hip_ratio;
                            // FileListButton(
                            //   notAvailableKeyLength: notAvailableKeys.length,
                            //   vitalName: 'waist to hip ratio',
                            //   vitalValue: waist_to_hip_ratio.toString(),
                            //   vitalStatus: waist_to_hip_ratio_status.toString(),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  )
                  //     : Container(
                  //   width: MediaQuery.of(context).size.width-30,
                  //   margin: EdgeInsets.only(
                  //       left: ScUtil().setWidth(15),
                  //       right: ScUtil().setWidth(15),
                  //       top: ScUtil().setHeight(15),
                  //       bottom: ScUtil().setHeight(15),
                  //   ),
                  //   padding: EdgeInsets.only(
                  //     left: ScUtil().setWidth(14),
                  //     right: ScUtil().setWidth(20),
                  //     top: ScUtil().setHeight(15),
                  //     bottom: ScUtil().setHeight(15),
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: FitnessAppTheme.white,
                  //     borderRadius: BorderRadius.only(
                  //         topLeft: Radius.circular(8.0),
                  //         bottomLeft: Radius.circular(8.0),
                  //         bottomRight: Radius.circular(8.0),
                  //         topRight: Radius.circular(68.0)),
                  //     boxShadow: <BoxShadow>[
                  //       BoxShadow(
                  //           color: FitnessAppTheme.grey.withOpacity(0.2),
                  //           offset: Offset(1.1, 1.1),
                  //           blurRadius: 10.0),
                  //     ],
                  //   ),
                  //   child: Text('Last checkup should be under 7 days.\nVisit your Nearby Kiosk for Vital Checkup.'),
                  // )
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  lottie.Lottie.network(
                      //'https://assets10.lottiefiles.com/packages/lf20_pcqghvjn.json',
                      'https://assets4.lottiefiles.com/packages/lf20_lexwgzsq.json',
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2,
                      fit: BoxFit.fitWidth),
                  Text(
                    'Fetching Vital Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        // color: Color.fromRGBO(109, 110, 113, 1),
                        color: AppColors.appTextColor,
                        fontFamily: 'Poppins',
                        fontSize: ScUtil().setSp(20),
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                        height: 1.33),
                  )
                ],
              ),
            ),
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.

      // return Future.error('Location services are disabled.');
      // return null;
      print(
          'permission location are denied  , show a pop up or snack bar and show a open setting button , so that user can on the permission');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // return null;//Future.error('Location permissions are denied');
        ///here show a pop up
        showDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                  title: new Text("Location Access Denied"),
                  content: new Text("Allow Location permission to continue"),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text("Yes"),
                      onPressed: () async {
                        await openAppSettings();
                        Get.back();
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text("No"),
                      onPressed: () => Get.back(),
                    )
                  ],
                ));
        print(
            'permission location are denied , show a pop up or snack bar and show a open setting button , so that user can on the permission');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      /// Permissions are denied forever, handle appropriately.
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
      print(
          'permission location are denied forever , show a pop up or snack bar and show a open setting button , so that user can on the permission');
      await showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                title: new Text("Location Access Denied"),
                content: new Text("Allow Location permission to continue"),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("Yes"),
                    onPressed: () async {
                      await openAppSettings();
                      Get.back();
                      Get.back();
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text("No"),
                    onPressed: () => Get.back(),
                  )
                ],
              ));
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // return await Geolocator.getCurrentPosition();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      var poss = await Geolocator.getCurrentPosition();
      print(poss.latitude);
      print(poss.longitude);
      if (mounted) {
        setState(() {
          _initialCordinate = CameraPosition(
            // target: LatLng(37.42796133580664, -122.085749655962),
            target: LatLng(poss.latitude, poss.longitude),
            zoom: 19.4746,
          );

          // markers.add(Marker(
          //   markerId: MarkerId('user'),
          //   // infoWindow:  InfoWindow(title: '$title',snippet: 'Kiosk H - Pod at this address',anchor: const Offset(0.5,                               0.0),onTap: (){}),
          //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          //   position: LatLng(poss.latitude, poss.longitude),
          // ));
        });
      }
    }
  }

  void _addMarker(LatLng pos, String id, String title) async {
    // Origin is not set OR Origin/Destination are both set
    // Set origin
    // setState(() {
    markers.add(Marker(
        markerId: MarkerId('$id'),
        infoWindow: InfoWindow(
          title: '$title',
          snippet: 'Kiosk H - Pod',
          anchor: const Offset(0.5, 0.0),
          onTap: () {},
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(200.0),
        position: pos,
        onTap: () async {
          // Get directions
          final directions = await DirectionsRepository()
              .getDirections(origin: pos, destination: pos);
          if (mounted) {
            setState(() => _info = directions);
          }
        }));
    // Reset destination
    _destination = null;

    // Reset info
    // _info = null;
    // });
  }
}
