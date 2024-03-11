import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../new_design/app/services/teleconsultation/teleconsultation_services.dart';
import '../../../../new_design/app/utils/appColors.dart';
import '../../../../new_design/data/model/TeleconsultationModels/doctorModel.dart';
import '../../../../new_design/data/model/retriveUpcomingDetails/upcomingDetailsModel.dart';
import '../../../../new_design/data/providers/network/apis/classImageApi/classImageApi.dart';

import '../../../../new_design/module/online_serivices/data/model/get_spec_class_list.dart';
import '../../../../new_design/module/online_serivices/presentation/online_class_screens/book_class_after_subscription.dart';
import '../../../../new_design/module/online_serivices/presentation/online_class_screens/book_class_before_subscription.dart';
import '../../../../new_design/presentation/clippath/subscriptionTagClipPath.dart';
import '../../../../new_design/presentation/controllers/dashboardControllers/dashBoardContollers.dart';
import '../../../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../../../../new_design/presentation/pages/onlineServices/doctorsDescriptionScreen.dart';
import '../../bloc/class_and_consultant_bloc/bloc/classandconsultantbloc_bloc.dart';
import '../../data/model/consultantAndClassListModel.dart';
import '../../functionalities/class_time_calculation.dart';
import 'class_detail_after_booking.dart';

