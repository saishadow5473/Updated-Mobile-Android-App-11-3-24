import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/spKeys.dart';
import '../data/providers/network/api_provider.dart';
import 'common_controller.dart';

class CommonApiCalls {
  static Dio dio = Dio();
  static Future<dynamic> userDataUpdateAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic prefValue = prefs.get(SPKeys.is_sso);

    bool logedSso = prefValue == 'true' ? true : false;
    String email = prefs.get(SPKeys.email);
    String password = prefs.get(SPKeys.password);
    String ihlUserId = prefs.get("ihlUserId");

    try {
      Response<dynamic> response;
      if (logedSso) {
        response = await dio.post('${API.iHLUrl}/login/get_user_login',
            options: Options(
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Token': 'bearer ',
                'ApiToken':
                    "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA=="
              },
            ),
            data: jsonEncode(<String, String>{
              "id": ihlUserId,
            }));
        return response.data;
      } else {
        response = await dio.post('${API.iHLUrl}/login/qlogin2',
            options: Options(
              headers: <String, dynamic>{
                'Content-Type': 'application/json',
                'ApiToken': CommonController.token ?? API.ihlToken,
                'Token': CommonController.authToken,
              },
            ),
            data: jsonEncode(<String, String>{
              'email': email,
              'password': password,
            }));
        return response.data;
      }
    } on DioError catch (error) {
      debugPrint(error.toString());
    }
  }

  static Future<dynamic> getCheckinData({String iHLUserId}) async {
    try {
      Response<dynamic> response = await dio.get(
        '${API.iHLUrl}/data/user/$iHLUserId/checkin',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Token': API.headerr['Token'],
            'ApiToken':
                "GHG5118RtDtd7C9AXHa9d/i0WDated53MlFmHgDK4n+8s86uo2s4HMvJkWCbKM5485lCRsBc6uTSlUuuzbWMGsJV3q+PEmAfvoVmjF8bKUgBAA==",
          },
        ),
      );
      return response.data;
    } on DioError catch (error) {
      debugPrint(error.toString());
    }
  }
}
