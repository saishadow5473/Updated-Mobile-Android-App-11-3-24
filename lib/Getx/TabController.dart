import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/signup/sso_signup_start_screen_new.dart';

class MyTabController extends GetxController with SingleGetTickerProviderMixin {
  TabController controller, signupController;
  final index;

  MyTabController({this.index});

  final List<Tab> loginTabs = <Tab>[
    const Tab(
      text: 'Login',
    ),
    const Tab(
      text: 'Corporate Login',
    ),
  ];

  final List<Tab> signUpTabs = <Tab>[
    const Tab(
      text: 'Sign Up',
    ),
    // Tab(
    //   text: '',
    // ),
  ];

  @override
  void onInit() {
    super.onInit();
    controller = TabController(vsync: this, length: 2, initialIndex: index);
    signupController = TabController(vsync: this, length: 1);
  }

  @override
  void onClose() {
    // controller.dispose();
    signupController.dispose();
    super.onClose();
  }
}
