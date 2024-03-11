import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../../constants/api.dart';
import '../../../../presentation/pages/manageHealthscreens/healthJournalScreens/ingredientDetailedScreen.dart';
import '../../../model/healthJournalModel/healthJournalgraph.dart';

class FoodLogNetWorkApis {
  final Dio dio = Dio();

  Future getGraphFoodLogList({HealthJournalGraphToJson healthJournalGraphToJson}) async {
    // dio.options.receiveTimeout = 10000;

    try {
      var response = await dio.post(
        API.iHLUrl + '/foodjournal/health_food_log_record',
        data: healthJournalGraphToJson.toJson(),
      );
      return response.data;
    } on DioError catch (error) {
      print(error);
      throw checkAndThrowError(error.type);
    }
  }

  Future<List<IngredientSizeModel>> ingredientSizes({String ingredientId}) async {
    try {
      var response = await dio
          .get(API.iHLUrl + '/foodjournal/get_different_sizes_of_ingredient?item=$ingredientId');
      List data = response.data;
      return data.map((e) => IngredientSizeModel.fromJson(e)).toList();
    } on DioError catch (error) {
      print(error);
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
