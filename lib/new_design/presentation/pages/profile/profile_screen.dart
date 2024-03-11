import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../views/screens.dart';
import '../aboutIHL/aboutIhl.dart';
import '../logout/logoutScreen.dart';
import '../onlineServices/MyMedicalFiles.dart';
import '../settings/settingsScreen.dart';
import 'myprofile.dart';
import '../basicData/functionalities/percentage_calculations.dart';
import '../basicData/screens/ProfileCompletion.dart';
import '../home/landingPage.dart';

import '../../../../tabs/badges.dart';
import '../../../../widgets/signin_email.dart';
import '../../../../constants/spKeys.dart';
import '../../../app/utils/textStyle.dart';
import '../../Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../Widgets/smallCard.dart';
import '../../controllers/dashboardControllers/upComingDetailsController.dart';
import '../dashboard/common_screen_for_navigation.dart';
import 'updatePhoto.dart';
import '../../../../utils/SpUtil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../../abha/networks/network_calls_abha.dart';
import '../../../../abha/views/abha_account.dart';
import '../../../../abha/views/abha_id_download.dart';
import '../../../../views/qrScanner/qr_scanner_screen.dart';
import '../../../../views/teleconsultation/files/MedicalFilesCategory.dart';
import '../../../app/utils/constLists.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../Widgets/appBar.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../spalshScreen/splashScreen.dart';

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String version = "";

  @override
  void initState() {
    if (localSotrage.read(GSKeys.isSSO) == null) {
      localSotrage.write(GSKeys.isSSO, false);
    }
    print(localSotrage.read(GSKeys.isSSO).toString());
    asyncfun();
    super.initState();
  }

  asyncfun() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    setState(() {});
  }

  bool abhaTapped = false;

  @override
  Widget build(BuildContext context) {
    void getAbhadata() async {
      setState(() {
        abhaTapped = true;
      });
      dynamic response = await NetworkCallsAbha().viewAbhadetails();
      print(response.isEmpty);
      if (response.isEmpty) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => AbhaAccountLogin(abhaTextField: "phonenumber")));
      } else {
        print(response);
        var healthid = response[0]['abha_address'];
        var abhaNumber = response[0]['abha_number'];
        String abhaCard = await NetworkCallsAbha().viewAbhaCard(healthid);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => AbhaIdDownloadScreen(
                      abhaAddress: healthid,
                      abhaCard: abhaCard,
                      abhaNumber: abhaNumber,
                    )));

        abhaTapped = false;
      }
    }

    final TabBarController tabController = Get.put(TabBarController());
    //    Future<void> _cup({BuildContext cont}) async {
    //   bool connection = await checkInternet();
    //   if (connection == false) {
    //     SnackBar snackBar = SnackBar(
    //       content:
    //           Text('Failed to connect to internet, Cannot change profile picture without internet'),
    //       backgroundColor: Colors.amber,
    //     );
    //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //     return;
    //   }

    //   return showCupertinoModalPopup(
    //     context: cont,
    //     builder: (context) => CupertinoActionSheet(
    //       title: Text('Upload profile photo'),
    //       actions: [
    //         Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: ClipRRect(
    //             borderRadius: BorderRadius.circular(10),
    //             child: TextButton(
    //               style: TextButton.styleFrom(
    //                 primary: Colors.white,
    //                 backgroundColor: AppColors.primaryAccentColor,
    //                 padding: EdgeInsets.all(10),
    //               ),
    //               child: Row(
    //                 mainAxisSize: MainAxisSize.max,
    //                 children: [
    //                   Icon(Icons.photo_camera),
    //                   SizedBox(
    //                     width: 10,
    //                   ),
    //                   Text(
    //                     'Open Camera',
    //                     textScaleFactor: 1.5,
    //                   ),
    //                 ],
    //               ),
    //               onPressed: () {
    //                 onCamera(cont);
    //               },
    //             ),
    //           ),
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: ClipRRect(
    //             borderRadius: BorderRadius.circular(10),
    //             child: TextButton(
    //               style: TextButton.styleFrom(
    //                 primary: Colors.white,
    //                 backgroundColor: AppColors.primaryAccentColor,
    //                 padding: EdgeInsets.all(10),
    //               ),
    //               child: Row(
    //                 mainAxisSize: MainAxisSize.max,
    //                 children: [
    //                   Icon(Icons.photo),
    //                   SizedBox(
    //                     width: 10,
    //                   ),
    //                   Text(
    //                     'Open Gallery',
    //                     textScaleFactor: 1.5,
    //                   ),
    //                 ],
    //               ),
    //               onPressed: () {
    //                 onGallery(cont);
    //               },
    //             ),
    //           ),
    //         ),
    //       ],
    //       cancelButton: ClipRRect(
    //         borderRadius: BorderRadius.circular(10),
    //         child: TextButton(
    //           style: TextButton.styleFrom(
    //             backgroundColor: Colors.red,
    //             primary: Colors.white,
    //             padding: EdgeInsets.all(10),
    //           ),
    //           child: Row(
    //             mainAxisSize: MainAxisSize.max,
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Text(
    //                 'Cancel',
    //                 textScaleFactor: 1.5,
    //               ),
    //             ],
    //           ),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // // ignore: missing_return
    // Future<File> _pickImage({ImageSource source, BuildContext context}) async {
    //   final picked = await ImagePicker().getImage(
    //     source: source,
    //     maxHeight: 720,
    //     maxWidth: 720,
    //     imageQuality: 80,
    //   );

    //   if (picked != null) {
    //     File selected = await FlutterExifRotation.rotateImage(path: picked.path);
    //     if (selected != null) {
    //       return selected;
    //     }
    //   }
    // }

    // Future<File> getIMG({ImageSource source, BuildContext context}) async {
    //   File fromPickImage = await _pickImage(context: context, source: source);
    //   if (fromPickImage != null) {
    //     await crop(fromPickImage);
    //   } else {
    //     loading = false;
    //   }
    // }

    // Future crop(File selectedfile) async {
    //   try {
    //     await ImageCropper().cropImage(
    //       sourcePath: selectedfile.path,
    //       uiSettings: [
    //         AndroidUiSettings(
    //           lockAspectRatio: false,
    //           activeControlsWidgetColor: AppColors.primaryAccentColor,
    //           backgroundColor: AppColors.appBackgroundColor,
    //           toolbarColor: AppColors.primaryAccentColor,
    //           toolbarWidgetColor: Colors.white,
    //           toolbarTitle: 'Crop Image',
    //         ),
    //         IOSUiSettings(
    //           title: 'Crop image',
    //         )
    //       ],
    //     ).then((value) {
    //       if (value != null) {
    //         upload(File(value.path), context);
    //       } else {
    //         loading = false;
    //       }
    //     });
    //   } catch (e) {
    //     return selectedfile;
    //   }
    // }
    // String userName = localSotrage.read(LSKeys.userName);
    String jobTitle = "";

    String userName = SpUtil.getString(LSKeys.userName);
    var userDetails;
    if (SpUtil.getString('data').isNotEmpty) {
      print(SpUtil.getString('data').toString());
      userDetails = jsonDecode(SpUtil.getString('data'));
    }
    if (userDetails != null) {
      Map userData = userDetails['User'];
      if (userData != null) {
        if (userData.containsKey('user_job_details')) {
          Map userJobDetails = userDetails['User']["user_job_details"];
          if (userJobDetails.containsKey('jobTitle')) {
            jobTitle = userDetails['User']["user_job_details"]["jobTitle"];
          }
        }
      }
    } else {
      jobTitle = "";
    }

    // var a = localSotrage.read(LSKeys.userDetail);
    return WillPopScope(
      onWillPop: () {
        Get.off(LandingPage());
      },
      child: CommonScreenForNavigation(
        appBar: AppBar(
          elevation: 0,
          //shadowColor: Colors.black26,
          toolbarHeight: 7.5.h,
          automaticallyImplyLeading: false,
          flexibleSpace: const CustomeAppBar(
            screen: ProgramLists.commonList,
          ),
          backgroundColor: Colors.white,
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // Container(
              //   height: 18.h,
              //   child: Center(
              //     child: Stack(
              //       children: [
              //         GestureDetector(
              //           onTap: () {},
              //           child: Container(
              //             height: 22.h,
              //             width: 28.w,
              //             decoration: BoxDecoration(
              //                 shape: BoxShape.circle,
              //                 image: DecorationImage(
              //                     fit: BoxFit.cover,
              //                     image: NetworkImage(
              //                         'https://cdn.pixabay.com/photo/2022/12/24/21/14/portrait-7676482_960_720.jpg'))),
              //           ),
              //         ),
              //         Positioned(
              //             bottom: 1.h,
              //             right: 0,
              //             child: GestureDetector(
              //               onTap: () {
              //                 Get.to(EditProfileScreen());
              //               },
              //               child: Container(
              //                 height: 40,
              //                 width: 40,
              //                 decoration:
              //                     BoxDecoration(color: Color(0xffffffff), shape: BoxShape.circle),
              //                 child: Icon(Icons.edit),
              //               ),
              //             ))
              //       ],
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 18.h,
                child: UpdatePhoto(
                  update: true,
                ),
              ),
              Center(
                child: Text(
                  userName,
                  style: AppTextStyles.profileName,
                ),
              ),
              const SizedBox(
                height: 9,
              ),
              jobTitle != null
                  ? Center(
                      child: Text(
                        jobTitle,
                        style: AppTextStyles.designation,
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 5.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 8.sp, right: 8.sp),
                child: Column(
                  children: [
                    SmallCard(
                      onTap: () {
                        PercentageCalculations().calculatePercentageFilled() != 100
                            ? Get.to(ProfileCompletionScreen())
                            :
                            //  Get.to(ProfileTab());
                            Get.to(const MyProfile());
                      },
                      cardName: 'My Profile',
                      image: 'newAssets/Icons/profile.png',
                    ),
                    //Mybadges implementation✅
                    const SizedBox(
                      height: 13,
                    ),
                    SmallCard(
                      onTap: () {
                        PercentageCalculations().calculatePercentageFilled() != 100
                            ? Get.to(ProfileCompletionScreen())
                            : Get.to(const BadgesTab());
                      },
                      cardName: 'My Badges',
                      image: 'newAssets/Icons/steps.png',
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    SmallCard(
                      onTap: () {
                        // Get.toNamed(Routes.MyMedicalFiles);
                        Get.to(MyMedicalFiles(medicalFiles: false, normalFlow: true));
                      },
                      cardName: 'Medical Records',
                      image: 'newAssets/Icons/Uploaded Document.png',
                    ),
                    // SizedBox(
                    //   height: 13,
                    // ),
                    // SmallCard(
                    //   onTap: () {
                    //     if (!abhaTapped) {
                    //       getAbhadata();
                    //     }
                    //   },
                    //   cardName: 'ABHA Health ID',
                    //   image: 'newAssets/Icons/ABHA Health ID.png',
                    // ),
                    const SizedBox(
                      height: 13,
                    ),
                    SmallCard(
                      onTap: () async {
                        PermissionStatus status = await Permission.camera.status;
                        // widget.pageController.animateToPage(2,
                        //     duration: Duration(milliseconds: 300),
                        //     curve: Curves.bounceIn);
                        //widget.closeDrawer();
                        if (status.isGranted) {
                          Get.to(const QRScannerScreen());
                        }
                        if (status.isGranted) {
                          showAlert(context);
                          //Get.to(QRScannerScreen());
                          return true;
                        } else if (status.isDenied) {
                          //await Permission.camera.request();
                          status = await Permission.camera.status;
                          if (status.isGranted) {
                            ///here
                            return true;
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => CupertinoAlertDialog(
                                      title: const Text("Camera Access Denied"),
                                      content: const Text("Allow Camera permission to continue"),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          isDefaultAction: true,
                                          child: const Text("Yes"),
                                          onPressed: () async {
                                            final bool result = await Permission.camera
                                                .request()
                                                .isPermanentlyDenied;
                                            if (await Permission.camera.request().isGranted) {
                                              status = await Permission.camera.status;
                                            } else if (result) {
                                              await openAppSettings();
                                            }
                                            Get.back();
                                          },
                                        ),
                                        CupertinoDialogAction(
                                          child: const Text("No"),
                                          onPressed: () => Get.back(),
                                        )
                                      ],
                                    ));
                            return false;
                          }
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => CupertinoAlertDialog(
                                    title: const Text("Activity Access Denied"),
                                    content: const Text("Allow Activity permission to continue"),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        isDefaultAction: true,
                                        child: const Text("Yes"),
                                        onPressed: () async {
                                          await openAppSettings();
                                          Get.back();
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: const Text("No"),
                                        onPressed: () => Get.back(),
                                      )
                                    ],
                                  ));

                          return false;
                          // Get.snackbar(
                          //     'Activity Access Denied', 'Allow Activity permission to continue',
                          //     backgroundColor: Colors.red,
                          //     colorText: Colors.white,
                          //     duration: Duration(seconds: 5),
                          //     isDismissible: false,
                          //     mainButton: TextButton(
                          //         onPressed: () async {
                          //           await openAppSettings();
                          //         },
                          //         child: Text('Allow')));
                        }
                      },
                      cardName: 'Hpod Login',
                      image: 'newAssets/Icons/Hpod Login.png',
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    SmallCard(
                      onTap: () {
                        PercentageCalculations().calculatePercentageFilled() != 100
                            ? Get.to(ProfileCompletionScreen())
                            : Get.to(const SettingsScreen());
                        // Get.to(ProfileSettingScreen());
                      },
                      cardName: 'Settings',
                      image: 'newAssets/Icons/Settings.png',
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    SmallCard(
                      onTap: () {
                        // Get.to(const About());
                        Get.to(const AboutIhl());
                      },
                      cardName: 'About India Health Link',
                      image: 'newAssets/Icons/About.png',
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    SmallCard(
                      onTap: () async {
                        // await clear();
                        Get.to(const LogoutScreen());
                      },
                      cardName: 'Logout',
                      image: 'newAssets/Icons/Logout.png',
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              // SizedBox(
              //   height: 13,
              // ),
              // SmallCard(
              //   cardName: 'My Badges',
              //   image: 'newAssets/Icons/My Badges.png',
              // ),

              Center(
                child: Text('Version $version'),
              ),
              SizedBox(
                height: 11.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //Removing the last selected affiliation data while signout🥚
    UpdatingColorsBasedOnAffiliations.ssoAffiliation = null;
    prefs.remove("sso_flow_affiliation");
    log("SSO account tap details removed");
    try {
      await localSotrage.write(LSKeys.ihlUserId, '');
      localSotrage.save();
      print(localSotrage.read(LSKeys.ihlUserId));
      Get.find<UpcomingDetailsController>().onClose();
      SpUtil.remove(LSKeys.userDetail);
      await localSotrage.erase();
      SpUtil.clear();

      try {
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
    Get.offAll(const LoginEmailScreen());
  }

  Future<void> _deleteCacheDir() async {
    final Directory cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  Future<void> _deleteAppDir() async {
    final Directory appDir = await getApplicationSupportDirectory();

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

  void showAlert(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              content: Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.lightBlue.shade300, Colors.blue.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // SharedPreferences prefs = await SharedPreferences.getInstance();
                        // prefs.setBool("firstTime", false);
                        Get.back();
                      },
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Stack(
                      children: [
                        Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.width / 1.8,
                            width: MediaQuery.of(context).size.width / 1.8,
                            child: Image.asset(
                              "assets/images/IHL_QR.png",
                              height: MediaQuery.of(context).size.width / 2.4,
                              width: MediaQuery.of(context).size.width / 2.4,
                            )),
                        // Image.asset(
                        //   "assets/images/badgeParticle.png",
                        //   height: MediaQuery.of(context).size.width / 1.8,
                        //   width: MediaQuery.of(context).size.width / 1.8,
                        // ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "> Select the vitals from Hpod. \n>Proceed by tapping on the Start Button.\n> Choose QR Code login option.\n> Scan the QR.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool("firstTime", false);
                        Get.back();
                        Get.to(const QRScannerScreen());
                      },
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(250),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}
