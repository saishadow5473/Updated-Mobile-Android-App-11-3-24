import 'package:connectivity_plus/connectivity_plus.dart';

/// Future<bool> returns true if user is connected to internet 🚀🚀
Future<bool> checkInternet() async {
  try {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print(e);
    return false;
  }
}
