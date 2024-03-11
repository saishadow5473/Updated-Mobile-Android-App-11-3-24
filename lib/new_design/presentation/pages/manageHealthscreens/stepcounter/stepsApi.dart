import 'dart:convert';

import 'package:ihl/constants/api.dart';
import 'package:ihl/new_design/data/providers/network/networks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepsActivityApi {
  //while start button pressed

  Future sendInitialData(List<List<String>> latlong, String formattedDateTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ihlUserId = prefs.get('IHL_User_ID');
    if (ihlUserId == null) {
      var data = prefs.get('data');

      var userData = jsonDecode(data);

      ihlUserId = userData['User']['id'];
    }
    print(formattedDateTime);
    try {
      var response = await dio.post(
        API.iHLUrl + "/stepwalker/steptracker_start_log",
        data: json.encode({
          "ihl_user_id": ihlUserId,
          "distance_covered": "0",
          "duration": "0",
          "calories_burned": "0",
          "steps_travelled": "0",
          "start_time": formattedDateTime,
          "lat_long": latlong
        }),
      );
      if (response.statusCode == 200) {
        print('data sent');
      }
    } catch (e) {
      print(e);
    }
  }

  sendEntireData(String distance_covered, String duration, String burned_calories, String steps,
      String endTime, List<List<String>> latlong, String base64Image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ihlUserId = prefs.get('IHL_User_ID');
    if (ihlUserId == null) {
      var data = prefs.get('data');

      var userData = jsonDecode(data);

      ihlUserId = userData['User']['id'];
    }
    List<String> parts = duration.split(':');

    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    double seconds = double.parse(parts[2]);

    double totalMinutes = (hours * 60) + minutes + (seconds / 60);

    print(duration);
    try {
      var response = await dio.post(
        API.iHLUrl + "/stepwalker/steptracker_update_log",
        data: json.encode({
          "ihl_user_id": ihlUserId,
          "distance_covered": distance_covered,
          "duration": totalMinutes.toStringAsFixed(2),
          "calories_burned": burned_calories,
          "steps_travelled": steps,
          "end_time": endTime,
          "lat_long": latlong,
          "status": "completed",
          "track_map_img": base64Image
        }),
      );
      if (response.statusCode == 200) {
        print('data sent');
      }
    } catch (e) {
      print(e);
    }
  }
}
