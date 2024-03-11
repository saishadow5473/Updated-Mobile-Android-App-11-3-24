import 'package:get/get.dart';
import 'package:ihl/views/dietJournal/models/food_list_tab_model.dart';

class SelectedFoodController extends GetxController {
  final foodList = <FoodListTileModel>[].obs;

  static SelectedFoodController get to => Get.find();
}