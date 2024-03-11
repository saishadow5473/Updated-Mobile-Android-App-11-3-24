import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import 'mapSnap.dart';
import 'stepsApi.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../../utils/SpUtil.dart';
import '../../../../app/utils/localStorageKeys.dart';

// ValueNotifier<Status> currentStatus;
double _caloriesG = 0.0;
int _stepsG = 0;
double distanceG = 0.0;
Stopwatch stopwatchG = Stopwatch();
LatLng resumeLng;
List<LatLng> _polylinesG;
DateTime startTimeG;
List<List<String>> entireDataG = [];

class TrackActivityWithMap extends StatefulWidget {
  TrackActivityWithMap({Key key, @required this.initialPos}) : super(key: key);
  var initialPos;
  @override
  State<TrackActivityWithMap> createState() => _TrackActivityWithMapState();
}

class _TrackActivityWithMapState extends State<TrackActivityWithMap> {
  List<LatLng> _polylines = [];
  bool _isListening = true;
  LatLng _startMarker;
  LatLng _endMarker;
  // Set<Marker> _markers = {};
  final ValueNotifier<Set<Marker>> _markerS = ValueNotifier({});
  double _distanceCovered = 0.0;
  final PolylinePoints _polylinePoints = PolylinePoints();
  int _stepsCount = 0;
  final double _strideLength = 0.76;
  StreamSubscription<Position> _positionStreamSubscription;
  double calories = 0.0;
  double _distanceCovered5 = 0.0;
  final List<LatLng> _polylines5 = [];
  //
  GetStorage box = GetStorage();
  GoogleMapController _mapController;
  List<List<String>> entireData = [];
  List<String> dropdownItems = [
    'Walking',
    // 'Running',
    // 'Jogging',
  ];
  String selectedValue = 'Walking';
  // Stopwatch _stopwatch;
  final ValueNotifier<Stopwatch> _stopWatch = ValueNotifier(Stopwatch());
  int weight;
  DateTime startDate;

  GlobalKey key = GlobalKey();

  @override
  void initState() {
    getWeight();
    // _stopwatch = Stopwatch();
    // _stopWatch.value = Stopwatch();
    if (ChangeCurrentStatus.currentStatus.value != Status.start) {
      if (ChangeCurrentStatus.currentStatus.value == Status.play) {
        ChangeCurrentStatus.currentStatus.value = Status.pause;
      }
      print(CheckStreamStatus().calories);
      // calories = _caloriesG;
      // _stepsCount = _stepsG;
      // _distanceCovered = distanceG;
      // _stopWatch.value = stopwatchG;
      // _stopWatch.value = _stopWatch.value;
      // _stopWatch.notifyListeners();
      // print(_stopWatch.value.elapsed);
      // // _polylines = _polylinesG;
      // _startMarker = resumeLng;
      // startDate = startTimeG;
      // entireData = entireDataG;
      GetStorage box = GetStorage();
      calories = box.read('_caloriesG');
      _distanceCovered = box.read('distanceG');
      _stopWatch.value = box.read('stopwatchG');
      _stopWatch.notifyListeners();
      _polylines = box.read('_polylinesG');
      entireData = box.read('entireDataG');
      startDate = box.read('startTimeG');
      _startMarker = box.read('resumeLng');

      resumeAf();
      // _stopWatch.value.start();
    } else {
      ChangeCurrentStatus.currentStatus.value = Status.start;
    }
    // currentStatus.value = Status.start;
    // currentStatus.notifyListeners();

    super.initState();
  }

