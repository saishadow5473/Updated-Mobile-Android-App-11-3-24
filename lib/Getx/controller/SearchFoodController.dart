import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../new_design/data/providers/network/healthjournal/searchfood.dart';

class SearchFoodController extends GetxController{
List foodList = [];
String type ='';
ScrollController controller = ScrollController();


@override
void onInit() async {
  foodList =await fetchFood(endPage: 0,type: this.type);
  controller.addListener(() {
    if (controller.position.maxScrollExtent == controller.position.pixels) {
      fetch();
    }
  });
  super.onInit();

}

@override
void dispose() {
  controller.dispose();
  super.dispose();
}
fetch()async{
  List _l = await fetchFood(
    endPage: foodList.length,
  );
  foodList.addAll(_l);
}

Future<List> fetchFood({@required int endPage,String type})async{
  List _temp =[];
_temp =await SearchFoodApi.searchFoodList(endPage: endPage, letter: type);
return _temp;
}
}