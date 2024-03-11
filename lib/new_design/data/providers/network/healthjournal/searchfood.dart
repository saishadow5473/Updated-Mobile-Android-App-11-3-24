import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../Getx/controller/listOfChallengeContoller.dart';
import '../api_provider.dart';

class SearchFoodApi {
  static Future searchFoodList(
      {@required int endPage, @required String letter}) async {
    final ListChallengeController listChallengeController = Get.find();
    var endIndex = endPage + 5;
    try {
      var _res = await Dio().post(
        "${API.iHLUrl}/foodjournal/list_of_food_items_starts_with",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
        data: {
          "search_string": letter,
          'ihl_user_id': listChallengeController.userid,
          "advanceSearch": true,
          "start_index": 1,
          "end_index": 5,
        },
      );
      if (_res.statusCode == 200) {
        return _res.data['final_food_list'];
      }
    } catch (e) {
      print(e);
    }
  }
}
