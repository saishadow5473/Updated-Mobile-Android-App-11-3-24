import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../../../constants/api.dart';
import '../../../../../../utils/SpUtil.dart';
import '../../../../../app/utils/localStorageKeys.dart';
import '../../networks.dart';

class HealthTipsApi {
  static String ihlUniqueName = 'global_services';
  Future healthTipsApi() async {
    // var apiToken = localSotrage.read(LSKeys.apiToken);
    var apiToken = SpUtil.getString(LSKeys.apiToken);
    //var ihlUserToken = localSotrage.read(LSKeys.iHLUserToken);
    var ihlUserToken = SpUtil.getString(LSKeys.iHLUserToken);
    try {
      final response = await dio.get(
        'https://azureapi.indiahealthlink.com/pushnotification/retrieve_healthtip_data',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': apiToken,
            'Token': ihlUserToken
          },
        ),
      );
      return response.data;
    } on DioError catch (error) {
      throw NetworkCallsCardio.checkAndThrowError(error.type);
    }
  }

  Future healthTipsAffiApi({String affiUnqiueName}) async {
    String apiToken = SpUtil.getString(LSKeys.apiToken);
    String ihlUserToken = SpUtil.getString(LSKeys.iHLUserToken);
    try {
      final dynamic response = await dio.post(
        '${API.iHLUrl}/pushnotification/retrieve_affiliated_healthtip',
        data: jsonEncode({
          "affiliation_list": affiUnqiueName,
          "start_index": 0,
          "end_index": 100,
        }),
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
            'ApiToken': apiToken,
            'Token': ihlUserToken
          },
        ),
      );
      return response.data;
    } on DioError catch (error) {
      throw NetworkCallsCardio.checkAndThrowError(error.type);
    }
  }
}
