import 'package:flutter/material.dart';
import 'package:ihl/new_design/data/model/healthJournalModel/healthJournalgraph.dart';

import '../../../data/providers/network/healthjournal/foodlogapi.dart';

class GraphApi {
  Future<List<HealthJournalGraphModel>> getLoggedFoodList(
      {@required HealthJournalGraphToJson healthJournalGraphToJson}) async {
    var response = await FoodLogNetWorkApis()
        .getGraphFoodLogList(healthJournalGraphToJson: healthJournalGraphToJson);
    List _list = response['status'];
    return _list.map((e) => HealthJournalGraphModel.fromJson(e)).toList();
  }
}
