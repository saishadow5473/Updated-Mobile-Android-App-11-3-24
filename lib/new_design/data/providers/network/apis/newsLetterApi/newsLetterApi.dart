import 'package:dio/dio.dart';
import 'package:ihl/new_design/data/providers/network/networks.dart';
import 'package:ihl/views/screens.dart';

import '../../../../../../utils/SpUtil.dart';
import '../../../../../app/utils/localStorageKeys.dart';

class NewsLetterApi {
  static Future newsLetterApi() async {
    // var apiToken = localSotrage.read(LSKeys.apiToken);
    var apiToken = SpUtil.getString(LSKeys.apiToken);
    //var ihlUserToken = localSotrage.read(LSKeys.iHLUserToken);
    var ihlUserToken = SpUtil.getString(LSKeys.iHLUserToken);
    try {
      final response = await dio.get(
        '${iHLUrl}/pushnotification/retrieve_newsletter_detail',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // 'ApiToken': apiToken,
            // 'Token': ihlUserToken
          },
        ),
      );
      return response.data;
    } on DioError catch (error) {
      throw NetworkCallsCardio.checkAndThrowError(error.type);
    }
  }
}
