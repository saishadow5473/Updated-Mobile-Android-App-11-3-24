import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:ihl/new_design/data/model/TeleconsultationModels/TeleconulstationDashboardModels.dart';
import 'package:ihl/new_design/data/model/TeleconsultationModels/doctorModel.dart';
import 'package:ihl/new_design/presentation/controllers/dashboardControllers/dashBoardContollers.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'package:connectanum/json.dart';
import 'package:strings/strings.dart';
import '../../../../constants/api.dart';
import '../../../../constants/routes.dart';
import '../../../../utils/CheckPermi.dart';
import '../../../../utils/screenutil.dart';
import '../../../../views/consultationStages.dart';
import '../../../../views/teleconsultation/files/medicalFiles.dart';
import '../../../../widgets/toc.dart';
import '../../../app/utils/appText.dart';
import '../../../data/model/TeleconsultationModels/MyAppointments.dart';
import '../../../data/model/TeleconsultationModels/allMedicalFiles.dart';
import '../../Widgets/appBar.dart';
import '../../../data/model/TeleconsultationModels/appointmentModels.dart';
import '../../Widgets/dashboardWidgets/teleconsultation_widget.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../dashboard/affiliation_dashboard/affiliationDasboard.dart';
import 'DashboardMyAppointments.dart';
import 'MyMedicalFiles.dart';
import 'SearchByDocAndList.dart';
import 'SearchBySpecAndList.dart';
import 'doctorsDescriptionScreen.dart';
import 'myAppointmentsTabs.dart';
import 'consultationStages.dart';

class TeleconsultationOnlineService extends StatefulWidget {
  const TeleconsultationOnlineService({Key key}) : super(key: key);

  @override
  State<TeleconsultationOnlineService> createState() => _TeleconsultationOnlineServiceState();
}

class _TeleconsultationOnlineServiceState extends State<TeleconsultationOnlineService> {
  int currentSearchType = 0;
  bool isVisible = false;
  ValueNotifier<bool> searchAnimation = ValueNotifier(false);
  Timer t;
  ValueNotifier<List<SpecialityList>> specName = ValueNotifier<List<SpecialityList>>([]);
  ValueNotifier<List<DoctorModel>> doctors = ValueNotifier<List<DoctorModel>>([]);
  var prescriptionStatus;
  ValueNotifier<List<CompletedAppointment>> appointment =
      ValueNotifier<List<CompletedAppointment>>([]);
  static ValueNotifier<List<CompletedAppointment>> approvedAndUpcomingList =
      ValueNotifier<List<CompletedAppointment>>([]);
  List gettedResponse = [];
  String type = "Requested";
  List<CompletedAppointment> appointmentLists = <CompletedAppointment>[];

  // var appointId;    bool getUserDetailsUpdate = false;  bool callCompleted = false;
  // bool noPrescription = false;
  // final counterValueConsultaionStages = ValueNotifier<int>(180);
  // bool isRejoin = false;

  String iHLUserId = '';