// ignore: must_be_immutable
class ClassAndConsultantListPage extends StatelessWidget {
  final String category;
  ClassAndConsultantListPage({Key key, @required this.category}) : super(key: key);
  ScrollController scrollController;
  bool endReached = false;
  double lastPixel;
  ClassAndConsultantListModel datas;
  initialFunction(BuildContext ctx) {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent <= scrollController.position.pixels &&
          endReached == false &&
          datas.consultantAndClassTotalCount != datas.consultantAndClassList.length) {
        lastPixel = scrollController.position.pixels;
        endReached = true;
        log("Pagination Started");
        ctx.read<ClassandconsultantblocBloc>().add(GetClassandConsPaginationEvent(category, datas));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: AppBar(
        backgroundColor: AppColors.ihlPrimaryColor,
        title: Text(category),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 28.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      content: SizedBox(
        height: 100.h,
        width: 100.w,
        child: Column(
          children: <Widget>[
            SizedBox(
              child: SizedBox(
                height: 80.h,
                child: BlocBuilder<ClassandconsultantblocBloc, ClassandconsultantblocState>(
                  builder: (BuildContext ctx, ClassandconsultantblocState state) {
                    if (state is ClassandconsultantblocInitial) {
                      ctx
                          .read<ClassandconsultantblocBloc>()
                          .add(GetClassandConsultantEvent(category));
                      if (scrollController == null) {
                        initialFunction(ctx);
                      }
                      return SizedBox(
                        height: 50.h,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: <Widget>[
                              shimmer(),
                              const SizedBox(
                                height: 15,
                              ),
                              shimmer(),
                              const SizedBox(
                                height: 15,
                              ),
                              shimmer(),
                              const SizedBox(
                                height: 15,
                              ),
                              shimmer(),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (state is ClassandconsultantUpdated) {
                      datas = state.data;
                      endReached = false;
                      if (state.data.consultantAndClassList.isEmpty) {
                        return Container(
                            height: 100.h,
                            width: 100.w,
                            alignment: Alignment.center,
                            child: category != "Health E-Market"
                                ? const Text("No Consultant or Sessions Found")
                                : const Text("No Services Found"));
                      }
                      return SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.vertical,
                          child: classandconsultantsWidgets(state.data));
                    } else if (state is ClassandconsultantPagination) {
                      return SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.vertical,
                          child: classandconsultantsWidgets(state.datas, isFecthing: true));
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox shimmer() {
    return SizedBox(
      height: 22.h,
      width: 94.w,
      child: Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: Colors.grey.withOpacity(0.3),
        direction: ShimmerDirection.ltr,
        child: Container(
          height: 21.h,
          width: 93.w,
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
  }

//This is the common list view to show all the consultant and classes in a pagination format ✅
  Column classandconsultantsWidgets(ClassAndConsultantListModel data, {bool isFecthing}) {
    List<ConsultantAndClassList> b = data.consultantAndClassList;
    bool t = scrollController != null ? scrollController.hasClients : false;

    //These conditions are used to algin the list in the proper position ✅
    if (t && scrollController.position.maxScrollExtent < scrollController.position.pixels) {
      Future<void>.delayed(Duration.zero, () {
        scrollController.jumpTo(
            (scrollController.position.maxScrollExtent / data.consultantAndClassList.length) *
                (data.consultantAndClassList.length - 10));
      });
    }
    if (isFecthing ?? false) {
      Future<void>.delayed(Duration.zero, () {
        scrollController.jumpTo((scrollController.position.maxScrollExtent));
      });
    }
    return Column(children: <Widget>[
      SizedBox(height: 2.h),
      ...b.map((ConsultantAndClassList e) {
        if (e.type == 'consultant') {
          return consultantsWidgets(e);
        } else {
          return classesWidget(e);
        }
      }).toList(),
      if (isFecthing ?? false) shimmer(),
      SizedBox(height: 2.5.h),
    ]);
  }

//The below widget is used to show the consultant card✅
  Widget consultantsWidgets(ConsultantAndClassList data) {
    ConsultantDetail consultantDetail = data.consultantDetail;
    return SizedBox(
      // height: 23.5.h,
      width: 94.w,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 4,
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              Get.to(DoctorsDescriptionScreen(
                ihlConsultantId: data.consultantDetail.ihlConsultantId,
                doctorDetails: DoctorModel.fromJson(data.consultantDetail.toJson()),
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
                            .getConsultantImageUrl(doctor: consultantDetail.toJson()),
                        builder: (BuildContext context, AsyncSnapshot<String> i) {
                          if (i.connectionState == ConnectionState.done) {
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                  width: 25.w,
                                  height: 12.h,
                                  decoration: BoxDecoration(
                                      color: const Color(0xff7c94b6),
                                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                      image: DecorationImage(
                                          image: Image.memory(
                                            base64Decode(i.data.toString()),
                                          ).image,
                                          fit: BoxFit.cover))),
                            );
                          } else if (i.connectionState == ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: SizedBox(
                                width: 25.w,
                                height: 12.h,
                                child: Shimmer.fromColors(
                                  baseColor: Colors.white,
                                  highlightColor: Colors.grey.withOpacity(0.3),
                                  direction: ShimmerDirection.ltr,
                                  child: Container(
                                    width: 25.w,
                                    height: 12.h,
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
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    SizedBox(
                      width: 53.w,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SizedBox(
                            width: 52.w,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                consultantDetail.name,
                                textAlign: TextAlign.start,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5.sp),
                                maxLines: 3,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 35.w,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                data.consultantDetail.qualification == null
                                    ? "MBBS"
                                    : data.consultantDetail.qualification.toString(),
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
                                consultantDetail.consultantSpeciality.first,
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
                              '${consultantDetail.experience.toString().replaceAll("years", '')}years Experience',
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
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.star,
                        color: AppColors.primaryColor,
                        size: 18.px,
                      ),
                      SizedBox(width: 1.w),
                      Text("${consultantDetail.ratings} Ratings",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14.sp))
                    ],
                  ),
                ),
                SizedBox(height: 1.h)
              ],
            ),
          ),
        ),
      ),
    );
  }

//The below widget is used to show the class card✅
  Widget classesWidget(ConsultantAndClassList data) {
    ClassDetail classDetails = data.classDetail;

    //Returning the empty widget if the class is expired✅
    DateTime currentDateTime = DateTime.now();
    String courseDuration = classDetails.courseDuration;
    String courseEndDuration = courseDuration.substring(13, 23);
    int lastIndexValue = classDetails.courseTime.length - 1;
    String courseEndTimeFullValue = classDetails.courseTime[lastIndexValue]; //02:00 PM - 07:00 PM
    String courseEndTime = courseEndTimeFullValue.substring(
        courseEndTimeFullValue.indexOf("-") + 1, courseEndTimeFullValue.length); //07:00 PM
    courseEndDuration = courseEndDuration + courseEndTime; //20-04-2022 07:00 PM
    DateTime endDate;
    if (courseEndTime != " Invalid DateTime") {
      try {
        endDate = DateFormat("dd-MM-yyyy hh:mm a").parse(courseEndDuration);
      } catch (e) {
        endDate = DateFormat("MM-dd-yyyy hh:mm a").parse(courseEndDuration);
      }
    } else {
      endDate = DateTime.now().subtract(const Duration(days: 365));
    }

    if (endDate.isBefore(currentDateTime)) {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            InkWell(
              onTap: () {
                Get.to(BookClassbeforeSubscription(
                  classDetail: SpecialityClassList.fromJson(classDetails.toJson()),
                ));
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          offset: const Offset(1, 1),
                          spreadRadius: 4,
                          blurRadius: 5,
                          color: Colors.grey.shade300)
                    ]),
                child: FutureBuilder<dynamic>(
                  future: ClassImage().getCourseImageURL(<String>[classDetails.courseId]),
                  builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      List<String> image = snapshot.data[0]['base_64'].split(',');
                      Uint8List bytes1;
                      bytes1 = const Base64Decoder().convert(image[1].toString());
                      return bytes1 == null
                          ? const Placeholder()
                          : Padding(
                              padding: const EdgeInsets.only(top: 15, left: 15, right: 15.0),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    height: 15.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      color: const Color(0xff7c94b6),
                                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                      image: DecorationImage(
                                          image: Image.memory(
                                            base64Decode(image[1].toString()),
                                          ).image,
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            SizedBox(width: 75.w, child: Text(classDetails.title)),
                                            const Spacer(),
                                            const Text(
                                              '★ ',
                                              style: TextStyle(color: Colors.amber),
                                            ),
                                            Text(classDetails.ratings.toString()),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              "${classDetails.courseStatus.capitalizeFirst} ",
                                            ),
                                            Text(
                                              TimeCalculation()
                                                  .getClassStartTime(classDetails.courseTime.first),
                                              style: const TextStyle(color: Colors.blue),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        SizedBox(
                                            width: 75.w, child: Text(classDetails.consultantName)),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
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
                          height: 40.5.w,
                          width: 90.w,
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
                          height: 40.5.w,
                          width: 90.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }
                    return Shimmer.fromColors(
                      baseColor: Colors.white,
                      direction: ShimmerDirection.ltr,
                      highlightColor: Colors.grey.withOpacity(0.2),
                      child: Container(
                        height: 47.5.w,
                        width: 95.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              child: ClipPath(
                clipper: SubscriptionClipPath(),
                child: Container(
                  color: AppColors.primaryAccentColor,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text(
                        TeleConsultationServices().processString(classDetails.feesFor) ?? " ",
                        style:
                            TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 15.sp),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
