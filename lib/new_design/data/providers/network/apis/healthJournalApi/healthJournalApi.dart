import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../utils/SpUtil.dart';
import '../../../../../app/utils/localStorageKeys.dart';
import '../../../../model/healthJournalModel/getTodayLog.dart';
import '../../api_provider.dart';
import '../../networks.dart';

class HealthJournalApi {
  var apiToken = SpUtil.getString(LSKeys.apiToken);
  // var apiToken = localSotrage.read(LSKeys.apiToken);
  // var ihlUserToken = localSotrage.read(LSKeys.iHLUserToken);
  var ihlUserToken = SpUtil.getString(LSKeys.iHLUserToken);
  // var userID = localSotrage.read(LSKeys.ihlUserId);
  var userID = SpUtil.getString(LSKeys.ihlUserId);
  getTodayLog() async {
    var response = await dio.post('${API.iHLUrl}/consult/get_today_log',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': apiToken,
            'Token': ihlUserToken
          },
        ),
        data: jsonEncode(<String, String>{"user_ihl_id": userID}));

    if (response.statusCode == 200) {
      return GetTodayLogModel.fromJson(response.data);
    }
  }

  getGraphData({userID, fromDate, tillDate, tabType}) async {
    final prefs = await SharedPreferences.getInstance();
    log(DateTime.now().millisecondsSinceEpoch.toString());
    log(DateTime.now().subtract(Duration(days: 6)).millisecondsSinceEpoch.toString());
    String iHLUserId = prefs.getString('ihlUserId');
    print(fromDate.toString());
    try {
      final response = await dio.post(API.iHLUrl + '/foodjournal/get_food_log',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
          ),
          data: jsonEncode(<String, String>{
            "user_ihl_id": iHLUserId,
            "from": fromDate.toString(),
            //  "2021-08-01",
            "till": tillDate.toString(),
          }));
      if (response.statusCode == 200) {
        // finalOutput = ;
        // var parsedString = response.data.replaceAll('&quot', '"');
        // var parsedString2 = parsedString.replaceAll("\\\\\\", "");
        // var parsedString3 = parsedString2.replaceAll("\\", "");
        // var parsedString4 = parsedString3.replaceAll(";", "");
        // var parsedString5 = parsedString4.replaceAll('""', '"');
        // var parsedString6 = parsedString5.replaceAll('"[', '[');
        // var parsedString7 = parsedString6.replaceAll(']"', ']');
        // var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
        // var pasrseString9 = pasrseString8.replaceAll('"{', '{');
        // var parseString10 = pasrseString9.replaceAll('}"', '}');
        // var parseString11 = parseString10.replaceAll('System.String[]', '');
        // var parseString12 = parseString11.replaceAll('/"', '/');
        // var parsedString13 = parseString12.replaceAll("rn", "");
        // finalOutput = parsedString13.replaceAll(':",', ':"",');
        // log(jsonEncode(response.data));
        // final foodLog = getFoodLogFromJson(response.data);
        // return foodLog;
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
