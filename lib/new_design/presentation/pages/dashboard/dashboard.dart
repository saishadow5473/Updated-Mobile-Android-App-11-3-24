import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/controllers/dashboardControllers/bottomNavController.dart';

import '../../../app/utils/constLists.dart';
import '../../Widgets/offeredProgram.dart';

class DashBoardBottomNavBar extends StatelessWidget {
  const DashBoardBottomNavBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _bottomController = Get.put(BottomNavController());
    return Scaffold(
      body: Column(
        children: [
          OfferedPrograms(screenTitle: 'Selected Programs', screen: ProgramLists.homeList),
          PageView(
            controller: _bottomController.pageController,
            children: _bottomController.screens,
          ),
        ],
      ),
      //bottomNavigationBar: BottomNavBar(),
    );
  }
}
