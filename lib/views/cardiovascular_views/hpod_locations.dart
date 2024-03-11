import 'dart:async';
import 'dart:convert';

// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/views/cardiovascular_views/direction_model.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:shimmer/shimmer.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a =
      0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));

  ///in km
}

// double totalDistance = calculateDistance(26.196435, 78.197535,26.197195, 78.196408);

// print(totalDistance);

// var currentIndexOfCardio = ValueNotifier<int>(0);

class HpodLocations extends StatefulWidget {
  final isGeneric;

  const HpodLocations({this.isGeneric});

  @override
  State<HpodLocations> createState() => _HpodLocationsState();
}

class _HpodLocationsState extends State<HpodLocations> {
  http.Client _client = http.Client(); //3gb
  @override
  void initState() {
    getKioskData();
    super.initState();
  }

  Map vitals;

  getKioskData() async {
    await _determinePosition();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    affiliated = true;
    await createMarker();
  }

  bool affiliated = false;
  var vitalsExpiredTxt =
      'Last checkup should be under 7 days. \nVisit your Nearby H-pod for Vital Checkup. \n H - Pod Nearby your location : \n';
  var someVitalsNotAvailable =
      'Some Vital are Not available for Cardiovascular Checkup. \nVisit your Nearby H-Pod for Vital Checkup. \n H - Pod Nearby your location : \n';
  List notAvailableKeys = [];
  List hPodlocations = [];
  List affHpodLocations = [];
  var userCordinates;
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
      final response =
          await http.get(Uri.parse(API.iHLUrl + '/empcardiohealth/fetch_kiosk_details'));
      if (response.statusCode == 200) {
        if (response.body != 'null' && response.body != '') {
          List ress = jsonDecode(response.body);
          // ress.removeWhere((element) => element['Latitude']);
          List data = []; //ress.toSet().toList();
          List lt = [];
          print('=========$ress');
          ;
          ress.forEach((element) {
            // element['Latitude'];
            if (element['Latitude'].toString() != 'null') {
              if (data.isEmpty) {
                data.add(element);

                lt.add(element['Latitude'].toString().replaceAll(',', ''));
                // } else if (data.isNotEmpty && !lt.contains(element['Latitude'])) { // uncomment it if to avoid kiosk in same location condition
              } else if (data.isNotEmpty) {
                data.add(element);
                lt.add(element['Latitude'].toString().replaceAll(',', ''));
              }
            }
          });

          var AffmarkersDetails = [];
          var markersDetails = [];
          // hPodlocations = data;
          data.forEach((element) {
            // markersDetails.add(
            //   {
            //     'pos': LatLng(double.tryParse(element['Latitude']),
            //         double.tryParse(element['Longitude'])),
            //     'id': 'kiosk_${data.indexOf(element).toString()}',
            //     'title': element['OrgAddress'].toString() +
            //         ' ' +
            //         element['OrgAddressLine2'].toString()
            //   },
            // );
            if (API.affNmLst.contains(element['OrganizationName']))
              affHpodLocations.add(element);
            else
              hPodlocations.add(element);
          });
          List lstWithDistance = [];
          hPodlocations.forEach((element) {
            print(hPodlocations.indexOf(element));
            element['distanceInKm'] = calculateDistance(
                double.parse(element['Latitude'].toString().replaceAll(',', '')),
                double.parse(element['Longitude'].toString().replaceAll(',', '')),
                userCordinates.latitude,
                userCordinates.longitude);
            lstWithDistance.add(element);
          });
          print(lstWithDistance);
          lstWithDistance.sort((a, b) => a['distanceInKm'].compareTo(b['distanceInKm']));
          print(lstWithDistance);
          hPodlocations = lstWithDistance;
          hPodlocations.forEach((element) {
            markersDetails.add(
              {
                'pos': LatLng(double.tryParse(element['Latitude'].toString().replaceAll(',', '')),
                    double.tryParse(element['Longitude'].toString().replaceAll(',', ''))),
                'id': 'kiosk_${data.indexOf(element).toString()}',
                'title':
                    element['OrgAddress'].toString() + ' ' + element['OrgAddressLine2'].toString()
              },
            );
          });
          affHpodLocations.forEach((element) {
            print(element);
            AffmarkersDetails.add(
              {
                'pos': LatLng(double.tryParse(element['Latitude'].toString().replaceAll(',', '')),
                    double.tryParse(element['Longitude'].toString().replaceAll(',', ''))),
                'id': 'kiosk_${data.indexOf(element).toString()}',
                'title':
                    element['OrgAddress'].toString() + ' ' + element['OrgAddressLine2'].toString()
              },
            );
          });
          return {'marker': markersDetails, 'affMarker': AffmarkersDetails};
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
    List markersDetails = [];
    List AffmarkersDetails = [];
    Map markerLocations = await getKioskLocations() ?? {"marker": [], "affMarker": []};
    markersDetails = markerLocations['marker'];
    AffmarkersDetails = markerLocations['affMarker'];
    for (int i = 0; i < markersDetails.length; i++) {
      _addMarker(
          markersDetails[i]['pos'], markersDetails[i]['id'], markersDetails[i]['title'], false);
    }
    for (int i = 0; i < AffmarkersDetails.length; i++) {
      _addMarker(AffmarkersDetails[i]['pos'], AffmarkersDetails[i]['id'],
          AffmarkersDetails[i]['title'], true);
    }
    // await Future.delayed(Duration(seconds: 1));
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<bool> willPopFunction() async {
    // Navigator.pushAndRemoveUntil(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => HomeScreen(
    //         introDone: true,
    //       ),
    //     ),
    //     (Route<dynamic> route) => false);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ScUtil.init(context,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        allowFontScaling: true);
    return SafeArea(
      child: WillPopScope(
        onWillPop: willPopFunction,
        child: Scaffold(
          backgroundColor: FitnessAppTheme.white,
          floatingActionButton: Visibility(
            visible: !loading,
            child: FloatingActionButton(
              child: Icon(Icons.my_location),
              onPressed: () {
                _googleMapController
                    .animateCamera(CameraUpdate.newCameraPosition(_initialCordinate));
              },
            ),
          ),
          body: !loading
              ? Stack(
                  children: [
                    Column(
                      children: [
                        Visibility(
                          // visible: affiliated,
                          visible: false,
                          child: Text(
                              'You are Affilated to below organization , click on it to get Location'),
                        ),
                        Visibility(
                          // visible: affiliated,
                          visible: false,
                          child: Container(
                            // height: MediaQuery.of(context).size.height / 10,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    shadowColor: Colors.white,
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.place,
                                              color: AppColors.primaryAccentColor,
                                            ),
                                            SizedBox(
                                              width: ScUtil().setWidth(8),
                                            ),
                                            Text(
                                              'India Health Link Location',
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          // height: affiliated
                          //     ? MediaQuery.of(context).size.height / 1.44
                          //     : MediaQuery.of(context).size.height / 1.227,
                          // width: affiliated
                          //     ? MediaQuery.of(context).size.width
                          //     : MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height - 120,
                          width: MediaQuery.of(context).size.width,
                          child: Stack(children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.only(topRight: Radius.circular(affiliated ? 1 : 45)),
                              child: GoogleMap(
                                mapToolbarEnabled: false,
                                mapType: MapType.terrain,
                                myLocationEnabled: true,
                                zoomControlsEnabled: false,
                                onMapCreated: (GoogleMapController controller) async {
                                  _googleMapController = controller;
                                  await createMarker();
                                },
                                initialCameraPosition: _initialCordinate,
                                scrollGesturesEnabled: true,
                                rotateGesturesEnabled: true,
                                zoomGesturesEnabled: true,
                                markers: markers.map((e) => e).toSet(),
                                polylines: {
                                  if (_info != null)
                                    Polyline(
                                      polylineId: const PolylineId('overview_polyline'),
                                      color: Colors.red,
                                      width: 5,
                                      points: _info.polylinePoints
                                          .map((e) => LatLng(e.latitude, e.longitude))
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
                            Padding(
                              padding: EdgeInsets.all(14.5.sp),
                              child: Container(
                                color: Colors.white70,
                                height: 4.5.h,
                                width: 10.w,
                                child: IconButton(
                                  alignment: Alignment.center,
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            )
                          ]),
                        ),
                        // buildPolicySheet(),
                      ],
                    ),
                    DraggableScrollableSheet(
                      initialChildSize: 0.30,
                      minChildSize: 0.15,
                      builder: (BuildContext context, ScrollController scrollController) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          child: Card(
                            color: FitnessAppTheme.white,
                            elevation: 12.0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            margin: const EdgeInsets.all(0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: FitnessAppTheme.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: CustomInnerContent(
                                affMarkerDetails: affHpodLocations,
                                markerDetails: hPodlocations,
                                // scrollController: scrollController,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // buildPolicySheet(),

                    /// this is for showing direction line info
                    /// that we are currently not showing because of this api.
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
                        'Please wait\nFetching H-Pod Locations',
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
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      userCordinates = await Geolocator.getCurrentPosition();
      print(userCordinates.latitude);
      print(userCordinates.longitude);
      if (mounted) {
        setState(() {
          _initialCordinate = CameraPosition(
            // target: LatLng(37.42796133580664, -122.085749655962),
            target: LatLng(userCordinates.latitude, userCordinates.longitude),
            zoom: 10.4746,
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

  void _addMarker(LatLng pos, String id, String title, bool affiliated) async {
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
        icon: affiliated
            ? BitmapDescriptor.defaultMarkerWithHue(20.0)
            : BitmapDescriptor.defaultMarkerWithHue(200.0),
        // : BitmapDescriptor.defaultMarkerWithHue(200.0),
        position: pos,
        onTap: () async {
          /// Get directions && poly lines
          // final directions = await DirectionsRepository()
          //     .getDirections(origin: pos, destination: pos);
          // if (mounted) {
          //   setState(() => _info = directions);
          // }
        }));
    // Reset destination
    _destination = null;

    // Reset info
    // _info = null;
    // });
  }
}

/// Content of the DraggableBottomSheet's child SingleChildScrollView
// class CustomScrollViewContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 12.0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       margin: const EdgeInsets.all(0),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: CustomInnerContent(),
//       ),
//     );
//   }
// }
// var ctlr = ScrollController();

class CustomInnerContent extends StatelessWidget {
  final markerDetails;
  final affMarkerDetails;

  const CustomInnerContent({Key key, this.markerDetails, this.affMarkerDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 12),
        CustomDraggingHandle(),
        SizedBox(height: 16),
        CustomExploreBerlin(),
        SizedBox(height: 16),

        // SizedBox(height: 24),
        // CustomFeaturedListsText(),
        // SizedBox(height: 16),
        // CustomFeaturedItemsGrid(),
        // SizedBox(height: 24),
        Visibility(
          visible: affMarkerDetails.length > 0,
          child: CustomRecentPhotosText(
            txt: 'Exclusive for you',
          ),
        ),
        SizedBox(height: 16),
        // ListView.builder(
        //   physics: AlwaysScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   padding: EdgeInsets.symmetric(vertical: 8),
        //   itemCount: markerDetails.length,
        //   itemBuilder: (context, index) => Padding(
        //     padding: EdgeInsets.all(7),
        //     child: CustomRecentPhotoLarge(
        //       markerDetails: markerDetails[index],
        //     ),
        //   ),
        // ),
        Column(
          children: affMarkerDetails.map<Widget>((e) {
            return Padding(
              padding: EdgeInsets.all(7),
              child: CustomRecentPhotoLarge(
                markerDetails: e,
                affiliated: false,
              ),
            );
          }).toList(),
        ),

        // CustomRecentPhotoLarge(),
        // SizedBox(height: 12),
        // CustomRecentPhotoLarge(),
        // SizedBox(height: 12),
        // CustomRecentPhotoLarge(),
        // SizedBox(height: 12),
        CustomRecentPhotosText(
          txt: 'Others',
        ),
        SizedBox(height: 16),
        Column(
          children: markerDetails.map<Widget>((e) {
            return Padding(
              padding: EdgeInsets.all(7),
              child: CustomRecentPhotoLarge(
                markerDetails: e,
                affiliated: !e['allow_generic_user'],
              ),
            );
          }).toList(),
        ),
        // CustomHorizontallyScrollingRestaurants(),
        // CustomHorizontallyScrollingRestaurants(),
        // CustomRecentPhotosSmall(),
        // SizedBox(height: 16),
      ],
    );
  }
}

class CustomDraggingHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      width: 30,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
    );
  }
}

class CustomExploreBerlin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Explore H-Pod",
            style: TextStyle(fontSize: 22, color: Colors.black45, fontFamily: 'Poppins')),
        SizedBox(width: 8),
        Container(
          height: 24,
          width: 24,
          child: Icon(Icons.map_rounded, size: 15, color: Colors.black54),
          decoration:
              BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
        ),
      ],
    );
  }
}

class CustomHorizontallyScrollingRestaurants extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomRestaurantCategory(),
            SizedBox(width: 12),
            CustomRestaurantCategory(),
            SizedBox(width: 12),
            CustomRestaurantCategory(),
            SizedBox(width: 12),
            CustomRestaurantCategory(),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class CustomFeaturedListsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      //only to left align the text
      child: Row(
        children: <Widget>[Text("Featured Lists", style: TextStyle(fontSize: 14))],
      ),
    );
  }
}

class CustomFeaturedItemsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        //to avoid scrolling conflict with the dragging sheet
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        children: <Widget>[
          CustomFeaturedItem(),
          CustomFeaturedItem(),
          CustomFeaturedItem(),
          CustomFeaturedItem(),
        ],
      ),
    );
  }
}

class CustomRecentPhotosText extends StatelessWidget {
  final txt;

  const CustomRecentPhotosText({Key key, this.txt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: <Widget>[
          Text(txt,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

class CustomRecentPhotoLarge extends StatelessWidget {
  final markerDetails;
  final affiliated;

  const CustomRecentPhotoLarge({Key key, this.markerDetails, this.affiliated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomFeaturedItem(
          orgAdd1: markerDetails['OrgAddress'],
          orgAdd2: markerDetails['OrgAddressLine2'],
          orgAdd3: markerDetails['OrgAddressLine3'],
          orgName: markerDetails['OrganizationName'],
          orgPinCode: markerDetails['OrgPincode'],
          orgCity: markerDetails['City'],
          lat: double.parse(markerDetails['Latitude'].replaceAll(",", "")),
          long: double.parse(markerDetails['Longitude']),
          affiliated: affiliated),
    );
  }
}

// class CustomRecentPhotosSmall extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return CustomFeaturedItemsGrid();
//   }
// }

class CustomRestaurantCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.grey[500],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class CustomFeaturedItem extends StatelessWidget {
  final orgName;
  String orgAdd1;
  String orgAdd2;
  String orgAdd3;
  final orgPinCode;
  String orgCity;
  double lat;
  double long;
  final affiliated;

  CustomFeaturedItem(
      {Key key,
      this.orgName,
      this.orgAdd1,
      this.orgAdd2,
      this.orgAdd3,
      this.orgPinCode,
      this.orgCity,
      this.lat,
      this.long,
      this.affiliated})
      : super(key: key);

  @override
  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      print('counld not able to open google map');
      throw 'Could not open the map.';
    }
  }

  Widget build(BuildContext context) {
    if (orgAdd1.toString() != 'null' &&
        orgAdd2.toString() != 'null' &&
        orgAdd3.toString() != 'null' &&
        orgCity.toString() != 'null') {
      if (orgAdd1 != '' && !orgAdd1.contains(',')) orgAdd1 = orgAdd1 + ',';
      if (orgAdd2 != '' && !orgAdd2.contains(',')) orgAdd2 = orgAdd2 + ',';
      if (orgAdd3 != '' && !orgAdd3.contains(',')) orgAdd3 = orgAdd3 + ',';
      if (orgCity != '' && !orgCity.contains(',')) orgCity = orgCity + ',';
    } else {
      if (orgAdd1.toString() == 'null') orgAdd1 = '';
      if (orgAdd2.toString() == 'null') orgAdd2 = '';
      if (orgAdd3.toString() == 'null') orgAdd3 = '';
      if (orgCity.toString() == 'null') orgCity = '';
    }
    return Container(
      // height: affiliated ? 155 : 130,
      width: MediaQuery.of(context).size.width - 20,
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            bottomLeft: Radius.circular(8.0),
            bottomRight: Radius.circular(8.0),
            topRight: Radius.circular(8.0)),
        border: Border.all(width: 0.4, color: FitnessAppTheme.grey.withOpacity(0.3)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: FitnessAppTheme.grey.withOpacity(0.2),
              offset: Offset(1.1, 1.1),
              blurRadius: 10.0),
        ],
      ),
      // decoration: BoxDecoration(
      //   border: Border.all(
      //       width: 0.1, color: FitnessAppTheme.grey.withOpacity(0.2)),
      //   // color: Colors.grey[300],
      //   borderRadius: BorderRadius.circular(4),
      //   // border: Border.fromBorderSide(BorderSide(width: )),
      // ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
//         child: Text("""
// BPC - Safal Fasal
// Behind Bajaj Show room, Bypass Road Barshi Road, In front of Mauli Clinic
// Latur, Pincode : 413512
//     """),
//             child: Text("""
// $orgName
// $orgAdd1, $orgAdd2, $orgAdd3
// $orgCity, $orgPinCode
//     """),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: """$orgName""",
                          style: TextStyle(
                            color: Colors.black, //Color(0xff6d6e71),
                            fontSize: ScUtil().setSp(14),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )),
                Visibility(
                  visible: affiliated,
                  child: SizedBox(
                    height: 18,
                    child: Shimmer.fromColors(
                      baseColor: Colors.red,
                      highlightColor: Colors.grey.shade300,
                      child: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: """only for affiliated user\n""",
                                style: TextStyle(
                                  color: //AppColors.appItemTitleTextColor
                                      // .withRed(110), //
                                      Color(0xff6d6e71),
                                  fontSize: ScUtil().setSp(12),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
                RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: """
$orgAdd1 $orgAdd2 $orgAdd3
$orgCity $orgPinCode
    """,
                          style: TextStyle(
                            color: Colors.black, //Color(0xff6d6e71),
                            fontSize: ScUtil().setSp(14),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: affiliated ? 20 : 0),
              ],
            ),

//             child: Shimmer.fromColors(
//               baseColor: AppColors.primaryAccentColor,
//               highlightColor: Color(0xff6d6e71),
//               child: RichText(
//                   textAlign: TextAlign.left,
//                   text: TextSpan(
//                     children: [
//                       TextSpan(
//                         text: """
// $orgName
//     """,
//                         style: TextStyle(
//                           color: Colors.black, //Color(0xff6d6e71),
//                           fontSize: ScUtil().setSp(14),
//                           fontFamily: 'Poppins',
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       TextSpan(
//                         text:
//                             """                   only for affiliated user\n""",
//                         style: TextStyle(
//                           color: //AppColors.appItemTitleTextColor
//                               // .withRed(110), //
//                               Color(0xff6d6e71),
//                           fontSize: ScUtil().setSp(12),
//                           fontFamily: 'Poppins',
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       TextSpan(
//                         text: """
// $orgAdd1, $orgAdd2, $orgAdd3
// $orgCity, $orgPinCode
//     """,
//                         style: TextStyle(
//                           color: Colors.black, //Color(0xff6d6e71),
//                           fontSize: ScUtil().setSp(14),
//                           fontFamily: 'Poppins',
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       // TextSpan(
//                       //   text: ' ',
//                       //   style: TextStyle(
//                       //     color: Color(0xff66688f),
//                       //     fontSize: ScUtil().setSp(12),
//                       //     fontFamily: 'Poppins',
//                       //   ),
//                       // ),
//                     ],
//                   )),
//             ),
          ),
          Positioned(
            right: 4,
            bottom: 10,
            child: GestureDetector(
              onTap: () {
                openMap(lat, long);
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), color: Colors.transparent),

                child: Image.asset(
                  'assets/images/cardio/Google-Maps-logo.jpg',
                  fit: BoxFit.cover,
                  // color: Colors.red,
                ),
                // child: Icon(
                //   Icons.place_sharp,
                //   color: FitnessAppTheme.white,
                //   size: 18,
                // ),

                // color: FitnessAppTheme.grey,
              ),
            ),
          )
        ],
      ),
    );
  }
}
