import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietDashboard/change_pwd_screen.dart';
import 'package:ihl/views/dietDashboard/edit_profile_screen.dart';

// import 'package:ihl/views/dietDashboard/google_fit_signin.dart';
import 'package:ihl/views/dietDashboard/other_account_setting_screen.dart';
import 'package:ihl/views/dietDashboard/profile_event_certificate.dart';
import 'package:ihl/views/goal_settings/edit_goal_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/spKeys.dart';
import '../../new_design/app/utils/localStorageKeys.dart';
import '../../new_design/presentation/Widgets/appBar.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';

class ProfileSettingScreen extends StatefulWidget {
  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  final TextStyle headerStyle = TextStyle(
    color: AppColors.primaryColor,
    fontWeight: FontWeight.w600,
    fontSize: 20.0,
  );
  bool isChecked = false;
  bool isdialogChecked = false;
  int check = 0;
  var isSSo;
  String ihlId = '';

  @override
  void initState() {
    checkSSO();
    super.initState();
  }

  void checkSSO() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    isSSo = prefs.get(
      SPKeys.is_sso,
    );
    if (mounted) setState(() {});
    print(isSSo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Get.back();
            //Get.to(ProfileTab());
          },
        ),
        title: Text(
          'Settings',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 26.0, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          color: AppColors.bgColorTab,
          child: CustomPaint(
            painter:
                BackgroundPainter(primary: Colors.blue.withOpacity(0.8), secondary: Colors.blue),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Colors.grey.shade200,
                        color: FitnessAppTheme.nearlyWhite,
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 30.0),
                              Text(
                                "Events ",
                                // "EVENTS SETTINGS",
                                style: headerStyle,
                              ),
                              Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 0,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text("Certificates"),
                                      trailing: Icon(Icons.arrow_forward_ios_rounded),
                                      onTap: () async {
                                        Get.to(EventsInProfile());
                                        // if(backR!=null){
                                        //   if(backR[0]==true){
                                        //     getEventDetails();
                                        //   }
                                        // }
                                        //Get.to(SignInDemo());
                                      },
                                    ),
                                    _buildDivider(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                // "PROFILE SETTINGS",
                                "Profile",
                                style: headerStyle,
                              ),
                              Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 0,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text("Edit Profile Details"),
                                      trailing: Icon(Icons.arrow_forward_ios_rounded),
                                      onTap: () {
                                        Get.to(EditProfileScreen(
                                          kisokAccountWithoutWeight: false,
                                        ));
                                      },
                                    ),
                                    // _buildDivider(),
                                    // ListTile(
                                    //   title: Text(
                                    //     "ABHA Health ID ",
                                    //     // "Other Account Settings",
                                    //   ),
                                    //   trailing: Icon(
                                    //     Icons.arrow_forward_ios_rounded,
                                    //   ),
                                    //   onTap: () {
                                    //     Get.to(AbhaAccountLogin(
                                    //       abhaTextField: "aadhar",
                                    //     ));
                                    //   },
                                    // ),
                                    // _buildDivider(),
                                    // ListTile(
                                    //   title: Text("Joint Accounts"),
                                    //   trailing:
                                    //       Icon(Icons.arrow_forward_ios_rounded),
                                    //   onTap: () {
                                    //     Get.to(JointAccount());
                                    //   },
                                    // )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                "Goal",
                                // "GOAL SETTINGS",
                                style: headerStyle,
                              ),
                              Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 0,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text("Edit/Change your goal"),
                                      trailing: Icon(Icons.arrow_forward_ios_rounded),
                                      onTap: () {
                                        ///goal settings Navigation
                                        Get.to(ViewGoalSettingScreen(
                                          goalChangeNavigation: false,
                                        ));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              // const SizedBox(height: 20.0),
                              // Text(
                              //   "Activate personal account",
                              //   // "GOAL SETTINGS",
                              //   style: headerStyle,
                              // ),
                              // Card(
                              //   margin: const EdgeInsets.symmetric(
                              //     vertical: 8.0,
                              //     horizontal: 0,
                              //   ),
                              //   child: Column(
                              //     children: <Widget>[
                              //       ListTile(
                              //         title: Text("Enable Personal Account"),
                              //         trailing: Switch(
                              //           value: Tabss.personalEnabled,
                              //           onChanged: (value) async {
                              //             SharedPreferences prefs =
                              //                 await SharedPreferences.getInstance();
                              //             if (value) {
                              //               String uid = prefs.getString(LSKeys.ihlUserId);
                              //               prefs.setString("personalDashboardUID", uid);
                              //               Tabss.personalEnabled = value;
                              //               _showAlertDialog(context, Tabss.personalEnabled);
                              //             } else {
                              //               prefs.remove("personalDashboardUID");
                              //               Tabss.personalEnabled = value;
                              //               _showAlertDialog(context, Tabss.personalEnabled);
                              //             }
                              //
                              //             // else {
                              //             //   Tabss.featureSettings.personalEnabled = false;
                              //             // }
                              //             // Get.to(LandingPage(personalenabled: Tabss.featureSettings.personalEnabled));
                              //             setState(() {
                              //               // Get.to(LandingPage(personalenabled: true));
                              //
                              //               // isChecked = value;
                              //             });
                              //           },
                              //         ),
                              //         onTap: () {},
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              const SizedBox(height: 20.0),
                              isSSo != 'true'
                                  ? Text(
                                      "Others",
                                      // "ACCOUNT SETTINGS",
                                      style: headerStyle,
                                    )
                                  : Container(),
                              isSSo != 'true'
                                  ? Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal: 0,
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          // ListTile(
                                          //   title: Text(
                                          //       "Connect to other Apps & Devices"),
                                          //   trailing:
                                          //       Icon(Icons.arrow_forward_ios_rounded),
                                          //   onTap: () {
                                          //     Get.to(ConnectAppsScreen());
                                          //     //Get.to(SignInDemo());
                                          //   },
                                          // ),
                                          // _buildDivider(),
                                          ListTile(
                                            title: Text("Change Password"),
                                            trailing: Icon(Icons.arrow_forward_ios_rounded),
                                            onTap: () {
                                              Get.to(ChangePasswordScreen());
                                            },
                                          ),
                                          _buildDivider(),
                                          ListTile(
                                            title: Text(
                                              "Other Account Settings",
                                              // "Other Account Settings",
                                            ),
                                            trailing: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                            ),
                                            onTap: () {
                                              Get.to(OtherAccountScreen());
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showAlertDialog(BuildContext context, bool enabled) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return an AlertDialog
        return AlertDialog(
          content: Text('Switch on my personal records and services??'),
          actions: <Widget>[
            // Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Spacer(),
                // TextButton(
                //   onPressed: () async {
                //     Get.back();
                //     Get.back();
                //     Get.back();
                //   },
                //   child: Text('Cancel'),
                // ),
                TextButton(
                  onPressed: () async {
                    Get.to(LandingPage(personalenabled: enabled));
                    // }
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade300,
    );
  }
}
