import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/new_design/data/providers/network/networks.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/api.dart';
import '../../constants/spKeys.dart';

class VitalsContoller extends GetxController {
  http.Client _client = http.Client();
  var iHLUserId;
  @override
  void onInit() {
    vitalData();
    super.onInit();
  }

  Future vitalData() async {
    var userInputWeight;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var password = prefs.get(SPKeys.password);
    var email = prefs.get(SPKeys.email);
    var authToken = prefs.get(SPKeys.authToken);
    var ihlUserId = prefs.get("ihlUserId");
    var is_sso = prefs.get(SPKeys.is_sso);
    var loginUrl = is_sso == "true" ? '/login/get_user_login' : '/login/qlogin2';
    var body = jsonEncode(<String, String>{
      'email': email,
      'password': password,
    });
    var bodySso = jsonEncode(<String, String>{
      "id": ihlUserId,
    });
    Map<String, String> header = {'Content-Type': 'application/json', 'ApiToken': authToken};
    Map<String, String> headerSso = {
      'Content-Type': 'application/json',
      'Token': 'bearer ',
      'ApiToken':
          "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA=="
    };
    try {
      final response1 = await _client.post(
        Uri.parse(API.iHLUrl + loginUrl),
        headers: is_sso == "true" ? headerSso : header,
        body: is_sso == "true" ? bodySso : body,
      );
      if (response1.statusCode == 200) {
        var resjd = jsonDecode(response1.body);
        if (response1.body == 'null' ||
            response1.body == null ||
            resjd == "Object reference not set to an instance of an object." ||
            response1.body == "Object reference not set to an instance of an object.") {
          return;
        } else {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString(SPKeys.userData, response1.body);

          try {
            ///because when sso true password is null and you can not set null inshare prefrence
            prefs.setString(SPKeys.password, password);
          } catch (e) {
            print(e);
          }
          prefs.setString(SPKeys.email, email);
          var decodedResponse = jsonDecode(response1.body);
          try {
            userInputWeight = decodedResponse['User']['userInputWeightInKG'].toString();
          } catch (e) {
            userInputWeight = null;
          }
          String iHLUserToken = decodedResponse['Token'];
          iHLUserId = decodedResponse['User']['id'];
          bool introDone = decodedResponse['User']['introDone'];
          SharedPreferences prefs1 = await SharedPreferences.getInstance();
          prefs1.setString("ihlUserId", iHLUserId);
          API.headerr = {};
          API.headerr['Token'] = '$iHLUserToken';
          API.headerr['ApiToken'] = is_sso != "true"
              ? '$authToken'
              : "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==";
          print("##############################################" + API.headerr.toString());

          // Fetch all Vital data API call
          final vitalData = await dio.get(API.iHLUrl + '/data/user/' + iHLUserId + '/checkin',
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  'Token': iHLUserToken,
                  'ApiToken':
                      "GHG5118RtDtd7C9AXHa9d/i0WDated53MlFmHgDK4n+8s86uo2s4HMvJkWCbKM5485lCRsBc6uTSlUuuzbWMGsJV3q+PEmAfvoVmjF8bKUgBAA==",
                },
              ));
          if (vitalData.statusCode == 200) {
            final sharedUserVitalData = await SharedPreferences.getInstance();
            sharedUserVitalData
                .setString(SPKeys.vitalsData, jsonEncode(vitalData.data))
                .then(((value) {
              update(['vital']);
            }));
          } else {}
        }
      } else {}
    } catch (e) {
      print(e);
    }
  }
}
