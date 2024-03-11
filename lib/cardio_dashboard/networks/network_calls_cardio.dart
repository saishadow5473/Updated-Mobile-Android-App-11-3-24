import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/api.dart';
import '../../constants/spKeys.dart';
import '../../new_design/app/utils/localStorageKeys.dart';
import '../../utils/SpUtil.dart';
import '../models/store_medical_data.dart';

class NetworkCallsCardio {
  final Dio dio = Dio();

  Future getMedicalData({String userId}) async {
    // dio.options.receiveTimeout = 5000;

    try {
      var response = await dio.post(
        API.iHLUrl + '/empcardiohealth/retrieve_medical_data',
        data: json.encode({"ihl_user_id": userId}),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      print(response.data);
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getConsaltantData({String iHLUserId}) async {
    // dio.options.receiveTimeout = 5000;
    try {
      var response = await dio.post(API.iHLUrl + "/consult/GetPlatfromData",
          options: Options(headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          }),
          data: {'ihl_id': iHLUserId, 'cache': "true"});
      print(response.data);
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future userData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var data = prefs.get('data');
      final map = jsonDecode(data);
      return map["User"];
    } on DioError catch (error) {
      print(error);
      throw checkAndThrowError(error.type);
    }
  }

  Future userLastCheckin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var data = prefs.get('data');
      final map = jsonDecode(data);
      return map["LastCheckin"];
    } on DioError catch (error) {
      print(error);
      throw checkAndThrowError(error.type);
    }
  }

  Future retriveMedicalDatas({String iHLUserId}) async {
    try {
      final response = await dio.post(
        API.iHLUrl + '/empcardiohealth/retrieve_medical_data',
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
        data: json.encode({"ihl_user_id": iHLUserId}),
      );
      return response.data[0];
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future vitalsToShowAPi({String iHLUserId}) async {
    var apiToken = SpUtil.getString(LSKeys.apiToken);
    //var ihlUserToken = localSotrage.read(LSKeys.iHLUserToken);
    var ihlUserToken = SpUtil.getString(LSKeys.iHLUserToken);
    try {
      final response = await dio.get(API.iHLUrl + '/data/user/' + iHLUserId + '/checkin',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Token': API.headerr['Token'],
              'ApiToken': API.headerr['ApiToken']
            },
          ));
      if (response.statusCode == 200) {
        if (response.data.length > 0) {
          return response.data[0];
        } else {
          return [];
        }
      } else {}
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future storeMedicalData({String iHLUserId, StoreMedicalData storeMedicalData}) async {
    try {
      final response = await dio.post(
        API.iHLUrl + '/empcardiohealth/store_medical_data',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Token': API.headerr['Token'],
            'ApiToken':
                '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==',
          },
        ),
        data: storeMedicalData.toJson(),
      );
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future retriveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _prefValue = prefs.get(
      SPKeys.is_sso,
    );

    bool _logedSso = _prefValue == 'true' ? true : false;
    var email = prefs.get(SPKeys.email);
    var password = prefs.get(SPKeys.password);
    var ihlUserId = prefs.get("ihlUserId");

    try {
      final response = await dio.post(
          !_logedSso ? API.iHLUrl + '/login/qlogin2' : API.iHLUrl + '/login/get_user_login',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
          ),
          data: !_logedSso
              ? jsonEncode(<String, String>{
                  'email': email,
                  'password': password,
                })
              : jsonEncode(<String, String>{
                  "id": ihlUserId,
                }));
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getCheckinData({String iHLUserId}) async {
    try {
      final response = await dio.get(
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
      throw checkAndThrowError(error.type);
    }
  }

  static checkAndThrowError(DioErrorType errorType) {
    switch (errorType) {
      case DioErrorType.sendTimeout:
        log('Send TimeOut');
        throw Exception('sendTimeout');
        break;
      case DioErrorType.receiveTimeout:
        log('Receive TimeOut');
        throw Exception('receiveTimeout');
        break;
      case DioErrorType.response:
        log('Error Response');
        throw Exception('response');
        break;
      case DioErrorType.cancel:
        log('Connection Cancel');
        throw Exception('cancel');
        break;
      case DioErrorType.other:
        log('Other Error');
        throw Exception('other');
        break;
      case DioErrorType.connectTimeout:
        log('Connect Timeout');
        throw Exception('connectTimeout');
        break;
    }
  }
}