  @override
  void initState() {
    asyncfunc();
    // widget.consultant['availabilityStatus'] = 'Offline';
    super.initState();
    doctors.value.clear();
    doctors.notifyListeners();
    print("search animation started");
    t = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      searchAnimation.value = !searchAnimation.value;
    });
    super.initState();
  }

  asyncfunc() async {
    TeleConsultationFunctionsAndVariables.tempNumber = -1;
    List<SpecialityList> specList =
        await TeleConsultationFunctionsAndVariables.medicalHealthConsultantsSpecialityfunc();
    await TeleConsultationFunctionsAndVariables.doctorsCallsModelSpeciality(specList: specList);
    // await TeleConsultationFunctionsAndVariables.AppointmentsApproved();
    // TeleConsultationFunctionsAndVariables.appointments.notifyListeners();
    //   showShimmer = true;
    //   showAppointmentShimmer = true;

    approvedAndUpcomingList.value = <CompletedAppointment>[];
    List gettedResponse = await TeleConsultationFunctionsAndVariables.appointmentList(
        startIndex: 0, endIndex: 510, type: "Requested");
    for (var ee in gettedResponse) {
      if (ee.runtimeType.toString() == "CompletedAppointment") {
        type = "Requested";
        if (type == "Requested") {
          List rs = await TeleConsultationFunctionsAndVariables.appointmentList(
              startIndex: 0, endIndex: 510, type: "Approved");
          gettedResponse += rs;
          approvedAndUpcomingList.value = gettedResponse;
          approvedAndUpcomingList.value.sort((CompletedAppointment a, CompletedAppointment b) =>
              a.appointmentStartTime.compareTo(b.appointmentStartTime));
          break;
        } else {
          appointmentLists = gettedResponse;
          break;
        }
      }
    }
    // ignore: always_specify_types

    await gettingFunction();
  }

  gettingFunction() async {
    for (var ee in gettedResponse) {
      if (ee.runtimeType.toString() == "Appointment") {
        approvedAndUpcomingList.value = gettedResponse;
        approvedAndUpcomingList.value.sort((CompletedAppointment a, CompletedAppointment b) =>
            a.appointmentStartTime.compareTo(b.appointmentStartTime));
      }
    }
  }

  @override
  void dispose() {
    t.cancel();
    print("search animation canceled");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // DateTime parseDate = DateFormat("yyyy-MM-dd HH:mm")
    //     .parse(TeleConsultationFunctionsAndVariables.appointments.value[0].appointmentEndTime);
    if (!Tabss.featureSettings.teleconsultation) {
      return const Center(child: Text("No Teleconsultation Available"));
    } else {
      return SingleChildScrollView(
        child: Column(children: [
          SizedBox(height: 3.h),
          ValueListenableBuilder(
              valueListenable: searchAnimation,
              builder: (BuildContext context, val, Widget child) {
                return InkWell(
                  onTap: () {
                    if (val) {
                      Get.to(const SearchBySpecAndList());
                    } else {
                      Get.to(SearchByDocAndList());
                    }
                  },
                  child: Container(
                    height: 5.h,
                    width: 95.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(width: 0.2, color: Colors.black.withOpacity(0.2)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 3,
                              spreadRadius: 3,
                              offset: const Offset(0, 0))
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.search, color: Colors.grey),
                        if (true)
                          Container(
                            width: 65.w,
                            margin: EdgeInsets.only(left: 8.px),
                            alignment: Alignment.centerLeft,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(seconds: 1),
                              curve: Curves.bounceOut,
                              style: const TextStyle(
                                  color: Colors.grey, letterSpacing: 0.7, fontFamily: "Poppins"),
                              child: Text(
                                val ? "Search By Speciality Name" : "Search By Doctor Name",
                              ),
                            ),
                            // ,,
                          ),
                      ],
                    ),
                  ),
                );
              }),
          SizedBox(height: 1.h),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: 100.w,
              child: Column(
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    InkWell(
                      // onTap: () => Get.to(TeleConsultationStagesScreen()),
                      child: Text(
                        AppTexts.consultation,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          color: const Color(0XFF19A9E5),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<List<CompletedAppointment>>(
                        valueListenable: approvedAndUpcomingList,
                        builder: (_, List<CompletedAppointment> val, __) {
                          if (val.isEmpty) {
                            return TeleConsultationWidgets().viewAllServices(
                              onTap: () {
                                Get.to(MyAppointmentsTabs());
                              },
                              color: AppColors.primaryColor,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                  ]),
                  const SizedBox(height: 10),
                  const Text(
                    "Avail best consultation services from our top doctors online .",
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Color(0XFF000000), height: 1.3),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: <Widget>[
                      Container(
                        height: 47.5.w,
                        width: 95.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            image: const DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                  "newAssets/images/group_of_doctors.png",
                                ))),
                      ),
                      Container(
                        height: 47.5.w,
                        width: 95.w,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                              colors: <Color>[
                                const Color(0XFF19A9E5).withOpacity(0.4),
                                const Color(0XFF19A9E5).withOpacity(0.2),
                              ]),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Get.to(SearchByDocAndList());

                      // openTocDialog(
                      //   context,
                      //   on_Tap:
                      //   Navigator.of(context).pushNamed(
                      //     Routes.AllSpecialtyType,
                      //   ),
                      //   ontap_Available: true,
                      //   specnewScreen: true,
                      // );
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          padding: EdgeInsets.all(10.sp),
                          decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 18,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 5))
                              ],
                              color: const Color(0XFF19A9E5),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            "CONSULT NOW",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 16.sp,
                                fontFamily: "Poppins"),
                          ),
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                        child: Text(
                          AppTexts.specialities,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.36),
                      TeleConsultationWidgets().viewAllServices(
                        onTap: () {
                          Get.to(const SearchBySpecAndList());
                        },
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                  SizedBox(
                      height: 9.h,
                      width: 65.h,
                      child: ValueListenableBuilder<List<SpecialityList>>(
                          valueListenable: TeleConsultationFunctionsAndVariables.specName,
                          builder: (_, List<SpecialityList> val, __) {
                            if (val.isNotEmpty && val != null) {
                              return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  itemCount: val.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Card(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      elevation: 4,
                                      child: InkWell(
                                        splashColor: Colors.blue.withAlpha(30),
                                        onTap: () {
                                          Get.to(SearchByDocAndList(
                                              specName: val[index].specialityName));
                                        },
                                        child: SizedBox(
                                          width: 52.w,
                                          height: 100.h,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                width: 4.w,
                                              ),
                                              SizedBox(
                                                height: 10.h,
                                                width: 10.w,
                                                child: Image.asset(
                                                  'newAssets/Icons/speciality/${val[index].specialityName.toLowerCase()}.png',
                                                  errorBuilder: (BuildContext buildContext,
                                                      Object object, StackTrace stackTrace) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.grey.shade100,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                width: 12.w,
                                              ),
                                              SizedBox(
                                                  width: 25.w,
                                                  child: Text(
                                                    val[index].specialityName,
                                                    maxLines: 2,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            } else {
                              return Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: Colors.grey.withOpacity(0.3),
                                direction: ShimmerDirection.ltr,
                                child: Container(
                                  width: 80.w,
                                  height: 9.h,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(8.0),
                                      bottomLeft: Radius.circular(8.0),
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                    ),
                                    color: Colors.red,
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  child: const Text('Hello'),
                                ),
                              );
                            }
                          })),
                  ValueListenableBuilder<List<DoctorModel>>(
                      valueListenable: TeleConsultationFunctionsAndVariables.doctors,
                      builder: (_, List<DoctorModel> val, __) {
                        if (val.isNotEmpty && val != null) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                                    child: Text(
                                      AppTexts.doctor,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width * 0.36),
                                  TeleConsultationWidgets().viewAllServices(
                                    onTap: () {
                                      Get.to(SearchByDocAndList());
                                    },
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 22.h,
                                width: 75.h,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                                    itemCount: val.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      List<String> consultantSpeciality = <String>[];
                                      for (int i = 0;
                                          i < val[index].consultantSpeciality.length;
                                          i++) {
                                        consultantSpeciality
                                            .add(val[index].consultantSpeciality[i]);
                                      }
                                      return SizedBox(
                                        height: 14.h,
                                        width: 70.w,
                                        child: Card(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(6),
                                            ),
                                          ),
                                          elevation: 4,
                                          child: InkWell(
                                            splashColor: Colors.blue.withAlpha(30),
                                            onTap: () {
                                              Get.to(DoctorsDescriptionScreen(
                                                ihlConsultantId:
                                                    val[index].ihlConsultantId.toString(),
                                                doctorDetails: val[index],
                                              ));
                                            },
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.all(9.0),
                                                      child: FutureBuilder<String>(
                                                        future: TabBarController()
                                                            .getConsultantImageUrl(
                                                                doctor: val[index].toJson()),
                                                        builder: (BuildContext context,
                                                            AsyncSnapshot<String> i) {
                                                          if (i.connectionState ==
                                                              ConnectionState.done) {
                                                            return Padding(
                                                              padding: const EdgeInsets.all(5.0),
                                                              child: Container(
                                                                width: 25.w,
                                                                height: 12.h,
                                                                decoration: BoxDecoration(
                                                                  color: const Color(0xff7c94b6),
                                                                  borderRadius:
                                                                      const BorderRadius.all(
                                                                          Radius.circular(4.0)),
                                                                  image: DecorationImage(
                                                                      image: Image.memory(
                                                                        base64Decode(
                                                                          i.data.toString(),
                                                                        ),
                                                                      ).image,
                                                                      fit: BoxFit.cover),
                                                                ),
                                                              ),
                                                            );
                                                          } else if (i.connectionState ==
                                                              ConnectionState.waiting) {
                                                            return SizedBox(
                                                              width: 25.w,
                                                              height: 12.h,
                                                              child: Shimmer.fromColors(
                                                                baseColor: Colors.white,
                                                                highlightColor:
                                                                    Colors.grey.withOpacity(0.3),
                                                                direction: ShimmerDirection.ltr,
                                                                child: Container(
                                                                  width: 25.w,
                                                                  height: 16.h,
                                                                  decoration: const BoxDecoration(
                                                                    borderRadius: BorderRadius.only(
                                                                      bottomRight:
                                                                          Radius.circular(8.0),
                                                                      bottomLeft:
                                                                          Radius.circular(8.0),
                                                                      topLeft: Radius.circular(8.0),
                                                                      topRight:
                                                                          Radius.circular(8.0),
                                                                    ),
                                                                    color: Colors.red,
                                                                  ),
                                                                  margin:
                                                                      const EdgeInsets.symmetric(
                                                                          vertical: 10,
                                                                          horizontal: 8),
                                                                  child: const Text('Hello'),
                                                                ),
                                                              ),
                                                            );
                                                          } else {
                                                            return Container();
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 1.w,
                                                    ),
                                                    SizedBox(
                                                      width: 34.w,
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceEvenly,
                                                        children: <Widget>[
                                                          SizedBox(
                                                            width: 32.w,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(
                                                                  bottom: 4.0),
                                                              child: Text(
                                                                val[index].name.toString(),
                                                                textAlign: TextAlign.start,
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 16.5.sp),
                                                                maxLines: 2,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 28.w,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(
                                                                  bottom: 4.0),
                                                              child: Text(
                                                                val[index].qualification == null
                                                                    ? "MBBS"
                                                                    : val[index]
                                                                        .qualification
                                                                        .toString(),
                                                                textAlign: TextAlign.start,
                                                                style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: 14.sp),
                                                                maxLines: 2,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 28.w,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(
                                                                  bottom: 4.0),
                                                              child: Text(
                                                                consultantSpeciality
                                                                    .toString()
                                                                    .substring(
                                                                        1,
                                                                        consultantSpeciality
                                                                                .toString()
                                                                                .length -
                                                                            1),
                                                                textAlign: TextAlign.start,
                                                                style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: 14.sp),
                                                                maxLines: 2,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 40.w,
                                                            child: Text(
                                                              val[index]
                                                                      .experience
                                                                      .toString()
                                                                      .contains('years')
                                                                  ? '${val[index].experience} Experience'
                                                                  : '${val[index].experience.toString()} yrs Experience',
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.w500,
                                                                  fontSize: 14.sp),
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Align(
                                                  alignment: Alignment.topCenter,
                                                  child: Row(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: 2.w,
                                                      ),
                                                      const Icon(
                                                        Icons.star,
                                                        color: AppColors.primaryColor,
                                                      ),
                                                      SizedBox(
                                                        width: 2.w,
                                                      ),
                                                      Text("${val[index].ratings} Ratings")
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          );
                        } else if (val.isEmpty &&
                            selectedAffiliationfromuniquenameDashboard == "") {
                          return SizedBox();
                        } else {
                          return Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: Colors.grey.withOpacity(0.3),
                            direction: ShimmerDirection.ltr,
                            child: Container(
                              width: 80.w,
                              height: 9.h,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(8.0),
                                  bottomLeft: Radius.circular(8.0),
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(8.0),
                                ),
                                color: Colors.red,
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              child: const Text('Hello'),
                            ),
                          );
                        }
                      }),
                  ValueListenableBuilder<List<CompletedAppointment>>(
                      valueListenable: approvedAndUpcomingList,
                      builder: (_, List<CompletedAppointment> val, __) {
                        if (val.isNotEmpty && val != null) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                                child: Text(
                                  AppTexts.MyAppointments,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width * 0.36),
                              TeleConsultationWidgets().viewAllServices(
                                onTap: () {
                                  Get.to(MyAppointmentsTabs());
                                },
                                color: AppColors.primaryColor,
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox();
                        }
                      }),
                  // ValueListenableBuilder<List<DoctorModel>>(
                  // valueListenable: TeleConsultationFunctionsAndVariables.doctors,
                  // builder: (_, val, __) {
                  ValueListenableBuilder<List<CompletedAppointment>>(
                      valueListenable: approvedAndUpcomingList,
                      builder: (_, List<CompletedAppointment> val, __) {
                        if (val.isNotEmpty && val != null) {
                          return SizedBox(
                            height: 30.h,
                            width: 94.w,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(top: 8.0, bottom: 9.0),
                                itemCount: val.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return CardMyAppointments(
                                    ConsultationId: val[index].ihlConsultantId.toString(),
                                    vendor_id: val[index].vendorId,
                                    consultant_name: val[index].consultantName,
                                    appointment_start_time: val[index].appointmentStartTime,
                                    appointment_end_time: val[index].appointmentEndTime,
                                    booked_date_time: val[index].bookedDateTime,
                                    appointment_id: val[index].appointmentId,
                                    call_status: val[index].callStatus,
                                    valConsult: val[index],
                                  );
                                }),
                          );
                        } else {
                          return const SizedBox();
                        }
                      }),

                  const MediFile(),
                  SizedBox(
                    height: 10.h,
                  )
                ],
              ),
            ),
          )
        ]),
      );
    }
  }
}

