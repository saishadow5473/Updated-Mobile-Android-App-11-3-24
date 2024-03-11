import 'package:get/get.dart';

import '../../../data/model/newsLetterModel/newsLetterModel.dart';
import '../../../data/providers/network/apis/newsLetterApi/newsLetterData.dart';

class NewsLetterController extends GetxController {
  void onInit() {
    getNewsLetters();
    super.onInit();
  }

  var newsLettersData = NewsLetterData();
  List<NewsLetterModel> newsLetters;
  getNewsLetters() async {
    newsLetters = await newsLettersData.newsLetterData();
    update();
    return newsLetters;
  }
}
