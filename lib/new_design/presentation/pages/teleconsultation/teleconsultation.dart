import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:sizer/sizer.dart';

import '../../../app/utils/constLists.dart';
import '../../Widgets/appBar.dart';
import '../../Widgets/bottomNavBar.dart';
import '../home/home_view.dart';

class Teleconsultation extends StatelessWidget {
  const Teleconsultation({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await Get.to(LandingPage());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          //elevation: 1,

          //shadowColor: Colors.black26,
          toolbarHeight: 31.h,
          flexibleSpace: CustomeAppBar(
            screen: ProgramLists.teleconsultationList,
          ),
          backgroundColor: Colors.white,
        ),
        body: Container(
          height: 50,
          child: Text("Teleconsultation"),
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}
