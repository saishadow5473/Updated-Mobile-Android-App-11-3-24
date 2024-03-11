import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../data/model/healthTipModel/healthTipModel.dart';
import '../../../data/providers/network/apis/healthTipsApi/healthTipsData.dart';
import '../../Widgets/dashboardWidgets/affiliation_widgets.dart';

class HealthTipsController extends GetxController {
  void onInit() {
    super.onInit();
    getHealthTips();
  }

  var healthTipsData = HealthTipsData();
  List<HealthTipsModel> healthTips;
  getHealthTips() async {
    healthTips = await healthTipsData.healthTipsData(
        affiUnqiueName:
            UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"]);
    update();
    return healthTips;
  }
}
