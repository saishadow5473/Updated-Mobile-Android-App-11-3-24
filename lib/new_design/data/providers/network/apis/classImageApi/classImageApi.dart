import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:ihl/new_design/data/providers/network/api_provider.dart';

import '../../../../../../utils/SpUtil.dart';
import '../../../../../app/utils/localStorageKeys.dart';
import '../../networks.dart';

class ClassImage {
  Future getCourseImageURL(courseID) async {
    var courseIDAndImage = [];
    //var apiToken = localSotrage.read(LSKeys.apiToken);
    var apiToken = SpUtil.getString(LSKeys.apiToken);
    //var ihlUserToken = localSotrage.read(LSKeys.iHLUserToken);
    var ihlUserToken = SpUtil.getString(LSKeys.iHLUserToken);
    try {
      final response = await dio.post(
        "${API.iHLUrl}/consult/courses_image_fetch",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': apiToken,
            'Token': ihlUserToken,
          },
        ),
        data: jsonEncode(<String, dynamic>{
          'classIDList': courseID,
        }),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return response.data;
      }
    } catch (e) {
      print(e);
    }
  }
}
