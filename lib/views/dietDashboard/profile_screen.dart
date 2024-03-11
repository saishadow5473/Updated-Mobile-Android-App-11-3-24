import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietDashboard/profile_settings_screen.dart';
import 'package:ihl/widgets/profileScreen/personal.dart';

class ProfileScreen extends StatefulWidget {
  final bool isJointAccount;

  const ProfileScreen({Key key, this.isJointAccount}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextStyle headerStyle = TextStyle(
    color: AppColors.primaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
  );

  bool isJointAccount = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Profile',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 26.0, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.settings),
              color: Colors.white,
              onPressed: () => Get.to(ProfileSettingScreen()),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          color: AppColors.bgColorTab,
          child: CustomPaint(
            painter: BackgroundPainter(
                primary: Colors.blue.withOpacity(0.8), secondary: Colors.blue),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
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
                              const SizedBox(height: 10.0),
                              /*Card(
                                elevation: 0.5,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 0,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: MediumProfilePhoto(),
                                          ),
                                          Text(
                                            "Test User",
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildDivider(),
                                    ListTile(
                                      title: Text("IHL Score: 400"),
                                      leading: Icon(
                                        Icons.stars,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),*/
                              PersonalProfileDetailsCard(),
                              /*const SizedBox(height: 20.0),
                              Text(
                                "PROFILE SETTINGS",
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
                                      trailing:
                                          Icon(Icons.arrow_forward_ios_rounded),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                "GOAL SETTINGS",
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
                                      trailing:
                                          Icon(Icons.arrow_forward_ios_rounded),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                "ACCOUNT SETTINGS",
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
                                      title: Text(
                                          "Connect to other apps & services"),
                                      trailing:
                                          Icon(Icons.arrow_forward_ios_rounded),
                                    ),
                                    _buildDivider(),
                                    ListTile(
                                      title: Text("Change Password"),
                                      trailing:
                                          Icon(Icons.arrow_forward_ios_rounded),
                                    ),
                                    _buildDivider(),
                                    ListTile(
                                      title: Text("Delete Account"),
                                      trailing:
                                          Icon(Icons.arrow_forward_ios_rounded),
                                    ),
                                  ],
                                ),
                              ),*/
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
