import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavController extends GetxController {
  final PageController pageController = PageController(initialPage: 0);
  RxInt pageIndex = 0.obs;
  // List<Widget> screens = [
  //   Teleconsultation(),
  //   Myvitals(),
  //   HealthProgram(),
  //   Social(),
  //   Home(),
  // ];
  List<Widget> screens = [
    Container(
      color: Colors.grey,
    ),
    Container(
      color: Colors.pink,
    ),
    Container(
      color: Colors.purple,
    ),
    Container(
      color: Colors.green,
    ),
    Container(
      color: Colors.blue,
    ),
  ];
  updatePage(int value) {
    pageIndex.value = value;
    pageController.animateToPage(value,
        duration: const Duration(
          milliseconds: 500,
        ),
        curve: Curves.easeInOut);
  }
}
