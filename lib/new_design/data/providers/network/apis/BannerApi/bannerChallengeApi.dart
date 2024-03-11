import 'package:dio/dio.dart';
import 'package:ihl/constants/api.dart';

import '../../../../model/Banner/BannerChallengeModel.dart';
import '../../../../model/Banner/BannerInputModel.dart';

class BannerChallengeApi {
  Future<BannerChallenge> gettingBannerChallenges(BannerInputModel bannerInputModel) async {
    Dio _dio = Dio();
    try {
      var _res = await _dio.post(API.iHLUrl + '/healthchallenge/v2/list_of_challenges_has_banner',
          data: bannerInputModel.toJson());

      return BannerChallenge.fromJson(_res.data);
    } catch (e) {
      print(e);
    }
  }
}
