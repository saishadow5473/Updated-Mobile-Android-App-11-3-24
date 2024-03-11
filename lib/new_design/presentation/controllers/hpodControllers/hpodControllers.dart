import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ihl/new_design/data/model/hpodMapModel/hpodMapModel.dart';

import '../../../data/providers/network/api_provider.dart';
import '../../../data/providers/network/networks.dart';

class HpodControllers extends GetxController {
  // Rx<LatLng> latLng = LatLng(45.521563, -122.677433).obs;
  Rx<LatLng> latLng = const LatLng(28.623561814351167, 77.20956906454096).obs;
  RxBool dataLoaded = false.obs;
  List<HpodMapModel> hpodLocations = <HpodMapModel>[].obs;
  var markers = RxSet<Marker>().obs;
  RxMap<double, HpodMapModel> sortedMap = <double, HpodMapModel>{}.obs;
  updateCurrentPosition({@required LatLng val}) {
    latLng.value = val;
  }

  updateCurrentState({@required bool val}) {
    dataLoaded.value = val;
  }

  updateNearbyList({@required Map<double, HpodMapModel> val}) {
    sortedMap.value = val;
  }

  updateMarkers({@required RxSet<Marker> val}) {
    markers.value = val;
  }

  fetchLocations() async {
    try {
      final response = await dio.get(
        '${API.iHLUrl}/empcardiohealth/fetch_kiosk_details',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      for (var element in response.data) {
        hpodLocations.add(HpodMapModel.fromJson(element));
      }
      // hpodLocations.addAll(RxList<Map<String, dynamic>>.from(result)
      //     .map((element) => HpodMapModel.fromJson(element))
      //     .toList());
      print(hpodLocations);
      print(response.data);
      print(response.statusCode);
      dataLoaded.value = true;
      return response.data;
    } on DioError catch (error) {
      throw NetworkCallsCardio.checkAndThrowError(error.type);
    }
  }
}
