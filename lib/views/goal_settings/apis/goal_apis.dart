// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, unnecessary_statements, non_constant_identifier_names
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/new_design/app/utils/localStorageKeys.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:ihl/views/dietJournal/journal_graph.dart';
import 'package:ihl/views/dietJournal/models/food_list_tab_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../../utils/SpUtil.dart';

class GoalApis {
  final iHLUrl = API.iHLUrl;
  String iHLUserId;

  getIhlUserId() async {
    final prefs = await SharedPreferences.getInstance();
    var userData = prefs.get('data');
    var decodedResponse = jsonDecode(userData);
    iHLUserId = decodedResponse['User']['id'];
    print(iHLUserId);
  }

  static Future<dynamic> setGoal(Map goalData) async {
    http.Client _client = http.Client(); //3gb
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    try {
      final response = await _client.post(
        Uri.parse(
          API.iHLUrl + '/consult/set_goal',
        ),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(goalData),
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
        var parsedString13 = parseString12.replaceAll("rn", "");
        finalOutput = parsedString13.replaceAll(':",', ':"",');
        print(finalOutput);
        return 'Success';
      } else {
        print('response.statusCode is not 200 , it is =>' + response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<List<dynamic>> listGoal() async {
    final prefs = await SharedPreferences.getInstance();
    // String iHLUserId = prefs.getString('ihlUserId');
    String iHLUserId = SpUtil.getString(LSKeys.ihlUserId);
    http.Client _client = http.Client(); //3gb
    try {
      final response = await _client.post(
        Uri.parse(
          API.iHLUrl + '/consult/view_user_goals',
        ),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, dynamic>{"ihl_user_id": iHLUserId}),
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
        var parsedString13 = parseString12.replaceAll("rn", "");
        var parsedString14 = parsedString13.replaceAll(': ",', ': "",');
        // var p = parsedString14.replaceAll('"goal_sub_type": "', '"goal_sub_type": ""');
        finalOutput = parsedString14.replaceAll(':",', ':"",');
        print(finalOutput);

        return json.decode(finalOutput);
      } else {
        print('response.statusCode is not 200 , it is =>' + response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<dynamic> editGoal(Map goalData) async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final response = await _client.post(
        Uri.parse(
          API.iHLUrl + '/consult/edit_goal',
        ),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(goalData),
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
        var parsedString13 = parseString12.replaceAll("rn", "");
        finalOutput = parsedString13.replaceAll(':",', ':"",');
        print(finalOutput);

        return 'Success';
      } else {
        print('response.statusCode is not 200 , it is =>' + response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
