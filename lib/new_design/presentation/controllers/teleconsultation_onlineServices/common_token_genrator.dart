import 'package:dio/dio.dart';

import '../../../../repositories/api_repository.dart';
import '../../../data/providers/network/api_provider.dart';

class CommonTokens {
  static String ihlToken = Apirepository().ihlToken;
  static getApiToken() async {
    String apiToken;
    final Response<dynamic> authResponse = await Dio().get('${API.iHLUrl}/login/kioskLogin',
        queryParameters: <String, String>{"id": "2936"},
        options: Options(
          headers: <String, String>{'ApiToken': ihlToken},
        ));
    if (authResponse.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(authResponse.data);
      apiToken = reponseToken.apiToken;
      API.headerr['ApiToken'] = apiToken;
      API.headerr['Token'] = ihlToken;
      return apiToken;
    }
    return apiToken ??
        '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
  }
}

class Signup {
  String apiToken, id;
  Signup({this.apiToken, this.id});

  List<String> get props => <String>[apiToken, id];

  static Signup fromJson(dynamic json) {
    return Signup(apiToken: json['ApiKey'], id: json['id']);
  }

  @override
  String toString() => 'Signup { ApiToken: $apiToken, id: $id';
}
