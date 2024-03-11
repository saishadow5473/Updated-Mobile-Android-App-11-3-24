import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../constants/api.dart';
import '../../../../data/providers/network/networks.dart';

class OtpHandle {
  var otp;
  Future<String> generateOtp(number) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final dynamic response = await dio.get("${API.iHLUrl}/login/send_registration_otp_verify",
        queryParameters: {'mobile': number, 'from': 'mobile'});
    if (response.statusCode == 200) {
      if (response.data != null || response.data != "[]") {
        prefs.setString('OtpProfile', response.data["OTP"].toString());
        print(response.data["OTP"].toString());
        // return otp;
      }
    }

    return response.data["OTP"].toString();
  }

  validateOtp(String otpUserEntered) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (otpUserEntered == prefs.getString('OtpProfile')) {
      return true;
    } else {
      return false;
    }
  }
}
