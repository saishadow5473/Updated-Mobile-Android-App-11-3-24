import 'dart:async';
import 'dart:convert';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:shimmer/shimmer.dart';
import '../../../../new_design/app/utils/appColors.dart';
import '../../../../new_design/app/utils/imageAssets.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../new_design/app/utils/appText.dart';
import '../../../../new_design/data/model/TeleconsultationModels/doctorModel.dart';

import '../../../../new_design/data/providers/network/apis/classImageApi/classImageApi.dart';
import '../../../../new_design/module/online_serivices/data/model/get_consultant_list.dart';
import '../../../../new_design/module/online_serivices/data/model/get_subscribtion_list.dart';
import '../../../../new_design/presentation/Widgets/dashboardWidgets/teleconsultation_widget.dart';

import '../../../../new_design/presentation/clippath/subscriptionTagClipPath.dart';
import '../../../../new_design/presentation/controllers/dashboardControllers/dashBoardContollers.dart';
import '../../../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../../../../new_design/presentation/pages/onlineServices/doctorsDescriptionScreen.dart';
import '../../data/model/getClassSpecalityModel.dart';
import '../../data/model/getClassSpecialityNameList.dart';

import '../../functionalities/upcoming_courses.dart';
import '../controllers/online_class_functions.dart';
import '../pages/view_all_class.dart';
import 'join_call_widget.dart';

