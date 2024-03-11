import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/spKeys.dart';
import '../../../../constants/api.dart';
import '../../../../notification_controller.dart';
import '../../../module/online_serivices/functionalities/online_services_data_cache.dart';
import '../../Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../../../widgets/signin_email.dart';
import '../../../app/utils/appColors.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../Widgets/appBar.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../controllers/dashboardControllers/upComingDetailsController.dart';
import '../dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../dashboard/common_screen_for_navigation.dart';
import '../spalshScreen/splashScreen.dart';
import '../../../../utils/SpUtil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({Key key}) : super(key: key);

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Logout'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 28.sp,
          ),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      content: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 12.h,
          ),
          Container(
            height: 30.h,
            width: 100.w,
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/images/logout.png'))),
          ),
          SizedBox(
            height: 3.5.h,
          ),
          const Text('Are you Sure?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
              )),
          SizedBox(
            height: 1.5.h,
          ),
          const Text('Do you want to logout from the app?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
              )),
          SizedBox(
            height: 6.h,
          ),
          Container(
            padding: EdgeInsets.only(left: 10.w, right: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    height: 4.5.h,
                    width: 33.w,
                    decoration: const BoxDecoration(
                      color: AppColors.ihlPrimaryColor,
                    ),
                    child: Center(
                      child: Text('GO BACK',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await clear();
                  },
                  child: Container(
                    height: 4.5.h,
                    width: 33.w,
                    decoration: const BoxDecoration(
                      color: AppColors.ihlPrimaryColor,
                    ),
                    child: Center(
                      child: Text('LOGOUT',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      )),
    );
  }

  Future clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final TabBarController tabController = Get.find();
    try {
      //This is used to remove the previous online services cached data ⚪️
      OnlineServiceCache.resetAllCache();
      SpUtil.remove(LSKeys.userDetail);
      await localSotrage.write(LSKeys.ihlUserId, '');
      localSotrage.save();
      print(localSotrage.read(LSKeys.ihlUserId));
      Get.find<UpcomingDetailsController>().onClose();
      await localSotrage.erase();
      SpUtil.clear();
      try {
        tabController.updateProgramsTab(val: 0);
        UpdatingColorsBasedOnAffiliations.affiColorCode.value == 0;
        UpdatingColorsBasedOnAffiliations.ssoAffiliation.clear();
        UpdatingColorsBasedOnAffiliations.affiMap.value.clear();
        UpdatingColorsBasedOnAffiliations.companyName.clear();
        selectedAffiliationfromuniquenameDashboard = '';
      } catch (e) {
        print('data is not there');
      }

      try {
        OnlineServiceCache.selectedAffiliationName = "loggedOut";
        await prefs.clear().then((bool value) {
          log('SharedPrefe Keys ${prefs.getKeys()}');

          log('Erase $value');
          localSotrage.write(LSKeys.logged, false);
          localSotrage.save();
        });
      } catch (e) {
        print(e);
      }

      Directory cacheDir;
      // = await getTemporaryDirectory();
      try {
        if (Platform.isAndroid) {
          cacheDir = await getTemporaryDirectory();
          if (cacheDir.existsSync()) {
            cacheDir.deleteSync(recursive: true);
          }
        } else {
          cacheDir = await getTemporaryDirectory();
          cacheDir.delete(recursive: true);
        }
      } catch (e) {
        print(e);
      }
      Directory appDir;
      // = await getApplicationSupportDirectory();
      try {
        if (Platform.isAndroid) {
          appDir = await getApplicationSupportDirectory();
          if (appDir.existsSync()) {
            appDir.deleteSync(recursive: true);
          }
        } else {
          appDir = await getApplicationSupportDirectory();
          appDir.delete(recursive: true);
        }
      } catch (e) {
        print(e);
      }
      Directory docDir;
      if (Platform.isAndroid) {
        docDir = await getApplicationDocumentsDirectory();
        try {
          if (docDir.existsSync()) {
            docDir.deleteSync(recursive: true);
          }
        } catch (e) {
          print(e);
        }
      }

      List<Directory> externalDir;
      if (Platform.isAndroid) {
        externalDir = await getExternalStorageDirectories();
        try {
          if (externalDir.isNotEmpty) {
            externalDir.clear();
          }
        } catch (e) {
          print(e);
        }
      }
      // final downDir = await getDownloadsDirectory();

      // if (downDir.existsSync()) {
      //   downDir.deleteSync(recursive: true);
      // }

      List<Directory> exeCac;

      try {
        if (Platform.isAndroid) {
          exeCac = await getExternalCacheDirectories();
          if (exeCac.isNotEmpty) {
            exeCac.clear();
          }
          print(exeCac.isEmpty);

          print(exeCac.toString());
          print(exeCac.toString());
        }
      } catch (e) {
        print(e);
      }
      Directory extSto;

      try {
        if (Platform.isAndroid) {
          extSto = await getExternalStorageDirectory();
          if (extSto.existsSync()) {
            extSto.deleteSync(recursive: true);
          }

          print(extSto.toString());
          extSto.delete();
        }
      } catch (e) {
        print(e);
      }
      // final libd = await getLibraryDirectory();

      // try {
      //   if (libd.existsSync()) {
      //     libd.deleteSync(recursive: true);
      //   }
      // } catch (e) {
      //   print(e);
      // }

      print('${prefs.isBlank}--------->');
      // print(localSotrage.getValues().toString() + '------>local storage');
      // print(cacheDir.isBlank.toString() + '------>cache storage');
      // print(appDir.isBlank.toString() + '------>appdir storage');
      // print(docDir.isBlank.toString() + '------>doc storage');
      //   print(externalDir.isBlank.toString() + '------>external storage');
      //    print(exeCac.isBlank.toString() + '------>external cache storage');
      //  print(extSto.isBlank.toString() + '------>ext storage storage');
      // print(libd.isBlank.toString() + '------>lib storage');
      // print(downDir.isBlank.toString() + '------>down storage');
    } catch (e) {
      print(e);
    }
    Tabss.firstTime = true;

    try {
      var userAffiliated;
      Object raw = prefs.get(SPKeys.userData);
      if (raw == '' || raw == null) {
        raw = '{}';
      }
      Map data = jsonDecode(raw);
      Map user = data['User'];
      user ??= {};

      ///from this variable we will  now that user is affiliated or not
      userAffiliated = user['user_affiliate'];
      List affUniqueNameList = [];
      if (userAffiliated == null) {
        userAffiliated = [];
      } else {
        userAffiliated.removeWhere((k, v) {
          if (v["affilate_unique_name"] != "" && v["affilate_unique_name"] != "null") {
            affUniqueNameList.add(v["affilate_unique_name"]);
            API.affNmLst.add(v['affilate_name'].toString().replaceAll(' Pvt Ltd', ''));
          }
          return v["affilate_unique_name"] == "";
        });
        print(API.affNmLst);
      }
      FCM().TopicUnsubscription(affUniqueNameList);
    } catch (e) {
      print('subcriptions not cleared');
    }
    Get.offAll(const LoginEmailScreen());
  }
}
