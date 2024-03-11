import 'package:get/get.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:flutter/material.dart';
import 'package:ihl/views/dietDashboard/profile_settings_screen.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/profileScreen/exports.dart';
import 'package:flushbar/flushbar.dart';

import '../new_design/app/utils/appColors.dart';
import '../new_design/presentation/pages/home/landingPage.dart';

class ProfileTab extends StatefulWidget {
  final showdel;
  final editing;
  Function bacNav;

  ProfileTab({this.editing, this.showdel, this.bacNav});

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool showdel;
  bool editing;

  @override
  void initState() {
    showdel = widget.showdel == null ? false : widget.showdel;
    editing = widget.editing == null ? false : widget.editing;
    if (widget.editing == true) {
      Future.delayed(const Duration(seconds: 1), () {
        Get.snackbar("Alert", "Please Add Address to Book an Appointment",
            backgroundColor: AppColors.primaryColor,
            colorText: Colors.white,
            icon: const Icon(Icons.warning_rounded, color: Colors.white),
            snackPosition: SnackPosition.BOTTOM,
            forwardAnimationCurve: Curves.easeOutBack,
            duration: const Duration(seconds: 3));
        // Flushbar(
        //   title: "Alert",
        //   message: "Please Add Address to Book an Appointment",
        //   duration: const Duration(seconds: 10),
        //   leftBarIndicatorColor: Colors.redAccent,
        //   flushbarPosition: FlushbarPosition.TOP,
        //   animationDuration: const Duration(seconds: 2),
        // ).show(context);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: WillPopScope(
        onWillPop: widget.bacNav ??
            () async {
              Get.back();
              return true;
            },
        child: BasicPageUI(
          appBar: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: widget.bacNav ??
                        () {
                          Get.off(LandingPage());
                        }
                    // widget.bacNav ??
                    //         () {
                    //       print('object');
                    //       // Navigator.pushAndRemoveUntil(
                    //       //     context,
                    //       //     MaterialPageRoute(
                    //       //       builder: (context) => HomeScreen(
                    //       //         introDone: true,
                    //       //       ),
                    //       //     ),
                    //       //     (Route<dynamic> route) => false);//old screen
                    //       // Get.back(); //new
                    //     },
                    // color: Colors.white,
                    // tooltip: 'Back',
                    ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      // icon: Icon(Icons.settings),
                      icon: const Icon(Icons.more_vert),
                      color: Colors.white,
                      onPressed: () => Get.to(ProfileSettingScreen()),
                    ),
                  ),

                  ///=============================
                  // PopupMenuButton<String>(
                  //   onSelected: (k) {
                  //     if (k == 'goal') {
                  //       //Get.to(ViewGoalSettingScreen());
                  //     } else {
                  //       if (this.mounted) {
                  //         setState(() {
                  //           editing = !editing;
                  //         });
                  //       }
                  //     }
                  //   },
                  //   itemBuilder: (context) {
                  //     return [
                  //       PopupMenuItem(
                  //         value: 'open',
                  //         child: Text(
                  //             !editing ? 'Edit your Profile' : 'Close Editing'),
                  //       ),
                  //     ];
                  //   },
                  // ),
                  ///=============================
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Text(
                  'Your Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: ScUtil().setSp(28),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Card(
                margin: const EdgeInsets.all(10),
                color: CardColors.bgColor,
                child: editing == true
                    ? PersonalDetails(
                        fromTele: editing,
                      )
                    : PersonalDetailsCard(),
              ),
              /*SizedBox(
                height: 10,
              ),
              Card(
                margin: EdgeInsets.all(10),
                color: CardColors.bgColor,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Account details'.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (k) {
                              showdel = !showdel;
                              if (this.mounted) {
                                setState(() {});
                              }
                            },
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  value: 'open',
                                  child: Text(showdel
                                      ? 'Hide advanced settings'
                                      : 'Show advanced settings'),
                                )
                              ];
                            },
                          ),
                        ],
                      ),
                    ),
                    ChangePassword(),
                    showdel
                        ? Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Advanced Settings',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    showdel ? DeleteUser() : Container(),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
