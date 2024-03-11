import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health/health.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/health_challenge/controllers/challenge_api.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/health_challenge/models/join_individual.dart';
import 'package:ihl/health_challenge/persistent/PersistenGetxController/PersistentGetxController.dart';
import 'package:ihl/health_challenge/views/join_or_create_group_challenge_screen.dart';
import 'package:ihl/health_challenge/views/on_going_challenge.dart';
import 'package:ihl/new_design/presentation/bindings/initialControllerBindings.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:jiffy/jiffy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Getx/controller/listOfChallengeContoller.dart';
import 'dynamicJoinorCreateGroupChallenge.dart';

// ignore: must_be_immutable
class DynamicChallengeNickName extends StatefulWidget {
  DynamicChallengeNickName({Key key, @required this.challengeDetail}) : super(key: key);
  ChallengeDetail challengeDetail;

  @override
  State<DynamicChallengeNickName> createState() => _DynamicChallengeNickNameState();
}

class _DynamicChallengeNickNameState extends State<DynamicChallengeNickName> {
  @override
  void initState() {
    _sharedpref();
    super.initState();
  }

  SharedPreferences prefs;

  final HealthFactory health = HealthFactory();
  final _formKey = GlobalKey<FormState>();
  var k;
  String department;
  String designation, id, gender, city, email;
  bool depValuesOrNull = false;
  bool isglobal = false;
  bool _logedSso = false;
  bool fitImplemented = false;
  bool fitInstalled = false;
  final box = GetStorage();

  //City list
  String _currentSelectedCity;
  List _cityList = [
    "Chennai",
    "Bangalore",
    "Mumbai",
    "Goa",
    "Pondicherry",
    "Coiambatore",
    "Cuddalore",
  ];
  bool dropDownError = false;

  _sharedpref() async {
    _cityList.clear();
    if (widget.challengeDetail.challenge_start_location_list != null &&
        !widget.challengeDetail.challenge_start_location_list.contains('null')) {
      _cityList = widget.challengeDetail.challenge_start_location_list;
    } else {
      _currentSelectedCity = '';
      _cityList = [];
    }
    prefs = await SharedPreferences.getInstance();
    if (Platform.isAndroid) {
      fitInstalled =
          await LaunchApp.isAppInstalled(androidPackageName: "com.google.android.apps.fitness");
      fitImplemented = box.read("fit") ?? false;
    } else if (Platform.isIOS) {
      fitInstalled = true;
      fitImplemented = true;
    }
    setState(() {
      k = jsonDecode(prefs.getString(SPKeys.jUserData));
      id = k["User"]["id"];
      gender = k["User"]["gender"].toLowerCase() == "m" ? "Male" : "Female";
      city = k["User"]["city"] ?? "N/A";
      // _currentSelectedCity = k["User"]["city"];
      email = k['User']['email'];
      String name = k["User"]["firstName"] + " " + k["User"]["lastName"];
      _DynamicChallengeNickName.text = name.toString();
      if (k["User"].containsKey("user_job_details")) {
        if (k["User"]["user_job_details"]["department"] != "" &&
            k["User"]["user_job_details"]["department"] != null) {
          department = k["User"]["user_job_details"]["department"];
          designation = k["User"]["user_job_details"]["jobTitle"];
          depValuesOrNull = false;
        } else {
          depValuesOrNull = true;
        }
      } else {
        depValuesOrNull = true;
      }
      var _prefValue = prefs.get(
        SPKeys.is_sso,
      );
      _logedSso = _prefValue == 'true' ? true : false;
      // ignore: missing_return
      widget.challengeDetail.affiliations.where((element) {
        if (element.toLowerCase() == "global") {
          isglobal = true;
        } else {
          return null;
        }
      });
    });
  }

