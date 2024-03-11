import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:googleapis/fitness/v1.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:permission_handler/permission_handler.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    FitnessApi.fitnessActivityReadScope,
    FitnessApi.fitnessBodyReadScope,
    FitnessApi.fitnessBloodGlucoseReadScope,
    FitnessApi.fitnessBloodPressureReadScope,
    FitnessApi.fitnessNutritionReadScope,
    FitnessApi.fitnessHeartRateReadScope,
    FitnessApi.fitnessSleepReadScope,
    FitnessApi.fitnessLocationReadScope
  ],
);

class ConnectAppsScreen extends StatefulWidget {
  @override
  State<ConnectAppsScreen> createState() => _ConnectAppsScreenState();
}

class _ConnectAppsScreenState extends State<ConnectAppsScreen> {
  GoogleSignInAccount _currentUser;
  bool googleFitSignedIn = false;
  final TextStyle headerStyle = TextStyle(
    color: AppColors.primaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
  );

  Future<void> _handlePermission() async {
    var granted = await Permission.activityRecognition.isGranted &&
        await Permission.location.isGranted;
    print(granted);
    if (!granted) {
      await Permission.activityRecognition.request();
      await Permission.location.request();
    }
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      if (this.mounted) {
        setState(() {
          _currentUser = account;
        });
      }
      if (_currentUser != null) {
        _handlePermission();
      }
    });
    _googleSignIn.signInSilently().then((value) {
      if (this.mounted) {
        if (value != null) {
          setState(() {
            _currentUser = value;
          });
        }
      }
    });
  }

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
          'Connect with other apps',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 26.0, fontWeight: FontWeight.bold),
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
                        color: Colors.grey.shade200,
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
                              Card(
                                elevation: 0.5,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              radius: 25,
                                              backgroundImage: NetworkImage(
                                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Google_Fit_2018_Logo.svg/169px-Google_Fit_2018_Logo.svg.png'),
                                            ),
                                          ),
                                          Text(
                                            "Google Fit",
                                            style: TextStyle(
                                              fontSize: 22,
                                              color:
                                                  AppColors.textitemTitleColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0)
                                          .copyWith(top: 0),
                                      child: Text(
                                        "Connect to Google Fit to access fitness data across a variety of different apps and devices, and sync data with hCare",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textitemTitleColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    _currentUser != null
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0)
                                                .copyWith(top: 0),
                                            child: Text(
                                              "Signed In as: ${_currentUser.email}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors
                                                    .textitemTitleColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    _buildDivider(),
                                    ListTile(
                                      leading: _currentUser == null
                                          ? ElevatedButton(
                                              onPressed: _handleSignIn,
                                              child:
                                                  Text('Connect to Google Fit'),
                                              style: ElevatedButton.styleFrom(
                                                  shape: StadiumBorder()),
                                            )
                                          : ElevatedButton(
                                              onPressed: _handleSignOut,
                                              child: Text('Disconnect'),
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.red,
                                                  shape: StadiumBorder()),
                                            ),
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
