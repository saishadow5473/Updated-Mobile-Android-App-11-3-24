import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import '../../../../../constants/api.dart';
import '../../../../../utils/CrossbarUtil.dart';
import '../../../../presentation/pages/customizeProgram/postSelectedProgram.dart';
import '../../../../presentation/pages/customizeProgram/selectedProgramDashboard.dart';

class SelectedDashboard {
  final String endPoint = "/platformservice/getUserSelectedDashboard";

  Future<GetUserSelectedDashboard> getSelectedPrograms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString("ihlUserId");
    final response = await Dio().post("${API.iHLUrl}/platformservice/getUserSelectedDashboard",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
        data: {"user_id": userid, "purpose": "dashboard", "platform": "web"});
    if (response.statusCode == 200) {
      if (response.data['status'] == 'success') {
        return GetUserSelectedDashboard.fromJson(response.data);
      } else {
        return GetUserSelectedDashboard(status: response.data['status'], data: [
          Datum(content: {
            "Manage Health": [
              "Vitals",
            ],
            "Online Services": ["Teleconsultations", "Online Class"],
            "Health Program": [],
            "Social": ["Health Challenge", "News Letter", "Health Tips"],
          })
        ]);
      }
    } else {
      throw Exception("Failed to load");
    }
  }

  postSelectedPrograms(programData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString("ihlUserId");
    PostUserSelectedDashboard dataConversion = PostUserSelectedDashboard(
      userId: userid,
      purpose: 'dashboard',
      platform: 'web',
      content: json.encode(programData),
    );
    final response = await Dio().post("${API.iHLUrl}/platformservice/userplatform_configuration",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
        data: dataConversion);
    if (response.statusCode == 200) {
      if (response.data['status'] == "successfully updated") {
        return "Updated Successfully";
      } else if (response.data['status'] == "successfully recorded") {
        return "Successfully Recorded";
      } else {
        return "Error";
      }
    }
  }
}
