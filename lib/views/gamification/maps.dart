import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/gamification/stepsScreen.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'dart:async';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(18.627061, 73.797943);

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  bool started = false;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  String googleAPIKey = 'AIzaSyAX1Oc5vIZmxKUb1k00EXHwLZD6SOA0YLE';

  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;

  LocationData currentLocation;
  LocationData destinationLocation;

  Location location;

  Marker marker;

  @override
  void initState() {
    super.initState();

    location = new Location();
    polylinePoints = PolylinePoints();

    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      updatePinOnMap();
    });
    setSourceAndDestinationIcons();
  }

  void setSourceAndDestinationIcons() async {}

  void setInitialLocation() async {}

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }
    return ScrollessBasicPageUI(
      appBar: Column(
        children: [
          SizedBox(
            width: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(
                color: Colors.white,
              ),
              Flexible(
                child: Center(
                  child: Text(
                    "21 Days Challenge - Step Walker",
                    style: TextStyle(color: Colors.white, fontSize: 22),
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: <Widget>[
            GoogleMap(
                myLocationEnabled: true,
                compassEnabled: true,
                markers: Set.from(_markers),
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                tiltGesturesEnabled: false,
                polylines: _polylines,
                mapType: MapType.satellite,
                // onTap:(){},
                initialCameraPosition: initialCameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                }),
            // Padding(
            //   padding: const EdgeInsets.only(top: 390.0),
            //   child: Center(
            //     child: Container(
            //       width: 80,
            //       height: 80,
            //       decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
            //         BoxShadow(
            //             color: AppColors.primaryAccentColor.withOpacity(0.5),
            //             blurRadius: 25.0,
            //             spreadRadius: 10)
            //       ]),
            //       child: MaterialButton(
            //         shape: CircleBorder(
            //             side: BorderSide(
            //                 width: 2,
            //                 color: AppColors.primaryAccentColor,
            //                 style: BorderStyle.solid)),
            //         child: Text(
            //           started ? "Stop" : "Start",
            //           style: TextStyle(fontSize: 18.0),
            //         ),
            //         color: AppColors.primaryAccentColor,
            //         textColor: Colors.white,
            //         onPressed: started
            //             ? () async {
            //                 destinationLocation = await location.getLocation();
            //                 var destPosition = LatLng(
            //                     destinationLocation.latitude,
            //                     destinationLocation.longitude);
            //
            //                 _markers.add(Marker(
            //                     markerId: MarkerId('destPin'),
            //                     position: destPosition,
            //                     icon: destinationIcon));
            //                 setPolylines();
            //               }
            //             : () async {
            //                 currentLocation = await location.getLocation();
            //                 started = true;
            //                 var pinPosition = LatLng(currentLocation.latitude,
            //                     currentLocation.longitude);
            //
            //                 _markers.add(Marker(
            //                   markerId: MarkerId('sourcePin'),
            //                   position: pinPosition,
            //                 ));
            //               },
            //       ),
            //     ),
            //   ),
            // ),
            // ClipOval(
            //   child: Material(
            //     color: Colors.white, // button color
            //     child: InkWell(
            //       splashColor: Colors.red, // inkwell color
            //       child: Icon(
            //         Icons.cancel,
            //         color: Colors.grey,
            //       ),
            //       onTap: () {
            //         Navigator.pushAndRemoveUntil(
            //             context,
            //             MaterialPageRoute(builder: (context) => StepsScreen()),
            //             (Route<dynamic> route) => false);
            //       },
            //     ),
            //   ),
            // ),F
          ],
        ),
      ),
    );
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPIKey,
        PointLatLng(currentLocation.latitude, currentLocation.longitude),
        PointLatLng(
            destinationLocation.latitude, destinationLocation.longitude));
    if (result != null) {
      if (this.mounted) {
        setState(() {
          _polylines.add(Polyline(
              width: 5, //set the width of the polylines
              polylineId: PolylineId("poly"),
              color: Color.fromARGB(255, 40, 122, 198),
              points: polylineCoordinates));
        });
      }
    }
  }

  void updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

    if (this.mounted) {
      setState(() {
        var pinPosition =
            LatLng(currentLocation.latitude, currentLocation.longitude);

        _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
        _markers.add(Marker(
            markerId: MarkerId('sourcePin'),
            position: pinPosition, // updated position
            icon: sourceIcon));
      });
    }
  }
}
