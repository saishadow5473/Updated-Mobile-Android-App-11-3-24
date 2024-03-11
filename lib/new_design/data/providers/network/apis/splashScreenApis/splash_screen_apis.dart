import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../constants/api.dart';
import '../../../../../../constants/spKeys.dart';
import '../../../../../../utils/SpUtil.dart';
import '../../../../../app/utils/localStorageKeys.dart';
import '../../networks.dart';

class SplashScreenApiCalls {
  //var apiToken = localSotrage.read(LSKeys.apiToken);
  var apiToken = SpUtil.getString(LSKeys.apiToken);

  //var ihlUserToken = localSotrage.read(LSKeys.iHLUserToken);
  var ihlUserToken = SpUtil.getString(LSKeys.iHLUserToken);

  Future loginApi() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var is_sso = prefs.get(SPKeys.is_sso);
      var authToken = prefs.get(SPKeys.authToken);
      var password = prefs.get(SPKeys.password);
      var email = prefs.get(SPKeys.email);
      var ihlUserId = prefs.get("ihlUserId");
      var loginUrl = is_sso == "true" ? '/login/get_user_login' : '/login/qlogin2';
      Map<String, String> header = {'Content-Type': 'application/json', 'ApiToken': authToken};
      Map<String, String> headerSso = {
        'Content-Type': 'application/json',
        'Token': 'bearer ',
        'ApiToken':
            "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA=="
      };
      var body = jsonEncode(<String, String>{
        'email': email,
        'password': password,
      });
      var bodySso = jsonEncode(<String, String>{
        "id": ihlUserId,
      });
      final response = await dio.post(
        API.iHLUrl + loginUrl,
        data: is_sso == "true" ? bodySso : body,
        options: Options(headers: is_sso == "true" ? headerSso : header),
      );
      return response.data;
    } on DioError catch (error) {
      throw NetworkCallsCardio.checkAndThrowError(error.type);
    }
  }

  Future getDetailsApi({String ihlUID}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var ihlUIDTemp;
      if (ihlUID == null || ihlUID == "") {
        ihlUIDTemp = prefs.getString("ihlUserId");
      } else {
        ihlUIDTemp = ihlUID;
      }
      // await MyvitalsApi().vitalDatas();
      final response = await dio.post("${API.iHLUrl}/consult/get_user_details",
          options: Options(
            headers: {
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
              'Content-Type': 'application/json',
            },
          ),
          data: json.encode({"ihl_id": ihlUIDTemp}));
      return response.data;
    } on DioError catch (error) {
      throw NetworkCallsCardio.checkAndThrowError(error.type);
    }
  }

  Future checkinData({String ihlUID, String ihlUserToken}) async {
    final sharedUserVitalData = await SharedPreferences.getInstance();
    final resp = await dio.get('${API.iHLUrl}/data/user/$ihlUID/checkin',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Token': ihlUserToken,
            'ApiToken':
                "GHG5118RtDtd7C9AXHa9d/i0WDated53MlFmHgDK4n+8s86uo2s4HMvJkWCbKM5485lCRsBc6uTSlUuuzbWMGsJV3q+PEmAfvoVmjF8bKUgBAA=="
          },
        ));
    if (resp.statusCode == 200) {
      sharedUserVitalData.setString(SPKeys.vitalsData, jsonEncode(resp.data));
      return json.encode(resp.data);
    }
  }
}
