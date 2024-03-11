import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import '../../../constants/api.dart';
import '../models/create_edit_ingredient_model.dart';
import '../models/create_edit_meal_model.dart';
import '../models/frequent_food_consumed.dart';
import '../models/log_user_activity_model.dart';
import '../models/log_user_food_intake_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogApis {
  final iHLUrl = API.iHLUrl;
  // final ihlToken = API.ihlToken;
  String iHLUserId;

  getIhlUserId() async {
    final prefs = await SharedPreferences.getInstance();
    iHLUserId = prefs.getString('ihlUserId');
  }

  //10. Log food Intake -(API-10)
  static Future<LogUserFoodIntakeResponse> logUserFoodIntakeApi({LogUserFood data}) async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final response = await _client.post(
        Uri.parse(
          // API.iHLUrl + '/consult/log_user_food_intake?ihl_user_id=$iHLUserId',
          '${API.iHLUrl}/foodjournal/log_user_food_intake',
        ),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: logUserFoodToJson(data),
      );
      var finalOutput;
      if (response.statusCode == 200) {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString2 = parsedString.replaceAll("\\\\\\", "");
        var parsedString3 = parsedString2.replaceAll("\\", "");
        var parsedString4 = parsedString3.replaceAll(";", "");
        var parsedString5 = parsedString4.replaceAll('""', '"');
        var parsedString6 = parsedString5.replaceAll('"[', '[');
        var parsedString7 = parsedString6.replaceAll(']"', ']');
        var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
        var pasrseString9 = pasrseString8.replaceAll('"{', '{');
        var parseString10 = pasrseString9.replaceAll('}"', '}');
        var parseString11 = parseString10.replaceAll('System.String[]', '');
        var parseString12 = parseString11.replaceAll('/"', '/');
        finalOutput = parseString12.replaceAll(':",', ':"",');
        final logUserFoodIntake = logUserFoodIntakeFromJson(finalOutput);
        return logUserFoodIntake;
      } else {
        print('response.statusCode is not 200 , it is =>' + response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<FrequentFoodConsumed> frequentFoodGroupMeal(
      {
        String meal_category,
        String foodFoodIdList,
        String foodNamelist,
        String foodQuantityList,
        }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final http.Response response =
      await _client.post(Uri.parse('${API.iHLUrl}/foodjournal/create_frequent_food_log'),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
          body: jsonEncode(<String, dynamic>
          {
            "user_id": iHLUserId,   // mandatory
            "category": meal_category,
            "list_of_food_logs": [      // mandatory
              {
                "food_id": foodFoodIdList.toString(),
                "quantity": foodQuantityList.toString(),
                "name": foodNamelist.toString()
              }
            ]
          }
          ));
      String finalOutput;
      if (response.statusCode == 200) {
        if (response.body.contains('success')) {
          String parsedString = response.body.replaceAll('&quot', '"');
          String parsedString2 = parsedString.replaceAll("\\\\\\", "");
          String parsedString3 = parsedString2.replaceAll("\\", "");
          String parsedString4 = parsedString3.replaceAll(";", "");
          String parsedString5 = parsedString4.replaceAll('""', '"');
          String parsedString6 = parsedString5.replaceAll('"[', '[');
          String parsedString7 = parsedString6.replaceAll(']"', ']');
          String pasrseString8 = parsedString7.replaceAll(':,', ':"",');
          String pasrseString9 = pasrseString8.replaceAll('"{', '{');
          String parseString10 = pasrseString9.replaceAll('}"', '}');
          String parseString11 = parseString10.replaceAll('System.String[]', '');
          String parseString12 = parseString11.replaceAll('/"', '/');
          finalOutput = parseString12.replaceAll(':",', ':"",');
          final logUserFoodIntake = frequentFoodConsumedFromJson(finalOutput);
          return logUserFoodIntake;
        } else {
          print('group name already exists');
          return null;
        }
      } else {
        print('response.statusCode is not 200 , it is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<LogUserFoodIntakeResponse> editUserFoodLogApi({EditLogUserFood data}) async {
    // var a = editlogUserFoodToJson(data);
    // var ab = API.iHLUrl + '/consult/edit_food_log';
    // print(a);
    // print(ab);
    http.Client _client = http.Client(); //3gb
    try {
      final response = await _client.post(
        Uri.parse(
          API.iHLUrl + '/foodjournal/edit_food_log',
        ),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: editlogUserFoodToJson(data),
      );
      var finalOutput;
      print(response.body);
      if (response.statusCode == 200) {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString2 = parsedString.replaceAll("\\\\\\", "");
        var parsedString3 = parsedString2.replaceAll("\\", "");
        var parsedString4 = parsedString3.replaceAll(";", "");
        var parsedString5 = parsedString4.replaceAll('""', '"');
        var parsedString6 = parsedString5.replaceAll('"[', '[');
        var parsedString7 = parsedString6.replaceAll(']"', ']');
        var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
        var pasrseString9 = pasrseString8.replaceAll('"{', '{');
        var parseString10 = pasrseString9.replaceAll('}"', '}');
        var parseString11 = parseString10.replaceAll('System.String[]', '');
        var parseString12 = parseString11.replaceAll('/"', '/');
        finalOutput = parseString12.replaceAll(':",', ':"",');
        final logUserFoodIntake = logUserFoodIntakeFromJson(finalOutput);
        return logUserFoodIntake;
      } else {
        print('response.statusCode is not 200 , it is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<LogUserFoodIntakeResponse> createEditCustomFoodApi({CreateEditRecipe data}) async {
    http.Client _client = http.Client(); //3gb
    try {
      final response = await _client.post(
        Uri.parse(
          '${API.iHLUrl}/foodjournal/create_or_edit_recipe',
        ),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: createEditRecipeToJson(data),
      );
      var finalOutput;
      if (response.statusCode == 200) {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString2 = parsedString.replaceAll("\\\\\\", "");
        var parsedString3 = parsedString2.replaceAll("\\", "");
        var parsedString4 = parsedString3.replaceAll(";", "");
        var parsedString5 = parsedString4.replaceAll('""', '"');
        var parsedString6 = parsedString5.replaceAll('"[', '[');
        var parsedString7 = parsedString6.replaceAll(']"', ']');
        var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
        var pasrseString9 = pasrseString8.replaceAll('"{', '{');
        var parseString10 = pasrseString9.replaceAll('}"', '}');
        var parseString11 = parseString10.replaceAll('System.String[]', '');
        var parseString12 = parseString11.replaceAll('/"', '/');
        finalOutput = parseString12.replaceAll(':",', ':"",');
        final logUserFoodIntake = logUserFoodIntakeFromJson(finalOutput);
        return logUserFoodIntake;
      } else {
        print('response.statusCode is not 200 , it is =>' + response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<LogUserFoodIntakeResponse> createEditCustomIngredientApi(
      {CreateEditIngredient data}) async {
    http.Client _client = http.Client(); //3gb
    try {
      log(jsonEncode(data.toJson()).toString());
      final response = await _client.post(
        Uri.parse(
          API.iHLUrl + "/foodjournal/create_or_edit_user_ingredient_detail",
        ),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(data.toJson()),
      );

      var finalOutput;
      if (response.statusCode == 200) {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString2 = parsedString.replaceAll("\\\\\\", "");
        var parsedString3 = parsedString2.replaceAll("\\", "");
        var parsedString4 = parsedString3.replaceAll(";", "");
        var parsedString5 = parsedString4.replaceAll('""', '"');
        var parsedString6 = parsedString5.replaceAll('"[', '[');
        var parsedString7 = parsedString6.replaceAll(']"', ']');
        var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
        var pasrseString9 = pasrseString8.replaceAll('"{', '{');
        var parseString10 = pasrseString9.replaceAll('}"', '}');
        var parseString11 = parseString10.replaceAll('System.String[]', '');
        var parseString12 = parseString11.replaceAll('/"', '/');
        finalOutput = parseString12.replaceAll(':",', ':"",');
        final logUserFoodIntake = logUserFoodIntakeFromJson(finalOutput);
        print('response.response is not 200 , it is =>' + response.toString());
        return logUserFoodIntake;
      } else {
        print('response.statusCode is not 200 , it is =>' + response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /// Bookmark Food items
  static Future<String> bookmarkFoodApi({String foodItemID}) async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final response = await _client.get(
        Uri.parse(API.iHLUrl +
            '/foodjournal/store_bookmark_food_item_id?ihl_user_id=$iHLUserId&food_item_id=$foodItemID'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      );
      if (response.statusCode == 200) {
        return 'Success';
      } else {
        print('response.statusCode is not 200 , it is =>' + response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /// Delete Bookmarked Food items
  static Future<String> deleteBookmarkFoodApi({String foodItemID}) async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final response = await _client.get(
        Uri.parse(API.iHLUrl +
            '/foodjournal/delete_bookmark_food_item_id?ihl_user_id=$iHLUserId&food_item_id=$foodItemID'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      );
      if (response.statusCode == 200) {
        return 'Success';
      } else {
        print('response.statusCode is not 200 , it is =>' + response.statusCode.toString());
        print(response.body);
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<String> deleteCustomUserFoodApi({String foodItemID}) async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final response = await _client.get(
        Uri.parse(API.iHLUrl +
            '/foodjournal/delete_user_recipe?food_id=$foodItemID&ihl_user_id=$iHLUserId'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      );
      if (response.statusCode == 200) {
        return 'Success';
      } else {
        print('response.statusCode is not 200 , it is =>' + response.statusCode.toString());
        print(response.body);
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //12. Log users activity -(API-12)
  static Future<LogUserActivity> logUserActivityApi({data}) async {
    var jsp = jsonEncode(data);
    print(jsp);
    http.Client _client = http.Client(); //3gb
    try {
      final response = await _client
          .post(
            Uri.parse(
              API.iHLUrl + '/consult/log_user_activity', //?ihl_user_id=abc',
            ),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));
      var finalOutput;
      print(response);
      if (response.statusCode == 200) {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString2 = parsedString.replaceAll("\\\\\\", "");
        var parsedString3 = parsedString2.replaceAll("\\", "");
        var parsedString4 = parsedString3.replaceAll(";", "");
        var parsedString5 = parsedString4.replaceAll('""', '"');
        var parsedString6 = parsedString5.replaceAll('"[', '[');
        var parsedString7 = parsedString6.replaceAll(']"', ']');
        var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
        var pasrseString9 = pasrseString8.replaceAll('"{', '{');
        var parseString10 = pasrseString9.replaceAll('}"', '}');
        var parseString11 = parseString10.replaceAll('System.String[]', '');
        var parseString12 = parseString11.replaceAll('/"', '/');
        finalOutput = parseString12.replaceAll(':",', ':"",');
        final logUserActivity = logUserActivityFromJson(finalOutput);
        return logUserActivity;
      } else {
        print('response.statusCode is not 200 , it is =>' + response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<LogUserActivity> editLogUserActivityApi({data}) async {
    var a = jsonEncode(data);
    print(a);
    http.Client _client = http.Client(); //3gb
    try {
      final response = await _client.post(
        Uri.parse(
          API.iHLUrl + '/consult/edit_activity_log', //?ihl_user_id='abc,
        ),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(data),
      );
      var finalOutput;
      if (response.statusCode == 200) {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString2 = parsedString.replaceAll("\\\\\\", "");
        var parsedString3 = parsedString2.replaceAll("\\", "");
        var parsedString4 = parsedString3.replaceAll(";", "");
        var parsedString5 = parsedString4.replaceAll('""', '"');
        var parsedString6 = parsedString5.replaceAll('"[', '[');
        var parsedString7 = parsedString6.replaceAll(']"', ']');
        var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
        var pasrseString9 = pasrseString8.replaceAll('"{', '{');
        var parseString10 = pasrseString9.replaceAll('}"', '}');
        var parseString11 = parseString10.replaceAll('System.String[]', '');
        var parseString12 = parseString11.replaceAll('/"', '/');
        finalOutput = parseString12.replaceAll(':",', ':"",');
        final logUserActivity = logUserActivityFromJson(finalOutput);
        return logUserActivity;
      } else {
        print('response.statusCode is not 200 , it is =>' + response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // 3. making User Bookmarked Activities
  static Future<bool> logBookMarkActivity({activiytID}) async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final response = await _client.get(
        Uri.parse(API.iHLUrl +
            '/consult/bookmark_user_activities?activity_id=$activiytID&ihl_user_id=$iHLUserId'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        //lw8nEpxp2EqqUngGCYXZoe'),
        // mxCwQjViHUqeURbQNcZghw'),
        //$iHLUserId'),
        ////lw8nEpxp2EqqUngGCYXZoe'),
      );
      var finalOutput;
      if (response.statusCode == 200) {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString2 = parsedString.replaceAll("\\\\\\", "");
        var parsedString3 = parsedString2.replaceAll("\\", "");
        var parsedString4 = parsedString3.replaceAll(";", "");
        var parsedString5 = parsedString4.replaceAll('""', '"');
        var parsedString6 = parsedString5.replaceAll('"[', '[');
        var parsedString7 = parsedString6.replaceAll(']"', ']');
        var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
        var pasrseString9 = pasrseString8.replaceAll('"{', '{');
        var parseString10 = pasrseString9.replaceAll('}"', '}');
        var parseString11 = parseString10.replaceAll('System.String[]', '');
        var parseString12 = parseString11.replaceAll('/"', '/');
        finalOutput = parseString12.replaceAll(':",', ':"",');
        // final bookMarkedActivity = bookMarkedActivityFromJson(finalOutput);
        var result = json.decode(finalOutput);
        if (result['status'] == "Selected Activity Stored"|| result['status']=="Selected Activity already bookmarked") {
          return true;
        }

        // return bookMarkedActivity;
      } else {
        print('response.statusCode is not 200 , it is =>' + response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
