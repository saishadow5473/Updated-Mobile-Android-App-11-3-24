import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/utils/textStyle.dart';
import '../../../data/model/hpodMapModel/hpodMapModel.dart';
import '../../controllers/hpodControllers/hpodControllers.dart';
import '../dashboard/common_screen_for_navigation.dart';

import '../../../app/utils/appColors.dart';
import '../../../app/utils/constLists.dart';
import '../../Widgets/appBar.dart';
import '../../Widgets/offeredProgram.dart';

class HpodLocations extends StatefulWidget {
  const HpodLocations({Key key}) : super(key: key);

  @override
  State<HpodLocations> createState() => _HpodLocationsState();
}

class _HpodLocationsState extends State<HpodLocations> {
  // LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng _center = const LatLng(28.623561814351167, 77.20956906454096);
  final HpodControllers _postionController = Get.put(HpodControllers());
  Map<double, HpodMapModel> sortedList = {};
  Map<double, HpodMapModel> finalSorted = {};
  @override
  void initState() {
    getGeoLocation();
    //_postionController.fetchLocations();
    getHpodLocations();
    super.initState();
  }

  void getHpodLocations() async {
    await _postionController.fetchLocations();
    if (mounted) setState(() {});
  }

  void getGeoLocation() async {
    bool locationStatus = await Permission.location.isDenied;
    if (locationStatus) {
      // Map<Permission, PermissionStatus> status = await [
      //   Permission.location,
      // ].request();
      PermissionStatus status = await Permission.location.request();
      //  print('========$status');
      if (status == PermissionStatus.permanentlyDenied) {
        openAppSettings();
      }
    }
    try {
      Position position = await Geolocator.getCurrentPosition();
      //print('POS========$position');
      print(position.latitude);
      print(position.longitude);
      _postionController.updateCurrentPosition(val: LatLng(position.latitude, position.longitude));
      _postionController.updateCurrentState(val: true);
      _postionController.latLng.obs;
      _center = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(_center));
    } catch (e) {
      print(e);
    }
    // print('CENTER==${_center.toString()}');
    getNearbyLocations();
  }

  GoogleMapController mapController;
  final RxSet<Marker> markers = RxSet();
  void getNearbyLocations() {
    double currentLat = _postionController.latLng.value.latitude;
    double currentLong = _postionController.latLng.value.longitude;
    getHpodLocations();
    _postionController.hpodLocations.removeWhere(
        (HpodMapModel element) => element.latitude == null || element.longitude == null);
    for (var element in _postionController.hpodLocations) {
      sortedList[Geolocator.distanceBetween(
          currentLat,
          currentLong,
          double.parse(element.latitude.toString()),
          double.parse(element.longitude.toString()))] = element;
    }
    markers.add(Marker(
      //add first marker
      markerId: const MarkerId('1'),
      position: LatLng(currentLat, currentLong), //position of marker
      infoWindow: const InfoWindow(
        //popup info
        title: 'Your Location',
        // snippet: 'My Custom Subtitle',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), //Icon for Marker
    ));

    //print('============>$sortedList');
    finalSorted = Map.fromEntries(sortedList.entries.toList()
      ..sort((MapEntry<double, HpodMapModel> e1, MapEntry<double, HpodMapModel> e2) =>
          e1.key.compareTo(e2.key)));
    _postionController.updateNearbyList(val: finalSorted);
    if (_postionController.sortedMap.isEmpty) {
      getHpodLocations();
    }
    _postionController.update(['Locations']);
    _postionController.sortedMap.forEach(
      (double key, HpodMapModel value) {
        markers.add(Marker(
          markerId: MarkerId(key.toString()),
          position: LatLng(double.parse(value.latitude.toString()),
              double.parse(value.longitude.toString())), //position of marker
          infoWindow: InfoWindow(
              //popup info
              title: value.organizationName,
              snippet: value.orgAddress),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
        ));
      },
    );
    print(finalSorted);
    _postionController.updateMarkers(val: markers);
    print(_postionController.markers.value);

    print('object');
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    // ignore: deprecated_member_use
    if (await canLaunch(googleUrl)) {
      // ignore: deprecated_member_use
      await launch(googleUrl);
    } else {
      print('counld not able to open google map');
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool aff = false;
    if (!Tabss.featureSettings.hpodLocations) {
      return const Center(child: Text("No hPod Locations Available"));
    } else {
      return WillPopScope(
        onWillPop: () async {
          Get.back();
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // const OfferedPrograms(
              //   screen: ProgramLists.commonList,
              //   screenTitle: "Social",
              // ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('hPod Locations',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      color: const Color(0xff19a9e5),
                      fontWeight: FontWeight.w500,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Find the HPOD\'s nearest to your location and do your total body checkup within 5 mins!!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    color: const Color(0xff585859),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 26.h,
                    child: Obx(() => GoogleMap(
                            zoomControlsEnabled: false,
                            onMapCreated: _onMapCreated,
                            markers: _postionController.markers.value,
                            initialCameraPosition: CameraPosition(
                              target: _postionController.latLng.value,
                              zoom: 11.0,
                            ),
                            // ignore: prefer_collection_literals
                            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            ].toSet())

                        // Center(
                        //         child: Shimmer.fromColors(
                        //             child: Container(
                        //                 height: 26.h,
                        //                 width: double.infinity,
                        //                 padding: EdgeInsets.only(
                        //                     left: 8, right: 8, top: 8),
                        //                 decoration: BoxDecoration(
                        //                     color: Colors.red,
                        //                     borderRadius:
                        //                         BorderRadius.circular(8)),
                        //                 child: Text('Hello')),
                        //             direction: ShimmerDirection.ltr,
                        //             period: Duration(seconds: 2),
                        //             baseColor: Color.fromARGB(255, 240, 240, 240),
                        //             highlightColor:
                        //                 Colors.grey.withOpacity(0.2))),
                        ),
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GetBuilder<HpodControllers>(
                    id: 'Locations',
                    builder: (_) => _.sortedMap.isNotEmpty
                        ? Column(
                            children: _postionController.sortedMap.values.map((HpodMapModel e) {
                              return e.organizationName == null
                                  ? Container()
                                  : Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(color: Colors.white),
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.organizationName.toString(),
                                              style: AppTextStyles.mapText,
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            e.allowGenericUser != true
                                                ? Text(
                                                    'Only for affiliated users',
                                                    style: AppTextStyles.affiliationUserStyle,
                                                  )
                                                : Container(),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    SizedBox(
                                                      width: 80.w,
                                                      child: Text(
                                                        e.orgAddress.toString(),
                                                        style: AppTextStyles.mapText,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    SizedBox(
                                                      width: 80.w,
                                                      child: Text(
                                                        e.orgAddressLine2.toString(),
                                                        style: AppTextStyles.mapText,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      e.orgPincode.toString(),
                                                      style: AppTextStyles.mapText,
                                                    ),
                                                  ],
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    openMap(
                                                      double.parse(e.latitude.toString()),
                                                      double.parse(e.longitude.toString()),
                                                    );
                                                  },
                                                  child: SizedBox(
                                                    height: 8.h,
                                                    width: 10.w,
                                                    child: Image.asset('newAssets/Icons/map.png'),
                                                  ),
                                                )
                                              ],
                                            )
                                          ]),
                                    );
                            }).toList(),
                          )
                        : Center(
                            child: Column(
                            children: <Widget>[
                              Shimmer.fromColors(
                                  direction: ShimmerDirection.ltr,
                                  period: const Duration(seconds: 2),
                                  baseColor: const Color.fromARGB(255, 240, 240, 240),
                                  highlightColor: Colors.grey.withOpacity(0.2),
                                  child: Container(
                                      height: 18.h,
                                      width: double.infinity,
                                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.yellow,
                                          borderRadius: BorderRadius.circular(8)),
                                      child: const Text('Hello'))),
                              const SizedBox(
                                height: 10,
                              ),
                              Shimmer.fromColors(
                                  direction: ShimmerDirection.ltr,
                                  period: const Duration(seconds: 2),
                                  baseColor: const Color.fromARGB(255, 240, 240, 240),
                                  highlightColor: Colors.grey.withOpacity(0.2),
                                  child: Container(
                                      height: 18.h,
                                      width: double.infinity,
                                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8)),
                                      child: const Text('Hello'))),
                            ],
                          ))),
              ),
              SizedBox(
                height: 10.h,
              )
            ],
          ),
        ),
      );
    }
  }
}
