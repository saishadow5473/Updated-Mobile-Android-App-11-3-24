import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health/health.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:ihl/new_design/app/utils/localStorageKeys.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '';

class PermissionHandlerUtil {
  static Future<bool> mediaPermission() async {
    bool permissionGrandted = false;
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      Map<Permission, PermissionStatus> _status;
      if (deviceInfo.version.sdkInt <= 32) {
        _status = await [Permission.storage].request();
      } else {
        _status = await [Permission.photos, Permission.videos].request();
      }
      _status.forEach((permission, status) async {
        if (status == PermissionStatus.granted) {
          return permissionGrandted = true;
        } else if (status == PermissionStatus.permanentlyDenied) {
          await openAppSettings();
        }
      });
    } else {
      final status = await Permission.photos.request();
      if (status == PermissionStatus.permanentlyDenied) {
        await Permission.photos.request();
        await openAppSettings();
      }
      return permissionGrandted = status == PermissionStatus.granted;
    }
    return permissionGrandted;
  }

  static Future<bool> cameraPermission() async {
    bool permissionGrandted = false;
    var _permissionStates = await Permission.camera.request();
    if (_permissionStates.isGranted) {
      permissionGrandted = true;
    } else if (_permissionStates.isPermanentlyDenied) {
      await openAppSettings();
    }
    return permissionGrandted;
  }

  static Future<bool> requestPermission(Permission permission) async {
    bool permissionGrandted = false;

    if (permission == Permission.storage) {
      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        Map<Permission, PermissionStatus> _status;
        if (deviceInfo.version.sdkInt <= 32) {
          _status = await [Permission.storage].request();
        } else {
          _status = await [Permission.photos, Permission.videos].request();
        }
        _status.forEach((permission, status) {
          if (status == PermissionStatus.granted) {
            return permissionGrandted = true;
          }
        });
      } else {
        final status = await permission.request();

        return permissionGrandted = status == PermissionStatus.granted;
      }
    } else {
      final status = await permission.request();
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return permissionGrandted = status == PermissionStatus.granted;
    }
  }

  static Future<bool> hasPermission(Permission permission) async {
    final status = await permission.status;
    return status == PermissionStatus.granted;
  }

  static Future<bool> hasPermissionOrRequest(Permission permission) async {
    final status = await permission.status;
    if (status != PermissionStatus.granted) {
      final result = await requestPermission(permission);
      return result;
    }
    return true;
  }

  static Future<bool> googleFitPermission() async {
    HealthFactory health = HealthFactory();
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    bool fitImplemented = _prefs.getBool('fit') ?? false;
    bool fitInstalled = localSotrage.read(LSKeys.fitInstalled) ?? false;
    final types = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];
    if (Platform.isIOS) {
      types.add(HealthDataType.DISTANCE_WALKING_RUNNING);
      types.add(HealthDataType.EXERCISE_TIME);
    } else {
      types.add(HealthDataType.DISTANCE_DELTA);
      types.add(HealthDataType.MOVE_MINUTES);
    }
    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];
    if (Platform.isAndroid) {
      if (!fitInstalled) {
        fitInstalled = await LaunchApp.isAppInstalled(
            androidPackageName: "com.google.android.apps.fitness");
        localSotrage.write(LSKeys.fitInstalled, fitInstalled);
      }
    } else {
      fitInstalled = true;
    }
    if (Platform.isAndroid) {
      try {
        GoogleSignIn _googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'https://www.googleapis.com/auth/contacts.readonly',
          ],
        );
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint('Google Account Selection Failed');
      }
    }
    if (!fitImplemented && !Get.isDialogOpen) {
      return Get.defaultDialog(
        title: "",
        barrierDismissible: false,
        content: WillPopScope(
          onWillPop: () async {
            SharedPreferences _prefs = await SharedPreferences.getInstance();
            _prefs.setBool('fit', false);
            localSotrage.write('fit', false);
            Get.back();
            return;
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(
                        height: Platform.isAndroid ? 20.sp : 25.sp,
                        child: Platform.isAndroid
                            ? Image.asset("assets/icons/googlefit.png")
                            : Image.asset(
                                "assets/images/health_app_icon.png",
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Text(
                      Platform.isAndroid ? "Google Fit" : "Health",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    var value;
                    try {
                      value = await health.requestAuthorization(types,
                          permissions: permissions);
                    } catch (e) {
                      debugPrint('Google Account Selection Failed');
                    }
                    if (value) {
                      Get.snackbar('Success', 'Connected Successfully',
                          margin: EdgeInsets.all(20).copyWith(bottom: 40),
                          backgroundColor: AppColors.primaryAccentColor,
                          colorText: Colors.white,
                          duration: Duration(seconds: 5),
                          snackPosition: SnackPosition.BOTTOM);
                      SharedPreferences _prefs =
                          await SharedPreferences.getInstance();
                      _prefs.setBool('fit', true);
                      localSotrage.write('fit', true);
                      log('Google Fit ${localSotrage.read('fit')}');
                      log(localSotrage.getKeys().toString());
                      Navigator.of(Get.context).pop(true);

                      return value;
                    } else if (!fitInstalled) {
                      SharedPreferences _prefs =
                          await SharedPreferences.getInstance();
                      _prefs.setBool('fit', false);
                      localSotrage.write('fit', false);
                      Navigator.of(Get.context).pop(false);
                      Get.snackbar('Connection Error',
                          'Unable to connect to Google Fit.',
                          margin: EdgeInsets.all(20).copyWith(bottom: 40),
                          backgroundColor: AppColors.hightStatusColor,
                          colorText: Colors.white,
                          duration: Duration(seconds: 5),
                          snackPosition: SnackPosition.BOTTOM);
                      return false;
                    } else {
                      SharedPreferences _prefs =
                          await SharedPreferences.getInstance();
                      _prefs.setBool('fit', false);
                      localSotrage.write('fit', false);
                      Navigator.of(Get.context).pop(false);
                      Get.snackbar('Failed', 'Failed to Connect!',
                          margin: EdgeInsets.all(20).copyWith(bottom: 40),
                          backgroundColor: AppColors.hightStatusColor,
                          colorText: Colors.white,
                          duration: Duration(seconds: 5),
                          snackPosition: SnackPosition.BOTTOM);
                      return false;
                    }
                  },
                  child: Text(
                      'Connect to ${Platform.isAndroid ? 'Google Fit' : 'Health'}'),
                  style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                ),
              )
            ],
          ),
        ),
      );
    } else
      return true;
  }
}
