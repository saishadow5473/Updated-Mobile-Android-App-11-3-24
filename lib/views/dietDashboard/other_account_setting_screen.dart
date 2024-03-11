import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietDashboard/delete_account_screen.dart';

class OtherAccountScreen extends StatefulWidget {
  @override
  State<OtherAccountScreen> createState() => _OtherAccountScreenState();
}

class _OtherAccountScreenState extends State<OtherAccountScreen> {
  final TextStyle headerStyle = TextStyle(
    color: AppColors.primaryColor,
    fontWeight: FontWeight.w500,
    fontSize: 17.0,
    fontFamily: 'Poppins'
  );

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
          'Other Account Settings',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Poppins',
              color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w500),
        ),
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
                              const SizedBox(height: 20.0),
                              Text(
                                "OTHER ACCOUNT SETTINGS",
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
                                      title: Text("Delete Account"),
                                      trailing:
                                          Icon(Icons.arrow_forward_ios_rounded),
                                      onTap: () {
                                        Get.to(DeleteProfileScreen());
                                      },
                                    ),
                                  ],
                                ),
                              ),
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

}