  TextEditingController _DynamicChallengeNickName = TextEditingController();
  TextEditingController _city = TextEditingController();
  TextEditingController _department = TextEditingController();
  TextEditingController _designation = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.backgroundScreenColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Nick Name",
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: width / 4,
            ),
            Container(
              height: width / 2.5,
              width: width / 2.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(250),
                boxShadow: [
                  const BoxShadow(offset: Offset(1, 1), color: Colors.grey, blurRadius: 6)
                ],
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(widget.challengeDetail.challengeImgUrl),
                ),
              ),
            ),
            SizedBox(
              height: width / 4,
            ),
            Padding(
              padding: EdgeInsets.all(15.0.sp),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nick Name',
                      style: TextStyle(color: AppColors.primaryColor, fontSize: 18.sp),
                    ),
                  ),
                  SizedBox(
                    height: 15.px,
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                            return "Please provide your full name.";
                        } else {
                          return null;
                        }
                      },
                      controller: _DynamicChallengeNickName,
                      keyboardType: TextInputType.name,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z -]"))],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        suffixIcon: Icon(
                          Icons.edit,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.px,
                  ),
                  Visibility(
                    // visible: city == null || city == "",
                    visible: !widget.challengeDetail.challenge_start_location_list.contains('null'),
                    child: Column(children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Location',
                          style: TextStyle(color: AppColors.primaryColor, fontSize: 18.sp),
                        ),
                      ),
                      SizedBox(
                        height: 8.px,
                      ),
                      FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                                errorStyle:
                                    const TextStyle(color: Colors.redAccent, fontSize: 16.0),
                                hintText: 'Select Location',
                                border:
                                    OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                            isEmpty: _currentSelectedCity == '' || _currentSelectedCity == null,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _currentSelectedCity,
                                isDense: true,
                                onChanged: (String newValue) {
                                  setState(() {
                                    _currentSelectedCity = newValue;
                                    state.didChange(newValue);
                                  });
                                },
                                items: _cityList.map((value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                      dropDownError
                          ? const Text(
                              "Select City",
                              style: TextStyle(color: Colors.red),
                            )
                          : Container(),
                      // Material(
                      //   elevation: 2,
                      //   child: TextFormField(
                      //     validator: (value) {
                      //       if (value.isEmpty) {
                      //         return "Please Enter Your City";
                      //       } else {
                      //         return null;
                      //       }
                      //     },
                      //     controller: _city,
                      //     keyboardType: TextInputType.name,
                      //     inputFormatters: [
                      //       FilteringTextInputFormatter.allow(RegExp("[a-zA-Z -]"))
                      //     ],
                      //     decoration: InputDecoration(
                      //       hintText: "Ex: Chennai",
                      //       suffixIcon: Icon(
                      //         Icons.location_on,
                      //         color: Colors.black45,
                      //       ),
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.all(Radius.circular(3)),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: 15.px,
                      ),
                    ]),
                  ),
                  // Visibility(
                  //   // visible: !widget.challengeDetail.affiliations
                  //   //         .contains("global") ||
                  //   //     (_logedSso && depValuesOrNull),
                  //   visible: false,
                  //   child: Column(
                  //     children: [
                  //       SizedBox(
                  //         height: 15.px,
                  //       ),
                  //       Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text(
                  //           'Department',
                  //           style: TextStyle(
                  //               color: AppColors.primaryColor,
                  //               fontSize: 18.sp),
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         height: 8.px,
                  //       ),
                  //       Material(
                  //         elevation: 2,
                  //         child: TextFormField(
                  //           autovalidateMode:
                  //               AutovalidateMode.onUserInteraction,
                  //           validator: (value) {
                  //             if (value.isEmpty) {
                  //               return "Please Enter Your DynamicChallengeNickName";
                  //             } else {
                  //               return null;
                  //             }
                  //           },
                  //           controller: _department,
                  //           keyboardType: TextInputType.name,
                  //           inputFormatters: [
                  //             FilteringTextInputFormatter.allow(
                  //                 RegExp("[a-zA-Z -]"))
                  //           ],
                  //           decoration: InputDecoration(
                  //             hintText: "Ex: IT ",
                  //             suffixIcon: Icon(
                  //               FontAwesomeIcons.building,
                  //               color: Colors.black45,
                  //             ),
                  //             border: OutlineInputBorder(
                  //               borderRadius: BorderRadius.all(
                  //                   Radius.circular(3)),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         height: 15.px,
                  //       ),
                  //       // Align(
                  //       //   alignment: Alignment.centerLeft,
                  //       //   child: Text(
                  //       //     'Designation',
                  //       //     style: TextStyle(
                  //       //         color: AppColors.primaryColor,
                  //       //         fontSize: 18.sp),
                  //       //   ),
                  //       // ),
                  //       // SizedBox(
                  //       //   height: 8.px,
                  //       // ),
                  //       // Material(
                  //       //   elevation: 2,
                  //       //   child: TextFormField(
                  //       //     autovalidateMode:
                  //       //         AutovalidateMode.onUserInteraction,
                  //       //     validator: (value) {
                  //       //       if (value.isEmpty) {
                  //       //         checkUser(
                  //       //             name: value.toString(),
                  //       //             userUid: id.toString());
                  //       //         return "Please Enter Your DynamicChallengeNickName";
                  //       //       } else {
                  //       //         return null;
                  //       //       }
                  //       //     },
                  //       //     controller: _designation,
                  //       //     keyboardType: TextInputType.name,
                  //       //     inputFormatters: [
                  //       //       FilteringTextInputFormatter.allow(
                  //       //           RegExp("[a-zA-Z -]"))
                  //       //     ],
                  //       //     decoration: InputDecoration(
                  //       //       hintText: "Ex: Project Manager ",
                  //       //       suffixIcon: Icon(
                  //       //         Icons.room,
                  //       //         color: Colors.black45,
                  //       //       ),
                  //       //       border: OutlineInputBorder(
                  //       //         borderRadius: BorderRadius.all(
                  //       //             Radius.circular(3)),
                  //       //       ),
                  //       //     ),
                  //       //   ),
                  //       // ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(
                    height: 20.px,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        if (await checkUser(
                            name: _DynamicChallengeNickName.text,
                            challengeID: widget.challengeDetail.challengeId)) {
                          UserDetails userDetails = UserDetails(
                              userStartLocation: _currentSelectedCity.toString(),
                              selected_fitness_app: 'google fit',
                              userId: id,
                              name: _DynamicChallengeNickName.text,
                              city: city ?? _city.text.trim(),
                              gender: gender,
                              department: depValuesOrNull ? _department.text : department,
                              designation: depValuesOrNull ? _designation.text : designation,
                              email: email,
                              isGloble: widget.challengeDetail.affiliations.contains("global") ||
                                  widget.challengeDetail.affiliations.contains("Global"));
                          SharedPreferences prefs = await SharedPreferences.getInstance();

                          prefs.setString("jobDetails", jsonEncode(userDetails.toJson()));
                          // Get.to(OnGoingChallenge(
                          //   challengeDetail: widget.challengeDetail,
                          //   navigatedNormal: false,
                          // )
                          Get.to(
                            DynamicJoinOrCreateGroupChallenge(
                              challengeDetail: widget.challengeDetail,
                            ),
                          );
                        } else {
                          Get.defaultDialog(
                              barrierDismissible: false,
                              backgroundColor: Colors.lightBlue.shade50,
                              title: 'Name already used',
                              titlePadding:
                                  EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
                              titleStyle: TextStyle(
                                  letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                              contentPadding: EdgeInsets.only(top: 0),
                              content: Column(
                                children: [
                                  // Divider(
                                  //   thickness: 2,
                                  // ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width / 4,
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Ok',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ));
                        }
                      }
                      // TODO No need following code for dynamic challenge
                      /*  if (_formKey.currentState.validate() &&
                          _currentSelectedCity != null) {
                        dropDownError = false;
                        var permission = await PermissionHandlerUtil.hasPermissionOrRequest(
                            Platform.isAndroid
                                ? await Permission.activityRecognition
                                : await Permission.sensors);
                        if (permission) {
                          if (Platform.isIOS) {
                            await Permission.sensors.request();
                          }
                          UserDetails userDetails = UserDetails(
                              userStartLocation: _currentSelectedCity.toString(),
                              selected_fitness_app: 'google fit',
                              userId: id,
                              name: _DynamicChallengeNickName.text,
                              city: city ?? _city.text.trim(),
                              gender: gender,
                              department: depValuesOrNull ? _department.text : department,
                              designation:
                                  depValuesOrNull ? _designation.text : designation,
                              email: email,
                              isGloble: widget.challengeDetail.affiliations
                                      .contains("global") ||
                                  widget.challengeDetail.affiliations.contains("Global"));
                          if (Get.find<ListChallengeController>()
                                      .affiliateCmpnyList
                                      .contains("persistent") &&
                                  widget.challengeDetail.affiliations
                                      .contains("persistent") &&
                                  widget.challengeDetail.challengeMode == "individual" ||
                              Get.find<ListChallengeController>().persistentInvite &&
                                  widget.challengeDetail.challengeMode == "individual") {
                            try {
                              gs.write(GSKeys.challengeDetail, widget.challengeDetail);
                              gs.write(GSKeys.userDetail, userDetails);
                              CustomDialog().googleFitDia();
                            } catch (e) {
                              log('GetStorage Error');
                            }
                          } else if (await checkUser(
                                  name: _DynamicChallengeNickName.text,
                                  challengeID: widget.challengeDetail.challengeId) ||
                              widget.challengeDetail.challengeMode.toLowerCase() ==
                                  "individual") {
                            if (widget.challengeDetail.challengeMode == "individual") {
                              if (!fitImplemented &&
                                  widget.challengeDetail.challengeType ==
                                      "Step Challenge") {
                                dialogBox().then((value) async {
                                  if (fitImplemented) {
                                    bool individualJoined = false;
                                    individualJoined = await ChallengeApi()
                                        .userJoinIndividual(
                                            joinIndividual: JoinIndividual(
                                                challengeId:
                                                    widget.challengeDetail.challengeId,
                                                userDetails: userDetails));
                                    if (individualJoined) {
                                      if (DateTime.now().isAfter(
                                          widget.challengeDetail.challengeStartTime)) {
                                        getdef(showD: 1);
                                      } else {
                                        getdef(showD: 2);
                                      }
                                    }
                                  }
                                });
                              } else {
                                // dialogBox();
                                bool individualJoined = false;
                                individualJoined = await ChallengeApi().userJoinIndividual(
                                    joinIndividual: JoinIndividual(
                                        challengeId: widget.challengeDetail.challengeId,
                                        userDetails: userDetails));
                                if (individualJoined) {
                                  if (DateTime.now()
                                      .isAfter(widget.challengeDetail.challengeStartTime)) {
                                    getdef(showD: 1);
                                  } else {
                                    getdef(showD: 2);
                                  }
                                }
                              }
                            } else {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();

                              prefs.setString(
                                  "jobDetails", jsonEncode(userDetails.toJson()));
                              // Get.to(OnGoingChallenge(
                              //   challengeDetail: widget.challengeDetail,
                              //   navigatedNormal: false,
                              // )
                              Get.to(
                                JoinOrCreateGroupChallenge(
                                  challengeDetail: widget.challengeDetail,
                                ),
                              );
                            }
                          } else {
                            Get.defaultDialog(
                                barrierDismissible: false,
                                backgroundColor: Colors.lightBlue.shade50,
                                title: 'Name already used',
                                titlePadding: EdgeInsets.only(
                                    top: 20, bottom: 0, left: 10, right: 10),
                                titleStyle: TextStyle(
                                    letterSpacing: 1,
                                    color: Colors.blue.shade400,
                                    fontSize: 20),
                                contentPadding: EdgeInsets.only(top: 0),
                                content: Column(
                                  children: [
                                    // Divider(
                                    //   thickness: 2,
                                    // ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width / 4,
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(20)),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Ok',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ));
                          }
                        } else {
                          if (Platform.isIOS) {
                            await Permission.sensors.request();
                          }
                          Get.snackbar(
                            'Permission Denied',
                            'Enable Activity Permission',
                          );
                          await openAppSettings();
                        }
                      }*/
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        primary: Colors.lightBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    child: const Text('Join'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> checkUser({String challengeID, name}) async {
    var user = await ChallengeApi().challengeUserNameCheck(name: name, challangeId: challengeID);
    if (user["status"] == "name never use") {
      return true;
    } else {
      return false;
    }
  }

  Future<Widget> dialogBox() {
    return fitImplemented && fitInstalled
        ? Container()
        : Get.defaultDialog(
            title: "",
            titlePadding: const EdgeInsets.only(),
            // barrierDismissible: false,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 50,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 25,
                          backgroundImage: AssetImage("assets/icons/googlefit.png"),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        "Google Fit",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.blueGrey,
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
                      bool t = await LaunchApp.isAppInstalled(
                          androidPackageName: "com.google.android.apps.fitness");
                      // t
                      //     ? Container()
                      //     : await LaunchApp.openApp(
                      //         openStore: true, androidPackageName: "com.google.android.apps.fitness");

                      final types = [
                        HealthDataType.STEPS,
                        HealthDataType.ACTIVE_ENERGY_BURNED,
                        HealthDataType.DISTANCE_DELTA,
                        HealthDataType.MOVE_MINUTES,
                      ];

                      final permissions = [
                        HealthDataAccess.READ,
                        HealthDataAccess.READ,
                        HealthDataAccess.READ,
                        HealthDataAccess.READ,
                      ];

                      if (t) {
                        try {
                          GoogleSignIn _googleSignIn = GoogleSignIn(
                            scopes: [
                              'email',
                              'https://www.googleapis.com/auth/contacts.readonly',
                            ],
                          );
                          await _googleSignIn.signOut();
                          bool _authenticate =
                              await health.requestAuthorization(types, permissions: permissions);
                          if (_authenticate) {
                            prefs.setBool("fit", _authenticate);
                            box.write("fit", _authenticate);
                            fitImplemented = _authenticate;
                            Get.back();
                            Get.snackbar('Success', 'Connected Successfully',
                                margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                backgroundColor: AppColors.primaryAccentColor,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 5),
                                snackPosition: SnackPosition.BOTTOM);
                          } else {
                            prefs.setBool("fit", _authenticate);
                            box.write("fit", _authenticate);
                            fitImplemented = _authenticate;
                            Get.back();
                            Get.snackbar('Connection Error', 'Unable to connect to Google Fit.',
                                margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                backgroundColor: AppColors.failure,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 5),
                                snackPosition: SnackPosition.BOTTOM);
                          }
                        } catch (e) {}
                      } else {
                        await LaunchApp.openApp(
                            openStore: true, androidPackageName: "com.google.android.apps.fitness");
                      }
                    },
                    child: const Text('Connect to Google Fit'),
                    style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  ),
                )
              ],
            ),
          );
  }

  getdef({int showD}) {
    if (showD == 1)
      Get.defaultDialog(
          barrierDismissible: false,
          backgroundColor: Colors.lightBlue.shade50,
          title: 'Welcome aboard!',
          titlePadding: const EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
          titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
          contentPadding: const EdgeInsets.only(top: 0),
          content: Column(
            children: [
              const Divider(
                thickness: 2,
              ),
              Icon(
                Icons.task_alt,
                size: 50,
                color: Colors.blue.shade300,
              ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () async {
                  List<EnrolledChallenge> enList =
                      await ChallengeApi().listofUserEnrolledChallenges(userId: id);
                  Get.find<ListChallengeController>().enrolledChallenegeList = enList;
                  enList.retainWhere(
                      (element) => element.challengeId == widget.challengeDetail.challengeId);

                  Get.off(
                      OnGoingChallenge(
                          groupDetail: null,
                          filteredList: enList.first,
                          navigatedNormal: false,
                          challengeDetail: widget.challengeDetail),
                      binding: BindingsBuilder(() => Get.put(PersistentGetXController())));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 4,
                  decoration:
                      BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Ok',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ));

    if (showD == 2)
      Get.defaultDialog(
          barrierDismissible: false,
          backgroundColor: Colors.lightBlue.shade50,
          title: 'Welcome aboard!',
          titlePadding: const EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
          titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
          contentPadding: const EdgeInsets.only(top: 0),
          content: Column(
            children: [
              const Divider(
                thickness: 2,
              ),
              Icon(
                Icons.task_alt,
                size: 50,
                color: Colors.blue.shade300,
              ),
              const SizedBox(
                height: 15,
              ),
              Get.find<ListChallengeController>().affiliateCmpnyList.contains("persistent") &&
                      widget.challengeDetail.affiliations.contains("persistent") &&
                      widget.challengeDetail.challengeMode == "individual"
                  ? Text(
                      "Run will be active from ${Jiffy(widget.challengeDetail.challengeStartTime).format("do MMM yyyy")}",
                      textAlign: TextAlign.center,
                      style: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                    )
                  : Text(
                      "Challenge will be active from ${Jiffy(widget.challengeDetail.challengeStartTime).format("do MMM yyyy")}",
                      textAlign: TextAlign.center,
                      style: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                    ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  Get.off(LandingPage(), binding: InitialBindings());
                  // Get.offAll(HomeScreen(introDone: true),
                  //     transition: Transition.size);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 4,
                  decoration:
                      BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Ok',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ));
  }
}
