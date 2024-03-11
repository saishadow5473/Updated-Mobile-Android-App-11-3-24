import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ihl/abha/networks/network_calls_abha.dart';
import 'package:ihl/new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import 'package:ihl/new_design/data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';
import 'package:ihl/new_design/presentation/controllers/vitalDetailsController/myVitalsController.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';

import '../../../../constants/spKeys.dart';
import '../../../app/utils/appColors.dart';
import '../../../app/utils/imageAssets.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../controllers/getTokenContoller/getTokenController.dart';
import '../../controllers/splashScreenController/splash_screen_controller.dart';

GetStorage localSotrage;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _initialUriIsHandled = false;
  final SplashScreenController _splashScreenController = Get.put(SplashScreenController());

  @override
  Future<void> initState() {
    getInstance();
    Get.put(() => GetTokenController());
    var getTokenController = Get.put(GetTokenController());
    // NetworkCallsAbha().getAccessToken();
    _splashScreenController.timerForSplashScreen();
    _splashScreenController.getStoreData();
    if (localSotrage.read(GSKeys.isSSO) == null) {
      localSotrage.write(GSKeys.isSSO, false);
    }
    print(localSotrage.read(GSKeys.isSSO).toString());
    _splashScreenController.handleInitialUri();
    retriveData();
    SpUtil.putBool(LSKeys.affiliation, false);
    super.initState();

    // Timer(Duration(seconds: 14),
    //     () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home())));
  }

  void getInstance() async {
    await SpUtil.getInstance();
  }

  Future retriveData() async {
    var response = await SplashScreenApiCalls().loginApi();

    await MyvitalsApi().vitalDatas(response);
    var userId = SpUtil.getString(LSKeys.ihlUserId);
    await MyVitalsController().getVitalsCheckinData(userId);
    _splashScreenController.timerSplashScreen.cancel();
    print("first");
  }

  @override
  Widget build(BuildContext context) {
    // ScUtil.init(context);
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return Scaffold(
      backgroundColor: AppColors.primaryAccentColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            end: Alignment.topRight,
            begin: Alignment.bottomLeft,
            colors: [
              AppColors.primaryColor,
              // AppColors.primaryColor,

              Color.fromRGBO(42, 178, 231, 1),
              Colors.white.withOpacity(0.5),
              // Color.fromRGBO(42, 178, 231,1),
              // Color.fromRGBO(42, 178, 231,1)
            ],
          ),
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.5,
              ),
              Container(
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(ImageAssets.ihlLogo),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
              ),
              Text(
                "India Health Link © 2024 \n   All Rights Reserved",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: 'Poppins-Black',
                    color: Colors.white),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 80,
              ),
              SpinKitThreeBounce(
                color: Colors.white, // Customize the color of the dots
                size: 25.0, // Adjust the size of the loader
              ),
            ],
          ),
        ),
      ),
    );
  }
}