class MediFile extends StatefulWidget {
  const MediFile({Key key}) : super(key: key);

  @override
  State<MediFile> createState() => _MediFileState();
}

class _MediFileState extends State<MediFile> {
  // bool isVisible = false;
  final ValueNotifier<bool> isVisible = ValueNotifier<bool>(false);

  List<String> filesNameList = <String>[];
  final ValueNotifier<bool> fileSelected = ValueNotifier<bool>(false);

  // bool fileSelected = false;
  PlatformFile file;
  String _chosenType = 'others';
  FilePickerResult result;
  ValueNotifier<String> fileNametext = ValueNotifier<String>('');
  TextEditingController fileNameController = TextEditingController();
  CroppedFile croppedFile;
  File _image;
  final ImagePicker picker = ImagePicker();
  bool isImageSelectedFromCamera = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
              child: Text(
                AppTexts.MyMedicalFiles,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.36),
            TeleConsultationWidgets().viewAllServices(
              onTap: () {
                Get.to(MyMedicalFiles(medicalFiles: false, normalFlow: true));
              },
              profileCheckUp: false,
              color: AppColors.primaryColor,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 9.0, top: 6.0, right: 6.0),
          child: FittedBox(
              child: Text(
            "Upload your medical files for your consultants reference",
            style: TextStyle(fontSize: 17.sp),
          )),
        ),
        Stack(children: <Widget>[
          SizedBox(
            width: 95.w,
            height: 18.h,
            child: Padding(
              padding: EdgeInsets.only(top: 20.sp),
              child: DottedBorder(
                  dashPattern: const <double>[6, 4],
                  borderType: BorderType.Rect,
                  color: Colors.black,
                  strokeWidth: 1,
                  child: GestureDetector(
                    onTap: () {
                      isVisible.value = !isVisible.value;
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('newAssets/upload.png', width: 20.sp, height: 20.sp),
                          TextButton(
                            onPressed: () {
                              isVisible.value = !isVisible.value;
                            },
                            child: Text(
                              'Upload your files here',
                              style: TextStyle(fontSize: 15.sp, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ),
          ),
          ValueListenableBuilder<bool>(
              valueListenable: isVisible,
              builder: (BuildContext context, bool value, Widget child) {
                return Visibility(
                  visible: value,
                  replacement: const SizedBox(),
                  child: Center(
                    child: SizedBox(
                      width: 88.w,
                      // height: 20.h,
                      child: InkWell(
                        onTap: () {
                          isVisible.value = !isVisible.value;
                        },
                        child: Card(
                          elevation: 4,
                          child: Column(
                            children: <Widget>[
                              const Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.close,
                                      color: AppColors.primaryColor,
                                      size: 20,
                                    ),
                                  )),
                              Center(
                                  child: OutlinedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0))),
                                  side: MaterialStateProperty.all(const BorderSide(
                                    color: AppColors.primaryColor,
                                  )),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(3.0),
                                  child: Text(
                                    'My Files',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                onPressed: () {
                                  // Get.to(MedicalFilesCategory());
                                  Get.to(MyMedicalFiles(medicalFiles: false, normalFlow: true));
                                },
                              )),
                              Center(
                                  child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 20.5, vertical: 5),
                                ),
                                child: const Text('Upload'),
                                onPressed: () {
                                  Get.to(showFileTypePicker(context));
                                },
                              )),
                              const Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.transparent,
                                      size: 20,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              })
        ]),
      ],
    );
  }

  Widget showFileTypePicker(BuildContext context) {
    // ignore: missing_return
    String fileNameValidator(String ip) {
      if (ip == null) {
        return null;
      }
      if (ip.isEmpty) {
        return 'File Name is required';
      }
      if (ip.length < 4) {
        return 'File Name should be at least 4 character long';
      }
      if (filesNameList.contains(ip)) {
        return 'File Name should be Unique';
      }
    }

    filesNameList.clear();
    for (AllMedicalFiles e in TeleConsultationFunctionsAndVariables.medFilesList.value) {
      String name;
      if (e.documentName.toString().contains('.')) {
        String parse1 = e.documentName.toString().replaceAll('.jpg', '');
        String parse2 = parse1.replaceAll('.jpeg', '');
        String parse3 = parse2.replaceAll('.png', '');
        String parse4 = parse3.replaceAll('.pdf', '');
        name = parse4;
      }
      filesNameList.add(name);
    }
    fileNameController.clear();
    return CommonScreenForNavigation(
        contentColor: '',
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              Get.back();
            }, //replaces the screen to Main dashboard
            color: Colors.white,
          ),
          title: const Text("Upload new files"),
          backgroundColor: AppColors.primaryColor,
        ),
        content: SizedBox(
          height: 100.h,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter mystate) {
              return ValueListenableBuilder<bool>(
                  valueListenable: fileSelected,
                  builder: (BuildContext context, bool v, Widget child) {
                    return Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            v == false
                                ? Padding(
                                    padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                                    child: const AutoSizeText(
                                      // 'Select File Type',
                                      'Upload File',
                                      style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.left,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                                    child: AutoSizeText(
                                      "${fileNametext.value}.${isImageSelectedFromCamera ? 'jpg' : file != null ? file.extension : "jpg"}",
                                      style: const TextStyle(
                                          color: Colors.black, //AppColors.primaryColor
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                            Visibility(
                              visible: v == false,
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
                                  child: ValueListenableBuilder<String>(
                                      valueListenable: fileNametext,
                                      builder: (BuildContext context, String val, Widget child) {
                                        return TextFormField(
                                          controller: fileNameController,
                                          // validator: (v) {
                                          //   return fileNameValidator(v);
                                          // },
                                          onChanged: (String value) {
                                            fileNametext.value = value;
                                          },
                                          // maxLength: 150,
                                          autocorrect: true,
                                          // scrollController: Scrollable,
                                          autofocus: true,
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 18),
                                            labelText: "Enter file name",
                                            errorText: fileNameValidator(fileNametext.value),
                                            fillColor: Colors.white24,
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15.0),
                                                borderSide:
                                                    const BorderSide(color: Colors.blueGrey)),
                                          ),
                                          maxLines: 1,
                                          style: const TextStyle(fontSize: 16.0),
                                          textInputAction: TextInputAction.done,
                                        );
                                      })),
                            ),
                            v == false
                                ? Padding(
                                    padding:
                                        const EdgeInsets.all(10.0).copyWith(left: 24, right: 24),
                                    child: DropdownButton<String>(
                                      focusColor: Colors.white,
                                      value: _chosenType,
                                      isExpanded: true,
                                      underline: Container(
                                        height: 2.0,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              // color: widget.mealtype!=null?HexColor(widget.mealtype.startColor):AppColors.primaryColor,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(color: Colors.white),
                                      iconEnabledColor: Colors.black,
                                      items: <String>[
                                        'lab_report',
                                        'x_ray',
                                        'ct_scan',
                                        'mri_scan',
                                        'others'
                                      ].map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            camelize(value.replaceAll('_', ' ')),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      hint: const Text(
                                        "Select File Type",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      onChanged: (String value) {
                                        mystate(() {
                                          _chosenType = value;
                                        });
                                      },
                                    ),
                                  )
                                : Row(
                                    children: <Widget>[
                                      MaterialButton(
                                        child: const Text(
                                          'Change',
                                          style: TextStyle(
                                              color:
                                                  AppColors.primaryColor, //AppColors.primaryColor
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () {
                                          //open file explorer again
                                          sheetForSelectingReport(context);
                                        },
                                      ),
                                      MaterialButton(
                                        child: const Text(
                                          'Confirm',
                                          style: TextStyle(
                                              color:
                                                  AppColors.primaryColor, //AppColors.primaryColor
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () async {
                                          //pop
                                          Navigator.pop(context);
                                          // Navigator.pop(context);
                                          // if (this.mounted) {
                                          //   setState(() {
                                          fileSelected.value = false;
                                          //   });
                                          // }

                                          ///send this payload diffrently if file selected from camera
                                          if (isImageSelectedFromCamera) {
                                            String n = croppedFile.path
                                                .substring(croppedFile.path.lastIndexOf('/') + 1);
                                            await TeleConsultationFunctionsAndVariables
                                                .getUploadMedicalDocumentList(
                                                    filename: n,
                                                    extension: 'jpg',
                                                    path: croppedFile.path,
                                                    chooseType: _chosenType,
                                                    fileNametext: fileNametext.value,
                                                    context: context);
                                            // medFiles = await MedicalFilesApi.getFiles();

                                            await TeleConsultationFunctionsAndVariables
                                                .allMedicalFilesList();

                                            Get.snackbar('Uploaded!',
                                                '${camelize('${fileNametext.value}.jpg')} uploaded successfully.',
                                                icon: const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Icon(Icons.check_circle,
                                                        color: Colors.white)),
                                                margin:
                                                    const EdgeInsets.all(20).copyWith(bottom: 40),
                                                backgroundColor: AppColors.primaryAccentColor,
                                                colorText: Colors.white,
                                                duration: const Duration(seconds: 5),
                                                snackPosition: SnackPosition.BOTTOM);
                                            // uploadDocuments(n, 'jpg', croppedFile.path);
                                          } else {
                                            if (result != null) {
                                              await TeleConsultationFunctionsAndVariables
                                                  .getUploadMedicalDocumentList(
                                                      filename: result.files.first.name,
                                                      extension: result.files.first.extension,
                                                      path: result.files.first.path,
                                                      chooseType: _chosenType,
                                                      fileNametext: fileNametext.value,
                                                      context: context);
                                            } else {
                                              String filename = croppedFile.path
                                                  .substring(croppedFile.path.lastIndexOf('/') + 1);
                                              await TeleConsultationFunctionsAndVariables
                                                  .getUploadMedicalDocumentList(
                                                      filename: filename,
                                                      extension: 'jpg',
                                                      path: croppedFile.path,
                                                      chooseType: _chosenType,
                                                      fileNametext: fileNametext.value,
                                                      context: context);
                                            }

                                            for (int i = 0;
                                                i <
                                                    TeleConsultationFunctionsAndVariables
                                                        .medFilesList.value.length;
                                                i++) {
                                              String name;
                                              if (TeleConsultationFunctionsAndVariables
                                                  .medFilesList.value[i].documentName
                                                  .toString()
                                                  .contains('.')) {
                                                String parse1 =
                                                    TeleConsultationFunctionsAndVariables
                                                        .medFilesList.value[i].documentName
                                                        .toString()
                                                        .replaceAll('.jpg', '');
                                                String parse2 = parse1.replaceAll('.jpeg', '');
                                                String parse3 = parse2.replaceAll('.png', '');
                                                String parse4 = parse3.replaceAll('.pdf', '');
                                                name = parse4;
                                              }
                                              filesNameList.add(name);
                                            }
                                            await TeleConsultationFunctionsAndVariables
                                                .allMedicalFilesList();
                                            Get.snackbar('Uploaded!',
                                                '${camelize('${fileNametext.value}${result == null ? ".jpeg" : result.files.first.extension.toLowerCase()}')} uploaded successfully.',
                                                icon: const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Icon(Icons.check_circle,
                                                        color: Colors.white)),
                                                margin:
                                                    const EdgeInsets.all(20).copyWith(bottom: 40),
                                                backgroundColor: AppColors.primaryAccentColor,
                                                colorText: Colors.white,
                                                duration: const Duration(seconds: 5),
                                                snackPosition: SnackPosition.BOTTOM);
                                            // uploadDocuments(result.files.first.name,
                                            //     result.files.first.extension, result.files.first.path);
                                          }

                                          // showDialog(
                                          //   context: context,
                                          //   barrierDismissible: false,
                                          //   builder: (ctx) => AlertDialog(
                                          //     title: Text("Uploading..."),
                                          //     content: Text("Please Wait. The File is Uploading..."),
                                          //     actions: <Widget>[
                                          //       CircularProgressIndicator(),
                                          //       // FlatButton(
                                          //       //   onPressed: () {
                                          //       //     Navigator.of(ctx).pop();
                                          //       //   },
                                          //       //   child: Text("okay"),
                                          //       // ),
                                          //     ],
                                          //   ),
                                          // );

                                          fileNameController.clear();
                                        },
                                      ),
                                    ],
                                  ),
                            Visibility(
                              visible: v == false,
                              child: Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    backgroundColor: AppColors.primaryAccentColor,
                                    textStyle: TextStyle(
                                        fontSize: ScUtil().setSp(14), fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    //open file picker
                                    if (fileNameValidator(fileNametext.value) == null &&
                                        fileNametext.value.isNotEmpty) {
                                      // Navigator.of(context).pop();
                                      sheetForSelectingReport(context);
                                    } else {
                                      fileNameValidator(fileNametext.value);
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    }
                                  },
                                  child: Text(
                                    ' Upload ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                        fontSize: ScUtil().setSp(16)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: ScUtil().setHeight(60)),
                          ],
                        ),
                      ),
                    );
                  });
            },
          ),
        ));
  }

  sheetForSelectingReport(BuildContext context) {
    // ignore: missing_return
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter mystate) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Platform.isIOS
                      ? ListTile(
                          title: const Text('Select Report From Storage'),
                          leading: const Icon(Icons.image),
                          onTap: () {
                            sheetForSelectingPdfOrImageIos(context);
                          },
                        )
                      : ListTile(
                          title: const Text('Select Report From Storage'),
                          leading: const Icon(Icons.image),
                          onTap: () async {
                            bool status = await CheckPermissions.filePermissions(context);
                            if (status) {
                              _openFileExplorer();
                            }
                          },
                        ),
                  ListTile(
                    title: const Text('Capture Report From Camera'),
                    leading: const Icon(Icons.camera_alt_outlined),
                    onTap: () async {
                      bool status = await CheckPermissions.cameraPermissions(context);
                      if (status) {
                        await _imgFromCamera();
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                        // ignore: use_build_context_synchronously
                        showFileTypePicker(context);
                        fileSelected.value = true;
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  sheetForSelectingPdfOrImageIos(BuildContext context) {
    // ignore: missing_return
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter mystate) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: const Text('Pdf'),
                    leading: const Icon(Icons.picture_as_pdf_rounded),
                    onTap: () {
                      _openFileExplorer();
                    },
                  ),
                  ListTile(
                    title: const Text('Image'),
                    leading: const Icon(Icons.image),
                    onTap: () {
                      onGallery(context);
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void onGallery(BuildContext cont) async {
    var permission = Permission.photos;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print(androidInfo.version.release);
      print(int.parse(androidInfo.version.release) <= 12);
      if (int.parse(androidInfo.version.release) <= 12) {
        permission = Permission.storage;
      }
    }
    if (await permission.request().isGranted) {
      getIMG(source: ImageSource.gallery, context: cont);
      //Navigator.of(context).pop();
    } else if (await permission.request().isDenied) {
      await permission.request();
      Get.snackbar('Gallery Access Denied', 'Allow Photos/Storage permission to continue',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          isDismissible: false,
          mainButton: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Allow')));
    } else {
      Get.snackbar('Gallery Access Denied', 'Allow Photos/Storage permission to continue',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          isDismissible: false,
          mainButton: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Allow')));
    }
  }

  Future<File> getIMG({ImageSource source, BuildContext context}) async {
    File fromPickImage = await _pickImage(context: context, source: source);
    if (fromPickImage != null) {
      File cropped = await crop(fromPickImage);
      print(cropped.path);
      //upload(cropped, context);
      if (cropped != null) {
        croppedFile = CroppedFile(cropped.path);
        if (this.mounted) {
          setState(() {
            fileSelected.value = true;
          });
        }
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
        showFileTypePicker(context);
      }
    } else {}
  }

  Future<File> _pickImage({ImageSource source, BuildContext context}) async {
    final picked = await ImagePicker().getImage(
      source: source,
      maxHeight: 720,
      maxWidth: 720,
      imageQuality: 80,
    );

    if (picked != null) {
      File selected = await FlutterExifRotation.rotateImage(path: picked.path);
      if (selected != null) {
        return selected;
      }
    }
  }

  Future<File> crop(File selectedfile) async {
    try {
      File toSend;
      await ImageCropper().cropImage(sourcePath: selectedfile.path, uiSettings: [
        AndroidUiSettings(
          lockAspectRatio: false,
          activeControlsWidgetColor: AppColors.primaryAccentColor,
          backgroundColor: AppColors.backgroundScreenColor,
          toolbarColor: AppColors.primaryAccentColor,
          toolbarWidgetColor: Colors.white,
          toolbarTitle: 'Crop Image',
        ),
        IOSUiSettings(
          title: 'Crop image',
        )
      ]).then((value) => toSend = File(value.path));
      isImageSelectedFromCamera = false;
      if (toSend == null) {
        return selectedfile;
      } else
        return toSend;
    } catch (e) {
      return selectedfile;
    }
  }

  _imgFromCamera() async {
    // ignore: deprecated_member_use
    final PickedFile pickedFile = await picker.getImage(source: ImageSource.camera);
    _image = File(pickedFile.path);
    croppedFile = await ImageCropper().cropImage(
        sourcePath: _image.path,
        aspectRatio: const CropAspectRatio(ratioX: 12, ratioY: 16),
        maxWidth: 512,
        maxHeight: 512,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 60,
        uiSettings: <PlatformUiSettings>[
          AndroidUiSettings(
            lockAspectRatio: false,
            activeControlsWidgetColor: AppColors.primaryAccentColor,
            toolbarTitle: 'Crop the Image',
            toolbarColor: const Color(0xFF19a9e5),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(title: 'Crop the Image', aspectRatioLockEnabled: true)
        ]);

    // if (this.mounted) {
    //   setState(() {
    // List<int> imageBytes = File(croppedFile.path).readAsBytesSync();
    // String im = croppedFile.path;
    isImageSelectedFromCamera = true;

    ///instead of image selected write here the older variable file selected = true, okay and than remove this file
    fileSelected.value = true;
    //   });
    // }
  }

  Future<void> _openFileExplorer() async {
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['jpg', 'pdf'],
    );
    // FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      file = result.files.first;
      fileSelected.value = true;
      isImageSelectedFromCamera = false;
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      showFileTypePicker(context);
    } else {
      // User canceled the picker
    }
  }
}