class OnlineClassWidgets {
  final ImageProvider<Object> _newTeleDesImage = ImageAssets.newTeleDesImage;
  final ImageProvider<Object> _newOnlineClassDesImage = ImageAssets.newOnlineClassDesImage;
  Widget searchBar() {
    return Container(
      height: 5.h,
      width: 95.w,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(width: 0.2, color: Colors.black.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 3,
                spreadRadius: 3,
                offset: const Offset(0, 0))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, color: Colors.grey),
          if (true)
            Container(
              width: 65.w,
              margin: EdgeInsets.only(left: 8.px),
              alignment: Alignment.centerLeft,
              child: const AnimatedDefaultTextStyle(
                duration: Duration(seconds: 1),
                curve: Curves.bounceOut,
                style: TextStyle(color: Colors.grey, letterSpacing: 0.7, fontFamily: "Poppins"),
                child: Text(
                  "Search By Trainer or Class",
                ),
              ),
              // ,,
            ),
        ],
      ),
    );
  }

  Widget onlineClassDetails(
    BuildContext context,
    var onPress,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 47.5.w,
                  width: 95.w,
                  decoration: BoxDecoration(
                      color: AppColors.plainColor,
                      borderRadius: BorderRadius.circular(2),
                      image: DecorationImage(fit: BoxFit.cover, image: _newOnlineClassDesImage)),
                ),
                Container(
                  height: 9.h,
                  width: 95.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: AppColors.plainColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                        width: 60.w,
                        child: Text(
                          "Get a rundown of your past class subscriptions instantly.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textColor, fontSize: 15.sp),
                        )),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 16.h,
              left: 28.w,
              child: GestureDetector(
                onTap: onPress,
                child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      padding: EdgeInsets.all(10.sp),
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 18,
                            spreadRadius: 1,
                            offset: const Offset(0, 5))
                      ], color: const Color(0XFF19A9E5), borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        "View Subscriptions",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontSize: 13.sp,
                            fontFamily: "Poppins"),
                      ),
                    )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget teleConsulationDetails(BuildContext context, Function onPress) {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                    height: 47.5.w,
                    width: 95.w,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: AppColors.plainColor,
                        image: DecorationImage(fit: BoxFit.cover, image: _newTeleDesImage)),
                    child: InkWell(
                        onTap: onPress,
                        child: Container(
                            margin: EdgeInsets.only(bottom: 10.px),
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
                            child: Text("View Appointments",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    fontSize: 14.sp,
                                    fontFamily: "Poppins"))))),
                Container(
                  height: 9.h,
                  width: 95.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: AppColors.plainColor,
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                        width: 65.w,
                        child: Text(
                          "See past consultations to track your health improvements over time.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textColor, fontSize: 15.sp),
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget specialtyCard(BuildContext context, List<SpecialityList> specialtyList, int lenght) {
    ValueNotifier<List<SpecialityTypeList>> specList =
        ValueNotifier<List<SpecialityTypeList>>(<SpecialityTypeList>[]);
    return SizedBox(
      height: 9.h,
      width: 65.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: specialtyList.length,
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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
              onTap: () async {
                specList.value =
                    await OnlineClassFunctionsAndVariables.onlineClassConsultantsSpecialityfunc(
                        specialtyList[index].specialityName.toString());
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((BuildContext context) => ViewEachCategory(
                            viewClassCategoryList:
                                specList.value)))); //     specName: val[index].specialityName));
              },
              child: SizedBox(
                width: 52.w,
                height: 100.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 4.w,
                    ),
                    SizedBox(
                      height: 10.h,
                      width: 10.w,
                      child: Image.asset(
                        'newAssets/Icons/speciality/${specialtyList[index].specialityName}.png',
                        errorBuilder:
                            (BuildContext BuildContext, Object Object, StackTrace StackTrace) {
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
                      width: 9.w,
                    ),
                    SizedBox(
                        width: 28.w,
                        child: Text(
                          specialtyList[index].specialityName,
                          maxLines: 2,
                        ))
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget classStatusBar({String title, String selectedTile}) {
    bool selected = title == selectedTile;
    return Padding(
      padding: EdgeInsets.all(1.5.w),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(25),
                topLeft: Radius.circular(25),
                topRight: Radius.circular(0)),
            elevation: selected ? 0 : 3,
            child: ClipPath(
                clipper: const ShapeBorderClipper(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(25),
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(0)))),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 5.2.h,
                  width: 30.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: const Color(0XFFDCDBDB),
                      border: selected
                          ? Border(bottom: BorderSide(color: AppColors.primaryColor, width: 1.w))
                          : null),
                  padding: EdgeInsets.all(2.w),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15.sp),
                  ),
                )),
          ),
          SizedBox(height: 2.w)
        ],
      ),
    );
  }

  Widget sectionHeader(BuildContext context, String header, onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
            child: Text(
              header,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16.sp,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          // SizedBox(width: MediaQuery.of(context).size.width * 0.36),
          TeleConsultationWidgets().viewAllServices(
            onTap: onTap,
            // Get.to(SearchBySpecAndList());

            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget cardDetailsWidget(BuildContext context, Subscription subcriptionList) {
    Timer endTimer;
    Timer startTimer;
    UpcomingCourses().trainerStatusFromFirebase(context.read, subcriptionList.consultantId);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          elevation: 3.0,
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FutureBuilder(
                    future: ClassImage().getCourseImageURL([subcriptionList.courseId]),
                    builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        List<String> image = snapshot.data[0]['base_64'].split(',');
                        Uint8List bytes1;
                        bytes1 = const Base64Decoder().convert(image[1].toString());
                        if (bytes1 == null) {
                          return const Placeholder();
                        } else {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: .5.w, vertical: .5.h),
                            child: Container(
                              width: 66.w,
                              height: 20.5.h,
                              decoration: BoxDecoration(
                                color: const Color(0xff7c94b6),
                                border: Border.all(
                                    width: 0.7.w, color: AppColors.primaryColor.withOpacity(0.2)),
                                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                image: DecorationImage(
                                    image: Image.memory(base64Decode(image[1].toString())).image,
                                    fit: BoxFit.fill),
                              ),
                            ),
                          );
                        }
                      }
                      if (snapshot.hasError) {
                        return Shimmer.fromColors(
                          direction: ShimmerDirection.ltr,
                          enabled: true,
                          baseColor: Colors.white,
                          highlightColor: Colors.grey.shade300,
                          child: Container(
                            height: 20.5.h,
                            width: 65.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          direction: ShimmerDirection.ltr,
                          enabled: true,
                          baseColor: Colors.white,
                          highlightColor: Colors.grey.shade400,
                          child: Container(
                            height: 20.5.h,
                            width: 65.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                        // return Container(
                        //   child: Center(
                        //     child: CircularProgressIndicator(),
                        //   ),
                        // );
                      }
                      return Shimmer.fromColors(
                        baseColor: Colors.white,
                        direction: ShimmerDirection.ltr,
                        highlightColor: Colors.grey.withOpacity(0.2),
                        child: Container(
                          height: 20.5.h,
                          width: 65.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 5.h,
                    width: 50.w,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        subcriptionList.title.capitalizeFirst,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // const Spacer(),
                  Container(
                    padding: EdgeInsets.only(right: 7.px, left: 7.px, top: 1.px, bottom: 3.5.px),
                    child: joinCallwidget(
                      subcriptionList: subcriptionList,
                      ui: const Text('data'),
                      noTime: false,
                    ),
                  ),
                  // const Spacer(),
                ],
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 12.0),
          child: SizedBox(
            child: ClipPath(
              clipper: SubscriptionClipPath(),
              child: Container(
                color: AppColors.primaryAccentColor,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                    child: Text(
                      subcriptionList.feesFor,
                      style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 13.sp),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget aboutClass(
    BuildContext context,
    Subscription subcriptionList,
  ) {
    return CommonScreenForNavigation(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          centerTitle: true,
          title: const Text("About Class", style: TextStyle(color: Colors.white)),
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
        content: SingleChildScrollView(
          child: SizedBox(
            height: 100.h,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 14.sp, right: 14.sp, top: 15.sp, bottom: 25.sp),
                  child: FutureBuilder(
                    future: ClassImage().getCourseImageURL([subcriptionList.courseId]),
                    builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        List<String> image = snapshot.data[0]['base_64'].split(',');
                        Uint8List bytes1;
                        bytes1 = const Base64Decoder().convert(image[1].toString());
                        return bytes1 == null
                            ? const Placeholder()
                            : Container(
                                width: 90.w,
                                height: 23.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xff7c94b6),
                                  borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                  image: DecorationImage(
                                      image: Image.memory(
                                        base64Decode(image[1].toString()),
                                      ).image,
                                      fit: BoxFit.fill),
                                ),
                              );
                      }
                      if (snapshot.hasError) {
                        return Shimmer.fromColors(
                          direction: ShimmerDirection.ltr,
                          enabled: true,
                          baseColor: Colors.white,
                          highlightColor: Colors.grey.shade300,
                          child: Container(
                            width: 90.w,
                            height: 23.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          direction: ShimmerDirection.ltr,
                          enabled: true,
                          baseColor: Colors.white,
                          highlightColor: Colors.grey.shade400,
                          child: Container(
                            width: 90.w,
                            height: 23.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                        // return Container(
                        //   child: Center(
                        //     child: CircularProgressIndicator(),
                        //   ),
                        // );
                      }
                      return Shimmer.fromColors(
                        baseColor: Colors.white,
                        direction: ShimmerDirection.ltr,
                        highlightColor: Colors.grey.withOpacity(0.2),
                        child: Container(
                          width: 90.w,
                          height: 23.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 14.sp, right: 14.sp, top: 15.sp, bottom: 12.sp),
                  child: Text(
                    subcriptionList.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.5.sp,
                      color: const Color(0XFF19A9E5),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 14.sp, right: 14.sp, top: 15.sp, bottom: 20.sp),
                  child: Text(
                    subcriptionList.classDetail.name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

//This widget is used to show the doctors card in the online services main dashboard ✅
  Widget doctorCardDashboard({ConsultantList consultant, List<String> consultantSpeciality}) {
    return SizedBox(
      // height: 14.h,
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
              ihlConsultantId: consultant.ihlConsultantId.toString(),
              doctorDetails: DoctorModel.fromJson(consultant.toJson()),
            ));
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(9.sp),
                        child: FutureBuilder<String>(
                          future:
                              TabBarController().getConsultantImageUrl(doctor: consultant.toJson()),
                          builder: (BuildContext context, AsyncSnapshot<String> i) {
                            if (i.connectionState == ConnectionState.done) {
                              return Padding(
                                padding: EdgeInsets.all(5.sp),
                                child: Container(
                                  width: 25.w,
                                  height: 14.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff7c94b6),
                                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                    image: DecorationImage(
                                        image: Image.memory(
                                          base64Decode(i.data.toString()),
                                        ).image,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              );
                            } else if (i.connectionState == ConnectionState.waiting) {
                              return SizedBox(
                                width: 25.w,
                                height: 14.h,
                                child: Shimmer.fromColors(
                                  baseColor: Colors.white,
                                  highlightColor: Colors.grey.withOpacity(0.3),
                                  direction: ShimmerDirection.ltr,
                                  child: Container(
                                    width: 25.w,
                                    height: 14.h,
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
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 2.w,
                            ),
                            Icon(Icons.star, size: 13.px, color: AppColors.primaryColor),
                            SizedBox(width: 2.w),
                            Text("${consultant.ratings} Ratings", style: TextStyle(fontSize: 15.sp))
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 1.w,
                  ),
                  SizedBox(
                    width: 34.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: 32.w,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              consultant.name.toString(),
                              textAlign: TextAlign.start,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5.sp),
                              maxLines: 2,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 28.w,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              consultant.qualification == null
                                  ? "MBBS"
                                  : consultant.qualification.toString(),
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
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              consultantSpeciality
                                  .toString()
                                  .substring(1, consultantSpeciality.toString().length - 1),
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
                            consultant.experience.toString().contains('years')
                                ? '${consultant.experience} Experience'
                                : '${consultant.experience.toString()} yrs Experience',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14.sp),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
