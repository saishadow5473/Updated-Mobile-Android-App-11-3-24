// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, unnecessary_statements, non_constant_identifier_names
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/views/dietJournal/calorieGraph/monthly_calorie_tab.dart';
import 'package:ihl/views/dietJournal/journal_graph.dart';
import 'package:ihl/views/dietJournal/models/autoCompleteList_ofIngredients.dart';
import 'package:ihl/views/dietJournal/models/food_list_model.dart';
import 'package:ihl/views/dietJournal/models/food_list_tab_model.dart';
import 'package:ihl/views/dietJournal/models/get_activity_log_model.dart';
import 'package:ihl/views/dietJournal/models/get_food_log_model.dart';
import 'package:ihl/views/dietJournal/models/get_todays_food_log_model.dart';
import 'package:ihl/views/dietJournal/models/today_food_logs.dart';
import 'package:ihl/views/dietJournal/models/user_bookmarked_activity_model.dart';
import 'package:ihl/views/dietJournal/models/viewFoodDetail.dart';
import 'package:ihl/views/dietJournal/models/view_custom_food_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../../new_design/presentation/pages/manageHealthscreens/stepcounter/trackActivityWithMap.dart';
import '../models/create_food_group_meal_model.dart';
import '../models/delete_food_group_meal.dart';
import '../models/food_deatils_updated.dart';
import '../models/food_unit_detils.dart';
import '../models/get_bookmarked_food.dart';
import '../models/get_frequent_food_consumed.dart';

//line 17 && 59 && 120 parse remaining!!!==>9,12,6,14
class ListApis {
  final String iHLUrl = API.iHLUrl;
  String iHLUserId;
  http.Client _client = http.Client(); //3gb

  getIhlUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Object userData = prefs.get('data');
    var decodedResponse = jsonDecode(userData);
    iHLUserId = decodedResponse['User']['id'];
  }

  //5. Auto Complete - List of Ingredients - Integrated(API-5)
  Future<List<AutoCompleteListOfIngredient>> autoCompleteSearchAPI({String searchText}) async {
    try {
      final http.Response response = await _client.get(
        Uri.parse(
            '$iHLUrl/consult/list_of_ingredient_starts_with?search_string=$searchText&ihl_user_id=$iHLUserId'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      );
      var finalOutput;
      if (response.statusCode == 200) {
        // final classData = classDataFromJson(finalOutput);
        final List<AutoCompleteListOfIngredient> autoCompleteListOfIngredient =
            autoCompleteListOfIngredientFromJson(finalOutput);

        return autoCompleteListOfIngredient;
      } else {
        print('response.statusCode is not 200 , it is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<ViewFoodDetail> foodDetailsApi({String itemId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    Map<String, String> abc = {
      'Content-Type': 'application/json',
      'ApiToken': '${API.headerr['ApiToken']}',
      'Token': '${API.headerr['Token']}',
    };
    http.Client _client = http.Client(); //3gb
    try {
      final http.Response response = await _client.get(
          Uri.parse(
              '${API.iHLUrl}/consult/get_food_details?food_item_id=$itemId&ihl_user_id=$iHLUserId'),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          });
      if (response.statusCode == 200) {
        ///for old
        String parse = response.body.replaceAll('"&quot;', '"');
        // var parse2 = parse.replaceAll('&quot;', '');
        String parse1 = parse.replaceAll('&#160;', ' ');
        final ViewFoodDetail viewFoodDetail = viewFoodDetailFromJson(parse1);

        ///end
        ///for new
        // final viewFoodDetail = viewFoodDetailFromJson(response.body);
        ///end

        return viewFoodDetail;
      } else {
        print('Response.statusCode is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<UpdatedFoodDetails> updatedGetFoodDetails({String foodID}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client();
    try {
      final http.Response response = await _client
          .get(Uri.parse('${API.iHLUrl}/foodjournal/get_food_detail?food_id=$foodID'), headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      });
      if (response.statusCode == 200) {
        String parse = response.body.replaceAll('"&quot;', '"');
        // var parse2 = parse.replaceAll('&quot;', '');
        String parse1 = parse.replaceAll('&#160;', ' ');
        final UpdatedFoodDetails updatedFoodDetails = updatedFoodDetailsFromJson(parse1);

        String parse2 = updatedFoodDetails.servingUnitSize.replaceAll("and", "*");
        String parse3 = parse2.replaceAll("half", "1/2");
        String parse4 = parse3.replaceAll("inches", '")');
        String parse5 = parse4.replaceAll("one", '1');
        String parse6 = parse5.replaceAll("two", '2');
        String parse7 = parse6.replaceAll("three", '3');
        String parse8 = parse7.replaceAll("four", '4');
        String parse9 = parse8.replaceAll("five", '5');
        String parse10 = parse9.replaceAll("six", '6');
        String parse11 = parse10.replaceAll("seven", '7');
        String parse12 = parse11.replaceAll("eight", '8');
        String parse13 = parse12.replaceAll("nine", '9');
        String parse14 = parse13.replaceAll("zero", '0');
        String parse15 = parse14.replaceAll(" to ", '-');
        String parse16 = parse15.replaceAll("Small ", "Small (");
        String parse17 = parse16.replaceAll("Medium ", "Medium (");
        String parse18 = parse17.replaceAll("Large ", "Large (");
        String parse19 = parse18.replaceAll("by", "/");
        String parse20 = parse19.replaceAll('\"', "");

        updatedFoodDetails.servingUnitSize = parse20;

        return updatedFoodDetails;
      } else {
        print('Response.statusCode is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<List<GetFoodUnit>> getFoodUnit(itemID) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client();
    try {
      final http.Response response = await _client
          .get(Uri.parse('${API.iHLUrl}/foodjournal/get_different_sizes_of_food?item=$itemID'));
      if (response.statusCode == 200) {
        String parse = response.body.replaceAll('"&quot;', '"');
        // var parse2 = parse.replaceAll('&quot;', '');
        String parse1 = parse.replaceAll('&#160;', ' ');
        final List<GetFoodUnit> foodUnits = getFoodUnitFromJson(parse1);
        // foodUnits.forEach((element) {
        //   String parse2 = element.servingUnitSize.replaceAll("and", "*");
        //   String parse3 = parse2.replaceAll("half", "1/2");
        //   String parse4 = parse3.replaceAll("inches", '")');
        //   String parse5 = parse4.replaceAll("one", '1');
        //   String parse6 = parse5.replaceAll("two", '2');
        //   String parse7 = parse6.replaceAll("three", '3');
        //   String parse8 = parse7.replaceAll("four", '4');
        //   String parse9 = parse8.replaceAll("five", '5');
        //   String parse10 = parse9.replaceAll("six", '6');
        //   String parse11 = parse10.replaceAll("seven", '7');
        //   String parse12 = parse11.replaceAll("eight", '8');
        //   String parse13 = parse12.replaceAll("nine", '9');
        //   String parse14 = parse13.replaceAll("zero", '0');
        //   String parse15 = parse14.replaceAll("to", '-');
        //   String parse16 = parse15.replaceAll("Small ", "Small (");
        //   String parse17 = parse16.replaceAll("Medium ", "Medium (");
        //   String parse18 = parse17.replaceAll("Large ", "Large (");
        //   String parse19 = parse18.replaceAll("by", "/");
        //   element.servingUnitSize = parse19;
        // });
        return foodUnits;
      } else {
        print('Response.statusCode is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<List<GetBookMarkedFood>> bookmarkedFoodDetailsApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final http.Response response = await _client.get(
        Uri.parse('${API.iHLUrl}/foodjournal/retrive_bookmark_food_item_id?ihl_user_id=$iHLUserId'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      );
      if (response.statusCode == 200) {
        final List<GetBookMarkedFood> listUserFood = getBookMarkedFoodFromJson(response.body);
        return listUserFood;
      } else {
        print('Response.statusCode is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<List<ListCustomRecipe>> customFoodDetailsApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final http.Response response = await _client.get(
        Uri.parse('${API.iHLUrl}/foodjournal/view_user_recipe?ihl_user_id=$iHLUserId'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      );
      if (response.statusCode == 200) {
        String _s = response.body
            .replaceAll('&quot;', '"')
            // .replaceAll('"[', "[")
            // .replaceAll(']"', "]")
            .replaceAll('"[{', '[{')
            .replaceAll('}]"', '}]')
            .replaceAll(';""', '"')
            .replaceAll('"W/"d', '"W/d');
        List<dynamic> s = jsonDecode(_s);
        //log(s);
        final List<ListCustomRecipe> listUserFood =
            s.map((e) => ListCustomRecipe.fromJson(e)).toList();
        // listCustomRecipeFromJson(jsonDecode(response.body.replaceAll('&quot;', '"')));
        return listUserFood;
      } else {
        print('Response.statusCode is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //15 todays user log
  // Future<List<GetFoodLog>>
  // Future<List<MealsListData>>
  Future<dynamic> getUserTodaysFoodLogHistoryApi({graph}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final http.Response response = await _client.post(
        Uri.parse(
          '${API.iHLUrl}/consult/get_today_log',
        ),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, String>{
          "user_ihl_id": iHLUserId, //"lw8nEpxp2EqqUngGCYXZog"
        }),
      );

      String finalOutput;
      if (response.statusCode == 200) {
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
        String parsedString13 = parseString12.replaceAll("rn", "");
        String parsedString14 = parsedString13.replaceAll('")"', ')"');
        finalOutput = parsedString14.replaceAll(':",', ':"",').replaceAll(': "      }', ':""}');
        // final foodLog = getFoodLogFromJson(finalOutput);
        GetTodaySFoodLog foodLog;
        try {
          foodLog = getTodaySFoodLogFromJson(finalOutput);
        } catch (e) {
          foodLog = GetTodaySFoodLog(food: [], activity: []);
          throw Exception('Getting food detail error');
        }
        final List<DailyCalorieData> dailyChartData = [];
        if (graph == true) {
          // foodLog.food[i].totalCaloriesGained
          for (int i = 0; i < foodLog.food.length; i++) {
            if (DateTime.now().subtract(Duration(days: 0)).toString().substring(5, 7) ==
                foodLog.food[i].logTime.substring(3, 5)) {
              if (DateTime.now().subtract(Duration(days: 0)).toString().substring(8, 10) ==
                  foodLog.food[i].logTime.substring(0, 2)) {
                DateTime now = DateTime.fromMillisecondsSinceEpoch(foodLog.food[i].epochLogTime);

                dailyChartData.add(
                  DailyCalorieData(
                    now,
                    int.parse(foodLog.food[i].totalCaloriesGained),
                  ),
                );
              }
            }
          }
          return dailyChartData;
        }
        List<Activity> todayActivityList = [];
        List<Activity> otherActivityList = [];
        List<MealsListData> fooditemNames = [];
        List<FoodListTileModel> bfastFoodlist = [];
        List<FoodListTileModel> lunchFoodlist = [];
        List<FoodListTileModel> snacksFoodlist = [];
        List<FoodListTileModel> dinnerFoodlist = [];
        int break_kcal = 0;
        List<String> break_meals = [];
        //lunch
        int lunch_kcal = 0;
        List<String> lunch_meals = [];
        //snacks
        int snack_kcal = 0;
        List<String> snack_meals = [];
        //dinner
        int dinner_kcal = 0;
        List<String> dinner_meals = [];
        for (int i = 0; i < foodLog.food.length; i++) {
          String current_time =
              DateTime.now().subtract(Duration(days: 0)).toString().substring(5, 7);
          String food_log_time = foodLog.food[i].logTime.substring(3, 5);
          String current_date_time =
              DateTime.now().subtract(Duration(days: 0)).toString().substring(8, 10);
          String food_log_time_two = foodLog.food[i].logTime.substring(0, 2);
          if (current_time == food_log_time) {
            if (current_date_time == food_log_time_two) {
              if (foodLog.food[i].mealDetails.isNotEmpty) {
                if (foodLog.food[i].mealCategory == 'breakfast' ||
                    foodLog.food[i].mealCategory == 'Breakfast') {
                  try {
                    break_kcal = break_kcal + int.tryParse(foodLog.food[i].totalCaloriesGained);
                  } catch (e) {
                    break_kcal =
                        break_kcal + double.tryParse(foodLog.food[i].totalCaloriesGained).toInt();
                  }
                  for (int i1 = 0; i1 < foodLog.food[i].mealDetails[0].foodDetails.length; i1++) {
                    break_meals
                        .add(camelize(foodLog.food[i].mealDetails[0].foodDetails[i1].foodName));
                    bfastFoodlist.add(
                      FoodListTileModel(
                          foodItemID:
                              foodLog.food[i].mealDetails[0].foodDetails[i1].foodId.toString(),
                          foodTime: foodLog.food[i].logTime,
                          foodLogId: foodLog.food[i].foodLogId,
                          epochTime: foodLog.food[i].epochLogTime,
                          quantity: foodLog.food[i].mealDetails[0].foodDetails[i1].foodQuantity,
                          quantityUnit:
                              camelize(foodLog.food[i].mealDetails[0].foodDetails[i1].quantityUnit),
                          title: camelize(foodLog.food[i].mealDetails[0].foodDetails[i1].foodName),
                          subtitle: camelize(
                            '${foodLog.food[i].mealDetails[0].foodDetails[i1].foodQuantity} ${foodLog.food[i].mealDetails[0].foodDetails[i1].quantityUnit.replaceAll(RegExp(r"\d"), "Nos.")}',
                          ),
                          extras: foodLog.food[i].totalCaloriesGained ?? " "),
                    );
                  }
                }
                if (foodLog.food[i].mealCategory == 'lunch' ||
                    foodLog.food[i].mealCategory == 'Lunch') {
                  try {
                    lunch_kcal = lunch_kcal + int.tryParse(foodLog.food[i].totalCaloriesGained);
                  } catch (e) {
                    lunch_kcal =
                        lunch_kcal + double.tryParse(foodLog.food[i].totalCaloriesGained).toInt();
                  }
                  for (int i1 = 0; i1 < foodLog.food[i].mealDetails[0].foodDetails.length; i1++) {
                    lunch_meals
                        .add(camelize(foodLog.food[i].mealDetails[0].foodDetails[i1].foodName));
                    lunchFoodlist.add(FoodListTileModel(
                        foodItemID:
                            foodLog.food[i].mealDetails[0].foodDetails[i1].foodId.toString(),
                        foodTime: foodLog.food[i].logTime,
                        foodLogId: foodLog.food[i].foodLogId,
                        epochTime: foodLog.food[i].epochLogTime,
                        quantity: foodLog.food[i].mealDetails[0].foodDetails[i1].foodQuantity,
                        quantityUnit:
                            camelize(foodLog.food[i].mealDetails[0].foodDetails[i1].quantityUnit),
                        title: camelize(foodLog.food[i].mealDetails[0].foodDetails[i1].foodName),
                        subtitle: camelize(
                            '${foodLog.food[i].mealDetails[0].foodDetails[i1].foodQuantity} ${foodLog.food[i].mealDetails[0].foodDetails[i1].quantityUnit}'),
                        extras: foodLog.food[i].totalCaloriesGained ?? " "));
                  }
                }
                if (foodLog.food[i].mealCategory == 'snacks' ||
                    foodLog.food[i].mealCategory == 'Snacks') {
                  try {
                    snack_kcal = snack_kcal + int.tryParse(foodLog.food[i].totalCaloriesGained);
                  } catch (e) {
                    snack_kcal =
                        snack_kcal + double.tryParse(foodLog.food[i].totalCaloriesGained).toInt();
                  }
                  for (int i1 = 0; i1 < foodLog.food[i].mealDetails[0].foodDetails.length; i1++) {
                    snack_meals
                        .add(camelize(foodLog.food[i].mealDetails[0].foodDetails[i1].foodName));
                    snacksFoodlist.add(FoodListTileModel(
                        foodItemID:
                            foodLog.food[i].mealDetails[0].foodDetails[i1].foodId.toString(),
                        foodTime: foodLog.food[i].logTime,
                        foodLogId: foodLog.food[i].foodLogId,
                        epochTime: foodLog.food[i].epochLogTime,
                        quantity: foodLog.food[i].mealDetails[0].foodDetails[i1].foodQuantity,
                        quantityUnit:
                            camelize(foodLog.food[i].mealDetails[0].foodDetails[i1].quantityUnit),
                        title: camelize(foodLog.food[i].mealDetails[0].foodDetails[i1].foodName),
                        subtitle: camelize(
                            '${foodLog.food[i].mealDetails[0].foodDetails[i1].foodQuantity} ${foodLog.food[i].mealDetails[0].foodDetails[i1].quantityUnit}'),
                        extras: foodLog.food[i].totalCaloriesGained ?? " "));
                  }
                }
                if (foodLog.food[i].mealCategory == 'dinner' ||
                    foodLog.food[i].mealCategory == 'Dinner') {
                  try {
                    dinner_kcal = dinner_kcal + int.tryParse(foodLog.food[i].totalCaloriesGained);
                  } catch (e) {
                    dinner_kcal =
                        dinner_kcal + double.tryParse(foodLog.food[i].totalCaloriesGained).toInt();
                  }
                  for (int i1 = 0; i1 < foodLog.food[i].mealDetails[0].foodDetails.length; i1++) {
                    dinner_meals
                        .add(camelize(foodLog.food[i].mealDetails[0].foodDetails[i1].foodName));
                    dinnerFoodlist.add(FoodListTileModel(
                        foodItemID:
                            foodLog.food[i].mealDetails[0].foodDetails[i1].foodId.toString(),
                        foodTime: foodLog.food[i].logTime,
                        foodLogId: foodLog.food[i].foodLogId,
                        epochTime: foodLog.food[i].epochLogTime,
                        quantity: foodLog.food[i].mealDetails[0].foodDetails[i1].foodQuantity,
                        quantityUnit:
                            camelize(foodLog.food[i].mealDetails[0].foodDetails[i1].quantityUnit),
                        title: camelize(foodLog.food[i].mealDetails[0].foodDetails[i1].foodName),
                        subtitle: camelize(
                            '${foodLog.food[i].mealDetails[0].foodDetails[i1].foodQuantity} ${foodLog.food[i].mealDetails[0].foodDetails[i1].quantityUnit}'),
                        extras: foodLog.food[i].totalCaloriesGained ?? " "));
                  }
                }
              }
            }
          }
        }
//breakfast
        if (break_kcal != 0) {
          fooditemNames.add(
            MealsListData(
              imagePath: 'assets/images/diet/breakfast.png',
              type: 'Breakfast',
              kcal: break_kcal,
              meals: break_meals,
              //<String>['Bread,', 'Peanut butter,', 'Apple'],
              foodList: bfastFoodlist,
              startColor: '#ed3f18',
              endColor: '#f57f64',
            ),
          );
        } else {
          fooditemNames.add(
            MealsListData(
              imagePath: 'assets/images/diet/breakfast.png',
              type: 'Breakfast',
              kcal: 0,
              meals: <String>['Log your', 'meal'],
              foodList: [],
              startColor: '#ed3f18',
              endColor: '#f57f64',
              // startColor: '#FA7D82',
              // endColor: '#FFB295',
            ),
          );
        }

        if (lunch_kcal != 0) {
          fooditemNames.add(
            MealsListData(
              imagePath: 'assets/images/diet/lunch.png',
              type: 'Lunch',
              kcal: lunch_kcal,
              meals: lunch_meals,
              //<String>['Bread,', 'Peanut butter,', 'Apple'],
              foodList: lunchFoodlist,
              startColor: '#23b6e6',
              // endColor: '#02d39a',
              endColor: '#40E0D0',
            ),
          );
        } else {
          fooditemNames.add(
            MealsListData(
              imagePath: 'assets/images/diet/lunch.png',
              type: 'Lunch',
              kcal: 0,
              meals: <String>['Log your', 'meal'],
              foodList: [],
              startColor: '#23b6e6',
              // endColor: '#02d39a',
              endColor: '#40E0D0',
            ),
          );
        }

        //snack
        if (snack_kcal != 0) {
          fooditemNames.add(
            MealsListData(
              imagePath: 'assets/images/diet/snack.png',
              type: 'Snacks',
              kcal: snack_kcal,
              meals: snack_meals,
              //<String>['Bread,', 'Peanut butter,', 'Apple'],
              foodList: snacksFoodlist,
              startColor: '#FE95B6',
              endColor: '#FF5287',
            ),
          );
        } else {
          fooditemNames.add(
            MealsListData(
              imagePath: 'assets/images/diet/snack.png',
              type: 'Snacks',
              kcal: 0,
              meals: <String>['Log your', 'meal'],
              foodList: [],
              startColor: '#FE95B6',
              endColor: '#FF5287',
            ),
          );
        }
//dinner
        if (dinner_kcal != 0) {
          fooditemNames.add(
            MealsListData(
              imagePath: 'assets/images/diet/dinner.png',
              type: 'Dinner',
              kcal: dinner_kcal,
              meals: dinner_meals,
              //<String>['Bread,', 'Peanut butter,', 'Apple'],
              foodList: dinnerFoodlist,
              startColor: '#6F72CA',
              endColor: '#1E1466',
            ),
          );
        } else {
          fooditemNames.add(
            MealsListData(
              imagePath: 'assets/images/diet/dinner.png',
              type: 'Dinner',
              kcal: 0,
              meals: <String>['Log your', 'meal'],
              foodList: [],
              startColor: '#6F72CA',
              endColor: '#1E1466',
            ),
          );
        }
        List<Activity> activityList = foodLog.activity;
        for (int i = 0; i < activityList.length; i++) {
          if (activityList[i].activityDetails.isNotEmpty) {
            if (DateTime.now().subtract(Duration(days: 0)).toString().substring(5, 7) ==
                activityList[i].logTime.substring(3, 5)) {
              if (DateTime.now().subtract(Duration(days: 0)).toString().substring(8, 10) ==
                  activityList[i].logTime.substring(0, 2)) {
                todayActivityList.add(activityList[i]);
              } else {
                otherActivityList.add(activityList[i]);
              }
            } else {
              otherActivityList.add(activityList[i]);
            }
          }
        }
        updateCalories(fooditemNames, todayActivityList);

        Map<String, List<Object>> todaysHistoryMap = {
          'food': fooditemNames,
          'activity': todayActivityList,
          'previous_activity': otherActivityList
        };
        return todaysHistoryMap;
      } else {
        print('response.statusCode is not 200 , it is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future getFoodGroupScreenApi({String ihlUserId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final http.Response response = await _client.get(
        Uri.parse(
          '${API.iHLUrl}/foodjournal/list_user_log_group?user_id=$iHLUserId',
        ),
        // headers: {
        //   'Content-Type': 'application/json',
        //   'ApiToken': '${API.headerr['ApiToken']}',
        //   'Token': '${API.headerr['Token']}',
        // },
        // body: jsonEncode(<String, String>{
        //   "user_ihl_id": iHLUserId, //"lw8nEpxp2EqqUngGCYXZog"
        // }),
      );

      String finalOutput;
      if (response.statusCode == 200) {
        Map<String, dynamic> resultMap = convertStringToMap(response.body);
        List<dynamic> resultList = resultMap['status'];
        return resultList;
      } else {
        print('response.statusCode is not 200 , it is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Map<String, dynamic> convertStringToMap(String input) {
    try {
      // Use json.decode to parse the string into a map
      Map<String, dynamic> resultMap = json.decode(input);
      return resultMap;
    } catch (e) {
      // Handle any parsing errors, e.g., if the input is not a valid JSON string
      print("Error converting string to map: $e");
      return {};
    }
  }

  void updateCalories(List<MealsListData> foodList, List<Activity> activityList) async {
    final StreamingSharedPreferences preferences = await StreamingSharedPreferences.instance;
    int foodKcal = 0;
    double activityKcal = 0.0;
    for (int i = 0; i < foodList.length; i++) {
      if (foodList[i].kcal != 0) {
        foodKcal = foodKcal + foodList[i].kcal;
      }
    }
    for (int i = 0; i < activityList.length; i++) {
      if (activityList[i].totalCaloriesBurned != '0' &&
          activityList[i].totalCaloriesBurned != null) {
        activityKcal =
            // activityKcal + int.parse(activityList[i].totalCaloriesBurned);
            activityKcal + double.parse(activityList[i].totalCaloriesBurned);
      }
    }
    preferences.setInt('burnedCalorie', activityKcal.toInt());
    preferences.setInt('eatenCalorie', foodKcal);
  }

  static Future<dynamic> getUserTodaysFoodLogApi(String mealType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    String todayStartTime =
        '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} 00:00:00';
    String todayEndTime =
        '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} 23:59:59';
    http.Client _client = http.Client(); //3gb

    try {
      final http.Response response = await _client.post(
        Uri.parse(
          '${API.iHLUrl}/foodjournal/get_food_log',
        ),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, String>{
          "user_ihl_id": iHLUserId,
          "from": todayStartTime, //"lw8nEpxp2EqqUngGCYXZog"
          "to": todayEndTime
        }),
      );
      String finalOutput;
      if (response.statusCode == 200) {
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
        String parsedString13 = parseString12.replaceAll("rn", "");
        finalOutput = parsedString13.replaceAll(':",', ':"",').replaceAll(': "      }', ':""}');
        final List<TodayFoodLog> foodLog = todayFoodLogFromJson(finalOutput);
        MealsListData fooditemNames;
        List<FoodListTileModel> mealFoodlist = [];
        int meal_kcal = 0;
        List<String> meals = [];
        for (int i = 0; i < foodLog.length; i++) {
          if (foodLog[i].foodTimeCategory == mealType ||
              foodLog[i].foodTimeCategory == mealType.toLowerCase()) {
            meal_kcal = meal_kcal + int.tryParse(foodLog[i].totalCaloriesGained);
            if (foodLog[i].food.isNotEmpty) {
              for (int i1 = 0; i1 < foodLog[i].food[0].foodDetails.length; i1++) {
                meals.add(camelize(foodLog[i].food[0].foodDetails[i1].foodName));
                mealFoodlist.add(FoodListTileModel(
                    foodItemID: foodLog[i].food[0].foodDetails[i1].foodId.toString(),
                    foodTime: foodLog[i].foodLogTime,
                    foodLogId: foodLog[i].foodLogId,
                    epochTime: foodLog[i].epochLogTime,
                    quantity: foodLog[i].food[0].foodDetails[i1].foodQuantity,
                    quantityUnit:
                        camelize(foodLog[i].food[0].foodDetails[i1].quantityUnit ?? 'Nos'),
                    title: camelize(foodLog[i].food[0].foodDetails[i1].foodName),
                    subtitle: camelize(
                        '${foodLog[i].food[0].foodDetails[i1].foodQuantity} ${foodLog[i].food[0].foodDetails[i1].quantityUnit}')));
              }
            }
          }
        }
//breakfast
        if (meal_kcal != 0) {
          fooditemNames = MealsListData(
            imagePath: mealType == 'Breakfast' || mealType == 'breakfast'
                ? 'assets/images/diet/breakfast.png'
                : mealType == 'Lunch' || mealType == 'lunch'
                    ? 'assets/images/diet/lunch.png'
                    : mealType == 'Snacks' || mealType == 'snacks'
                        ? 'assets/images/diet/snack.png'
                        : 'assets/images/diet/dinner.png',
            type: mealType,
            kcal: meal_kcal,
            meals: meals,
            foodList: mealFoodlist,
            startColor: mealType == 'Breakfast'
                ? '#ed3f18'
                : mealType == 'Lunch'
                    ? '#23b6e6'
                    : mealType == 'Snacks'
                        ? '#FE95B6'
                        : '#6F72CA',
            endColor: mealType == 'Breakfast'
                ? '#f57f64'
                : mealType == 'Lunch'
                    ? '#02d39a'
                    : mealType == 'Snacks'
                        ? '#FF5287'
                        : '#1E1466',
          );
        } else {
          fooditemNames = MealsListData(
            imagePath: mealType == 'Breakfast' || mealType == 'breakfast'
                ? 'assets/images/diet/breakfast.png'
                : mealType == 'Lunch' || mealType == 'lunch'
                    ? 'assets/images/diet/lunch.png'
                    : mealType == 'Snacks' || mealType == 'snacks'
                        ? 'assets/images/diet/snack.png'
                        : 'assets/images/diet/dinner.png',
            type: mealType,
            kcal: 0,
            meals: <String>['Log your', 'meal'],
            foodList: [],
            startColor: mealType == 'Breakfast'
                ? '#ed3f18'
                : mealType == 'Lunch'
                    ? '#23b6e6'
                    : mealType == 'Snacks'
                        ? '#FE95B6'
                        : '#6F72CA',
            endColor: mealType == 'Breakfast'
                ? '#f57f64'
                : mealType == 'Lunch'
                    ? '#02d39a'
                    : mealType == 'Snacks'
                        ? '#FF5287'
                        : '#1E1466',
          );
        }

        return fooditemNames;
      } else {
        print('response.statusCode is not 200 , it is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  static Future<GetFrequentFoodConsumed> list_user_frequent_food_log() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb

    try {
      final http.Response response = await _client.get(
        Uri.parse(
          '${API.iHLUrl}/foodjournal/list_user_frequent_food_log?user_id=$iHLUserId'
        ),
      );
      String finalOutput;
      if (response.statusCode == 200) {
        String parsedString = response.body.replaceAll('&quot', '"');
        String parsedString2 = parsedString.replaceAll("\\\\\\", "").replaceAll('&#39', '"');
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
        String parsedString13 = parseString12.replaceAll("rn", "");
        finalOutput = parsedString13.replaceAll(':",', ':"",').replaceAll(': "      }', ':""}');
        GetFrequentFoodConsumed  fooditemNames = getFrequentFoodConsumedFromJson(finalOutput);
       return fooditemNames;
      } else {
        print('response.statusCode is not 200 , it is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//Api -9 User Intake History

  // Future<List<MealsListData>>
  // Future<List<DailyCalorieData>>
  static Future<dynamic> getUserFoodLogHistoryApi({userID, fromDate, tillDate, tabType}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final http.Response response = await _client.post(
        Uri.parse(
          '${API.iHLUrl}/foodjournal/get_food_log',
        ),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, String>{
          "user_ihl_id": iHLUserId,
          "from": fromDate.toString(),
          //  "2021-08-01",
          "till": tillDate.toString(),
        }),
      );
      String finalOutput;
      if (response.statusCode == 200) {
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
        String parsedString13 = parseString12.replaceAll("rn", "");
        String parsedString14 = parsedString13.replaceAll('")', "inches)");

        finalOutput = parsedString14.replaceAll(':",', ':"",');
        final List<GetFoodLog> foodLog = getFoodLogFromJson(finalOutput);
        // final foodLog = getTodaySFoodLogFromJson(finalOutput);
        List foodLogList = [];
        int calorieDate;
        int totalCalorie = 0;
        if (tabType == null) {
          return (foodLog);
        }
        if ('weekly' == tabType) {
          List<ChartData> weeklyChartData = [];
          // [
          //   ChartData('Son', 0),
          //   ChartData('Mon', 0),
          //   ChartData('Tue', 200),
          // ];
          // return weeklyChartData;
          dynamic weekData = {
            "1": "Mon",
            "2": "Tue",
            "3": "Wed",
            "4": "Thu",
            "5": "Fri",
            "6": "Sat",
            "7": "Sun"
          };
          // var length = diffrence between start and end date;
          DateTime st = DateTime.now().subtract(Duration(days: 6));
          String start = st.toString().substring(0, 10);
          for (int i = 0; i <= 6; i++) {
            st = st.add(Duration(days: i == 0 ? 0 : 1));
            start = st.toString().substring(0, 10);
            // epochLogTime =
            //     DateTime.fromMillisecondsSinceEpoch(foodLog[i].epochLogTime);
            String cat = "";
            foodLog.forEach((GetFoodLog element) {
              // element.epochLogTime
              if (DateTime.fromMillisecondsSinceEpoch(element.epochLogTime)
                      .toString()
                      .substring(0, 10) ==
                  start) {
                totalCalorie = totalCalorie + int.tryParse(element.totalCaloriesGained ?? '0');
                cat = element.foodTimeCategory;
                // calorieDate = element.epochLogTime;
                calorieDate = DateTime.fromMillisecondsSinceEpoch(element.epochLogTime).weekday;
              } else {
                if (totalCalorie == 0) {
                  totalCalorie = 0;
                  calorieDate = st.weekday;
                  cat = "noFood";
                }
              }
            });
            if (totalCalorie != 0) {
              // foodLogList.add(
              //   FoodLogCalorieHistory(
              //       calorieConsume: totalCalorie, calorieDate: calorieDate),
              // );
              weeklyChartData.add(
                ChartData(weekData[calorieDate.toString()], totalCalorie, category: cat),
              );
            } else {
              weeklyChartData.add(
                ChartData(weekData[calorieDate.toString()], 0, category: cat),
              );
              // weeklyChartData.add(
              //   ChartData(
              //       weekData[DateTime.fromMillisecondsSinceEpoch(calorieDate)
              //           .weekday
              //           .toString()],
              //       totalCalorie),
              // );

              // foodLogList.add(
              //   FoodLogCalorieHistory(
              //       calorieConsume: totalCalorie, calorieDate: st.millisecondsSinceEpoch),
              // );
            }
            //reset the variables
            totalCalorie = 0;
            calorieDate = 0;
            // st.add(Duration(days: i));
            // start = st
            //     .toString()
            //     .substring(0, 10);
          }
          //for we daily we return the data from here only
          return weeklyChartData; //foodLogList;
        }
        if ('monthly' == tabType) {
          String _calorieDate;
          int _totalCalorie = 0;
          List<ChartData> monthlyChartData = [];
          // var length = diffrence between start and end date;
          DateTime st = DateTime.now().subtract(Duration(days: 334));
          String start = st.toString().substring(0, 10);
          int mont = st.month;
          int year = st.year;
          dynamic monthData = {
            "1": "Jan",
            "2": "Feb",
            "3": "Mar",
            "4": "Apr",
            "5": "May",
            "6": "June",
            "7": "Jul",
            "8": "Aug",
            "9": "Sep",
            "10": "Oct",
            "11": "Nov",
            "12": "Dec"
          };
          for (int i = 0; i <= 12; i++) {
            st = st.add(Duration(days: i == 0 ? 0 : 31));
            year = st.year;
            mont = st.month;
            // mont = st.year==year && st.month==mont ? mont
            start = st.toString().substring(0, 10);
            // epochLogTime =
            //     DateTime.fromMillisecondsSinceEpoch(foodLog[i].epochLogTime);
            foodLog.forEach((GetFoodLog element) {
              // element.epochLogTime
              if (DateTime.fromMillisecondsSinceEpoch(element.epochLogTime).year == year &&
                  DateTime.fromMillisecondsSinceEpoch(element.epochLogTime).month == mont) {
                _totalCalorie = _totalCalorie + int.tryParse(element.totalCaloriesGained ?? '0');
                // calorieDate = element.epochLogTime;
                _calorieDate = monthData[
                    DateTime.fromMillisecondsSinceEpoch(element.epochLogTime).month.toString()];
              } else {
                if (_totalCalorie == 0) {
                  _totalCalorie = 0;
                  _calorieDate = monthData[st.month.toString()];
                }
              }
            });
            if (_totalCalorie != 0) {
              // foodLogList.add(
              //   FoodLogCalorieHistory(
              //       calorieConsume: totalCalorie, calorieDate: calorieDate),
              // );
              monthlyChartData.add(
                ChartData(_calorieDate, _totalCalorie),
              );
            } else {
              monthlyChartData.add(
                ChartData(_calorieDate, _totalCalorie),
              );
              // foodLogList.add(
              //   FoodLogCalorieHistory(
              //       calorieConsume: totalCalorie, calorieDate: calorieDate),
              // );
              // monthlyChartData.add(
              //   DailyCalorieData( DateTime.fromMillisecondsSinceEpoch(st.millisecondsSinceEpoch),
              //       // DateTime.fromMillisecondsSinceEpoch(calorieDate),
              //       totalCalorie),
              // );
              // foodLogList.add(
              //   FoodLogCalorieHistory(
              //       calorieConsume: totalCalorie, calorieDate: st.millisecondsSinceEpoch),
              // );
            }
            //reset the variables
            _totalCalorie = 0;
            _calorieDate = '';
            // st.add(Duration(days: i));
            // start = st
            //     .toString()
            //     .substring(0, 10);
          }
          //for we daily we return the data from here only
          // return foodLogList;
          return monthlyChartData;
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

  //14. List User Activity History
  Future<List<GetActivityLog>> getUserActivityLogHistoryApi({
    fromDate,
    tillDate,
  }) async {
    http.Client _client = http.Client(); //3gb
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    try {
      final http.Response response = await _client.post(
        Uri.parse(
          '$iHLUrl/consult/get_activity_log',
        ),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, String>{
          "user_ihl_id": iHLUserId,
          "from": fromDate.toString(),
          "till": tillDate.toString()
        }),
      );
      String finalOutput;
      if (response.statusCode == 200) {
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
        String parsedString13 = parseString12.replaceAll("rn", "");
        finalOutput = parsedString13.replaceAll(':",', ':"",');
        final List<GetActivityLog> getActivityLog = getActivityLogFromJson(finalOutput);

        return getActivityLog;
      } else {
        print('response.statusCode is not 200 , it is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // 2. Retrieve User Bookmarked Activities
// https://testing.indiahealthlink.com:750/consult/get_user_activities?ihl_user_id=lw8nEpxp2EqqUngGCYXZoe
  static Future<List<BookMarkedActivity>> getBookMarkedActivity({userID}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final http.Response response = await _client.get(
        Uri.parse('${API.iHLUrl}/consult/get_user_activities?ihl_user_id=$iHLUserId'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        //lw8nEpxp2EqqUngGCYXZoe'),//$iHLUserId'),
      );
      String finalOutput;
      if (response.statusCode == 200) {
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
        final List<BookMarkedActivity> bookMarkedActivity = bookMarkedActivityFromJson(finalOutput);

        return bookMarkedActivity;
      } else {
        print('response.statusCode is not 200 , it is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Group meal api call
  static Future<CreateFoodGroupMealModel> createFoodGroupMeal(
      {String group_name,
        String meal_category,
      String foodFoodIdList,
      String foodNamelist,
      String foodQuantityList,
      String foodServingUnitList,
      String foodTotalCaloriesList,
      int total_calorie_count}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final http.Response response =
          await _client.post(Uri.parse('${API.iHLUrl}/foodjournal/create_food_log_group'),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              },
              body: jsonEncode(<String, dynamic>{
                "group_name": group_name,
                // mandatory
                "user_id": iHLUserId,
                // mandatory
                "list_of_food_logs":
                    "{'foodId': [$foodFoodIdList],'foodName': [$foodNamelist],'foodQuantity':[$foodQuantityList], 'quantityUnit':[$foodServingUnitList],'Calories':[$foodTotalCaloriesList],'mealCategory':'$meal_category'}",
                // mandatory
                "total_calorie_count": total_calorie_count.toString()
                // mandatory
              }
                  //lw8nEpxp2EqqUngGCYXZoe'),//$iHLUserId'),
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

  static Future<DeleteFoodGroupMealModel> deleteFoodGroupMeal({String group_id}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final http.Response response = await _client.get(
        Uri.parse('${API.iHLUrl}/foodjournal/delete_food_log_group?food_log_group_id=$group_id'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        // body: jsonEncode(<String, dynamic>{
        //   "food_log_group_id": group_id.toString(),
        // }
        //lw8nEpxp2EqqUngGCYXZoe'),//$iHLUserId'),
      );
      String finalOutput;
      if (response.statusCode == 200) {
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
      } else {
        print('response.statusCode is not 200 , it is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Get activity list
  static Future<List<BookMarkedActivity>> getActivityList({userID}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client(); //3gb
    try {
      final http.Response response = await _client.get(
        Uri.parse('${API.iHLUrl}/consult/get_activities?ihl_user_id=$iHLUserId'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        //lw8nEpxp2EqqUngGCYXZoe'),
      );
      String finalOutput;
      if (response.statusCode == 200) {
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
        final List<BookMarkedActivity> bookMarkedActivity = bookMarkedActivityFromJson(finalOutput);

        return bookMarkedActivity;
      } else {
        print('response.statusCode is not 200 , it is =>${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//13. Get Activity Input
// Future<ViewIngredientDetail> getActivityInputApi({activityId}) async {
//   try {
//     final response = await http.get(
//       Uri.parse(iHLUrl + 'consult/get_activity_input?activity_id=$activityId'),
//     );
//     var finalOutput;
//     if (response.statusCode == 200) {
//       //parse According Data
//       //Remaining Parse
//       var parsedString = response.body.replaceAll('&quot', '"');
//       var parsedString2 = parsedString.replaceAll("\\\\\\", "");
//       var parsedString3 = parsedString2.replaceAll("\\", "");
//       var parsedString4 = parsedString3.replaceAll(";", "");
//       var parsedString5 = parsedString4.replaceAll('""', '"');
//       var parsedString6 = parsedString5.replaceAll('"[', '[');
//       var parsedString7 = parsedString6.replaceAll(']"', ']');
//       var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
//       var pasrseString9 = pasrseString8.replaceAll('"{', '{');
//       var parseString10 = pasrseString9.replaceAll('}"', '}');
//       var parseString11 = parseString10.replaceAll('System.String[]', '');
//       var parseString12 = parseString11.replaceAll('/"', '/');
//       finalOutput = parseString12.replaceAll(':",', ':"",');
//       final viewIngredientDetail = viewIngredientDetailFromJson(finalOutput);

//       return viewIngredientDetail;
//     } else {
//       print('response.statusCode is not 200 , it is =>' +
//           response.statusCode.toString());
//       return null;
//     }
//   } catch (e) {
//     print(e.toString());
//     return null;
//   }
// }
}

class MealsListData {
  MealsListData({
    this.imagePath = '',
    this.type = '',
    this.startColor = '',
    this.endColor = '',
    this.meals,
    this.foodList,
    this.kcal = 0,
  });

  String imagePath;
  String type;
  String startColor;
  String endColor;
  List<String> meals;
  List<FoodListTileModel> foodList;
  int kcal;
}

class FoodLogCalorieHistory {
  FoodLogCalorieHistory({
    this.calorieConsume = 0,
    this.calorieDate = 0,
  });

  int calorieConsume;
  int calorieDate;
}
//  var foodLogList ;
// ListApis  listApis = ListApis();
// // Future<List<GetFoodLog>>
//  void getData() async {
//   // await Future<dynamic>.delayed(const Duration(milliseconds: 50));
//   // return true;
//      foodLogList =  await listApis.getUserFoodLogHistoryApi();
//    setState(() {
//    foodLogList;
//    });
//    await print(foodLogList.toString());
//   //  await print("===>>>>>"+foodLogList[0].mealCategory.toString());
//   // //  await print(foodLogList[0].mealCategory.toString());
//   //  await print(foodLogList[0].food[0].foodDetails[0].foodName);
//   //  await print(foodLogList[0].food[0].foodDetails[1].foodName);

// }
