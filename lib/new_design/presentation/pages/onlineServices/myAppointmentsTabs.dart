import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectanum/connectanum.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/invoice.dart';
import '../../../../repositories/api_consult.dart';
import '../../../../views/view_past_bill/view_only_bill.dart';
import '../../../../widgets/teleconsulation/appointmentTile.dart';
import '../../../jitsi/genix_signal.dart';
import '../../../jitsi/genix_web_view_call.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_apiCalls.dart';
import '../home/landingPage.dart';
import 'MyMedicalFiles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../clippath/subscriptionTagClipPath.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

// import '../../../../constants/api.dart';
import '../../../app/utils/appColors.dart';
import '../../../data/model/TeleconsultationModels/appointmentModels.dart';
import '../../../data/providers/network/api_provider.dart';
import '../../Widgets/teleconsultation_widgets/teleconsultation_widget_onlineServies.dart';
import '../dashboard/common_screen_for_navigation.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../teleconsultation/wait_for_consultant_screen.dart';

import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class MyAppointmentsTabs extends StatefulWidget {
  MyAppointmentsTabs({Key key, this.fromCall}) : super(key: key);
  bool fromCall = false;

  @override
  State<MyAppointmentsTabs> createState() => _MyAppointmentsTabsState();
}

class _MyAppointmentsTabsState extends State<MyAppointmentsTabs> {
  ValueNotifier<String> selectedType = ValueNotifier<String>("");

  final TextEditingController reasonController = TextEditingController();
  bool makeValidateVisible = false;
  bool autoValidate = false;
  List<CompletedAppointment> expiredAppointment = [];

  // List<CompletedAppointment> appointmentList = <CompletedAppointment>[];
  List<CompletedAppointment> tempShimmerList =
      List<CompletedAppointment>.generate(7, (int index) => CompletedAppointment());
  List<CompletedAppointment> tempShimmerAppointmentList =
      List<CompletedAppointment>.generate(7, (int index) => CompletedAppointment());
  bool showShimmer = false;
  bool showAppointmentShimmer = false;
  List<CompletedAppointment> appointmentLists = <CompletedAppointment>[];

  List<CompletedAppointment> get getAppointmentsList => appointmentLists;

  static ValueNotifier<List<CompletedAppointment>> approvedAndUpcomingList =
      ValueNotifier<List<CompletedAppointment>>(<CompletedAppointment>[]);

  // ignore: always_specify_types
  List gettedResponse = [];
  var appointmentStartingTime;
  ValueNotifier<bool> enableJoinCall = ValueNotifier<bool>(false);
  String selectedRadioValue = 'Option 1';
  bool isRadioSelected = false;
  int ind = 0;

  // Create a list of radio options.
  List<String> radioOptions = <String>[
    'Option 1',
    'Option 2',
    'Option 3',
  ];

  // Create a function to handle radio button selection.
  void handleRadioValueChange(String value) {
    setState(() {
      selectedRadioValue = value;
    });
  }

  @override
  void initState() {
    print(approvedAndUpcomingList.value);
    selectedType.value = appointmentTypes.first;
    asyncfunc(); //update();
    super.initState();
  }

  asyncfunc() async {
    showShimmer = true;
    showAppointmentShimmer = true;
    Future<void>.delayed(
        Duration.zero, () => approvedAndUpcomingList.value = <CompletedAppointment>[]);
    List<CompletedAppointment> gettedResponse =
        await TeleConsultationFunctionsAndVariables.appointmentList(
            startIndex: 0, endIndex: 510, type: "Requested");
    // expiredAppointment
    //     .addAll(TeleConsultationFunctionsAndVariables.expiredListFilter(gettedResponse));
    // type = "Requested";
    // if (type == "Requested") {
    // List<CompletedAppointment> rs = await TeleConsultationFunctionsAndVariables.appointmentList(
    //     startIndex: 0, endIndex: 510, type: "Approved");
    // expiredAppointment.addAll(TeleConsultationFunctionsAndVariables.expiredListFilter(rs));

    List<CompletedAppointment> gettedResponse2 =
        await TeleConsultationFunctionsAndVariables.appointmentList(
            startIndex: 0, endIndex: 510, type: "Missed");

    gettedResponse += gettedResponse2;
    expiredAppointment
        .addAll(TeleConsultationFunctionsAndVariables.expiredListFilter(gettedResponse2));
    // gettedResponse += rs;
    gettedResponse.sort((CompletedAppointment a, CompletedAppointment b) =>
        b.appointmentStartTime.compareTo(a.appointmentStartTime));
    if (selectedType.value == "Upcoming") {
      approvedAndUpcomingList.value = gettedResponse;
      appointmentLists = gettedResponse;
    }
    // } else {

    // }
    showShimmer = false;
    showAppointmentShimmer = false;
    selectedType.notifyListeners();
  }

