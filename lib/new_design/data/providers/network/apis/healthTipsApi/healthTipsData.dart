import 'package:ihl/new_design/data/model/healthTipModel/healthTipModel.dart';
import 'package:ihl/new_design/data/providers/network/apis/healthTipsApi/healthTipsApi.dart';
import 'package:intl/intl.dart';

import '../../../../../presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';

class HealthTipsData {
  Future<List<HealthTipsModel>> healthTipsData({String affiUnqiueName}) async {
    var response;
    // if (selectedAffiliationfromuniquenameDashboard == "") {
    //   response = await HealthTipsApi().healthTipsApi();
    // } else {
    //   response = await HealthTipsApi()
    //       .healthTipsAffiApi(affiUnqiueName: selectedAffiliationfromuniquenameDashboard);
    // }

    response = await HealthTipsApi().healthTipsAffiApi(
        affiUnqiueName: selectedAffiliationfromuniquenameDashboard == "" ||
                selectedAffiliationfromuniquenameDashboard == null
            ? "global_services"
            : selectedAffiliationfromuniquenameDashboard);
    // List mapdata = jsonDecode(response.toString());
    // List<HealthTipsModel> healthTipsList =
    //     response.map((e) => HealthTipsModel.fromJson(e)).toList();
    List<HealthTipsModel> healthTipsList = [];
    for (var element in response) {
      healthTipsList.add(HealthTipsModel.fromJson(element));
    }
    healthTipsList.sort((a, b) {
      DateTime dateTimeA = DateFormat('yyyy-MM-dd hh:mm:ss').parse(a.healthTipLog);
      DateTime dateTimeB = DateFormat('yyyy-MM-dd hh:mm:ss').parse(b.healthTipLog);
      return dateTimeB.compareTo(dateTimeA);
    });
    return healthTipsList;
  }
}
