import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../new_design/app/utils/localStorageKeys.dart';
import '../utils/SpUtil.dart';

class GetData {
  http.Client _client = http.Client(); //3gb
  static String iHLUrl = Apirepository().iHLUrl;

  Future<bool> uptoUserInfoDate({bool fromWeight}) async {
    final prefs = await SharedPreferences.getInstance();
    String apikey = SpUtil.getString(LSKeys.apiToken);

    if (apikey.toString() == "") {
      var tkn = apikey = prefs.get('auth_token');
      if (tkn.toString().length > 4) {
        apikey = tkn;
      } else {
        apikey =
            '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
        API.headerr['ApiToken'] =
            '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
      }
    }
    qloginApiReplacmentForSso(email) async {
      try {
        final ress1 = await _client.post(
          Uri.parse(iHLUrl + '/sso/get_sso_user_ihl_id'),
          headers: {
            'Content-Type': 'application/json',
            // 'ApiToken': '${API.headerr['ApiToken']}',
            'ApiToken': apikey,
            'Token': '${API.headerr['Token']}',
          },
          // headers: {
          //   'Content-Type': 'application/json',
          //   'Token': 'bearer ',
          //   'ApiToken': authToken
          // },
          body: jsonEncode(<String, String>{
            'email': email,
          }),
        );
        if (ress1.statusCode == 200) {
          if (ress1.body.toString() != 'null') {
            var decodedRess1 = json.decode(ress1.body);
            if (decodedRess1['status'] == 'success') {
              var ihlUserId_for_sso_user = decodedRess1['response']['ihl_user_id'];

              final sso_account_login_response = await _client.post(
                Uri.parse(iHLUrl + '/login/get_user_login'),
                headers: {
                  'Content-Type': 'application/json',
                  // 'ApiToken': '${API.headerr['ApiToken']}',
                  'ApiToken': apikey,
                  'Token': '${API.headerr['Token']}',
                },
                body: jsonEncode(<String, String>{
                  'id': ihlUserId_for_sso_user,
                }),
              );

              print(sso_account_login_response.body);
              return sso_account_login_response;
            }
          }
        } else {
          print(' there is some problem with this api...');
          return 'null';
        }
      } catch (e) {
        print(e.toString());
        return 'null';
      }
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var password = prefs.get('password');
      var email = prefs.get('email');
      var emailM = prefs.get('EmailM');
      var authToken = prefs.get('auth_token');
      var is_Sso = prefs.get('is_sso');
      var apiToken = SpUtil.getString(LSKeys.apiToken);
      // var ihlUserToken = localSotrage.read(LSKeys.iHLUserToken);
      var ihlUserToken = SpUtil.getString(LSKeys.iHLUserToken);
      var response1;
      if (is_Sso.toString() == 'true') {
        response1 = await qloginApiReplacmentForSso(email ?? emailM);
      } else {
        response1 = await _client.post(
          Uri.parse(iHLUrl + '/login/qlogin2'),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': authToken,
            'Token': ihlUserToken,
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'password': password,
          }),
        );
      }
      //response handling
      if (response1.statusCode == 200) {
        if (response1.body == 'null') {
          return false;
        } else {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('data', response1.body);
          return true;
        }
      } else {
        return false;
      }
    } catch (e) {
      print('api calling error-> ' + e.toString());
    }
  }

  Future<String> updateAffiliation(String affiliateUniqueName, String affiliateName,
      String affiliateEmail, String affiliateMobile, String affiliateIdentifierId) async {
    Map affiliationData = {
      "affilate_unique_name": affiliateUniqueName,
      "affilate_name": affiliateName,
      "affilate_email": affiliateEmail,
      "affilate_mobile": affiliateMobile,
      "affliate_identifier_id": affiliateIdentifierId
    };

    Map affiliateToSend;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = prefs.get('data');
    Map res = jsonDecode(userData);
    var userAffiliate = res['User']['user_affiliate'];

    if (userAffiliate != null) {
      if (!userAffiliate.containsKey("af_no1")) {
        affiliateToSend = {'af_no1': affiliationData};
      } else if (!userAffiliate.containsKey("af_no2")) {
        affiliateToSend = {'af_no2': affiliationData};
      } else if (!userAffiliate.containsKey("af_no3")) {
        affiliateToSend = {'af_no3': affiliationData};
      } else if (!userAffiliate.containsKey("af_no4")) {
        affiliateToSend = {'af_no4': affiliationData};
      } else if (!userAffiliate.containsKey("af_no5")) {
        affiliateToSend = {'af_no5': affiliationData};
      } else if (!userAffiliate.containsKey("af_no6")) {
        affiliateToSend = {'af_no6': affiliationData};
      } else if (!userAffiliate.containsKey("af_no7")) {
        affiliateToSend = {'af_no7': affiliationData};
      } else if (!userAffiliate.containsKey("af_no8")) {
        affiliateToSend = {'af_no8': affiliationData};
      } else if (!userAffiliate.containsKey("af_no9")) {
        affiliateToSend = {'af_no9': affiliationData};
      } else {
        return "AffiliationFull";
      }
    } else {
      affiliateToSend = {'af_no1': affiliationData};
    }

    print(affiliateToSend);
    var authToken = prefs.get('auth_token');
    String iHLUserId = res['User']['id'];
    String iHLUserToken = res['Token'];
    final updatedAffiliation = await _client.post(
      Uri.parse(iHLUrl + '/data/user/' + iHLUserId + ''),
      headers: {
        'Content-Type': 'application/json',
        'Token': iHLUserToken,
        'ApiToken': authToken,
        'Accept': 'application/json'
      },
      body: jsonEncode(<String, dynamic>{'user_affiliate': affiliateToSend}),
    );
    if (updatedAffiliation.statusCode == 200) {
      print("Updated Affiliation!");
      return "AffiliationSuccessful";
    } else {
      print(updatedAffiliation.body);
      return "AffiliationFailed";
    }
  }
}