  getWeight() {
    String w = SpUtil.getString(LSKeys.weight);

    weight = double.parse(w).toInt();
    print(weight);
    weight ??= 55;
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    // _polylines.clear();
    // // _markers.clear();
    // _markerS.value.clear();
    // // _stopwatch.reset();
    // // _stopWatch.value.reset();

    // _endMarker = _polylines.last;
    // _distanceCovered = 0.0;
    // _stepsCount = 0;
    // calories = 0;
    // ChangeCurrentStatus.currentStatus.value = Status.start;
    // ChangeCurrentStatus.currentStatus.notifyListeners();
    //new
    // _caloriesG = calories;
    // _stepsG = _stepsCount;
    // distanceG = _distanceCovered;
    // stopwatchG = _stopWatch.value;
    // _stopWatch.notifyListeners();
    // _polylinesG = _polylines;
    // entireDataG = entireData;
    // startTimeG = startDate;
    // // _stopWatch.value.stop();
    // print(_caloriesG);
    // Get.back();
    // Get.back();
    box.write('_caloriesG', calories);
    box.write('distanceG', _distanceCovered);
    box.write('stopwatchG', _stopWatch.value);
    _stopWatch.notifyListeners();
    box.write('_polylinesG', _polylines);
    box.write('entireDataG', entireData);
    box.write('startTimeG', startDate);
    // _stopWatch.value.stop();

    print(box.read('_caloriesG'));
    // Get.back();
    Get.back();
    super.dispose();
  }

