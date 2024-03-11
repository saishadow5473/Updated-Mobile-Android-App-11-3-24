import 'package:dio/dio.dart';
import 'package:ihl/new_design/data/providers/network/networks.dart';
import 'package:ihl/utils/SpUtil.dart';

import '../../../app/utils/localStorageKeys.dart';
import 'api_provider.dart';

class GenerateToken {
  final ihlToken = API.ihlToken;

  Future GetApiToken() async {
    try {
      final response = await dio.get('${API.iHLUrl}/login/kioskLogin?id=2936',
          options: Options(
            headers: {'ApiToken': ihlToken},
          ));
      if (response.statusCode == 200) {
        print(response.data);
        //Login student = Login.fromJson(json.decode(response.data));

        // localSotrage.write(LSKeys.apiToken, response.data["ApiKey"]);
        SpUtil.putString(LSKeys.apiToken, response.data["ApiKey"]);

        // Get.put(MyVitalsController());
        // Get.put(UpcomingDetailsController());
        // Get.put(TodayLogController());
        return response.data["ApiKey"];
      } else {
        print("Error while Getting API Token");
        return null;
      }
    } catch (e) {
      return e;
    }
  }

  // Future GetCSRFToken() async {
  //   try {
  //     var csrfTokenRes = await Dio().get(API.iHLUrl + '/login/getCToken',
  //         options: Options(headers: {'ApiToken': localSotrage.read(LSKeys.apiToken)}));
  //     var csrfToken = csrfTokenRes.data['token'];
  //     return csrfToken;
  //   } catch (e) {
  //     return e;
  //   }
  // }
}
