import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../Modules/online_class/bloc/trainer_status/bloc/trainer_bloc.dart';
import '../../../Modules/online_class/functionalities/upcoming_courses.dart';
import '../../../Modules/online_class/presentation/widgets/join_call_widget.dart';
import '../../presentation/pages/onlineServices/teleconsultation_underonlineServiceTab.dart';
import 'data/model/get_specality_module.dart';
import 'presentation/online_class_screens/book_class_after_subscription.dart';
import 'bloc/search_animation_bloc/courseDetailBloc/courseDetailBloc.dart';
import 'presentation/online_class_screens/class_search.dart';
import '../../app/utils/appText.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Modules/online_class/bloc/online_class_api_bloc.dart';
import '../../../Modules/online_class/bloc/online_class_state.dart';
import '../../../Modules/online_class/presentation/pages/view_all_class.dart';
import '../../data/model/TeleconsultationModels/appointmentModels.dart';
import '../../presentation/Widgets/dashboardWidgets/teleconsultation_widget.dart';
import '../../presentation/pages/onlineServices/DashboardMyAppointments.dart';
import '../../presentation/pages/onlineServices/myAppointmentsTabs.dart';
import 'data/model/get_consultant_list.dart';
import 'presentation/online_services_widgets/online_services_widgets.dart';
import '../../../utils/SpUtil.dart';
import '../../app/utils/appColors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../Modules/online_class/presentation/widgets/online_service_widgets.dart';
import '../../app/utils/constLists.dart';
import '../../app/utils/localStorageKeys.dart';
import '../../presentation/Widgets/appBar.dart';
import '../../presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../../presentation/pages/onlineServices/SearchByDocAndList.dart';
import '../../presentation/pages/onlineServices/SearchBySpecAndList.dart';
import 'bloc/online_services_api_bloc.dart';
import 'bloc/online_services_api_state.dart';
import 'functionalities/online_services_dashboard_functionalities.dart';

class OnlineServicesDashboard extends StatefulWidget {
  const OnlineServicesDashboard({Key key}) : super(key: key);

  @override
  State<OnlineServicesDashboard> createState() => _OnlineServicesDashboardState();
}

class _OnlineServicesDashboardState extends State<OnlineServicesDashboard> {
  OnlineClassWidgets onlineClassWidgets = OnlineClassWidgets();

  OnlineServicesFunctions onlineClassMethods = OnlineServicesFunctions();

  OnlineServicesWidgets onlineServicesWidgets = OnlineServicesWidgets();

  Timer t;
  ValueNotifier<int> searchAnimation = ValueNotifier<int>(0);

