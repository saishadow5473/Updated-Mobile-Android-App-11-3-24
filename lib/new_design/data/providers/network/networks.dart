import 'dart:developer';

import 'package:dio/dio.dart';

final Dio dio = Dio();

class NetworkCallsCardio {
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
