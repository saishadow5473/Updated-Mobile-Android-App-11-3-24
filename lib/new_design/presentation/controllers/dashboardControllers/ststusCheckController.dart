import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/new_design/data/providers/network/api_provider.dart';
import 'package:strings/strings.dart';

class StatusController extends GetxController {
  RxString apiStatus = 'Offline'.obs;
  http.Client _client = http.Client();
  updateStatus(var consultantId) async {
    try {
      final response = await _client.post(
        Uri.parse(API.iHLUrl + '/consult/getConsultantLiveStatus'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, dynamic>{
          "consultant_id": [consultantId]
        }),
      );
      if (response.statusCode == 200) {
        if (response.body != '"[]"') {
          var parsedString = response.body.replaceAll('&quot', '"');
          var parsedString1 = parsedString.replaceAll(";", "");
          var parsedString2 = parsedString1.replaceAll('"[', '[');
          var parsedString3 = parsedString2.replaceAll(']"', ']');
          var finalOutput = json.decode(parsedString3);
          var doctorId = consultantId;

          if (doctorId == finalOutput[0]['consultant_id']) {
            apiStatus.value = camelize(finalOutput[0]['status'].toString());
          } else {
            apiStatus.value = "Offline";
          }
        }
      } else {
        "Offline";
      }
    } catch (e) {
      return e;
    }
  }
}