  @override
  void initState() {
    t = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (searchAnimation.value != 3) {
        searchAnimation.value++;
      } else {
        searchAnimation.value = 0;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    contextForJoincall = context;
    return WillPopScope(
      onWillPop: () {
        return null;
      },
      child: CommonScreenForNavigation(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarOpacity: 0,
          toolbarHeight: 7.5.h,
          flexibleSpace: const CustomeAppBar(screen: ProgramLists.commonList),
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.unSelectedColor,
        ),
        content: Padding(
          padding: EdgeInsets.only(left: 14.sp, right: 14.sp, bottom: 14.sp, top: 8.sp),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 2.h),
                ValueListenableBuilder<int>(
                    valueListenable: searchAnimation,
                    builder: (BuildContext context, int value, Widget child) {
                      return InkWell(
                        onTap: () => searchByNav(value: value),
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
                                        color: Colors.grey,
                                        letterSpacing: 0.7,
                                        fontFamily: "Poppins"),
                                    child: Text(searchBytext(value: value)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                SizedBox(height: .8.h),
                BlocBuilder<OnlineServicesApiBloc, OnlineServicesState>(
                  builder: (BuildContext ctx, OnlineServicesState state) {
                    List<String> specList = <String>[];
                    List<String> mergedList = <String>[];
                    if (state is ApiCallLoadingState) {
                      return Column(
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[shimmer(), shimmer()]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[shimmer(), shimmer()]),
                        ],
                      );
                    }
                    List classSpeclist = [];
                    if (state is ApiCallLoadedState) {
                      state.classSpec.specialityList
                          .forEach((OnlineServicesSpecialityList element) {
                        classSpeclist.add(element.specialityName);
                      });
                      specList = onlineClassMethods.mergeSpec(
                        state.docSpec.specialityList,
                        state.classSpec.specialityList,
                      );
                      mergedList = onlineClassMethods.mergeFullSpec(
                        state.docSpec.specialityList,
                        state.classSpec.specialityList,
                      );
                    }

                    return state is ApiCallLoadedState
                        ? (!SpUtil.getBool(LSKeys.affiliation) ?? false)
                            ? onlineServicesWidgets.specialtyCard(context,
                                specialtyList: specList,
                                length: specList.length,
                                fullMrgedList: mergedList,
                                data: classSpeclist)
                            : onlineServicesWidgets.CategoryCard(context)
                        : Container(height: 40.h);
                  },
                ),
                BlocBuilder<SubscrptionFilterBloc, SubscriptionFilterState>(
                    builder: (BuildContext context, SubscriptionFilterState state) {
                  return Visibility(
                    visible: state is FilterLoadedState ? state.subscriptionList.isEmpty : false,
                    child: Column(
                      children: [
                        onlineClassWidgets.sectionHeader(context, "My Subscription", () {
                          state is FilterLoadedState
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                      builder: (BuildContext ctx) => MultiBlocProvider(
                                            providers: [
                                              BlocProvider(
                                                  create: (BuildContext context) => TrainerBloc()),
                                            ],
                                            child: ViweAllClass(
                                              subcriptionList: state.subscriptionList,
                                            ),
                                          )),
                                )
                              : null;
                        }),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                          child: onlineClassWidgets.onlineClassDetails(
                              context,
                              state is FilterLoadedState
                                  ? () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                              builder: (BuildContext ctx) => MultiBlocProvider(
                                                    providers: [
                                                      BlocProvider(
                                                          create: (BuildContext context) =>
                                                              TrainerBloc()),
                                                    ],
                                                    child: ViweAllClass(
                                                      subcriptionList: state.subscriptionList,
                                                    ),
                                                  )));
                                    }
                                  : () {}),
                        ),
                      ],
                    ),
                  );
                }),
                BlocBuilder<StreamOnlineServicesApiBloc, StreamOnlineServicesState>(
                    builder: (BuildContext ctx, StreamOnlineServicesState state) {
                  if (state is StreamApiLoadingState) {
                    return Column(
                      children: [
                        onlineClassWidgets.sectionHeader(context, "My Appointments", null),
                        Shimmer.fromColors(
                          baseColor: Colors.white,
                          highlightColor: Colors.grey.withOpacity(0.3),
                          direction: ShimmerDirection.ltr,
                          child: Container(
                            width: 90.w,
                            height: 25.h,
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
                      ],
                    );
                  }
                  if (state is StreamApiLoadedState) {
                    List<CompletedAppointment> val = state.appoinmtmentList.appointments;

                    return Visibility(
                      visible: state is StreamApiLoadedState
                          ? state.appoinmtmentList.appointments.isEmpty
                          : false,
                      child: Column(
                        children: <Widget>[
                          onlineClassWidgets.sectionHeader(context, "My Appointments", () {
                            state is StreamApiLoadedState ? Get.to(MyAppointmentsTabs()) : null;
                          }),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                            child: onlineClassWidgets.teleConsulationDetails(
                                context,
                                state is StreamApiLoadedState
                                    ? () {
                                        Get.to(MyAppointmentsTabs());
                                      }
                                    : () {}),
                          ),
                        ],
                      ),
                    );
                  }
                  return Container();
                }),
                BlocBuilder<SubscrptionFilterBloc, SubscriptionFilterState>(
                    builder: (BuildContext context, SubscriptionFilterState state) {
                  if (state is FilterLoadingState) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: SizedBox(
                        height: 25.h,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(bottom: 5.0),
                            itemCount: 3,
                            itemBuilder: (BuildContext context, int index) {
                              return Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: Colors.grey.withOpacity(0.3),
                                direction: ShimmerDirection.ltr,
                                child: Container(
                                  width: 75.w,
                                  height: 15.h,
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
                            }),
                      ),
                    );
                  }
                  if (state is FilterLoadedState) {
                    if (state.subscriptionList.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          onlineClassWidgets.sectionHeader(context, "My Subscription", () {
                            Navigator.push(
                                context,
                                MaterialPageRoute<dynamic>(
                                    builder: (BuildContext ctx) => MultiBlocProvider(
                                            providers: [
                                              BlocProvider(
                                                  create: (BuildContext context) => TrainerBloc())
                                            ],
                                            child: ViweAllClass(
                                                subcriptionList: state.subscriptionList))));
                          }),
                          Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                  height: 32.h,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: state.subscriptionList.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return GestureDetector(
                                          onTap: () {
                                            UpcomingCourses().trainerStatusFromFirebase(
                                                context.read,
                                                state.subscriptionList[index].courseId);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext context) =>
                                                        MultiBlocProvider(
                                                          providers: [
                                                            BlocProvider(
                                                                create: (BuildContext context) =>
                                                                    CourseDetailBloc()
                                                                      ..add(CourseEventTrigger(
                                                                          courseID: state
                                                                              .subscriptionList[
                                                                                  index]
                                                                              .courseId)))
                                                          ],
                                                          child: BookClassAfterSubscription(
                                                            joinCallWidget: joinCallwidget(
                                                              subcriptionList:
                                                                  state.subscriptionList[index],
                                                              ui: const Text('data'),
                                                              noTime: true,
                                                            ),
                                                            classDetail:
                                                                state.subscriptionList[index],
                                                          ),
                                                        )));
                                          },
                                          child: Padding(
                                              padding: EdgeInsets.all(8.sp),
                                              child: onlineClassWidgets.cardDetailsWidget(
                                                  context, state.subscriptionList[index])),
                                        );
                                      })))
                        ],
                      );
                    } else {
                      debugPrint("There is no subscription for this id");
                      return const SizedBox();
                    }
                  }
                  return const SizedBox();
                }),
                BlocBuilder<OnlineServicesApiBloc, OnlineServicesState>(
                    builder: (BuildContext ctx, OnlineServicesState state) {
                  if (state is ApiCallLoadingState) {
                    return Column(
                      children: <Widget>[
                        onlineClassWidgets.sectionHeader(context, AppTexts.doctor, null),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: SizedBox(
                            height: 23.h,
                            width: 75.h,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(bottom: 5.0),
                                itemCount: 3,
                                itemBuilder: (BuildContext context, int index) {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.white,
                                    highlightColor: Colors.grey.withOpacity(0.3),
                                    direction: ShimmerDirection.ltr,
                                    child: Container(
                                      width: 70.w,
                                      height: 20.h,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(8.0),
                                          bottomLeft: Radius.circular(8.0),
                                          topLeft: Radius.circular(8.0),
                                          topRight: Radius.circular(8.0),
                                        ),
                                        color: Colors.red,
                                      ),
                                      margin:
                                          const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                      child: const Text('Hello'),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ],
                    );
                  }
                  if (state is ApiCallLoadedState) {
                    List<ConsultantList> val = state.consultantList.consultantList;
                    return Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 13.0, right: 2.0, top: 12.0, bottom: 6.0),
                              child: Text(
                                AppTexts.doctor,
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
                                Get.to(SearchByDocAndList());
                              },
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: SizedBox(
                            height: 23.h,
                            width: 75.h,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                                itemCount: val.length,
                                itemBuilder: (BuildContext context, int index) {
                                  List<String> consultantSpeciality = <String>[];
                                  for (int i = 0; i < val[index].consultantSpeciality.length; i++) {
                                    consultantSpeciality.add(val[index].consultantSpeciality[i]);
                                  }
                                  return onlineClassWidgets.doctorCardDashboard(
                                      consultant: val[index],
                                      consultantSpeciality: consultantSpeciality);
                                }),
                          ),
                        ),
                      ],
                    );
                  }
                  return Container();
                }),
                BlocBuilder<StreamOnlineServicesApiBloc, StreamOnlineServicesState>(
                    builder: (BuildContext ctx, StreamOnlineServicesState state) {
                  if (state is StreamApiLoadingState) {
                    return Column(
                      children: <Widget>[
                        onlineClassWidgets.sectionHeader(context, "My Appointments", null),
                        Padding(
                          padding: EdgeInsets.only(right: 10.px),
                          child: SizedBox(
                            height: 30.h,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(bottom: 5.0),
                                itemCount: 3,
                                itemBuilder: (BuildContext context, int index) {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.white,
                                    highlightColor: Colors.grey.withOpacity(0.3),
                                    direction: ShimmerDirection.ltr,
                                    child: Container(
                                      width: 45.w,
                                      height: 25.h,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(8.0),
                                          bottomLeft: Radius.circular(8.0),
                                          topLeft: Radius.circular(8.0),
                                          topRight: Radius.circular(8.0),
                                        ),
                                        color: Colors.red,
                                      ),
                                      margin:
                                          const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                      child: const Text('Hello'),
                                    ),
                                  );
                                }),
                          ),
                        )
                      ],
                    );
                  }
                  if (state is StreamApiLoadedState) {
                    List<CompletedAppointment> val = state.appoinmtmentList.appointments;
                    if (val.isNotEmpty && val != null) {
                      return Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0, bottom: 6.0, left: 14.0),
                                child: Text(
                                  AppTexts.MyAppointments,
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
                                  Get.to(MyAppointmentsTabs());
                                },
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 90.w,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: val.map((e) {
                                    return CardMyAppointments(
                                      ConsultationId: e.ihlConsultantId.toString(),
                                      vendor_id: e.vendorId,
                                      consultant_name: e.consultantName,
                                      appointment_start_time: e.appointmentStartTime,
                                      appointment_end_time: e.appointmentEndTime,
                                      booked_date_time: e.bookedDateTime,
                                      appointment_id: e.appointmentId,
                                      call_status: e.callStatus,
                                      valConsult: e,
                                    );
                                  }).toList()),
                            ),
                          ),
                          // Padding(
                          //   padding: EdgeInsets.only(left: 12.0),
                          //   child: SizedBox(
                          //     height: 100.h < 800 ? 40.h : 30.h,
                          //     width: 94.w,
                          //     child: ListView.builder(
                          //         shrinkWrap: true,
                          //         scrollDirection: Axis.horizontal,
                          //         padding: const EdgeInsets.only(top: 8.0, bottom: 9.0),
                          //         itemCount: val.length,
                          //         itemBuilder: (BuildContext context, int index) {
                          //           return CardMyAppointments(
                          //             ConsultationId: val[index].ihlConsultantId.toString(),
                          //             vendor_id: val[index].vendorId,
                          //             consultant_name: val[index].consultantName,
                          //             appointment_start_time: val[index].appointmentStartTime,
                          //             appointment_end_time: val[index].appointmentEndTime,
                          //             booked_date_time: val[index].bookedDateTime,
                          //             appointment_id: val[index].appointmentId,
                          //             call_status: val[index].callStatus,
                          //             valConsult: val[index],
                          //           );
                          //         }),
                          //   ),
                          // ),
                        ],
                      );
                    }
                  }
                  return Container();
                }),
                const Padding(
                  padding: EdgeInsets.only(left: 14.0, top: 8.0),
                  child: MediFile(),
                ),
                SizedBox(
                  height: 20.h,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget shimmer() {
    return Shimmer.fromColors(
        direction: ShimmerDirection.ltr,
        period: const Duration(seconds: 2),
        baseColor: Colors.white,
        highlightColor: Colors.grey.withOpacity(0.2),
        child: Container(
            margin: EdgeInsets.only(bottom: 14.sp),
            width: 40.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Hello')));
  }

  String searchBytext({int value}) {
    if (value == 0) {
      return "Search By Speciality Name";
    } else if (value == 1) {
      return "Search By Doctor Name";
    } else {
      return "Search By Class Name";
    }
  }

  void searchByNav({int value}) {
    if (value == 0) {
      Get.to(const SearchBySpecAndList());
    } else if (value == 1) {
      Get.to(SearchByDocAndList());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => ClassSearch(
                  selectedSpec: "Adventure Services",
                )),
      );
      // Get.to(ClassSearch());
    }
  }
}
