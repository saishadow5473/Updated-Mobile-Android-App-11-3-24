import 'package:dio/dio.dart';
import 'package:ihl/utils/SpUtil.dart';

import '../../../../app/utils/localStorageKeys.dart';
import '../api_end_points.dart';
import '../api_provider.dart';
import '../networks.dart';

class GetAffiliationDetails {
  // var apiToken = localSotrage.read(LSKeys.apiToken);
  var apiToken = SpUtil.getString(LSKeys.apiToken);
  // var ihlUserToken = localSotrage.read(LSKeys.iHLUserToken);
  var ihlUserToken = SpUtil.getString(LSKeys.iHLUserToken);
  Future affiliationDetailsGetter() async {
    try {
      final response = await dio.get(
        API.iHLUrl + ApiEndPoints.getListOfAfiliation,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': apiToken,
            'Token': ihlUserToken
          },
        ),
      );
      return response.data;
    } on DioError catch (error) {
      throw NetworkCallsCardio.checkAndThrowError(error.type);
    }
  }
}