  String formatTime(int milliseconds) {
    int secs = milliseconds ~/ 1000;
    String hours = (secs ~/ 3600).toString().padLeft(2, '0');
    String minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    String seconds = (secs % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(size.width);
    print(size.height);
    _stopWatch.notifyListeners();
    return CommonScreenForNavigation(
        appBar: AppBar(
          title: const Text('Track Workout'),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              // try {
              //   if (ChangeCurrentStatus.currentStatus.value != Status.start) {
              //     _positionStreamSubscription?.cancel();
              //     _polylines.clear();
              //     // _markers.clear();
              //     _markerS.value.clear();
              //     // _stopwatch.reset();
              //     _stopWatch.value.reset();

              //     _endMarker = _polylines.last;
              //     _distanceCovered = 0.0;
              //     _stepsCount = 0;
              //     calories = 0;
              //   }
              // } catch (e) {
              //   print(e);
              // }

              // Get.back();
              // ChangeCurrentStatus.currentStatus.value = Status.start;
              // CheckStreamStatus().calories = calories;

              // CheckStreamStatus().steps = _stepsCount;
              // CheckStreamStatus().distance = _distanceCovered;
              // // CheckStreamStatus()._stopWatch = _stopWatch.value;
              // print(CheckStreamStatus().calories);

              // _caloriesG = calories;

              // _stepsG = _stepsCount;
              // distanceG = _distanceCovered;
              // stopwatchG = _stopWatch.value;
              // _stopWatch.notifyListeners();
              // _polylinesG = _polylines;
              // entireDataG = entireData;
              // startTimeG = startDate;
              box.write('_caloriesG', calories);
              box.write('distanceG', _distanceCovered);
              box.write('stopwatchG', _stopWatch.value);
              _stopWatch.notifyListeners();
              box.write('_polylinesG', _polylines);
              box.write('entireDataG', entireData);
              box.write('startTimeG', startDate);
              // _stopWatch.value.stop();

              print(box.read('_caloriesG'));
              // Get.back();
              Get.back();
            },
            child: Icon(
              Icons.keyboard_arrow_left,
              size: 28.sp,
            ),
          ),
          elevation: 0,
        ),
        content: WillPopScope(
          onWillPop: () {
            box.write('_caloriesG', calories);
            box.write('distanceG', _distanceCovered);
            box.write('stopwatchG', _stopWatch.value);
            _stopWatch.notifyListeners();
            box.write('_polylinesG', _polylines);
            box.write('entireDataG', entireData);
            box.write('startTimeG', startDate);
            // _stopWatch.value.stop();

            print(box.read('_caloriesG'));
            // Get.back();
            Get.back();
            // _caloriesG = calories;
            // _stepsG = _stepsCount;
            // distanceG = _distanceCovered;
            // stopwatchG = _stopWatch.value;
            // _stopWatch.notifyListeners();
            // _polylinesG = _polylines;
            // entireDataG = entireData;
            // startTimeG = startDate;
            // // _stopWatch.value.stop();
            // print(_caloriesG);
            // Get.back();
            // Get.back();
            // try {
            //   if (ChangeCurrentStatus.currentStatus.value != Status.start) {
            //     _positionStreamSubscription?.cancel();
            //     _polylines.clear();
            //     // _markers.clear();
            //     _markerS.value.clear();
            //     // _stopwatch.reset();
            //     _stopWatch.value.reset();
            //     _endMarker = _polylines.last;
            //     _distanceCovered = 0.0;
            //     _stepsCount = 0;
            //     calories = 0;
            //   }
            // } catch (e) {
            //   print(e);
            // }

            // Get.back();
            // ChangeCurrentStatus.currentStatus.value = Status.start;
          },
          child: ValueListenableBuilder(
              valueListenable: ChangeCurrentStatus.currentStatus,
              builder: (__, val, _) {
                return ValueListenableBuilder(
                    valueListenable: _markerS,
                    builder: (_, stopMarker, __) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                // left: 13.sp,
                                // top: 10.sp,
                                // right: 13.sp,
                                ),
                            child: RepaintBoundary(
                              key: key,
                              child: Container(
                                color: Colors.blueGrey,
                                height: 39.h,
                                child: SizedBox(
                                  child: GoogleMap(
                                    // zoomGesturesEnabled: true,
                                    onMapCreated: (GoogleMapController controller) async {
                                      _mapController = controller;
                                      // final uin8list = await controller.takeSnapshot();

                                      // final base64image = base64Encode(uin8list);
                                      // print(base64image);
                                    },
                                    polylines: {
                                      Polyline(
                                        polylineId: const PolylineId('route'),
                                        points: _polylines,
                                        color: Colors.blue,
                                        width: 5,
                                        //   patterns: _createDottedPattern(),
                                      ),
                                    },
                                    markers: stopMarker,
                                    zoomControlsEnabled: false,
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(widget.initialPos.latitude,
                                          widget.initialPos.longitude), // Initial camera position
                                      zoom: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //container for start only....
                          if (val == Status.start)
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 13.sp,
                                      top: size.height > 760 ? 24.sp : 15.sp,
                                      right: 13.sp,
                                    ),
                                    child: const Text('Activity Type'),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                        left: 13.sp,
                                        top: 18.sp,
                                        right: 13.sp,
                                      ),
                                      child: Container(
                                        height: 7.h,
                                        padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(width: 1, color: Colors.black)),
                                        child: DropdownButtonFormField<String>(
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          icon: const Icon(
                                            Icons.abc,
                                            color: Colors.transparent,
                                          ),
                                          value: selectedValue,
                                          items: dropdownItems.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              selectedValue = newValue;
                                            });
                                          },
                                        ),
                                      )),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: size.height > 760 ? 34.sp : 22.sp),
                                    child: Center(
                                      child: Container(
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _startListening();

                                                ChangeCurrentStatus.currentStatus.value =
                                                    Status.pause;
                                              },
                                              child: const Icon(
                                                Icons.play_arrow,
                                                size: 36,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 13.sp,
                                            ),
                                            Text(
                                              'Start $selectedValue',
                                              style: TextStyle(fontSize: 16.5.sp),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          //Activity runnging , need to show pause button
                          if (val == Status.pause)
                            Container(
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: size.height > 760 ? 20.sp : 12.sp),
                                    child: Center(
                                        child: Text(
                                      selectedValue,
                                      style: TextStyle(fontSize: 17.sp),
                                    )),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: size.height > 760 ? 25.sp : 13.sp,
                                        left: 15.sp,
                                        right: 15.sp),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              _distanceCovered.toStringAsFixed(2),
                                              style: TextStyle(fontSize: 22.sp),
                                            ),
                                            const Text('Distance [m]')
                                          ],
                                        ),
                                        const Text('-- : --'),
                                        ValueListenableBuilder(
                                            valueListenable: _stopWatch,
                                            builder: (_, v, __) {
                                              return Column(
                                                children: [
                                                  Text(
                                                    formatTime(v.elapsedMilliseconds),
                                                    style: TextStyle(fontSize: 22.sp),
                                                  ),
                                                  const Text('Duration')
                                                ],
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: size.height > 760 ? 18.sp : 10.sp,
                                        left: 15.sp,
                                        right: 15.sp),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              '${calories.toInt()}',
                                              style: TextStyle(fontSize: 22.sp),
                                            ),
                                            const Text('Cal')
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              '$_stepsCount',
                                              style: TextStyle(fontSize: 22.sp),
                                            ),
                                            const Text('Steps')
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _pauseListening();

                                      ChangeCurrentStatus.currentStatus.value = Status.play;
                                    },
                                    child: Container(
                                      height: 40.sp,
                                      width: 30.sp,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle, color: Colors.blue),
                                      child: const Icon(
                                        Icons.pause,
                                        size: 33,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          //Activity get stopped , need to show play button
                          if (val == Status.play)
                            Container(
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: size.height > 760 ? 20.sp : 10.sp),
                                    child: Center(
                                        child: Text(
                                      selectedValue,
                                      style: TextStyle(fontSize: 17.sp),
                                    )),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: size.height > 760 ? 25.sp : 12.sp,
                                        left: 15.sp,
                                        right: 15.sp),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              _distanceCovered.toStringAsFixed(2),
                                              style: TextStyle(fontSize: 22.sp),
                                            ),
                                            const Text('Distance [m]')
                                          ],
                                        ),
                                        const Text('-- : --'),
                                        ValueListenableBuilder(
                                            valueListenable: _stopWatch,
                                            builder: (_, v, __) {
                                              return Column(
                                                children: [
                                                  Text(
                                                    formatTime(v.elapsedMilliseconds),
                                                    style: TextStyle(fontSize: 22.sp),
                                                  ),
                                                  const Text('Duration')
                                                ],
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: size.height > 760 ? 18.sp : 10.sp,
                                        left: 15.sp,
                                        right: 15.sp),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              '${calories.toInt()}',
                                              style: TextStyle(fontSize: 22.sp),
                                            ),
                                            const Text('Cal')
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              '$_stepsCount',
                                              style: TextStyle(fontSize: 22.sp),
                                            ),
                                            const Text('Steps')
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (_stepsCount > 0 && _distanceCovered > 0) {
                                              _stopListening();
                                            }
                                          },
                                          child: Hero(
                                            tag: 'imageTag',
                                            child: Container(
                                              height: 40.sp,
                                              width: 30.sp,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _stepsCount > 0 && _distanceCovered > 0
                                                      ? Colors.blue
                                                      : Colors.grey),
                                              child: const Icon(
                                                Icons.stop,
                                                size: 33,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _playListening();
                                            ChangeCurrentStatus.currentStatus.value = Status.pause;
                                          },
                                          child: Container(
                                            height: 40.sp,
                                            width: 30.sp,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle, color: Colors.blue),
                                            child: const Icon(
                                              Icons.play_arrow,
                                              size: 33,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    });
              }),
        ));
  }

  bool firstTime = true;
  double zoomLevel = 16;
  void _getCurrentLocation() async {
    bool locationStatus = await Permission.location.isDenied;
    if (locationStatus) {
      await Permission.location.request();
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    //[["13.082680","80.270721"],["13.082680","80.270721"]]
    List<List<String>> initialData = [];
    List<String> data = [];
    data.add(position.latitude.toString());
    data.add(position.longitude.toString());
    initialData.add(data);
    print(initialData);
    startDate = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate);
    await StepsActivityApi().sendInitialData(initialData, formattedDateTime);
    // final Uint8List markerIcon = await getBytesFromAsset('assets/images/pin1.png', 160);

    double oldone = 0;
    int addAtFour = 0;
    resumeLng = LatLng(position.latitude, position.longitude);
    box.write('resumeLng', resumeLng);
    setState(() {
      _startMarker = LatLng(position.latitude, position.longitude);
      _markerS.value.add(Marker(
        markerId: const MarkerId('startMarker'),
        position: _startMarker,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
        // icon: BitmapDescriptor.fromBytes(markerIcon))
      ));
    });
    const LocationSettings locationOptions = LocationSettings(accuracy: LocationAccuracy.best);

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationOptions)
        .listen((Position newPosition) {
      if (_isListening) {
        if (firstTime) {
          _polylines.add(LatLng(newPosition.latitude, newPosition.longitude));
          oldone = newPosition.accuracy;
        }
        _stopWatch.notifyListeners();
        // started walking if user away from 5m radius
        // remove jumping distance
        print('NEW position accuracy => ${newPosition.accuracy}');
        print('NEW position speed  =-=>${newPosition.speedAccuracy}');
        // print('see no one cares ' + (oldone - newPosition.accuracy).abs().toString());
        //if (newPosition.accuracy < 2) {}
        // if ((newPosition.accuracy - oldone) < 100 || (newPosition.accuracy - oldone) > -100) {}
        print('good to add==> ${oldone - newPosition.accuracy}');
        //  if (newPosition.accuracy < 15) {}
        // _polylines5.add(LatLng(newPosition.latitude, newPosition.longitude));
        // if (_distanceCovered5 > 1) {
        //   //_polylines.add(LatLng(newPosition.latitude, newPosition.longitude));
        //   _polylines.add(_applySmoothing(LatLng(newPosition.latitude, newPosition.longitude)));
        // }
        // _polylines.add(_applySmoothing(LatLng(newPosition.latitude, newPosition.longitude)));
        if (_distanceCovered5 < 3) {
          _polylines5.add(LatLng(newPosition.latitude, newPosition.longitude));
          _calFirstFiveMeters();
        } else {
          if (addAtFour == 4) {
            addAtFour = 0;
            _polylines.add(LatLng(newPosition.latitude, newPosition.longitude));
          } else {
            addAtFour++;
          }

          oldone = newPosition.accuracy;
          if (_distanceCovered > 0 && _distanceCovered < 50) {
            zoomLevel = 18;
          }
          if (_distanceCovered > 50 && _distanceCovered < 100) {
            zoomLevel = 17;
          }
          if (_distanceCovered > 100 && _distanceCovered < 200) {
            zoomLevel = 16;
          }
          if (_distanceCovered > 200 && _distanceCovered < 500) {
            zoomLevel = 15;
          } else if (_distanceCovered > 500 && _distanceCovered < 800) {
            zoomLevel = 13;
          } else if (_distanceCovered > 800) {
            zoomLevel = 10;
          }
          _mapController?.animateCamera(
              //  CameraUpdate.newLatLng(LatLng(newPosition.latitude, newPosition.longitude)),
              CameraUpdate.newLatLngZoom(
                  LatLng(newPosition.latitude, newPosition.longitude), zoomLevel));

          print('listening length => ${_polylines.length}');
          // if (_distanceCovered5 < 1) {
          //   _calFirstFiveMeters();
          // } else {
          //   _calculateDistance();
          // }
          _calculateDistance();

          firstTime = false;
        }
      } else {
        print('comes here ?');
      }
    });
  }

  resumeAf() {
    print(resumeLng);
    setState(() {
      _markerS.value.add(
        Marker(
          markerId: const MarkerId('startMarker'),
          position: resumeLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    });
    const LocationSettings locationOptions = LocationSettings(accuracy: LocationAccuracy.best);

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationOptions)
        .listen((Position newPosition) {
      if (_isListening) {
        if (firstTime) {
          print(LatLng(newPosition.latitude, newPosition.longitude));
          _polylines.add(LatLng(newPosition.latitude, newPosition.longitude));
          // oldone = newPosition.accuracy;
        }
        _stopWatch.notifyListeners();
        // started walking if user away from 5m radius
        // remove jumping distance
        print('NEW position accuracy => ${newPosition.accuracy}');
        print('NEW position speed  =-=>${newPosition.speedAccuracy}');
        // print('see no one cares ' + (oldone - newPosition.accuracy).abs().toString());
        //if (newPosition.accuracy < 2) {}
        // if ((newPosition.accuracy - oldone) < 100 || (newPosition.accuracy - oldone) > -100) {}
        // print('good to add==> ${oldone - newPosition.accuracy}');
        //  if (newPosition.accuracy < 15) {}
        // _polylines5.add(LatLng(newPosition.latitude, newPosition.longitude));
        // if (_distanceCovered5 > 1) {
        //   //_polylines.add(LatLng(newPosition.latitude, newPosition.longitude));
        //   _polylines.add(_applySmoothing(LatLng(newPosition.latitude, newPosition.longitude)));
        // }
        // _polylines.add(_applySmoothing(LatLng(newPosition.latitude, newPosition.longitude)));
        // if (addAtFour == 4) {
        //   addAtFour = 0;
        //   _polylines.add(LatLng(newPosition.latitude, newPosition.longitude));
        // } else {
        //   addAtFour++;
        // }

        // oldone = newPosition.accuracy;
        if (_distanceCovered > 0 && _distanceCovered < 50) {
          zoomLevel = 18;
        }
        if (_distanceCovered > 50 && _distanceCovered < 100) {
          zoomLevel = 17;
        }
        if (_distanceCovered > 100 && _distanceCovered < 200) {
          zoomLevel = 16;
        }
        if (_distanceCovered > 200 && _distanceCovered < 500) {
          zoomLevel = 15;
        } else if (_distanceCovered > 500 && _distanceCovered < 800) {
          zoomLevel = 13;
        } else if (_distanceCovered > 800) {
          zoomLevel = 10;
        }
        _mapController?.animateCamera(
            //  CameraUpdate.newLatLng(LatLng(newPosition.latitude, newPosition.longitude)),
            CameraUpdate.newLatLngZoom(
                LatLng(newPosition.latitude, newPosition.longitude), zoomLevel));

        print('listening length => ${_polylines.length}');
        // if (_distanceCovered5 < 1) {
        //   _calFirstFiveMeters();
        // } else {
        //   _calculateDistance();
        // }
        _calculateDistance();

        firstTime = false;
      } else {
        print('comes here ?');
      }
    });
  }

  Future<String> captureWidgetToUint8List() async {
    // RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    // ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    // ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    // Uint8List uint8List = byteData.buffer.asUint8List();
    final Uint8List uin8list = await _mapController.takeSnapshot();
    final String base64image = base64Encode(uin8list);
    print(base64image);
    return base64image;
  }

  void _calculateDistance() {
    if (_isListening) {
      print('listening');
      if (_polylines.length > 1) {
        double totalDistance = 0.0;
        for (int i = 0; i < _polylines.length - 1; i++) {
          List<String> data = [];
          data.add(_polylines[i].latitude.toString());
          data.add(_polylines[i].longitude.toString());
          entireData.add(data);
          totalDistance += Geolocator.distanceBetween(
            _polylines[i].latitude,
            _polylines[i].longitude,
            _polylines[i + 1].latitude,
            _polylines[i + 1].longitude,
          );
        }
        _distanceCovered = totalDistance;
        if (_distanceCovered > 0) {
          _stepsCount = (_distanceCovered / _strideLength).round();
          if (_stepsCount > 0) {
            calories =
                (_stopWatch.value.elapsedMilliseconds / (1000 * 60)) * (3 * 3.5 * weight) / 200;
          }
        }
        setState(() {});
      }
    } else {
      print('stopped listening');
    }
  }

  void _calFirstFiveMeters() {
    if (_isListening) {
      print('listening');
      if (_polylines5.length > 1) {
        double totalDistance5 = 0.0;
        for (int i = 0; i < _polylines5.length - 1; i++) {
          List<String> data = [];
          data.add(_polylines5[i].latitude.toString());
          data.add(_polylines5[i].longitude.toString());
          entireData.add(data);
          totalDistance5 += Geolocator.distanceBetween(
            _polylines5[i].latitude,
            _polylines5[i].longitude,
            _polylines5[i + 1].latitude,
            _polylines5[i + 1].longitude,
          );
        }
        _distanceCovered5 = totalDistance5;
      }
    }
  }

  void _startListening() {
    _isListening = true;
    _getCurrentLocation();
    _stopWatch.value.start();
    // _stopwatch.start();
    setState(() {});
  }

  void _pauseListening() {
    _isListening = false;
    // _positionStreamSubscription.pause();
    // _stopwatch.stop();
    _stopWatch.value.stop();
    setState(() {});
    print('after pause button pressed${_polylines.length}');
    print(_stepsCount);
  }

  void _playListening() {
    _isListening = true;
    // _positionStreamSubscription.resume();
    // _stopwatch.start();
    _stopWatch.value.start();
    print('after play button pressed${_polylines.length}');
    setState(() {});
  }

  Future addStopMarker(LatLng endMarker) {
    if (_distanceCovered > 0 && _distanceCovered < 50) {
      zoomLevel = 18;
    }
    if (_distanceCovered > 50 && _distanceCovered < 100) {
      zoomLevel = 17;
    }
    if (_distanceCovered > 100 && _distanceCovered < 200) {
      zoomLevel = 16;
    }
    if (_distanceCovered > 200 && _distanceCovered < 500) {
      zoomLevel = 15;
    } else if (_distanceCovered > 500 && _distanceCovered < 800) {
      zoomLevel = 13;
    } else if (_distanceCovered > 800) {
      zoomLevel = 10;
    }
    _markerS.value.add(
      Marker(
        markerId: const MarkerId('endMarker'),
        position: endMarker,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    _mapController?.animateCamera(
        //  CameraUpdate.newLatLng(LatLng(newPosition.latitude, newPosition.longitude)),
        CameraUpdate.newLatLngZoom(LatLng(endMarker.latitude, endMarker.longitude), zoomLevel));
    _markerS.notifyListeners();
  }

  void _stopListening() async {
    print(entireData);
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    print(formattedDateTime);

    // setState(() {
    //   makeItLine = true;
    // });

    print(_polylines);
    print(startDate);
    Duration activeTime = now.difference(startDate);

    String activeTimeString = activeTime.inHours.toString() == '0'
        ? activeTime.inMinutes.toString() == '0'
            ? '${activeTime.inSeconds} s'
            : '${activeTime.inMinutes} min'
        : '${activeTime.inHours} hrs${activeTime.inMinutes} min ';
    _endMarker = LatLng(double.parse(entireData.last[0]), double.parse(entireData.last[1]));

    await addStopMarker(_endMarker);

    // Add Your Code here.
    Future.delayed(const Duration(seconds: 2), () async {
      String a;
      a = await captureWidgetToUint8List();
      StepsActivityApi().sendEntireData(
          _distanceCovered.toString(),
          _stopWatch.value.elapsed.toString(),
          calories.toString(),
          _stepsCount.toString(),
          formattedDateTime,
          entireData,
          a);
      Get.to(PictureConversion(
          image: a,
          calories: calories.toString(),
          distance: _distanceCovered.toString(),
          duration: _stopWatch.value.elapsed.toString(),
          steps: _stepsCount.toString(),
          startTime: startDate.toString(),
          activeTime: activeTimeString));
    });

    // _stopwatch.reset();

    // _endMarker = _polylines.last;
    // _distanceCovered = 0.0;
    // _stepsCount = 0;
    // calories = 0;
    // _positionStreamSubscription?.cancel();
    // _polylines.clear();
    // _markers.clear();

    //_calculateDistance();

    _positionStreamSubscription?.cancel();
  }

  // bool makeItLine = false;
  // List<PatternItem> _createDottedPattern() {
  //   return !makeItLine
  //       ? <PatternItem>[
  //           PatternItem.dot,
  //           PatternItem.gap(10),
  //         ]
  //       : <PatternItem>[
  //           PatternItem.dash(5),
  //           PatternItem.gap(0),
  //         ];
  // }

  final int _smoothingWindow = 3;
  LatLng _applySmoothing(LatLng newPoint) {
    // Apply moving average smoothing to the new point
    if (_polylines.length < _smoothingWindow) {
      // If there aren't enough points for smoothing, just add the new point
      _polylines.add(newPoint);
    } else {
      // Calculate the average of the last _smoothingWindow points
      double avgLat = 0;
      double avgLng = 0;
      for (int i = _polylines.length - _smoothingWindow; i < _polylines.length; i++) {
        avgLat += _polylines[i].latitude;
        avgLng += _polylines[i].longitude;
      }
      avgLat /= _smoothingWindow;
      avgLng /= _smoothingWindow;

      // Add the averaged point to the smoothed path
      _polylines.add(LatLng(avgLat, avgLng));
    }

    return _polylines.last;
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }
}

enum Status {
  start,
  pause,
  play,
  stop,
}

class ChangeCurrentStatus {
  static ValueNotifier<Status> currentStatus = ValueNotifier<Status>(Status.start);
}

class KalmanFilter {
  // State variables
  double _latitudeEstimate = 0.0;
  double _longitudeEstimate = 0.0;
  double _velocityEstimate = 0.0;

  // State covariance matrix (initialize based on your use case)
  double _positionCovariance = 1.0;
  final double _velocityCovariance = 1.0;

  // Process noise and measurement noise (tune based on your use case)
  final double _processNoise = 0.01;
  final double _measurementNoise = 10.0;

  // Constructor
  KalmanFilter();

  // Prediction Step
  void predict() {
    // Predict the next state based on system dynamics (constant velocity model)
    _latitudeEstimate += _velocityEstimate;
    _longitudeEstimate += _velocityEstimate;

    // Update state covariance matrix based on process noise
    _positionCovariance += _velocityCovariance + _processNoise;
  }

  // Update Step
  void update(double latitudeMeasurement, double longitudeMeasurement) {
    // Calculate Kalman Gain for latitude
    double kalmanGainLatitude = _positionCovariance / (_positionCovariance + _measurementNoise);

    // Calculate Kalman Gain for longitude
    double kalmanGainLongitude = _positionCovariance / (_positionCovariance + _measurementNoise);

    // Update state based on measurements
    _latitudeEstimate += kalmanGainLatitude * (latitudeMeasurement - _latitudeEstimate);
    _longitudeEstimate += kalmanGainLongitude * (longitudeMeasurement - _longitudeEstimate);

    // Update state covariance matrix based on measurement noise and Kalman Gain
    _positionCovariance = (1 - kalmanGainLatitude) * _positionCovariance;
    _velocityEstimate = (_latitudeEstimate + _longitudeEstimate) /
        2; // Update velocity estimate based on new position
  }

  // Get the filtered latitude and longitude
  double getFilteredLatitude() {
    return _latitudeEstimate;
  }

  double getFilteredLongitude() {
    return _longitudeEstimate;
  }
}

class CheckStreamStatus {
  ValueNotifier<bool> isStreamStarted = ValueNotifier<bool>(false);
  final Stopwatch _stopWatch = Stopwatch();
  double distance = 0;
  double calories = 0;
  int steps = 0;
}

class GetResumeDataFromLocal {}
