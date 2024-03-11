import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../data/providers/network/tokenGenration.dart';

class GetTokenController extends GetxController {
  void onInit() {
    GenerateToken().GetApiToken();
    print('Api Token Init');
    // TODO: implement onInit
    super.onInit();
  }
}