  String type = "Requested";
  List<String> appointmentTypes = <String>['Upcoming', 'Completed', 'Canceled'];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        if (widget.fromCall ?? false) {
          Get.offAll(LandingPage());
        } else {
          Get.back();
        }
      },
      child: CommonScreenForNavigation(
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            centerTitle: true,
            title: const Text("My Appointments", style: TextStyle(color: Colors.white)),
            leading: InkWell(
              onTap: () {
                if (widget.fromCall ?? false) {
                  Get.offAll(LandingPage());
                } else {
                  Get.back();
                }
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
          ),
          content: Container(
            color: Colors.white,
            width: 100.w,
            height: 100.h,
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                ValueListenableBuilder<String>(
                    valueListenable: selectedType,
                    builder: (BuildContext ctz, String value, Widget wid) {
                      return Column(
                        children: <Widget>[
                          Row(
                            children: appointmentTypes.map((String e) {
                              return InkWell(
                                onTap: () async {
                                  showShimmer = true;
                                  showAppointmentShimmer = true;
                                  selectedType.value = e;
                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  selectedType.notifyListeners();
                                  type = e == "Upcoming" ? "Requested" : e;
                                  List<CompletedAppointment> gettedResponse =
                                      await TeleConsultationFunctionsAndVariables.appointmentList(
                                          startIndex: 0, endIndex: 250, type: type);
                                  gettedResponse.sort(
                                      (CompletedAppointment a, CompletedAppointment b) =>
                                          b.appointmentStartTime.compareTo(a.appointmentStartTime));
                                  approvedAndUpcomingList.value = gettedResponse;
                                  appointmentLists = gettedResponse;
                                  if (selectedType.value == 'Canceled') {
                                    appointmentLists = expiredAppointment + gettedResponse;
                                    appointmentLists.sort((CompletedAppointment a,
                                            CompletedAppointment b) =>
                                        b.appointmentStartTime.compareTo(a.appointmentStartTime));
                                    appointmentLists = appointmentLists.toSet().toList();
                                  }
                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  selectedType.notifyListeners();
                                  showShimmer = false;
                                  showAppointmentShimmer = false;
                                },
                                child: TeleConsultationWidgetsOnlineSevices.appointmenttabbar(
                                    title: e, selectedTile: value),
                              );
                            }).toList(),
                          ),
                          if (showShimmer && selectedType.value != "Upcoming")
                            ...tempShimmerList
                                .map((CompletedAppointment e) => Shimmer.fromColors(
                                    direction: ShimmerDirection.ltr,
                                    period: const Duration(seconds: 2),
                                    baseColor: const Color.fromARGB(255, 240, 240, 240),
                                    highlightColor: Colors.grey.withOpacity(0.2),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 10.h,
                                        width: 90.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                offset: const Offset(0, 0),
                                                blurRadius: 3,
                                                spreadRadius: 3,
                                                color: Colors.grey.shade200)
                                          ],
                                          color: Colors.white,
                                        ),
                                      ),
                                    )))
                                .toList(),
                          if (showAppointmentShimmer && selectedType.value == "Upcoming")
                            ...tempShimmerAppointmentList
                                .map((CompletedAppointment e) => SizedBox(
                                      width: 7 < 2 ? 95.w : null,
                                      child: Wrap(
                                          alignment: WrapAlignment.start,
                                          runSpacing: 1.w,
                                          spacing: 2.w,
                                          children: tempShimmerAppointmentList
                                              .map((CompletedAppointment e) {
                                            e = e ?? CompletedAppointment();
                                            return SizedBox(
                                              width: 45.w, // Adjust the width as needed
                                              height: 32.h, // Adjust the height as needed
                                              child: Card(
                                                elevation: 4,
                                                child: Row(
                                                  children: [
                                                    skeleton(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 5.h,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.center,
                                                            children: [
                                                              SizedBox(
                                                                width: 6.w,
                                                              ),
                                                              SizedBox(
                                                                  height: 10.h,
                                                                  width: 34.w,
                                                                  child: FutureBuilder(
                                                                      future: TabBarController()
                                                                          .getConsultantImageUrl(
                                                                              doctor: e.toJson()),
                                                                      builder: (BuildContext
                                                                              context,
                                                                          AsyncSnapshot<String> i) {
                                                                        if (i.connectionState ==
                                                                            ConnectionState.done) {
                                                                          return CircleAvatar(
                                                                            radius: 36.0,
                                                                            backgroundImage:
                                                                                Image.memory(
                                                                              base64Decode(i.data
                                                                                  .toString()),
                                                                              fit: BoxFit.contain,
                                                                            ).image,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                          );
                                                                        } else if (i
                                                                                .connectionState ==
                                                                            ConnectionState
                                                                                .waiting) {
                                                                          return SizedBox(
                                                                            width: 15.w,
                                                                            height: 8.h,
                                                                            child:
                                                                                Shimmer.fromColors(
                                                                              baseColor:
                                                                                  Colors.white,
                                                                              highlightColor: Colors
                                                                                  .grey
                                                                                  .withOpacity(0.3),
                                                                              direction:
                                                                                  ShimmerDirection
                                                                                      .ltr,
                                                                              child: Container(
                                                                                width: 15.w,
                                                                                height: 6.h,
                                                                                decoration:
                                                                                    const BoxDecoration(
                                                                                  shape: BoxShape
                                                                                      .circle,
                                                                                  color: Colors.red,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        } else {
                                                                          return Container();
                                                                        }
                                                                      })),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 6.h,
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              SizedBox(
                                                                width: 3.w,
                                                              ),
                                                              Container(
                                                                height: 2.h,
                                                                width: 25.w,
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(5),
                                                                  boxShadow: <BoxShadow>[
                                                                    BoxShadow(
                                                                        offset: const Offset(0, 0),
                                                                        blurRadius: 3,
                                                                        spreadRadius: 3,
                                                                        color: Colors.grey.shade200)
                                                                  ],
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 1.h,
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              SizedBox(
                                                                width: 3.w,
                                                              ),
                                                              Container(
                                                                height: 2.h,
                                                                width: 25.w,
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(5),
                                                                  boxShadow: <BoxShadow>[
                                                                    BoxShadow(
                                                                        offset: const Offset(0, 0),
                                                                        blurRadius: 3,
                                                                        spreadRadius: 3,
                                                                        color: Colors.grey.shade200)
                                                                  ],
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList()),
                                    ))
                                .toList(),
                          if (showShimmer == false && selectedType.value != "Upcoming")
                            ...appointmentLists
                                .map((CompletedAppointment e) =>
                                    TeleConsultationWidgetsOnlineSevices.completedAndCancelled(
                                        appointment: e,
                                        refundOntap: () {
                                          showDia(e: e);
                                        }))
                                .toList(),
                          if (showShimmer == false && selectedType.value == "Upcoming")
                            ValueListenableBuilder<dynamic>(
                                valueListenable: approvedAndUpcomingList,
                                builder: (BuildContext context, dynamic e, Widget child) {
                                  return SizedBox(
                                    width: approvedAndUpcomingList.value.length < 2 ? 95.w : null,
                                    child: Wrap(
                                        alignment: WrapAlignment.start,
                                        runSpacing: 1.w,
                                        spacing: 2.w,
                                        children: approvedAndUpcomingList.value
                                            .map((CompletedAppointment e) {
                                          return AppointmentTileWidget(
                                              e,
                                              callButton(e.ihlConsultantId, e.appointmentId,
                                                  e.appointmentStartTime, e.appointmentStatus, e));
                                        }).toList()),
                                  );
                                }),
                          if (showShimmer == false &&
                              selectedType.value != "Upcoming" &&
                              appointmentLists.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 3.h),
                              child: const Text("No Data Found !"),
                            ),
                          if (showShimmer == false &&
                              selectedType.value == "Upcoming" &&
                              approvedAndUpcomingList.value.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 3.h),
                              child: const Text("Currently No Appointments !"),
                            ),
                          SizedBox(height: 11.h)
                        ],
                      );
                    }),
              ]),
            ),
          )),
    );
  }

  showDia({CompletedAppointment e}) {
    List reasons = [
      "Consultant didn't joined the call",
      "You were facing technical issue",
      "You didn't joined the call",
      "Consultant was facing technical issue"
    ];
    bool isChecking = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String reasonRadioBtnVal = "";
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
              insetPadding: EdgeInsets.all(15.sp),
              title: Text(
                'Provide the reason for Refund!',
                style: TextStyle(
                    color: AppColors.primaryColor, fontSize: 16.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              contentPadding: EdgeInsets.zero,
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Column(
                            children: <Widget>[
                              ...reasons
                                  .map((reason) => RadioListTile<String>(
                                      title: Text(
                                        reason,
                                        style: TextStyle(fontSize: 16.sp),
                                      ),
                                      value: reason,
                                      groupValue: reasonRadioBtnVal,
                                      onChanged: (String value) {
                                        if (mounted) {
                                          setState(() {
                                            reasonRadioBtnVal = value;
                                          });
                                        }
                                      }))
                                  .toList(),
                              SizedBox(
                                height: 3.h,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: TextFormField(
                                  controller: reasonController,
                                  validator: (String value) {
                                    if (value.isEmpty) {
                                      return 'Please provide the reason!';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                                    labelText: "Other reason",
                                    fillColor: Colors.white24,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                        borderSide: const BorderSide(color: Colors.blueGrey)),
                                  ),
                                  maxLines: 1,
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                            ],
                          ),
                          Visibility(
                            visible: makeValidateVisible ? true : false,
                            child: const Text(
                              "Please select the reason!",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          SizedBox(
                            height: 2.5.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  minimumSize: Size(30.w, 4.h),
                                  backgroundColor: AppColors.primaryAccentColor,
                                  textStyle:
                                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                                ),
                                onPressed: isChecking == true
                                    ? null
                                    : () {
                                        Navigator.pop(context);
                                      },
                                child: Text(
                                  'GO BACK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Poppins",
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  minimumSize: Size(30.w, 4.h),
                                  backgroundColor: AppColors.primaryAccentColor,
                                  textStyle:
                                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                                ),
                                onPressed: isChecking == true
                                    ? null
                                    : () async {
                                        if (reasonRadioBtnVal.isNotEmpty ||
                                            reasonController.text.isNotEmpty) {
                                          if (mounted) {
                                            setState(() {
                                              isChecking = true;
                                              makeValidateVisible = false;
                                            });
                                          }
                                          try {
                                            await TeleConsultationApiCalls.cancelAppointment(
                                                appointmentId: e.appointmentId,
                                                by: 'user',
                                                reason: reasonRadioBtnVal);
                                            int appointmentIndex = appointmentLists.indexOf(e);
                                            appointmentLists[appointmentIndex].isExpired = false;
                                            isChecking = false;
                                            TeleConsultationApiCalls.currentAppointmentStatusUpdate(
                                                e.appointmentId, "Canceled");
                                            SharedPreferences prefs =
                                                await SharedPreferences.getInstance();

                                            Object data = prefs.get('data');
                                            Map res = jsonDecode(data);
                                            var iHLUserId = res['User']['id'];

                                            List<String> receiverIds = <String>[];
                                            receiverIds.add(e.ihlConsultantId.toString());
                                            Map q = {};
                                            Map x = {};
                                            x['cmd'] = "GenerateNotification";
                                            x['notification_domain'] = "CancelAppointment";
                                            x['appointment_id'] = e.appointmentId;
                                            q['sender_id'] = iHLUserId;
                                            q['sender_session_id'] = "1245";
                                            q['receiver_ids'] = receiverIds;
                                            q['data'] = x;
                                            FireStoreCollections.teleconsultationServices
                                                .doc(e.appointmentId)
                                                .set({
                                              "sender_id": iHLUserId,
                                              "receiver_ids": receiverIds,
                                              "data": x
                                            }, SetOptions(merge: false));
                                            setState(() {});
                                            // ignore: use_build_context_synchronously
                                            AwesomeDialog(
                                                    context: context,
                                                    animType: AnimType.TOPSLIDE,
                                                    headerAnimationLoop: true,
                                                    dialogType: DialogType.SUCCES,
                                                    dismissOnTouchOutside: false,
                                                    title: 'Success!',
                                                    desc:
                                                        'Appointment Successfully Cancelled! Your Refund has been Initiated.',
                                                    btnOkOnPress: () => Get.back(),
                                                    btnOkColor: Colors.green,
                                                    btnOkText: 'Proceed',
                                                    btnOkIcon: Icons.check,
                                                    onDismissCallback: (_) {})
                                                .show();
                                          } catch (e) {
                                            setState(() {
                                              isChecking = false;
                                            });
                                            AwesomeDialog(
                                                    context: context,
                                                    animType: AnimType.TOPSLIDE,
                                                    headerAnimationLoop: true,
                                                    dialogType: DialogType.ERROR,
                                                    dismissOnTouchOutside: false,
                                                    title: 'Failed!',
                                                    desc:
                                                        'Appointment Cancellation Unsuccessful. Please Try Again.',
                                                    btnOkOnPress: () => Get.back(),
                                                    btnOkColor: Colors.red,
                                                    btnOkText: 'Proceed',
                                                    btnOkIcon: Icons.refresh,
                                                    onDismissCallback: (_) {})
                                                .show();
                                          }
                                        } else if (reasonController.text.isNotEmpty) {
                                          if (mounted) {
                                            setState(() {
                                              isChecking = true;
                                              makeValidateVisible = false;
                                            });
                                          }
                                          try {
                                            await TeleConsultationApiCalls.cancelAppointment(
                                                appointmentId: e.appointmentId,
                                                by: 'user',
                                                reason: reasonController.text);
                                            int appointmentIndex = appointmentLists.indexOf(e);
                                            appointmentLists[appointmentIndex].isExpired = false;
                                            isChecking = false;
                                            setState(() {});
                                            // ignore: use_build_context_synchronously
                                            AwesomeDialog(
                                                    context: context,
                                                    animType: AnimType.TOPSLIDE,
                                                    headerAnimationLoop: true,
                                                    dialogType: DialogType.SUCCES,
                                                    dismissOnTouchOutside: false,
                                                    title: 'Success!',
                                                    desc:
                                                        'Appointment Successfully Cancelled! Your Refund has been Initiated.',
                                                    btnOkOnPress: () => Get.back(),
                                                    btnOkColor: Colors.green,
                                                    btnOkText: 'Proceed',
                                                    btnOkIcon: Icons.check,
                                                    onDismissCallback: (_) {})
                                                .show();
                                          } catch (e) {
                                            setState(() {
                                              isChecking = false;
                                            });
                                            AwesomeDialog(
                                                    context: context,
                                                    animType: AnimType.TOPSLIDE,
                                                    headerAnimationLoop: true,
                                                    dialogType: DialogType.ERROR,
                                                    dismissOnTouchOutside: false,
                                                    title: 'Failed!',
                                                    desc:
                                                        'Appointment Cancellation Unsuccessful. Please Try Again.',
                                                    btnOkOnPress: () => Get.back(),
                                                    btnOkColor: Colors.red,
                                                    btnOkText: 'Proceed',
                                                    btnOkIcon: Icons.refresh,
                                                    onDismissCallback: (_) {})
                                                .show();
                                          }
                                        } else {
                                          if (mounted) {
                                            setState(() {
                                              makeValidateVisible = true;
                                            });
                                          }
                                        }
                                      },
                                child: isChecking == true
                                    ? const SizedBox(
                                        height: 20.0,
                                        width: 20.0,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'GET REFUND',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "Poppins",
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 2.5.h,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )),
        );
      },
    );
  }

  Widget callButton(String consultId, String appointId, dynamic appointStartTime,
      String appointStatus, CompletedAppointment e) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String status = "Offline";
    StreamSubscription<dynamic> stream;
    //use this bottom condition to hard code run ✅
    // if (e.appointmentId == "APO191223325") {
    //   e.appointmentStartTime = "2023-12-21 08:52 PM";
    // }
    stream = FireStoreCollections.consultantOnlineStatus
        .doc(e.ihlConsultantId)
        .snapshots()
        .listen((dynamic event) {
      try {
        Map<String, dynamic> data = event.data() as Map<String, dynamic>;
        status = data['status'];
        if (status.toLowerCase() != "online") {
          enableJoinCall.notifyListeners();
        } else {
          enableJoinCall.notifyListeners();
        }
      } catch (ee) {
        log("some issues are there");
        FireStoreCollections.consultantOnlineStatus
            .doc(e.ihlConsultantId)
            .set({'consultantId': e.ihlConsultantId, 'status': "Offline"});
      }
    });
    return ValueListenableBuilder<bool>(
        valueListenable: enableJoinCall,
        builder: (BuildContext context, bool v, Widget child) {
          e = e ?? CompletedAppointment();
          try {
            String appointmentStartstringTime = e.appointmentStartTime.substring(11, 19);
            String appointmentStartTime = e.appointmentStartTime.substring(0, 10);
            DateTime startTimeformattime = DateFormat.jm().parse(appointmentStartstringTime);
            String starttime = DateFormat("HH:mm:ss").format(startTimeformattime);
            String appointmentStartdateToFormat = "$appointmentStartTime $starttime";
            appointmentStartingTime = DateTime.parse(appointmentStartdateToFormat);
            DateTime fiveMinutesBeforeStartAppointment =
                appointmentStartingTime.subtract(const Duration(minutes: 0));
            DateTime thirtyMinutesAfterStartAppointment =
                appointmentStartingTime.add(const Duration(minutes: 30));
            if (DateTime.now().isAfter(fiveMinutesBeforeStartAppointment) &&
                DateTime.now().isBefore(thirtyMinutesAfterStartAppointment) &&
                e.callStatus != "completed") {
              if ((status.toLowerCase() == "online" || status.toLowerCase() == "busy") &&
                  e.appointmentStatus.toLowerCase() != "requested") {
                v = true;
              }
            } else if (DateTime.now().isBefore(fiveMinutesBeforeStartAppointment) &&
                e.callStatus != "completed") {
              Duration difference = fiveMinutesBeforeStartAppointment.difference(DateTime.now());
              Timer timer;
              timer = Timer(difference, () {
                if ((status.toLowerCase() == "online" || status.toLowerCase() == "busy") &&
                    e.appointmentStatus.toLowerCase() != "requested") {
                  enableJoinCall.value = true;
                }
                timer.cancel();
              });
            } else {
              stream.cancel();
              v = false;
            }
          } on Abort catch (abort) {
            print(abort.message.message);
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: 2.w,
              ),
              SizedBox(
                height: 3.h,
                width: 18.w,
                child: v
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          fixedSize: Size.fromWidth(34.w / 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String uid = prefs.getString("ihlUserId");
                          String userName = prefs.getString(LSKeys.userName);
                          try {
                            if (e.vendorId == "GENIX") {
                              Get.offAll(GenixWebViewCall(
                                genixCallDetails: GenixCallDetails(
                                    genixAppointId: e.appointmentId, ihlUserId: uid),
                              ));
                            } else {
                              TeleConsultationFunctionsAndVariables().permissionCheckerForCall(
                                  nav: () {
                                Get.offAll(WaitForConsultant(
                                    videoCallDetails: VideoCallDetail(
                                        appointId: appointId,
                                        docId: e.ihlConsultantId,
                                        userID: uid,
                                        callType: "appointmentCall",
                                        ihlUserName: userName)));
                              });
                            }
                          } catch (e) {
                            return Get.defaultDialog(
                                backgroundColor: Colors.lightBlue.shade50,
                                title: "Alert",
                                titleStyle: TextStyle(color: Colors.blue.shade300),
                                titlePadding: const EdgeInsets.only(bottom: 0, top: 10),
                                contentPadding: const EdgeInsets.only(top: 0),
                                content: Column(
                                  children: <Widget>[
                                    const Divider(
                                      thickness: 2,
                                    ),
                                    Text(
                                      "Something went wrong. Please try again.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.blue.shade400),
                                    ),
                                    const SizedBox(height: 5),
                                    Icon(
                                      Icons.error_outline,
                                      size: 50,
                                      color: Colors.blue.shade300,
                                    ),
                                  ],
                                ));
                          }
                        },
                        child: Text('JOIN', style: TextStyle(fontSize: 13.sp)))
                    : Opacity(
                        opacity: 0.5,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              fixedSize: Size.fromWidth(34.w / 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            onPressed: () {},
                            child: Text('JOIN', style: TextStyle(fontSize: 13.sp))),
                      ),
              ),
              SizedBox(
                width: 0.5.w,
              ),
              SizedBox(
                height: 3.h,
                width: 18.w,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      backgroundColor: Colors.white,
                      fixedSize: Size.fromWidth(34.w / 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    onPressed: () async {
                      appointStatus == "Approved"
                          ? await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                String reasonRadioBtnVal;
                                return WillPopScope(
                                    onWillPop: () async => false,
                                    child: AlertDialog(
                                        title: const Text(
                                          'Please provide the reason for Cancellation!',
                                          style: TextStyle(color: Color(0xff4393cf)),
                                          textAlign: TextAlign.center,
                                        ),
                                        content: StatefulBuilder(
                                          builder: (BuildContext context, StateSetter setState) {
                                            return SingleChildScrollView(
                                              child: Form(
                                                key: formKey,
                                                child: Column(
                                                  children: <Widget>[
                                                    Column(
                                                      children: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            Radio<String>(
                                                              value:
                                                                  // ignore: unnecessary_string_escapes
                                                                  "Consultant didn\'t joined the call",
                                                              groupValue: reasonRadioBtnVal,
                                                              onChanged: (String value) {
                                                                if (mounted) {
                                                                  setState(() {
                                                                    isRadioSelected = true;
                                                                    reasonRadioBtnVal = value;
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                            const Expanded(
                                                              child: Text(
                                                                'Consultant didn\'t joined the call',
                                                                style: TextStyle(fontSize: 16.0),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            Radio<String>(
                                                              value:
                                                                  "You were facing technical issue",
                                                              groupValue: reasonRadioBtnVal,
                                                              onChanged: (String value) {
                                                                if (mounted) {
                                                                  setState(() {
                                                                    isRadioSelected = true;
                                                                    reasonRadioBtnVal = value;
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                            const Expanded(
                                                              child: Text(
                                                                'You were facing technical issue',
                                                                style: TextStyle(
                                                                  fontSize: 16.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            Radio<String>(
                                                              value: 'You didn\'t joined the call',
                                                              groupValue: reasonRadioBtnVal,
                                                              onChanged: (String value) {
                                                                if (mounted) {
                                                                  setState(() {
                                                                    isRadioSelected = true;
                                                                    reasonRadioBtnVal = value;
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                            const Expanded(
                                                              child: Text(
                                                                'You didn\'t joined the call',
                                                                style: TextStyle(fontSize: 16.0),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            Radio<String>(
                                                              value:
                                                                  'Consultant was facing technical issue',
                                                              groupValue: reasonRadioBtnVal,
                                                              onChanged: (String value) {
                                                                if (mounted) {
                                                                  setState(() {
                                                                    isRadioSelected = true;
                                                                    reasonRadioBtnVal = value;
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                            const Expanded(
                                                              child: Text(
                                                                'Consultant was facing technical issue',
                                                                style: TextStyle(fontSize: 16.0),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 2.h,
                                                        ),
                                                        TextFormField(
                                                          // enabled: reasonRadioBtnVal,
                                                          // autofocus: true,
                                                          controller: reasonController,
                                                          validator: (String value) {
                                                            if (value.isEmpty) {
                                                              return 'Please provide the reason!';
                                                            }
                                                            return null;
                                                          },
                                                          decoration: InputDecoration(
                                                            contentPadding:
                                                                const EdgeInsets.symmetric(
                                                                    vertical: 15, horizontal: 18),
                                                            labelText: "Other reason",
                                                            fillColor: Colors.white24,
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(15.0),
                                                                borderSide: const BorderSide(
                                                                    color: Colors.blueGrey)),
                                                          ),
                                                          maxLines: 1,
                                                          textInputAction: TextInputAction.done,
                                                        ),
                                                      ],
                                                    ),
                                                    Visibility(
                                                      visible: makeValidateVisible ? true : false,
                                                      child: const Text(
                                                        "Please select the reason!",
                                                        style: TextStyle(color: Colors.red),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10.0,
                                                    ),
                                                    ValueListenableBuilder<bool>(
                                                        valueListenable:
                                                            TeleConsultationFunctionsAndVariables
                                                                .isChecking,
                                                        builder: (BuildContext context, bool value,
                                                            Widget child) {
                                                          return Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.spaceEvenly,
                                                            children: <Widget>[
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  // ignore: deprecated_member_use
                                                                  primary: AppColors.primaryColor,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                      side: const BorderSide(
                                                                          color: AppColors
                                                                              .primaryColor)),
                                                                ),
                                                                onPressed: value == true
                                                                    ? null
                                                                    : () {
                                                                        reasonController.text = '';
                                                                        Navigator.pop(context);
                                                                      },
                                                                child: const Text(
                                                                  'Go Back',
                                                                  style: TextStyle(
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                10.0),
                                                                        side: const BorderSide(
                                                                            color: AppColors
                                                                                .primaryColor)),
                                                                    // ignore: deprecated_member_use
                                                                    primary: AppColors.primaryColor,
                                                                  ),
                                                                  onPressed: value == true
                                                                      ? null
                                                                      : () async {
                                                                          if (reasonRadioBtnVal
                                                                              .isNotEmpty) {
                                                                            TeleConsultationFunctionsAndVariables
                                                                                .isChecking
                                                                                .value = true;
                                                                            await TeleConsultationFunctionsAndVariables
                                                                                .getCancelledSlotList(
                                                                                    ihlConsultantID: e
                                                                                        .ihlConsultantId,
                                                                                    reason: reasonRadioBtnVal ??
                                                                                        reasonController
                                                                                            .text,
                                                                                    appointId: e
                                                                                        .appointmentId);
                                                                            TeleConsultationFunctionsAndVariables
                                                                                .isChecking
                                                                                .value = false;
                                                                            // ignore: use_build_context_synchronously
                                                                            AwesomeDialog(
                                                                                    context:
                                                                                        context,
                                                                                    animType:
                                                                                        AnimType
                                                                                            // ignore: deprecated_member_use
                                                                                            .TOPSLIDE,
                                                                                    headerAnimationLoop:
                                                                                        true,
                                                                                    dialogType:
                                                                                        DialogType
                                                                                            // ignore: deprecated_member_use
                                                                                            .SUCCES,
                                                                                    dismissOnTouchOutside:
                                                                                        false,
                                                                                    title:
                                                                                        'Success!',
                                                                                    desc:
                                                                                        'Appointment Successfully Cancelled! Your Refund has been Initiated.',
                                                                                    btnOkOnPress: () =>
                                                                                        Get.offAll(MyAppointmentsTabs(
                                                                                            fromCall:
                                                                                                true)),
                                                                                    // Get.offAll(MyAppointment(
                                                                                    //   backNav: false,
                                                                                    // )
                                                                                    // ),
                                                                                    btnOkColor:
                                                                                        Colors
                                                                                            .green,
                                                                                    btnOkText:
                                                                                        'Proceed',
                                                                                    btnOkIcon:
                                                                                        Icons.check,
                                                                                    onDismissCallback:
                                                                                        (_) {})
                                                                                .show();
                                                                          } else if (reasonController
                                                                              .text.isNotEmpty) {
                                                                            TeleConsultationFunctionsAndVariables
                                                                                .getCancelledSlotList(
                                                                                    ihlConsultantID: e
                                                                                        .ihlConsultantId,
                                                                                    reason:
                                                                                        reasonRadioBtnVal,
                                                                                    appointId: e
                                                                                        .appointmentId);

                                                                            AwesomeDialog(
                                                                                    context:
                                                                                        context,
                                                                                    animType:
                                                                                        AnimType
                                                                                            // ignore: deprecated_member_use
                                                                                            .TOPSLIDE,
                                                                                    headerAnimationLoop:
                                                                                        true,
                                                                                    dialogType:
                                                                                        DialogType
                                                                                            // ignore: deprecated_member_use
                                                                                            .SUCCES,
                                                                                    dismissOnTouchOutside:
                                                                                        false,
                                                                                    title:
                                                                                        'Success!',
                                                                                    desc:
                                                                                        'Appointment Successfully Cancelled! Your Refund has been Initiated.',
                                                                                    btnOkOnPress: () =>
                                                                                        Get.offAll(MyAppointmentsTabs(
                                                                                            fromCall:
                                                                                                true)),
                                                                                    // Get.offAll(MyAppointment(
                                                                                    //   backNav: false,
                                                                                    // )
                                                                                    // ),
                                                                                    btnOkColor:
                                                                                        Colors
                                                                                            .green,
                                                                                    btnOkText:
                                                                                        'Proceed',
                                                                                    btnOkIcon:
                                                                                        Icons.check,
                                                                                    onDismissCallback:
                                                                                        (_) {})
                                                                                .show();
                                                                          } else {
                                                                            if (mounted) {
                                                                              setState(() {
                                                                                autoValidate = true;
                                                                              });
                                                                            }
                                                                          }
                                                                        },
                                                                  child: value == true
                                                                      ? const SizedBox(
                                                                          height: 20.0,
                                                                          width: 20.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<
                                                                                        Color>(
                                                                                    Colors.white),
                                                                          ),
                                                                        )
                                                                      : const Text(
                                                                          'Submit',
                                                                          style: TextStyle(
                                                                              color: Colors.white),
                                                                        )),
                                                            ],
                                                          );
                                                        })
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        )));
                              })
                          // if (this.mounted) {
                          //   setState(() {});
                          // }

                          : showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return WillPopScope(
                                  onWillPop: () async => false,
                                  child: AlertDialog(
                                      title: const Text(
                                        'Please provide the reason for cancellation!',
                                        style: TextStyle(color: AppColors.primaryColor),
                                        textAlign: TextAlign.center,
                                      ),
                                      content: SingleChildScrollView(
                                        child: Form(
                                          key: formKey,
                                          // ignore: deprecated_member_use
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          child: Column(
                                            children: <Widget>[
                                              TextFormField(
                                                // autofocus: true,
                                                controller: reasonController,
                                                // validator: (value) {
                                                //   if (value.isEmpty) {
                                                //     return 'Please provide the reason!';
                                                //   }
                                                //   return null;
                                                // },
                                                decoration: InputDecoration(
                                                  contentPadding: const EdgeInsets.symmetric(
                                                      vertical: 15, horizontal: 18),
                                                  labelText: "Specify your reason",
                                                  fillColor: Colors.white24,
                                                  border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(15.0),
                                                      borderSide:
                                                          const BorderSide(color: Colors.blueGrey)),
                                                ),
                                                maxLines: 1,
                                                // textInputAction: TextInputAction.done,
                                              ),
                                              const SizedBox(
                                                height: 10.0,
                                              ),
                                              ValueListenableBuilder<bool>(
                                                  valueListenable:
                                                      TeleConsultationFunctionsAndVariables
                                                          .isChecking,
                                                  builder: (BuildContext context, bool value,
                                                      Widget child) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceEvenly,
                                                      children: <Widget>[
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            // ignore: deprecated_member_use
                                                            primary: AppColors.primaryColor,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(10.0),
                                                                side: const BorderSide(
                                                                    color: AppColors.primaryColor)),
                                                          ),
                                                          onPressed: value == true
                                                              ? null
                                                              : () {
                                                                  reasonController.text = '';
                                                                  Navigator.pop(context);
                                                                },
                                                          child: const Text(
                                                            'Go Back',
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(10.0),
                                                                  side: const BorderSide(
                                                                      color:
                                                                          AppColors.primaryColor)),
                                                              backgroundColor:
                                                                  AppColors.primaryColor,
                                                            ),
                                                            onPressed: value == true
                                                                ? null
                                                                : () {
                                                                    if (formKey.currentState
                                                                        .validate()) {
                                                                      reasonController.text = '';

                                                                      TeleConsultationFunctionsAndVariables
                                                                          .getCancelledSlotList(
                                                                              ihlConsultantID:
                                                                                  e.ihlConsultantId,
                                                                              reason:
                                                                                  reasonController
                                                                                      .text
                                                                                      .toString(),
                                                                              appointId: appointId);
                                                                      AwesomeDialog(
                                                                              context: context,
                                                                              animType:
                                                                                  // ignore: deprecated_member_use
                                                                                  AnimType.TOPSLIDE,
                                                                              headerAnimationLoop:
                                                                                  true,
                                                                              dialogType:
                                                                                  // ignore: deprecated_member_use
                                                                                  DialogType.SUCCES,
                                                                              dismissOnTouchOutside:
                                                                                  false,
                                                                              title: 'Success!',
                                                                              desc:
                                                                                  'Appointment Successfully Cancelled! Your Refund has been Initiated.',
                                                                              btnOkOnPress: () {
                                                                                Get.offAll(
                                                                                    MyAppointmentsTabs(
                                                                                        fromCall:
                                                                                            true));
                                                                              },
                                                                              // Get.offAll(MyAppointment(
                                                                              //   backNav: false,
                                                                              // )
                                                                              // ),
                                                                              btnOkColor:
                                                                                  Colors.green,
                                                                              btnOkText: 'Proceed',
                                                                              btnOkIcon:
                                                                                  Icons.check,
                                                                              onDismissCallback:
                                                                                  (_) {})
                                                                          .show();
                                                                    } else {
                                                                      if (mounted) {
                                                                        setState(() {
                                                                          autoValidate = true;
                                                                        });
                                                                      }
                                                                    }
                                                                  },
                                                            child: value == true
                                                                ? const SizedBox(
                                                                    height: 20.0,
                                                                    width: 20.0,
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      valueColor:
                                                                          AlwaysStoppedAnimation<
                                                                              Color>(Colors.white),
                                                                    ),
                                                                  )
                                                                : const Text(
                                                                    'Submit',
                                                                    style: TextStyle(
                                                                        color: Colors.white),
                                                                  )),
                                                      ],
                                                    );
                                                  })
                                            ],
                                          ),
                                        ),
                                      )),
                                );
                              });
                    },
                    //
                    //     print('consultId===>$consultId=====$appointId');
                    //     // List gettedResponse =
                    //     //     await TeleConsultationFunctionsAndVariables.getCancelledSlotList(
                    //     //     ihlConsultantID: bookings., appointId: 510, reason: type);
                    //     // // ignore: always_specify_types
                    //     // print(gettedResponse);
                    //   };

                    child: FittedBox(
                      child: Text(
                        'CANCEL',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    )),
              ),
              SizedBox(
                width: 2.w,
              ),
            ],
          );
        });
  }

  skeleton({Widget child}) {
    return Shimmer.fromColors(
        direction: ShimmerDirection.ltr,
        period: const Duration(seconds: 2),
        baseColor: const Color.fromARGB(255, 240, 240, 240),
        highlightColor: Colors.grey.withOpacity(0.2),
        child: child);
  }
}

class AppointmentTileWidget extends StatefulWidget {
  AppointmentTileWidget(this.e, this.callButton, {Key key}) : super(key: key);
  CompletedAppointment e;
  Widget callButton;

  @override
  State<AppointmentTileWidget> createState() => _AppointmentTileWidgetState();
}

class _AppointmentTileWidgetState extends State<AppointmentTileWidget> {
  String status = 'Offline';

  Stream<DocumentSnapshot<Map<String, dynamic>>> stream;

  @override
  void initState() {
    stream = FireStoreCollections.consultantOnlineStatus.doc(widget.e.ihlConsultantId).snapshots();
    widget.e = widget.e ?? CompletedAppointment();
    super.initState();
  }

  @override
  void dispose() {
    stream.listen((DocumentSnapshot<Map<String, dynamic>> event) {}).cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.w, // Adjust the width as needed
      // height: 34.5.h, // Adjust the height as needed
      child: Row(
        children: <Widget>[
          SizedBox(
              width: 48.w,
              // height: 34.h,
              child: Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(6),
                    ),
                  ),
                  elevation: 4,
                  child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () {},
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(
                                  height: 4.w,
                                  width: 13.w,
                                  child: RotationTransition(
                                    turns: const AlwaysStoppedAnimation<double>(0 / 360),
                                    child: ClipPath(
                                      clipper: SubscriptionClipPath(),
                                      child: StreamBuilder<DocumentSnapshot<dynamic>>(
                                        stream: stream,
                                        builder: (BuildContext context,
                                            AsyncSnapshot<DocumentSnapshot<dynamic>> snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return Shimmer.fromColors(
                                              baseColor: Colors.white,
                                              highlightColor: Colors.grey.withOpacity(0.3),
                                              child: Container(
                                                  height: 4.w,
                                                  width: 12.w,
                                                  color: Colors.white,
                                                  child: const RotationTransition(
                                                      turns:
                                                          AlwaysStoppedAnimation<double>(0 / 360),
                                                      child: Text(
                                                        "Offline",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.transparent,
                                                            fontSize: 10),
                                                      ))),
                                            );
                                          }
                                          if (snapshot.hasError) {
                                            FireStoreCollections.consultantOnlineStatus
                                                .doc(widget.e.ihlConsultantId)
                                                .set({
                                              'consultantId': widget.e.ihlConsultantId,
                                              'status': status != 'Online' ? "Offline" : "Online"
                                            });
                                          }
                                          Map<String, dynamic> data =
                                              snapshot.data.data() as Map<String, dynamic>;
                                          if (data != null) {
                                            status = data['status'];
                                          }
                                          return InkWell(
                                            onTap: () {},
                                            child: Container(
                                                height: 4.w,
                                                width: 13.w,
                                                color: status == 'Online'
                                                    ? Colors.green
                                                    : status == 'Busy'
                                                        ? Colors.red
                                                        : Colors.grey,
                                                child: RotationTransition(
                                                    turns: const AlwaysStoppedAnimation<double>(
                                                        0 / 360),
                                                    child: Text(
                                                      status,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                          color: Colors.white, fontSize: 10),
                                                    ))),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                PopupMenuButton<String>(
                                    child: Container(
                                        alignment: Alignment.center,
                                        width: 7.w,
                                        height: 7.w,
                                        child: const Icon(Icons.more_horiz)),
                                    onSelected: (String k) async {
                                      final prefs = await SharedPreferences.getInstance();
                                      String iHLUserId = prefs.getString('ihlUserId');
                                      if (k == 'Share Medical Report') {
                                        Get.to(MyMedicalFiles(
                                          ihlConsultantId: widget.e.ihlConsultantId,
                                          appointmentId: widget.e.appointmentId,
                                          medicalFiles: false,
                                          normalFlow: false,
                                        ));

                                        // Get.to(
                                        //     ShareDocumentFromMyAppointment(
                                        //   ihlConsultantId:
                                        //       e.ihlConsultantId,
                                        //   appointmentId:
                                        //       e.appointmentId,
                                        // ));
                                      } else {
                                        //////////////////////////////
                                        bool permissionGrandted = false;
                                        if (Platform.isAndroid) {
                                          final deviceInfo = await DeviceInfoPlugin().androidInfo;
                                          Map<Permission, PermissionStatus> _status;
                                          if (deviceInfo.version.sdkInt <= 32) {
                                            _status = await [Permission.storage].request();
                                          } else {
                                            _status = await [Permission.photos, Permission.videos]
                                                .request();
                                          }
                                          _status.forEach((permission, status) {
                                            if (status == PermissionStatus.granted) {
                                              permissionGrandted = true;
                                            }
                                          });
                                        } else {
                                          permissionGrandted = true;
                                        }
                                        if (permissionGrandted) {
                                          SharedPreferences prefs =
                                              await SharedPreferences.getInstance();
                                          Get.snackbar(
                                            '',
                                            'Invoice will be saved in your mobile!',
                                            backgroundColor: AppColors.primaryAccentColor,
                                            colorText: Colors.white,
                                            duration: Duration(seconds: 5),
                                            isDismissible: false,
                                          );
                                          await appointmentDetailsGlobal(
                                              context: context,
                                              appointmentID: widget.e.appointmentId);
                                          Invoice invoice = await ConsultApi()
                                              .getInvoiceNumber(iHLUserId, widget.e.appointmentId);

                                          new Future.delayed(new Duration(seconds: 2), () {
                                            billView(context, invoiceNumber, true,
                                                invoiceModel: invoice);
                                          });
                                        } else {
                                          Get.snackbar('Storage Access Denied',
                                              'Allow Storage permission to continue',
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                              duration: Duration(seconds: 5),
                                              isDismissible: false,
                                              mainButton: TextButton(
                                                  onPressed: () async {
                                                    await openAppSettings();
                                                  },
                                                  child: Text('Allow')));
                                        }
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      if (double.parse(widget.e.consultationFees) > 1) {
                                        return [
                                          PopupMenuItem<String>(
                                            value: 'Share Medical Report',
                                            child: Row(
                                              children: const <Widget>[
                                                Icon(
                                                  Icons.share,
                                                  color: AppColors.primaryColor,
                                                ),
                                                SizedBox(
                                                  width: 7,
                                                ),
                                                Text('Share Medical Report'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'Download Invoice',
                                            child: Row(
                                              children: const <Widget>[
                                                Icon(
                                                  Icons.download,
                                                  color: AppColors.primaryColor,
                                                ),
                                                SizedBox(
                                                  width: 7,
                                                ),
                                                Text('Download Invoice'),
                                              ],
                                            ),
                                          ),
                                        ];
                                      } else {
                                        return [
                                          PopupMenuItem<String>(
                                            value: 'Share Medical Report',
                                            child: Row(
                                              children: const <Widget>[
                                                Icon(
                                                  Icons.share,
                                                  color: AppColors.primaryColor,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text('Share Medical Report'),
                                              ],
                                            ),
                                          ),
                                        ];
                                      }
                                    }),
                              ],
                            ),
                            Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(
                                        left: 10.sp,
                                        top: 10.sp,
                                      ),
                                      child: SizedBox(
                                          height: 10.h,
                                          width: 34.w,
                                          child: FutureBuilder(
                                              future: TabBarController()
                                                  .getConsultantImageUrl(doctor: widget.e.toJson()),
                                              builder:
                                                  (BuildContext context, AsyncSnapshot<String> i) {
                                                if (i.connectionState == ConnectionState.done) {
                                                  return CircleAvatar(
                                                    radius: 36.0,
                                                    backgroundImage: Image.memory(
                                                      base64Decode(i.data.toString()),
                                                      fit: BoxFit.contain,
                                                    ).image,
                                                    backgroundColor: Colors.transparent,
                                                  );
                                                } else if (i.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return SizedBox(
                                                    width: 15.w,
                                                    height: 8.h,
                                                    child: Shimmer.fromColors(
                                                      baseColor: Colors.white,
                                                      highlightColor: Colors.grey.withOpacity(0.3),
                                                      direction: ShimmerDirection.ltr,
                                                      child: Container(
                                                        width: 15.w,
                                                        height: 6.h,
                                                        decoration: const BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              }))),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 10.sp, top: 8.sp),
                                    child: Column(
                                      children: <Widget>[
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 14.sp, bottom: 2.0, top: 3.0),
                                              child: SizedBox(
                                                width: 45.w,
                                                child: Text(
                                                  widget.e.consultantName,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold, fontSize: 14.sp
                                                      // fontSize: widget.consultant_name.length < 23 ? 14.sp : 13.5.sp,
                                                      ),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 14.sp, bottom: 2.0, top: 3.0),
                                              child: SizedBox(
                                                width: 45.w,
                                                child: Text(
                                                  '${widget.e.appointmentStartTime.replaceRange(0, 11, '')} - ${widget.e.appointmentEndTime.replaceRange(0, 11, '')}',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: AppColors.primaryColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14.sp),
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 14.sp, bottom: 2.0, top: 3.0),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 13.w,
                                                    child: Text(
                                                      'Status - ',
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                          color: Colors.black, fontSize: 14.sp),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 28.w,
                                                    child: Text(
                                                      widget.e.appointmentStatus == "Approved"
                                                          ? "Request Accepted"
                                                          : "Request Pending",
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                          color: widget.e.appointmentStatus ==
                                                                  "Approved"
                                                              ? Colors.green
                                                              : Colors.black87,
                                                          fontSize: 14.sp),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 14.sp, bottom: 7.0, top: 3.0),
                                              child: SizedBox(
                                                width: 45.w,
                                                child: Text(
                                                  widget.e.appointmentStartTime.substring(0, 10) ==
                                                          DateFormat('yyyy-MM-dd')
                                                              .format(DateTime.now())
                                                      ? "Today"
                                                      : "Upcoming",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w500, fontSize: 14.sp),
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 14.sp, top: 8.sp),
                                      child: SizedBox(
                                        height: 3.h,
                                        child: widget.callButton,
                                      )),
                                ])
                          ])))),
        ],
      ),
    );
  }
}
