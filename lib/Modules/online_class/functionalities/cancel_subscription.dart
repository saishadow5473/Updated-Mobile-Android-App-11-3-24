import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/api.dart';
import '../bloc/online_class_api_bloc.dart';
import '../bloc/online_class_events.dart';

class CancelSubscription {
  final Dio dio = Dio();
  cancelSubscription(
      String subscriptionId, String canceledBy, String reason, String provider) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Object data = prefs.get('data');
    Map res = jsonDecode(data);
    var iHLUserId = res['User']['id'];
    Object apiToken = prefs.get('auth_token');
    print(API.headerr['ApiToken'] == null);
    final Response response = await dio.post(
      '${API.iHLUrl}/consult/cancel_subscription',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': API.headerr['ApiToken'] != "null"
              ? '${API.headerr['ApiToken']}'
              : "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
          'Token': '${API.headerr['Token']}',
        },
      ),
      data: jsonEncode(<String, dynamic>{
        "subscription_id": subscriptionId.toString(),
        "canceled_by": canceledBy.toString(),
        "reason": reason.toString(),
      }),
    );
    print(response.data);
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var apiToken = prefs.get('auth_token');
      final response = await dio.post(
        '${API.iHLUrl}/consult/approve_or_reject_subscription',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),

        // headers: {'ApiToken': apiToken},
        data: jsonEncode(<String, String>{
          "company_name": provider,
          "subscription_id": subscriptionId,
          "subscription_status": "Cancelled",
        }),
      );
      if (response.statusCode == 200) {
        var parsedString = response.data;
        if ((parsedString == "Database Updated") || (parsedString == "Approved")) {
          return "success";
        }
      }
      //
      print('cancelled');
    }
  }
}
