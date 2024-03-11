import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteApis {
  String iHLUserId;
  // 3. delete User Bookmarked Activities
  static Future<bool> deleteBookMarkActivity({activityID}) async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final response = await _client.get(
        Uri.parse(API.iHLUrl +
            '/consult/delete_user_activity?activity_id=$activityID&ihl_user_id=$iHLUserId'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        //lw8nEpxp2EqqUngGCYXZoe'),//$iHLUserId'),//lw8nEpxp2EqqUngGCYXZoe'),
      );
      var finalOutput;
      if (response.statusCode == 200) {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString2 = parsedString.replaceAll("\\\\\\", "");
        var parsedString3 = parsedString2.replaceAll("\\", "");
        var parsedString4 = parsedString3.replaceAll(";", "");
        var parsedString5 = parsedString4.replaceAll('""', '"');
        var parsedString6 = parsedString5.replaceAll('"[', '[');
        var parsedString7 = parsedString6.replaceAll(']"', ']');
        var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
        var pasrseString9 = pasrseString8.replaceAll('"{', '{');
        var parseString10 = pasrseString9.replaceAll('}"', '}');
        var parseString11 = parseString10.replaceAll('System.String[]', '');
        var parseString12 = parseString11.replaceAll('/"', '/');
        finalOutput = parseString12.replaceAll(':",', ':"",');
        // final bookMarkedActivity = bookMarkedActivityFromJson(finalOutput);
        var result = json.decode(finalOutput);
        if (result[0]['status'] == "Activity Deleted Successfully") {
          return true;
        }
        // return bookMarkedActivity;
      } else {
        print('response.statusCode is not 200 , it is =>' +
            response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
