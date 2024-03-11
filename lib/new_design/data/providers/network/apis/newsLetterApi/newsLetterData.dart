import 'package:ihl/new_design/data/model/newsLetterModel/newsLetterModel.dart';

import 'newsLetterApi.dart';

class NewsLetterData {
  Future<List<NewsLetterModel>> newsLetterData() async {
    var response = await NewsLetterApi.newsLetterApi();

    // List mapdata = jsonDecode(response.toString());
    // List<HealthTipsModel> healthTipsList =
    //     response.map((e) => HealthTipsModel.fromJson(e)).toList();
    List<NewsLetterModel> newsLetterList = [];
    for (var element in response) {
      print(element);
      newsLetterList.add(NewsLetterModel.fromJson(element));
    }
    return newsLetterList;
  }
}
