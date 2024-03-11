import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ihl/views/cardiovascular_views/direction_model.dart';

class DirectionsRepository {
  http.Client _client = http.Client(); //3gb
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  Future<Directions> getDirections({
    @required LatLng origin,
    @required LatLng destination,
  }) async {
    final http.Response response = await _client.get(
      Uri.parse(_baseUrl +
          'origin=13.0135125,80.200097' +
          '&&' +
          'destination=${destination.latitude},${destination.longitude}' +
          '&&' +
          'key=AIzaSyAyzL5ZhJYJx8Ogbt6ZYVWwoii2ZZ1IHYU'), //(13.013660760152224,80.20033176988365)
      // headers: {
      //   // LatLng(13.0135125,80.200097)
      //   'origin': '13.0135125,80.200097',
      //   'destination': '${destination.latitude},${destination.longitude}',
      //   // 'destination': '13.013660760152224,80.20033176988365',
      //   'key': 'AIzaSyAyzL5ZhJYJx8Ogbt6ZYVWwoii2ZZ1IHYU',//googleAPIKey
      // },
    );

    // Check if response is successful
    if (response.statusCode == 200) {
      var v = jsonDecode(response.body);
      print(v.runtimeType);
      return Directions.fromMap(jsonDecode(response.body));
    }
    return null;
  }
}
